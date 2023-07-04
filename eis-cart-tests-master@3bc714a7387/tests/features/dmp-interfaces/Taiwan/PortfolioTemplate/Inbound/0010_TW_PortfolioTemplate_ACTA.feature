#https://collaborate.pruconnect.net/pages/viewpage.action?pageId=37309781
#https://jira.pruconnect.net/browse/EISDEV-5165
#https://jira.pruconnect.net/browse/EISDEV-6216: Included User Group File load with dummy email ids

@gc_interface_portfolios @gc_interface_user_group
@dmp_regression_integrationtest
@dmp_taiwan
@eisdev_5165 @eisdev_6216
Feature: Portfolio Uploader | ACTA | PORTFOLIO_MANAGER_1 | PORTFOLIO_MANAGER_2 | BACKUP_PORTFOLIO_MANAGER

  This feature is to test the duplicates are not created for PORTFOL_MGR1,PORTFOL_MGR2,BKP_PORTFOL_MGR in ACTA when an update is received
  1. Load portfolio template file with PORTFOL_MGR1,PORTFOL_MGR2,BKP_PORTFOL_MGR details
  2. Load portfolio template file with updated PORTFOL_MGR1,PORTFOL_MGR2,BKP_PORTFOL_MGR details

  Scenario: End date ACTA data for the test accounts and setup variables
  deleting existing ACTA entries to load data using the current file load

    Given I assign "tests/test-data/dmp-interfaces/Taiwan/PortfolioTemplate" to variable "testdata.path"
    And I assign "DMP_R3_PortfolioMasteringTemplate_Final_4.11_EISDEV_5165_Before.xlsx" to variable "PORTFOLIO_TEMPLATE_BEFORE"
    And I assign "DMP_R3_PortfolioMasteringTemplate_Final_4.11_EISDEV_5165_After.xlsx" to variable "PORTFOLIO_TEMPLATE_AFTER"
    And I assign "5165_UserGroup.xml" to variable "USER_GROUP"

    And I execute below query to "delete existing acta for the test portfolio"
	"""
    delete ft_t_acta where
    acct_id in (select acct_id from ft_t_acid where acct_alt_id  = 'TSTA5165');
    COMMIT
    """

  Scenario: Load User Group File
  Verify User Group File is Loaded with success count 4

    Given I copy files below from local folder "${testdata.path}/testdata/infiles" to the host "dmp.ssh.inbound" folder "${dmp.ssh.inbound.path}":
      | ${USER_GROUP} |

    When I process files with below parameters and wait for the job to be completed
      | BUSINESS_FEED |                       |
      | FILE_PATTERN  | ${USER_GROUP}         |
      | MESSAGE_TYPE  | EIS_MT_BRS_USER_GROUP |

    Then I expect workflow is processed in DMP with success record count as "6"

    Then I execute below query to "Remove TD001 from ACGR TWBDAM"
    """
    update ft_t_fpro set PRO_DESIGNATION_TXT = 'PM' where LAST_NME like '%5165%';
    commit;
    """

  Scenario: Load portfolio Template
  Verify Portfolio Template is Successfully Loaded with Success Count 1

    Given I copy files below from local folder "${testdata.path}/testdata/infiles" to the host "dmp.ssh.inbound" folder "${dmp.ssh.inbound.path}":
      | ${PORTFOLIO_TEMPLATE_BEFORE} |

    When I process files with below parameters and wait for the job to be completed
      | BUSINESS_FEED |                                      |
      | FILE_PATTERN  | ${PORTFOLIO_TEMPLATE_BEFORE}         |
      | MESSAGE_TYPE  | EIS_MT_RDM_PORTFOLIO_MASTER_TEMPLATE |

    Then I expect workflow is processed in DMP with success record count as "1"

  Scenario: Verify Data with ACTA for PORTFOL_MGR1
  Verify 1 Record for ACTA with CONTCT_RL_TYP = 'PORTFOLIO_MANAGER1' and FPRO id portfolio.manager.1.1@eastspring.com is created for fund TSTA5165

    Given I expect value of column "ACTA_PORTFOLIO_MANAGER1_BEFORE" in the below SQL query equals to "portfolio.manager.1.1@eastspring.com":
    """
    SELECT FPRO.FINS_PRO_ID AS ACTA_PORTFOLIO_MANAGER1_BEFORE FROM FT_T_ACTA ACTA, FT_T_ACID ACID, FT_T_FPRO FPRO
    WHERE ACTA.ACCT_ID = ACID.ACCT_ID
    AND ACTA.FPRO_OID = FPRO.FPRO_OID
    AND ACTA.CONTCT_RL_TYP = 'PORTFOLIO_MANAGER1'
    AND ACID.ACCT_ID_CTXT_TYP = 'CRTSID'
    AND ACID.ACCT_ALT_ID = 'TSTA5165'
    AND ACID.END_TMS IS NULL
    AND ACTA.END_TMS IS NULL
    """

  Scenario: Verify Data with ACTA for PORTFOL_MGR2
  Verify 1 Record for ACTA with CONTCT_RL_TYP = 'PORTFOLIO_MANAGER2' and FPRO id portfolio.manager.2.1@eastspring.com is created for fund TSTA5165

    Given I expect value of column "ACTA_PORTFOLIO_MANAGER2_BEFORE" in the below SQL query equals to "portfolio.manager.2.1@eastspring.com":
    """
    SELECT FPRO.FINS_PRO_ID AS ACTA_PORTFOLIO_MANAGER2_BEFORE FROM FT_T_ACTA ACTA, FT_T_ACID ACID, FT_T_FPRO FPRO
    WHERE ACTA.ACCT_ID = ACID.ACCT_ID
    AND ACTA.FPRO_OID = FPRO.FPRO_OID
    AND ACTA.CONTCT_RL_TYP = 'PORTFOLIO_MANAGER2'
    AND ACID.ACCT_ID_CTXT_TYP = 'CRTSID'
    AND ACID.ACCT_ALT_ID = 'TSTA5165'
    AND ACID.END_TMS IS NULL
    AND ACTA.END_TMS IS NULL
    """

  Scenario: Verify Data with ACTA for BACKUP_PORTFOLIO_MGR
  Verify 1 Record for ACTA with CONTCT_RL_TYP = 'BACKUP_PORTFOLIO_MGR' and FPRO id bkp.portfolio.manager.1@eastspring.com is created for fund TSTA5165

    Given I expect value of column "ACTA_BACKUP_PORTFOLIO_MGR_BEFORE" in the below SQL query equals to "bkp.portfolio.manager.1@eastspring.com":
    """
    SELECT FPRO.FINS_PRO_ID AS ACTA_BACKUP_PORTFOLIO_MGR_BEFORE FROM FT_T_ACTA ACTA, FT_T_ACID ACID, FT_T_FPRO FPRO
    WHERE ACTA.ACCT_ID = ACID.ACCT_ID
    AND ACTA.FPRO_OID = FPRO.FPRO_OID
    AND ACTA.CONTCT_RL_TYP = 'BACKUP_PORTFOLIO_MGR'
    AND ACID.ACCT_ID_CTXT_TYP = 'CRTSID'
    AND ACID.ACCT_ALT_ID = 'TSTA5165'
    AND ACID.END_TMS IS NULL
    AND ACTA.END_TMS IS NULL
    """

  Scenario: Re-Load portfolio Template with updated data
  Verify Portfolio Template is Successfully Loaded with Success Count 1

    Given I copy files below from local folder "${testdata.path}/testdata/infiles" to the host "dmp.ssh.inbound" folder "${dmp.ssh.inbound.path}":
      | ${PORTFOLIO_TEMPLATE_AFTER} |

    When I process files with below parameters and wait for the job to be completed
      | BUSINESS_FEED |                                      |
      | FILE_PATTERN  | ${PORTFOLIO_TEMPLATE_AFTER}          |
      | MESSAGE_TYPE  | EIS_MT_RDM_PORTFOLIO_MASTER_TEMPLATE |

    Then I expect workflow is processed in DMP with success record count as "1"

  Scenario: Verify Data with ACTA for PORTFOL_MGR1 After Re-load
  Verify 1 Record for ACTA with CONTCT_RL_TYP = 'PORTFOLIO_MANAGER1' and FPRO id portfolio.manager.1.2@eastspring.com is created for fund TSTA5165

    Given I expect value of column "ACTA_PORTFOLIO_MANAGER1_AFTER" in the below SQL query equals to "portfolio.manager.1.2@eastspring.com":
    """
    SELECT FPRO.FINS_PRO_ID AS ACTA_PORTFOLIO_MANAGER1_AFTER FROM FT_T_ACTA ACTA, FT_T_ACID ACID, FT_T_FPRO FPRO
    WHERE ACTA.ACCT_ID = ACID.ACCT_ID
    AND ACTA.FPRO_OID = FPRO.FPRO_OID
    AND ACTA.CONTCT_RL_TYP = 'PORTFOLIO_MANAGER1'
    AND ACID.ACCT_ID_CTXT_TYP = 'CRTSID'
    AND ACID.ACCT_ALT_ID = 'TSTA5165'
    AND ACID.END_TMS IS NULL
    AND ACTA.END_TMS IS NULL
    """

  Scenario: Verify Data with ACTA for PORTFOL_MGR2 After Re-load
  Verify 1 Record for ACTA with CONTCT_RL_TYP = 'PORTFOLIO_MANAGER2' and FPRO id portfolio.manager.2.2@eastspring.com is created for fund TSTA5165

    Given I expect value of column "ACTA_PORTFOLIO_MANAGER2_AFTER" in the below SQL query equals to "portfolio.manager.2.2@eastspring.com":
    """
    SELECT FPRO.FINS_PRO_ID AS ACTA_PORTFOLIO_MANAGER2_AFTER FROM FT_T_ACTA ACTA, FT_T_ACID ACID, FT_T_FPRO FPRO
    WHERE ACTA.ACCT_ID = ACID.ACCT_ID
    AND ACTA.FPRO_OID = FPRO.FPRO_OID
    AND ACTA.CONTCT_RL_TYP = 'PORTFOLIO_MANAGER2'
    AND ACID.ACCT_ID_CTXT_TYP = 'CRTSID'
    AND ACID.ACCT_ALT_ID = 'TSTA5165'
    AND ACID.END_TMS IS NULL
    AND ACTA.END_TMS IS NULL
    """

  Scenario: Verify Data with ACTA for BACKUP_PORTFOLIO_MGR After Re-load
  Verify 1 Record for ACTA with CONTCT_RL_TYP = 'BACKUP_PORTFOLIO_MGR' and FPRO id bkp.portfolio.manager.2@eastspring.com is created for fund TSTA5165

    Given I expect value of column "ACTA_BACKUP_PORTFOLIO_MGR_AFTER" in the below SQL query equals to "bkp.portfolio.manager.2@eastspring.com":
    """
    SELECT FPRO.FINS_PRO_ID AS ACTA_BACKUP_PORTFOLIO_MGR_AFTER FROM FT_T_ACTA ACTA, FT_T_ACID ACID, FT_T_FPRO FPRO
    WHERE ACTA.ACCT_ID = ACID.ACCT_ID
    AND ACTA.FPRO_OID = FPRO.FPRO_OID
    AND ACTA.CONTCT_RL_TYP = 'BACKUP_PORTFOLIO_MGR'
    AND ACID.ACCT_ID_CTXT_TYP = 'CRTSID'
    AND ACID.ACCT_ALT_ID = 'TSTA5165'
    AND ACID.END_TMS IS NULL
    AND ACTA.END_TMS IS NULL
    """

  Scenario: Re-set FPRO

    Given I execute below query to "reset FPRO"
	"""
    update ft_t_fpro set FINS_PRO_ID = 'azhar.arayilakath@eastspring.com'
    where fpro_oid in('Ec6Q58Mj81','Ec6e46Mj81','Dc6R45Mj81','Ec6)44Mj81','Ec6O44Mj81','Ec6C44Mj81');
    commit
    """