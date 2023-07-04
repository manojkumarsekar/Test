# =====================================================================
# Date            JIRA        Comments
# ============    ========    ========
# 03/08/2018      TOM-3511    First Version
# 13/08/2018      TOM-3555    Code beautification and formatting
# 11/03/2019      TOM-4341    Changed the Vendor Defintion id from "RT" to "REUTERS"
# =====================================================================

#https://jira.intranet.asia/browse/TOM-3481
#https://jira.intranet.asia/browse/TOM-3487
#https://collaborate.intranet.asia/pages/viewpage.action?pageId=45843320

@gc_interface_prices
@dmp_regression_unittest
@tom_3511 @1005_esi_pricing_rt_inbound_negative_tradedate_greater_than_headerdate @tom_4341 @eisdev_7379
Feature: Reuters Price Inbound to DMP - Negative Test Case Scenario: TradeDate Greater Than HeaderDate

  Load Reuters Price file with 1 records (details below)
  1 record where TradeDate > HeaderDate

  HeaderDate: 07/27/2018

  ISIN            Trade Date     Bid Price
  ====            ========       ========
  VNBVDB173193     7/29/2018     110.751            (TradeDate > HeaderDate)

  There is one invalid record where TradeDate > HeaderDate


  Scenario: TC_1: Clear the data as a Prerequisite

    Given I assign "ESI_Pricing_RT_005_Negative_TradeDateGreaterThanHeaderDate.csv" to variable "INPUT_FILENAME1"
    And I assign "tests/test-data/DevTest/TOM-3511" to variable "testdata.path"

    # Clear data for the given instruments from ISGP and ISPC tables
    Given I execute below query
    """
    ${testdata.path}/sql/ESI_Pricing_RT_005_ClearData.sql
    """

  Scenario: TC_2: Load Reuters Price File and verify data in DMP

    Given I copy files below from local folder "${testdata.path}/testdata" to the host "dmp.ssh.inbound" folder "${dmp.ssh.inbound.path}":
      | ${INPUT_FILENAME1} |

    When I process files with below parameters and wait for the job to be completed
      | BUSINESS_FEED |                      |
      | FILE_PATTERN  | ${INPUT_FILENAME1}   |
      | MESSAGE_TYPE  | EIS_MT_REUTERS_PRICE |

    Then I extract new job id from jblg table into a variable "JOB_ID"

    # Validation: JBLG NTEL error logged for missing ISIN, TradeDate, BidPrice
    Then I expect value of column "EXCEPTION_MSG1_CHECK" in the below SQL query equals to "1":
    """
    SELECT COUNT(*) AS EXCEPTION_MSG1_CHECK
    FROM ft_t_ntel ntel
        JOIN ft_t_trid trid
        ON ntel.last_chg_trn_id = trid.trn_id
    WHERE trid.job_id = '${JOB_ID}'
    AND ntel.notfcn_stat_typ = 'OPEN'
    AND ntel.notfcn_id = '60003'
    AND ntel.source_id = 'TRANSLATION'
    AND ntel.msg_typ = 'EIS_MT_REUTERS_PRICE'
    AND ntel.parm_val_txt LIKE '%TradeDate should be less than or equal to HeaderDate%'
    """

    # Validation: 0 records should be created in ISGP
    Then I expect value of column "RTPRCNGSOI_COUNT" in the below SQL query equals to "0":
        """
        SELECT count(*) AS RTPRCNGSOI_COUNT FROM ft_t_isgp
        WHERE prnt_iss_grp_oid = 'RTPRCNGSOI'
        AND instr_id IN
        (
            SELECT instr_id
            FROM ft_t_isid
            WHERE id_ctxt_typ = 'ISIN'
            AND end_tms IS NULL
            AND iss_id = 'VNBVDB173193'
        )
        AND trunc(last_chg_tms) = trunc(sysdate)
        """

    # Validation: 0 BID records should be created in ISPC with correct mapping of ISIN with BID price
    Then I expect value of column "ISPC_ISIN_BID_COUNT" in the below SQL query equals to "0":
        """
        SELECT COUNT(*) AS ISPC_ISIN_BID_COUNT FROM ft_t_ispc ispc
            JOIN ft_t_isid isid
                ON ispc.instr_id = isid.instr_id
                    AND isid.id_ctxt_typ = 'ISIN'
                    AND isid.end_tms IS NULL
                    AND ispc.prc_srce_typ = 'RTVNQ'
                    AND ispc.prcng_meth_typ = 'REUVN'
                    AND ispc.prc_typ = 'BID'
        WHERE isid.iss_id = 'VNBVDB173193'
        AND trunc(ispc.last_chg_tms) = trunc(sysdate)
        """

    # Validation: 0 DERIVE records should be created in ISPC
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
        WHERE isid.iss_id = 'VNBVDB173193'
        AND trunc(ispc.last_chg_tms) = trunc(sysdate)
        """
