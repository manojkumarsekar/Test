#https://collaborate.intranet.asia/display/TOMR4/R5.IN-CASH1+OCR-DMP+EOD+Cash+Statement
#https://jira.intranet.asia/browse/TOM-3390
#TOM-3390 : R5.IN-CASH1 OCR-DMP EOD Cash Statement
#TOM-4119 : Enclose field values with quotes, to mimic Kofax output
#TOM-4207 : Make SECDESC non-mandatory. Modified inbound template for this feature to have a null SECDESC.

@tom_3390 @dmp_interfaces @taiwan_dmp_interfaces @taiwan_cash_statement @tom_4097 @tom_4119 @tom_4207
Feature: Loading Taiwan cash statement into DMP

  Taiwan's custodian banks sent EOD cash statements to EIS. The statements are loaded into BRS via DMP.
  DMP transformations ensure we have an opening balance where a bank doesn't provide one; a requirement of BRS.

  Scenario: TC_1: Clear old test data and setup variables

    Given I assign "tests/test-data/dmp-interfaces/Taiwan/CashStatement" to variable "testdata.path"
    And I assign "esi_TW_EODCash_1_template.csv" to variable "INPUT_TEMPLATE_FILENAME"
    And I assign "esi_TW_EODCash_1.csv" to variable "INPUT_FILENAME"

    And I execute below query and extract values of "SYSTEM_DATE" into same variables
      """
      SELECT TO_CHAR(SYSDATE,'DD/MM/YYYY') AS SYSTEM_DATE FROM DUAL
      """

    And I execute below query
    """
    DELETE ft_t_actr WHERE stmnt_dte >= TRUNC(SYSDATE) - 2
    """

    And I modify date "${SYSTEM_DATE}" with "-0d" from source format "dd/MM/yyyy" to destination format "yyyyMMdd" and assign to "SYSDATE_MINUS_1"
    And I modify date "${SYSTEM_DATE}" with "-1d" from source format "dd/MM/yyyy" to destination format "yyyyMMdd" and assign to "SYSDATE_MINUS_2"

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

    # Validation 1: Check all 11 rows have loaded into ACTR
    Then I expect value of column "PROCESSED_ROW_COUNT" in the below SQL query equals to "11":
        """
        SELECT COUNT(*) AS PROCESSED_ROW_COUNT FROM ft_t_actr WHERE stmnt_dte >= TRUNC(SYSDATE) - 2
        """

  Scenario: TC_4: Teardown test data
  
    Given I execute below query
    """
    DELETE ft_t_actr WHERE stmnt_dte >= TRUNC(SYSDATE) - 2
    """
    