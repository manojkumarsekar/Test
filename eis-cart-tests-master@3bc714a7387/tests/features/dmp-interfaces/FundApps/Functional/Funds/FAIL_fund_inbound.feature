#https://jira.intranet.asia/browse/TOM-4124
#https://collaborate.intranet.asia/display/FUNDAPPS/FA-IN-SMF-LBURCR-DMP-Fund-File

@dmp_rcrlbu_boci_fail_funds @tom_4124 @dmp_fundapps_functional @fund_apps_funds  @tom_4489
Feature: TOM-4124: Funds RCRLBU BOCI fail file load (Golden Source)

  1) Fund creation in DMP through any feed file load from RCRLBU.
  2) As the fund file is dependant on ORG Chart for FINS data, we are loading the dependant ORG Chart data first.

  #Prerequisites
  Scenario: TC_1: File load for RCRLBU Fund for Data Source BOCI for missing mandatory field

    Given I assign "tests/test-data/dmp-interfaces/FundApps/Functional/Funds" to variable "testdata.path"
    And I assign "BOCIEISLFUNDLE20181218_fail.csv" to variable "INPUT_FILENAME"

    When I copy files below from local folder "${testdata.path}/inputfiles/BOCI" to the host "dmp.ssh.inbound" folder "${dmp.ssh.inbound.path}":
      | ${INPUT_FILENAME} |

    And I process files with below parameters and wait for the job to be completed
      | FILE_PATTERN  | ${INPUT_FILENAME}    |
      | MESSAGE_TYPE  | EIS_MT_BOCI_DMP_FUND |
      | BUSINESS_FEED |                      |

    Then I extract new job id from jblg table into a variable "JOB_ID"

    #Verification of successful File load
    And I expect value of column "JBLG_ROW_COUNT" in the below SQL query equals to "1":
      """
      SELECT count(*) as JBLG_ROW_COUNT FROM FT_T_JBLG
      WHERE JOB_ID = '${JOB_ID}'
      AND JOB_STAT_TYP ='CLOSED'
      AND TASK_TOT_CNT = 1
      AND TASK_CMPLTD_CNT = 1
      AND TASK_SUCCESS_CNT = 0
      """

    #Verification of Exception table for the fund loaded with required data from file with missing fields
    And I expect value of column "EXCEPTION_ROW_COUNT" in the below SQL query equals to "1":
     """
     SELECT Count(DISTINCT(CHAR_VAL_TXT)) AS EXCEPTION_ROW_COUNT
     FROM   ft_t_ntel ntel
     join ft_t_trid trid
     ON ntel.last_chg_trn_id = trid.trn_id
     WHERE  trid.job_id = '${JOB_ID}'
     AND ntel.notfcn_stat_typ = 'OPEN'
     AND ntel.notfcn_id = '60001'
     AND ntel.msg_typ = 'EIS_MT_BOCI_DMP_FUND'
     AND ntel.parm_val_txt LIKE '%User defined Error%'
     """