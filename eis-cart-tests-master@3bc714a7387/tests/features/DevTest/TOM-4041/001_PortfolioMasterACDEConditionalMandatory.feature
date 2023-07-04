#https://jira.intranet.asia/browse/TOM-4041

@gc_interface_portfolios
@dmp_regression_unittest
@tom_4041
Feature: share class is able to link with multiple main portfolio in GS but it should overwrite the existing one instead of creating new record in ACCR table.

  Scenario: TC_1: Setup share class and FT_T_ACCR table should be create

    Given I assign "ShortNameMissing.xlsx" to variable "INPUT_FILENAME_1"
    And I assign "ShortNamePresent.xlsx" to variable "INPUT_FILENAME_2"
    And I assign "tests/test-data/DevTest/TOM-4041" to variable "testdata.path"

    When I copy files below from local folder "${testdata.path}/testdata" to the host "dmp.ssh.inbound" folder "${dmp.ssh.inbound.path}":
      | ${INPUT_FILENAME_1} |
      | ${INPUT_FILENAME_2} |

    And I execute below query
	  """
	  delete ft_T_acde where acct_id in(select acct_id from fT_T_acct where acct_nme in ('TT56_CNY','TW PORTFOLIO LONG NAME 24'));
	  """

    And I process files with below parameters and wait for the job to be completed
      | FILE_PATTERN  | ${INPUT_FILENAME_1}                  |
      | MESSAGE_TYPE  | EIS_MT_RDM_PORTFOLIO_MASTER_TEMPLATE |
      | BUSINESS_FEED |                                      |

    Then I extract new job id from jblg table into a variable "JOB_ID"

    Then I expect value of column "NTEL_COUNT" in the below SQL query equals to "1":
    """
    SELECT COUNT(*) AS NTEL_COUNT FROM FT_T_NTEL
    WHERE last_chg_trn_id IN (SELECT trn_id FROM gs_gc.ft_t_trid WHERE JOB_ID = '${JOB_ID}')
    AND NOTFCN_STAT_TYP='OPEN'
    AND APPL_ID='TPS'
    AND PART_ID='TRANS'
    AND NOTFCN_ID='60001'
    AND PARM_VAL_TXT='User defined Error thrown! . Mandatory fields not specified in template:TRD_CHINESE_SHRT_PORT_FUND_NME'
    """

  Scenario: TC_2: Setup FT_T_ACCR table should be create with latest portfolio

    Given I process files with below parameters and wait for the job to be completed
      | FILE_PATTERN  | ${INPUT_FILENAME_2}                  |
      | MESSAGE_TYPE  | EIS_MT_RDM_PORTFOLIO_MASTER_TEMPLATE |
      | BUSINESS_FEED |                                      |

    Then I expect value of column "ACDE_COUNT" in the below SQL query equals to "1":
    """
    SELECT COUNT(*) AS ACDE_COUNT FROM FT_T_ACDE
    WHERE ACCT_ID IN (SELECT ACCT_ID FROM FT_T_ACCT WHERE ACCT_NME = 'Test_4041')
    AND NLS_CDE='CHINESEM'
    AND ACCT_NME='瀚亞亞太高股息基金'
    """