#Feature History
#EISDEV-7035: https://jira.pruconnect.net/browse/EISDEV-7035
#EISDEV-7229: Adding additional erecords to test end-date scenarios and changes for new workflow

@dmp_regression_integrationtest @cal_holiday_wf @eisdev_7035 @eisdev_7229
Feature: Load Fund Holiday Calendar and verify end-date of holiday entries not present on reload

  1. 12 holiday records are loaded for fund with SITCAFNDID DFO02, and 2 records for fund with SITCAFNDID TEST2.
  TEST2 records will be filtered as the Fund is not present in the database.
  In this case, we expect all 12 DFO02 calendar records to be set up and an ACCA record to be set up with DFO02 fund.
  2. 11 holiday records are loaded for DFO02 ie 10 existing records and 1 new record. In this case we expect the new record
  to get set up and the 2 excluded records to be end-dated.

  Scenario: TC_1: Clear data for TEST, set up ACID and initial variable assignment

    And I assign "tests/test-data/dmp-interfaces/Taiwan/FASFundHoliday" to variable "TESTDATA_PATH"
    And I assign "esi_TW_fas_fund_holiday_Load1.csv" to variable "INPUT_FILENAME1"
    And I assign "esi_TW_fas_fund_holiday_load2.csv" to variable "INPUT_FILENAME2"
    And I execute below query to "clear existing calendar data for DFO02"
      """
      ${TESTDATA_PATH}/ClearData.sql
      """

  Scenario: TC_2: Load 1st Calendar file using workflow

    Given I copy files below from local folder "${TESTDATA_PATH}" to the host "dmp.ssh.inbound" folder "${dmp.ssh.inbound.path}/taiwan/":
      | ${INPUT_FILENAME1} |

    Given I assign "tests/test-data/intf-specs/gswf/template/EIS_LoadCalendarHolidayDetails/request.xmlt" to variable "HLDY_CAL_WF"

    And I process the workflow template file "${HLDY_CAL_WF}" with below parameters and wait for the job to be completed

      | BULK_SIZE         | 100                                               |
      | FILE_NAME         | ${dmp.ssh.inbound.path}/taiwan/${INPUT_FILENAME1} |
      | IS_VDDBCONFIGURED | false                                             |
      | MESSAGE_TYPE      | EIS_MT_TW_FAS_FUND_HOLIDAY                        |
      | NO_OF_THREADS     | 20                                                |
      | ARCHIVE_DIR       | /dmp/archive/in/taiwan                            |
      | PARALLELISM       | 4                                                 |
      | SUCCESS_ACTION    | MOVE                                              |

    Then I extract new job id from jblg table into a variable "JOB_ID"
    And I expect workflow is processed in DMP with success record count as "24"
    And partial record count as "2"

  Scenario: TC_3: Verify load of the 12 successful records

    Then I expect value of column "CADH_COUNT" in the below SQL query equals to "24":
    """
      SELECT COUNT(1) AS CADH_COUNT FROM FT_T_CADH where cal_id in ('DFO02','DDM01','DDO03') and end_tms is null
    """

  Scenario: TC_4: Load 2nd Calendar file using workflow for second load

    Given I copy files below from local folder "${TESTDATA_PATH}" to the host "dmp.ssh.inbound" folder "${dmp.ssh.inbound.path}/taiwan/":
      | ${INPUT_FILENAME2} |

    Given I assign "tests/test-data/intf-specs/gswf/template/EIS_LoadCalendarHolidayDetails/request.xmlt" to variable "HLDY_CAL_WF"

    And I process the workflow template file "${HLDY_CAL_WF}" with below parameters and wait for the job to be completed

      | BULK_SIZE         | 100                                               |
      | FILE_NAME         | ${dmp.ssh.inbound.path}/taiwan/${INPUT_FILENAME2} |
      | IS_VDDBCONFIGURED | false                                             |
      | MESSAGE_TYPE      | EIS_MT_TW_FAS_FUND_HOLIDAY                        |
      | NO_OF_THREADS     | 20                                                |
      | ARCHIVE_DIR       | /dmp/archive/in/taiwan                            |
      | PARALLELISM       | 4                                                 |
      | SUCCESS_ACTION    | MOVE                                              |

    Then I extract new job id from jblg table into a variable "JOB_ID"
    And I expect workflow is processed in DMP with success record count as "21"

  Scenario: TC_5: Verify load and that only 11 records are active as compared to 13 records

    Then I expect value of column "CADH_COUNT" in the below SQL query equals to "21":
    """
      SELECT COUNT(1) AS CADH_COUNT FROM FT_T_CADH where cal_id in ('DFO02','DDM01','DDO03') and end_tms is null
    """
