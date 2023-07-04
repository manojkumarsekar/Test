#https://collaborate.intranet.asia/display/TOMR4/R5.IN-CASH3+DMP-DMP+Cash+Statement
#https://jira.intranet.asia/browse/TOM-3984
#TOM-3984 : Taiwan | EOD Cash Statement | Issues
#TOM-4119 : Enclose field values with quotes, to mimic Kofax output

@tom_3984 @dmp_interfaces @taiwan_dmp_interfaces @taiwan_cash_statement @tom_4119
Feature: Ensure BRS cash statement records are ordered as expected, opening balance before closing balance

  Scenario: TC_1: Clear old test data and setup variables

    Given I assign "tests/test-data/dmp-interfaces/Taiwan/CashStatement" to variable "testdata.path"
    And I assign "esi_TW_EODCash_3_template.csv" to variable "INPUT_TEMPLATE_FILENAME"
    And I assign "esi_TW_EODCash_3.csv" to variable "INPUT_FILENAME"

    And I execute below query and extract values of "SYSTEM_DATE" into same variables
      """
      SELECT TO_CHAR(SYSDATE,'DD/MM/YYYY') AS SYSTEM_DATE FROM DUAL
      """

    And I execute below query
    """
    DELETE ft_t_actr WHERE stmnt_dte >= TRUNC(SYSDATE) - 1
    """

    And I modify date "${SYSTEM_DATE}" with "-1d" from source format "dd/MM/yyyy" to destination format "yyyyMMdd" and assign to "SYSDATE_MINUS_1"
    And I modify date "${SYSTEM_DATE}" with "+0d" from source format "dd/MM/yyyy" to destination format "yyyyMMdd" and assign to "SYSDATE"

    And I create input file "${INPUT_FILENAME}" using template "${INPUT_TEMPLATE_FILENAME}" with below codes from location "${testdata.path}"
      |  |  |

  Scenario: TC_2: Load cash statement file

    Given I copy files below from local folder "${testdata.path}/testdata" to the host "dmp.ssh.inbound" folder "${dmp.ssh.inbound.path}":
      | ${INPUT_FILENAME} |

    When I process files with below parameters and wait for the job to be completed
      | BUSINESS_FEED |                              |
      | FILE_PATTERN  | ${INPUT_FILENAME}            |
      | MESSAGE_TYPE  | EIS_MT_TW_OCR_CASH_STATEMENT |

  Scenario: TC_3: Verify cash statement entries

    Then I expect value of column "PROCESSED_ROW_COUNT" in the below SQL query equals to "25":
        """
        SELECT COUNT(*) AS PROCESSED_ROW_COUNT FROM ft_t_actr WHERE stmnt_dte = TRUNC(SYSDATE) - 1
        """

  Scenario: TC_4: Publish cash statement file

    Given I assign "esi_TW_EODCash3" to variable "PUBLISHING_FILE_NAME"
    And I assign "/dmp/out/brs" to variable "publishDirectory"

    And I create input file "Template3.csv" using template "output_template_3.csv" with below codes from location "${testdata.path}"
      |  |  |

    And I remove below files in the host "dmp.ssh.outbound" from folder "${publishDirectory}" if exists:
      | ${PUBLISHING_FILE_NAME}*.csv |

    When I process publishing wrapper with below parameters and wait for the job to be completed
      | PUBLISHING_FILE_NAME | ${PUBLISHING_FILE_NAME}.csv         |
      | SUBSCRIPTION_NAME    | EIS_DMP_TO_BRS_CASHSTMT_FILE313_SUB |

    Then I expect below files to be present in the host "dmp.ssh.outbound" into folder "${publishDirectory}" after processing:
      | ${PUBLISHING_FILE_NAME}_${SYSDATE}_1.csv |

    Then I copy files below from remote folder "${publishDirectory}" on host "dmp.ssh.outbound" into local folder "${testdata.path}/outfiles/runtime":
      | ${PUBLISHING_FILE_NAME}_${SYSDATE}_1.csv |

  Scenario: TC_5: Verify cash statement file against template, including the order of records

    Then I expect all records in file "${testdata.path}/testdata/Template3.csv" should exist in file "${testdata.path}/outfiles/runtime/${PUBLISHING_FILE_NAME}_${SYSDATE}_1.csv" with same order and exceptions to be written to "${testdata.path}/outfiles/runtime/${PUBLISHING_FILE_NAME}_${VAR_SYSDATE}_0003_TC5_exceptions.csv" file