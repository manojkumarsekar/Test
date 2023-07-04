#https://collaborate.intranet.asia/display/TOMTN/Share+Class+NAV+from+FA#businessRequirements-dataRequirement
#https://jira.intranet.asia/browse/TOM-4297
#https://jira.pruconnect.net/browse/EISDEV-7016 - Added FINR Insert for SBINVMGR

@gc_interface_nav @gc_interface_prices
@dmp_regression_integrationtest  @eisdev_7373
@dmp_taiwan
@tom_4297 @taiwan_hsbc_nav_file365 @tom_5270
@eisdev_7016

Feature: Load HSBC NAV Price from Fund Admin(HSBC) to DMP with SITCA id and publish BRS file 365 for share class of SITCA id to calculate hedge ratio in Aladdin

  Taiwan's fund admin banks sent EOD HSBC NAV to EIS. The statements are loaded into BRS via DMP.
  Expected Result: a) HSBC NAV price should get loaded without any issue/Exception (Check in JBLG)
  b) All the data HSBC Nav file should publish into BRS file 365

  Scenario: TC1: Clear old test data and setup variables

    Given I assign "tests/test-data/dmp-interfaces/Taiwan/HSBCNav-file365" to variable "testdata.path"
    And I assign "hsbc_nav_day1_template.csv" to variable "INPUT_FILENAME_DAY1_TEMPLATE"
    And I assign "hsbc_nav_Day1.csv" to variable "INPUT_FILENAME_DAY1"
    And I assign "hsbc_nav_day2_template.csv" to variable "INPUT_FILENAME_DAY2_TEMPLATE"
    And I assign "hsbc_nav_day2.csv" to variable "INPUT_FILENAME_DAY2"
    And I assign "File365_ExpectedOutput1.csv" to variable "OUTPUT_DAY1_TEMPLATE"
    And I assign "File365_Day1_Output.csv" to variable "OUTPUT_FILENAME_DAY1"
    And I assign "File365_ExpectedOutput2.csv" to variable "OUTPUT_DAY2_TEMPLATE"
    And I assign "File365_Day2_Output.csv" to variable "OUTPUT_FILENAME_DAY2"
    And I assign "/dmp/out/brs/eod" to variable "PUBLISHING_DIRECTORY"
    And I assign "Hsbc_Nav_to_File365_ShareClassPortfolio" to variable "PUBLISHING_FILE_NAME"
    And I generate value with date format "YYYYMMdd" and assign to variable "VAR_SYSDATE"
    And I generate value with date format "YYYYMMdd-HHMMSS" and assign to variable "EXT_ID"

    #FINR Insert for SBINVMGR
    And I execute below query
      """
      ${testdata.path}/sql/FINR_Insert.sql
      """

    And I assign "PortfolioTemplate.xlsx" to variable "INPUT_FILENAME_PORTFOLIO"

    When I copy files below from local folder "${testdata.path}/infiles/prerequisite" to the host "dmp.ssh.inbound" folder "${dmp.ssh.inbound.path}":
      | ${INPUT_FILENAME_PORTFOLIO} |

    And I process files with below parameters and wait for the job to be completed
      | BUSINESS_FEED |                                      |
      | FILE_PATTERN  | ${INPUT_FILENAME_PORTFOLIO}          |
      | MESSAGE_TYPE  | EIS_MT_RDM_PORTFOLIO_MASTER_TEMPLATE |

    Then I extract new job id from jblg table into a variable "JOB_ID1"

    And I expect value of column "JBLG_ROW_COUNT" in the below SQL query equals to "1":
      """
      SELECT count(*) as JBLG_ROW_COUNT FROM FT_T_JBLG WHERE JOB_ID = '${JOB_ID1}' and TASK_SUCCESS_CNT ='15'
      """

    And I assign "TSTTT56_TWD" to variable "SHARE_PORTFOLIO_NAME"

    And I execute below query and extract values of "SYSTEM_DATE" into same variables
      """
      SELECT TO_CHAR(SYSDATE,'DD/MM/YYYY') AS SYSTEM_DATE FROM DUAL
      """

    #Clear old HSBC NAV data from ACCV table
    And I execute below query
      """
      ${testdata.path}/sql/ClearData_HsbcNav.sql
      """

    And I modify date "${SYSTEM_DATE}" with "-1d" from source format "dd/MM/yyyy" to destination format "yyyy/MM/dd" and assign to "SYSDATE_MINUS_1"
    And I modify date "${SYSTEM_DATE}" with "-2d" from source format "dd/MM/yyyy" to destination format "yyyy/MM/dd" and assign to "SYSDATE_MINUS_2"

    And I modify date "${SYSTEM_DATE}" with "-1d" from source format "dd/MM/yyyy" to destination format "yyyyMMdd" and assign to "SYSDATEMINUS_1"
    And I modify date "${SYSTEM_DATE}" with "-2d" from source format "dd/MM/yyyy" to destination format "yyyyMMdd" and assign to "SYSDATEMINUS_2"

    And I create input file "${INPUT_FILENAME_DAY1}" using template "${INPUT_FILENAME_DAY1_TEMPLATE}" with below codes from location "${testdata.path}/infiles"
      |  |  |
    And I create input file "${INPUT_FILENAME_DAY2}" using template "${INPUT_FILENAME_DAY2_TEMPLATE}" with below codes from location "${testdata.path}/infiles"
      |  |  |
    And I create input file "${OUTPUT_FILENAME_DAY1}" using template "${OUTPUT_DAY1_TEMPLATE}" with below codes from location "${testdata.path}/outfiles"
      |  |  |
    And I create input file "${OUTPUT_FILENAME_DAY2}" using template "${OUTPUT_DAY2_TEMPLATE}" with below codes from location "${testdata.path}/outfiles"
      |  |  |

  Scenario: TC2: Load HSBC NAV file for Share Class for Day 1 and check file365 generated as per requirement

    Given I copy files below from local folder "${testdata.path}/infiles/testdata" to the host "dmp.ssh.inbound" folder "${dmp.ssh.inbound.path}":
      | ${INPUT_FILENAME_DAY1} |

    When I process files with below parameters and wait for the job to be completed
      | BUSINESS_FEED |                        |
      | FILE_PATTERN  | ${INPUT_FILENAME_DAY1} |
      | MESSAGE_TYPE  | EITW_MT_HSBC_NAV_PRICE |

    Given I remove below files with pattern in the host "dmp.ssh.inbound" from folder "${PUBLISHING_DIRECTORY}" if exists:
      | ${PUBLISHING_FILE_NAME}_*.csv |

    When I process publishing wrapper with below parameters and wait for the job to be completed
      | PUBLISHING_FILE_NAME | ${PUBLISHING_FILE_NAME}.csv         |
      | SUBSCRIPTION_NAME    | EITW_DMP_TO_BRS_HSBC_EOD_NAV_B1_SUB |

    And I expect below files to be present in the host "dmp.ssh.inbound" into folder "${PUBLISHING_DIRECTORY}" after processing:
      | ${PUBLISHING_FILE_NAME}_${VAR_SYSDATE}_1.csv |

    And I copy files below from remote folder "${PUBLISHING_DIRECTORY}" on host "dmp.ssh.inbound" into local folder "${testdata.path}/outfiles/runtime":
      | ${PUBLISHING_FILE_NAME}_${VAR_SYSDATE}_1.csv |

    Then I expect all records in file "${testdata.path}/outfiles/testdata/${OUTPUT_FILENAME_DAY1}" should exist in file "${testdata.path}/outfiles/runtime/${PUBLISHING_FILE_NAME}_${VAR_SYSDATE}_1.csv" with same order and exceptions to be written to "${testdata.path}/outfiles/runtime/${PUBLISHING_FILE_NAME}_${VAR_SYSDATE}_TC2_exceptions.csv" file

  Scenario: TC3: Load HSBC NAV file for Share Class for Day 2 and check file365 generated as per requirement

    And I assign "Hsbc_Nav_to_File365_ShareClassPortfolio_DAY2" to variable "PUBLISHING_FILE_NAME"

    Given I copy files below from local folder "${testdata.path}/infiles/testdata" to the host "dmp.ssh.inbound" folder "${dmp.ssh.inbound.path}":
      | ${INPUT_FILENAME_DAY2} |

    When I process files with below parameters and wait for the job to be completed
      | BUSINESS_FEED |                        |
      | FILE_PATTERN  | ${INPUT_FILENAME_DAY2} |
      | MESSAGE_TYPE  | EITW_MT_HSBC_NAV_PRICE |

    Given I remove below files with pattern in the host "dmp.ssh.inbound" from folder "${PUBLISHING_DIRECTORY}" if exists:
      | ${PUBLISHING_FILE_NAME}_*.csv |

    When I process publishing wrapper with below parameters and wait for the job to be completed
      | PUBLISHING_FILE_NAME | ${PUBLISHING_FILE_NAME}.csv         |
      | SUBSCRIPTION_NAME    | EITW_DMP_TO_BRS_HSBC_EOD_NAV_B1_SUB |

    And I expect below files to be present in the host "dmp.ssh.inbound" into folder "${PUBLISHING_DIRECTORY}" after processing:
      | ${PUBLISHING_FILE_NAME}_${VAR_SYSDATE}_1.csv |

    And I copy files below from remote folder "${PUBLISHING_DIRECTORY}" on host "dmp.ssh.inbound" into local folder "${testdata.path}/outfiles/runtime":
      | ${PUBLISHING_FILE_NAME}_${VAR_SYSDATE}_1.csv |

    Then I expect all records in file "${testdata.path}/outfiles/testdata/${OUTPUT_FILENAME_DAY2}" should exist in file "${testdata.path}/outfiles/runtime/${PUBLISHING_FILE_NAME}_${VAR_SYSDATE}_1.csv" with same order and exceptions to be written to "${testdata.path}/outfiles/runtime/${PUBLISHING_FILE_NAME}_${VAR_SYSDATE}_TC2_exceptions.csv" file