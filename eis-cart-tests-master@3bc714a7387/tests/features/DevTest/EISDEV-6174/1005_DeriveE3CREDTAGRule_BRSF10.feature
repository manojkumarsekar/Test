#https://collaborate.pruconnect.net/display/EISTOM/EIFFEL+III+Development+-+Credit+Tagging
#base jira : https://jira.pruconnect.net/browse/EISDEV-6174
#eisdev_6346 : enabled rule processing for F10 and defect fix for null pointer exception
#eisdev_6553 : removed start_tms mapping from rule. start_tms should not be updated on re-run

@gc_interface_securities
@dmp_regression_unittest
@e3credtag_brs @eisdev_6346 @e3credtag @eisdev_6553
Feature: Test derivation of E3CreditTag classification for BRS conditions

  This feature tests derivation of E3CreditTag classification from BRS F10 from java rule
  Null Pointer Exception for below two use cases are handled as part of this ticket
  1. Null Check has been added for deriveFrmCond1EsiCresctLev2 method for processing IssueClassification Segment with SEGPROCESSEDIND
  SEGPROCESSEDIND could be null for derived segmnts, for e.g RDMSECTYP
  2. Null Check has been added for createDerivedISCLSegments. IssueClassification Segments with SEGPROCESSEDIND null or Error should be ignored for processing

  Scenario: Initialize variables used across the feature file

    Given I assign "tests/test-data/DevTest/EISDEV-6174" to variable "testdata.path"
    And I assign "BRS_File10_BCUSIP6346.xml" to variable "INPUT_FILENAME_BRS"
    And I assign "brs_f10_handle_nullpointer.xml" to variable "INPUT_FILENAME_NULLPOINTER"
    And I generate value with date format "YYYYMMdd" and assign to variable "VAR_SYSDATE"

  Scenario: End date Instruments in GC and VD DB for BCUSIP6346

    Given I inactivate "BCUSIP6346" instruments in GC database
    Given I inactivate "BCUSIP6346" instruments in VD database

  Scenario: Load BRS File10 and verify data is successfully processed

    When I process "${testdata.path}/inputfiles/testdata/${INPUT_FILENAME_BRS}" file with below parameters
      | BUSINESS_FEED |                         |
      | FILE_PATTERN  | ${INPUT_FILENAME_BRS}   |
      | MESSAGE_TYPE  | EIS_MT_BRS_SECURITY_NEW |

    Then I expect workflow is processed in DMP with total record count as "1"

  Scenario: Verification if FUTURE_CLASS field is loaded in table FT_T_ISCL sucessfully

    Then I expect value of column "FUTCLASS_COUNT" in the below SQL query equals to "1":
      """
      SELECT COUNT(*) as FUTCLASS_COUNT
      FROM ft_T_iscl WHERE instr_id IN (SELECT instr_id FROM ft_t_isid WHERE iss_id = 'BCUSIP6346' AND end_tms is null)
      AND INDUS_CL_SET_ID = 'FUTCLASS' AND cl_value = 'GBOND' AND end_tms IS NULL
      """

  Scenario: Verification if E3 CREDIT TAG custom classification value is derived as per condition1 of java rule

    Then I expect value of column "E3CREDTAG_COUNT_BCUSIP6346" in the below SQL query equals to "1":
      """
      SELECT COUNT(*) as E3CREDTAG_COUNT_BCUSIP6346
      FROM ft_T_iscl WHERE instr_id IN (SELECT instr_id FROM ft_t_isid WHERE iss_id = 'BCUSIP6346' AND end_tms is null)
      AND INDUS_CL_SET_ID = 'E3CREDTAG' AND cl_value = 'Non Credit' AND end_tms IS NULL
      """

  Scenario: End date Instruments in GC and VD DB for BRSCVDXZ8

    Given I inactivate "BRSCVDXZ8" instruments in GC database
    Given I inactivate "BRSCVDXZ8" instruments in VD database

  Scenario: Load BRS File10 and verify data is successfully processed and no null pointer exception is thrown

    When I process "${testdata.path}/inputfiles/testdata/${INPUT_FILENAME_NULLPOINTER}" file with below parameters
      | BUSINESS_FEED |                               |
      | FILE_PATTERN  | ${INPUT_FILENAME_NULLPOINTER} |
      | MESSAGE_TYPE  | EIS_MT_BRS_SECURITY_NEW       |

    Then I expect workflow is processed in DMP with total record count as "1"

  Scenario: Verification if exception is thrown for processing one of the IndustryClassification segment

    Then I expect value of column "EXCEPTION_ISCL" in the below SQL query equals to "2":
      """
      select COUNT(*) as EXCEPTION_ISCL from ft_t_ntel
      where last_chg_trn_id in
      (select trn_id from ft_t_trid where job_id = '${JOB_ID}')
      and NOTFCN_STAT_TYP = 'OPEN'
      and PARM_VAL_TXT like '%IndustryClassification%'
      """

  Scenario: Verification if exception is not thrown while processing this record

    Then I expect value of column "EXCEPTION_NOTFCN_ID_2" in the below SQL query equals to "0":
      """
      select COUNT(*) as EXCEPTION_NOTFCN_ID_2 from ft_t_ntel
      where last_chg_trn_id in (select trn_id from ft_t_trid where job_id = '${JOB_ID}')
      and NOTFCN_ID = 2
      and PARM_VAL_TXT like '%com.j2fe.container.FatalContainerException%'
      """

  Scenario: Verification if E3 CREDIT TAG custom classification value is derived as per condition1 of java rule

    Then I expect value of column "E3CREDTAG_COUNT_BRSCVDXZ8" in the below SQL query equals to "1":
      """
      SELECT COUNT(*) as E3CREDTAG_COUNT_BRSCVDXZ8
      FROM ft_T_iscl WHERE instr_id IN (SELECT instr_id FROM ft_t_isid WHERE iss_id = 'BRSCVDXZ8' AND end_tms is null)
      AND INDUS_CL_SET_ID = 'E3CREDTAG' AND cl_value = 'Credit' AND end_tms IS NULL
      """

    Then I execute below query and extract values of "START_TMS" into same variables
      """
      SELECT START_TMS
      FROM ft_T_iscl WHERE instr_id IN (SELECT instr_id FROM ft_t_isid WHERE iss_id = 'BRSCVDXZ8' AND end_tms is null)
      AND INDUS_CL_SET_ID = 'E3CREDTAG' AND cl_value = 'Credit' AND end_tms IS NULL
      """

  Scenario: Load BRS File10 and verify start_tms is not updated

    When I process "${testdata.path}/inputfiles/testdata/${INPUT_FILENAME_NULLPOINTER}" file with below parameters
      | BUSINESS_FEED |                               |
      | FILE_PATTERN  | ${INPUT_FILENAME_NULLPOINTER} |
      | MESSAGE_TYPE  | EIS_MT_BRS_SECURITY_NEW       |

    Then I expect workflow is processed in DMP with total record count as "1"

    Then I expect value of column "START_TMS" in the below SQL query equals to "${START_TMS}":
      """
      SELECT START_TMS
      FROM ft_T_iscl WHERE instr_id IN (SELECT instr_id FROM ft_t_isid WHERE iss_id = 'BRSCVDXZ8' AND end_tms is null)
      AND INDUS_CL_SET_ID = 'E3CREDTAG' AND cl_value = 'Credit' AND end_tms IS NULL
      """