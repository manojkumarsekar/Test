#https://jira.pruconnect.net/browse/EISDEV-6494 (Include GAA_ALGENS in the esi_bnp_drifted_bmk_weights_YYYYMMDD.csv file)

@gc_interface_securities @gc_interface_risk_analytics @gc_interface_benchmark
@dmp_regression_integrationtest
@dmp_taiwan
@eisdev_6494
Feature: Loading Risk Analytics file to include GAA_ALGENS in drifted benchmark

  This feature is to test the BM code for the drifted benchmark file
  | FUND CODE  |  BENCHMARK CODE |
  | AA_M705882 |  GAA_ALGENS     |

  Scenario: TC_1: Initial setup

    Given I assign "RiskAnanlytics_GAA_ALGENS_Template.xml" to variable "INPUT_TEMPLATENAME"
    And I assign "RiskAnanlytics_GAA_ALGENS.xml" to variable "INPUT_FILENAME"
    And I generate value with date format "ddMMYYYY" and assign to variable "VAR_SYSDATE"
    And I assign "tests/test-data/dmp-interfaces/Taiwan/RiskAnalytics" to variable "testdata.path"
    And I modify date "${VAR_SYSDATE}" with "-1d" from source format "ddMMYYYY" to destination format "MM/dd/YYYY" and assign to "DYNAMIC_DATE"
    And I create input file "${INPUT_FILENAME}" using template "${INPUT_TEMPLATENAME}" from location "${testdata.path}/inputfiles"

    # Setup BM data
    And I execute below query to "setup benchmark data"
    """
    ${testdata.path}/sql/6494_InsertBenchmark.sql
    """

  Scenario: TC_2: Load RiskAnalytics

    When I process "${testdata.path}/inputfiles/testdata/${INPUT_FILENAME}" file with below parameters
      | BUSINESS_FEED |                           |
      | FILE_PATTERN  | ${INPUT_FILENAME}         |
      | MESSAGE_TYPE  | EIS_MT_BRS_RISK_ANALYTICS |

   #Verification of successful File load INPUT_FILENAME6
    Then I expect workflow is processed in DMP with total record count as "5"
    And completed record count as "5"

  Scenario: TC_3: Publish Drifted BM

    Given I assign "DriftedBM" to variable "PUBLISHING_FILE_NAME"
    And I generate value with date format "YYYYMMdd" and assign to variable "VAR_SYSDATE"
    And I assign "/dmp/out/bnp/eod" to variable "PUBLISHING_DIR"

    And I remove below files in the host "dmp.ssh.inbound" from folder "${PUBLISHING_DIR}" if exists:
      | ${PUBLISHING_FILE_NAME}_${VAR_SYSDATE}_*.csv |

    When I process publishing wrapper with below parameters and wait for the job to be completed
      | PUBLISHING_FILE_NAME | ${PUBLISHING_FILE_NAME}.csv                                                                                                 |
      | SUBSCRIPTION_NAME    | EIS_DMP_TO_BNP_DRIFTED_BM_WEIGHTS_SUB                                                                                       |
      | SQL                  | &lt;sql&gt; BNCH_OID IN(SELECT BNCH_OID FROM FT_T_BNID WHERE BNCHMRK_ID IN ('GAA_ALGENS') AND END_TMS IS NULL) &lt;/sql&gt; |

    Then I expect below files to be present in the host "dmp.ssh.inbound" into folder "${PUBLISHING_DIR}" after processing:
      | ${PUBLISHING_FILE_NAME}_${VAR_SYSDATE}_1.csv |

    Then I copy files below from remote folder "${PUBLISHING_DIR}" on host "dmp.ssh.inbound" into local folder "tests/test-data/dmp-interfaces/Taiwan/RiskAnalytics/outfiles":
      | ${PUBLISHING_FILE_NAME}_${VAR_SYSDATE}_1.csv |

  Scenario: TC_4: Check the drfited BM file

    Given I assign "${testdata.path}/outfiles/${PUBLISHING_FILE_NAME}_${VAR_SYSDATE}_1.csv" to variable "CSV_FILE"

    #verification of file published
    Then I expect column "FUND CODE" values in the CSV file "${CSV_FILE}" should be "ALGENS"
    And I expect column "BENCHMARK CODE" values in the CSV file "${CSV_FILE}" should be "GAA_ALGENS"
