#https://collaborate.pruconnect.net/display/EISTOM/EIFFEL+III+Development+-+Credit+Tagging
#base jira : https://jira.pruconnect.net/browse/EISDEV-6174
#eisdev_6425 : new condition for money market deposit has been added to the E3CreditTag rule.
#also verify VSH changes for iscl.INDUS_CL_SET_ID = 'E3CREDTAG' where BNP is able to update value set up by BRS

@gc_interface_securities
@dmp_regression_integrationtest
@e3credtag_brs @eisdev_6425 @e3credtag
Feature: Test derivation of E3CreditTag classification for Money Market Deposit

  This feature tests derivation of E3CreditTag classification for Money Market Deposit Condition

  Scenario: Initialize variables used across the feature file

    Given I assign "tests/test-data/DevTest/EISDEV-6174" to variable "testdata.path"
    And I assign "cash_cash_BES3B54D7.xml" to variable "INPUT_FILENAME_BRS"
    And I assign "bnp_BES3B54D7.out" to variable "INPUT_FILENAME_BNP"
    And I generate value with date format "YYYYMMdd" and assign to variable "VAR_SYSDATE"

  Scenario: End date Instruments in GC and VD DB for BES3B54D7

    Given I inactivate "BES3B54D7" instruments in GC database
    Given I inactivate "BES3B54D7" instruments in VD database

  Scenario: Load BRS File10 and verify data is successfully processed

    When I process "${testdata.path}/inputfiles/testdata/${INPUT_FILENAME_BRS}" file with below parameters
      | BUSINESS_FEED |                         |
      | FILE_PATTERN  | ${INPUT_FILENAME_BRS}   |
      | MESSAGE_TYPE  | EIS_MT_BRS_SECURITY_NEW |

    Then I expect workflow is processed in DMP with total record count as "1"

  Scenario: Verification if E3 CREDIT TAG custom classification value is derived as per condition1 of java rule to credit

    Then I expect value of column "E3CREDTAG_COUNT" in the below SQL query equals to "1":
      """
      SELECT COUNT(*) as E3CREDTAG_COUNT
      FROM ft_T_iscl WHERE instr_id IN (SELECT instr_id FROM ft_t_isid WHERE iss_id = 'BES3B54D7' AND end_tms is null)
      AND INDUS_CL_SET_ID = 'E3CREDTAG' AND cl_value = 'Credit' AND end_tms IS NULL
      """

  Scenario: Load BNP SOD File and verify data is successfully processed

    When I process "${testdata.path}/inputfiles/testdata/${INPUT_FILENAME_BNP}" file with below parameters
      | BUSINESS_FEED |                       |
      | FILE_PATTERN  | ${INPUT_FILENAME_BNP} |
      | MESSAGE_TYPE  | EIS_MT_BNP_SECURITY   |

    Then I expect workflow is processed in DMP with total record count as "1"

  Scenario: Verification of BSIT P9 to Money Market Deposit

    Then I expect value of column "bsit_p9" in the below SQL query equals to "1":
      """
      select count(*) as bsit_p9 from ft_v_bst1 where BSIT_P9 = 'Money Market Deposit'
      and instr_id in (SELECT instr_id FROM ft_t_isid WHERE iss_id = 'BES3B54D7' AND end_tms is null)
      """

  Scenario: Verification if E3 CREDIT TAG custom classification value is derived as per condition1 of java rule to credit

    Then I expect value of column "E3CREDTAG_COUNT" in the below SQL query equals to "1":
      """
      SELECT COUNT(*) as E3CREDTAG_COUNT
      FROM ft_T_iscl WHERE instr_id IN (SELECT instr_id FROM ft_t_isid WHERE iss_id = 'BES3B54D7' AND end_tms is null)
      AND INDUS_CL_SET_ID = 'E3CREDTAG' AND cl_value = 'Non Credit' AND end_tms IS NULL
      """