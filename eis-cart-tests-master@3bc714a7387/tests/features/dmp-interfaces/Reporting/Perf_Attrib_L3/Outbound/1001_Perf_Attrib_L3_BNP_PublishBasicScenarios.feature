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
@tom_5126 @perf_attrib_l3 @tom_5207 @dmp_gs_upgrade @eisdev_5525 @eisdev_5564 @perf_l1 @eisdev_7166 @eisdev_7323
Feature: Test BNP Attribution L3 file

  This is to test if BNP L3 Attribution file is getting loaded in DWH. Total 3 scenario are being tested as below:-
  1. Publish L3 Attribution for 1 record
  2. Publish L3 Attribution for 2 records, one of them record is modified record in previous file (delta testing)
  3. Publish L3 Attribution for 1 record, same record gets loaded with update on next day

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
      | PUBLISHING_FILE_NAME | ${PUBLISHING_FILE_NAME}.csv |
      | SUBSCRIPTION_NAME    | EIS_DMP_TO_CORIC_ATTRIB_L3  |
      | XML_SPLIT_NODENAME   | EISL3Attrib                 |
      | PUBLISHING_BULK_SIZE | 1                           |

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

  Scenario: Load BNP L3 performance file

    Given I copy files below from local folder "${testdata.path}/testdata" to the host "dmp.ssh.inbound" folder "${dmp.ssh.inbound.path}":
      | PERF_ATTRIB_L3_SAMPLE1.csv |

    And I process files with below parameters and wait for the job to be completed
      | BUSINESS_FEED |                               |
      | FILE_PATTERN  | PERF_ATTRIB_L3_SAMPLE1.csv    |
      | MESSAGE_TYPE  | EIS_MT_BNP_DWH_PERF_ATTRIB_L3 |

    Then I extract new job id from jblg table into a variable "JOB_ID"

    And I expect value of column "JBLG_ROW_COUNT" in the below SQL query equals to "1":
    """
      SELECT COUNT(1) AS JBLG_ROW_COUNT FROM FT_T_JBLG WHERE JOB_ID = '${JOB_ID}' AND TASK_SUCCESS_CNT ='1'
    """

  Scenario: Perform checks in WPEA for multiple scenarios for account returns

    Then I expect value of column "WPEA_COUNT" in the below SQL query equals to "1":
    """
      SELECT COUNT(*) AS WPEA_COUNT
      FROM FT_T_WPEA WHERE ACCT_SOK_1 = (select acct_sok from ft_t_wact where intrnl_id10 = 'T5126' and  DW_STATUS_NUM =1)
      and DW_STATUS_NUM =1
    """

  Scenario: Publish L3 Attribution file for 1 record

    Given I set the DMP workflow web service endpoint to named configuration "dwh.ws.WORKFLOW"
    And I set the database connection to configuration "dmp.db.DW"
    And I assign "ESI_L3_ATTRIB_01" to variable "PUBLISHING_FILE_NAME"
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

  Scenario: Verify trade L3 attribution file

    Then I expect each record in file "${testdata.path}/outfiles/testdata/ESI_L3_ATTRIB_Expected_1.csv" should exist in file "${testdata.path}/outfiles/runtime/${PUBLISHING_FILE_NAME}_${VAR_SYSDATE}_1.csv" and exceptions to be written to "${testdata.path}/outfiles/runtime/Exceptions_${PUBLISHING_FILE_NAME}_${VAR_SYSDATE}.csv" file

  Scenario: Load BNP L3 attribution file to test delta file publishing

    Given I copy files below from local folder "${testdata.path}/testdata" to the host "dmp.ssh.inbound" folder "${dmp.ssh.inbound.path}":
      | PERF_ATTRIB_L3_SAMPLE2.csv |

    And I process files with below parameters and wait for the job to be completed
      | BUSINESS_FEED |                               |
      | FILE_PATTERN  | PERF_ATTRIB_L3_SAMPLE2.csv    |
      | MESSAGE_TYPE  | EIS_MT_BNP_DWH_PERF_ATTRIB_L3 |

    Then I extract new job id from jblg table into a variable "JOB_ID2"

    And I expect value of column "JBLG_ROW_COUNT" in the below SQL query equals to "1":
    """
      SELECT COUNT(1) AS JBLG_ROW_COUNT FROM FT_T_JBLG WHERE JOB_ID = '${JOB_ID2}' AND TASK_SUCCESS_CNT ='2'
    """

  Scenario: Perform checks in WPEA for delta scenario

    Then I expect value of column "WPEA_COUNT" in the below SQL query equals to "2":
    """
      SELECT COUNT(*) AS WPEA_COUNT
      FROM FT_T_WPEA WHERE ACCT_SOK_1 = (select acct_sok from ft_t_wact where intrnl_id10 = 'T5126' and  DW_STATUS_NUM =1)
      and DW_STATUS_NUM =1
    """

  Scenario: Publish L3 Attribution file for delta scenario

    Given I assign "ESI_L3_ATTRIB_02" to variable "PUBLISHING_FILE_NAME"
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

  Scenario: Verify L3 attribution file for delta scenario

    Then I expect each record in file "${testdata.path}/outfiles/testdata/ESI_L3_ATTRIB_Expected_2.csv" should exist in file "${testdata.path}/outfiles/runtime/${PUBLISHING_FILE_NAME}_${VAR_SYSDATE}_1.csv" and exceptions to be written to "${testdata.path}/outfiles/runtime/Exceptions_${PUBLISHING_FILE_NAME}_${VAR_SYSDATE}.csv" file

  Scenario: Load BNP L3 attribution file to verify same record gets loaded with update on next day

    Given I copy files below from local folder "${testdata.path}/testdata" to the host "dmp.ssh.inbound" folder "${dmp.ssh.inbound.path}":
      | PERF_ATTRIB_L3_SAMPLE3.csv |

    And I process files with below parameters and wait for the job to be completed
      | BUSINESS_FEED |                               |
      | FILE_PATTERN  | PERF_ATTRIB_L3_SAMPLE3.csv    |
      | MESSAGE_TYPE  | EIS_MT_BNP_DWH_PERF_ATTRIB_L3 |

    Then I extract new job id from jblg table into a variable "JOB_ID3"

    And I expect value of column "JBLG_ROW_COUNT" in the below SQL query equals to "1":
    """
      SELECT COUNT(1) AS JBLG_ROW_COUNT FROM FT_T_JBLG WHERE JOB_ID = '${JOB_ID3}' AND TASK_SUCCESS_CNT ='1'
    """

  Scenario: Perform checks in WPEA for verifying same record gets loaded with update on next day

    Then I expect value of column "WPEA_COUNT" in the below SQL query equals to "2":
    """
      SELECT COUNT(*) AS WPEA_COUNT
      FROM FT_T_WPEA WHERE ACCT_SOK_1 = (select acct_sok from ft_t_wact where intrnl_id10 = 'T5126' and  DW_STATUS_NUM =1)
      and DW_STATUS_NUM =1
    """

  Scenario: Publish L3 Attribution file for verifying same record gets loaded with update on next day

    Given I assign "ESI_L3_ATTRIB_03" to variable "PUBLISHING_FILE_NAME"
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

  Scenario: Verify L3 attribution file for same record gets loaded with update on next day

    Then I expect each record in file "${testdata.path}/outfiles/testdata/ESI_L3_ATTRIB_Expected_3.csv" should exist in file "${testdata.path}/outfiles/runtime/${PUBLISHING_FILE_NAME}_${VAR_SYSDATE}_1.csv" and exceptions to be written to "${testdata.path}/outfiles/runtime/Exceptions_${PUBLISHING_FILE_NAME}_${VAR_SYSDATE}.csv" file