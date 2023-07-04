#https://collaborate.intranet.asia/pages/viewpage.action?pageId=48893798
#https://jira.intranet.asia/browse/TOM-3873
#https://jira.intranet.asia/browse/TOM-4094

@gc_interface_counterparty
@dmp_regression_unittest
@dmp_taiwan
@tom_3873 @tw_broker_updatebroker @tom_4094
Feature: Test the broker file from by updating one identifier for broker

  Scenario: TC0: Clear old test data and setup variables

    Given I assign "tests/test-data/dmp-interfaces/Taiwan/CounterParty/" to variable "testdata.path"
    And I assign "0009_UpdateBrokerIdentifiers.xml" to variable "INPUT_FILENAME"
    And I extract value from the xml file "${testdata.path}/testdata/${INPUT_FILENAME}" with xpath "//COUNTERPARTY//COUNTERPARTY_CODE[text()='200_TEST']/../COUNTERPARTY_CODE" to variable "COUNTERPARTY_CODE"

    And I execute below query
     """
      UPDATE FT_T_FIID SET START_TMS=SYSDATE-1, END_TMS=SYSDATE, LAST_CHG_TMS=SYSDATE WHERE INST_MNEM IN (
      SELECT INST_MNEM FROM FT_T_FIID WHERE FINS_ID IN('100_TEST','101_TEST','200_TEST','TICKER2_TEST','TICKER1_TEST')AND end_tms IS NULL );
      COMMIT
     """

#  EISTOMTEST-3970
  Scenario: TC1: Load Broker file by updating identifies for broker
  Expected Result: It should update the existing broker identifier as the source is same instead of creating new record for evert update in FIID table

    When I copy files below from local folder "${testdata.path}/testdata" to the host "dmp.ssh.inbound" folder "${dmp.ssh.inbound.path}":
      | ${INPUT_FILENAME} |

    And I process files with below parameters and wait for the job to be completed
      | FILE_PATTERN  | ${INPUT_FILENAME}       |
      | MESSAGE_TYPE  | EIS_MT_BRS_COUNTERPARTY |
      | BUSINESS_FEED |                         |

    Then I extract new job id from jblg table into a variable "JOB_ID"

    And I expect value of column "JBLG_ROW_COUNT" in the below SQL query equals to "1":
    """
    SELECT count(*) as JBLG_ROW_COUNT FROM FT_T_JBLG WHERE JOB_ID = '${JOB_ID}'
    """

  #   Check COUNTERPARTY_NAME field from BRS file stored in INST_NME and INST_DESC desc column in FINS Table against COUNTERPARTY_CODE
    Then I expect value of column "FIID_COUNT" in the below SQL query equals to "3":
      """
      SELECT COUNT(*) AS FIID_COUNT from ft_t_FIID where INST_MNEM IN (select INST_MNEM from ft_t_FIID where FINS_ID IN ('${COUNTERPARTY_CODE}') AND end_tms IS NULL)
      """

