#Feature History
#TOM-2253 : https://collaborate.intranet.asia/pages/viewpage.action?spaceKey=TOMR3&title=Provision+of+prices+to+BRS+for+Processing+Portfolios
#TOM-3768 : Moved the location of the feature file from cart-tests/tests/features/pricing/processing_portfolios/1001_req3_provision_of_ESIPX_GP_CalcA.
#TOM-3768 : Removed the last_chg_usr_id = anonymus for GS issue reported under FO#463366
#EISDEV-4155 : Its a part of GC Upgrade ticket, Included scenario for Missing Price for Prev day to see job should not fail with this scenario
# EISDEV-7120 In order to speed up the execution time of golden price calculation, added the instruments and set RUNPVCFORPRVI as "False" part of parameters

@gc_interface_securities @gc_interface_prices @eisdev_7120
@dmp_regression_integrationtest
@dmp_smoke @esipx_gp_calc @tom_3768 @tom_4742 @eisdev_4155 @pvc
Feature: GC Smoke | Orchestrator | ESI | Pricing | Pricing Process Consolidated | Derive ESI FV Price | Derive Thai Price | Refresh Price Validation SOI

  Provision of ESIPX prices to BRS and Golden Price Calculation as per Defined Hierarchy
  As a User I should be able to load ESIPX prices from Bloomberg to DMP. And should be able to calculate GP for Instrument as per Defined Logic.

  when DMP receive response from BBG, GS to apply the following to choose the correct price type for the particular security.
  EQ/INDEX/COMDTY = PX_LAST -> PX_CLOSE_1D -> PX_BID -> PX_ASK
  FI = PX_BID -> PX_ASK -> PX_LAST
  OTHERS = PX_LAST -> PRIOR_CLOSE_MID -> PX_CLOSE_1D

  Scenario: TC_1: Assigning Files to variables prior to execution

    Given I assign "BBG_ESIPX_PRICES_EQ_VALID_Template.out" to variable "BB_PRICE_FEED_TEMPLATE"
    Given I assign "BBG_ESIPX_PRICES_EQ_INVALID_Template.out" to variable "BB_PRICE_FEED_TEMPLATE2"
    And I assign "BBG_ESIPX_PRICES_EQ_1.out" to variable "BB_PRICE_FEED"
    And I assign "tests/test-data/pricing/processing_portfolios/REQ3_ESIPX_BBG" to variable "testdata.path"
    And I assign "SEC_CREATE__BNP.out" to variable "SECURITY_FILE"
    And I generate value with date format "yyyyMMdd" and assign to variable "PRC_TMS"

  Scenario Outline: TC_2: Prerequisites before running actual tests

    And I extract below values for row <RecordNum> from PSV file "${SECURITY_FILE}" in local folder "${testdata.path}/security_feed" and assign to variables:
      | INSTR_ID            | INSTR_ID     |
      | ISIN                | ISIN         |
      | SEDOL               | SEDOL        |
      | HIP_SECURITY_CODE   | HIP_SEC_CODE |
      | HIP_EXT2_ID         | HIP_EXT_ID   |
      | BLOOMBERG_GLOBAL_ID | BB_ID        |
      | EXCHANGE_TICKER     | TICKER       |

    Then I set end_tms to SYSDATE in database "dmp.db.VD" where iss_id in "'${INSTR_ID}','${ISIN}','${SEDOL}','${HIP_SECURITY_CODE}','${HIP_EXT_ID}','${BB_ID}','${TICKER}'"
    And I set end_tms to SYSDATE in database "dmp.db.GC" where iss_id in "'${INSTR_ID}','${ISIN}','${SEDOL}','${HIP_SECURITY_CODE}','${HIP_EXT_ID}','${BB_ID}','${TICKER}'"

    Examples:
      | RecordNum |
      | 2         |
      | 3         |
      | 4         |
      | 5         |
      | 6         |
      | 7         |
      | 8         |
      | 9         |

  Scenario: Delete 5 Days Data for TH0148A10Z14 intrument
  It is to replicate the scenario where GP Job runs successfully even if previous price is not available for one of the instrument.

    Given I execute below queries to "Delete FT_T_ISPS and FT_T_GPCS for TH0148A10Z14"
    """
    DELETE FT_T_ISPS WHERE ISS_PRC_ID IN
    (
      SELECT ISS_PRC_ID FROM FT_T_GPCS WHERE INSTR_ID IN (SELECT INSTR_ID FROM FT_T_ISID WHERE ISS_ID = 'TH0148A10Z14')AND TRUNC(LAST_CHG_TMS) > TRUNC(SYSDATE-5)
    );
    DELETE FT_T_GPCS WHERE INSTR_ID IN
    (
      SELECT INSTR_ID FROM FT_T_ISID WHERE ISS_ID = 'TH0148A10Z14'
    )
    AND TRUNC(LAST_CHG_TMS) > TRUNC(SYSDATE-5);
    COMMIT
    """

  Scenario: TC_3: Load Instruments

    When I copy files below from local folder "${testdata.path}/security_feed" to the host "dmp.ssh.inbound" folder "${dmp.ssh.inbound.path}":
      | ${SECURITY_FILE} |

    Then I process files with below parameters and wait for the job to be completed
      | FILE_PATTERN  | ${SECURITY_FILE}    |
      | MESSAGE_TYPE  | EIS_MT_BNP_SECURITY |
      | BUSINESS_FEED |                     |

  Scenario: TC_4: Creating BB price Feed and Load Price feed

    When I create input file "${BB_PRICE_FEED}" using template "${BB_PRICE_FEED_TEMPLATE}" from location "${testdata.path}"

    Then I copy files below from local folder "${testdata.path}/testdata" to the host "dmp.ssh.inbound" folder "${dmp.ssh.inbound.path}":
      | ${BB_PRICE_FEED} |

    Then I ensure all instruments defined in the BB price feed "${testdata.path}/testdata/${BB_PRICE_FEED}" are configured with BBPRICEGRP group

    And I process files with below parameters and wait for the job to be completed
      | FILE_PATTERN  | ${BB_PRICE_FEED}                 |
      | MESSAGE_TYPE  | EIS_MT_BBG_SECURITY_PER_SECURITY |
      | BUSINESS_FEED |                                  |

    And I update PPED_OID column for all instruments defined in the BB price feed "${testdata.path}/testdata/${BB_PRICE_FEED}" with ESIPRPTEOD

  Scenario: TC_5: Price Feed ESIPX Verifications in FT_T_ISPC For 1st Record in BB Price Feed

    Given I extract below values for row 1 from BBGPSV file "${BB_PRICE_FEED}" in local folder "${testdata.path}/testdata" and assign to variables:
      | ID_BB_GLOBAL    | ID_BB_GLOBAL    |
      | PRIOR_CLOSE_MID | PRIOR_CLOSE_MID |
      | PX_LAST         | PX_LAST         |
      | PX_BID          | PX_BID          |
      | PX_ASK          | PX_ASK          |
      | PX_MID          | PX_MID          |
      | PX_LAST_EOD     | PX_LAST_EOD     |
      | PX_CLOSE_1D     | PX_CLOSE_1D     |
      | CRNCY           | CRNCY           |

    Then I expect value of column "PRIOR_CLOSE_MID_COUNT" in the below SQL query equals to "1":
      """
      SELECT COUNT(*) AS PRIOR_CLOSE_MID_COUNT FROM FT_T_ISPC WHERE
      INSTR_ID IN (SELECT INSTR_ID FROM FT_T_ISID WHERE ISS_ID IN ('${ID_BB_GLOBAL}') AND END_TMS IS NULL)
      AND TO_CHAR(PRC_TMS,'YYYYMMDD') = '${PRC_TMS}'
      AND PRC_SRCE_TYP = 'ESALL'
      AND PRC_CURR_CDE = '${CRNCY}'
      AND PRC_QT_METH_TYP = 'PRCQUOTE'
      AND PRC_VALID_TYP = 'UNVERIFD'
      AND LAST_CHG_USR_ID = 'EIS_BBG_DMP_SECURITY'
      AND DATA_SRC_ID = 'BB'
      AND PRC_TYP = 'PRCLMID'
      AND PRCNG_METH_TYP = 'ESIPX'
      AND UNIT_CPRC = ${PRIOR_CLOSE_MID}
      """

    Then I expect value of column "PX_LAST_COUNT" in the below SQL query equals to "1":
      """
      SELECT COUNT(*) AS PX_LAST_COUNT FROM FT_T_ISPC WHERE
      INSTR_ID IN (SELECT INSTR_ID FROM FT_T_ISID WHERE ISS_ID IN ('${ID_BB_GLOBAL}') AND END_TMS IS NULL)
      AND TO_CHAR(PRC_TMS,'YYYYMMDD') = '${PRC_TMS}'
      AND PRC_SRCE_TYP = 'ESALL'
      AND PRC_CURR_CDE = '${CRNCY}'
      AND PRC_QT_METH_TYP = 'PRCQUOTE'
      AND PRC_VALID_TYP = 'UNVERIFD'
      AND LAST_CHG_USR_ID = 'EIS_BBG_DMP_SECURITY'
      AND DATA_SRC_ID = 'BB'
      AND PRC_TYP = '003'
      AND PRCNG_METH_TYP = 'ESIPX'
      AND UNIT_CPRC = ${PX_LAST}
      """

    Then I expect value of column "PX_BID_COUNT" in the below SQL query equals to "1":
      """
      SELECT COUNT(*) AS PX_BID_COUNT FROM FT_T_ISPC WHERE
      INSTR_ID IN (SELECT INSTR_ID FROM FT_T_ISID WHERE ISS_ID IN ('${ID_BB_GLOBAL}') AND END_TMS IS NULL)
      AND TO_CHAR(PRC_TMS,'YYYYMMDD') = '${PRC_TMS}'
      AND PRC_SRCE_TYP = 'ESALL'
      AND PRC_CURR_CDE = '${CRNCY}'
      AND PRC_QT_METH_TYP = 'PRCQUOTE'
      AND PRC_VALID_TYP = 'UNVERIFD'
      AND LAST_CHG_USR_ID = 'EIS_BBG_DMP_SECURITY'
      AND DATA_SRC_ID = 'BB'
      AND PRC_TYP = 'BID'
      AND PRCNG_METH_TYP = 'ESIPX'
      AND UNIT_CPRC = ${PX_BID}
      """

    Then I expect value of column "PX_ASK_COUNT" in the below SQL query equals to "1":
      """
      SELECT COUNT(*) AS PX_ASK_COUNT FROM FT_T_ISPC WHERE
      INSTR_ID IN (SELECT INSTR_ID FROM FT_T_ISID WHERE ISS_ID IN ('${ID_BB_GLOBAL}') AND END_TMS IS NULL)
      AND TO_CHAR(PRC_TMS,'YYYYMMDD') = '${PRC_TMS}'
      AND PRC_SRCE_TYP = 'ESALL'
      AND PRC_CURR_CDE = '${CRNCY}'
      AND PRC_QT_METH_TYP = 'PRCQUOTE'
      AND PRC_VALID_TYP = 'UNVERIFD'
      AND LAST_CHG_USR_ID = 'EIS_BBG_DMP_SECURITY'
      AND DATA_SRC_ID = 'BB'
      AND PRC_TYP = 'ASKED'
      AND PRCNG_METH_TYP = 'ESIPX'
      AND UNIT_CPRC = ${PX_ASK}
      """

    Then I expect value of column "PX_MID_COUNT" in the below SQL query equals to "1":
      """
      SELECT COUNT(*) AS PX_MID_COUNT FROM FT_T_ISPC WHERE
      INSTR_ID IN (SELECT INSTR_ID FROM FT_T_ISID WHERE ISS_ID IN ('${ID_BB_GLOBAL}') AND END_TMS IS NULL)
      AND TO_CHAR(PRC_TMS,'YYYYMMDD') = '${PRC_TMS}'
      AND PRC_SRCE_TYP = 'ESALL'
      AND PRC_CURR_CDE = '${CRNCY}'
      AND PRC_QT_METH_TYP = 'PRCQUOTE'
      AND PRC_VALID_TYP = 'UNVERIFD'
      AND LAST_CHG_USR_ID = 'EIS_BBG_DMP_SECURITY'
      AND DATA_SRC_ID = 'BB'
      AND PRC_TYP = 'MID'
      AND PRCNG_METH_TYP = 'ESIPX'
      AND UNIT_CPRC = ${PX_MID}
      """

    Then I expect value of column "PX_LAST_EOD_COUNT" in the below SQL query equals to "1":
      """
      SELECT COUNT(*) AS PX_LAST_EOD_COUNT FROM FT_T_ISPC WHERE
      INSTR_ID IN (SELECT INSTR_ID FROM FT_T_ISID WHERE ISS_ID IN ('${ID_BB_GLOBAL}') AND END_TMS IS NULL)
      AND TO_CHAR(PRC_TMS,'YYYYMMDD') = '${PRC_TMS}'
      AND PRC_SRCE_TYP = 'ESALL'
      AND PRC_CURR_CDE = '${CRNCY}'
      AND PRC_QT_METH_TYP = 'PRCQUOTE'
      AND PRC_VALID_TYP = 'UNVERIFD'
      AND LAST_CHG_USR_ID = 'EIS_BBG_DMP_SECURITY'
      AND DATA_SRC_ID = 'BB'
      AND PRC_TYP = 'PXLSTEOD'
      AND PRCNG_METH_TYP = 'ESIPX'
      AND UNIT_CPRC = ${PX_LAST_EOD}
      """

    Then I expect value of column "PX_CLOSE_1D_COUNT" in the below SQL query equals to "1":
      """
      SELECT COUNT(*) AS PX_CLOSE_1D_COUNT FROM FT_T_ISPC WHERE
      INSTR_ID IN (SELECT INSTR_ID FROM FT_T_ISID WHERE ISS_ID IN ('${ID_BB_GLOBAL}') AND END_TMS IS NULL)
      AND TO_CHAR(PRC_TMS,'YYYYMMDD') = '${PRC_TMS}'
      AND PRC_SRCE_TYP = 'ESALL'
      AND PRC_CURR_CDE = '${CRNCY}'
      AND PRC_QT_METH_TYP = 'PRCQUOTE'
      AND PRC_VALID_TYP = 'UNVERIFD'
      AND LAST_CHG_USR_ID = 'EIS_BBG_DMP_SECURITY'
      AND DATA_SRC_ID = 'BB'
      AND PRC_TYP = 'CL1D'
      AND PRCNG_METH_TYP = 'ESIPX'
      AND UNIT_CPRC = ${PX_CLOSE_1D}
      """

  Scenario: TC_6: Process Golden Price Calculation Workflow

    Given I process Goldenprice calculation with below parameters and wait for the job to be completed
      | PROCESSING_DATE                       | ${PRC_TMS}                                                                                              |
      | RUNPVCFORPRVI                         | false                                                                                                    |
      | RUN_UNLISTED_WARRANT_PRICE_DERIVATION | false                                                                                                   |
      | INSTRUMENTS                           | BBG000DKCC19,BBG000BDGHM9,BBG000PW2YN9,BBG00FY2JQC3,BBG0015VR9D0,BBG00K5WSWV4,BBG00J9YSGK6,BBG000BN2HR7 |


  Scenario: TC_7: Verify NEGATIVE Price Handling while Golden Price Calculation
  I expect System should throw a error message if it encounters negative price while calculating Golden price
  #4th row - BBG000BDGHM9 of VALID Price file is intentionally populated with Negative Price to validate this scenario.

    Given I extract below values for row 4 from BBGPSV file "${BB_PRICE_FEED}" in local folder "${testdata.path}/testdata" and assign to variables:
      | ID_BB_GLOBAL | ID_BB_GLOBAL |


    Then I expect value of column "GP_NEGTIVE_RECORD_COUNT" in the below SQL query equals to "1":
      """
      SELECT COUNT(*) AS GP_NEGTIVE_RECORD_COUNT FROM FT_T_ISPS ISPS
      JOIN FT_T_GPCS GPCS
      ON ISPS.ISS_PRC_ID = GPCS.ISS_PRC_ID
      JOIN FT_T_ISID ISID
      ON GPCS.INSTR_ID = ISID.INSTR_ID
      WHERE ISID.ISS_ID = '${ID_BB_GLOBAL}'
      AND TO_CHAR(ISPS.PRC_TMS,'YYYYMMDD') IN ('${PRC_TMS}')
      AND GPCS.PRC_VALID_LIST_TXT = 'CAL;ZCHK;GOLDENPRICE'
      AND ISPS.PRC_STAT_TYP = 'SUSPECT'
      AND GPCS.GPCS_TYP = 'SUSPECT'
      AND ISPS.PRC_STAT_CMNT_TXT = 'Error: Price failed validation as price is negative'
      AND ISPS.PRC_VALIDATION_TYP = 'ZCHK'
      """

  Scenario Outline: TC_8: Verify Golden Price Calculation in FT_T_GPCS with <GoldenPrice_Column> in Hierarchy

    Given I extract below values for row <RecordNum> from BBGPSV file "${BB_PRICE_FEED}" in local folder "${testdata.path}/testdata" and assign to variables:
      | <GoldenPrice_Column> | GOLDEN_PRICE |
      | ID_BB_GLOBAL         | ID_BB_GLOBAL |

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

    #BB_ID column is just for indication purpose not used in validations
    Examples:
      | RecordNum | GoldenPrice_Column | BB_ID        |
      | 1         | PX_LAST            | BBG000DKCC19 |
      | 2         | PX_CLOSE_1D        | BBG000PW2YN9 |
      | 3         | PX_BID             | BBG00FY2JQC3 |
      | 4         | PX_ASK             | BBG000BDGHM9 |
      | 5         | PX_BID             | BBG0015VR9D0 |
      | 6         | PX_ASK             | BBG00K5WSWV4 |
      | 7         | PX_LAST            | BBG00J9YSGK6 |
      | 8         | PRIOR_CLOSE_MID    | BBG000BN2HR7 |

  Scenario: TC_9: Verify GOLDENPRICE entry not there in ISPS table

    Given I extract below values for row 4 from BBGPSV file "${BB_PRICE_FEED}" in local folder "${testdata.path}/testdata" and assign to variables:
      | ID_BB_GLOBAL | ID_BB_GLOBAL |

    Then I expect value of column "GOLDENPRICE_RECORD_COUNT" in the below SQL query equals to "0":
      """
      SELECT COUNT(*) AS GOLDENPRICE_RECORD_COUNT FROM FT_T_ISPS ISPS
      JOIN FT_T_GPCS GPCS
      ON ISPS.ISS_PRC_ID = GPCS.ISS_PRC_ID
      JOIN FT_T_ISID ISID
      ON GPCS.INSTR_ID = ISID.INSTR_ID
      WHERE ISID.ISS_ID = '${ID_BB_GLOBAL}'
      AND ISPS.PRC_STAT_TYP = 'VALID'
      AND TRUNC(ISPS.LAST_CHG_TMS)=TRUNC(SYSDATE)
      AND ISPS.PRC_VALIDATION_TYP = 'GOLDENPRICE'
      """

  Scenario: TC_10: Clear Golden Price Calculation Records
  Deleting all records in FT_T_ISPS, FT_T_GPCS and FT_T_ISPC tables. Since we are running this test for 2 dates, i.e. T and T+1, it is required to clear data for both dates.

    Then I execute below query to "Clear Golden Price Calculation Records"
    """
    DELETE FT_T_ISGP WHERE LAST_CHG_USR_ID = 'AUTO'
    """
    Then I delete price records for all instruments defined in the BB price feed "${testdata.path}/testdata/${BB_PRICE_FEED}"