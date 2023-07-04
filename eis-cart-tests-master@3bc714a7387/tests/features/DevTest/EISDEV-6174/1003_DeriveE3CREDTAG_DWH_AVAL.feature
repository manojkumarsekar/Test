#https://jira.pruconnect.net/browse/EISDEV-6174
#https://collaborate.pruconnect.net/display/EISTOM/EIFFEL+III+Development+-+Credit+Tagging
#EISDEV_6336: As part of this ticket, new columns ESI_CORE_L2 and ESI_E3_CTAG were removed from month-end file
#EISDEV-6431: Updated insert script for DWH to end_date existing classification data from Prod. This is to match data set up in GC vs DWH in feature file.
#eisdev_6425 : new condition for money market deposit has been added redi2 view
#eisdev_6700 : ft_v_rpt1_redi_billing view has a join with WISU table for the reporting month. This security is not received post May. Adding Security data load for reporting month
#eisdev_7227 : added portfolio and exchange rate load. Added steps to refresh Mviews
#eisdev_7378 : added dw_status_num=1 to wagr.

@dw_interface_positions
@dmp_dw_regression
@dw_interface_securities
@eisdev_6174 @e3credtag_dwh @eisdev_6336 @eisdev_6431 @eisdev_6425 @e3credtag @eisdev_6700
@eisdev_7227 @eisdev_7378

Feature: Test addition of two new columns in DWH AVAL

  This feature tests addition of two new columns(classifications) - ESI_CORE_L2 and ESI_E3_CTAG in DWH AVAL
  ESI_CORE_L2 and ESI_E3_CTAG - values are flowing to DWH from GC via Talend delta job

  Background:

    Given I set the DMP workflow web service endpoint to named configuration "dwh.ws.WORKFLOW"
    And I set the database connection to configuration "dmp.db.DW"

  Scenario: Assign Variables

    Given I generate value with date format "YYYYMMdd" and assign to variable "VAR_SYSDATE"
    And I assign "tests/test-data/DevTest/EISDEV-6174" to variable "testdata.path"
    #By default Publishing job polling time is 300sec. Since these are testing jobs, we don't want to wait 300sec in case of failures
    #so setting to 600sec and removing this variable at the end
    Given I assign "600" to variable "workflow.max.polling.time"

  Scenario: Insert prequisite data

    And I execute below query to "Set up data for the given instrument for WNCS, WNCL, WISL"
    """
    ${testdata.path}/sql/dwh_wncs_wncl_insert.sql
    """

  Scenario: Create Positions file from Template based on VALN_DATE, RUN_DATE, START_DATE and LAST_DATE

    And I assign "001_ME_POS.out" to variable "INPUT_FILENAME"
    And I assign "001_ME_POS_Template.out" to variable "INPUT_TEMPLATENAME"
    And I assign "ESIPME_SEC_Template.out" to variable "SEC_INPUT_TEMPLATENAME"
    And I assign "ESIPME_PFL_Template.out" to variable "PFL_INPUT_TEMPLATENAME"
    And I assign "ESISODP_EXR_1_Template.out" to variable "EXR_INPUT_TEMPLATENAME"

    And I modify date "${VAR_SYSDATE}" with "-3m" from source format "YYYYMMdd" to destination format "yyyy-MMM-dd" and assign to "VALN_DATE"
    And I modify date "${VAR_SYSDATE}" with "-2m" from source format "YYYYMMdd" to destination format "yyyy-MMM-dd" and assign to "RUN_DATE"

    Given I execute below query and extract values of "LAST_DATE;START_DATE;ME_DATE;BNP_ME_DATE" into same variables
    """
    select TO_CHAR(LAST_DAY(ADD_MONTHS(SYSDATE,-2)),'YYYY-MON-DD') AS LAST_DATE, CONCAT(TO_CHAR(LAST_DAY(ADD_MONTHS(SYSDATE,-2)),'YYYY-MON'),'-01') AS START_DATE,TO_CHAR(LAST_DAY(ADD_MONTHS(SYSDATE,-2)),'YYYYMMDD') AS ME_DATE, TO_CHAR(LAST_DAY(ADD_MONTHS(SYSDATE,-2)),'YYYY-MON-DD') AS BNP_ME_DATE from dual
    """

    And I assign "ESIPME_SEC_${ME_DATE}.out" to variable "SEC_INPUT_FILENAME"
    And I assign "ESIPME_PFL_${ME_DATE}.out" to variable "PFL_INPUT_FILENAME"
    And I assign "ESISODP_EXR_1_${ME_DATE}.out" to variable "EXR_INPUT_FILENAME"

    And I create input file "${INPUT_FILENAME}" using template "${INPUT_TEMPLATENAME}" from location "${testdata.path}/inputfiles"

    And I create input file "${SEC_INPUT_FILENAME}" using template "${SEC_INPUT_TEMPLATENAME}" from location "${testdata.path}/inputfiles"

    And I create input file "${PFL_INPUT_FILENAME}" using template "${PFL_INPUT_TEMPLATENAME}" from location "${testdata.path}/inputfiles"

    And I create input file "${EXR_INPUT_FILENAME}" using template "${EXR_INPUT_TEMPLATENAME}" from location "${testdata.path}/inputfiles"

  Scenario: Load Portfolio

    When I process "${testdata.path}/inputfiles/testdata/${PFL_INPUT_FILENAME}" file with below parameters
      | BUSINESS_FEED |                       |
      | FILE_PATTERN  | ${PFL_INPUT_FILENAME} |
      | MESSAGE_TYPE  | EIS_MT_BNP_MOPK_PFL   |

  Scenario: Load Security

    When I process "${testdata.path}/inputfiles/testdata/${SEC_INPUT_FILENAME}" file with below parameters
      | BUSINESS_FEED |                       |
      | FILE_PATTERN  | ${SEC_INPUT_FILENAME} |
      | MESSAGE_TYPE  | EIS_MT_BNP_MOPK_SEC   |

  Scenario: Load Exchange rate

    When I process "${testdata.path}/inputfiles/testdata/${EXR_INPUT_FILENAME}" file with below parameters
      | BUSINESS_FEED |                        |
      | FILE_PATTERN  | ${EXR_INPUT_FILENAME}  |
      | MESSAGE_TYPE  | EIS_MT_BNP_MOPK_SOD_FX |

  Scenario: Load Positions

    When I process "${testdata.path}/inputfiles/testdata/${INPUT_FILENAME}" file with below parameters
      | BUSINESS_FEED |                     |
      | FILE_PATTERN  | ${INPUT_FILENAME}   |
      | MESSAGE_TYPE  | EIS_MT_BNP_MOPK_POS |

  Scenario: Refresh cross rates data and exchange rate materialised view

    Given I assign "tests/test-data/intf-specs/gswf/template/EIS_CallStoredProcedureDW/request.xmlt" to variable "STORED_PROCEDURE"

    And I process the workflow template file "${STORED_PROCEDURE}" with below parameters and wait for the job to be completed
      | SQL_PROC_NAME | esi_create_wfxr_cross_rates |

    And I process the workflow template file "${STORED_PROCEDURE}" with below parameters and wait for the job to be completed
      | SQL_PROC_NAME | esi_refresh_daily_month_rates |

  Scenario: Publish positions report for AVAL file

    Given I assign "dwh_aval_position" to variable "AVALPOS_PUBLISHING_FILENAME"
    And I assign "/dmp/out/eis/redi2" to variable "PUBLISHING_DIR"

    When I remove below files in the host "dmp.ssh.inbound" from folder "${PUBLISHING_DIR}" if exists:
      | ${AVALPOS_PUBLISHING_FILENAME}.csv |

    Then I process DWH publishing wrapper with below parameters and wait for the job to be completed
      | BULK_SIZE           | 100000                                                                                                          |
      | CONVERT_TO_EXCEL    | false                                                                                                           |
      | FILE_DIRECTORY      | ${PUBLISHING_DIR}                                                                                               |
      | PUBLISHING_FILENAME | ${AVALPOS_PUBLISHING_FILENAME}.csv                                                                              |
      | THREAD_COUNT        | 1                                                                                                               |
      | SQL_ID              | SELECT DISTINCT posn_sok id FROM ft_v_rpt1_redi_billing WHERE me_date = TRUNC(LAST_DAY(ADD_MONTHS(SYSDATE,-2))) |
      | SQL_PUBLISH         | SELECT posn_sok id, flow_data FROM ft_v_rpt1_redi_billing                                                       |

    Then I expect below files to be present in the host "dmp.ssh.inbound" into folder "${PUBLISHING_DIR}" after processing:
      | ${AVALPOS_PUBLISHING_FILENAME}.csv |

    Then I copy files below from remote folder "${PUBLISHING_DIR}" on host "dmp.ssh.inbound" into local folder "${testdata.path}/outfiles/runtime":
      | ${AVALPOS_PUBLISHING_FILENAME}.csv |

  Scenario: Check the reports record count and positions' client details

    Then I expect file "${testdata.path}/outfiles/runtime/${AVALPOS_PUBLISHING_FILENAME}.csv" should have 3 records
    And I expect column '"ESI_CORE_L2"' value to be "Fixed Income" where column '"SecurityCode"' value is "MD_146755" in CSV file "${testdata.path}/outfiles/runtime/${AVALPOS_PUBLISHING_FILENAME}.csv"
    And I expect column '"ESI_E3_CTAG"' value to be "Non Credit" where column '"SecurityCode"' value is "MD_146755" in CSV file "${testdata.path}/outfiles/runtime/${AVALPOS_PUBLISHING_FILENAME}.csv"
    And I expect column '"ESI_E3_CTAG"' value to be "Non Credit" where column '"SecurityCode"' value is "MD_637025" in CSV file "${testdata.path}/outfiles/runtime/${AVALPOS_PUBLISHING_FILENAME}.csv"

  Scenario: Cleanup max polling time variable

    Then I remove variable "workflow.max.polling.time" from memory