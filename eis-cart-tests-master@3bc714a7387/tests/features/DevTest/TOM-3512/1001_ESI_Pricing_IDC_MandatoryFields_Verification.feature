# =====================================================================
# Date            JIRA        Comments
# ============    ========    ========
# 03/08/2018      TOM-3512    First Version
# 14/08/2018      TOM-3555    Changes to BidPrice Rounding
# =====================================================================

#https://collaborate.intranet.asia/pages/viewpage.action?pageId=45845204
#https://jira.intranet.asia/browse/TOM-3482

@gc_interface_prices
@dmp_regression_unittest
@tom_3512 @1001_esi_pricing_idc_inbound_mandatory_fields_verification
Feature: Inbound IDC Price to DMP Interface Testing (R4.VN IDC to DMP)

  Load IDC Price file with 3 records (details below), all containing SEDOL, ISIN, TradeDate, BidPrice as mandatory fields and comments as optional field

  Sedol	    ISIN	        Price Date	Bid	        Comments
  6BQ56C4	VNBVBS164062	20180731	117.95505	All mandatory fields
  ------	VNTD16314633  	20180731	124.1587	Sedol Missing
  B3YH4S3	------------    20180731	106.95309	ISIN Missing

  Scenario: TC_1: Clear the data as a Prerequisite

    Given I assign "ESI_Pricing_IDC_001_MandatoryFields_Verification20180731.csv" to variable "INPUT_FILENAME"
    And I assign "tests/test-data/DevTest/TOM-3512" to variable "testdata.path"

    # Clear data for the given instruments from ISGP and ISPC tables
    Given I execute below query
    """
    ${testdata.path}/sql/ESI_Pricing_IDC_001_ClearData.sql
    """

  Scenario: TC_2: Load IDC Price File

    Given I copy files below from local folder "${testdata.path}/testdata" to the host "dmp.ssh.inbound" folder "${dmp.ssh.inbound.path}":
      | ${INPUT_FILENAME} |

    When I process files with below parameters and wait for the job to be completed
      | BUSINESS_FEED |                   |
      | FILE_PATTERN  | ${INPUT_FILENAME} |
      | MESSAGE_TYPE  | EIS_MT_IDC_PRICE  |

    Then I extract new job id from jblg table into a variable "JOB_ID"

  Scenario: TC_3: Data Verifications

    # Validation: 3 records should be created in ISGP
    Then I expect value of column "IDCPRCNGSOI_COUNT" in the below SQL query equals to "3":
        """
        SELECT count(*) AS IDCPRCNGSOI_COUNT FROM ft_t_isgp
        WHERE prnt_iss_grp_oid = 'IDCPRCGSOI'
        AND instr_id IN
        (
            SELECT instr_id
            FROM ft_t_isid
            WHERE id_ctxt_typ IN ('SEDOL','ISIN')
            AND end_tms IS NULL
            AND
            (
                (id_ctxt_typ = 'SEDOL' AND iss_id = '6BQ56C4') OR
                (id_ctxt_typ = 'SEDOL' AND iss_id = '6BQ8XQ6') OR
                (id_ctxt_typ = 'SEDOL' AND iss_id = 'B3YH4S3') OR
                (id_ctxt_typ = 'ISIN'  AND iss_id = 'VNBVBS164062') OR
                (id_ctxt_typ = 'ISIN'  AND iss_id = 'VNTD16314633')
            )
        )
        AND trunc(last_chg_tms) = trunc(sysdate)
        """

    # Validation: 3 BID records should be created in ISPC with correct mapping of SEDOL/ISIN with BID price
    Then I expect value of column "ISPC_BID_COUNT" in the below SQL query equals to "3":
        """
        SELECT COUNT(*) AS ISPC_BID_COUNT FROM ft_t_ispc ispc
           JOIN ft_t_isid isid
               ON ispc.instr_id = isid.instr_id
                   AND isid.id_ctxt_typ IN ('ISIN','SEDOL')
                   AND isid.end_tms IS NULL
                   AND ispc.prc_srce_typ = 'IDCVN'
                   AND ispc.prcng_meth_typ = 'ESILOCAL'
                   AND ispc.prc_typ = 'BID'
        WHERE
        (

           (((isid.iss_id = '6BQ56C4' AND isid.id_ctxt_typ = 'SEDOL') OR (isid.iss_id = 'VNBVBS164062' AND isid.id_ctxt_typ = 'ISIN')) AND ispc.unit_cprc = 117.95505 AND ispc.isid_oid IS NOT NULL AND ispc.mkt_oid IS NOT NULL) OR
           (((isid.iss_id = 'VNTD16314633' AND isid.id_ctxt_typ = 'ISIN')) AND ispc.unit_cprc = 124.1587 AND ispc.isid_oid IS NOT NULL AND ispc.mkt_oid IS NOT NULL) OR
           (((isid.iss_id = 'B3YH4S3' AND isid.id_ctxt_typ = 'SEDOL')) AND ispc.unit_cprc = 106.95309 AND ispc.isid_oid IS NOT NULL AND ispc.mkt_oid IS NOT NULL)
        )
        AND ispc.job_id = '${JOB_ID}'
        """
