#https://jira.intranet.asia/browse/TOM-2253
#https://collaborate.intranet.asia/pages/viewpage.action?spaceKey=TOMR3&title=Provision+of+prices+to+BRS+for+Processing+Portfolios
#EISDEV-6773 : Price validation are not invoked for matured securities. adding an update statement to nullify maturity date for the test security
# EISDEV-7120 In order to speed up the execution time of golden price calculation, added the instruments and set RUNPVCFORPRVI as "False" part of parameters

#Reducing burden on integration test by tagging this under too_slow tag. temporarily adding this under unit_tests as integration already overloaded
@gc_interface_securities @gc_interface_prices
@dmp_regression_unittest
#@dmp_regression_integrationtest
@1003_esipx_gp_calc @eisdev_6773 @pvc @eisdev_7120
Feature: Provision of ESIPX prices to BRS and Golden Price Calculation as per Defined Hierarchy. Tolerance Valid Check.

  As a User I should be able to load ESIPX prices from Bloomberg to DMP. And should be able to calculate GP for Instrument as per Defined Logic.
  Golden Source Tolerance rules should comes into picture and error to be raised in FT_T_ISPS table, when there is a breach of Tolerance Limit between Yesterday's and Today's Golden Price
  The Logic is defined below:
  EQ = 10%
  FI = 2%
  OTHERS = 10%
  Index = 50%

  Scenario: TC_1: Assigning Files to variables prior to execution

    Given I assign "BBG_ESIPX_PRICES_EQ_TOL_T_DAY_Template.out" to variable "BB_PRICE_FEED_TEMPLATE1"
    And I assign "BBG_ESIPX_PRICES_EQ_TOL_VALID_CHECK_Template.out" to variable "BB_PRICE_FEED_TEMPLATE3"
    And I assign "600" to variable "workflow.max.polling.time"

    And I assign "BBG_ESIPX_PRICES_EQ_1.out" to variable "BB_PRICE_FEED"
    And I assign "tests/test-data/pricing/processing_portfolios/REQ3_ESIPX_BBG" to variable "testdata.path"
    And I assign "SEC_CREATE__BNP.out" to variable "SECURITY_FILE"
    And I generate value with date format "yyyyMMdd" and assign to variable "PRC_TMS"

    And I execute below query to "teardown and update existing test data"
      """
      ${testdata.path}/sql/01_teardown_and_update.sql
      """

  Scenario: TC_2: Setting up Instruments with BNP Feed load

    Given I setup instruments defined in the BB price feed with BNP file "${SECURITY_FILE}" in the path "${testdata.path}/security_feed"

  Scenario: TC_3: Configure Instrument with Pricing requirements and Load Price Feed

    When I create input file "${BB_PRICE_FEED}" using template "${BB_PRICE_FEED_TEMPLATE1}" from location "${testdata.path}"

    Then I copy files below from local folder "${testdata.path}/testdata" to the host "dmp.ssh.inbound" folder "${dmp.ssh.inbound.path}":
      | ${BB_PRICE_FEED} |

    Then I ensure all instruments defined in the BB price feed "${testdata.path}/testdata/${BB_PRICE_FEED}" are configured with BBPRICEGRP group

    And I process files with below parameters and wait for the job to be completed
      | FILE_PATTERN  | ${BB_PRICE_FEED}                 |
      | MESSAGE_TYPE  | EIS_MT_BBG_SECURITY_PER_SECURITY |
      | BUSINESS_FEED |                                  |

    And I update PPED_OID column for all instruments defined in the BB price feed "${testdata.path}/testdata/${BB_PRICE_FEED}" with ESIPRPTEOD

    Then I process Goldenprice calculation with below parameters and wait for the job to be completed
      | PROCESSING_DATE                       | ${PRC_TMS}                                          |
      | RUNPVCFORPRVI                         | false                                               |
      | RUN_UNLISTED_WARRANT_PRICE_DERIVATION | false                                               |
      | RUN_THAI_PRICE_DERIVATION             | false                                               |
      | INSTRUMENTS                           | BBG000DKCC19,BBG00FY2JQC3,BBG0015VR9D0,BBG000BN2HR7 |

    And I execute below query and extract values of "NEXT_BIZ_DAY" into same variables
      """
      SELECT TO_CHAR(GREG_DTE,'YYYYMMDD') AS NEXT_BIZ_DAY FROM (SELECT * FROM FT_T_CADP WHERE BUS_DTE_IND = 'Y' AND TO_CHAR(GREG_DTE,'YYYYMMDD') > '${PRC_TMS}' ORDER BY GREG_DTE)
      WHERE ROWNUM = 1
      """

    And I modify date "${NEXT_BIZ_DAY}" with "+0d" from source format "yyyyMMdd" to destination format "yyyyMMdd" and assign to "PRC_TMS"

    When I create input file "${BB_PRICE_FEED}" using template "${BB_PRICE_FEED_TEMPLATE3}" from location "${testdata.path}"

    Then I copy files below from local folder "${testdata.path}/testdata" to the host "dmp.ssh.inbound" folder "${dmp.ssh.inbound.path}":
      | ${BB_PRICE_FEED} |

    And I process files with below parameters and wait for the job to be completed
      | FILE_PATTERN  | ${BB_PRICE_FEED}                 |
      | MESSAGE_TYPE  | EIS_MT_BBG_SECURITY_PER_SECURITY |
      | BUSINESS_FEED |                                  |

    And I update PPED_OID column for all instruments defined in the BB price feed "${testdata.path}/testdata/${BB_PRICE_FEED}" with ESIPRPTEOD

    Then I process Goldenprice calculation with below parameters and wait for the job to be completed
      | PROCESSING_DATE                       | ${PRC_TMS}                                          |
      | RUNPVCFORPRVI                         | false                                               |
      | RUN_UNLISTED_WARRANT_PRICE_DERIVATION | false                                               |
      | RUN_THAI_PRICE_DERIVATION             | false                                               |
      | INSTRUMENTS                           | BBG000DKCC19,BBG00FY2JQC3,BBG0015VR9D0,BBG000BN2HR7 |

  Scenario Outline: TC_4: Golden Price Verification with less than Tolerance Limit

    Given I extract below values for row <RecordNum> from BBGPSV file "${BB_PRICE_FEED}" in local folder "${testdata.path}/testdata" and assign to variables:
      | ID_BB_GLOBAL         | ID_BB_GLOBAL |
      | <GoldenPrice_Column> | GOLDEN_PRICE |

    And I execute below query and extract values of "INSTR_ID" into same variables
    """
    SELECT INSTR_ID FROM FT_T_ISID WHERE ISS_ID IN ('${ID_BB_GLOBAL}') AND END_TMS IS NULL
    """

    Then I expect value of column "GOLDEN_PRICE_COUNT" in the below SQL query equals to "1":
    """
    SELECT COUNT(*) AS GOLDEN_PRICE_COUNT FROM FT_T_GPCS
    WHERE INSTR_ID = '${INSTR_ID}'
    AND CMNT_REAS_TYP = 'GOLDENPRICE'
    AND TO_CHAR(PRC_TMS,'YYYYMMDD') = '${PRC_TMS}'
    AND GPRC_IND = 'Y'
    AND PRC_VALID_LIST_TXT = 'CAL;ZCHK;GOLDENPRICE;GSTOL'
    AND PPED_OID = 'ESIPRPTEOD'
    AND GPCS_TYP = 'VALID'
    AND PRCNG_METH_TYP = 'ESIPX'
    AND PRC_QT_METH_TYP = 'PRCQUOTE'
    AND PRC_SRCE_TYP = 'ESALL'
    AND DATA_SRC_ID = 'BB'
    AND UNIT_CPRC = ${GOLDEN_PRICE}
    """

    Examples:
      | RecordNum | GoldenPrice_Column | BB_ID        |
      | 1         | PX_LAST            | BBG000DKCC19 |
      | 2         | PX_BID             | BBG00FY2JQC3 |
      | 3         | PX_BID             | BBG0015VR9D0 |
      | 4         | PRIOR_CLOSE_MID    | BBG000BN2HR7 |

  Scenario: TC_5: Clear Golden Price Calculation Records
  Deleting all records in FT_T_ISPS, FT_T_GPCS and FT_T_ISPC tables. Since we are running this test for 2 dates,
  i.e. T and T+1, it is required to clear data for both dates.

    And I execute below query to "teardown and update existing test data"
      """
      ${testdata.path}/sql/01_teardown_and_update.sql
      """

    Then I delete price records for all instruments defined in the BB price feed "${testdata.path}/testdata/${BB_PRICE_FEED}"

    And I generate value with date format "yyyyMMdd" and assign to variable "PRC_TMS"

    And I delete price records for all instruments defined in the BB price feed "${testdata.path}/testdata/${BB_PRICE_FEED}"

  Scenario: Cleanup max polling time variable
    Then I remove variable "workflow.max.polling.time" from memory