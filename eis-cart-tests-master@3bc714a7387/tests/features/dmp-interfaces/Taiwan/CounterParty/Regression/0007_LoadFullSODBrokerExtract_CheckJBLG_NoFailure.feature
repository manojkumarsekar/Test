#https://collaborate.intranet.asia/pages/viewpage.action?pageId=48893798
#https://jira.intranet.asia/browse/TOM-3873
#https://jira.intranet.asia/browse/TOM-4094

@dmp_taiwan
@tom_3873 @tw_broker_fulllist @tom_4094
Feature: Test full list of brokers from BRS and check JBLG

  Scenario: TC1: Load Broker file with full list of BRS brokers and check there is no failed in JBLG

    Given I assign "tests/test-data/dmp-interfaces/Taiwan/CounterParty/" to variable "testdata.path"
    And I assign "0007_LoadFullSODBrokerExtract_CheckJBLG_NoFailure.xml" to variable "INPUT_FILENAME"
    And I assign "180" to variable "workflow.max.polling.time"

    When I copy files below from local folder "${testdata.path}/testdata" to the host "dmp.ssh.inbound" folder "${dmp.ssh.inbound.path}":
      | ${INPUT_FILENAME} |
    And I assign "600" to variable "workflow.max.polling.time"
    And I process files with below parameters and wait for the job to be completed
      | FILE_PATTERN  | ${INPUT_FILENAME}       |
      | MESSAGE_TYPE  | EIS_MT_BRS_COUNTERPARTY |
      | BUSINESS_FEED |                         |

    Then I extract new job id from jblg table into a variable "JOB_ID"

#    GEN broker_type is filtered and skipped while loading
    And I expect value of column "JBLG_ROW_COUNT" in the below SQL query equals to "1":
      """
      SELECT count(*) as JBLG_ROW_COUNT FROM FT_T_JBLG WHERE JOB_ID = '${JOB_ID}' and TASK_SUCCESS_CNT ='3209' and TASK_FILTERED_CNT ='2'
      """

  Scenario: Cleanup max polling time variable
    Then I remove variable "workflow.max.polling.time" from memory