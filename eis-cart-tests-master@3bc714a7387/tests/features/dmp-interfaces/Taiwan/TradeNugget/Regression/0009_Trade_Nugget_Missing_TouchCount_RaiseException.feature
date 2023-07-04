#https://jira.intranet.asia/browse/TOM-3844
#https://collaborate.intranet.asia/display/TOMR4/R5.IN-TRAN10+Aladdin-%3EDMP+TW+Trades

@gc_interface_transactions
@dmp_regression_unittest
@dmp_taiwan
@tom_3844 @tom_3385 @tw_touchcount_missing
Feature: TW Intraday Trades Interface Testing (R5.IN-TRAN10 Trades BRS to DMP) - Missing Touch Count for new Trade

#  EISTOMTEST-3966 -raised for developers to look into this
  Scenario: TC1:Verify missing Touch count in BRS file raise exception

    Given I assign "BondGovt_Missing_TouchCount.xml" to variable "INPUT_FILENAME"
    And  I assign "tests/test-data/dmp-interfaces/Taiwan/TradeNugget" to variable "testdata.path"

    And I copy files below from local folder "${testdata.path}/infiles/regression" to the host "dmp.ssh.inbound" folder "${dmp.ssh.inbound.path}":
      | ${INPUT_FILENAME} |

    When I process files with below parameters and wait for the job to be completed
      | BUSINESS_FEED |                                 |
      | FILE_PATTERN  | ${INPUT_FILENAME}               |
      | MESSAGE_TYPE  | EIS_MT_BRS_INTRADAY_TRANSACTION |

    And I extract new job id from jblg table into a variable "JOB_ID"
    Then I expect value of column "NTEL_ROW_COUNT" in the below SQL query equals to "1":
      """
      SELECT COUNT(*) AS NTEL_ROW_COUNT FROM FT_T_NTEL WHERE NOTFCN_STAT_TYP = 'OPEN'
      AND NOTFCN_ID = 60001 AND MSG_SEVERITY_CDE = 40 AND LAST_CHG_TRN_ID IN
      (SELECT TRN_ID FROM FT_T_TRID WHERE JOB_ID ='${JOB_ID}')
      """
