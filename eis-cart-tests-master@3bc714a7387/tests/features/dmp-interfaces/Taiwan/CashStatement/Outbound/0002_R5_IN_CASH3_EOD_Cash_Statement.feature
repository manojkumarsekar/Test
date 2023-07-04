#https://collaborate.intranet.asia/display/TOMR4/R5.IN-CASH3+DMP-DMP+Cash+Statement
#https://jira.intranet.asia/browse/TOM-3586
#TOM-3586 : R5.IN-CASH3 DMP-BRS Cash Statement
#TOM-4119 : Enclose field values with quotes, to mimic Kofax output
#TOM-4207 : Make SECDESC non-mandatory

@tom_3586 @dmp_interfaces @taiwan_dmp_interfaces @taiwan_cash_statement @tom_4119 @tom_4207
Feature: Publishing Taiwan cash statement from DMP to BRS

  Taiwan's custodian banks sent EOD cash statements to EIS. The statements are loaded into BRS via DMP.
  DMP transformations ensure we have an opening balance where a bank doesn't provide one; a requirement of BRS.

  Scenario: TC_1: Clear old test data and setup variables

    Given I assign "tests/test-data/dmp-interfaces/Taiwan/CashStatement" to variable "testdata.path"
    And I assign "/dmp/out/brs" to variable "publishDirectory"

    And I assign "esi_TW_EODCash_1_template.csv" to variable "INPUT_TEMPLATE_FILENAME_1"
    And I assign "esi_TW_EODCash_1.csv" to variable "INPUT_FILENAME_1"
    And I assign "esi_TW_EODCash_1a_template.csv" to variable "INPUT_TEMPLATE_FILENAME_2"
    And I assign "esi_TW_EODCash_1a.csv" to variable "INPUT_FILENAME_2"

    And I execute below query and extract values of "SYSTEM_DATE" into same variables
      """
      SELECT TO_CHAR(SYSDATE,'DD/MM/YYYY') AS SYSTEM_DATE FROM DUAL
      """

    And I execute below query
    """
    DELETE ft_t_actr WHERE stmnt_dte >= TRUNC(SYSDATE) - 2
    """

    And I modify date "${SYSTEM_DATE}" with "-1d" from source format "dd/MM/yyyy" to destination format "yyyyMMdd" and assign to "SYSDATE_MINUS_1"
    And I modify date "${SYSTEM_DATE}" with "-2d" from source format "dd/MM/yyyy" to destination format "yyyyMMdd" and assign to "SYSDATE_MINUS_2"

    And I create input file "${INPUT_FILENAME_1}" using template "${INPUT_TEMPLATE_FILENAME_1}" with below codes from location "${testdata.path}"
      |  |  |

    And I create input file "${INPUT_FILENAME_2}" using template "${INPUT_TEMPLATE_FILENAME_2}" with below codes from location "${testdata.path}"
      |  |  |

    And I create input file "Template1.csv" using template "output_template_1.csv" with below codes from location "${testdata.path}"
      |  |  |

    And I create input file "Template2.csv" using template "output_template_2.csv" with below codes from location "${testdata.path}"
      |  |  |

  Scenario: TC_2: Load cash statement file

    Given I copy files below from local folder "${testdata.path}/testdata" to the host "dmp.ssh.inbound" folder "${dmp.ssh.inbound.path}":
      | ${INPUT_FILENAME_1} |

    When I process files with below parameters and wait for the job to be completed
      | BUSINESS_FEED |                              |
      | FILE_PATTERN  | ${INPUT_FILENAME_1}          |
      | MESSAGE_TYPE  | EIS_MT_TW_OCR_CASH_STATEMENT |

  Scenario: TC_3: Verify cash statement entries

    Then I expect value of column "PROCESSED_ROW_COUNT" in the below SQL query equals to "11":
        """
        SELECT COUNT(*) AS PROCESSED_ROW_COUNT FROM ft_t_actr WHERE stmnt_dte >= TRUNC(SYSDATE) - 2
        """

  Scenario: TC_4: Publish first cash statement file

    Given I assign "esi_TW_EODCash1" to variable "PUBLISHING_FILE_NAME"

    And I generate value with date format "YYYYMMdd" and assign to variable "VAR_SYSDATE"

    And I remove below files in the host "dmp.ssh.inbound" from folder "/dmp/out/brs" if exists:
      | ${PUBLISHING_FILE_NAME}_${VAR_SYSDATE}_*.csv |

    When I process publishing wrapper with below parameters and wait for the job to be completed
      | PUBLISHING_FILE_NAME | ${PUBLISHING_FILE_NAME}.csv         |
      | SUBSCRIPTION_NAME    | EIS_DMP_TO_BRS_CASHSTMT_FILE313_SUB |

    Then I expect below files to be present in the host "dmp.ssh.inbound" into folder "${publishDirectory}" after processing:
      | ${PUBLISHING_FILE_NAME}_${VAR_SYSDATE}_1.csv |

    Then I copy files below from remote folder "${publishDirectory}" on host "dmp.ssh.inbound" into local folder "${testdata.path}/outfiles/runtime":
      | ${PUBLISHING_FILE_NAME}_${VAR_SYSDATE}_1.csv |

  Scenario: TC_5: Verify first cash statement file

    Then I expect reconciliation between generated CSV file "${testdata.path}/outfiles/runtime/${PUBLISHING_FILE_NAME}_${VAR_SYSDATE}_1.csv" and reference CSV file "${testdata.path}/testdata/Template1.csv" should be successful and exceptions to be written to "${testdata.path}/outfiles/runtime/${PUBLISHING_FILE_NAME}_${VAR_SYSDATE}_TC5_exceptions.csv" file

  Scenario: TC_6: Load revised cash statement file

    Given I copy files below from local folder "${testdata.path}/testdata" to the host "dmp.ssh.inbound" folder "${dmp.ssh.inbound.path}":
      | ${INPUT_FILENAME_2} |

    When I process files with below parameters and wait for the job to be completed
      | BUSINESS_FEED |                              |
      | FILE_PATTERN  | ${INPUT_FILENAME_2}          |
      | MESSAGE_TYPE  | EIS_MT_TW_OCR_CASH_STATEMENT |

  Scenario: TC_7: Verify cash statement entries

    Then I expect value of column "PROCESSED_ROW_COUNT" in the below SQL query equals to "12":
        """
        SELECT COUNT(*) AS PROCESSED_ROW_COUNT FROM ft_t_actr WHERE stmnt_dte >= TRUNC(SYSDATE) - 2
        """

  Scenario: TC_8: Publish revised cash statement file

    Given I assign "esi_TW_EODCash2" to variable "PUBLISHING_FILE_NAME"

    And I generate value with date format "YYYYMMdd" and assign to variable "VAR_SYSDATE"

    And I remove below files in the host "dmp.ssh.inbound" from folder "/dmp/out/brs" if exists:
      | ${PUBLISHING_FILE_NAME}_${VAR_SYSDATE}_*.csv |

    When I process publishing wrapper with below parameters and wait for the job to be completed
      | PUBLISHING_FILE_NAME | ${PUBLISHING_FILE_NAME}.csv         |
      | SUBSCRIPTION_NAME    | EIS_DMP_TO_BRS_CASHSTMT_FILE313_SUB |

    Then I expect below files to be present in the host "dmp.ssh.inbound" into folder "${publishDirectory}" after processing:
      | ${PUBLISHING_FILE_NAME}_${VAR_SYSDATE}_1.csv |

    Then I copy files below from remote folder "${publishDirectory}" on host "dmp.ssh.inbound" into local folder "${testdata.path}/outfiles/runtime":
      | ${PUBLISHING_FILE_NAME}_${VAR_SYSDATE}_1.csv |

  Scenario: TC_9: Verify revised cash statement file

    Then I expect reconciliation between generated CSV file "${testdata.path}/outfiles/runtime/${PUBLISHING_FILE_NAME}_${VAR_SYSDATE}_1.csv" and reference CSV file "${testdata.path}/testdata/Template2.csv" should be successful and exceptions to be written to "${testdata.path}/outfiles/runtime/${PUBLISHING_FILE_NAME}_${VAR_SYSDATE}_TC9_exceptions.csv" file

