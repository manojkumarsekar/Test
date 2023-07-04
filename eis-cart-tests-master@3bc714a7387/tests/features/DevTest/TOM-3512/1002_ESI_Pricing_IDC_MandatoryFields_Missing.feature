# =====================================================================
# Date            JIRA        Comments
# ============    ========    ========
# 03/08/2018      TOM-3512    First Version
# 13/08/2018      TOM-3555    Code beautification and formatting
# =====================================================================

#https://collaborate.intranet.asia/pages/viewpage.action?pageId=45845204
#https://jira.intranet.asia/browse/TOM-3482

@gc_interface_prices
@dmp_regression_unittest
@tom_3512 @1002_esi_pricing_idc_mandatoryfields_missing
Feature: Inbound IDC Price to DMP Interface Testing (R4.VN IDC to DMP)

  Load IDC Price file with 5 records (details below)

  Sedol	    ISIN	        Price Date	Bid	        Comments
  X123456	Y12345678910    20180731    103.19542   SEDOL/ISIN - No lookup
  B7NFFS3	VNTD17324045    20180731    115.19989   SEDOL ISIN Split
  -------   ------------    20180731    104.81118   Missing identifiers in file
  BF50Q89   VNBVBS170630    --------    104.22805   Price Date missing
  BF50DY4	VNBVBS170952    20180731    ---------   Bid Price Missing

  Scenario: TC_1: Clear the data as a Prerequisite

    Given I assign "ESI_Pricing_IDC_002_MandatoryFields_Missing20180731.csv" to variable "INPUT_FILENAME"
    And I assign "tests/test-data/DevTest/TOM-3512" to variable "testdata.path"

    # Clear data for the given instruments from ISGP and ISPC tables
    Given I execute below query
    """
    ${testdata.path}/sql/ESI_Pricing_IDC_002_ClearData.sql
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
     # Validation: JBLG NTEL error logged for SEDOL/ISIN not present in DB -> X123456
    Then I expect value of column "EXCEPTION_MSG_CHECK" in the below SQL query equals to "1":
       """
        SELECT COUNT(*) AS EXCEPTION_MSG_CHECK
        FROM ft_t_ntel ntel
          JOIN ft_t_trid trid
            ON ntel.last_chg_trn_id = trid.trn_id
        WHERE trid.job_id = '${JOB_ID}'
        AND ntel.notfcn_stat_typ = 'OPEN'
        AND ntel.notfcn_id = '153'
        AND ntel.msg_typ = 'EIS_MT_IDC_PRICE'
        and ntel.main_entity_id = 'X123456'
        AND ntel.parm_val_txt LIKE '%No lookup %dentifier available%'
      """

     # Validation: JBLG NTEL error logged for SEDOL/ISIN split -> B7NFFS3
    Then I expect value of column "EXCEPTION_MSG_CHECK" in the below SQL query equals to "1":
      """
        SELECT COUNT(*) AS EXCEPTION_MSG_CHECK
        FROM ft_t_ntel ntel
          JOIN ft_t_trid trid
            ON ntel.last_chg_trn_id = trid.trn_id
        WHERE trid.job_id = '${JOB_ID}'
        AND ntel.notfcn_stat_typ = 'OPEN'
        AND ntel.notfcn_id = '153'
        AND ntel.msg_typ = 'EIS_MT_IDC_PRICE'
        and ntel.main_entity_id = 'B7NFFS3'
        AND ntel.char_val_txt LIKE '%Different Issues are associated with ID%'
        """

     # Validation: JBLG NTEL error logged for missing identifiers for SEDOL/ISIN -> null
    Then I expect value of column "EXCEPTION_MSG_CHECK" in the below SQL query equals to "1":
       """
        SELECT COUNT(*) AS EXCEPTION_MSG_CHECK
        FROM ft_t_ntel ntel
          JOIN ft_t_trid trid
          ON ntel.last_chg_trn_id = trid.trn_id
        WHERE trid.job_id = '${JOB_ID}'
        AND ntel.notfcn_stat_typ = 'OPEN'
        AND ntel.notfcn_id = '60001'
        AND ntel.msg_typ = 'EIS_MT_IDC_PRICE'
        and ntel.main_entity_id IS NULL
        AND ntel.parm_val_txt LIKE '%Cannot process IDC Price record as Sedol and ISIN are missing%'
       """

     # Validation: JBLG NTEL error logged for missing Price Date for SEDOL -> BF50Q89
    Then I expect value of column "EXCEPTION_MSG_CHECK" in the below SQL query equals to "1":
        """
          SELECT COUNT(*) AS EXCEPTION_MSG_CHECK
          FROM ft_t_ntel ntel
            JOIN ft_t_trid trid
              ON ntel.last_chg_trn_id = trid.trn_id
          WHERE trid.job_id = '${JOB_ID}'
          AND ntel.notfcn_stat_typ = 'OPEN'
          AND ntel.notfcn_id = '60001'
          AND ntel.source_id = 'TRANSLATION'
          AND ntel.msg_typ = 'EIS_MT_IDC_PRICE'
          and ntel.main_entity_id = 'BF50Q89'
          AND ntel.parm_val_txt LIKE '%Cannot process IDC Price record as%is missing%'
        """

     # Validation: JBLG NTEL error logged for missing Bid Price-> BF50DY4
    Then I expect value of column "EXCEPTION_MSG_CHECK" in the below SQL query equals to "1":
        """
          SELECT COUNT(*) AS EXCEPTION_MSG_CHECK
          FROM ft_t_ntel ntel
            JOIN ft_t_trid trid
              ON ntel.last_chg_trn_id = trid.trn_id
          WHERE trid.job_id = '${JOB_ID}'
          AND ntel.notfcn_stat_typ = 'OPEN'
          AND ntel.notfcn_id = '60001'
          AND ntel.source_id = 'TRANSLATION'
          AND ntel.msg_typ = 'EIS_MT_IDC_PRICE'
          and ntel.main_entity_id = 'BF50DY4'
          AND ntel.parm_val_txt LIKE '%Cannot process IDC Price record as%is missing%'
        """