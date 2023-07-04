# ==============================================================================================
# Date            JIRA           Comments
# ==============================================================================================
# 06/04/2020      EISDEV-5546    Automate price upload for securities with stale prices in SOI
# 06/04/2020      EISDEV-6649    To enhance job whereby if “PRC_TMS” has multiple value, job will look at “LAST_CHG_TMS” for latest available price
# ==============================================================================================
# FS: https://collaborate.pruconnect.net/display/EISTOMR3/Solution+Area+-+Price+R3

@gc_interface_prices
@dmp_regression_unittest
@eisdev_5546 @eisdev_6649
Feature: 001 | Price | Stale Price | Verify Price Load/Publish

  This interface is to load the stale prices for the securities that are part of STLPRCSOI
  SOI: STLPRCSOI - Helps to define the list of securites for which stale prices should present

  Scenario: Setup the data as a Prerequisite

    Given I assign "tests/test-data/dmp-interfaces/Prices/Stale_Prices" to variable "testdata.path"

    # Clear ISPC and ISGP data
    Given I execute below query to "Clear ISPC and ISGP data"
    """
    ${testdata.path}/sql/001_SetupData.sql;
    """

  Scenario: Load Stale Price for the securities in SOI STLPRCSOI

    Given I process DeriveESIStalePrices workflow with below parameters
      | GROUP_NAME     | STLPRCSOI |
      | NO_OF_BRANCH   | 5         |
      | PRC_SRCE_TYP   | ESM       |
      | PRC_TYP        | SODEIS    |
      | PRCNG_METH_TYP | ESIPX     |

    Then I expect workflow is processed in DMP with total record count as "5"

  Scenario: Data Verifications - Verifiying the sum of price values loaded for the securities part of STLPRCSOI in the ISPC table

    Then I expect value of column "UNIT_CPRC" in the below SQL query equals to "322.7137":
      """
      ${testdata.path}/sql/001_ValidatePriceData.sql
      """
