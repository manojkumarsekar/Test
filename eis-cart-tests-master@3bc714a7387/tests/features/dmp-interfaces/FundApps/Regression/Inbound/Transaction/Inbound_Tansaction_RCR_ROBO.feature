#https://collaborate.pruconnect.net/display/EISTOMR4/FA-IN-TXN-LBURCR-DMP-Transaction
#https://jira.pruconnect.net/browse/EISDEV-6128

@gc_interface_funds @gc_interface_transactions @gc_interface_securities
@dmp_regression_integrationtest
@eisdev_6128 @fa_transactions_robo @fa_inbound @dmp_fundapps_functional @dmp_fundapps_regression

Feature: Transaction RCRLBU ROBO file load (Golden Source)

  1) Security & Fund creation in DMP through any feed file load from RCRLBU.
  2) As the fund file is dependant on ORG Chart for FINS data, we are loading the dependant ORG Chart data first.
  3) Load the transactions from the file and verify the transaction count and types

  #Prerequisites
  Scenario: TC_1: Clear Trade data and load pre-requisite Org Chart data

    Given I assign "tests/test-data/dmp-interfaces/FundApps/Regression/Inbound/Transaction" to variable "testdata.path"
    And I assign "ROBOEISLTRANSN20200421.CSV" to variable "INPUT_FILENAME"

    When I extract below values for row 2 from PSV file "${INPUT_FILENAME}" in local folder "${testdata.path}/testdata/ROBO" with reference to "Security Id" column and assign to variables:
      | Security Id      | Security_ID |
      | Fund Id          | FUND_ID     |
      | Transaction Id   | TRD_ID      |
      | Transaction Type | TRN_SUB_TYP |
      | Transaction Date | TRD_DTE     |
      | Quantity         | TRD_CQT     |
      | Trade Currency   | TRD_CUR_CDE |
      | Trade Price      | TRD_PRZ     |

    And I assign "ROBOCODE" to variable "ID_CTXT_TYPE"
    And I assign "CRTSID" to variable "ACCT_ID_CTXT"
    And I assign "ROBOEOD" to variable "TRN_CDE"

    And I execute below query to "remove the ROBO Transactions from EXTR table"
    """
    ${testdata.path}/sql/Clear_data.sql
    """

  Scenario: TC_2: File load for RCRLBU Fund for Data Source ROBO

    Given I assign "ROBOEISLFUNDLE20200421.CSV" to variable "INPUT_FILENAME"

    When I process "${testdata.path}/testdata/ROBO/${INPUT_FILENAME}" file with below parameters
      | FILE_PATTERN  | ROBOEISLFUNDLE*      |
      | MESSAGE_TYPE  | EIS_MT_ROBO_DMP_FUND |
      | BUSINESS_FEED |                      |

    Then I expect workflow is processed in DMP with total record count as "1"

  Scenario: TC_3: Load pre-requisite Security Data before file

    Given I assign "ROBOEISLINSTMT20200421.CSV" to variable "INPUT_FILENAME"

    When I process "${testdata.path}/testdata/ROBO/${INPUT_FILENAME}" file with below parameters
      | FILE_PATTERN  | ROBOEISLINSTMT*          |
      | MESSAGE_TYPE  | EIS_MT_ROBO_DMP_SECURITY |
      | BUSINESS_FEED |                          |

    Then I expect workflow is processed in DMP with total record count as "1"

  Scenario: TC_4: Load Transaction Data File

    Given I assign "ROBOEISLTRANSN20200421.CSV" to variable "INPUT_FILENAME"

    When I process "${testdata.path}/testdata/ROBO/${INPUT_FILENAME}" file with below parameters
      | FILE_PATTERN  | ROBOEISLTRANSN*     |
      | MESSAGE_TYPE  | EIS_MT_ROBO_DMP_TXN |
      | BUSINESS_FEED |                     |

    Then I expect workflow is processed in DMP with total record count as "1"

  Scenario: TC_5: Verification of EXTR For  Transaction Data from  File

    Then I expect value of column "VERIFY_EXECTRD" in the below SQL query equals to "1":
    """
	${testdata.path}/sql/VERIFY_EXTR_CHECK.sql
    """

  Scenario: TC_6: Verification of ETCL For  Transaction_type

    Then I expect value of column "VERIFY_TRAB_TYPE" in the below SQL query equals to "1":
    """
    select count(*) as VERIFY_TRAB_TYPE
    from fT_T_etcl
    where cl_value='P'
    and indus_cl_set_id='TRANTYPE'
    and exec_trd_id in
                      (
                          select exec_trd_id from fT_T_extr  where trd_id='${TRD_ID}'
                       )
    """

  Scenario: TC_7: Verification of ACCT_ORG_ID and ACCT_BK_ID For  Trade

    Then I expect value of column "VERIFY_ORG_BK" in the below SQL query equals to "1":
    """
	${testdata.path}/sql/VERIFY_ORG_BK_ID_CHECK.sql
    """