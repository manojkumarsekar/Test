#https://jira.intranet.asia/browse/TOM-5266
#https://jira.intranet.asia/browse/TOM-5295

@tom_5266 @dmp_interfaces @reporting_dmp_interfaces  @r6_regulatory_reporting @tom_5295

Feature: This feature is to test the new fields mapped in GC Positions table from File 29


  Scenario: TC_1: Setup variables

    Given I assign "tests/test-data/dmp-interfaces/Reporting/RegulatoryReporting/Positions" to variable "testdata.path"
    And I assign "001_RegReporting_PosNewFields.xml" to variable "POSITIONS_FILE29_FILENAME"
    And I assign "001_RegReporting_PreRequisitePosFile.xml" to variable "POSITIONS_FILENAME"


   #Position file is loaded before loading security analytics to fetch the position data for the portfolio.
  Scenario: TC_2: Load Position file in DMP

    Given I copy files below from local folder "${testdata.path}/testdata/Inbound" to the host "dmp.ssh.inbound" folder "${dmp.ssh.inbound.path}":
      | ${POSITIONS_FILENAME} |

    Then I process files with below parameters and wait for the job to be completed
      | BUSINESS_FEED |                               |
      | FILE_PATTERN  | ${POSITIONS_FILENAME}         |
      | MESSAGE_TYPE  | EIS_MT_BRS_EOD_POSITION_LATAM |


  Scenario: TC_2: Load Security file in DMP

    Given I copy files below from local folder "${testdata.path}/testdata/Inbound" to the host "dmp.ssh.inbound" folder "${dmp.ssh.inbound.path}":
      | ${POSITIONS_FILE29_FILENAME} |

    Then I process files with below parameters and wait for the job to be completed
      | BUSINESS_FEED |                              |
      | FILE_PATTERN  | ${POSITIONS_FILE29_FILENAME} |
      | MESSAGE_TYPE  | EIS_MT_BRS_RISK_ANALYTICS    |

    And I extract new job id from jblg table into a variable "VAR_JOB_ID"

    Then I expect value of column "SEC_LOAD_SCCS_COUNT" in the below SQL query equals to "1":
    """
    SELECT TASK_SUCCESS_CNT AS SEC_LOAD_SCCS_COUNT FROM FT_T_JBLG WHERE JOB_ID = '${VAR_JOB_ID}'
    """

  Scenario: TC_3: Data Verification in BAHL table

    Then I expect value of column "LOCAL_MKT_VALUE" in the below SQL query equals to "70003613.01":
      """
      SELECT LOCAL_CURR_MKT_CAMT AS LOCAL_MKT_VALUE FROM FT_T_BALH
       WHERE INSTR_ID IN
      (
          SELECT INSTR_ID FROM FT_T_ISID WHERE ISS_ID = 'BPM0UJEC4'
      )
      AND ACCT_ID IN (select acct_id from ft_t_acid where acct_alt_id = 'ALGAIF')
      """

    And I expect value of column "MKT_VALUE" in the below SQL query equals to "70003613.01":
    """
      SELECT BKPG_CURR_MKT_CAMT AS MKT_VALUE FROM FT_T_BALH
       WHERE INSTR_ID IN
      (
          SELECT INSTR_ID FROM FT_T_ISID WHERE ISS_ID = 'BPM0UJEC4'
      )
      AND ACCT_ID IN (select acct_id from ft_t_acid where acct_alt_id = 'ALGAIF')
      """

    And I expect value of column "CUR_FACE" in the below SQL query equals to "640723":
    """
      SELECT ORIG_FACE_CAMT AS CUR_FACE FROM FT_T_BALH
       WHERE INSTR_ID IN
      (
          SELECT INSTR_ID FROM FT_T_ISID WHERE ISS_ID = 'BPM0UJEC4'
      )
      AND ACCT_ID IN (select acct_id from ft_t_acid where acct_alt_id = 'ALGAIF')
      """