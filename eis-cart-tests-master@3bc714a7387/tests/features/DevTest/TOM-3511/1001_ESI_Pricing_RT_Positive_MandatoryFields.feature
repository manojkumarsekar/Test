# =====================================================================
# Date            JIRA        Comments
# ============    ========    ========
# 03/08/2018      TOM-3511    First Version
# 13/08/2018      TOM-3521    Code beautification and formatting
# 14/08/2018      TOM-3555    Changes to BidPrice Rounding
# 11/03/2019      TOM-4341    Changed the Vendor Defintion id from "RT" to "REUTERS"
# =====================================================================

#https://jira.intranet.asia/browse/TOM-3481
#https://jira.intranet.asia/browse/TOM-3487
#https://collaborate.intranet.asia/pages/viewpage.action?pageId=45843320

@gc_interface_prices
@dmp_regression_unittest
@1001_esi_pricing_rt_inbound_positive_mandatory_fields @tom_4341 @tom_3511 @eisdev_7379
Feature: Reuters Price Inbound to DMP - Positive Test Case Scenarios

  Load Reuters Price file with 6 records (details below), all containing HeaderDate, ISIN, TradeDate and BidPrice as mandatory fields

  HeaderDate: 07/27/2018

  ISIN            Trade Date              Bid Price
  ====            ========                ========
  VNTB13281548    07/20/2018              122.027
  VNTD10200655    HeaderDate-StaleDays+1  115.191
  VNTD15302894    07/21/2018              121.605
  VNTD16214460    07/20/2018              131.681
  VNTD16314617    HeaderDate-StaleDays    116.181
  VNTD17474097    07/21/2018              120.871

  There are 5 Valid records within stale days which means that it will create 2 prices, BID price and Derive price.
  There is 1 Valid record which is greater the stale days which means it will only create 1 price, BID price.


  Scenario: TC_1: Clear the data as a Prerequisite

    Given I assign "ESI_Pricing_RT_001_Positive_MandatoryFields.csv" to variable "INPUT_FILENAME"
    And I assign "tests/test-data/DevTest/TOM-3511" to variable "testdata.path"

    # Clear data for the given instruments from ISGP and ISPC tables
    And I execute below query
    """
    ${testdata.path}/sql/ESI_Pricing_RT_001_ClearData.sql
    """

    And I execute below query and extract values of "DYNAMIC_DATE_BEFORE_STALE" into same variables
     """
     SELECT TO_CHAR(TO_DATE('07/27/2018','MM/DD/YYYY')-TO_NUMBER(intrnl_dmn_val_txt),'MM/dd/YYYY') as DYNAMIC_DATE_BEFORE_STALE FROM ft_t_idmv WHERE intrnl_dmn_val_nme = 'REUTERS_STALE_PRICE_DAYS' AND fld_id = '41000801'
     """
    And I modify date "${DYNAMIC_DATE_BEFORE_STALE}" with "-1d" from source format "MM/dd/YYYY" to destination format "MM/dd/YYYY" and assign to "DYNAMIC_DATE_STALE"
    And I assign "ESI_Pricing_RT_001_Positive_MandatoryFields_template.csv" to variable "INPUT_TEMPLATENAME"
    And I create input file "${INPUT_FILENAME}" using template "${INPUT_TEMPLATENAME}" from location "${testdata.path}"


  Scenario: TC_2: Load Reuters Price File and verify records in DMP

    Given I copy files below from local folder "${testdata.path}/testdata" to the host "dmp.ssh.inbound" folder "${dmp.ssh.inbound.path}":
      | ${INPUT_FILENAME} |

    When I process files with below parameters and wait for the job to be completed
      | BUSINESS_FEED |                      |
      | FILE_PATTERN  | ${INPUT_FILENAME}    |
      | MESSAGE_TYPE  | EIS_MT_REUTERS_PRICE |

    Then I extract new job id from jblg table into a variable "JOB_ID"

    # Validation: 6 records should be created in ISGP
    Then I expect value of column "RTPRCNGSOI_COUNT" in the below SQL query equals to "6":
        """
        SELECT count(*) AS RTPRCNGSOI_COUNT FROM ft_t_isgp
        WHERE prnt_iss_grp_oid = 'RTPRCNGSOI'
        AND instr_id IN
        (
            SELECT instr_id
            FROM ft_t_isid
            WHERE id_ctxt_typ = 'ISIN'
            AND end_tms IS NULL
            AND iss_id IN
            (
                'VNTB13281548',
                'VNTD10200655',
                'VNTD15302894',
                'VNTD16214460',
                'VNTD16314617',
                'VNTD17474097'
            )
        )
        AND trunc(last_chg_tms) = trunc(sysdate)
        """

    # Validation: 6 BID records should be created in ISPC with correct mapping of ISIN with BID price
    Then I expect value of column "ISPC_ISIN_BID_COUNT" in the below SQL query equals to "6":
        """
        SELECT COUNT(*) AS ISPC_ISIN_BID_COUNT FROM ft_t_ispc ispc
            JOIN ft_t_isid isid
                ON ispc.instr_id = isid.instr_id
                    AND isid.id_ctxt_typ = 'ISIN'
                    AND isid.end_tms IS NULL
                    AND ispc.prc_srce_typ = 'RTVNQ'
                    AND ispc.prcng_meth_typ = 'REUVN'
                    AND ispc.prc_typ = 'BID'
        WHERE
        (
            (isid.iss_id = 'VNTB13281548' AND ispc.unit_cprc = 122.027 AND ispc.isid_oid IS NOT NULL AND ispc.mkt_oid IS NOT NULL) OR
            (isid.iss_id = 'VNTD10200655' AND ispc.unit_cprc = 115.191 AND ispc.isid_oid IS NOT NULL AND ispc.mkt_oid IS NOT NULL) OR
            (isid.iss_id = 'VNTD15302894' AND ispc.unit_cprc = 121.605 AND ispc.isid_oid IS NOT NULL AND ispc.mkt_oid IS NOT NULL) OR
            (isid.iss_id = 'VNTD16214460' AND ispc.unit_cprc = 131.681 AND ispc.isid_oid IS NOT NULL AND ispc.mkt_oid IS NOT NULL) OR
            (isid.iss_id = 'VNTD16314617' AND ispc.unit_cprc = 116.181 AND ispc.isid_oid IS NOT NULL AND ispc.mkt_oid IS NOT NULL) OR
            (isid.iss_id = 'VNTD17474097' AND ispc.unit_cprc = 120.871 AND ispc.isid_oid IS NOT NULL AND ispc.mkt_oid IS NOT NULL)
        )
        AND ispc.job_id = '${JOB_ID}'
        """

    # Validation: 4 DERIVE records should be created in ISPC with correct mapping of ISIN with DERIVE price as HeaderDate - TradeDate is less than or equal to 13 days.
    Then I expect value of column "ISPC_ISIN_DERIVE_COUNT" in the below SQL query equals to "5":
        """
        SELECT COUNT(*) AS ISPC_ISIN_DERIVE_COUNT FROM ft_t_ispc ispc
            JOIN ft_t_isid isid
                ON ispc.instr_id = isid.instr_id
                    AND isid.id_ctxt_typ = 'ISIN'
                    AND isid.end_tms IS NULL
                    AND ispc.prc_srce_typ = 'ESIVN'
                    AND ispc.prcng_meth_typ = 'ESIVNM'
                    AND ispc.prc_typ = 'DERIVE'
        WHERE
        (
            (isid.iss_id = 'VNTB13281548' AND ispc.unit_cprc = 122.027 AND ispc.isid_oid IS NOT NULL AND ispc.mkt_oid IS NOT NULL) OR
            (isid.iss_id = 'VNTD10200655' AND ispc.unit_cprc = 115.191 AND ispc.isid_oid IS NOT NULL AND ispc.mkt_oid IS NOT NULL) OR
            (isid.iss_id = 'VNTD15302894' AND ispc.unit_cprc = 121.605 AND ispc.isid_oid IS NOT NULL AND ispc.mkt_oid IS NOT NULL) OR
            (isid.iss_id = 'VNTD16214460' AND ispc.unit_cprc = 131.681 AND ispc.isid_oid IS NOT NULL AND ispc.mkt_oid IS NOT NULL) OR
            (isid.iss_id = 'VNTD16314617' AND ispc.unit_cprc = 116.181 AND ispc.isid_oid IS NOT NULL AND ispc.mkt_oid IS NOT NULL) OR
            (isid.iss_id = 'VNTD17474097' AND ispc.unit_cprc = 120.871 AND ispc.isid_oid IS NOT NULL AND ispc.mkt_oid IS NOT NULL)
        )
        AND ispc.job_id = '${JOB_ID}'
        """

    # Validation: 2 DERIVE records should NOT be created in ISPC as HeaderDate - TradeDate is greater than 1 days.
    Then I expect value of column "ISPC_ISIN_DERIVE_COUNT" in the below SQL query equals to "0":
        """
        SELECT COUNT(*) AS ISPC_ISIN_DERIVE_COUNT FROM ft_t_ispc ispc
            JOIN ft_t_isid isid
                ON ispc.instr_id = isid.instr_id
                    AND isid.id_ctxt_typ = 'ISIN'
                    AND isid.end_tms IS NULL
                    AND ispc.prc_srce_typ = 'ESIVN'
                    AND ispc.prcng_meth_typ = 'ESIVNM'
                    AND ispc.prc_typ = 'DERIVE'
        WHERE isid.iss_id IN
        (
            'VNTD16314617'
        )
        AND ispc.job_id = '${JOB_ID}'
        """