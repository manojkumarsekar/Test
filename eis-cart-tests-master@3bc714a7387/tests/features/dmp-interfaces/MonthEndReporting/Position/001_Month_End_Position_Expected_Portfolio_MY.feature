# Dev Ticket -  https://jira.intranet.asia/browse/TOM-5073
# QA Ticket  -  https://jira.intranet.asia/browse/TOM-5214#
# confluence page - https://collaborate.intranet.asia/display/TOM/Splitting+of+Month-end+reports+from+DMP
# About - This feature file is to test that the Month End Position file contains certain portfolios only.
# TOM-5214 - Created the feature file to verify the month end position file for MY is generating as expected.
# EISDEV-5358 - Modified the feature file . The feature file developed as part of TOM-5214 verify all the fields of output file in which some of the fields are meant to change.
#               The input file is of Aug Data. The publishing profile takes the latest data for some of the fields.
# EISDEV-5447 - Previously the input file were having AUG data . The feature file has been modified to change the date in the input file to previous month with respect to current date.
# EISDEV-5565 - Modified the input file . The input data will be 2 months before. The validation will be also for data 2 months before.
# EISDEV-7227 : added portfolio, security and exchange rate load. Added steps to refresh Mviews

@dw_interface_positions @dw_interface_reports @ignore @to_be_fixed_eisdev_7592
@dmp_dw_regression
@eisdev_5447 @eisdev_5358 @eisdev_5565
@eisdev_7225 @eisdev_7384

Feature: Verify month end Position file for MY contains portfolios.

  As part of Dev Ticket TOM-5073 (EISDEV-5073) , the Month End Position file for MY should contain data of group "ES-AWMY - EASTSPRING AL-WARA' INVESTMENTS BERHAD".
  The group "ES-AWMY - EASTSPRING AL-WARA' INVESTMENTS BERHAD" contains currently only one portfolio "AYAWAN"
  This feature is designed to check whether the Month End Position file contains only "AYAWAN"

  Background:

    Given I set the DMP workflow web service endpoint to named configuration "dwh.ws.WORKFLOW"
    And I set the database connection to configuration "dmp.db.DW"
    And I assign "300" to variable "workflow.max.polling.time"

  Scenario: Assign Variables

    Given I generate value with date format "YYYYMMdd" and assign to variable "VAR_SYSDATE"
    And I assign "tests/test-data/dmp-interfaces/MonthEndReporting/Position" to variable "TESTDATA_PATH"

  Scenario: Create Positions file from Template based on VALN_DATE, RUN_DATE, START_DATE and LAST_DATE

    Given I assign "001_ESIPME_PFL_MY.out" to variable "PFL_INPUT_FILENAME"
    And I assign "001_ESIPME_PFL_MY_Template.out" to variable "PFL_INPUT_TEMPLATENAME"

    And I assign "001_ESIPME_SEC_MY_Template.out" to variable "SEC_INPUT_TEMPLATENAME"

    And I assign "001_ESIPME_EXR_MY_Template.out" to variable "EXR_INPUT_TEMPLATENAME"

    And I assign "001_ESIPME_POS_MY_Template.out" to variable "POS_INPUT_TEMPLATENAME"

    And I modify date "${VAR_SYSDATE}" with "-3m" from source format "YYYYMMdd" to destination format "yyyy-MMM-dd" and assign to "VALN_DATE"
    And I modify date "${VAR_SYSDATE}" with "-2m" from source format "YYYYMMdd" to destination format "yyyy-MMM-dd" and assign to "RUN_DATE"

    And I execute below query and extract values of "LAST_DATE;START_DATE;BNP_EXR_DATE;ME_DATE" into same variables
    """
    select TO_CHAR(LAST_DAY(ADD_MONTHS(SYSDATE,-2)),'YYYY-MON-DD') AS LAST_DATE, CONCAT(TO_CHAR(LAST_DAY(ADD_MONTHS(SYSDATE,-2)),'YYYY-MON'),'-01') AS START_DATE, TO_CHAR(LAST_DAY(ADD_MONTHS(SYSDATE,-2)),'YYYY-MON-DD') AS BNP_EXR_DATE,TO_CHAR(LAST_DAY(ADD_MONTHS(SYSDATE,-2)),'YYYYMMDD') AS ME_DATE from dual
    """

    And I assign "ESIPME_SEC_${ME_DATE}.out" to variable "SEC_INPUT_FILENAME"
    And I assign "ESIPME_PFL_${ME_DATE}.out" to variable "PFL_INPUT_FILENAME"
    And I assign "ESIPME_POS_${ME_DATE}.out" to variable "POS_INPUT_FILENAME"
    And I assign "ESISODP_EXR_1_${ME_DATE}.out" to variable "EXR_INPUT_FILENAME"

    And I create input file "${POS_INPUT_FILENAME}" using template "${POS_INPUT_TEMPLATENAME}" from location "${TESTDATA_PATH}"
    And I create input file "${SEC_INPUT_FILENAME}" using template "${SEC_INPUT_TEMPLATENAME}" from location "${TESTDATA_PATH}"
    And I create input file "${PFL_INPUT_FILENAME}" using template "${PFL_INPUT_TEMPLATENAME}" from location "${TESTDATA_PATH}"
    And I create input file "${EXR_INPUT_FILENAME}" using template "${EXR_INPUT_TEMPLATENAME}" from location "${TESTDATA_PATH}"

  Scenario: Load Portfolio file

    When I process "${TESTDATA_PATH}/testdata/${PFL_INPUT_FILENAME}" file with below parameters
      | BUSINESS_FEED |                       |
      | FILE_PATTERN  | ${PFL_INPUT_FILENAME} |
      | MESSAGE_TYPE  | EIS_MT_BNP_MOPK_PFL   |

  Scenario: Load Security file

    When I process "${TESTDATA_PATH}/testdata/${SEC_INPUT_FILENAME}" file with below parameters
      | BUSINESS_FEED |                       |
      | FILE_PATTERN  | ${SEC_INPUT_FILENAME} |
      | MESSAGE_TYPE  | EIS_MT_BNP_MOPK_SEC   |

  Scenario: Load Exchange rate file

    When I process "${TESTDATA_PATH}/testdata/${EXR_INPUT_FILENAME}" file with below parameters
      | BUSINESS_FEED |                        |
      | FILE_PATTERN  | ${EXR_INPUT_FILENAME}  |
      | MESSAGE_TYPE  | EIS_MT_BNP_MOPK_SOD_FX |

  Scenario: Load Positions with 2 NON MY records and 1 MY record

    When I process "${TESTDATA_PATH}/testdata/${POS_INPUT_FILENAME}" file with below parameters
      | BUSINESS_FEED |                       |
      | FILE_PATTERN  | ${POS_INPUT_FILENAME} |
      | MESSAGE_TYPE  | EIS_MT_BNP_MOPK_POS   |

  Scenario: Refresh cross rates data and exchange rate materialised view

    Given I assign "tests/test-data/intf-specs/gswf/template/EIS_CallStoredProcedureDW/request.xmlt" to variable "STORED_PROCEDURE"

    And I process the workflow template file "${STORED_PROCEDURE}" with below parameters and wait for the job to be completed
      | SQL_PROC_NAME | esi_create_wfxr_cross_rates |

    And I process the workflow template file "${STORED_PROCEDURE}" with below parameters and wait for the job to be completed
      | SQL_PROC_NAME | esi_refresh_daily_month_rates |

  Scenario: Verify Publishing Query retrieves only MY records (Groups) from ft_v_rpt1_meds_positions (Publishing Table)

  This query is triggered by Control-M internally, so instead of running publishing profile job
  we are testing whether MY records are loaded or not by executing the query.

    Then I expect value of column "PORTFOLIO" in the below SQL query equals to "AYAWAN":
    """
    SELECT distinct SUBSTR(flow_data,29,6) AS PORTFOLIO
    FROM ft_v_rpt1_meds_positions
    where posn_sok  in
    (SELECT DISTINCT posn_sok FROM ft_v_rpt1_meds_positions
    WHERE me_date = TO_DATE((select TO_CHAR(LAST_DAY(ADD_MONTHS(SYSDATE,-2)),'YYYYMMDD') from dual),'YYYYMMDD') and grp_nme ='MY')
    """








