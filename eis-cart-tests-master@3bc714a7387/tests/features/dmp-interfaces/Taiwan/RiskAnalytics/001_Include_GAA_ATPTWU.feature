#https://jira.intranet.asia/browse/TOM-4706 (Include GAA_ATPTWU in the esi_bnp_drifted_bmk_weights_YYYYMMDD.csv file)
#https://jira.pruconnect.net/browse/EISDEV-5424 - This ticket is used for regression fix in master. we have provide the filter on FT_T_NTEL table to check if there is any failure in GC or not.
#https://jira.pruconnect.net/browse/EISDEV-5491 - This ticket is to add  AA-ISHIHYU (BES2ZYTK7) was added to drifted Benchmark GAA_ATPTWU

@gc_interface_securities @gc_interface_risk_analytics @gc_interface_benchmark
@dmp_regression_integrationtest
@dmp_taiwan
@tom_4706 @eisdev_5491 @tom_5424
Feature: Loading Risk Analytics file to include GAA_ in drifted benchmark

  Scenario: TC_1: Load F10

    Given I assign "BES0N2U06.xml" to variable "INPUT_FILENAME_1"
    And I assign "BES0KEU45.xml" to variable "INPUT_FILENAME_2"
    And I assign "BRT7W2MT7.xml" to variable "INPUT_FILENAME_3"
    And I assign "BRTFD6KX4.xml" to variable "INPUT_FILENAME_4"
    And I assign "BRTFD6J99.xml" to variable "INPUT_FILENAME_5"
    And I assign "RiskAnanlytics_GAA.xml" to variable "INPUT_FILENAME_6"
    And I assign "BRSCVDXZ8.xml" to variable "INPUT_FILENAME_7"
    And I assign "RiskAnanlytics_GAA_Template.xml" to variable "INPUT_TEMPLATENAME"
    And I generate value with date format "ddMMYYYY" and assign to variable "VAR_SYSDATE"
    And I assign "tests/test-data/dmp-interfaces/Taiwan/RiskAnalytics" to variable "testdata.path"

    And I execute below query to "Clear data for the given PRICE for FT_T_ISPC Table"
    """
    ${testdata.path}/sql/4706_InsertBenchmark.sql
    """

    And I modify date "${VAR_SYSDATE}" with "-1d" from source format "ddMMYYYY" to destination format "MM/dd/YYYY" and assign to "DYNAMIC_DATE"
    And I create input file "${INPUT_FILENAME_6}" using template "${INPUT_TEMPLATENAME}" from location "${testdata.path}/inputfiles"

  Scenario: TC_3: Load security file

    When I copy files below from local folder "${testdata.path}/inputfiles/testdata" to the host "dmp.ssh.inbound" folder "${dmp.ssh.inbound.path}":
      | ${INPUT_FILENAME_1} |
      | ${INPUT_FILENAME_2} |
      | ${INPUT_FILENAME_3} |
      | ${INPUT_FILENAME_4} |
      | ${INPUT_FILENAME_5} |
      | ${INPUT_FILENAME_6} |
      | ${INPUT_FILENAME_7} |

    Given I process files with below parameters and wait for the job to be completed
      | BUSINESS_FEED |                         |
      | FILE_PATTERN  | ${INPUT_FILENAME_1}     |
      | MESSAGE_TYPE  | EIS_MT_BRS_SECURITY_NEW |

    Then I extract new job id from jblg table into a variable "JOB_ID"

    Then I expect value of column "NTEL_COUNT" in the below SQL query equals to "0":
      """
       SELECT COUNT(*) AS NTEL_COUNT FROM FT_T_NTEL WHERE LAST_CHG_TRN_ID IN
      (SELECT TRN_ID FROM Ft_T_TRID WHERE JOB_ID = '${JOB_ID}')
       AND SOURCE_ID LIKE '%GS_GC%'
       AND NOTFCN_STAT_TYP ='OPEN'
      """

    Given I process files with below parameters and wait for the job to be completed
      | BUSINESS_FEED |                         |
      | FILE_PATTERN  | ${INPUT_FILENAME_2}     |
      | MESSAGE_TYPE  | EIS_MT_BRS_SECURITY_NEW |

    #Verification of successful File load INPUT_SECURITY_FILENAME2
    Then I expect workflow is processed in DMP with total record count as "1"
    And completed record count as "1"

    Given I process files with below parameters and wait for the job to be completed
      | BUSINESS_FEED |                         |
      | FILE_PATTERN  | ${INPUT_FILENAME_3}     |
      | MESSAGE_TYPE  | EIS_MT_BRS_SECURITY_NEW |

    Then I extract new job id from jblg table into a variable "JOB_ID"

    Then I expect value of column "NTEL_COUNT" in the below SQL query equals to "0":
      """
      SELECT COUNT(*) AS NTEL_COUNT FROM FT_T_NTEL WHERE LAST_CHG_TRN_ID IN
      (SELECT TRN_ID FROM Ft_T_TRID WHERE JOB_ID = '${JOB_ID}')
       AND SOURCE_ID LIKE '%GS_GC%'
       AND NOTFCN_STAT_TYP ='OPEN'
       AND MSG_SEVERITY_CDE > 30
      """

    Given I process files with below parameters and wait for the job to be completed
      | BUSINESS_FEED |                         |
      | FILE_PATTERN  | ${INPUT_FILENAME_4}     |
      | MESSAGE_TYPE  | EIS_MT_BRS_SECURITY_NEW |

    Then I extract new job id from jblg table into a variable "JOB_ID"

    Then I expect value of column "NTEL_COUNT" in the below SQL query equals to "0":
      """
       SELECT COUNT(*) AS NTEL_COUNT FROM FT_T_NTEL WHERE LAST_CHG_TRN_ID IN
      (SELECT TRN_ID FROM Ft_T_TRID WHERE JOB_ID = '${JOB_ID}')
       AND SOURCE_ID LIKE '%GS_GC%'
       AND NOTFCN_STAT_TYP ='OPEN'
       AND MSG_SEVERITY_CDE > 30
      """

    Given I process files with below parameters and wait for the job to be completed
      | BUSINESS_FEED |                         |
      | FILE_PATTERN  | ${INPUT_FILENAME_5}     |
      | MESSAGE_TYPE  | EIS_MT_BRS_SECURITY_NEW |

    Then I extract new job id from jblg table into a variable "JOB_ID"

    Then I expect value of column "NTEL_COUNT" in the below SQL query equals to "0":
      """
      SELECT COUNT(*) AS NTEL_COUNT FROM FT_T_NTEL WHERE LAST_CHG_TRN_ID IN
      (SELECT TRN_ID FROM Ft_T_TRID WHERE JOB_ID = '${JOB_ID}')
       AND SOURCE_ID LIKE '%GS_GC%'
       AND NOTFCN_STAT_TYP ='OPEN'
       AND MSG_SEVERITY_CDE > 30
      """

    Given I process files with below parameters and wait for the job to be completed
      | BUSINESS_FEED |                         |
      | FILE_PATTERN  | ${INPUT_FILENAME_7}     |
      | MESSAGE_TYPE  | EIS_MT_BRS_SECURITY_NEW |

    Then I extract new job id from jblg table into a variable "JOB_ID"

    Then I expect value of column "NTEL_COUNT" in the below SQL query equals to "0":
      """
      SELECT COUNT(*) AS NTEL_COUNT FROM FT_T_NTEL WHERE LAST_CHG_TRN_ID IN
      (SELECT TRN_ID FROM Ft_T_TRID WHERE JOB_ID = '${JOB_ID}')
       AND SOURCE_ID LIKE '%GS_GC%'
       AND NOTFCN_STAT_TYP ='OPEN'
       AND MSG_SEVERITY_CDE > 30
      """


  Scenario: TC_4: Load RiskAnalytics

    Given I process files with below parameters and wait for the job to be completed
      | BUSINESS_FEED |                           |
      | FILE_PATTERN  | ${INPUT_FILENAME_6}       |
      | MESSAGE_TYPE  | EIS_MT_BRS_RISK_ANALYTICS |

   #Verification of successful File load INPUT_FILENAME6
    Then I expect workflow is processed in DMP with total record count as "7"
    And completed record count as "7"


  Scenario: TC_5: Publish Drifted BM

    Given I assign "DriftedBM" to variable "PUBLISHING_FILE_NAME"
    And I generate value with date format "YYYYMMdd" and assign to variable "VAR_SYSDATE"
    And I assign "/dmp/out/bnp/eod" to variable "PUBLISHING_DIR"

    And I remove below files in the host "dmp.ssh.inbound" from folder "${PUBLISHING_DIR}" if exists:
      | ${PUBLISHING_FILE_NAME}_${VAR_SYSDATE}_1.csv |

    When I process publishing wrapper with below parameters and wait for the job to be completed
      | PUBLISHING_FILE_NAME | ${PUBLISHING_FILE_NAME}.csv                                                                                                 |
      | SUBSCRIPTION_NAME    | EIS_DMP_TO_BNP_DRIFTED_BM_WEIGHTS_SUB                                                                                       |
      | SQL                  | &lt;sql&gt; BNCH_OID IN(SELECT BNCH_OID FROM FT_T_BNID WHERE BNCHMRK_ID IN ('GAA_ATPTWU') AND END_TMS IS NULL) &lt;/sql&gt; |

    Then I expect below files to be present in the host "dmp.ssh.inbound" into folder "${PUBLISHING_DIR}" after processing:
      | ${PUBLISHING_FILE_NAME}_${VAR_SYSDATE}_1.csv |

    Then I copy files below from remote folder "${PUBLISHING_DIR}" on host "dmp.ssh.inbound" into local folder "tests/test-data/dmp-interfaces/Taiwan/RiskAnalytics/outfiles":
      | ${PUBLISHING_FILE_NAME}_${VAR_SYSDATE}_1.csv |

  Scenario: TC_6: Check the drfited BM file

    Given I assign "${testdata.path}/outfiles/${PUBLISHING_FILE_NAME}_${VAR_SYSDATE}_1.csv" to variable "CSV_FILE"

    #verification of file published
    Then I expect column "FUND CODE" values in the CSV file "${CSV_FILE}" should be "ATPTWU"
    And I expect column "BENCHMARK CODE" values in the CSV file "${CSV_FILE}" should be "GAA_ATPTWU"
