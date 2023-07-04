#https://jira.intranet.asia/browse/TOM-4687
#https://collaborate.intranet.asia/display/FUNDAPPS/FA-IN-SMF-LBURCR-DMP-Fund-File
#https://jira.intranet.asia/browse/EISDEV-5400 - Changes to load GP files directly. The transaction connector will load RCR as well GP files in DMP


@gc_interface_transactions
@dmp_regression_unittest
@tom_4687 @dmp_fundapps_functional @tom_4788 @dmp_fundapps_regression @eisdev_5400 @fundapps_transaction_inbound_gp
Feature: Transaction GP WFOE file load (Golden Source)

  1) Security & Fund creation in DMP through any feed file load from RCRLBU.
  2) As the fund file is dependant on ORG Chart for FINS data, we are loading the dependant ORG Chart data first.

  #Prerequisites
  Scenario: TC_1: Clear Trade data and load pre-requisite Org Chart data

    Given I assign "tests/test-data/dmp-interfaces/FundApps/Functional/Transaction" to variable "testdata.path"
    And I assign "WFOEEISLTRANSN20190319_test.csv" to variable "INPUT_FILENAME"

    When I extract below values for row 2 from CSV file "${INPUT_FILENAME}" in local folder "${testdata.path}/inputfiles/WFOE" with reference to "SECURITY.CLIENT_ID" column and assign to variables:
      | SECURITY.CLIENT_ID | Security_ID |
      | PORTFOLIO          | FUND_ID     |
      | EXT_ID1            | TRD_ID      |
      | TRADE_DATE         | TRD_DTE     |
      | QUANTITY           | TRD_CQT     |
      | TRD_CURRENCY       | TRD_CUR_CDE |
      | PRICE              | TRD_PRZ     |

    And I assign "WFOECODE" to variable "ID_CTXT_TYPE"
    And I assign "CRTSID" to variable "ACCT_ID_CTXT"
    And I assign "WFOEEOD" to variable "TRN_CDE"
    And I assign "P" to variable "TRN_SUB_TYP"

    And I execute below query
    """
    ${testdata.path}/sql/Clear_data.sql
    """

  Scenario: TC_2: Load Transaction Data File

    When I copy files below from local folder "${testdata.path}/inputfiles/WFOE" to the host "dmp.ssh.inbound" folder "${dmp.ssh.inbound.path}":
      | WFOEEISLTRANSN20190319_test.csv |

    And I process files with below parameters and wait for the job to be completed
      | FILE_PATTERN  | WFOEEISLTRANSN20190319_test* |
      | MESSAGE_TYPE  | EIS_MT_WFOE_DMP_TXN          |
      | BUSINESS_FEED |                              |

    Then I extract new job id from jblg table into a variable "JOB_ID"
    And I expect value of column "JBLG_ROW_COUNT" in the below SQL query equals to "1":
    """
    SELECT count(*) as JBLG_ROW_COUNT FROM FT_T_JBLG
    WHERE JOB_ID = '${JOB_ID}'
    AND JOB_STAT_TYP ='CLOSED'
    """

  Scenario: TC_3: Verification of EXTR For  Transaction Data from  File

    Then I expect value of column "VERIFY_EXECTRD" in the below SQL query equals to "1":
    """
	${testdata.path}/sql/VERIFY_EXTR_CHECK_GP.sql
    """

  Scenario: TC_4: Verification of ETCL For  Transaction_type

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

  Scenario: TC_5: Verification of ACCT_ORG_ID and ACCT_BK_ID For  Trade

    Then I expect value of column "VERIFY_ORG_BK" in the below SQL query equals to "1":
    """
	${testdata.path}/sql/VERIFY_ORG_BK_ID_CHECK.sql
    """
