#https://jira.intranet.asia/browse/EISDEV-5374
#https://collaborate.intranet.asia/pages/viewpage.action?pageId=53936905

@gc_interface_transactions
@dmp_regression_integrationtest
@dmp_fundapps_functional @dmp_fundapps_regression @fundapps_transaction_inbound_gp @eisdev_5374 @eisdev_5374_transactions
Feature: This feature is to load transaction file coming in GP format from CCB in DMP and verify if it got loaded successfully

  #Prerequisites
  Scenario: TC_1: Clear Trade data

    Given I assign "tests/test-data/dmp-interfaces/FundApps/Functional/Transaction" to variable "testdata.path"
    And I assign "esi_sc_transactions_ccb_qdlp_test.csv" to variable "INPUT_FILENAME"

    When I extract below values for row 2 from CSV file "${INPUT_FILENAME}" in local folder "${testdata.path}/inputfiles/WFOECCB" with reference to "SECURITY.CLIENT_ID" column and assign to variables:
      | SECURITY.CLIENT_ID | Security_ID |
      | PORTFOLIO          | FUND_ID     |
      | EXT_ID1            | TRD_ID      |
      | TRADE_DATE         | TRD_DTE     |
      | QUANTITY           | TRD_CQT     |
      | TRD_CURRENCY       | TRD_CUR_CDE |
      | PRICE              | TRD_PRZ     |

    And I assign "WFOECCBCODE" to variable "ID_CTXT_TYPE"
    And I assign "CRTSID" to variable "ACCT_ID_CTXT"
    And I assign "WFOECCBE" to variable "TRN_CDE"
    And I assign "P" to variable "TRN_SUB_TYP"

    And I execute below query to "end-date ETID so that new EXTR gets created when file is loaded"
    """
    ${testdata.path}/sql/Clear_data.sql
    """

    #Instrument and Account that we are setting up identifiers with
    And I assign "GS0000001286" to variable "ACCTID"
    #ISIN for instrument to link to
    And I assign "XS1679515038" to variable "INSTRID"

    #Instrument and Account identifiers for RCRLBU need to be set up before running position files
    And I execute below query to "insert ACID and ISID"
    """
    ${testdata.path}/sql/InsertIdentifier.sql
    """

  Scenario: TC_2: Load Transaction Data File

    When I copy files below from local folder "${testdata.path}/inputfiles/WFOECCB" to the host "dmp.ssh.inbound" folder "${dmp.ssh.inbound.path}":
      | esi_sc_transactions_ccb_qdlp_test.csv |

    And I process files with below parameters and wait for the job to be completed
      | FILE_PATTERN  | esi_sc_transactions_ccb_qdlp_test* |
      | MESSAGE_TYPE  | EIS_MT_WFOECCB_DMP_TXN             |
      | BUSINESS_FEED |                                    |

    Then I expect workflow is processed in DMP with success record count as "1"

  Scenario: TC_3: Check if transaction file has populated EXTR (Executed Transaction) table in DMP

    Then I expect value of column "VERIFY_EXECTRD" in the below SQL query equals to "1":
    """
	${testdata.path}/sql/VERIFY_EXTR_CHECK_GP.sql
    """

  Scenario: TC_4: Check if transaction file has populated ETCL (Executed Transaction) table in DMP

    Then I expect value of column "VERIFY_ETCL_TYPE" in the below SQL query equals to "1":
    """
    select count(*) as VERIFY_ETCL_TYPE
    from fT_T_etcl where cl_value='P'
    and indus_cl_set_id='TRANTYPE'
    and exec_trd_id in
	(
	select exec_trd_id from fT_T_extr  where trd_id='${TRD_ID}'
	)
    """