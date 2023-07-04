#https://jira.intranet.asia/browse/TOM-5116
#Rule for SID Validation

@tom_5116 @dmp_fundapps_functional @dmp_fundapps_regression
Feature: TOM-5116: Positions BRS file load (Golden Source) with SID Validation

  SID Validation error will be thrown for positions which are on XIDX exchange but do not have SID Number

  #Prerequisites
  Scenario: TC_1: Clear data for BRS Position and initial variable assignment

    Given I assign "tests/test-data/dmp-interfaces/FundApps/Functional/Positions" to variable "testdata.path"

    #Clearing all positions of SYSDATE and end-dating the SID so that the exception is thrown
    And I execute below query
    """
    ${testdata.path}/sql/ClearBALH.sql;
    update ft_t_frap set end_tms=SYSDATE-1
    where end_tms is null
    and finsrl_typ='SIDIDTAG'
    and acct_id in
    (
        select ACCT_ID from ft_t_acid
        where acct_alt_id = '10058'
        AND acct_id_ctxt_typ = 'BRSFUNDID'
        AND end_tms IS NULL
    )
    """

    And I generate value with date format "dd/MM/YYYY" and assign to variable "DYNAMIC_DATE"

  Scenario: TC_5: File load for BRS Position

    And I create input file "BRS-POSN.xml" using template "BRS-POSN-template.xml" from location "${testdata.path}/inputfiles/BRS"

    When I copy files below from local folder "${testdata.path}/inputfiles/BRS/testdata" to the host "dmp.ssh.inbound" folder "${dmp.ssh.inbound.path}":
      | BRS-POSN.xml |

    And I process files with below parameters and wait for the job to be completed
      | FILE_PATTERN  | BRS-POSN.xml                      |
      | MESSAGE_TYPE  | EIS_MT_BRS_EOD_POSITION_NON_LATAM |
      | BUSINESS_FEED |                                   |

    #Verification of successful File load
    Then I extract new job id from jblg table into a variable "JOB_ID"

    And I expect value of column "JBLG_ROW_COUNT" in the below SQL query equals to "1":
      """
      SELECT count(*) as JBLG_ROW_COUNT FROM FT_T_JBLG
      WHERE JOB_ID = '${JOB_ID}'
      AND JOB_STAT_TYP ='CLOSED'
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
