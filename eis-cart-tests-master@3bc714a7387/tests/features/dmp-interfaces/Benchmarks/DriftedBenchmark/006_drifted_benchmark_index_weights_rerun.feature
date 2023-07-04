#EISDEV-7406: Ticket for enabling re-run functionality for reloading corrected index weights and GAA blocks file

@gc_interface_benchmark
@gc_interface_index_weights
@dmp_regression_unittest
@eisdev_7406

Feature: 006 | Drifted Benchmark | GAA Blocks | Re-run functionality

  In this feature file, we will be testing rerun functionality of Index weights and GAA blocks.
  First we will be loading T-1 file with 3 records followed by T day file with 3 records.
  In this case, the publishing file will contain all 3 records with their respective weights.
  Second we will be loading the T day file again, but with rerun functionality with 2 records.
  In this case, the publishing file will contain 3 records, but the missing record will have 0 weight.

  Scenario: TC_1:Prerequisites

    Given I assign "tests/test-data/dmp-interfaces/Benchmarks/DriftedBenchmarkGAABlock" to variable "testdata.path"
    And I assign "/dmp/archive/in/brs" to variable "MOVE_DIRECTORY"
    And I assign "esi_security_analytics_gaablocks_day1day2.xml" to variable "INPUTFILE_GAABLOCK_TEMPLATE"
    And I assign "index_weights_rerun_Day1.xml" to variable "INPUTFILE_INDEXDAY1_TEMPLATE"
    And I assign "index_weights_rerun_Day2.xml" to variable "INPUTFILE_INDEXDAY2_TEMPLATE"
    And I generate value with date format "YYYYMMdd" and assign to variable "VAR_SYSDATE"
    And I assign "esi_security_analytics_gaablocks.xml" to variable "INPUTFILE_GAABLOCK"
    And I assign "index_weights_day1.xml" to variable "INPUTFILE_INDEXDAY1"
    And I assign "index_weights_day2.xml" to variable "INPUTFILE_INDEXDAY2"
    And I modify date "${VAR_SYSDATE}" with "-1d" from source format "YYYYMMdd" to destination format "MM/dd/YYYY" and assign to "DYNAMIC_DATE"
    And I execute below query and extract values of "DYNAMIC_DATE" into same variables
    """
    (select TO_CHAR(max(greg_dte),'MM/DD/YYYY') as DYNAMIC_DATE from fT_T_cadp where bus_dte_ind ='Y' and cal_id = 'PRPTUAL' and trunc(greg_dte)<(TO_DATE( '${DYNAMIC_DATE}' , 'MM/DD/YYYY')))
    """
    And I create input file "${INPUTFILE_GAABLOCK}" using template "${INPUTFILE_GAABLOCK_TEMPLATE}" from location "${testdata.path}/InputFiles"
    And I create input file "${INPUTFILE_INDEXDAY1}" using template "${INPUTFILE_INDEXDAY1_TEMPLATE}" from location "${testdata.path}/InputFiles"
    And I execute below query to "Clear existing data for clean data setup"
    """
    ${testdata.path}/sql/ClearDataAndSetup.sql
    """

  Scenario: Day T-1 loads

    When I process "${testdata.path}/InputFiles/testdata/${INPUTFILE_INDEXDAY1}" file with below parameters
      | FILE_PATTERN  | ${INPUTFILE_INDEXDAY1}              |
      | MESSAGE_TYPE  | EIS_MT_BRS_INDEX_WEIGHTS_PREPROCESS |
      | BUSINESS_FEED |                                     |
    Then I expect workflow is processed in DMP with total record count as "2"
    And success record count as "2"

    When I process "${testdata.path}/InputFiles/testdata/${INPUTFILE_GAABLOCK}" file with below parameters
      | FILE_PATTERN  | ${INPUTFILE_GAABLOCK}                     |
      | MESSAGE_TYPE  | EIS_MT_BRS_RISK_ANALYTICS_GAA_BLOCKS_ISSU |
      | BUSINESS_FEED |                                           |
    Then I expect workflow is processed in DMP with total record count as "2"

    When I process "${testdata.path}/InputFiles/testdata/${INPUTFILE_INDEXDAY1}" file with below parameters
      | FILE_PATTERN  | ${INPUTFILE_INDEXDAY1}   |
      | MESSAGE_TYPE  | EIS_MT_BRS_INDEX_WEIGHTS |
      | BUSINESS_FEED |                          |
    Then I expect workflow is processed in DMP with total record count as "2"
    And success record count as "2"

    When I process "${testdata.path}/InputFiles/testdata/${INPUTFILE_GAABLOCK}" file with below parameters
      | FILE_PATTERN  | ${INPUTFILE_GAABLOCK}                     |
      | MESSAGE_TYPE  | EIS_MT_BRS_RISK_ANALYTICS_GAA_BLOCKS_BNCH |
      | BUSINESS_FEED |                                           |
    Then I expect workflow is processed in DMP with total record count as "2"


  Scenario: TC_2: Day 1 loads
    When I modify date "${VAR_SYSDATE}" with "-1d" from source format "YYYYMMdd" to destination format "MM/dd/YYYY" and assign to "DYNAMIC_DATE"
    When I process "${testdata.path}/InputFiles/testdata/${INPUTFILE_INDEXDAY1}" file with below parameters
      | FILE_PATTERN  | ${INPUTFILE_INDEXDAY1}              |
      | MESSAGE_TYPE  | EIS_MT_BRS_INDEX_WEIGHTS_PREPROCESS |
      | BUSINESS_FEED |                                     |
    Then I expect workflow is processed in DMP with total record count as "2"
    And success record count as "2"

    When I process "${testdata.path}/InputFiles/testdata/${INPUTFILE_GAABLOCK}" file with below parameters
      | FILE_PATTERN  | ${INPUTFILE_GAABLOCK}                     |
      | MESSAGE_TYPE  | EIS_MT_BRS_RISK_ANALYTICS_GAA_BLOCKS_ISSU |
      | BUSINESS_FEED |                                           |
    Then I expect workflow is processed in DMP with total record count as "2"

    When I process "${testdata.path}/InputFiles/testdata/${INPUTFILE_INDEXDAY1}" file with below parameters
      | FILE_PATTERN  | ${INPUTFILE_INDEXDAY1}   |
      | MESSAGE_TYPE  | EIS_MT_BRS_INDEX_WEIGHTS |
      | BUSINESS_FEED |                          |
    Then I expect workflow is processed in DMP with total record count as "2"
    And success record count as "2"

    When I process "${testdata.path}/InputFiles/testdata/${INPUTFILE_GAABLOCK}" file with below parameters
      | FILE_PATTERN  | ${INPUTFILE_GAABLOCK}                     |
      | MESSAGE_TYPE  | EIS_MT_BRS_RISK_ANALYTICS_GAA_BLOCKS_BNCH |
      | BUSINESS_FEED |                                           |
    Then I expect workflow is processed in DMP with total record count as "2"

  Scenario: Publish Day 1 Drifted Benchmark and verify that output contains data for benchmark starting with SAA_ and MP_

    Given I assign "esi_bnp_drifted_bmk_weights_day1" to variable "PUBLISHING_FILE_NAME"

    And I assign "/dmp/out/bnp/eod" to variable "PUBLISHING_DIR"

    And I remove below files in the host "dmp.ssh.inbound" from folder "${PUBLISHING_DIR}" if exists:
      | ${PUBLISHING_FILE_NAME}* |

    And I process publishing wrapper with below parameters and wait for the job to be completed
      | PUBLISHING_FILE_NAME | ${PUBLISHING_FILE_NAME}.csv           |
      | SUBSCRIPTION_NAME    | EIS_DMP_TO_BNP_DRIFTED_BM_WEIGHTS_SUB |

    Then I expect below files to be present in the host "dmp.ssh.inbound" into folder "${PUBLISHING_DIR}" after processing:
      | ${PUBLISHING_FILE_NAME}_${VAR_SYSDATE}_1.csv |

    Then I copy files below from remote folder "${PUBLISHING_DIR}" on host "dmp.ssh.inbound" into local folder "${testdata.path}/outfiles/runtime":
      | ${PUBLISHING_FILE_NAME}_${VAR_SYSDATE}_1.csv |

    Then I exclude below columns from CSV file while doing reconciliations
      | AS OF |

    And I expect each record in file "${testdata.path}/outfiles/reference/esi_bnp_drifted_bmk_weights_DAY1_template.csv" should exist in file "${testdata.path}/outfiles/runtime/${PUBLISHING_FILE_NAME}_${VAR_SYSDATE}_1.csv" and exceptions to be written to "${testdata.path}/outfiles/004_3_exceptions_${recon.timestamp}.csv" file

  Scenario: TC_4: Rerun loads

    When I create input file "${INPUTFILE_GAABLOCK}" using template "${INPUTFILE_GAABLOCK_TEMPLATE}" from location "${testdata.path}/InputFiles"
    And I create input file "${INPUTFILE_INDEXDAY2}" using template "${INPUTFILE_INDEXDAY2_TEMPLATE}" from location "${testdata.path}/InputFiles"

    And I copy files below from local folder "${testdata.path}/InputFiles/testdata/" to the host "dmp.ssh.inbound" folder "${dmp.ssh.inbound.path}":
      | ${INPUTFILE_INDEXDAY2} |

    Given I assign "tests/test-data/intf-specs/gswf/template/EIS_GenerateSqlFromFileAndExecute_LoadFile/request.xmlt" to variable "GENERATE_SQL_LOAD_WF"

    And I process the workflow template file "${GENERATE_SQL_LOAD_WF}" with below parameters and wait for the job to be completed
      | EXECUTE_SQL                     | true                                           |
      | FILE_URI                        | ${dmp.ssh.inbound.path}/${INPUTFILE_INDEXDAY2} |
      | MESSAGETYPE_GENERATESQLFROMFILE | EIS_MT_BRS_INDEX_WEIGHTS_RERUN                 |
      | MESSAGETYPE_STANDARDFILELOAD    | EIS_MT_BRS_INDEX_WEIGHTS_PREPROCESS            |
      | OUTPUT_DIRECTORY                | ${MOVE_DIRECTORY}                              |
      | SUCCESS_ACTION                  | MOVE                                           |

    When I process "${testdata.path}/InputFiles/testdata/${INPUTFILE_INDEXDAY2}" file with below parameters
      | FILE_PATTERN  | ${INPUTFILE_INDEXDAY2}              |
      | MESSAGE_TYPE  | EIS_MT_BRS_INDEX_WEIGHTS_PREPROCESS |
      | BUSINESS_FEED |                                     |
    Then I expect workflow is processed in DMP with total record count as "2"
    And success record count as "2"

    When I process "${testdata.path}/InputFiles/testdata/${INPUTFILE_GAABLOCK}" file with below parameters
      | FILE_PATTERN  | ${INPUTFILE_GAABLOCK}                     |
      | MESSAGE_TYPE  | EIS_MT_BRS_RISK_ANALYTICS_GAA_BLOCKS_ISSU |
      | BUSINESS_FEED |                                           |
    Then I expect workflow is processed in DMP with total record count as "2"

    When I process "${testdata.path}/InputFiles/testdata/${INPUTFILE_INDEXDAY2}" file with below parameters
      | FILE_PATTERN  | ${INPUTFILE_INDEXDAY2}   |
      | MESSAGE_TYPE  | EIS_MT_BRS_INDEX_WEIGHTS |
      | BUSINESS_FEED |                          |
    Then I expect workflow is processed in DMP with total record count as "2"
    And success record count as "2"

    When I process "${testdata.path}/InputFiles/testdata/${INPUTFILE_GAABLOCK}" file with below parameters
      | FILE_PATTERN  | ${INPUTFILE_GAABLOCK}                     |
      | MESSAGE_TYPE  | EIS_MT_BRS_RISK_ANALYTICS_GAA_BLOCKS_BNCH |
      | BUSINESS_FEED |                                           |
    Then I expect workflow is processed in DMP with total record count as "2"

  Scenario: Publish Day 2 Drifted Benchmark and verify that output contains data for benchmark starting with SAA_ and MP_

    Given I assign "esi_bnp_drifted_bmk_weights_day2" to variable "PUBLISHING_FILE_NAME"

    And I assign "/dmp/out/bnp/eod" to variable "PUBLISHING_DIR"

    And I remove below files with pattern in the host "dmp.ssh.inbound" from folder "${PUBLISHING_DIR}" if exists:
      | ${PUBLISHING_FILE_NAME}_*_1.csv |

    And I process publishing wrapper with below parameters and wait for the job to be completed
      | PUBLISHING_FILE_NAME | ${PUBLISHING_FILE_NAME}.csv           |
      | SUBSCRIPTION_NAME    | EIS_DMP_TO_BNP_DRIFTED_BM_WEIGHTS_SUB |

    Then I expect below files to be present in the host "dmp.ssh.inbound" into folder "${PUBLISHING_DIR}" after processing:
      | ${PUBLISHING_FILE_NAME}_${VAR_SYSDATE}_1.csv |

    Then I copy files below from remote folder "${PUBLISHING_DIR}" on host "dmp.ssh.inbound" into local folder "${testdata.path}/outfiles/runtime":
      | ${PUBLISHING_FILE_NAME}_${VAR_SYSDATE}_1.csv |

    Then I exclude below columns from CSV file while doing reconciliations
      | AS OF |

    And I expect each record in file "${testdata.path}/outfiles/reference/esi_bnp_drifted_bmk_weights_DAY2_template.csv" should exist in file "${testdata.path}/outfiles/runtime/${PUBLISHING_FILE_NAME}_${VAR_SYSDATE}_1.csv" and exceptions to be written to "${testdata.path}/outfiles/004_3_exceptions_${recon.timestamp}.csv" file


  Scenario: Revert data setup

    And I execute below query to "Revert data setup for feature file"
    """
    UPDATE FT_T_BNID SET bnchmrk_id='SNP500TD' where bnchmrk_id='MP_TESTDOP' and bnchmrk_id_ctxt_typ = 'BRSBNCHID' and end_tms is null;
    UPDATE FT_T_BNID SET bnchmrk_id='EMBIGIDRUS' where bnchmrk_id='SAA_TESTDOP' and bnchmrk_id_ctxt_typ = 'BRSBNCHID' and end_tms is null;
    COMMIT
    """
