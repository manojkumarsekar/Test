#https://collaborate.intranet.asia/display/FUNDAPPS/FA-IN-SMF-LBURCR-DMP-Fund-File
#https://jira.intranet.asia/browse/EISDEV-7392
#EISDEV-7475: Adding filter for TRN_CDE and changing input file as per sample from WELL

@gc_interface_transactions
@dmp_regression_unittest
@eisdev_7392 @dmp_fundapps_functional @dmp_fundapps_regression @fundapps_transaction_inbound_well @eisdev_7475
Feature: Transaction GP WELL file load (Golden Source)

  #Prerequisites
  Scenario: TC_1: Clear Trade data and load pre-requisite Org Chart data

    Given I assign "tests/test-data/dmp-interfaces/FundApps/Regression/Inbound/Transaction" to variable "testdata.path"
    And I assign "WELLEISLTRANSN20190319.csv" to variable "INPUT_FILENAME"

    When I extract below values for row 2 from CSV file "${INPUT_FILENAME}" in local folder "${testdata.path}/testdata/WELL" with reference to "SECURITY.CLIENT_ID" column and assign to variables:
      | SECURITY.CLIENT_ID | Security_ID |
      | PORTFOLIO          | FUND_ID     |
      | EXT_ID1            | TRD_ID      |
      | TRADE_DATE         | TRD_DTE     |
      | QUANTITY           | TRD_CQT     |
      | TRD_CURRENCY       | TRD_CUR_CDE |
      | PRICE              | TRD_PRZ     |

    And I assign "WELLCODE" to variable "ID_CTXT_TYPE"
    And I assign "CRTSID" to variable "ACCT_ID_CTXT"
    And I assign "WELLEOD" to variable "TRN_CDE"
    And I assign "P" to variable "TRN_SUB_TYP"

    And I execute below query
    """
    ${testdata.path}/sql/Clear_data.sql
    """

    #Instrument and Account that we are setting up identifiers with. This is a temporary step as data is not present
    And I assign "GS0000006114" to variable "ACCTID"
    #ISIN for instrument to link to
    And I assign "XS1679515038" to variable "INSTRID"

    #Instrument and Account identifiers for RCRLBU need to be set up before running position files
    And I execute below query
    """
    ${testdata.path}/sql/InsertIdentifier.sql
    """

  Scenario: TC_2: Load Transaction Data File

    When I copy files below from local folder "${testdata.path}/testdata/WELL" to the host "dmp.ssh.inbound" folder "${dmp.ssh.inbound.path}":
      | WELLEISLTRANSN20190319.csv |

    And I process files with below parameters and wait for the job to be completed
      | FILE_PATTERN  | WELLEISLTRANSN20190319* |
      | MESSAGE_TYPE  | EIS_MT_WELL_DMP_TXN     |
      | BUSINESS_FEED |                         |


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
        select exec_trd_id from fT_T_extr  where trd_id='${TRD_ID}' and trn_cde='WELLEOD'
    )
    """

  Scenario: TC_5: Verification of ACCT_ORG_ID and ACCT_BK_ID For  Trade

    Then I expect value of column "VERIFY_ORG_BK" in the below SQL query equals to "1":
    """
	${testdata.path}/sql/VERIFY_ORG_BK_ID_CHECK.sql
    """
