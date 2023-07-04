#https://collaborate.pruconnect.net/pages/viewpage.action?pageId=41970306
#EISDEV-6054: Created New Feature file to test "Request Reply for Bloomberg Per Security for EIS_CreditRisk Vendor Request
#EISDEV-6199: Included Test Scenario where Ultimate Parent Country of Risk and Contry of Risk are different grographic unit
#EISDEV-6536: Changing the task count to 4 from 5 as special handling to remove duplicates has been added in the RR workflow
#eisdev_7499: Performance improved by increasing NO_OF_PARALLEL_BRANCHES, PUBLISHING_BULK_SIZE values

@gc_interface_positions @gc_interface_request_reply @gc_interface_cdf @eisdev_7499
@dmp_regression_integrationtest
@eisdev_6054 @eisdev_6199 @eisdev_6536
Feature: Request Reply | Bloomberg | Per Security | Credit Risk

  As part of EISDEV-6054, we need to publish data with tag ESI_CNTRY_RISK for securities belonging for Portfolio UBZF sourced from BBG field “CNTRY_OF_RISK”
  Sample Position file created contains positions for
  1. Instrument Id XS1961092266 and Portfolio UBZF
  Expected Behavior : ESI_CNTRY_RISK Should be populated for this security
  2. Instrument Id HK0000282985 and Portfolio UBZF
  Expected Behavior : ESI_CNTRY_RISK Should be populated for this security
  3. Instrument Id HK0000350774 and Portfolio UBZF
  Expected Behavior : ESI_CNTRY_RISK Should be populated for this security
  4. Instrument Id HK0000350774 and Portfolio 16SUN
  Expected Behavior : This is an overlapping security, ESI_CNTRY_RISK Should be populated for this security only once
  5. Instrument Id HK0000362761 and Portfolio 16SUN
  Expected Behavior : ESI_CNTRY_RISK Should not be populated for this security

  Scenario: Load BRS Positions

    Given I assign "tests/test-data/dmp-interfaces/RequestReply/Bloomberg/CreditRisk" to variable "testdata.path"
    And I assign "eis_credit_risk_pos.xml" to variable "INPUTFILE_NAME"

    And I execute below query to "Update Latest Positions to T-2"
      """
      UPDATE FT_T_BALH SET AS_OF_TMS = SYSDATE-2 WHERE AS_OF_TMS IN (SELECT MAX(AS_OF_TMS) FROM FT_T_BALH);
      COMMIT
      """

    #Create Positions File
    And I execute below query and extract values of "T_1_MMDDYYYY" into same variables
     """
     select TO_CHAR(sysdate-1, 'MM/DD/YYYY') AS T_1_MMDDYYYY from dual
     """

    And I create input file "${INPUTFILE_NAME}" using template "eis_credit_risk_pos_template.xml" from location "${testdata.path}/inputfiles"

    When I copy files below from local folder "${testdata.path}/inputfiles/testdata" to the host "dmp.ssh.inbound" folder "${dmp.ssh.inbound.path}":
      | ${INPUTFILE_NAME} |

    And I process files with below parameters and wait for the job to be completed
      | FILE_PATTERN  | ${INPUTFILE_NAME}                 |
      | MESSAGE_TYPE  | EIS_MT_BRS_EOD_POSITION_NON_LATAM |
      | BUSINESS_FEED |                                   |

    Then I expect workflow is processed in DMP with success record count as "5"

  Scenario: Refresh FT_V_BLH2

    Given I assign "tests/test-data/intf-specs/gswf/template/EIS_CallStoredProcedure/request.xmlt" to variable "STORED_PROCEDURE"

    And I process the workflow template file "${STORED_PROCEDURE}" with below parameters and wait for the job to be completed
      | SQL_PROC_NAME | esi_refresh_ft_v_blh2 |

  Scenario: Verify Execution of Workflow with all parameters for Request Type EIS_Creditrisk

    Given I assign "/dmp/in/bloomberg" to variable "BB_DOWNLOAD_DIR"
    And I assign "/dmp/out/bloomberg" to variable "BB_UPLOAD_DIR"
    And I assign "gs_creditrisk_response_template.out" to variable "RESPONSE_TEMPLATENAME"

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
    WHERE VND_RQST_TYP = 'EIS_Creditrisk'
    """

    # We are copying the response file on server because request reply workflow will generate request file and expect response file with same sequence number.
    # Since, we are not connecting to Bloomberg for testing this is to simulate the process of request reply
    When I copy files below from local folder "${testdata.path}/Template" to the host "dmp.ssh.inbound" folder "${BB_DOWNLOAD_DIR}":
      | ${RESPONSE_TEMPLATENAME} |

    And I rename file "${BB_DOWNLOAD_DIR}/${RESPONSE_TEMPLATENAME}" as "${BB_DOWNLOAD_DIR}/${RESPONSE_FILE_NAME}" in the named host "dmp.ssh.inbound"

    And I process BBPerSecurity workflow with below parameters and wait for the job to be completed
      | BB_DOWNLOAD_DIR | ${BB_DOWNLOAD_DIR} |
      | BB_UPLOAD_DIR   | ${BB_UPLOAD_DIR}   |
      | FIRM_NAME       | dl790188           |
      | REQUEST_TYPE    | EIS_Creditrisk     |
      | SN              | 191305             |
      | USER_NUMBER     | 3650834            |
      | WORK_STATION    | 0                  |

    Then I expect below files to be present in the host "dmp.ssh.inbound" into folder "${BB_UPLOAD_DIR}" after processing:
      | gs_credtrisk${SEQ}.req |

    Then I expect workflow is processed in DMP with success record count as "4"

    And I expect value of column "RECORD_COUNT" in the below SQL query equals to "1":
      """
      ${testdata.path}/SQL/BBPerSec_VerifyAllWorkflowStatus_DONE.sql
      """

  Scenario: Publish CDF File and recon

    Given I assign "esi_brs_sec_cdf" to variable "PUBLISHING_FILE_NAME"
    And I generate value with date format "YYYYMMdd" and assign to variable "VAR_SYSDATE"
    And I assign "/dmp/out/brs/1a_security" to variable "PUBLISHING_DIR"

    And I remove below files with pattern in the host "dmp.ssh.inbound" from folder "${PUBLISHING_DIR}" if exists:
      | ${PUBLISHING_FILE_NAME}* |

    When I process publishing wrapper with below parameters and wait for the job to be completed
      | PUBLISHING_FILE_NAME    | ${PUBLISHING_FILE_NAME}.csv |
      | SUBSCRIPTION_NAME       | EIS_DMP_TO_BRS_CDF_SUB      |
      | NO_OF_PARALLEL_BRANCHES | 30                          |
      | PUBLISHING_BULK_SIZE    | 2000                        |

    Then I expect below files to be present in the host "dmp.ssh.inbound" into folder "${PUBLISHING_DIR}" after processing:
      | ${PUBLISHING_FILE_NAME}_${VAR_SYSDATE}_1.csv |

    Then I copy files below from remote folder "${PUBLISHING_DIR}" on host "dmp.ssh.inbound" into local folder "${testdata.path}/outfiles/runtime":
      | ${PUBLISHING_FILE_NAME}_${VAR_SYSDATE}_1.csv |

    And I remove below files in the host "dmp.ssh.inbound" from folder "${PUBLISHING_DIRECTORY}" if exists:
      | ${PUBLISHING_FILE_NAME}_${VAR_SYSDATE}_1.csv |

    When I exclude below columns from CSV file while doing reconciliations
      | EFFECTIVE_DATE |

    Then I expect all records from file1 of type CSV exists in file2
      | File1 | ${testdata.path}/outfiles/testdata/cdf_ubzf_sec.csv                            |
      | File2 | ${testdata.path}/outfiles/runtime/${PUBLISHING_FILE_NAME}_${VAR_SYSDATE}_1.csv |