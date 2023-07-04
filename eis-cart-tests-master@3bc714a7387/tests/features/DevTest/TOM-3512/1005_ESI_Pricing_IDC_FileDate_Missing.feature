# =====================================================================
# Date            JIRA        Comments
# ============    ========    ========
# 15/08/2018      TOM-3555    First Version
# =====================================================================

# https://collaborate.intranet.asia/pages/viewpage.action?pageId=45845204
# https://jira.intranet.asia/browse/TOM-3482

@gc_interface_prices
@dmp_regression_unittest
@tom_3512 @1005_esi_pricing_filedate_missing
Feature: Inbound IDC Price to DMP Interface Testing (R4.VN IDC to DMP)

  Load IDC Price file with missing "FileDate" with 1 records (details below)
  Sedol	    ISIN	        Price Date	Bid
  B3W8JF0	VN0CP4A13040	20180724	103.39418

  Scenario: TC_1: Clear the data as a Prerequisite

    Given I assign "ESI_Pricing_IDC_005_FileDate_Missing.csv" to variable "INPUT_FILENAME"
    And I assign "tests/test-data/DevTest/TOM-3512" to variable "testdata.path"

    # Clear data for the given instruments from ISGP and ISPC tables
    Given I execute below query
    """
    ${testdata.path}/sql/ESI_Pricing_IDC_005_ClearData.sql
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

    # Validation: FileDate is missing in Filename -> B3W8JF0
    Then I expect value of column "EXCEPTION_MSG_CHECK" in the below SQL query equals to "1":
      """
        SELECT COUNT(*) AS EXCEPTION_MSG_CHECK
        FROM ft_t_ntel ntel
          JOIN ft_t_trid trid
            ON ntel.last_chg_trn_id = trid.trn_id
        WHERE trid.job_id = '${JOB_ID}'
        AND ntel.notfcn_id = 15
        AND ntel.notfcn_stat_typ = 'OPEN'
        AND ntel.msg_typ = 'EIS_MT_IDC_PRICE'
        AND ntel.char_val_txt LIKE '%Extended error message: Parsing of Date failed! Check Date and Format String%'
        """

