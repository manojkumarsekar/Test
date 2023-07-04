#Feature History
#TOM-3768: Created New Feature file to sanity test "Raise Load Calendar Holiday Details" workflow

@dmp_smoke @cal_holiday_wf @tom_3768
Feature: GC Smoke | Orchestrator | GS | Standard OOB | Raise Load Calendar Holiday Details

  Scenario: Verify Execution of Workflow

  #Assign Variables
    And I assign "tests/test-data/dmp-gs/CalendarHoliday" to variable "TESTDATA_PATH"
    And I assign "ExchangeSettlementAllDays_20181011.csv" to variable "INPUT_FILENAME"

  #Load Data
    Given I copy files below from local folder "${TESTDATA_PATH}" to the host "dmp.ssh.inbound" folder "${dmp.ssh.inbound.path}/coppclark/":
      | ${INPUT_FILENAME} |

    Given I set the workflow template parameter "BULK_SIZE" to "100"
    And I set the workflow template parameter "BUSINESS_FEED" to ""
    And I set the workflow template parameter "FILE_NAME" to "${dmp.ssh.inbound.path}/coppclark/${INPUT_FILENAME}"
    And I set the workflow template parameter "IS_VDDBCONFIGURED" to "true"
    And I set the workflow template parameter "MESSAGE_TYPE" to "CoppClark_HolidayReferenceData"
    And I set the workflow template parameter "NO_OF_THREADS" to "20"
    And I set the workflow template parameter "ARCHIVE_DIR" to "/dmp/archive/in/coppclark"
    And I set the workflow template parameter "PARALLELISM" to "4"
    And I set the workflow template parameter "MESSAGE_PROCESSING_EVENT" to "MESSAGE_PROCESSING_EVENT"
    And I set the workflow template parameter "SUCCESS_ACTION" to "MOVE"

    When I send a web service request using template file "tests/test-data/intf-specs/gswf/template/LoadCalendarHolidayDetails/request.xmlt" and save the response to file "testout/evidence/gswf/resp/asyncResponse.xml"
    Then I extract a value from the XML file "testout/evidence/gswf/resp/asyncResponse.xml" using XPath query in file "tests/test-data/intf-specs/gswf/template/LoadCalendarHolidayDetails/flowResultIdQuery.xpath" to variable "flowResultId"

        Then I poll for maximum 60 seconds and expect the result of the SQL query below equals to "DONE":
        """
        SELECT WF_RUNTIME_STAT_TYP FROM FT_WF_WFRI WHERE INSTANCE_ID='${flowResultId}'
        """

    Then I extract new job id from jblg table into a variable "JOB_ID"

    Then I poll for maximum 20 seconds and expect the result of the SQL query below equals to "CLOSED":
      """
      SELECT JOB_STAT_TYP FROM FT_T_JBLG WHERE JOB_ID='${JOB_ID}' AND TASK_SUCCESS_CNT !=0
      """