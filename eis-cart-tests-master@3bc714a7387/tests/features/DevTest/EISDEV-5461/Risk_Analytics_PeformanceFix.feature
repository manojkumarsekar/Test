#https://jira.intranet.asia/browse/EISDEV-5461

#No regression tag observed. Hence, modular tag (Ex: gc_interface or dw_interface) has not given.
@eisdev_5461
Feature: Load Risk Analytics full file for performance test
  Risk analytics file load performance issue is fixed.
  Time taken to load around 12k+ records(full file load) has been reduced around 1 hour to 14 min(01:09:42 to 00:14:33)
  This feature file load 1358 records for which time has been reduced from 00:08:05 to 00:02:01

  Scenario: Load Risk Analytics file

    Given I assign "esi_security_analytics_apac_20191227.xml" to variable "INPUT_FILENAME1"
    And I assign "tests/test-data/DevTest/EISDEV-5461" to variable "testdata.path"
    And I assign "150" to variable "workflow.max.polling.time"

    Given I copy files below from local folder "${testdata.path}/testdata" to the host "dmp.ssh.inbound" folder "${dmp.ssh.inbound.path}":
      | ${INPUT_FILENAME1} |

    When I process files with below parameters and wait for the job to be completed
      | BUSINESS_FEED |                           |
      | FILE_PATTERN  | ${INPUT_FILENAME1}        |
      | MESSAGE_TYPE  | EIS_MT_BRS_RISK_ANALYTICS |

    Then I expect workflow is processed in DMP with total record count as "1358"
    And success record count as "1292"
    And completed record count as "1358"

  Scenario: TC_3: Cleanup max polling time variable
    Then I remove variable "workflow.max.polling.time" from memory