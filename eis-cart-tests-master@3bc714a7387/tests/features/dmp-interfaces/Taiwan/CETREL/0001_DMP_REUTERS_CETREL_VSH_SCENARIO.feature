#https://jira.intranet.asia/browse/TOM-5097 (To Test VSH configuration for CETREL)

# Loading file file of Higher rank so that it updates the record in DB

@gc_interface_reuters @gc_interface_securities
@dmp_regression_integrationtest
@dmp_taiwan
@tom_5097 @eisdev_7552
Feature: Loading Reuters and CETREL file to to test VSH configuration

  First we load Reuters data which is lower rank vendor for ft_t_rgch.fund_euro_ucits_ind field
  then we load cetrel data so it should update the data for given as cetrel is higher ranking vendor

  Scenario:  Assign Variables and load file for Reuters to setup lower rank data_src_id in FT_T_RGCH table

    Given I assign "Reuters.csv" to variable "INPUT_FILENAME_1"
    And I assign "CETREL_Y.PAMPROD" to variable "INPUT_FILENAME_2"
    And I assign "tests/test-data/dmp-interfaces/Taiwan/CETREL" to variable "testdata.path"

    And I execute below query
    """
    ${testdata.path}/sql/ClearData_CETREL.sql
    """

    When I copy files below from local folder "${testdata.path}/testdata" to the host "dmp.ssh.inbound" folder "${dmp.ssh.inbound.path}":
      | ${INPUT_FILENAME_1} |
      | ${INPUT_FILENAME_2} |

    Given I process files with below parameters and wait for the job to be completed
      | BUSINESS_FEED |                               |
      | FILE_PATTERN  | ${INPUT_FILENAME_1}           |
      | MESSAGE_TYPE  | ReutersDSS_TermsandConditions |

    Then I expect value of column "ID_COUNT_RGCH_REUTERS" in the below SQL query equals to "1":
      """
     SELECT COUNT(*) AS ID_COUNT_RGCH_REUTERS
     FROM FT_T_RGCH
     WHERE INSTR_ID IN (SELECT INSTR_ID FROM FT_T_ISID WHERE ISS_ID = 'JP3274150006' AND ID_CTXT_TYP = 'ISIN' AND END_TMS IS NULL)
     AND GU_ID = 'EU'
     AND GU_TYP = 'REGION'
     AND GU_CNT = '1'
     AND DATA_SRC_ID = 'REUTERS'
     and fund_euro_ucits_ind is null
      """

  Scenario: Load file for CETREL to update higher rank data_src_id in FT_T_RGCH table

    Given I process files with below parameters and wait for the job to be completed
      | BUSINESS_FEED |                        |
      | FILE_PATTERN  | ${INPUT_FILENAME_2}    |
      | MESSAGE_TYPE  | EIS_MT_CETREL_SECURITY |

    Then I expect value of column "ID_COUNT_RGCH_CETERL" in the below SQL query equals to "1":
      """
     SELECT COUNT(*) AS ID_COUNT_RGCH_CETERL
     FROM FT_T_RGCH
     WHERE INSTR_ID IN (SELECT INSTR_ID FROM FT_T_ISID WHERE ISS_ID = 'JP3274150006' AND ID_CTXT_TYP = 'ISIN' AND END_TMS IS NULL)
     AND GU_ID = 'EU'
     AND GU_TYP = 'REGION'
     AND GU_CNT = '1'
     AND DATA_SRC_ID = 'REUTERS'
     AND FUND_EURO_UCITS_IND = 'Y'
      """

  Scenario:  Load file for Reuter to check it should not update data with higher rank vendor.

    Given I process files with below parameters and wait for the job to be completed
      | BUSINESS_FEED |                               |
      | FILE_PATTERN  | ${INPUT_FILENAME_1}           |
      | MESSAGE_TYPE  | ReutersDSS_TermsandConditions |

    Then I expect value of column "ID_COUNT_RGCH_REUTERS" in the below SQL query equals to "1":
      """
     SELECT COUNT(*) AS ID_COUNT_RGCH_REUTERS
     FROM FT_T_RGCH
     WHERE INSTR_ID IN (SELECT INSTR_ID FROM FT_T_ISID WHERE ISS_ID = 'JP3274150006' AND ID_CTXT_TYP = 'ISIN' AND END_TMS IS NULL)
     AND GU_ID = 'EU'
     AND GU_TYP = 'REGION'
     AND GU_CNT = '1'
     AND DATA_SRC_ID = 'REUTERS'
     AND FUND_EURO_UCITS_IND = 'Y'
      """
