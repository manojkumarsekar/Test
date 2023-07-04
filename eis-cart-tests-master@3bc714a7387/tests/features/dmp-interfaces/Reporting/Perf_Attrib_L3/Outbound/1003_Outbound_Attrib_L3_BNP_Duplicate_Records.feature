#https://jira.intranet.asia/browse/TOM-5126
#https://collaborate.intranet.asia/display/TOM/Attribution+Data+Marts+-+New
#https://collaborate.intranet.asia/pages/viewpage.action?spaceKey=TOMR4&title=Outbound+Data+Mapping+%3A-+L3+Attribution

# ===================================================================================================================================================================================
# Date            JIRA        Comments
# ===================================================================================================================================================================================
# 09/09/2019      TOM-4971    Development - BNP Performance L3 file Load
# 04/02/2020      EISDEV-5225  Date format changes in input file and field name changes
# 27/02/2020      EISDEV-5564  Active Return(local) and Active Contribution field mappings
# 19/11/2020      EISDEV-7166  Input Layout Changes for BNP L1 file for 37 columns
# 15/01/2021      EISDEV-7323  Change in date format for L1 files
# ===================================================================================================================================================================================

@dw_interface_performance
@dmp_dw_regression
@tom_5222 @perf_attrib_l3 @eisdev_5525 @eisdev_5564 @perf_l1 @eisdev_7166 @eisdev_7323
Feature: Test duplicate records in BNP Attribution L3 file

  This is to test BNP L3 Attribution file does not have duplicate records in published file.
  Duplicates were getting published if file has multiple records in the input having same unique key

  Background:

    Given I set the DMP workflow web service endpoint to named configuration "dwh.ws.WORKFLOW"
    And I set the database connection to configuration "dmp.db.DW"
    And I generate value with date format "YYYYMMdd-HHmmss" and assign to variable "UPDATE_VAR_SYSDATE"

  Scenario: Clear old test data and setup variables

    Given I assign "tests/test-data/dmp-interfaces/Reporting/Perf_Attrib_L3/Outbound" to variable "testdata.path"

    #In order to make feature file re-runnable, existing L3 fund attribution & related data is cleaned up
    And I execute below query
    """
     ${testdata.path}/sql/1001_AccountBMSetup.sql
    """

  Scenario: Publish L3 Attribution backlog file and remove it

    Given I set the DMP workflow web service endpoint to named configuration "dwh.ws.WORKFLOW"
    And I set the database connection to configuration "dmp.db.DW"
    And I assign "ESI_L3_ATTRIB_00" to variable "PUBLISHING_FILE_NAME"
    And I assign "/dmp/out/coric" to variable "publishDirectory"
    And I generate value with date format "YYYYMMdd" and assign to variable "VAR_SYSDATE"
    And I remove below files with pattern in the host "dmp.ssh.inbound" from folder "${publishDirectory}" if exists:
      | ${PUBLISHING_FILE_NAME}_*.csv |

    When I process GSO_DWH publishing wrapper with below parameters and wait for the job to be completed
      | PUBLISHING_FILE_NAME        | ${PUBLISHING_FILE_NAME}.csv |
      | SUBSCRIPTION_NAME           | EIS_DMP_TO_CORIC_ATTRIB_L3  |
      | EXTRACT_STREETREF_TO_SUBMIT | false                       |

    And I remove below files with pattern in the host "dmp.ssh.inbound" from folder "${publishDirectory}" if exists:
      | ${PUBLISHING_FILE_NAME}_*.csv |

  Scenario: Load BNP L1 performance file

    Given I copy files below from local folder "${testdata.path}/testdata" to the host "dmp.ssh.inbound" folder "${dmp.ssh.inbound.path}":
      | 001_PERFL1.csv |

    And I process files with below parameters and wait for the job to be completed
      | BUSINESS_FEED |                        |
      | FILE_PATTERN  | 001_PERFL1.csv         |
      | MESSAGE_TYPE  | EIS_MT_BNP_DWH_PERF_L1 |

    Then I extract new job id from jblg table into a variable "JOB_ID"

    And I expect value of column "JBLG_ROW_COUNT" in the below SQL query equals to "1":
    """
      SELECT COUNT(1) AS JBLG_ROW_COUNT FROM FT_T_JBLG WHERE JOB_ID = '${JOB_ID}' AND TASK_SUCCESS_CNT ='1'
    """

  Scenario: Perform checks in WCRI for accounts loaded

    Then I expect value of column "WCRI_COUNT" in the below SQL query equals to "3":
    """
      SELECT COUNT(*) AS WCRI_COUNT
      FROM FT_T_WCRI WHERE ACCT_SOK = (select acct_sok from ft_t_wact where intrnl_id10 = 'T5126' and  DW_STATUS_NUM =1) AND DW_STATUS_NUM =1
    """

  Scenario: Load BNP L3 performance file having duplicates

    Given I copy files below from local folder "${testdata.path}/testdata" to the host "dmp.ssh.inbound" folder "${dmp.ssh.inbound.path}":
      | PERF_ATTRIB_L3_SAMPLE4.csv |

    And I process files with below parameters and wait for the job to be completed
      | BUSINESS_FEED |                               |
      | FILE_PATTERN  | PERF_ATTRIB_L3_SAMPLE4.csv    |
      | MESSAGE_TYPE  | EIS_MT_BNP_DWH_PERF_ATTRIB_L3 |

    Then I extract new job id from jblg table into a variable "JOB_ID"

    And I expect value of column "JBLG_ROW_COUNT" in the below SQL query equals to "1":
    """
      SELECT COUNT(1) AS JBLG_ROW_COUNT FROM FT_T_JBLG WHERE JOB_ID = '${JOB_ID}' AND TASK_SUCCESS_CNT ='18'
    """

  Scenario: Publish L3 Attribution file for the loaded records

    Given I set the DMP workflow web service endpoint to named configuration "dwh.ws.WORKFLOW"
    And I set the database connection to configuration "dmp.db.DW"
    And I assign "ESI_L3_ATTRIB_04" to variable "PUBLISHING_FILE_NAME"
    And I assign "/dmp/out/coric" to variable "publishDirectory"
    And I generate value with date format "YYYYMMdd" and assign to variable "VAR_SYSDATE"
    And I remove below files with pattern in the host "dmp.ssh.inbound" from folder "${publishDirectory}" if exists:
      | ${PUBLISHING_FILE_NAME}_*.csv |

    When I process GSO_DWH publishing wrapper with below parameters and wait for the job to be completed
      | PUBLISHING_FILE_NAME        | ${PUBLISHING_FILE_NAME}.csv |
      | SUBSCRIPTION_NAME           | EIS_DMP_TO_CORIC_ATTRIB_L3  |
      | EXTRACT_STREETREF_TO_SUBMIT | false                       |

    Then I expect below files to be present in the host "dmp.ssh.inbound" into folder "${publishDirectory}" after processing:
      | ${PUBLISHING_FILE_NAME}_${VAR_SYSDATE}_1.csv |

    Then I copy files below from remote folder "${publishDirectory}" on host "dmp.ssh.inbound" into local folder "${testdata.path}/outfiles/runtime":
      | ${PUBLISHING_FILE_NAME}_${VAR_SYSDATE}_1.csv |

  Scenario: Verify trade L3 attribution file

    Then I expect reconciliation between generated CSV file "${testdata.path}/outfiles/runtime/${PUBLISHING_FILE_NAME}_${VAR_SYSDATE}_1.csv" and reference CSV file "${testdata.path}/outfiles/testdata/ESI_L3_ATTRIB_Expected_4.csv" should be successful and exceptions to be written to "${testdata.path}/outfiles/runtime/Exceptions_${PUBLISHING_FILE_NAME}_${VAR_SYSDATE}.csv" file

  Scenario: Load BNP L3 performance file with 1 record loaded previously to check if same is getting published

    Given I copy files below from local folder "${testdata.path}/testdata" to the host "dmp.ssh.inbound" folder "${dmp.ssh.inbound.path}":
      | PERF_ATTRIB_L3_SAMPLE5.csv |

    And I process files with below parameters and wait for the job to be completed
      | BUSINESS_FEED |                               |
      | FILE_PATTERN  | PERF_ATTRIB_L3_SAMPLE5.csv    |
      | MESSAGE_TYPE  | EIS_MT_BNP_DWH_PERF_ATTRIB_L3 |

    Then I extract new job id from jblg table into a variable "JOB_ID"

    And I expect value of column "JBLG_ROW_COUNT" in the below SQL query equals to "1":
    """
      SELECT COUNT(1) AS JBLG_ROW_COUNT FROM FT_T_JBLG WHERE JOB_ID = '${JOB_ID}' AND TASK_SUCCESS_CNT ='1'
    """

  Scenario: Publish L3 Attribution file for the loaded records

    Given I set the DMP workflow web service endpoint to named configuration "dwh.ws.WORKFLOW"
    And I set the database connection to configuration "dmp.db.DW"
    And I assign "ESI_L3_ATTRIB_05" to variable "PUBLISHING_FILE_NAME"
    And I assign "/dmp/out/coric" to variable "publishDirectory"
    And I generate value with date format "YYYYMMdd" and assign to variable "VAR_SYSDATE"
    And I remove below files with pattern in the host "dmp.ssh.inbound" from folder "${publishDirectory}" if exists:
      | ${PUBLISHING_FILE_NAME}_*.csv |

    When I process GSO_DWH publishing wrapper with below parameters and wait for the job to be completed
      | PUBLISHING_FILE_NAME        | ${PUBLISHING_FILE_NAME}.csv |
      | SUBSCRIPTION_NAME           | EIS_DMP_TO_CORIC_ATTRIB_L3  |
      | EXTRACT_STREETREF_TO_SUBMIT | false                       |

    Then I expect below files to be present in the host "dmp.ssh.inbound" into folder "${publishDirectory}" after processing:
      | ${PUBLISHING_FILE_NAME}_${VAR_SYSDATE}_1.csv |

    Then I copy files below from remote folder "${publishDirectory}" on host "dmp.ssh.inbound" into local folder "${testdata.path}/outfiles/runtime":
      | ${PUBLISHING_FILE_NAME}_${VAR_SYSDATE}_1.csv |

  Scenario: Verify trade L3 attribution file

    Then I expect reconciliation between generated CSV file "${testdata.path}/outfiles/runtime/${PUBLISHING_FILE_NAME}_${VAR_SYSDATE}_1.csv" and reference CSV file "${testdata.path}/outfiles/testdata/ESI_L3_ATTRIB_Expected_5.csv" should be successful and exceptions to be written to "${testdata.path}/outfiles/runtime/Exceptions_${PUBLISHING_FILE_NAME}_${VAR_SYSDATE}.csv" file
