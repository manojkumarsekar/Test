#base jira : https://jira.pruconnect.net/browse/EISDEV-7296

@gc_interface_securities @eisdev_7375
@dmp_regression_unittest
@exception_management
@notification_153
@eisdev_7296

Feature: Exception Management | 153 | BNP Security | TICKER
  Loading BNP Security with expecting no error Issue Usage Type as BNPLSTID for the TICKER

  Scenario: Initialize variables used across the feature file and clear up existing data

    Given I assign "tests/test-data/dmp-interfaces/Exception_Management/Notification_153" to variable "INPUT_FILEPATH"
    And I assign "012_153_BNP_SECURITY_TICKER.out" to variable "INPUT_FILENAME_1"

    And I execute below query to "clear existing data from ISID table"
    """
    UPDATE FT_T_ISID
    SET END_TMS=SYSDATE-1
    WHERE ISS_ID = '3333'
    AND ID_CTXT_TYP = 'TICKER'
    AND ISS_USAGE_TYP = 'MD_684772'
    """

  Scenario: Load BNP Security file

    When I process "${INPUT_FILEPATH}/${INPUT_FILENAME_1}" file with below parameters
      | BUSINESS_FEED |                                  |
      | FILE_PATTERN  | ${INPUT_FILENAME_1}            |
      | MESSAGE_TYPE  | EIS_MT_BNP_SECURITY|

  And I expect value of column "ISS_USAGE_TYP" in the below SQL query equals to "MD_684772":
        """
        SELECT iss_usage_typ AS ISS_USAGE_TYP
        FROM   ft_t_isid
        WHERE  iss_id = '3333'
               AND id_ctxt_typ = 'TICKER'
               AND Trunc(last_chg_tms) = Trunc(sysdate)
               AND end_tms IS NULL
        """