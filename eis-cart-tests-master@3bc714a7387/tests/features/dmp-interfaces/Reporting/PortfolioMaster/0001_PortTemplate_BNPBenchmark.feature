#https://jira.intranet.asia/browse/TOM-5123

@tom_5123 @dmp_interfaces @reporting_dmp_interfaces @portfolio_uploader @tom_5139 @dmp_gs_upgrade
Feature: This feature is to test the new fields added for Reporting in the portfolio template.

  BNP L1 Primary Benchmark
  BNP L1 Secondary Benchmark
  BNP L3 Primary Benchmark

  Scenario: TC_1: Clear old test data and setup variables

    Given I assign "tests/test-data/dmp-interfaces/Reporting/PortfolioMaster" to variable "testdata.path"

    And I execute below query
    """
    ${testdata.path}/sql/cleardown.sql
    """

  Scenario: TC_2: Setup new account in DMP

    Given I assign "TOM-5123-PortTemplate-R6-attributes.xlsx" to variable "PORTFOLIO_FILENAME"
    And I copy files below from local folder "${testdata.path}/testdata/infiles" to the host "dmp.ssh.inbound" folder "${dmp.ssh.inbound.path}":
      | ${PORTFOLIO_FILENAME} |

    Then I process files with below parameters and wait for the job to be completed
      | BUSINESS_FEED |                                      |
      | FILE_PATTERN  | ${PORTFOLIO_FILENAME}                |
      | MESSAGE_TYPE  | EIS_MT_RDM_PORTFOLIO_MASTER_TEMPLATE |

  Scenario: TC_3: Data Verifications

    Then I expect value of column "ABMR_BNP_L1" in the below SQL query equals to "2":
        """
        select count(1) AS "ABMR_BNP_L1" from ft_T_abmr WHERE rl_typ in ('BL1PRIM','BL1SECON')
        and acct_id IN (SELECT acct_id FROM ft_t_acid WHERE acct_alt_id like 'Test5123' and end_tms is null)
        """

    Then I expect value of column "ABMR_BNP_L1_YBNCH" in the below SQL query equals to "2":
        """
        select count(1) AS "ABMR_BNP_L1_YBNCH" from ft_T_abmr WHERE rl_typ in ('BL1PRIM','BL1SECON')
        and acct_id IN (SELECT acct_id FROM ft_t_acid WHERE acct_alt_id like 'Test5123_YBNCH' and end_tms is null)
        """

    Then I expect value of column "ABMR_BNP_SECONDARY" in the below SQL query equals to "2":
        """
        select count(1) AS "ABMR_BNP_SECONDARY" from ft_T_abmr WHERE rl_typ in ('BL1PRIM','BL1SECON')
        and acct_id IN (SELECT acct_id FROM ft_t_acid WHERE acct_alt_id like '%Share5123%' and end_tms is null)
        """

    Then I expect value of column "SHRCLS_IRPID" in the below SQL query equals to "1":
        """
        select count(1) AS "SHRCLS_IRPID" from ft_T_acid WHERE acct_id_ctxt_typ = 'IRPID'
        and acct_id IN (SELECT acct_id FROM ft_t_acid WHERE acct_alt_id like '%Share5123%' and end_tms is null)
        """

    Then I expect value of column "ABMR_BNP_L3_P" in the below SQL query equals to "1":
        """
        select count(1) AS "ABMR_BNP_L3_P" from ft_T_abmr WHERE rl_typ in ('BL3PRIM')
        and acct_id IN (SELECT acct_id FROM ft_t_acid WHERE acct_alt_id like '%Test5139%' and end_tms is null)
        """

    Then I expect value of column "ABMR_BNP_L3_S" in the below SQL query equals to "1":
        """
        select count(1) AS "ABMR_BNP_L3_S" from ft_T_abmr WHERE rl_typ in ('BL3PRIM')
        and acct_id IN (SELECT acct_id FROM ft_t_acid WHERE acct_alt_id like '%Share5139%' and end_tms is null)
        """

