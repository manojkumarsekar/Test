#https://jira.pruconnect.net/browse/EISDEV-6163

@gc_interface_orders @gc_interface_bics @gc_interface_securities @gc_interface_request_reply
@dmp_regression_integrationtest
@eisdev_6163 @eisdev_6163_01
Feature: BICS Classification for BRS Orders

  This feature covers the request to BB for BICS classification and creating the outbound file to BRS:
  1. Load BRS Orders file containing 5 instruments.
  a)BPM0C6UC4 - 20MOON - BND - Requested to BB and response received
  b)BPM0MWN34 - 20MOON - BND - Requested to BB and response received
  c)TEST123 - 20MOON - BND - Unlisted Security not requested to BB
  d)TEST456 - 20MOON - EQUITY - Not belonging to the right SECGROUP, hence not requested to BB
  e)BPM0NPVT2 - 20MOON - BND - Requested to BB and response not received
  Out of the above securities, only a, b and e will be present in ISGP
  2. Publish outbound file with BICS data
  Out of the above securities, only a and b will be published with corresponding BICS
  3. Load BRS Orders file2 containing 4 instruments.
  a)BRSFPV233 - 20MOON - BND - Requested to BB and response received
  b)BES32M4A6 - 20MOON - BND - Requested to BB and response received
  c)BES34TBQ6 - ALGUMF - BND - Not belonging to the right PORTFOLIO, hence not requested to BB
  e)BPM0C6UC4 - 20MOON - BND - BICS value already present in DB, hence should not be requested to BB again
  Out of above securities, only a and b will be present in ISGP
  4. Publish outbound file with BICS data
  Out of the above securities, only a, b and e will be published with corresponding BICS

  Scenario: TC_1:Prerequisites before running actual tests and deleting existing BICS ISCL, inserting dummy job to not pickup old data

    Given I assign "tests/test-data/dmp-interfaces/BICS" to variable "testdata.path"
    And I execute below query to "Clear existing data for clean data setup"
    """
    ${testdata.path}/sql/01_BICS_ClearData.sql
    """
    And I assign "01_esi_orders.001.xml" to variable "INPUTFILE_NAME1"
    And I assign "01_esi_orders.002.xml" to variable "INPUTFILE_NAME2"

  Scenario: TC_2: Load 1st BRS Orders file

    When I process "${testdata.path}/InputFiles/${INPUTFILE_NAME1}" file with below parameters
      | FILE_PATTERN  | ${INPUTFILE_NAME1} |
      | MESSAGE_TYPE  | EIS_MT_BRS_ORDERS  |
      | BUSINESS_FEED |                    |

  Scenario: TC_3: Run BICS BB Wrapper Workflow with all parameters for Request Type EIS_Secmaster

    Given I assign "/dmp/in/bloomberg" to variable "BB_DOWNLOAD_DIR"
    And I assign "/dmp/out/bloomberg" to variable "BB_UPLOAD_DIR"
    And I assign "01_gs_secmaster_bic_template.out" to variable "RESPONSE_TEMPLATENAME"

    #This is to generate the response filename which is driven by database sequence
    And I execute below query and extract values of "SEQ" into same variables
        """
        SELECT LPAD(VREQ_FILE_SEQ.NEXTVAL+1,8,'0') AS SEQ FROM DUAL
        """
    #This is to generate the response filename taking sequence value from previous step.
    And I execute below query and extract values of "RESPONSE_FILE_NAME" into same variables
        """
        SELECT SUBSTR(FILE_PATTERN_TYP,0,INSTR(FILE_PATTERN_TYP,'*')-1)|| '${SEQ}' || '.out' AS RESPONSE_FILE_NAME
        FROM FT_CFG_VRTY
        WHERE VND_RQST_TYP = 'EIS_Secmaster'
        """

    # We are copying the response file on server because request reply workflow will generate request file and expect response file with same sequence number.
    # Since, we are not connecting to Bloomberg for testing this is to simulate the process of request reply
    When I copy files below from local folder "${testdata.path}/Template" to the host "dmp.ssh.inbound" folder "${BB_DOWNLOAD_DIR}":
      | ${RESPONSE_TEMPLATENAME} |

    And I rename file "${BB_DOWNLOAD_DIR}/${RESPONSE_TEMPLATENAME}" as "${BB_DOWNLOAD_DIR}/${RESPONSE_FILE_NAME}" in the named host "dmp.ssh.inbound"

    Given I assign "tests/test-data/intf-specs/gswf/template/EIS_BICSBBRequestReplyWrapper/request.xmlt" to variable "BICS_RR_WF"

    And I process the workflow template file "${BICS_RR_WF}" with below parameters and wait for the job to be completed
      | BB_DOWNLOAD_DIR      | ${BB_DOWNLOAD_DIR}          |
      | BB_UPLOAD_DIR        | ${BB_UPLOAD_DIR}            |
      | BB_FIRM_NAME         | dl790188                    |
      | GROUP_NAME           | BICSREQSOI                  |
      | BB_REQUEST_TYPE      | EIS_Secmaster               |
      | BB_SN                | 191305                      |
      | BB_USER_NUMBER       | 3650834                     |
      | WORK_STATION         | 0                           |
      | QUERY_NAME           | EIS_REFRESH_BB_BICS_SOI     |
      | BICS_EMAIL_RECEPIENT | raisa.dsouza@eastspring.com |
      | BICS_EMAIL_CC        | raisa.dsouza@eastspring.com |
      | UL_EMAIL_RECEPIENT   | raisa.dsouza@eastspring.com |
      | EMAIL_SENDER         | raisa.dsouza@eastspring.com |

    Then I expect below files to be present in the host "dmp.ssh.inbound" into folder "${BB_UPLOAD_DIR}" after processing:
      | gs_secmaster${SEQ}.req |

    And I expect value of column "BICS_SOI_COUNT" in the below SQL query equals to "3":
    """
     Select COUNT(*) AS BICS_SOI_COUNT FROM FT_T_ISGP
     WHERE prnt_iss_grp_oid='BICSREQSOI' and END_TMS IS NULL
    """

  Scenario: TC_4: Publish BICS outbound file

  #Assign Variables
    Given I assign "/dmp/out/brs/intraday" to variable "PUBLISHING_DIRECTORY"
    And I assign "esi_brs_sector_classification" to variable "PUBLISHING_FILE_NAME"
    And I generate value with date format "YYYYMMdd" and assign to variable "VAR_SYSDATE"

    Given I remove below files in the host "dmp.ssh.inbound" from folder "${PUBLISHING_DIRECTORY}" if exists:
      | ${PUBLISHING_FILE_NAME}*.csv |

    When I process publishing wrapper with below parameters and wait for the job to be completed
      | PUBLISHING_FILE_NAME | ${PUBLISHING_FILE_NAME}.csv |
      | SUBSCRIPTION_NAME    | EIS_DMP_TO_BRS_BICS_SUB     |

    Then I expect below files to be present in the host "dmp.ssh.inbound" into folder "${PUBLISHING_DIRECTORY}" after processing:
      | ${PUBLISHING_FILE_NAME}_${VAR_SYSDATE}_1.csv |

    Then I copy files below from remote folder "${PUBLISHING_DIRECTORY}" on host "dmp.ssh.inbound" into local folder "${testdata.path}/outfiles/runtime":
      | ${PUBLISHING_FILE_NAME}_${VAR_SYSDATE}_1.csv |

    And I remove below files in the host "dmp.ssh.inbound" from folder "${PUBLISHING_DIRECTORY}" if exists:
      | ${PUBLISHING_FILE_NAME}_${VAR_SYSDATE}_1.csv |

    When I capture current time stamp into variable "recon.timestamp"

    Then I expect each record in file "${testdata.path}/outfiles/esi_brs_sector_classification.csv" should exist in file "${testdata.path}/outfiles/runtime/${PUBLISHING_FILE_NAME}_${VAR_SYSDATE}_1.csv" and exceptions to be written to "${TESTDATA_PATH}/outfiles/exceptions_${recon.timestamp}.csv" file

  Scenario: TC_5: Loading 2nd BRS orders file

    #Deleting the BICS value for 2nd file
    Given I execute below query to "Clear data for the new instruments requested to BB"
     """
     DELETE FT_T_ISCL
     WHERE INDUS_CL_SET_ID='BICSSECT'
     AND END_TMS is NULL
     AND INSTR_ID IN (
       SELECT INSTR_ID FROM FT_T_ISID
       WHERE ISS_ID IN ('BRSFPV233','BES32M4A6','BES34TBQ6')
       AND END_TMS IS NULL)
     """

    When I process "${testdata.path}/InputFiles/${INPUTFILE_NAME2}" file with below parameters
      | FILE_PATTERN  | ${INPUTFILE_NAME2} |
      | MESSAGE_TYPE  | EIS_MT_BRS_ORDERS  |
      | BUSINESS_FEED |                    |

  Scenario: TC_6: Run BICS BB Wrapper Workflow with all parameters for Request Type EIS_Secmaster

    #This is to generate the response filename which is driven by database sequence
    And I execute below query and extract values of "SEQ" into same variables
        """
        SELECT LPAD(VREQ_FILE_SEQ.NEXTVAL+1,8,'0') AS SEQ FROM DUAL
        """
    #This is to generate the response filename taking sequence value from previous step.
    And I execute below query and extract values of "RESPONSE_FILE_NAME" into same variables
        """
        SELECT SUBSTR(FILE_PATTERN_TYP,0,INSTR(FILE_PATTERN_TYP,'*')-1)|| '${SEQ}' || '.out' AS RESPONSE_FILE_NAME
        FROM FT_CFG_VRTY
        WHERE VND_RQST_TYP = 'EIS_Secmaster'
        """

    When I copy files below from local folder "${testdata.path}/Template" to the host "dmp.ssh.inbound" folder "${BB_DOWNLOAD_DIR}":
      | ${RESPONSE_TEMPLATENAME} |

    And I rename file "${BB_DOWNLOAD_DIR}/${RESPONSE_TEMPLATENAME}" as "${BB_DOWNLOAD_DIR}/${RESPONSE_FILE_NAME}" in the named host "dmp.ssh.inbound"

    And I process the workflow template file "${BICS_RR_WF}" with below parameters and wait for the job to be completed
      | BB_DOWNLOAD_DIR      | ${BB_DOWNLOAD_DIR}          |
      | BB_UPLOAD_DIR        | ${BB_UPLOAD_DIR}            |
      | BB_FIRM_NAME         | dl790188                    |
      | GROUP_NAME           | BICSREQSOI                  |
      | BB_REQUEST_TYPE      | EIS_Secmaster               |
      | BB_SN                | 191305                      |
      | BB_USER_NUMBER       | 3650834                     |
      | WORK_STATION         | 0                           |
      | QUERY_NAME           | EIS_REFRESH_BB_BICS_SOI     |
      | BICS_EMAIL_RECEPIENT | raisa.dsouza@eastspring.com |
      | BICS_EMAIL_CC        | raisa.dsouza@eastspring.com |
      | UL_EMAIL_RECEPIENT   | raisa.dsouza@eastspring.com |
      | EMAIL_SENDER         | raisa.dsouza@eastspring.com |

    Then I expect below files to be present in the host "dmp.ssh.inbound" into folder "${BB_UPLOAD_DIR}" after processing:
      | gs_secmaster${SEQ}.req |

    And I expect value of column "BICS_SOI_COUNT" in the below SQL query equals to "2":
    """
     Select COUNT(*) AS BICS_SOI_COUNT FROM FT_T_ISGP
     WHERE prnt_iss_grp_oid='BICSREQSOI' and END_TMS IS NULL
    """

  Scenario: TC_7: Publish BICS outbound file

  #Assign Variables
    And I assign "esi_brs_sector_classification2" to variable "PUBLISHING_FILE_NAME2"

    Given I remove below files in the host "dmp.ssh.inbound" from folder "${PUBLISHING_DIRECTORY}" if exists:
      | ${PUBLISHING_FILE_NAME2}*.csv |

    When I process publishing wrapper with below parameters and wait for the job to be completed
      | PUBLISHING_FILE_NAME | ${PUBLISHING_FILE_NAME2}.csv |
      | SUBSCRIPTION_NAME    | EIS_DMP_TO_BRS_BICS_SUB      |

    Then I expect below files to be present in the host "dmp.ssh.inbound" into folder "${PUBLISHING_DIRECTORY}" after processing:
      | ${PUBLISHING_FILE_NAME2}_${VAR_SYSDATE}_1.csv |

    Then I copy files below from remote folder "${PUBLISHING_DIRECTORY}" on host "dmp.ssh.inbound" into local folder "${testdata.path}/outfiles/runtime":
      | ${PUBLISHING_FILE_NAME2}_${VAR_SYSDATE}_1.csv |

    And I remove below files in the host "dmp.ssh.inbound" from folder "${PUBLISHING_DIRECTORY}" if exists:
      | ${PUBLISHING_FILE_NAME2}_${VAR_SYSDATE}_1.csv |

    When I capture current time stamp into variable "recon.timestamp"

    Then I expect each record in file "${testdata.path}/outfiles/esi_brs_sector_classification2.csv" should exist in file "${testdata.path}/outfiles/runtime/${PUBLISHING_FILE_NAME2}_${VAR_SYSDATE}_1.csv" and exceptions to be written to "${TESTDATA_PATH}/outfiles/exceptions_${recon.timestamp}.csv" file
