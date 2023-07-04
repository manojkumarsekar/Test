#https://collaborate.pruconnect.net/pages/viewpage.action?spaceKey=EISTOM&title=PH+TD+Automated+loading+to+Aladdin#businessRequirements--430487976
#https://jira.pruconnect.net/browse/EISDEV-7339

@gc_interface_cash
@dmp_regression_unittest
@eisdev_7339

Feature: Transform XLSX file from PH for TD to BRS Cash Transactions (File 365) for password protected file

  Load CASH/TD transactions from files provided by PLUK PH TD in XLSX format by converting them to CSV
  This feature file tests if exception is getting raised in NTEL for password protected file

  Scenario: TC_1: Assign Variables

    Given I assign "tests/test-data/dmp-interfaces/Cash" to variable "testdata.path"
    And I assign "TDPlacement-2020-11-17-Eastspring_Password.xlsx" to variable "INPUT_FILENAME_LOAD"
    And I assign "esi_brs_tradein_td" to variable "OUTPUT_FILENAME"
    And I assign "/dmp/out/brs/intraday" to variable "PUBLISHING_DIR"
    And I assign "tests/test-data/intf-specs/gswf/template/EIS_ConvertXLSXtoCSVandLoad/request.xmlt" to variable "CONVERT_XLS_CSV"

  Scenario: TC_2: Transform the new Excel file to BRS F365

    Given I remove below files in the host "dmp.ssh.inbound" from folder "${PUBLISHING_DIR}" if exists:
      | ${OUTPUT_FILENAME}*.csv |

    When I copy files below from local folder "${testdata.path}/infiles" to the host "dmp.ssh.inbound" folder "${dmp.ssh.inbound.path}":
      | ${INPUT_FILENAME_LOAD} |

    And I process the workflow template file "${CONVERT_XLS_CSV}" with below parameters and wait for the job to be completed
      | MESSAGE_TYPE    | EIS_PH_TD_BRS_PLACEMENT        |
      | INPUT_DATA_DIR  | ${dmp.ssh.inbound.path}        |
      | FILEPATTERN     | ${INPUT_FILENAME_LOAD}         |
      | PARALLELISM     | 1                              |
      | OUTPUT_DATA_DIR | ${dmp.ssh.archive.path}        |
      | SUCCESS_ACTION  | MOVE                           |
      | FILE_LOAD_EVENT | EIS_StandardFileTransformation |

    And I extract new job id from jblg table into a variable "JOB_ID"

    Then I expect 1 exceptions are captured with the following criteria
      | PARM_VAL_TXT     | TDPlacement-2020-11-17-Eastspring_Password.xlsx is password protected |
      | NOTFCN_ID        | 60039                                                                 |
      | NOTFCN_STAT_TYP  | OPEN                                                                  |
      | MSG_SEVERITY_CDE | 50                                                                    |
