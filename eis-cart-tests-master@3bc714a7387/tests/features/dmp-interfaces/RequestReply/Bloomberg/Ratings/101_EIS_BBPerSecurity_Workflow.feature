#TOM-3518: Created New Feature file to test "Request Reply for Bloomberg Per Security for EIS_Entitymasterdetail Vendor Request
#TOM-5023: Add scenario to load positions data
# EISDEV-7037: Wrapper class created for BB request and replay

@gc_interface_positions @gc_interface_request_reply @gc_interface_ratings @eisdev_7037
@dmp_regression_integrationtest
@tom_3518 @tom_5023 @eisdev_7287
Feature: Request Reply | Bloomberg | Per Security | TRIS Subordinate Rating

  >> Currently all BBG requests are set up for PROGRAMMENAME = getdata. This data needs to be requested with PROGRAMMNAME = getcompany.
  >> Separate request named "EIS_Entitymasterdetail" needs to be created with the related fields.
  >> Request should be placed for all the securities for latest dated positions belonging to funds ABTHDB, ABTHAB, ABTSLF,ABTHDB_L
  >> TRIS Subordinated Ratings are received at Issuer Level Ratings, Store data to FT_T_FIRT (Financial Institution Ratings) table
  >> Rating codes are A- to AAA, B- to BBB+, C- to C+ , D, WR and NR
  >> Publish ratings at security level with Aladdin AGY code 10501 as part of EOD Ratings feed to BRS along with other rating data

  Scenario: Load ADX NP POS File

    Given I execute below query to "end date ratings"
      """
      DELETE FT_T_FIRT
      WHERE ORIG_DATA_PROV_ID like '%TRIS_SUBORDINATED%'
      AND INST_MNEM IN (SELECT INST_MNEM FROM FT_T_FIID WHERE FINS_ID IN ('117281','51357157','117348','15468979'));
      COMMIT
      """

    Given I assign "tests/test-data/dmp-interfaces/RequestReply/Bloomberg/Ratings" to variable "testdata.path"
    And I assign "pos_nonlatam.xml" to variable "INPUTFILE_NAME"

    #Create Positions File
    And I execute below query and extract values of "T_MMDDYYYY" into same variables
     """
     select TO_CHAR(sysdate, 'MM/DD/YYYY') AS T_MMDDYYYY from dual
     """

    And I execute below query to clear the balance history
     """
     ${testdata.path}/SQL/Clear_balh.sql
     """

    And I create input file "${INPUTFILE_NAME}" using template "pos.non.latam.template.xml" from location "${testdata.path}/inputfiles"

    When I process "${testdata.path}/inputfiles/testdata/${INPUTFILE_NAME}" file with below parameters
      | FILE_PATTERN  | ${INPUTFILE_NAME}                 |
      | MESSAGE_TYPE  | EIS_MT_BRS_EOD_POSITION_NON_LATAM |
      | BUSINESS_FEED |                                   |

    Then I expect workflow is processed in DMP with success record count as "4"

  Scenario: Verify Execution of Workflow with all parameters for Request Type EIS_Entitymasterdetails

    Given I assign "/dmp/in/bloomberg" to variable "BB_DOWNLOAD_DIR"
    And I assign "/dmp/out/bloomberg" to variable "BB_UPLOAD_DIR"
    And I assign "gs_entitymasterdetail_response_template.out" to variable "RESPONSE_TEMPLATENAME"

    Given Setup BB request reply prerequisites with following details
      | VND_RQST_TYP            | EIS_Entitymasterdetail                                                 |
      | RESPONSE_TEMPLATE_PATH  | tests/test-data/dmp-interfaces/RequestReply/Bloomberg/Ratings/Template |
      | RESPONSE_TEMPLATE_FILES | ${RESPONSE_TEMPLATENAME}                                               |
      | BB_PATH                 | ${BB_DOWNLOAD_DIR}                                                     |

    And I process BBPerSecurity workflow with below parameters and wait for the job to be completed
      | BB_DOWNLOAD_DIR | ${BB_DOWNLOAD_DIR}     |
      | BB_UPLOAD_DIR   | ${BB_UPLOAD_DIR}       |
      | FIRM_NAME       | dl790188               |
      | REQUEST_TYPE    | EIS_Entitymasterdetail |
      | SN              | 191305                 |
      | USER_NUMBER     | 3650834                |
      | WORK_STATION    | 0                      |

    Then I expect below files to be present in the host "dmp.ssh.inbound" into folder "${BB_UPLOAD_DIR}" after processing:
      | gs_entmaster${LATEST_SEQ}.req |

    Then I expect workflow is processed in DMP with success record count as "4"

    And I expect value of column "RECORD_COUNT" in the below SQL query equals to "1":
      """
      ${testdata.path}/SQL/BBPerSec_VerifyAllWorkflowStatus_DONE.sql
      """

  Scenario: Publish Ratings

    #Assign Variables
    Given I assign "/dmp/out/brs/1a_security" to variable "PUBLISHING_DIRECTORY"
    And I assign "esi_brs_p_ratings" to variable "PUBLISHING_FILE_NAME"
    And I generate value with date format "YYYYMMdd" and assign to variable "VAR_SYSDATE"

    Given I remove below files with pattern in the host "dmp.ssh.inbound" from folder "${PUBLISHING_DIR}" if exists:
      | ${PUBLISHING_FILE_NAME}*.csv |

    When I process publishing wrapper with below parameters and wait for the job to be completed
      | PUBLISHING_FILE_NAME | ${PUBLISHING_FILE_NAME}.csv   |
      | SUBSCRIPTION_NAME    | EIS_DMP_TO_BRS_BBGRATINGS_SUB |

    Then I expect below files to be present in the host "dmp.ssh.inbound" into folder "${PUBLISHING_DIRECTORY}" after processing:
      | ${PUBLISHING_FILE_NAME}_${VAR_SYSDATE}_1.csv |

    Then I copy files below from remote folder "${PUBLISHING_DIRECTORY}" on host "dmp.ssh.inbound" into local folder "${testdata.path}/outfiles/runtime":
      | ${PUBLISHING_FILE_NAME}_${VAR_SYSDATE}_1.csv |

    And I remove below files in the host "dmp.ssh.inbound" from folder "${PUBLISHING_DIRECTORY}" if exists:
      | ${PUBLISHING_FILE_NAME}_${VAR_SYSDATE}_1.csv |

    Then I expect all records from file1 of type CSV exists in file2
      | File1 | ${testdata.path}/outfiles/testdata/esi_brs_p_ratings_template.csv              |
      | File2 | ${testdata.path}/outfiles/runtime/${PUBLISHING_FILE_NAME}_${VAR_SYSDATE}_1.csv |

