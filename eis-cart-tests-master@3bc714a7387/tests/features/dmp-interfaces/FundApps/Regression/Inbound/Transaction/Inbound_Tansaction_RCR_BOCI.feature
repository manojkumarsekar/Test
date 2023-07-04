#https://collaborate.intranet.asia/display/TOMR4/FA-IN-TXN-LBURCR-DMP-Transaction
#https://jira.intranet.asia/browse/TOM-4275
#https://jira.intranet.asia/browse/TOM-4718


@gc_interface_org_chart @gc_interface_funds @gc_interface_transactions @gc_interface_securities
@dmp_regression_integrationtest
@tom_4718 @fa_transactions_boci @fa_inbound @dmp_fundapps_functional @dmp_fundapps_regression
Feature: To verify that DMP receive the inbound Transaction file data from the entity BOCI
  1) Security & Fund creation in DMP through any feed file load from RCRLBU.
  2) As the fund file is dependant on ORG Chart for FINS data, we are loading the dependant ORG Chart data first
  3) Verify all the Transaction details in dmp

  #Prerequisites
  Scenario: TC_1: Clear Trade data

    Given I assign "tests/test-data/dmp-interfaces/FundApps/Regression/Inbound/Transaction" to variable "testdata.path"
    And I assign "BOCIEISLTRANSN20190529.csv" to variable "TRNS_INPUT_FILENAME"

    When I extract below values for row 2 from PSV file "${TRNS_INPUT_FILENAME}" in local folder "${testdata.path}/testdata/BOCI" with reference to "SECURITY_ID" column and assign to variables:
      | SECURITY_ID      | SECURITY_ID |
      | FUND_ID          | FUND_ID     |
      | TRANSACTION_ID   | TRD_ID      |
      | TRANSACTION_TYPE | TRN_SUB_TYP |
      | TRANSACTION_DATE | TRD_DTE     |
      | QUANTITY         | TRD_CQT     |
      | TRADE_CURRENCY   | TRD_CUR_CDE |
      | TRADE_PRICE      | TRD_PRZ     |

    And I assign "BOCICODE" to variable "ID_CTXT_TYPE"
    And I assign "BOCIEOD" to variable "TRN_CDE"
    And I assign "CRTSID" to variable "ACCT_ID_CTXT"

    And I execute below query
    """
    ${testdata.path}/sql/Clear_data.sql
    """

  Scenario: TC_2: Load pre-requisite ORG Chart Data before file
    Given I assign "BOCI_ORG_Chart_template.xls" to variable "ORG_INPUT_FILENAME"
    When I copy files below from local folder "${testdata.path}/testdata/BOCI" to the host "dmp.ssh.inbound" folder "${dmp.ssh.inbound.path}":
      | ${ORG_INPUT_FILENAME} |

    And I process files with below parameters and wait for the job to be completed
      | FILE_PATTERN  | BOCI_ORG_Chart_template.xls |
      | MESSAGE_TYPE  | EIS_MT_ORG_CHART_EXCEL      |
      | BUSINESS_FEED |                             |

    Then I extract new job id from jblg table into a variable "JOB_ID"

    And I expect value of column "JBLG_ROW_COUNT" in the below SQL query equals to "1":
      """
      SELECT count(*) as JBLG_ROW_COUNT FROM FT_T_JBLG
      WHERE JOB_ID = '${JOB_ID}'
      AND JOB_STAT_TYP ='CLOSED'
      """

  Scenario: TC_3: File load for RCRLBU Fund for Data Source BOCI
    Given I assign "BOCIEISLFUNDLE20190529.csv" to variable "FUND_INPUT_FILENAME"
    When I copy files below from local folder "${testdata.path}/testdata/BOCI" to the host "dmp.ssh.inbound" folder "${dmp.ssh.inbound.path}":
      | ${FUND_INPUT_FILENAME} |

    And I process files with below parameters and wait for the job to be completed
      | FILE_PATTERN  | BOCIEISLFUNDLE*      |
      | MESSAGE_TYPE  | EIS_MT_BOCI_DMP_FUND |
      | BUSINESS_FEED |                      |

    Then I extract new job id from jblg table into a variable "JOB_ID"
    And I expect value of column "JBLG_ROW_COUNT" in the below SQL query equals to "1":
      """
      SELECT count(*) as JBLG_ROW_COUNT FROM FT_T_JBLG
      WHERE JOB_ID = '${JOB_ID}'
      AND JOB_STAT_TYP ='CLOSED'
      """

  Scenario: TC_4: Load pre-requisite Security Data before file
    Given I assign "BOCIEISLINSTMT20190529.csv" to variable "INST_INPUT_FILENAME"
    When I copy files below from local folder "${testdata.path}/testdata/BOCI" to the host "dmp.ssh.inbound" folder "${dmp.ssh.inbound.path}":
      | ${INST_INPUT_FILENAME} |

    And I process files with below parameters and wait for the job to be completed
      | FILE_PATTERN  | BOCIEISLINSTMT*          |
      | MESSAGE_TYPE  | EIS_MT_BOCI_DMP_SECURITY |
      | BUSINESS_FEED |                          |

    Then I extract new job id from jblg table into a variable "JOB_ID"
    And I expect value of column "JBLG_ROW_COUNT" in the below SQL query equals to "1":
    """
    SELECT count(*) as JBLG_ROW_COUNT FROM FT_T_JBLG
    WHERE JOB_ID = '${JOB_ID}'
    AND JOB_STAT_TYP ='CLOSED'
    """

  Scenario: TC_5: Load Transaction Data File

    When I copy files below from local folder "${testdata.path}/testdata/BOCI" to the host "dmp.ssh.inbound" folder "${dmp.ssh.inbound.path}":
      | ${TRNS_INPUT_FILENAME} |

    And I process files with below parameters and wait for the job to be completed
      | FILE_PATTERN  | BOCIEISLTRANSN*     |
      | MESSAGE_TYPE  | EIS_MT_BOCI_DMP_TXN |
      | BUSINESS_FEED |                     |

    Then I extract new job id from jblg table into a variable "JOB_ID"
    And I expect value of column "JBLG_ROW_COUNT" in the below SQL query equals to "1":
    """
    SELECT count(*) as JBLG_ROW_COUNT FROM FT_T_JBLG
    WHERE JOB_ID = '${JOB_ID}'
    AND JOB_STAT_TYP ='CLOSED'
    """

  Scenario: TC_5: Verification of EXTR For Transaction Data from  File
  Validate Transaction Id, Transaction Date, Execution Date,Execution time, Settlement Date,Trade currency details

    Then I expect value of column "VERIFY_EXECTRD" in the below SQL query equals to "1":
    """
    ${testdata.path}/sql/VerifyExtr.sql
    """


  Scenario: TC_5: Verification of ETCL For  Transaction_type
  Validate Transaction Type for the corresponding transaction id

    Then I expect value of column "VERIFY_TRAB_TYPE" in the below SQL query equals to "1":
    """
     SELECT COUNT(*) AS VERIFY_TRAB_TYPE
     FROM FT_T_ETCL
     WHERE CL_VALUE='S'
     AND INDUS_CL_SET_ID='TRANTYPE'
     AND EXEC_TRD_ID IN
                (
                 SELECT EXEC_TRD_ID FROM FT_T_EXTR
				 WHERE TRD_ID='${TRD_ID}'
                )
    """