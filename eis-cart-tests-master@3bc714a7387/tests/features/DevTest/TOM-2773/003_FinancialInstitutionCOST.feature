#https://jira.intranet.asia/browse/TOM-2773
#tom_4158 : update test portfolio and cleardown script

@gc_interface_securities
@dmp_regression_unittest
@tom_2773 @tom_4158
Feature: Loading BBG files to create FinancialInsitution
  Each vendor should create its own FINS/FIID as there are no common identifiers between them.

  Scenario: TC_4.1: Load files for EIS_BBG_DMP_SECURITY

    Given I assign "TC-04.1_VES.out" to variable "INPUT_FILENAME_1"
    And I assign "tests/test-data/DevTest/TOM-2773" to variable "testdata.path"

    And I execute below query to "Clear data from FINS and its Child table"
    """
    ${testdata.path}/sql/04_ClearDataFINS.sql
    """

    When I copy files below from local folder "${testdata.path}/testdata" to the host "dmp.ssh.inbound" folder "${dmp.ssh.inbound.path}":
      | ${INPUT_FILENAME_1} |

    Given I process files with below parameters and wait for the job to be completed
      | BUSINESS_FEED |                                  |
      | FILE_PATTERN  | ${INPUT_FILENAME_1}              |
      | MESSAGE_TYPE  | EIS_MT_BBG_SECURITY_PER_SECURITY |

    Then I expect value of column "ID_COUNT_COST" in the below SQL query equals to "1":
      """
    select COUNT(*) AS ID_COUNT_COST
    from fT_T_cost where inst_mnem in (select inst_mnem from fT_T_frip
    where instr_id in (select instR_id from ft_t_isid
    where iss_id='USP7807HAT25'
    and end_tms is null)
    and end_tms is null)
    and stats_curr_cde='VES'
    """

  Scenario: TC_4.2: Load files for EIS_BBG_DMP_SECURITY

    Given I assign "TC-04.2_VEF.out" to variable "INPUT_FILENAME_2"


    When I copy files below from local folder "${testdata.path}/testdata" to the host "dmp.ssh.inbound" folder "${dmp.ssh.inbound.path}":
      | ${INPUT_FILENAME_2} |

    Given I process files with below parameters and wait for the job to be completed
      | BUSINESS_FEED |                                  |
      | FILE_PATTERN  | ${INPUT_FILENAME_2}              |
      | MESSAGE_TYPE  | EIS_MT_BBG_SECURITY_PER_SECURITY |

    Then I expect value of column "ID_COUNT_COST" in the below SQL query equals to "1":
      """
    select COUNT(*) AS ID_COUNT_COST
    from fT_T_cost where inst_mnem in (select inst_mnem from fT_T_frip
    where instr_id in (select instR_id from ft_t_isid
    where iss_id='USP7807HAT25'
    and end_tms is null)
    and end_tms is null)
    and stats_curr_cde='VEF'
    """