#https://jira.intranet.asia/browse/TOM-4127
#Rule for SID Validation

@tom_4892
Feature: TOM-4892: Positions RCRLBU MANDG file load (Golden Source) with SID Validation

  SID Validation error will be thrown for positions which are on XIDX exchange but do not have SID Number

  #Prerequisites
  Scenario: TC_1: Clear data for RCRLBU Position for Data Source MNG and initial variable assignment

    Given I assign "tests/test-data/dmp-interfaces/FundApps/Functional/Positions" to variable "testdata.path"

    And I execute below query
    """
    ${testdata.path}/sql/ClearBALH.sql
    """

    And I execute below query
    """
    update ft_t_frap set end_tms=SYSDATE-1 where end_tms is null and finsrl_typ='SIDIDTAG' and acct_id in (select ACCT_ID from ft_t_acid where acct_alt_id='ABNA' and acct_id_ctxt_typ='CRTSID')
    """

  Scenario: TC_5: File load for RCRLBU Position for Data Source MNG

    And I execute below query and extract values of "T_1" into same variables
    """
    select TO_CHAR(sysdate-1, 'DD/MM/YYYY') AS T_1 from dual
    """

    And I create input file "MANGEISLPOSITN.csv" using template "MANGEISLSLPOSN_template.csv" with below codes from location "${testdata.path}/inputfiles/MNG"
      | CURR_DATE_1 | ${T_1} |

    When I copy files below from local folder "${testdata.path}/inputfiles/MNG/testdata" to the host "dmp.ssh.inbound" folder "${dmp.ssh.inbound.path}":
      | MANGEISLPOSITN.csv |

    And I process files with below parameters and wait for the job to be completed
      | FILE_PATTERN  | MANGEISLPOSITN.csv      |
      | MESSAGE_TYPE  | EIS_MT_MNG_DMP_POSITION |
      | BUSINESS_FEED |                         |

    #Verification of successful File load
    Then I extract new job id from jblg table into a variable "JOB_ID"

    And I expect value of column "JBLG_ROW_COUNT" in the below SQL query equals to "1":
      """
      SELECT count(*) as JBLG_ROW_COUNT FROM FT_T_JBLG
      WHERE JOB_ID = '${JOB_ID}'
      AND JOB_STAT_TYP ='CLOSED'
      AND TASK_TOT_CNT = 3
      AND TASK_CMPLTD_CNT = 3
      AND TASK_SUCCESS_CNT = 2
      AND TASK_PARTIAL_CNT = 1
      """

  Scenario: TC_6: Verification of exception

    Then I expect value of column "EXCEPTION_MSG_CHECK" in the below SQL query equals to "1":
      """
      SELECT COUNT(*) AS EXCEPTION_MSG_CHECK
      FROM ft_t_ntel ntel
      JOIN ft_t_trid trid
      ON ntel.last_chg_trn_id = trid.trn_id
      WHERE trid.job_id = '${JOB_ID}'
      AND ntel.notfcn_stat_typ = 'OPEN'
      AND ntel.notfcn_id = '60031'
      AND ntel.CHAR_VAL_TXT LIKE '%SID number of the corresponding account%'
      """
