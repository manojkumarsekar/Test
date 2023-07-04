#https://jira.intranet.asia/browse/TOM-5207
#https://collaborate.intranet.asia/display/TOM/Attribution+Data+Marts+-+New
#https://collaborate.intranet.asia/pages/viewpage.action?spaceKey=TOMR4&title=Outbound+Data+Mapping+%3A-+L3+Attribution

# ===================================================================================================================================================================================
# Date            JIRA        Comments
# ===================================================================================================================================================================================
# 09/09/2019      TOM-4971    Development - BNP Performance L3 file Load
# 04/02/2020      EISDEV-5225  Date format changes in input file and field name changes
# 27/02/2020      EISDEV-5564  Active Return(local) and Active Contribution field mappings
# 14/07/2020      EISDEV-6591  As part of this JIRA, OOB Patch MT 31 has been updated. Adding jira tag to ensure this ff is working as part of the upgrade
# 19/11/2020      EISDEV-7166  Input Layout Changes for BNP L1 file for 37 columns
# 15/01/2021      EISDEV-7323  Change in date format for L1 files
# ===================================================================================================================================================================================

@dw_interface_performance
@dmp_dw_regression
@tom_5207 @perf_attrib_l3 @eisdev_5525 @eisdev_5564 @eisdev_6591 @perf_l1 @eisdev_7166 @eisdev_7323
Feature: Test BNP Attribution L3 file to check if portfolio's are filtered and comma issue

  This is to test published BNP L3 Attribution file to check portfolio's are filtered out based on IMName field in coming in L1 file.
  Below are the steps followed:
  1. Load L1 file with 5 records for one account(TOM5207) having IM Name = 'Eastspring (S) & (HK)' and 1 record for another account(WPWC5207) not having IM Name = 'Eastspring (S) & (HK)'
  2. Load L3 file with 2 records for account -TOM5207 , account - WPWC5207 and account - WP5207 each
  3. Publish L3 Attribution - This will give 2 records for for account -TOM5207
  account - WPWC5207 - filtered out as IM Name != 'Eastspring (S) & (HK)' in L1 file for same account
  account - WP5207 - filtered out as this portfolio was not present in L1 file loaded

  Bugfix - This is also to test that the record having comma in any of the fields in L3 file is published as it is coming in file

  Background:

    Given I set the DMP workflow web service endpoint to named configuration "dwh.ws.WORKFLOW"
    And I set the database connection to configuration "dmp.db.DW"
    And I generate value with date format "YYYYMMdd-HHmmss" and assign to variable "UPDATE_VAR_SYSDATE"

  Scenario: Clear old test data and setup variables

    Given I assign "tests/test-data/dmp-interfaces/Reporting/Perf_Attrib_L3/Outbound" to variable "testdata.path"

    #In order to make feature file re-runnable, existing L1 & L3 fund attribution & related data is cleaned up
    # Account and Benchmark are created
    And I execute below query
    """
     ${testdata.path}/sql/1002_AccountBMSetup.sql
    """

  Scenario: Publish L3 Attribution backlog file and remove it

    Given I assign "ESI_L3_ATTRIB_00" to variable "PUBLISHING_FILE_NAME"
    And I assign "/dmp/out/coric" to variable "publishDirectory"
    And I generate value with date format "YYYYMMdd" and assign to variable "VAR_SYSDATE"
    And I remove below files with pattern in the host "dmp.ssh.inbound" from folder "${publishDirectory}" if exists:
      | ${PUBLISHING_FILE_NAME}_*.csv |

    When I process GSO_DWH publishing wrapper with below parameters and wait for the job to be completed
      | PUBLISHING_FILE_NAME | ${PUBLISHING_FILE_NAME}.csv |
      | SUBSCRIPTION_NAME    | EIS_DMP_TO_CORIC_ATTRIB_L3  |
      | XML_SPLIT_NODENAME   | EISL3Attrib                 |
      | PUBLISHING_BULK_SIZE | 1                           |

    And I remove below files with pattern in the host "dmp.ssh.inbound" from folder "${publishDirectory}" if exists:
      | ${PUBLISHING_FILE_NAME}_*.csv |

  Scenario: Load BNP L1 performance file

    Given I copy files below from local folder "${testdata.path}/testdata" to the host "dmp.ssh.inbound" folder "${dmp.ssh.inbound.path}":
      | 002_PERFL1.csv |

    And I process files with below parameters and wait for the job to be completed
      | BUSINESS_FEED |                        |
      | FILE_PATTERN  | 002_PERFL1.csv         |
      | MESSAGE_TYPE  | EIS_MT_BNP_DWH_PERF_L1 |

    Then I extract new job id from jblg table into a variable "JOB_ID"

    And I expect value of column "JBLG_ROW_COUNT" in the below SQL query equals to "1":
    """
      SELECT COUNT(1) AS JBLG_ROW_COUNT FROM FT_T_JBLG WHERE JOB_ID = '${JOB_ID}' AND TASK_SUCCESS_CNT ='6'
    """

  Scenario: Perform checks in WCRI for accounts loaded

    Then I expect value of column "WCRI_COUNT" in the below SQL query equals to "14":
    """
      SELECT COUNT(*) AS WCRI_COUNT
      FROM FT_T_WCRI WHERE ACCT_SOK = (select acct_sok from ft_t_wact where intrnl_id10 = 'TOM5207' and  DW_STATUS_NUM =1) AND DW_STATUS_NUM =1
    """

    Then I expect value of column "WCRI_COUNT" in the below SQL query equals to "3":
    """
      SELECT COUNT(*) AS WCRI_COUNT
      FROM FT_T_WCRI WHERE ACCT_SOK = (select acct_sok from ft_t_wact where intrnl_id10 = 'WPWC5207' and  DW_STATUS_NUM =1) AND DW_STATUS_NUM =1
    """

  Scenario: Load BNP L3 performance file

    Given I copy files below from local folder "${testdata.path}/testdata" to the host "dmp.ssh.inbound" folder "${dmp.ssh.inbound.path}":
      | 002_PERF_ATTRIB_L3.csv |

    And I process files with below parameters and wait for the job to be completed
      | BUSINESS_FEED |                               |
      | FILE_PATTERN  | 002_PERF_ATTRIB_L3.csv        |
      | MESSAGE_TYPE  | EIS_MT_BNP_DWH_PERF_ATTRIB_L3 |

    Then I extract new job id from jblg table into a variable "JOB_ID"

    And I expect value of column "JBLG_ROW_COUNT" in the below SQL query equals to "1":
    """
      SELECT COUNT(1) AS JBLG_ROW_COUNT FROM FT_T_JBLG WHERE JOB_ID = '${JOB_ID}' AND TASK_SUCCESS_CNT ='6'
    """

  Scenario: Perform checks in WPEA for all accounts loaded

    Then I expect value of column "WPEA_COUNT" in the below SQL query equals to "2":
    """
      SELECT COUNT(*) AS WPEA_COUNT
      FROM FT_T_WPEA WHERE ACCT_SOK_1 = (select acct_sok from ft_t_wact where intrnl_id10 = 'TOM5207' and  DW_STATUS_NUM =1)
      and DW_STATUS_NUM =1
    """

    Then I expect value of column "WPEA_COUNT" in the below SQL query equals to "2":
    """
      SELECT COUNT(*) AS WPEA_COUNT
      FROM FT_T_WPEA WHERE ACCT_SOK_1 = (select acct_sok from ft_t_wact where intrnl_id10 = 'WP5207' and  DW_STATUS_NUM =1)
      and DW_STATUS_NUM =1
    """

    Then I expect value of column "WPEA_COUNT" in the below SQL query equals to "2":
    """
      SELECT COUNT(*) AS WPEA_COUNT
      FROM FT_T_WPEA WHERE ACCT_SOK_1 = (select acct_sok from ft_t_wact where intrnl_id10 = 'WPWC5207' and  DW_STATUS_NUM =1)
      and DW_STATUS_NUM =1
    """

  Scenario: Publish L3 Attribution file

    Given I assign "002_ESI_L3_ATTRIB" to variable "PUBLISHING_FILE_NAME"
    And I assign "/dmp/out/coric" to variable "publishDirectory"
    And I generate value with date format "YYYYMMdd" and assign to variable "VAR_SYSDATE"
    And I remove below files with pattern in the host "dmp.ssh.inbound" from folder "${publishDirectory}" if exists:
      | ${PUBLISHING_FILE_NAME}_*.csv |

    When I process GSO_DWH publishing wrapper with below parameters and wait for the job to be completed
      | PUBLISHING_FILE_NAME | ${PUBLISHING_FILE_NAME}.csv |
      | SUBSCRIPTION_NAME    | EIS_DMP_TO_CORIC_ATTRIB_L3  |
      | XML_SPLIT_NODENAME   | EISL3Attrib                 |
      | PUBLISHING_BULK_SIZE | 1                           |

    Then I expect below files to be present in the host "dmp.ssh.inbound" into folder "${publishDirectory}" after processing:
      | ${PUBLISHING_FILE_NAME}_${VAR_SYSDATE}_1.csv |

    Then I copy files below from remote folder "${publishDirectory}" on host "dmp.ssh.inbound" into local folder "${testdata.path}/outfiles/runtime":
      | ${PUBLISHING_FILE_NAME}_${VAR_SYSDATE}_1.csv |

  Scenario: Verify published L3 attribution file

    Then I expect each record in file "${testdata.path}/outfiles/testdata/002_ESI_L3_ATTRIB_Expected.csv" should exist in file "${testdata.path}/outfiles/runtime/${PUBLISHING_FILE_NAME}_${VAR_SYSDATE}_1.csv" and exceptions to be written to "${testdata.path}/outfiles/runtime/Exceptions_${PUBLISHING_FILE_NAME}_${VAR_SYSDATE}.csv" file
