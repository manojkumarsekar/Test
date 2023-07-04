# ===================================================================================================================================================================================
# Date            JIRA        Comments
# ===================================================================================================================================================================================
# 04/08/2020      EISDEV-6411 Fiserv - File publishing for HTSG
# ===================================================================================================================================================================================
# FS : https://collaborate.pruconnect.net/display/EISFISERV/EISG+-+HTSG

@gc_interface_fiserv
@dmp_regression_unittest
@eisdev_6411 @fiserv_htsg_exceptions_60034 @exceltocsv
Feature: 003 | Fiserv | HTSG Watchlist | Verify Exception are raised for HTSG file transformation when invalid tab name is provided

  As a user I expect a HTSG AML watchlist file to be transformed into a FISERV formatted file.
  Exception are thrown for
  invalid excel tab name

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
      | SHEET_NAME      | Invalid                                         |
      | FILE_LOAD_EVENT | EIS_StandardFileTransformation                  |

    Then I execute below query and extract values of "JOB_ID" into same variables
      """
      SELECT JOB_ID FROM FT_T_JBLG WHERE INSTANCE_ID='${flowResultId}'
      """

  Scenario: Verify if the exception is thrown for SheetName

    Then I expect 1 exceptions are captured with the following criteria
      | PARM_VAL_TXT     | SheetName provided for UH_Fund_Balance_By_Distributor_Details_Apr 20_TC2.xls is invalid |
      | NOTFCN_ID        | 60034                                                                                   |
      | NOTFCN_STAT_TYP  | OPEN                                                                                    |
      | MSG_SEVERITY_CDE | 50                                                                                      |
      | APPL_ID          | BSNCOMP                                                                                 |
      | PART_ID          | GENERAL                                                                                 |