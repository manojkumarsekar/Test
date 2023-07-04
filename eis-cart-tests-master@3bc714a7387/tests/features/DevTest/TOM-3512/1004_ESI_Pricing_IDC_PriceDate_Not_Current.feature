# =====================================================================
# Date            JIRA        Comments
# ============    ========    ========
# 14/08/2018      TOM-3555    First Version
# =====================================================================

# https://collaborate.intranet.asia/pages/viewpage.action?pageId=45845204
# https://jira.intranet.asia/browse/TOM-3482

@gc_interface_prices
@dmp_regression_unittest
@tom_3512 @1004_esi_pricing_pricedate_not_current
Feature: Inbound IDC Price to DMP Interface Testing (R4.VN IDC to DMP)

  Load IDC Price file with 4 records (details below)

  Sedol   ISIN          Price Date  Bid       Comments
  6BT4W86 VNTD17324037  20180730    115.21194 PriceDate less than FileDate
  6BT6C15 VNTD17324045  20180801    115.19989 PriceDate greater than FileDate
  20180726    110.14018 Sedol and ISIN missing for older PriceDate
  6BTQ657 VNTD17474105  20180726              Bid missing for older PriceDate

  Scenario: TC_1: Clear the data as a Prerequisite

    Given I assign "ESI_Pricing_IDC_004_PriceDate_Not_Current20180731.csv" to variable "INPUT_FILENAME"
    And I assign "tests/test-data/DevTest/TOM-3512" to variable "testdata.path"

    # Clear data for the given instruments from ISGP and ISPC tables
    Given I execute below query
    """
    ${testdata.path}/sql/ESI_Pricing_IDC_004_ClearData.sql
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

    # Validation: No errors logged (record silently skipped) when PriceDate is less than FileDate -> 6BT4W86
    Then I expect value of column "EXCEPTION_MSG_CHECK" in the below SQL query equals to "0":
      """
        SELECT COUNT(*) AS EXCEPTION_MSG_CHECK
        FROM ft_t_ntel ntel
          JOIN ft_t_trid trid
            ON ntel.last_chg_trn_id = trid.trn_id
        WHERE trid.job_id = '${JOB_ID}'
        AND ntel.notfcn_stat_typ = 'OPEN'
        AND ntel.msg_typ = 'EIS_MT_IDC_PRICE'
        and ntel.main_entity_id = '6BT4W86'
        """

     # Validation: JBLG NTEL error logged when PriceDate greater then FileDate-> 6BT6C15
    Then I expect value of column "EXCEPTION_MSG_CHECK" in the below SQL query equals to "1":
       """
        SELECT COUNT(*) AS EXCEPTION_MSG_CHECK
        FROM ft_t_ntel ntel
          JOIN ft_t_trid trid
            ON ntel.last_chg_trn_id = trid.trn_id
        WHERE trid.job_id = '${JOB_ID}'
        AND ntel.notfcn_stat_typ = 'OPEN'
        AND ntel.notfcn_id = '60003'
        AND ntel.msg_typ = 'EIS_MT_IDC_PRICE'
        and ntel.main_entity_id = '6BT6C15'
        AND ntel.char_val_txt LIKE '%PriceDate cannot be greater than FileDate%'
      """

    # Validation: No errors logged (record silently skipped) when ISIN/Sedol is missing, if PriceDate is less than FileDate
    Then I expect value of column "EXCEPTION_MSG_CHECK" in the below SQL query equals to "0":
       """
        SELECT COUNT(*) AS EXCEPTION_MSG_CHECK
        FROM ft_t_ntel ntel
          JOIN ft_t_trid trid
            ON ntel.last_chg_trn_id = trid.trn_id
        WHERE trid.job_id = '${JOB_ID}'
        AND ntel.notfcn_stat_typ = 'OPEN'
        AND ntel.msg_typ = 'EIS_MT_IDC_PRICE'
        AND ntel.parm_val_txt LIKE '%Cannot process IDC Price record as Sedol and ISIN are missing%'
      """

     # Validation: No errors logged (record silently skipped) when Bid is missing, if PriceDate is less than FileDate-> 6BTQ657
    Then I expect value of column "EXCEPTION_MSG_CHECK" in the below SQL query equals to "0":
       """
        SELECT COUNT(*) AS EXCEPTION_MSG_CHECK
        FROM ft_t_ntel ntel
          JOIN ft_t_trid trid
            ON ntel.last_chg_trn_id = trid.trn_id
        WHERE trid.job_id = '${JOB_ID}'
        AND ntel.notfcn_stat_typ = 'OPEN'
        AND ntel.msg_typ = 'EIS_MT_IDC_PRICE'
        and ntel.main_entity_id = '6BTQ657'
      """
