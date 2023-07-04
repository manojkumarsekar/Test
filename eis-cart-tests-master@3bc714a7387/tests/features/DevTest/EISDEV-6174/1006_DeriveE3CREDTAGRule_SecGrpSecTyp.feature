#https://collaborate.pruconnect.net/display/EISTOM/EIFFEL+III+Development+-+Credit+Tagging
#base jira : https://jira.pruconnect.net/browse/EISDEV-6174
#eisdev_6425 : new condition for SecGrpSecTyp has been added to the E3CreditTag rule

@gc_interface_securities
@dmp_regression_unittest
@e3credtag_brs @eisdev_6425 @e3credtag
Feature: Test derivation of E3CreditTag classification for SecGrpSecTyp Condition

  This feature tests derivation of E3CreditTag classification for SecGrpSecTyp Condition

  Scenario: Initialize variables used across the feature file

    Given I assign "tests/test-data/DevTest/EISDEV-6174" to variable "testdata.path"
    And I assign "cash_td_BPM2N7GB4.xml" to variable "INPUT_FILENAME_BRS"
    And I generate value with date format "YYYYMMdd" and assign to variable "VAR_SYSDATE"

  Scenario: End date Instruments in GC and VD DB for BPM2N7GB4

    Given I inactivate "BPM2N7GB4" instruments in GC database
    Given I inactivate "BPM2N7GB4" instruments in VD database

  Scenario: Load BRS File10 and verify data is successfully processed

    When I process "${testdata.path}/inputfiles/testdata/${INPUT_FILENAME_BRS}" file with below parameters
      | BUSINESS_FEED |                         |
      | FILE_PATTERN  | ${INPUT_FILENAME_BRS}   |
      | MESSAGE_TYPE  | EIS_MT_BRS_SECURITY_NEW |

    Then I expect workflow is processed in DMP with total record count as "1"

  Scenario: Verification if SECGROUP field is loaded in table FT_T_ISCL sucessfully

    Then I expect value of column "SECGROUP_COUNT" in the below SQL query equals to "1":
      """
      SELECT COUNT(*) as SECGROUP_COUNT
      FROM ft_T_iscl WHERE instr_id IN (SELECT instr_id FROM ft_t_isid WHERE iss_id = 'BPM2N7GB4' AND end_tms is null)
      AND INDUS_CL_SET_ID = 'SECGROUP' AND cl_value = 'CASH' AND end_tms IS NULL
      """

  Scenario: Verification if SECTYPE field is loaded in table FT_T_ISCL sucessfully

    Then I expect value of column "SECTYPE_COUNT" in the below SQL query equals to "1":
      """
      SELECT COUNT(*) as SECTYPE_COUNT
      FROM ft_T_iscl WHERE instr_id IN (SELECT instr_id FROM ft_t_isid WHERE iss_id = 'BPM2N7GB4' AND end_tms is null)
      AND INDUS_CL_SET_ID = 'SECTYPE' AND cl_value = 'TD' AND end_tms IS NULL
      """

  Scenario: Verification if E3 CREDIT TAG custom classification value is derived as per condition1 of java rule

    Then I expect value of column "E3CREDTAG_COUNT" in the below SQL query equals to "1":
      """
      SELECT COUNT(*) as E3CREDTAG_COUNT
      FROM ft_T_iscl WHERE instr_id IN (SELECT instr_id FROM ft_t_isid WHERE iss_id = 'BPM2N7GB4' AND end_tms is null)
      AND INDUS_CL_SET_ID = 'E3CREDTAG' AND cl_value = 'Non Credit' AND end_tms IS NULL
      """