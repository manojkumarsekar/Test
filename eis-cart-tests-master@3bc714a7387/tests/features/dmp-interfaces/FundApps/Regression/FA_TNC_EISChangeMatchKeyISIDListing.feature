#eisdev-6354 : Initial Version

@gc_interface_reuters
@dmp_regression_unittest
@fund_apps @eisdev_6354
Feature: EISChangeMatchKeyISIDListing Rule Config

  Verify INSTR_ID is not updated for Identifier TRDSYMIL. Unique ISID records are created based on RIC in issue usage type

  Scenario: End date Instruments in GC and VD DB

    Given I inactivate "CBG.BK" instruments in GC database
    Given I inactivate "CBGN.BK" instruments in GC database

  Scenario: Loading Security with RIC CBG.BK and TRDSYMIL 11490

    Given I assign "tests/test-data/dmp-interfaces/FundApps/EISChangeMatchKeyISIDListing" to variable "TESTDATA_PATH"
    And I assign "gs_CBG.BK.csv" to variable "INPUT_FILENAME_1"
    And I assign "gs_CBGN.BK.csv" to variable "INPUT_FILENAME_2"

    Given I copy files below from local folder "${TESTDATA_PATH}" to the host "dmp.ssh.inbound" folder "${dmp.ssh.inbound.path}":
      | ${INPUT_FILENAME_1} |

    When I process files with below parameters and wait for the job to be completed
      | BUSINESS_FEED |                               |
      | FILE_PATTERN  | ${INPUT_FILENAME_1}           |
      | MESSAGE_TYPE  | ReutersDSS_TermsandConditions |

    Then I expect workflow is processed in DMP with success record count as "1"

  Scenario: Data verification in GC for ISID with ISS_USAGE_TYP BG.BK
  Expect 1 valid isid should get loaded into FT_T_ISID table with ISS_USAGE_TYP CBG.BK

    Then I expect value of column "issu_count_gc" in the below SQL query equals to "1":
    """
    select count(*) as issu_count_gc from ft_t_isid where iss_id = '11490'
    and ID_CTXT_TYP = 'TRDSYMIL' and ISS_USAGE_TYP = 'CBG.BK'
    and instr_id in (select instr_id from ft_t_isid where iss_id = 'CBG.BK')
    and LAST_CHG_USR_ID = 'TRMCONDT'
    and trunc(START_TMS) = trunc(sysdate)
    and end_tms is null
    """

  Scenario: Loading Security with RIC CBGN.BK and TRDSYMIL 11490

    Given I assign "tests/test-data/dmp-interfaces/FundApps/EISChangeMatchKeyISIDListing" to variable "TESTDATA_PATH"
    Given I assign "gs_CBGN.BK.csv" to variable "INPUT_FILENAME_2"

    And I copy files below from local folder "${TESTDATA_PATH}" to the host "dmp.ssh.inbound" folder "${dmp.ssh.inbound.path}":
      | ${INPUT_FILENAME_2} |

    When I process files with below parameters and wait for the job to be completed
      | BUSINESS_FEED |                               |
      | FILE_PATTERN  | ${INPUT_FILENAME_2}           |
      | MESSAGE_TYPE  | ReutersDSS_TermsandConditions |

    Then I expect workflow is processed in DMP with success record count as "1"

  Scenario: Data verification in GC for ISID with ISS_USAGE_TYP BG.BK
  Expect existing ISID is retained

    Then I expect value of column "issu_count_gc" in the below SQL query equals to "1":
    """
    select count(*) as issu_count_gc from ft_t_isid where iss_id = '11490'
    and ID_CTXT_TYP = 'TRDSYMIL' and ISS_USAGE_TYP = 'CBG.BK'
    and instr_id in (select instr_id from ft_t_isid where iss_id = 'CBG.BK')
    and LAST_CHG_USR_ID = 'TRMCONDT'
    and trunc(START_TMS) = trunc(sysdate)
    and end_tms is null
    """

  Scenario: Data verification in GC for ISID with ISS_USAGE_TYP CBGN.BK
  Expect 1 valid isid should get loaded into FT_T_ISID table with ISS_USAGE_TYP CBGN.BK

    Then I expect value of column "issu_count_gc" in the below SQL query equals to "1":
    """
    select count(*) as issu_count_gc from ft_t_isid where iss_id = '11490'
    and ID_CTXT_TYP = 'TRDSYMIL' and ISS_USAGE_TYP = 'CBGN.BK'
    and instr_id in (select instr_id from ft_t_isid where iss_id = 'CBGN.BK')
    and LAST_CHG_USR_ID = 'TRMCONDT'
    and trunc(START_TMS) = trunc(sysdate)
    and end_tms is null
    """

