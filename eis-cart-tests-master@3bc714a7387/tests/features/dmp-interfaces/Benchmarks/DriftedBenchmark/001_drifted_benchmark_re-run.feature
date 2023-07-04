# ===================================================================================================================================================================================
# Date            JIRA        Comments
# ===================================================================================================================================================================================
# 22/05/2019      TOM-3726    Provide Capability to extract Drifted Benchmark interface file on an adhoc basis if there is any issue / break.
# 06/09/2019      TOM-5088    Exclude ORIG_FACE from re-concile, as data for this field changes in Production. Purpose of re-run is to en-sure an older dated data is extracted.
#                             Count match along with Benchmark code and security code should suffice.
# 08/01/2020      EISDEV-7100 expected data changed 
# ===================================================================================================================================================================================
#https://collaborate.intranet.asia/display/TOMR4/Drifted-Benchmark+Re-run+Functionality
# ===================================================================================================================================================================================

@gc_interface_benchmark
@dmp_regression_unittest
@dmp_gs_upgrade
@dmp_benchmark_adhoc_extract @tom_3726 @tom_5088
@eisdev_7100

Feature: 001 | Drifted Benchmark | Provide Capability to extract Drifted Benchmark interface file on an adhoc basis for given date

  Scenario: Extract File 20190110 (YYYYMMDD)

    Given I assign "tests/test-data/dmp-interfaces/Benchmarks/DriftedBenchmarkRerun" to variable "TESTDATA_PATH"
    And I assign "esi_bnp_drifted_11Feb2019" to variable "PUBLISHING_FILE_NAME"
    And I assign "esi_bnp_drifted_11Feb2019_template" to variable "PUBLISHING_TEMPLATE_FILE_NAME"
    And I generate value with date format "YYYYMMdd" and assign to variable "VAR_SYSDATE"
    And I assign "/dmp/out/bnp/eod" to variable "PUBLISHING_DIRECTORY"

    And I remove below files with pattern in the host "dmp.ssh.inbound" from folder "${PUBLISHING_DIRECTORY}" if exists:
      | ${PUBLISHING_FILE_NAME}_*_1.csv |

    Then I process publishing wrapper with below parameters and wait for the job to be completed
      | PUBLISHING_FILE_NAME | ${PUBLISHING_FILE_NAME}.csv           |
      | SUBSCRIPTION_NAME    | EIS_DMP_TO_BNP_DRIFTED_BM_WEIGHTS_SUB |
      | RUNTIMEPUBLISH_TMS   | 20190211                              |

    Then I expect below files to be present in the host "dmp.ssh.inbound" into folder "${PUBLISHING_DIRECTORY}" after processing:
      | ${PUBLISHING_FILE_NAME}_${VAR_SYSDATE}_1.csv |

    Then I copy files below from remote folder "${PUBLISHING_DIRECTORY}" on host "dmp.ssh.inbound" into local folder "${TESTDATA_PATH}/outfiles/runtime":
      | ${PUBLISHING_FILE_NAME}_${VAR_SYSDATE}_1.csv |

    Then I remove below files with pattern in the host "dmp.ssh.inbound" from folder "${PUBLISHING_DIRECTORY}" if exists:
      | ${PUBLISHING_FILE_NAME}*.csv |

    Then I exclude below columns from CSV file while doing reconciliations
      | ORIG_FACE |

    Then I expect reconciliation between generated CSV file "${TESTDATA_PATH}/outfiles/runtime/${PUBLISHING_FILE_NAME}_${VAR_SYSDATE}_1.csv" and reference CSV file "${TESTDATA_PATH}/outfiles/template/${PUBLISHING_TEMPLATE_FILE_NAME}.csv" should be successful and exceptions to be written to "${TESTDATA_PATH}/outfiles/002_2_1_exceptions_${recon.timestamp}.csv" file