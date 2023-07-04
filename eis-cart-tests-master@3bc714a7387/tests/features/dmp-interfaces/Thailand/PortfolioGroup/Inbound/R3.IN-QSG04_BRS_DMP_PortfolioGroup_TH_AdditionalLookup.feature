#https://jira.pruconnect.net/browse/EISDEV-6204

@gc_interface_portfolios
@dmp_regression_integrationtest
@eisdev_6204 @001_portfolio_group_th_additional_lookup @dmp_thailand @dmp_thailand_portfolio_group
Feature: Test changes for DMP to BRS Portfolio Group for additional lookup on PORTFOLIOS_PORTFOLIO_NAME field

  1. PortGroup file has two identifiers - the BRSFUNDID and the Portfolio ID
  2. Currently the PortGroup depends on F54 since the lookup happens only based on BRSFUNDID
  3. Due to this dependency if the F54 load fails or if a portfolio is not present in F54 the PortGroup also fails
  4. In case where the Fund ID lookup fails , the Portfolio ID needs to be used for lookup and if Portfolio ID is present the Portgroup update should happen
  5. As part of this test we are setting up a portfolio without BRSFUNDID. Lookup will happen on CRTSID and Account Group participant creation will be tested

  Scenario: TC1: Initialize all the variables

    Given I assign "001_R3.IN-QSG04_BRS_DMP_Portfolio_TH_AdditionalLookup.xlsx" to variable "PORTFOLIO_INPUT_FILENAME"
    And I assign "001_R3.IN-QSG04_BRS_DMP_PortfolioGroup_TH_AdditionalLookup.xml" to variable "PORTFOLIO_GROUP_INPUT_FILENAME"

    And I assign "tests/test-data/dmp-interfaces/Thailand/PortfolioGroup/Inbound" to variable "testdata.path"

  Scenario: TC2: Load Portfolio File to setup portfolio if not present

    Given I copy files below from local folder "${testdata.path}/testdata" to the host "dmp.ssh.inbound" folder "${dmp.ssh.inbound.path}":
      | ${PORTFOLIO_INPUT_FILENAME} |

    Given I process files with below parameters and wait for the job to be completed
      | BUSINESS_FEED |                                      |
      | FILE_PATTERN  | ${PORTFOLIO_INPUT_FILENAME}          |
      | MESSAGE_TYPE  | EIS_MT_RDM_PORTFOLIO_MASTER_TEMPLATE |

    Then I expect workflow is processed in DMP with total record count as "1"

  Scenario: TC3: Load Portfolio Group file to setup Account Group Participant

    Given I copy files below from local folder "${testdata.path}/testdata" to the host "dmp.ssh.inbound" folder "${dmp.ssh.inbound.path}":
      | ${PORTFOLIO_GROUP_INPUT_FILENAME} |

    When I process files with below parameters and wait for the job to be completed
      | BUSINESS_FEED |                                   |
      | FILE_PATTERN  | ${PORTFOLIO_GROUP_INPUT_FILENAME} |
      | MESSAGE_TYPE  | EIS_MT_BRS_PORTFOLIO_GROUP        |

    Then I expect workflow is processed in DMP with total record count as "1"

  Scenario: TC4: Check if Portfolio Group participant is created

    Then I expect value of column "ACGP_COUNT" in the below SQL query equals to "1":
    """
	select count(1) as "ACGP_COUNT" from ft_t_acgp where prnt_acct_grp_oid in
    (select acct_grp_oid from ft_t_acgr where acct_grp_id = 'EISDEV6204_TEST_GROUP')
    """