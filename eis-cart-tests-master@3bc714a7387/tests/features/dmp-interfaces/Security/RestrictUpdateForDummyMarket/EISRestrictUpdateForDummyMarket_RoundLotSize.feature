#eisdev-6740 : Initial Version
#eisdev-6791 : Add use case for decial round lot size

@gc_interface_securities @gc_interface_orders
@dmp_regression_integrationtest
@eisdev_6740 @eisdev_6791
Feature: EISRestrictUpdateForDummyMarket Rule Config
  Verify RoundLotSize is not updated for MKIS with valid market when incoming market is Dummy

  Scenario: End date Instruments in GC DB

    Given I inactivate "SBP3R5D09" instruments in GC database
    Given I inactivate "SB50YWZ55" instruments in GC database

  Scenario: Loading Security with BCUSIP SBP3R5D09 via F10 with Valid Market

    Given I assign "tests/test-data/dmp-interfaces/Security/EISRestrictUpdateForDummyMarket" to variable "TESTDATA_PATH"
    And I assign "SBP3R5D09.F10.xml" to variable "INPUT_FILENAME_F10"

    Given I copy files below from local folder "${TESTDATA_PATH}" to the host "dmp.ssh.inbound" folder "${dmp.ssh.inbound.path}":
      | ${INPUT_FILENAME_F10} |

    When I process files with below parameters and wait for the job to be completed
      | BUSINESS_FEED |                         |
      | FILE_PATTERN  | ${INPUT_FILENAME_F10}   |
      | MESSAGE_TYPE  | EIS_MT_BRS_SECURITY_NEW |

    Then I expect workflow is processed in DMP with success record count as "2"

  Scenario: Data verification in GC for MKIS with Round Lot Size 100 for BCUSIP SBP3R5D09
  Expect 1 valid mkis should get loaded into FT_T_MKIS table with RND_LOT_SZ_CQTY 100

    Then I expect value of column "RND_LOT_SZ_CQTY_F10" in the below SQL query equals to "100":
    """
    select mkis.RND_LOT_SZ_CQTY as RND_LOT_SZ_CQTY_F10 from ft_t_isid isid, ft_t_mixr mixr, ft_t_mkis mkis
    where isid.isid_oid = mixr.isid_oid
    and mixr.mkt_iss_oid = mkis.mkt_iss_oid
    and mixr.end_tms is null
    and mkis.end_tms is null
    and isid.end_tms is null
    and isid.iss_id = 'SBP3R5D09'
    """

  Scenario: Data verification in GC for MKIS with Round Lot Size 0.0123 for BCUSIP SB50YWZ55
  Expect 1 valid mkis should get loaded into FT_T_MKIS table with RND_LOT_SZ_CQTY 0.0123

    Then I expect value of column "RND_LOT_SZ_CQTY_F10" in the below SQL query equals to ".0123":
    """
    select mkis.RND_LOT_SZ_CQTY as RND_LOT_SZ_CQTY_F10 from ft_t_isid isid, ft_t_mixr mixr, ft_t_mkis mkis
    where isid.isid_oid = mixr.isid_oid
    and mixr.mkt_iss_oid = mkis.mkt_iss_oid
    and mixr.end_tms is null
    and mkis.end_tms is null
    and isid.end_tms is null
    and isid.iss_id = 'SB50YWZ55'
    """

  Scenario: Loading Security with BCUSIP SBP3R5D09 via Orders with Dummy Market

    Given I assign "tests/test-data/dmp-interfaces/Security/EISRestrictUpdateForDummyMarket" to variable "TESTDATA_PATH"
    And I assign "SBP3R5D09.order.xml" to variable "INPUT_FILENAME_ORDERS"

    And I copy files below from local folder "${TESTDATA_PATH}" to the host "dmp.ssh.inbound" folder "${dmp.ssh.inbound.path}":
      | ${INPUT_FILENAME_ORDERS} |

    When I process files with below parameters and wait for the job to be completed
      | BUSINESS_FEED |                          |
      | FILE_PATTERN  | ${INPUT_FILENAME_ORDERS} |
      | MESSAGE_TYPE  | EIS_MT_BRS_ORDERS        |

    Then I expect workflow is processed in DMP with success record count as "2"

  Scenario: Data verification in GC for MKIS with Round Lot Size remains 100 and not updated to 0 for BCUSIP SBP3R5D09
  Expect RND_LOT_SZ_CQTY is set to 100 and not updated to 0

    Then I expect value of column "RND_LOT_SZ_CQTY_ORDERS" in the below SQL query equals to "100":
    """
    select mkis.RND_LOT_SZ_CQTY as RND_LOT_SZ_CQTY_ORDERS from ft_t_isid isid, ft_t_mixr mixr, ft_t_mkis mkis
    where isid.isid_oid = mixr.isid_oid
    and mixr.mkt_iss_oid = mkis.mkt_iss_oid
    and mixr.end_tms is null
    and mkis.end_tms is null
    and isid.end_tms is null
    and isid.iss_id = 'SBP3R5D09'
    """

  Scenario: Data verification in GC for MKIS with Round Lot Size remains 100 and not updated to 0 for BCUSIP SB50YWZ55
  Expect RND_LOT_SZ_CQTY is set to 100 and not updated to 0

    Then I expect value of column "RND_LOT_SZ_CQTY_ORDERS" in the below SQL query equals to ".0123":
    """
    select mkis.RND_LOT_SZ_CQTY as RND_LOT_SZ_CQTY_ORDERS from ft_t_isid isid, ft_t_mixr mixr, ft_t_mkis mkis
    where isid.isid_oid = mixr.isid_oid
    and mixr.mkt_iss_oid = mkis.mkt_iss_oid
    and mixr.end_tms is null
    and mkis.end_tms is null
    and isid.end_tms is null
    and isid.iss_id = 'SB50YWZ55'
    """
