#Parent Ticket: https://collaborate.intranet.asia/pages/viewpage.action?pageId=24938013#Test-logicalMapping
#Requirement Link: https://collaborate.intranet.asia/pages/viewpage.action?spaceKey=TOM&title=SOD+Flows%3A+SOD+Positions+for+Reconciliation

@gc_interface_portfolios
@dmp_regression_unittest
@02_tom_4480_bnp_dmp_portfolio
Feature: SOD-1 | Portfolio | BNP to DMP Portfolio load and Mapping scenarios.

  Description:
  1. Loading portfolio Master with 3 identifiers CRTSID, DBANKID, IRPID and verifying all got processed successfully
  2. Loading BNP Portfolio as per existing Account and verifying ACCT_ID (ESISOD_PTF File) is mapped in FT_T_ACID (ACC_ALT_ID)
  3. Reloading BNP Portfolio as per existing Account with new BNP ID and verifying new ACCT_ID (ESISOD_PTF File) is mapped in FT_T_ACID (ACC_ALT_ID)


  Scenario: Loading Portfolio Master File

    Given I assign "tests/test-data/Regression-DMP/SOD/BNP_TO_DMP/Portfolio/TOM-4480" to variable "testdata.path"
    And I generate value with date format "DDMMHHmmss" and assign to variable "TIMESTAMP"

    And I assign "Portfolio_Master.xlsx" to variable "INPUT_FILENAME_2"

    When I create input file "${INPUT_FILENAME_2}" using template "Portfolio_Master_template.xlsx" with below codes from location "${testdata.path}"
      | ACC_ID_EIS1 | T_ACID_EIS_${TIMESTAMP} |

    And I copy files below from local folder "${testdata.path}/testdata" to the host "dmp.ssh.inbound" folder "${dmp.ssh.inbound.path}":
      | ${INPUT_FILENAME_2} |

    And I process files with below parameters and wait for the job to be completed
      | BUSINESS_FEED |                                      |
      | FILE_PATTERN  | ${INPUT_FILENAME_2}                  |
      | MESSAGE_TYPE  | EIS_MT_RDM_PORTFOLIO_MASTER_TEMPLATE |

  Scenario: Verifying New Portfolio is created as per Portfolio Master

    Then I expect value of column "CLIENT_PORT_CODE" in the below SQL query equals to "PASS":
      """
      SELECT CASE WHEN COUNT(1) = 3 THEN 'PASS' ELSE 'FAIL' END AS CLIENT_PORT_CODE
      FROM FT_T_ACID
      WHERE ACCT_ALT_ID IN ('${ACC_ID_EIS1}')
      AND ACCT_ID_CTXT_TYP in ('CRTSID','DBANKID','IRPID')
      """

  Scenario: Loading BNP Portfolio file

    Given I assign "ESISOD_PTF_NewClientCode.out" to variable "INPUT_FILENAME_1"

    When I create input file "${INPUT_FILENAME_1}" using template "ESISOD_PTF_template.out" with below codes from location "${testdata.path}"
      | ACC_ID_BNP1 | T_ACID_BNP_${TIMESTAMP} |

    When I copy files below from local folder "${testdata.path}/testdata" to the host "dmp.ssh.inbound" folder "${dmp.ssh.inbound.path}":
      | ${INPUT_FILENAME_1} |

    And I process files with below parameters and wait for the job to be completed
      | BUSINESS_FEED |                      |
      | FILE_PATTERN  | ${INPUT_FILENAME_1}  |
      | MESSAGE_TYPE  | EIS_MT_BNP_PORTFOLIO |

    Given I assign "${ACC_ID_BNP1}" to variable "OLD_BNP_ID"

  Scenario: Verified the BNP account ID (ACCT_ID in file to ACCT_ALT_ID in table) successfully loaded to FT_T_ACID

    Then I expect value of column "AcctAltID_BNP" in the below SQL query equals to "1":
      """
      SELECT COUNT(*) as AcctAltID_BNP FROM FT_T_ACID WHERE ACCT_ALT_ID in ('${ACC_ID_BNP1}')
      AND ACCT_ID_CTXT_TYP = 'BNPPRTID'
      """

  Scenario: Re Loading BNP Portfolio file (ESISOD_PTF File) with new ACCT_ID (ESISOD_PTF File)

    Given I assign "ESISOD_PTF_NewClientCode.out" to variable "INPUT_FILENAME_1"

    When I create input file "${INPUT_FILENAME_1}" using template "ESISOD_PTF_template.out" with below codes from location "${testdata.path}"
      | ACC_ID_BNP1 | RELOAD_ACID_BNP_${TIMESTAMP} |

    When I copy files below from local folder "${testdata.path}/testdata" to the host "dmp.ssh.inbound" folder "${dmp.ssh.inbound.path}":
      | ${INPUT_FILENAME_1} |

    And I process files with below parameters and wait for the job to be completed
      | BUSINESS_FEED |                      |
      | FILE_PATTERN  | ${INPUT_FILENAME_1}  |
      | MESSAGE_TYPE  | EIS_MT_BNP_PORTFOLIO |

  Scenario: Old ACCT_ID (ESISOD_PTF File) should not be available in FT_T_ACID as it got overridden by new Id

    Then I expect value of column "RELOADED_BNP_OLD_RECORD" in the below SQL query equals to "0":
      """
      SELECT COUNT(*) as RELOADED_BNP_OLD_RECORD FROM FT_T_ACID WHERE ACCT_ALT_ID in ('${OLD_BNP_ID}')
      AND ACCT_ID_CTXT_TYP = 'BNPPRTID'
      """

  Scenario: Newly added ACCT_ID (ESISOD_PTF File) should get overridden in FT_T_ACID

    Then I expect value of column "RELOADED_BNP_NEW_RECORD" in the below SQL query equals to "1":
      """
      SELECT COUNT(*) as RELOADED_BNP_NEW_RECORD FROM FT_T_ACID WHERE ACCT_ALT_ID in ('${ACC_ID_BNP1}')
      AND ACCT_ID_CTXT_TYP = 'BNPPRTID'
      """

  Scenario: Re Loading BNP Portfolio file (ESISOD_PTF File) with Same ACCT_ID (ESISOD_PTF File)

    Given I assign "ESISOD_PTF_NewClientCode.out" to variable "INPUT_FILENAME_1"

    When I create input file "${INPUT_FILENAME_1}" using template "ESISOD_PTF_template.out" with below codes from location "${testdata.path}"
      |  |  |

    When I copy files below from local folder "${testdata.path}/testdata" to the host "dmp.ssh.inbound" folder "${dmp.ssh.inbound.path}":
      | ${INPUT_FILENAME_1} |

    And I process files with below parameters and wait for the job to be completed
      | BUSINESS_FEED |                      |
      | FILE_PATTERN  | ${INPUT_FILENAME_1}  |
      | MESSAGE_TYPE  | EIS_MT_BNP_PORTFOLIO |

    And I extract new job id from jblg table into a variable "JOB_ID"

  Scenario: Verify no exceptions should be thrown when BNP Portfolio load with same BNP ACCT ID i.e. ACCT_ID (ESISOD_PTF File)

    Then I expect value of column "EXCEPTION_MSG1_CHECK" in the below SQL query equals to "0":
      """
      SELECT COUNT(*) AS EXCEPTION_MSG1_CHECK FROM FT_T_NTEL NTEL
      JOIN FT_T_TRID TRID
      ON NTEL.LAST_CHG_TRN_ID = TRID.TRN_ID
      AND TRID.JOB_ID = '${JOB_ID}'
      AND NTEL.NOTFCN_STAT_TYP = 'OPEN'
      """




