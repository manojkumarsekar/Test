# ===================================================================================================================================================================================
# Date            JIRA        Comments
# ===================================================================================================================================================================================
# 04/08/2020      EISDEV-6411 Fiserv - File publishing for HTSG
# ===================================================================================================================================================================================
# FS : https://collaborate.pruconnect.net/display/EISFISERV/EISG+-+HTSG

@gc_interface_fiserv
@dmp_regression_unittest
@eisdev_6411 @fiserv_htsg_exceptions_60001 @exceltocsv
Feature: 002 | Fiserv | HTSG Watchlist | Verify Exception are raised for HTSG file transformation

  As a user I expect a HTSG AML watchlist file to be transformed into a FISERV formatted file.
  Exception are thrown for
    invalid DOB, COR and NAT.
    missing madatory fields for Agent
    missing madatory fields for Holder

  Test Scenarios
  ===================================================================================================================================================================================
  Agent Code |  Agent Name                |  Holder Name   					    		  |  ID No.   	    |  NAT		 |  DOB     |  COR     | Expected Behavior
  ===================================================================================================================================================================================
  ATSGDMGI   |  IFAST FINANCIAL PTE LTD   |  IFAST FINANCIAL PTE LTD (NC)   	          |  200616003HNC   |  INVALID   | INVALID  | INVALID   | Both Agent and Holder should be Transformed, Excption is raised for Invalid, DOB, NAT and COR
             |  MAYBANK SINGAPORE LIMITED |  MAYBAN NOMINEES (SINGAPORE) PTE LTD A/CDIRECT|  MAYBANNOM1     |  SINGAPORE |          | SINGAPORE | Holder should be Transformed. Exception Raised for Missing Agent Code.
  ATSGFPF    |  AVALLIS FINANCIAL PTE LTD |                                  			  |  200616003HNC   |  SINGAPORE |          | SINGAPORE | Agent should be Transformed. Exception Raised for Missing HolderName.
             |  AVALLIS FINANCIAL PTE LTD |                                  			  |  200616003HNC   |  SINGAPORE |          | SINGAPORE | Nothing should be Transformed. Exception Raised for Missing HolderName and Agent Code.

  Scenario: Transform HTSG watchlist to FISERV format

    Given I assign "tests/test-data/dmp-interfaces/Fiserv" to variable "testdata.path"
    And I assign "UH_Fund_Balance_By_Distributor_Details_Apr 20_TC2.xls" to variable "INPUT_FILENAME"
    And I generate value with date format "YYYYMMdd" and assign to variable "VAR_SYSDATE"
    And I assign "WLF_MONTHLY_EISG_HTG_${VAR_SYSDATE}.txt" to variable "TRANSFORMED_FILE_NAME"
    And I assign "/dmp/out/fiserv" to variable "PUBLISHING_DIR"
    And I assign "tests/test-data/intf-specs/gswf/template/EIS_ConvertXLSXtoCSVandLoad/request.xmlt" to variable "CONVERT_XLS_CSV"

    # Delete the output file if it exist
    Given I remove below files in the host "dmp.ssh.outbound" from folder "${PUBLISHING_DIR}" if exists:
      | ${TRANSFORMED_FILE_NAME} |

    When I copy files below from local folder "${testdata.path}/testdata" to the host "dmp.ssh.inbound" folder "${dmp.ssh.inbound.path}":
      | ${INPUT_FILENAME} |

    And I process the workflow template file "${CONVERT_XLS_CSV}" with below parameters and wait for the job to be completed
      | MESSAGE_TYPE    | EIS_MT_HTSG_FISERV_WATCHLIST                    |
      | INPUT_DATA_DIR  | ${dmp.ssh.inbound.path}                         |
      | FILEPATTERN     | UH_Fund_Balance_By_Distributor_Details_Apr*.xls |
      | PARALLELISM     | 1                                               |
      | OUTPUT_DATA_DIR | ${dmp.ssh.archive.path}                         |
      | SUCCESS_ACTION  | MOVE                                            |
      | SHEET_NAME      | Details                                         |
      | FILE_LOAD_EVENT | EIS_StandardFileTransformation                  |

    Then I execute below query and extract values of "JOB_ID" into same variables
      """
      SELECT JOB_ID FROM FT_T_JBLG WHERE PRNT_JOB_ID IN (
      SELECT JOB_ID FROM FT_T_JBLG WHERE INSTANCE_ID='${flowResultId}')
      """

    Then I expect below files to be present in the host "dmp.ssh.outbound" into folder "${PUBLISHING_DIR}" after processing:
      | ${TRANSFORMED_FILE_NAME} |

    Then I copy files below from remote folder "${PUBLISHING_DIR}" on host "dmp.ssh.outbound" into local folder "${testdata.path}/outfiles/runtime":
      | ${TRANSFORMED_FILE_NAME} |

  Scenario: Verify if the exception is thrown for Invalid COR

    Then I expect 1 exceptions are captured with the following criteria
      | PARM_VAL_TXT            | User defined Error thrown! . Record is partially processed as country code for COR is not present in DMP |
      | NOTFCN_ID               | 60001                                                                                                    |
      | NOTFCN_STAT_TYP         | OPEN                                                                                                     |
      | MAIN_ENTITY_ID_CTXT_TYP | AGENTCODE:IDNO                                                                                           |
      | MAIN_ENTITY_ID          | ATSGDMGI:200616003HNC                                                                                    |
      | MSG_SEVERITY_CDE        | 40                                                                                                       |
      | APPL_ID                 | TPS                                                                                                      |
      | PART_ID                 | TRANS                                                                                                    |
      | TRID.RECORD_SEQ_NUM     | 1                                                                                                        |

  Scenario: Verify if the exception is thrown for Invalid NAT

    Then I expect 1 exceptions are captured with the following criteria
      | PARM_VAL_TXT            | User defined Error thrown! . Record is partially processed as country code for NAT is not present in DMP |
      | NOTFCN_ID               | 60001                                                                                                    |
      | NOTFCN_STAT_TYP         | OPEN                                                                                                     |
      | MAIN_ENTITY_ID_CTXT_TYP | AGENTCODE:IDNO                                                                                           |
      | MAIN_ENTITY_ID          | ATSGDMGI:200616003HNC                                                                                    |
      | MSG_SEVERITY_CDE        | 40                                                                                                       |
      | APPL_ID                 | TPS                                                                                                      |
      | PART_ID                 | TRANS                                                                                                    |
      | TRID.RECORD_SEQ_NUM     | 1                                                                                                        |

  Scenario: Verify if the exception is thrown for Invalid DOB

    Then I expect 1 exceptions are captured with the following criteria
      | PARM_VAL_TXT            | User defined Error thrown! . Record is partially processed as incorrect DOB INVALID is received in the input record. |
      | NOTFCN_ID               | 60001                                                                                                                |
      | NOTFCN_STAT_TYP         | OPEN                                                                                                                 |
      | MAIN_ENTITY_ID_CTXT_TYP | AGENTCODE:IDNO                                                                                                       |
      | MAIN_ENTITY_ID          | ATSGDMGI:200616003HNC                                                                                                |
      | MSG_SEVERITY_CDE        | 40                                                                                                                   |
      | APPL_ID                 | TPS                                                                                                                  |
      | PART_ID                 | TRANS                                                                                                                |
      | TRID.RECORD_SEQ_NUM     | 1                                                                                                                    |

  Scenario: Verify if the exception is thrown for Missing Mandatory Fields for Agent

    Then I expect 1 exceptions are captured with the following criteria
      | PARM_VAL_TXT            | User defined Error thrown! . Cannot process record as required fields AgentCode is not present in the input record. |
      | NOTFCN_ID               | 60001                                                                                                               |
      | NOTFCN_STAT_TYP         | OPEN                                                                                                                |
      | MAIN_ENTITY_ID_CTXT_TYP | AGENTCODE:IDNO                                                                                                      |
      | MAIN_ENTITY_ID          | :MAYBANNOM1                                                                                                         |
      | MSG_SEVERITY_CDE        | 40                                                                                                                  |
      | APPL_ID                 | TPS                                                                                                                 |
      | PART_ID                 | TRANS                                                                                                               |
      | TRID.RECORD_SEQ_NUM     | 2                                                                                                                   |

  Scenario: Verify if the exception is thrown for Missing Mandatory Fields for Holder

    Then I expect 1 exceptions are captured with the following criteria
      | PARM_VAL_TXT            | User defined Error thrown! . Cannot process record as required fields , HolderName is not present in the input record. |
      | NOTFCN_ID               | 60001                                                                                                                  |
      | NOTFCN_STAT_TYP         | OPEN                                                                                                                   |
      | MAIN_ENTITY_ID_CTXT_TYP | AGENTCODE:IDNO                                                                                                         |
      | MAIN_ENTITY_ID          | ATSGFPF:200616003HNC                                                                                                   |
      | MSG_SEVERITY_CDE        | 40                                                                                                                     |
      | APPL_ID                 | TPS                                                                                                                    |
      | PART_ID                 | TRANS                                                                                                                  |
      | TRID.RECORD_SEQ_NUM     | 3                                                                                                                      |

  Scenario: Compare HTSG FISERV file against expected output

    Given I exclude below column indices from CSV file while doing reconciliations
      | 1 |

    And I expect reconciliation should be successful between given CSV files
      | ActualFile   | ${testdata.path}/outfiles/runtime/${TRANSFORMED_FILE_NAME}               |
      | ExpectedFile | ${testdata.path}/outfiles/expected/WLF_MONTHLY_EISG_HTG_tc2_expected.txt |
