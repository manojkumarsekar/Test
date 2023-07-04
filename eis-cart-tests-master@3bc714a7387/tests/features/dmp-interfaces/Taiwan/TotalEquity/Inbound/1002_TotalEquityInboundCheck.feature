#https://collaborate.intranet.asia/display/TOMTN/Taiwan+Security+-+BBG+Total+Equity
#https://jira.intranet.asia/browse/TOM-4135

@gc_interface_securities @gc_interface_equity
@dmp_regression_integrationtest
@dmp_taiwan
@tom_4135 @tw_total_equity_in @inbound_check @tw_total_equity
Feature: This feature is to test below scenarios for TotalEquity changes in existing BBG MDX

  1. BOND_TO_EQUITY_TICKER shared across multiple securities should not raise exception as it is set as Global Identifier

  Scenario: TC_1: Create Position file with POS_DATE as SYSDATE and Load into DMP

    Given I assign "tc_1_bndtoeqytckr_global.out" to variable "INPUT_FILENAME1"
    And I assign "tc_2_bndtoeqytckr_fundamentls.out" to variable "INPUT_FILENAME2"
    And I assign "tests/test-data/dmp-interfaces/Taiwan/Total_Equity" to variable "testdata.path"

    And I execute below query
    """
    UPDATE ft_t_isid SET end_tms = sysdate-1, start_tms = sysdate-1 WHERE id_ctxt_typ = 'BNDEQYTCKER' AND end_tms is null
    AND instr_id IN (SELECT instr_id FROM ft_t_isid WHERE iss_id IN ('XS1453462076','USG21886AB53') AND end_tms IS NULL)
    """

    And I copy files below from local folder "${testdata.path}/testdata" to the host "dmp.ssh.inbound" folder "${dmp.ssh.inbound.path}":
      | ${INPUT_FILENAME1} |
      | ${INPUT_FILENAME2} |

    And I process files with below parameters and wait for the job to be completed
      | BUSINESS_FEED |                                  |
      | FILE_PATTERN  | ${INPUT_FILENAME1}               |
      | MESSAGE_TYPE  | EIS_MT_BBG_SECURITY_PER_SECURITY |

    Then I expect value of column "NTEL_INVALID_COUNT" in the below SQL query equals to "0":
      """
      SELECT COUNT(1) AS NTEL_INVALID_COUNT FROM FT_T_NTEL
      WHERE NOTFCN_STAT_TYP = 'OPEN' AND LAST_CHG_TRN_ID IN
      (SELECT TRN_ID FROM FT_T_TRID WHERE JOB_ID IN
      (SELECT JOB_ID FROM (SELECT JOB_ID, ROW_NUMBER() OVER
      (PARTITION BY JOB_INPUT_TXT ORDER BY JOB_START_TMS DESC) R
      FROM FT_T_JBLG WHERE JOB_INPUT_TXT LIKE '%${INPUT_FILENAME1}')
      WHERE R=1))
      """

    Then I expect value of column "ISID_COUNT" in the below SQL query equals to "2":
      """
      SELECT COUNT(1) AS ISID_COUNT FROM FT_T_ISID WHERE ISS_ID = '823 HK'
      AND ID_CTXT_TYP = 'BNDEQYTCKER' AND END_TMS IS NULL AND INSTR_ID IN (SELECT INSTR_ID FROM FT_T_ISID
      WHERE ISS_ID IN ('XS1453462076','USG21886AB53') AND END_TMS IS NULL)
      """

  Scenario: TC_2: Load fundamental file to check whether ISAM is updated for all securities which have same BOND_TO_EQY_TICKER

    And I process files with below parameters and wait for the job to be completed
      | BUSINESS_FEED |                         |
      | FILE_PATTERN  | ${INPUT_FILENAME2}      |
      | MESSAGE_TYPE  | EIS_MT_BBG_TOTAL_EQUITY |


    Then I expect value of column "ISAM_COUNT" in the below SQL query equals to "4":
      """
      SELECT COUNT(1) AS ISAM_COUNT FROM FT_T_ISAM WHERE INSTR_ID IN (SELECT INSTR_ID
      FROM FT_T_ISID WHERE ISS_ID = '823 HK'
      AND ID_CTXT_TYP = 'BNDEQYTCKER' AND END_TMS IS NULL AND INSTR_ID IN (SELECT INSTR_ID FROM FT_T_ISID
      WHERE ISS_ID IN ('XS1453462076','USG21886AB53') AND END_TMS IS NULL)) AND ISS_AMT_TYP IN ('TOTEQYS','TOTEQYQ','TOTEQYA')
      AND END_TMS IS NULL
      """