#Parent Ticket: https://collaborate.intranet.asia/pages/viewpage.action?pageId=24938013#Test-logicalMapping
#Requirement Link: https://collaborate.intranet.asia/pages/viewpage.action?spaceKey=TOM&title=SOD+Flows%3A+SOD+Positions+for+Reconciliation

@gc_interface_portfolios
@dmp_regression_unittest
@01_tom_4480_bnp_dmp_portfolio
Feature: SOD-1 | Portfolio | BNP to DMP Portfolio load and Exceptions.

  Description:
  1. Verify if exception is thrown when CLIENT_PORTFOLIO_CODE (ESISOD_PTF File) is not present in FT_T_ACID (ACC_ALT_ID)
  2. Verify if exception is thrown when ACCT_ID (ESISOD_PTF File) is NULL & Verify if exception is thrown when CLIENT_PORTFOLIO_CODE (ESISOD_PTF File) is NULL


  Scenario: System should throw exception when ESISOD_PTF File load with CLIENT_PORTFOLIO_CODE which is not available in DMP

    Given I assign "ESISOD_PTF_NoClientCode.out" to variable "INPUT_FILENAME_1"
    And I assign "tests/test-data/Regression-DMP/SOD/BNP_TO_DMP/Portfolio/TOM-4480" to variable "testdata.path"
    And I generate value with date format "DDMMHHmmss" and assign to variable "TIMESTAMP"

    When I create input file "${INPUT_FILENAME_1}" using template "ESISOD_PTF_template.out" with below codes from location "${testdata.path}"
      | ACC_ID_BNP1 | T_ACID_BNP_${TIMESTAMP} |
      | ACC_ID_EIS1 | T_ACID_EIS_${TIMESTAMP} |

    And I copy files below from local folder "${testdata.path}/testdata" to the host "dmp.ssh.inbound" folder "${dmp.ssh.inbound.path}":
      | ${INPUT_FILENAME_1} |

    And I process files with below parameters and wait for the job to be completed
      | BUSINESS_FEED |                      |
      | FILE_PATTERN  | ${INPUT_FILENAME_1}  |
      | MESSAGE_TYPE  | EIS_MT_BNP_PORTFOLIO |

    And I extract new job id from jblg table into a variable "JOB_ID"

    Then I expect value of column "EXCEPTION_MSG1_CHECK" in the below SQL query equals to "1":
      """
      SELECT COUNT(*) AS EXCEPTION_MSG1_CHECK FROM FT_T_NTEL NTEL
      JOIN FT_T_TRID TRID
      ON NTEL.LAST_CHG_TRN_ID = TRID.TRN_ID
      AND TRID.JOB_ID = '${JOB_ID}'
      AND NTEL.NOTFCN_ID = 26
      AND NTEL.NOTFCN_STAT_TYP = 'OPEN'
      AND NTEL.CHAR_VAL_TXT LIKE '%${ACC_ID_EIS1}% received from BNP  could not be retrieved from the AccountAlternateIdentifier%'
      """

  Scenario: Validate the exceptions for NULL ACCT_ID (ESISOD_PTF File) i.e. FT_T_ACID (ACC_ALT_ID)

    Given I assign "${ACC_ID_BNP1}" to variable "OLD_BNP_ID"

    When I create input file "${INPUT_FILENAME_1}" using template "ESISOD_PTF_template.out" with below codes from location "${testdata.path}"
      | ACC_ID_BNP1 |  |

    And I copy files below from local folder "${testdata.path}/testdata" to the host "dmp.ssh.inbound" folder "${dmp.ssh.inbound.path}":
      | ${INPUT_FILENAME_1} |

    #Processing the file load and deleting post process
    And I process files with below parameters and wait for the job to be completed
      | BUSINESS_FEED |                      |
      | FILE_PATTERN  | ${INPUT_FILENAME_1}  |
      | MESSAGE_TYPE  | EIS_MT_BNP_PORTFOLIO |

    And I extract new job id from jblg table into a variable "JOB_ID"

    #Validating the load count to be zero for null ACCT_ID (ESISOD_PTF File) i.e. FT_T_ACID (ACC_ALT_ID)
    Then I expect value of column "SUCCESS_COUNT" in the below SQL query equals to "0":
      """
      SELECT TASK_SUCCESS_CNT AS SUCCESS_COUNT FROM FT_T_JBLG WHERE JOB_ID='${JOB_ID}'

      """

  Scenario: Validate the exceptions for NULL CLIENT_PORTFOLIO_CODE (ESISOD_PTF File)

    When I create input file "${INPUT_FILENAME_1}" using template "ESISOD_PTF_template.out" with below codes from location "${testdata.path}"
      | ACC_ID_BNP1 | ${OLD_BNP_ID} |
      | ACC_ID_EIS1 |               |

    And I copy files below from local folder "${testdata.path}/testdata" to the host "dmp.ssh.inbound" folder "${dmp.ssh.inbound.path}":
      | ${INPUT_FILENAME_1} |

    #Processing the file load and deleting post process
    And I process files with below parameters and wait for the job to be completed
      | BUSINESS_FEED |                      |
      | FILE_PATTERN  | ${INPUT_FILENAME_1}  |
      | MESSAGE_TYPE  | EIS_MT_BNP_PORTFOLIO |

    And I extract new job id from jblg table into a variable "JOB_ID"

    #Validating the load count to be zero for null CLIENT_PORTFOLIO_CODE (ESISOD_PTF File)
    Then I expect value of column "SUCCESS_COUNT" in the below SQL query equals to "0":
      """
      SELECT TASK_SUCCESS_CNT AS SUCCESS_COUNT FROM FT_T_JBLG WHERE JOB_ID='${JOB_ID}'

      """
