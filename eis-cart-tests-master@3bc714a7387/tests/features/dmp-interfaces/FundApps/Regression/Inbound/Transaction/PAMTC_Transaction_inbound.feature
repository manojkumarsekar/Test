#https://jira.pruconnect.net/browse/EISDEV-5367
#https://collaborate.intranet.asia/display/FUNDAPPS/FA-IN-SMF-LBURCR-DMP-Fund-File
#EISDEV-7475: Adding filter for TRN_CDE

@gc_interface_funds @gc_interface_transactions @gc_interface_securities
@dmp_regression_integrationtest
@eisdev_5367 @dmp_fundapps_functional @eisdev_5367_transactions @eisdev_7475
Feature: Transaction RCRLBU PAMTC file load (Golden Source)

  Verifying transaction creation in DMP through new feed PAMTC and if the required attributes have been set up.

  #Prerequisites
  Scenario: TC_1: Clear Trade data and load pre-requisite Org Chart data

    Given I assign "tests/test-data/dmp-interfaces/FundApps/Functional/Transaction" to variable "testdata.path"
    And I assign "PAMTEISLTRANSN20191115.csv" to variable "INPUT_FILENAME"

    When I extract below values for row 2 from PSV file "${INPUT_FILENAME}" in local folder "${testdata.path}/inputfiles/PAMTC" with reference to "Security Id" column and assign to variables:

      | Security Id      | Security_ID |
      | Fund Id          | FUND_ID     |
      | Transaction Id   | TRD_ID      |
      | Transaction Type | TRN_SUB_TYP |
      | Transaction Date | TRD_DTE     |
      | Quantity         | TRD_CQT     |
      | Trade Currency   | TRD_CUR_CDE |
      | Trade Price      | TRD_PRZ     |

    And I assign "PAMTCCODE" to variable "ID_CTXT_TYPE"
    And I assign "CRTSID" to variable "ACCT_ID_CTXT"
    And I assign "PAMTCEOD" to variable "TRN_CDE"


    And I execute below query to "clear data to be loaded in subsequent step"
    """
    ${testdata.path}/sql/Clear_data.sql
    """

  Scenario: TC_2: File load for RCRLBU Fund for Data Source PAMTC

    When I copy files below from local folder "${testdata.path}/inputfiles/PAMTC" to the host "dmp.ssh.inbound" folder "${dmp.ssh.inbound.path}":
      | PAMTEISLFUNDLE20191115.csv |

    And I process files with below parameters and wait for the job to be completed
      | FILE_PATTERN  | PAMTEISLFUNDLE*       |
      | MESSAGE_TYPE  | EIS_MT_PAMTC_DMP_FUND |
      | BUSINESS_FEED |                       |

    Then I expect workflow is processed in DMP with success record count as "1"

  Scenario: TC_3: Load pre-requisite Security Data before file

    When I copy files below from local folder "${testdata.path}/inputfiles/PAMTC" to the host "dmp.ssh.inbound" folder "${dmp.ssh.inbound.path}":
      | PAMTEISLINSTMT20191115.csv |

    And I process files with below parameters and wait for the job to be completed
      | FILE_PATTERN  | PAMTEISLINSTMT*           |
      | MESSAGE_TYPE  | EIS_MT_PAMTC_DMP_SECURITY |
      | BUSINESS_FEED |                           |

    Then I expect workflow is processed in DMP with success record count as "1"

  Scenario: TC_4: Load Transaction Data File

    When I copy files below from local folder "${testdata.path}/inputfiles/PAMTC" to the host "dmp.ssh.inbound" folder "${dmp.ssh.inbound.path}":
      | PAMTEISLTRANSN20191115.csv |

    And I process files with below parameters and wait for the job to be completed
      | FILE_PATTERN  | PAMTEISLTRANSN*      |
      | MESSAGE_TYPE  | EIS_MT_PAMTC_DMP_TXN |
      | BUSINESS_FEED |                      |

    Then I expect workflow is processed in DMP with success record count as "1"

  Scenario: TC_5: Check if transaction file has populated EXTR (Executed Transaction) table in DMP

    Then I expect value of column "VERIFY_EXECTRD" in the below SQL query equals to "1":
    """
	${testdata.path}/sql/VERIFY_EXTR_CHECK.sql
    """

  Scenario: TC_6: Check if transaction file has populated ETCL (Executed Transaction) table in DMP

    Then I expect value of column "VERIFY_ETCL_TYPE" in the below SQL query equals to "1":
    """
    select count(*) as VERIFY_ETCL_TYPE
    from fT_T_etcl where cl_value='P'
    and indus_cl_set_id='TRANTYPE'
    and exec_trd_id in
	(
	select exec_trd_id from fT_T_extr  where trd_id='${TRD_ID}'  and trn_cde='PAMTCEOD'
	)
    """

  Scenario: TC_7: Verification of ACCT_ORG_ID and ACCT_BK_ID For  Trade

    Then I expect value of column "VERIFY_ORG_BK" in the below SQL query equals to "1":
    """
	${testdata.path}/sql/VERIFY_ORG_BK_ID_CHECK.sql
    """