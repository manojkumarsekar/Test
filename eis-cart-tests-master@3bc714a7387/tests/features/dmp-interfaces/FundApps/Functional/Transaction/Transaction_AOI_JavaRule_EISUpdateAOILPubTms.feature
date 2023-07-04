#https://jira.intranet.asia/browse/EISDEV-5325
#https://collaborate.pruconnect.net/pages/viewpage.action?spaceKey=EISTOMR4&title=Rule+to+update+AOIL.PUB_TMS+to+SYSDATE+for+configured+Message+Classifications

@dmp_fundapps_functional @dmp_fundapps_transaction_eisupdateaoilpubtms @eisdev_5325
Feature: FundApps | Transaction | AOI Java Rule EISUpdateAOILPubTms

  1) Load EOD File with Transaction T1
  Expected Result : Data Should be successfully loaded - Rule Processing Skipped as SEGPROCESSEDIND = C

  2) Load Intraday File with Transaction T2 - Touch Count 1
  Expected Result : Data Should be successfully loaded - Rule Processing Skipped as Message Type is not configured

  3) Extact FundApps Transaction File
  Expected Result : Only T1 Transaction should be extracted - AOIL Status Should be set to PUBLISHED for T1 and AOIPROCESSED for T2 for AOFI AOI_EISExecutedTransactionFundApps_Economics

  4) Extact Data Report
  Expected Result : Only T1 Transaction should be extracted - AOIL Status Should be set to PUBLISHED for T1 and AOIPROCESSED for T2 for AOFI AOI_EISExecutedTransactionDataReport_Economics

  5) Load EOD File with Transaction T2
  Expected Result : Data Should be successfully loaded - Rule Processing should be invoked. AOIL.PUB_TMS and LAST_CHG_USR_ID for T2 for both AOFI should be updated

  6) Extact FundApps Transaction File
  Expected Result : Only T2 Transaction should be extracted. Only T2 should be extracted. AOIL Status Should be set to PUBLISHED for T2 for AOI_EISExecutedTransactionFundApps_Economics

  7) Extact Data Report
  Expected Result : Only T2 Transaction should be extracted. Only T2 should be extracted. AOIL Status Should be set to PUBLISHED for T2 for AOI_EISExecutedTransactionDataReport_Economics

  Scenario: Assign Variables, Create Test Data and Published Transaction from previous load

    #Assign Variables
    Given I assign "/dmp/out/eis/datareports" to variable "PUBLISHING_DIRECTORY_DR"
    And I assign "/dmp/out/fundapps" to variable "PUBLISHING_DIRECTORY"
    And I assign "tests/test-data/dmp-interfaces/FundApps/Functional/Transaction" to variable "testdata.path"
    And I assign "T1_EOD.xml" to variable "INPUT_FILE_T1_EOD"
    And I assign "T2_EOD.xml" to variable "INPUT_FILE_T2_EOD"
    And I assign "T2_INTRADAY.xml" to variable "INPUT_FILE_T2_INTRADAY"
    And I assign "FA_Trasaction_1" to variable "PUBLISHING_FILE_NAME_FA_1"
    And I assign "DR_Trasaction_1" to variable "PUBLISHING_FILE_NAME_DR_1"
    And I assign "FA_Trasaction_2" to variable "PUBLISHING_FILE_NAME_FA_2"
    And I assign "DR_Trasaction_2" to variable "PUBLISHING_FILE_NAME_DR_2"
    And I assign "FA_Trasaction_1_Reference" to variable "PUBLISHING_FILE_NAME_FA_1_REFERENCE"
    And I assign "DR_Trasaction_1_Reference" to variable "PUBLISHING_FILE_NAME_DR_1_REFERENCE"
    And I assign "FA_Trasaction_2_Reference" to variable "PUBLISHING_FILE_NAME_FA_2_REFERENCE"
    And I assign "DR_Trasaction_2_Reference" to variable "PUBLISHING_FILE_NAME_DR_2_REFERENCE"

    And I generate value with date format "YYYYMMdd" and assign to variable "VAR_SYSDATE"

    #Update existing EXTR.TRD_ID to new oid
    And I execute below query
	"""
    UPDATE FT_T_EXTR SET TRD_ID = NEW_OID() WHERE TRD_ID IN ('3167-1212','3167-1207');
    COMMIT
    """

    #Update END_TMS to SYSDATE for last published SBEX_OID

    And I execute below query
	"""
    UPDATE FT_CFG_SBEX SET END_TMS = SYSDATE WHERE SBEX_OID IN (SELECT SBEX_OID FROM (
    SELECT SBEX_OID, SBDF_OID,
    ROW_NUMBER() OVER (PARTITION BY SBDF_OID ORDER BY END_TMS DESC) AS RECORD_ORDER
    FROM FT_CFG_SBEX WHERE SUBS_EXEC_STAT_TYP = 'CLOSED' AND SBDF_OID IN (SELECT SBDF_OID FROM FT_CFG_SBDF
    WHERE SUBSCRIPTION_NME IN ('EIS_DMP_TO_FUNDAPPS_TRANSACTION_SUB','EIS_DMP_TO_TRANSACTION_DATAREPORT_SUB'))) WHERE RECORD_ORDER = 1);
    COMMIT
    """

  Scenario: Load EOD File with Transaction T1

    Given I copy files below from local folder "${testdata.path}/inputfiles/Rule_EISUpdateAOILPubTms/testdata" to the host "dmp.ssh.inbound" folder "${dmp.ssh.inbound.path}":
      | ${INPUT_FILE_T1_EOD} |

    And I process files with below parameters and wait for the job to be completed
      | FILE_PATTERN  | ${INPUT_FILE_T1_EOD}                 |
      | MESSAGE_TYPE  | EIS_MT_BRS_EOD_TRANSACTION_NON_LATAM |
      | BUSINESS_FEED |                                      |

    Then I extract new job id from jblg table into a variable "JOB_ID_1"

    And I expect value of column "JBLG_ROW_COUNT" in the below SQL query equals to "1":
    """
    SELECT count(*) as JBLG_ROW_COUNT FROM FT_T_JBLG
    WHERE JOB_ID = '${JOB_ID_1}'
    AND JOB_STAT_TYP ='CLOSED'
    AND TASK_SUCCESS_CNT = 1
    """

    Then I expect value of column "AOIL_T1_EOD_COUNT" in the below SQL query equals to "2":
    """
    SELECT COUNT(*) AS AOIL_T1_EOD_COUNT FROM FT_T_AOIL AOIL,FT_CFG_AOFI AOFI WHERE AOFI.AOFD_OID = AOIL.AOFD_OID AND AOIL.XREF_TBL_ROW_OID IN (SELECT XREF_TBL_ROW_OID FROM FT_T_MSGP WHERE TRN_ID IN(
    SELECT TRN_ID FROM FT_T_TRID WHERE JOB_ID = '${JOB_ID_1}') AND XREF_TBL_TYP = 'EXTR')
    AND AOFI.AOFI_NME IN  ('AOI_EISExecutedTransactionDataReport_Economics','AOI_EISExecutedTransactionFundApps_Economics')
    AND AOIL.XREF_TBL_TYP = 'EXTR'
    AND AOIL.DATA_STAT_TYP IS NULL
    AND AOFI.END_TMS IS NULL AND AOIL.END_TMS IS NULL
    AND AOIL.LAST_CHG_USR_ID = 'EIS_BRS_DMP_TRANSACTION'
    """

  Scenario: Load Intraday File with Transaction T2 Run 1

    Given I copy files below from local folder "${testdata.path}/inputfiles/Rule_EISUpdateAOILPubTms/testdata" to the host "dmp.ssh.inbound" folder "${dmp.ssh.inbound.path}":
      | ${INPUT_FILE_T2_INTRADAY} |

    And I process files with below parameters and wait for the job to be completed
      | FILE_PATTERN  | ${INPUT_FILE_T2_INTRADAY}       |
      | MESSAGE_TYPE  | EIS_MT_BRS_INTRADAY_TRANSACTION |
      | BUSINESS_FEED |                                 |

    Then I extract new job id from jblg table into a variable "JOB_ID_2"
    And I expect value of column "JBLG_ROW_COUNT" in the below SQL query equals to "1":
    """
    SELECT count(*) as JBLG_ROW_COUNT FROM FT_T_JBLG
    WHERE JOB_ID = '${JOB_ID_2}'
    AND JOB_STAT_TYP ='CLOSED'
    AND TASK_SUCCESS_CNT = 1
    """

    Then I expect value of column "AOIL_T2_INTRADAY_COUNT" in the below SQL query equals to "2":
    """
    SELECT COUNT(*) AS AOIL_T2_INTRADAY_COUNT FROM FT_T_AOIL AOIL,FT_CFG_AOFI AOFI WHERE AOFI.AOFD_OID = AOIL.AOFD_OID AND AOIL.XREF_TBL_ROW_OID IN (SELECT XREF_TBL_ROW_OID FROM FT_T_MSGP WHERE TRN_ID IN(
    SELECT TRN_ID FROM FT_T_TRID WHERE JOB_ID = '${JOB_ID_2}') AND XREF_TBL_TYP = 'EXTR')
    AND AOFI.AOFI_NME IN  ('AOI_EISExecutedTransactionDataReport_Economics','AOI_EISExecutedTransactionFundApps_Economics')
    AND AOIL.XREF_TBL_TYP = 'EXTR'
    AND AOIL.DATA_STAT_TYP IS NULL
    AND AOFI.END_TMS IS NULL AND AOIL.END_TMS IS NULL
    AND AOIL.LAST_CHG_USR_ID = 'EIS_BRS_DMP_TRANSACTION'
    """

  Scenario: Extact FundApps Transaction File

    Given I remove below files with pattern in the host "dmp.ssh.inbound" from folder "${PUBLISHING_DIRECTORY}" if exists:
      | ${PUBLISHING_FILE_NAME_FA_1}*.csv |

    And I process publishing wrapper with below parameters and wait for the job to be completed
      | PUBLISHING_FILE_NAME | ${PUBLISHING_FILE_NAME_FA_1}.csv    |
      | SUBSCRIPTION_NAME    | EIS_DMP_TO_FUNDAPPS_TRANSACTION_SUB |
      | AOI_PROCESSING       | true                                |

    Then I expect below files to be present in the host "dmp.ssh.inbound" into folder "${PUBLISHING_DIRECTORY}" after processing:
      | ${PUBLISHING_FILE_NAME_FA_1}_${VAR_SYSDATE}_1.csv |

    Then I copy files below from remote folder "${PUBLISHING_DIRECTORY}" on host "dmp.ssh.inbound" into local folder "${testdata.path}/outfiles/Rule_EISUpdateAOILPubTms/runtime":
      | ${PUBLISHING_FILE_NAME_FA_1}_${VAR_SYSDATE}_1.csv |

    Then I remove below files with pattern in the host "dmp.ssh.inbound" from folder "${PUBLISHING_DIRECTORY}" if exists:
      | ${PUBLISHING_FILE_NAME_FA_1} |

    Then I expect reconciliation between generated CSV file "${testdata.path}/outfiles/Rule_EISUpdateAOILPubTms/runtime/${PUBLISHING_FILE_NAME_FA_1}_${VAR_SYSDATE}_1.csv" and reference CSV file "${testdata.path}/outfiles/Rule_EISUpdateAOILPubTms/reference/${PUBLISHING_FILE_NAME_FA_1_REFERENCE}.csv" should be successful and exceptions to be written to "${TESTDATA_PATH}/outfiles/002_1_1_exceptions_${recon.timestamp}.csv" file

  Scenario: Extract Transactions Data Report

    Given I remove below files with pattern in the host "dmp.ssh.inbound" from folder "${PUBLISHING_DIRECTORY_DR}" if exists:
      | ${PUBLISHING_FILE_NAME_DR_1}*.csv |

    And I process publishing wrapper with below parameters and wait for the job to be completed
      | PUBLISHING_FILE_NAME | ${PUBLISHING_FILE_NAME_DR_1}.csv      |
      | SUBSCRIPTION_NAME    | EIS_DMP_TO_TRANSACTION_DATAREPORT_SUB |
      | AOI_PROCESSING       | true                                  |
      | COLUMN_SEPARATOR     | ,                                     |
      | COLUMN_TO_SORT       | 3                                     |

    Then I expect below files to be present in the host "dmp.ssh.inbound" into folder "${PUBLISHING_DIRECTORY_DR}" after processing:
      | ${PUBLISHING_FILE_NAME_DR_1}_${VAR_SYSDATE}_1.csv |

    Then I copy files below from remote folder "${PUBLISHING_DIRECTORY_DR}" on host "dmp.ssh.inbound" into local folder "${testdata.path}/outfiles/Rule_EISUpdateAOILPubTms/runtime":
      | ${PUBLISHING_FILE_NAME_DR_1}_${VAR_SYSDATE}_1.csv |

    Then I remove below files with pattern in the host "dmp.ssh.inbound" from folder "${PUBLISHING_DIRECTORY_DR}" if exists:
      | ${PUBLISHING_FILE_NAME_DR_1} |

    Then I exclude below columns from CSV file while doing reconciliations
      | Position Date/Effective Date |

    Then I expect reconciliation between generated CSV file "${testdata.path}/outfiles/Rule_EISUpdateAOILPubTms/runtime/${PUBLISHING_FILE_NAME_DR_1}_${VAR_SYSDATE}_1.csv" and reference CSV file "${testdata.path}/outfiles/Rule_EISUpdateAOILPubTms/reference/${PUBLISHING_FILE_NAME_DR_1_REFERENCE}.csv" should be successful and exceptions to be written to "${TESTDATA_PATH}/outfiles/002_1_1_exceptions_${recon.timestamp}.csv" file

  Scenario: Verify AOIL After Publishing

    Then I expect value of column "AOIL_T1_EOD_COUNT_POSTAOI" in the below SQL query equals to "2":
    """
    SELECT COUNT(*) AS AOIL_T1_EOD_COUNT_POSTAOI FROM FT_T_AOIL AOIL,FT_CFG_AOFI AOFI WHERE AOFI.AOFD_OID = AOIL.AOFD_OID AND AOIL.XREF_TBL_ROW_OID IN (SELECT XREF_TBL_ROW_OID FROM FT_T_MSGP WHERE TRN_ID IN(
    SELECT TRN_ID FROM FT_T_TRID WHERE JOB_ID = '${JOB_ID_1}') AND XREF_TBL_TYP = 'EXTR')
    AND AOFI.AOFI_NME IN  ('AOI_EISExecutedTransactionDataReport_Economics','AOI_EISExecutedTransactionFundApps_Economics')
    AND AOIL.XREF_TBL_TYP = 'EXTR'
    AND AOIL.DATA_STAT_TYP = 'PUBLISHED'
    AND AOFI.END_TMS IS NULL AND AOIL.END_TMS IS NULL
    AND AOIL.LAST_CHG_USR_ID = 'EIS_BRS_DMP_TRANSACTION'
    """

    Then I expect value of column "AOIL_T2_INTRADAY_COUNT_POSTAOI" in the below SQL query equals to "2":
    """
    SELECT COUNT(*) AS AOIL_T2_INTRADAY_COUNT_POSTAOI FROM FT_T_AOIL AOIL,FT_CFG_AOFI AOFI WHERE AOFI.AOFD_OID = AOIL.AOFD_OID AND AOIL.XREF_TBL_ROW_OID IN (SELECT XREF_TBL_ROW_OID FROM FT_T_MSGP WHERE TRN_ID IN(
    SELECT TRN_ID FROM FT_T_TRID WHERE JOB_ID = '${JOB_ID_2}') AND XREF_TBL_TYP = 'EXTR')
    AND AOFI.AOFI_NME IN  ('AOI_EISExecutedTransactionDataReport_Economics','AOI_EISExecutedTransactionFundApps_Economics')
    AND AOIL.XREF_TBL_TYP = 'EXTR'
    AND AOIL.DATA_STAT_TYP = 'AOIPROCESSED'
    AND AOFI.END_TMS IS NULL AND AOIL.END_TMS IS NULL
    AND AOIL.LAST_CHG_USR_ID = 'EIS_BRS_DMP_TRANSACTION'
    """

  Scenario: Load EOD File with Transaction T2

    Given I copy files below from local folder "${testdata.path}/inputfiles/Rule_EISUpdateAOILPubTms/testdata" to the host "dmp.ssh.inbound" folder "${dmp.ssh.inbound.path}":
      | ${INPUT_FILE_T2_EOD} |

    And I process files with below parameters and wait for the job to be completed
      | FILE_PATTERN  | ${INPUT_FILE_T2_EOD}                 |
      | MESSAGE_TYPE  | EIS_MT_BRS_EOD_TRANSACTION_NON_LATAM |
      | BUSINESS_FEED |                                      |

    Then I extract new job id from jblg table into a variable "JOB_ID_3"

    And I expect value of column "JBLG_ROW_COUNT" in the below SQL query equals to "1":
    """
    SELECT count(*) as JBLG_ROW_COUNT FROM FT_T_JBLG
    WHERE JOB_ID = '${JOB_ID_3}'
    AND JOB_STAT_TYP ='CLOSED'
    AND TASK_CMPLTD_CNT = 1
    """

    Then I expect value of column "AOIL_T2_EOD_COUNT_POSTRULE" in the below SQL query equals to "2":
    """
    SELECT COUNT(*) AS AOIL_T2_EOD_COUNT_POSTRULE FROM FT_T_AOIL AOIL,FT_CFG_AOFI AOFI WHERE AOFI.AOFD_OID = AOIL.AOFD_OID AND AOIL.XREF_TBL_ROW_OID IN (SELECT XREF_TBL_ROW_OID FROM FT_T_MSGP WHERE TRN_ID IN(
    SELECT TRN_ID FROM FT_T_TRID WHERE JOB_ID = '${JOB_ID_3}') AND XREF_TBL_TYP = 'EXTR')
    AND AOFI.AOFI_NME IN  ('AOI_EISExecutedTransactionDataReport_Economics','AOI_EISExecutedTransactionFundApps_Economics')
    AND AOIL.XREF_TBL_TYP = 'EXTR'
    AND AOIL.DATA_STAT_TYP = 'AOIPROCESSED'
    AND AOFI.END_TMS IS NULL AND AOIL.END_TMS IS NULL
    AND AOIL.LAST_CHG_USR_ID = 'EIS_UPDATEAOILPUBTMS_RULEPROCESSOR'
    """

  Scenario: Extact FundApps Transaction File

    Given I remove below files with pattern in the host "dmp.ssh.inbound" from folder "${PUBLISHING_DIRECTORY}" if exists:
      | ${PUBLISHING_FILE_NAME_FA_2}*.csv |

    And I process publishing wrapper with below parameters and wait for the job to be completed
      | PUBLISHING_FILE_NAME | ${PUBLISHING_FILE_NAME_FA_2}.csv    |
      | SUBSCRIPTION_NAME    | EIS_DMP_TO_FUNDAPPS_TRANSACTION_SUB |
      | AOI_PROCESSING       | true                                |

    Then I expect below files to be present in the host "dmp.ssh.inbound" into folder "${PUBLISHING_DIRECTORY}" after processing:
      | ${PUBLISHING_FILE_NAME_FA_2}_${VAR_SYSDATE}_1.csv |

    Then I copy files below from remote folder "${PUBLISHING_DIRECTORY}" on host "dmp.ssh.inbound" into local folder "${testdata.path}/outfiles/Rule_EISUpdateAOILPubTms/runtime":
      | ${PUBLISHING_FILE_NAME_FA_2}_${VAR_SYSDATE}_1.csv |

    Then I remove below files with pattern in the host "dmp.ssh.inbound" from folder "${PUBLISHING_DIRECTORY}" if exists:
      | ${PUBLISHING_FILE_NAME_FA_2} |

    Then I expect reconciliation between generated CSV file "${testdata.path}/outfiles/Rule_EISUpdateAOILPubTms/runtime/${PUBLISHING_FILE_NAME_FA_2}_${VAR_SYSDATE}_1.csv" and reference CSV file "${testdata.path}/outfiles/Rule_EISUpdateAOILPubTms/reference/${PUBLISHING_FILE_NAME_FA_2_REFERENCE}.csv" should be successful and exceptions to be written to "${TESTDATA_PATH}/outfiles/002_1_1_exceptions_${recon.timestamp}.csv" file

  Scenario: Publish Transactions Data Report

    Given I remove below files with pattern in the host "dmp.ssh.inbound" from folder "${PUBLISHING_DIRECTORY_DR}" if exists:
      | ${PUBLISHING_FILE_NAME_DR_2}*.csv |

    And I process publishing wrapper with below parameters and wait for the job to be completed
      | PUBLISHING_FILE_NAME | ${PUBLISHING_FILE_NAME_DR_2}.csv      |
      | SUBSCRIPTION_NAME    | EIS_DMP_TO_TRANSACTION_DATAREPORT_SUB |
      | AOI_PROCESSING       | true                                  |
      | COLUMN_SEPARATOR     | ,                                     |
      | COLUMN_TO_SORT       | 3                                     |

    Then I expect below files to be present in the host "dmp.ssh.inbound" into folder "${PUBLISHING_DIRECTORY_DR}" after processing:
      | ${PUBLISHING_FILE_NAME_DR_2}_${VAR_SYSDATE}_1.csv |

    Then I copy files below from remote folder "${PUBLISHING_DIRECTORY_DR}" on host "dmp.ssh.inbound" into local folder "${testdata.path}/outfiles/Rule_EISUpdateAOILPubTms/runtime":
      | ${PUBLISHING_FILE_NAME_DR_2}_${VAR_SYSDATE}_1.csv |

    Then I remove below files with pattern in the host "dmp.ssh.inbound" from folder "${PUBLISHING_DIRECTORY_DR}" if exists:
      | ${PUBLISHING_FILE_NAME_DR_2} |

    Then I exclude below columns from CSV file while doing reconciliations
      | Position Date/Effective Date |

    Then I expect reconciliation between generated CSV file "${testdata.path}/outfiles/Rule_EISUpdateAOILPubTms/runtime/${PUBLISHING_FILE_NAME_DR_2}_${VAR_SYSDATE}_1.csv" and reference CSV file "${testdata.path}/outfiles/Rule_EISUpdateAOILPubTms/reference/${PUBLISHING_FILE_NAME_DR_2_REFERENCE}.csv" should be successful and exceptions to be written to "${TESTDATA_PATH}/outfiles/002_1_1_exceptions_${recon.timestamp}.csv" file

  Scenario: Verify AOIL After Publishing

    Then I expect value of column "AOIL_T2_EOD_COUNT_POSTPUBLISH" in the below SQL query equals to "2":
    """
    SELECT COUNT(*) AS AOIL_T2_EOD_COUNT_POSTPUBLISH FROM FT_T_AOIL AOIL,FT_CFG_AOFI AOFI WHERE AOFI.AOFD_OID = AOIL.AOFD_OID AND AOIL.XREF_TBL_ROW_OID IN (SELECT XREF_TBL_ROW_OID FROM FT_T_MSGP WHERE TRN_ID IN(
    SELECT TRN_ID FROM FT_T_TRID WHERE JOB_ID = '${JOB_ID_3}') AND XREF_TBL_TYP = 'EXTR')
    AND AOFI.AOFI_NME IN  ('AOI_EISExecutedTransactionDataReport_Economics','AOI_EISExecutedTransactionFundApps_Economics')
    AND AOIL.XREF_TBL_TYP = 'EXTR'
    AND AOIL.DATA_STAT_TYP = 'PUBLISHED'
    AND AOFI.END_TMS IS NULL AND AOIL.END_TMS IS NULL
    AND AOIL.LAST_CHG_USR_ID = 'EIS_UPDATEAOILPUBTMS_RULEPROCESSOR'
    """