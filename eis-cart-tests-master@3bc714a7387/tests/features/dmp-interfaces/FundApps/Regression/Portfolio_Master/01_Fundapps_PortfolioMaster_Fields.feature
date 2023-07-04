#https://jira.intranet.asia/browse/TOM-4280
#EISDEV-5511 : as part of this ticket M&G Flag mapping has been removed. Removing the validation check from Feature

@gc_interface_portfolios
@dmp_regression_unittest
@tom_4280 @dmp_fundapps_functional @dmp_fundapps_regression @eisdev_5511
Feature: Loading Portfolio file to verify data load for FundApps Extra Field

  Scenario: TC_1: Load files for EIS_RDM_DMP_PORTFOLIO_MASTER

    Given I assign "Portfolio_fundapp.xlsx" to variable "INPUT_FILENAME"
    And I assign "tests/test-data/dmp-interfaces/FundApps/Functional/Portfolio_master" to variable "testdata.path"

    And I execute below query to "Clear data from FINS and its Child table"
      """
      ${testdata.path}/sql/01_CleanupFrap_Acid.sql
      """

    When I copy files below from local folder "${testdata.path}/inputfiles" to the host "dmp.ssh.inbound" folder "${dmp.ssh.inbound.path}":
      | ${INPUT_FILENAME} |

    Given I process files with below parameters and wait for the job to be completed
      | BUSINESS_FEED |                                      |
      | FILE_PATTERN  | ${INPUT_FILENAME}                    |
      | MESSAGE_TYPE  | EIS_MT_RDM_PORTFOLIO_MASTER_TEMPLATE |

    Then I extract new job id from jblg table into a variable "JOB_ID"

    And I expect value of column "JBLG_ROW_COUNT" in the below SQL query equals to "1":
	 """
	 SELECT count(*) as JBLG_ROW_COUNT FROM FT_T_JBLG WHERE JOB_ID = '${JOB_ID}'
	 """

  Scenario: TC_2:Verify data For Account Classification for FUND_VEHICLE_TYPE,INVEST_DISCRE_LE_VR_DISCRE,INVEST_DISCRE_LE_INVST_DISCRE

    Then I expect value of column "VERIFY_ACCT_CLASSI" in the below SQL query equals to "3":
     """
     select count (*) as  VERIFY_ACCT_CLASSI
     FROM  FT_T_ACCL
     WHERE ACCT_ID IN
                     (
                        SELECT ACCT_ID
                        FROM FT_T_ACID
                        WHERE ACCT_ALT_ID='Test4280'
                        AND END_TMS IS NULL
                      )
     and  indus_cl_set_id in ('LEINDISC','LEVRDISC','FNDVHCLTYP')
     and END_TMS IS NULL
     """

  Scenario: TC_3:Verify Data for Fins Role/Account participant

    Then I expect value of column "ID_COUNT_FRAP" in the below SQL query equals to "1":
     """
     SELECT COUNT(*) AS ID_COUNT_FRAP
     FROM FT_T_FRAP
     WHERE ACCT_ID IN (SELECT ACCT_ID FROM FT_T_ACID WHERE ACCT_ALT_ID='Test4280' AND END_TMS IS NULL)
     AND FINSRL_TYP in ('INVMGR')
     AND INST_MNEM IN (
                        SELECT INST_MNEM
                        FROM FT_T_FIID
                        WHERE FINS_ID='ES-SG'
                        AND FINS_ID_CTXT_TYP='INHOUSE'
                        AND END_TMS IS NULL
                        )
     AND END_TMS IS NULL
     """

  Scenario: TC_4:Verify Data for Account Statistics

    Then I expect value of column "VERIFY_ACCT_STAT" in the below SQL query equals to "2":
     """
     select COUNT(*)AS VERIFY_ACCT_STAT
     FROM FT_T_ACST
     WHERE stat_def_id in('SSHFLAG','PPMFLAG ','QFIIFLAG','STCFLAG ','FINIFLAG')
     and  ACCT_ID IN
                    (
                        SELECT ACCT_ID
                        FROM FT_T_ACID
                        WHERE ACCT_ALT_ID='Test4280'
                        AND END_TMS IS NULL
                    )
     AND  END_TMS IS NULL
     """

  Scenario: TC_5: Translator throws ERROR for finsrole if inputField does not match with the lookup(Negative Testing)

    Then I expect value of column "VERIFY_NESTED_ERROR_FINSROLE" in the below SQL query equals to "1":
     """
     SELECT COUNT(*) AS VERIFY_NESTED_ERROR_FINSROLE
     FROM ft_t_ntel ntel
     JOIN ft_t_trid trid
     ON ntel.last_chg_trn_id = trid.trn_id
     WHERE trid.job_id = '${JOB_ID}'
     AND ntel.msg_typ = 'EIS_MT_RDM_PORTFOLIO_MASTER_TEMPLATE'
     AND ntel.notfcn_stat_typ = 'OPEN'
     AND  ntel.char_val_txt in ('The company ID ''INHOUSE - ABCDS'' received from EIS is not present in the FinancialInstitutionIdentifier.')
     """
