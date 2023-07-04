# Dev Ticket -  https://jira.intranet.asia/browse/TOM-5073
# QA Ticket  -  https://jira.intranet.asia/browse/TOM-5214
# confluence page - https://collaborate.intranet.asia/display/TOM/Splitting+of+Month-end+reports+from+DMP
# About - This feature file to test that the Month End Transaction file contains certain portfolios only.
# TOM-5214 - Created the feature file to verify the month end transaction file for MY is generating as expected.
# EISDEV-5358 - Modified the feature file . The feature file developed as part of TOM-5214 verify all the fields of output file in which some of the fields are meant to change.
#               The input file is of Aug Data. The publishing profile takes the latest data for some of the fields.
# EISDEV-5447 - Previously the input file were having AUG data . The feature file has been modified to change the date in the input file to previous month with respect to current date.
# EISDEV-5565 - Modified the input file . The input data will be 2 months before. The validation will be also for data 2 months before.

@dw_interface_reports @dw_interface_transactions
@dmp_dw_regression
@too_slow
@eisdev_5447 @eisdev_5358 @eisdev_5565
@eisdev_7226 @eisdev_7384
Feature: Verify month end transaction file for MY contains portfolios.

  As part of Dev Ticket TOM-5073 (EISDEV-5073) , the Month End Transaction file for MY should contain data of group "ES-AWMY - EASTSPRING AL-WARA' INVESTMENTS BERHAD".
  The group "ES-AWMY - EASTSPRING AL-WARA' INVESTMENTS BERHAD" contains currently only one portfolio "AYAWAN"
  This feature is designed to check whether the Month End Transaction file contains only "AYAWAN"

  Background:

    Given I set the DMP workflow web service endpoint to named configuration "dwh.ws.WORKFLOW"
    And I set the database connection to configuration "dmp.db.DW"

  Scenario: Assign Variables

    Given I generate value with date format "YYYYMMdd" and assign to variable "VAR_SYSDATE"
    And I assign "tests/test-data/dmp-interfaces/MonthEndReporting/Transaction" to variable "TESTDATA_PATH"


  Scenario: Create Positions file from Template based on VALN_DATE, RUN_DATE, START_DATE and LAST_DATE

    And I assign "001_ESIPME_TRN_MY.out" to variable "INPUT_FILENAME"
    And I assign "001_ESIPME_TRN_MY_Template.out" to variable "INPUT_TEMPLATENAME"
    And I assign "ESIPME_SEC_Template.out" to variable "SEC_INPUT_TEMPLATENAME"
    And I assign "ESIPME_PFL_Template.out" to variable "PFL_INPUT_TEMPLATENAME"
    And I assign "ESIPME_EXR_Template.out" to variable "EXR_INPUT_FILENAME_MTH_TEMPLATENAME"
    And I assign "ESISODP_EXR_Template.out" to variable "EXR_INPUT_FILENAME_DAILY_TEMPLATENAME"


    And I modify date "${VAR_SYSDATE}" with "-2m" from source format "YYYYMMdd" to destination format "yyyy-MMM-dd" and assign to "VALN_DATE"
    And I modify date "${VAR_SYSDATE}" with "-2m" from source format "YYYYMMdd" to destination format "yyyy-MMM-dd" and assign to "RUN_DATE"

    Given I execute below query and extract values of "ME_FX_DATE;SOD_FX_DATE;LAST_DATE;START_DATE;ME_DATE" into same variables
    """
    select TO_CHAR(LAST_DAY(ADD_MONTHS(SYSDATE,-2)),'YYYY-MON-DD') AS ME_FX_DATE, TO_CHAR(LEAST(TO_DATE('${VALN_DATE}','YYYY-MON-DD'), NEXT_DAY(TO_DATE('${VALN_DATE}','YYYY-MON-DD'), 'Monday') - 3),'YYYY-MON-DD') AS SOD_FX_DATE,
    TO_CHAR(LAST_DAY(ADD_MONTHS(SYSDATE,-2)),'YYYY-MON-DD') AS LAST_DATE,
    CONCAT(TO_CHAR(LAST_DAY(ADD_MONTHS(SYSDATE,-2)),'YYYY-MON'),'-01') AS START_DATE,TO_CHAR(LAST_DAY(ADD_MONTHS(SYSDATE,-2)),'YYYYMMDD') AS ME_DATE from dual
    """

    And I assign "ESIPME_SEC_${ME_DATE}.out" to variable "SEC_INPUT_FILENAME"
    And I assign "ESIPME_PFL_${ME_DATE}.out" to variable "PFL_INPUT_FILENAME"
    And I assign "ESIPME_EXR_${ME_DATE}.out" to variable "EXR_INPUT_FILENAME_MTH"
    And I assign "ESISODP_EXR_${ME_DATE}.out" to variable "EXR_INPUT_FILENAME_DAILY"

    And I create input file "${PFL_INPUT_FILENAME}" using template "${PFL_INPUT_TEMPLATENAME}" from location "${TESTDATA_PATH}"
    And I create input file "${SEC_INPUT_FILENAME}" using template "${SEC_INPUT_TEMPLATENAME}" from location "${TESTDATA_PATH}"
    And I create input file "${INPUT_FILENAME}" using template "${INPUT_TEMPLATENAME}" from location "${TESTDATA_PATH}"
    And I create input file "${EXR_INPUT_FILENAME_MTH}" using template "${EXR_INPUT_FILENAME_MTH_TEMPLATENAME}" from location "${TESTDATA_PATH}"
    And I create input file "${EXR_INPUT_FILENAME_DAILY}" using template "${EXR_INPUT_FILENAME_DAILY_TEMPLATENAME}" from location "${TESTDATA_PATH}"

  Scenario: Load monthly exchange rates

    When I process "${TESTDATA_PATH}/testdata/${EXR_INPUT_FILENAME_MTH}" file with below parameters
      | BUSINESS_FEED |                           |
      | FILE_PATTERN  | ${EXR_INPUT_FILENAME_MTH} |
      | MESSAGE_TYPE  | EIS_MT_BNP_MOPK_FXR       |

  Scenario: Load daily exchange rates

    When I process "${TESTDATA_PATH}/testdata/${EXR_INPUT_FILENAME_DAILY}" file with below parameters
      | BUSINESS_FEED |                             |
      | FILE_PATTERN  | ${EXR_INPUT_FILENAME_DAILY} |
      | MESSAGE_TYPE  | EIS_MT_BNP_MOPK_SOD_FX      |

  Scenario: Refresh cross rates data and exchange rate materialised view

    Given I assign "tests/test-data/intf-specs/gswf/template/EIS_CallStoredProcedureDW/request.xmlt" to variable "STORED_PROCEDURE"

    And I process the workflow template file "${STORED_PROCEDURE}" with below parameters and wait for the job to be completed
      | SQL_PROC_NAME | esi_create_wfxr_cross_rates |

    And I process the workflow template file "${STORED_PROCEDURE}" with below parameters and wait for the job to be completed
      | SQL_PROC_NAME | esi_refresh_daily_month_rates |

  Scenario: Load Security

    When I process "${TESTDATA_PATH}/testdata/${SEC_INPUT_FILENAME}" file with below parameters
      | BUSINESS_FEED |                       |
      | FILE_PATTERN  | ${SEC_INPUT_FILENAME} |
      | MESSAGE_TYPE  | EIS_MT_BNP_MOPK_SEC   |

  Scenario: Load Portfolio

    When I process "${TESTDATA_PATH}/testdata/${PFL_INPUT_FILENAME}" file with below parameters
      | BUSINESS_FEED |                       |
      | FILE_PATTERN  | ${PFL_INPUT_FILENAME} |
      | MESSAGE_TYPE  | EIS_MT_BNP_MOPK_PFL   |

  Scenario: Load Transaction with 2 NON MY records and 1 MY record

    Given I copy files below from local folder "${TESTDATA_PATH}/testdata" to the host "dmp.ssh.inbound" folder "${dmp.ssh.inbound.path}":
      | ${INPUT_FILENAME} |

    When I process files with below parameters and wait for the job to be completed
      | BUSINESS_FEED |                     |
      | FILE_PATTERN  | ${INPUT_FILENAME}   |
      | MESSAGE_TYPE  | EIS_MT_BNP_MOPK_TRN |

  Scenario: Verify Publishing Query retrieves only MY records (Groups) from ft_v_rpt1_meds_transactions (Publishing Table)

  This query is triggered by Control-M internally, so instead of running publishing profile job
  we are testing whether MY records are loaded or not by executing the query.

    Then I expect value of column "PORTFOLIO" in the below SQL query equals to "AYAWAN":
    """
    SELECT distinct SUBSTR(flow_data,instr(flow_data,'MD_266873')-9,6) AS PORTFOLIO FROM ft_v_rpt1_meds_transactions
    WHERE me_date = TO_DATE((select TO_CHAR(LAST_DAY(ADD_MONTHS(SYSDATE,-2)),'YYYYMMDD') from dual),'YYYYMMDD') and grp_nme ='MY'
    and SUBSTR(flow_data,instr(flow_data,'MD_266873')-9,6)='AYAWAN'
    """