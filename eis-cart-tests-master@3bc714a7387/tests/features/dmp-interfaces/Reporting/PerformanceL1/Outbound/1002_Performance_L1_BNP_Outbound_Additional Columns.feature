#https://jira.intranet.asia/browse/TOM-5178
#https://jira.pruconnect.net/browse/EISDEV-6997
# ===================================================================================================================================================================================
# Date            JIRA        Comments
# ===================================================================================================================================================================================
# 20/09/2019      TOM-5178    Additional data fields to be exposed to CORIC Outbound files
# 11/11/2020      EISDEV-6997 Addition of new column ShareClassAUMMUSD
# 19/11/2020      EISDEV-7166  Input Layout Changes for BNP L1 file for 37 columns
# 22/12/2020      EISDEV-5173 Change in input file date format
# ===================================================================================================================================================================================

#https://collaborate.intranet.asia/display/TOM/Performance+Data+Mart+-New
#https://collaborate.intranet.asia/display/TOMR4/Outbound+Data+Mapping+%3A-+L1+Fund+Performance

@dw_interface_performance
@dmp_dw_regression
@tom_5178 @tom_5178_outbound @perf_l1_out @eisdev_6997 @perf_l1 @eisdev_7166 @eisdev_5173
Feature: Test BNP performance L1 file is getting published including addition of 12 columns as below

  This is to test if BNP L1 performance file is getting loaded in DWH and file is getting published
  And load data with different data to verify if delta publishing is working
  1. 6 Month Net Absolute Returns
  2.  6 Month Net Relative Returns
  3.  1 Month Benchmark Returns
  4.  3 Month Benchmark Returns
  5.  6 Month Benchmark Returns
  6.  1 Year Benchmark Returns
  7.  1 Month Gross Relative Returns
  8.  3 Month Gross Relative Returns
  9. 6 Month Gross Relative Returns
  10. 1 Year Gross Relative Returns
  11.  Since Inception Gross Absolute Returns
  12.  Since Inception Gross Relative Returns

  Background:

    Given I set the DMP workflow web service endpoint to named configuration "dwh.ws.WORKFLOW"
    And I set the database connection to configuration "dmp.db.DW"
    And I generate value with date format "YYYYMMdd-HHmmss" and assign to variable "UPDATE_VAR_SYSDATE"

  Scenario: Clear old test data and setup variables

    Given I assign "tests/test-data/dmp-interfaces/Reporting/PerformanceL1/Outbound" to variable "testdata.path"

    #In order to make feature file re-runnable, existing fund performance & related data is cleaned up
    And I execute below query
    """
     ${testdata.path}/sql/Additional_Columns_AccountBMSetup.sql
    """

  Scenario: Publish L1 Performance backlog file and remove it

    Given I assign "ESI_L1_PERF_AD_00" to variable "PUBLISHING_FILE_NAME"
    And I assign "/dmp/out/coric" to variable "publishDirectory"
    And I generate value with date format "YYYYMMdd" and assign to variable "VAR_SYSDATE"
    And I remove below files with pattern in the host "dmp.ssh.inbound" from folder "${publishDirectory}" if exists:
      | ${PUBLISHING_FILE_NAME}_*.csv |

    When I process GSO_DWH publishing wrapper with below parameters and wait for the job to be completed
      | PUBLISHING_FILE_NAME        | ${PUBLISHING_FILE_NAME}.csv |
      | SUBSCRIPTION_NAME           | EIS_DMP_TO_CORIC_PER_L1     |
      | EXTRACT_STREETREF_TO_SUBMIT | false                       |

    And I remove below files with pattern in the host "dmp.ssh.inbound" from folder "${publishDirectory}" if exists:
      | ${PUBLISHING_FILE_NAME}_*.csv |

  Scenario: Load BNP L1 performance file having 6 records

    Given I copy files below from local folder "${testdata.path}/testdata" to the host "dmp.ssh.inbound" folder "${dmp.ssh.inbound.path}":
      | PERFL1SAMPLE1_Additional_Columns.csv |

    And I process files with below parameters and wait for the job to be completed
      | BUSINESS_FEED |                                      |
      | FILE_PATTERN  | PERFL1SAMPLE1_Additional_Columns.csv |
      | MESSAGE_TYPE  | EIS_MT_BNP_DWH_PERF_L1               |

    Then I extract new job id from jblg table into a variable "JOB_ID"

    And I expect value of column "JBLG_ROW_COUNT" in the below SQL query equals to "1":
    """
      SELECT COUNT(1) AS JBLG_ROW_COUNT FROM FT_T_JBLG WHERE JOB_ID = '${JOB_ID}' AND TASK_SUCCESS_CNT ='6'
    """

  Scenario: Perform checks in WCRI for multiple scenarios

    Then I expect value of column "WCRI_COUNT" in the below SQL query equals to "28":
    """
      SELECT COUNT(*) AS WCRI_COUNT
      FROM FT_T_WCRI WHERE ACCT_SOK = (select acct_sok from ft_t_wact where intrnl_id10 = 'TOM5178' and  DW_STATUS_NUM =1) AND DW_STATUS_NUM =1
    """

  Scenario: Publish L1 Performance file for 6 records

    Given I assign "ESI_L1_PERF_AD_01" to variable "PUBLISHING_FILE_NAME"
    And I assign "/dmp/out/coric" to variable "publishDirectory"
    And I generate value with date format "YYYYMMdd" and assign to variable "VAR_SYSDATE"
    And I remove below files with pattern in the host "dmp.ssh.inbound" from folder "${publishDirectory}" if exists:
      | ${PUBLISHING_FILE_NAME}_*.csv |

    When I process GSO_DWH publishing wrapper with below parameters and wait for the job to be completed
      | PUBLISHING_FILE_NAME        | ${PUBLISHING_FILE_NAME}.csv |
      | SUBSCRIPTION_NAME           | EIS_DMP_TO_CORIC_PER_L1     |
      | EXTRACT_STREETREF_TO_SUBMIT | false                       |

    Then I expect below files to be present in the host "dmp.ssh.inbound" into folder "${publishDirectory}" after processing:
      | ${PUBLISHING_FILE_NAME}_${VAR_SYSDATE}_1.csv |

    Then I copy files below from remote folder "${publishDirectory}" on host "dmp.ssh.inbound" into local folder "${testdata.path}/outfiles/runtime":
      | ${PUBLISHING_FILE_NAME}_${VAR_SYSDATE}_1.csv |

  Scenario: Verify trade L1 performance file

    Then I expect each record in file "${testdata.path}/outfiles/testdata/ESI_L1_PERF_Expected_Addnl_Col_1.csv" should exist in file "${testdata.path}/outfiles/runtime/${PUBLISHING_FILE_NAME}_${VAR_SYSDATE}_1.csv" and exceptions to be written to "${testdata.path}/outfiles/runtime/Exceptions_${PUBLISHING_FILE_NAME}_${VAR_SYSDATE}.csv" file

  Scenario: Load BNP L1 performance file with 3 old records and 3 new records to test delta file publishing

    Given I copy files below from local folder "${testdata.path}/testdata" to the host "dmp.ssh.inbound" folder "${dmp.ssh.inbound.path}":
      | PERFL1SAMPLE2_Additional_Columns.csv |

    And I process files with below parameters and wait for the job to be completed
      | BUSINESS_FEED |                                      |
      | FILE_PATTERN  | PERFL1SAMPLE2_Additional_Columns.csv |
      | MESSAGE_TYPE  | EIS_MT_BNP_DWH_PERF_L1               |

    Then I extract new job id from jblg table into a variable "JOB_ID2"

    And I expect value of column "JBLG_ROW_COUNT" in the below SQL query equals to "1":
    """
      SELECT COUNT(1) AS JBLG_ROW_COUNT FROM FT_T_JBLG WHERE JOB_ID = '${JOB_ID2}' AND TASK_SUCCESS_CNT ='6'
    """

  Scenario: Perform checks in WCRI for delta scenario

    Then I expect value of column "WCRI_COUNT" in the below SQL query equals to "41":
    """
      SELECT COUNT(*) AS WCRI_COUNT
      FROM FT_T_WCRI WHERE ACCT_SOK = (select acct_sok from ft_t_wact where intrnl_id10 = 'TOM5178' and  DW_STATUS_NUM =1)  AND DW_STATUS_NUM =1
    """

  Scenario: Publish L1 Performance file for delta scenario

    Given I assign "ESI_L1_PERF_AD_02" to variable "PUBLISHING_FILE_NAME"
    And I assign "/dmp/out/coric" to variable "publishDirectory"
    And I generate value with date format "YYYYMMdd" and assign to variable "VAR_SYSDATE"
    And I remove below files with pattern in the host "dmp.ssh.inbound" from folder "${publishDirectory}" if exists:
      | ${PUBLISHING_FILE_NAME}_*.csv |

    When I process GSO_DWH publishing wrapper with below parameters and wait for the job to be completed
      | PUBLISHING_FILE_NAME        | ${PUBLISHING_FILE_NAME}.csv |
      | SUBSCRIPTION_NAME           | EIS_DMP_TO_CORIC_PER_L1     |
      | EXTRACT_STREETREF_TO_SUBMIT | false                       |

    Then I expect below files to be present in the host "dmp.ssh.inbound" into folder "${publishDirectory}" after processing:
      | ${PUBLISHING_FILE_NAME}_${VAR_SYSDATE}_1.csv |

    Then I copy files below from remote folder "${publishDirectory}" on host "dmp.ssh.inbound" into local folder "${testdata.path}/outfiles/runtime":
      | ${PUBLISHING_FILE_NAME}_${VAR_SYSDATE}_1.csv |

  Scenario: Verify trade L1 performance file for delta scenario

    Then I expect each record in file "${testdata.path}/outfiles/testdata/ESI_L1_PERF_Expected_Addnl_Col_2.csv" should exist in file "${testdata.path}/outfiles/runtime/${PUBLISHING_FILE_NAME}_${VAR_SYSDATE}_1.csv" and exceptions to be written to "${testdata.path}/outfiles/runtime/Exceptions_${PUBLISHING_FILE_NAME}_${VAR_SYSDATE}.csv" file

  Scenario: Load BNP L1 performance file to verify same record with update on next day is published & verify if record is published when sec benchmark is blank

    And I copy files below from local folder "${testdata.path}/testdata" to the host "dmp.ssh.inbound" folder "${dmp.ssh.inbound.path}":
      | PERFL1SAMPLE3_Additional_Columns.csv |

    And I process files with below parameters and wait for the job to be completed
      | BUSINESS_FEED |                                      |
      | FILE_PATTERN  | PERFL1SAMPLE3_Additional_Columns.csv |
      | MESSAGE_TYPE  | EIS_MT_BNP_DWH_PERF_L1               |

    Then I extract new job id from jblg table into a variable "JOB_ID3"

    And I expect value of column "JBLG_ROW_COUNT" in the below SQL query equals to "1":
    """
      SELECT COUNT(1) AS JBLG_ROW_COUNT FROM FT_T_JBLG WHERE JOB_ID = '${JOB_ID3}' AND TASK_SUCCESS_CNT ='2'
    """

  Scenario: Perform checks in WCRI for verifying same record with update on next day is published & verify if record is published when sec benchmark is blank

    Then I expect value of column "WCRI_COUNT" in the below SQL query equals to "44":
    """
      SELECT COUNT(*) AS WCRI_COUNT
      FROM FT_T_WCRI WHERE ACCT_SOK in (select acct_sok from ft_t_wact where intrnl_id10 in ('TOM5178','TOT5178') and  DW_STATUS_NUM =1)  AND DW_STATUS_NUM =1
    """

  Scenario: Publish L1 Performance file for verifying same record with update on next day is published & verify if record is published when sec benchmark is blank

    Given I assign "ESI_L1_PERF_AD_03" to variable "PUBLISHING_FILE_NAME"
    And I assign "/dmp/out/coric" to variable "publishDirectory"
    And I generate value with date format "YYYYMMdd" and assign to variable "VAR_SYSDATE"
    And I remove below files with pattern in the host "dmp.ssh.inbound" from folder "${publishDirectory}" if exists:
      | ${PUBLISHING_FILE_NAME}_*.csv |

    When I process GSO_DWH publishing wrapper with below parameters and wait for the job to be completed
      | PUBLISHING_FILE_NAME        | ${PUBLISHING_FILE_NAME}.csv |
      | SUBSCRIPTION_NAME           | EIS_DMP_TO_CORIC_PER_L1     |
      | EXTRACT_STREETREF_TO_SUBMIT | false                       |

    Then I expect below files to be present in the host "dmp.ssh.inbound" into folder "${publishDirectory}" after processing:
      | ${PUBLISHING_FILE_NAME}_${VAR_SYSDATE}_1.csv |

    Then I copy files below from remote folder "${publishDirectory}" on host "dmp.ssh.inbound" into local folder "${testdata.path}/outfiles/runtime":
      | ${PUBLISHING_FILE_NAME}_${VAR_SYSDATE}_1.csv |

  Scenario: Verify trade L1 performance file for verifying same record with update on next day is published

    Then I expect each record in file "${testdata.path}/outfiles/testdata/ESI_L1_PERF_Expected_Addnl_Col_3.csv" should exist in file "${testdata.path}/outfiles/runtime/${PUBLISHING_FILE_NAME}_${VAR_SYSDATE}_1.csv" and exceptions to be written to "${testdata.path}/outfiles/runtime/Exceptions_${PUBLISHING_FILE_NAME}_${VAR_SYSDATE}.csv" file