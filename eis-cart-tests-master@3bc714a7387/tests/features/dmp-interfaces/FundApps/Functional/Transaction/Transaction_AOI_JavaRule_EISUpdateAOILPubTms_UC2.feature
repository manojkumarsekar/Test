#https://jira.intranet.asia/browse/EISDEV-5487
#https://collaborate.pruconnect.net/display/EISTOMR4/Rule+to+update+AOIL.PUB_TMS+to+SYSDATE+for+configured+Message+Types+and+AOI+Names

@dmp_fundapps_functional @dmp_fundapps_transaction_eisupdateaoilpubtms @eisdev_5487
Feature: FundApps | Transaction | AOI Java Rule EISUpdateAOILPubTms | Parent Segment is not EXTR

  1) Load EOD File with Transaction T1
  Expected Result : Data Should be successfully loaded - Rule Processing Skipped as SEGPROCESSEDIND = C

  2) Extact SSDR Transaction File
  Expected Result : T1 Transaction should be extracted - AOIL Status Should be set to PUBLISHED for T1 AOI_EISExecutedTransactionSSDR_Economics and AOIPROCESSED for other AOFI

  3) Extact FundApps Transaction File
  Expected Result : T1 is not extracted and AOIL Status Should be set to AOIPROCESSED for other AOFI

  4) Extact Data Report
  Expected Result : T1 is not extracted and AOIL Status Should be set to AOIPROCESSED for other AOFI

  5) Load EOD File with Transaction T1 with touch count 1
  Expected Result : Data Should be successfully loaded - Rule Processing should be invoked. AOIL.PUB_TMS and LAST_CHG_USR_ID for T1 for both AOFI should be updated. No Exception should be thrown

  Scenario: Assign Variables, Create Test Data and Published Transaction from previous load

    #Assign Variables
    Given I assign "/dmp/out/eis/datareports" to variable "PUBLISHING_DIRECTORY_DR"
    And I assign "/dmp/out/fundapps" to variable "PUBLISHING_DIRECTORY"
    And I assign "/dmp/out/eis/ssdr" to variable "PUBLISHING_DIRECTORY_SSDR"
    And I assign "tests/test-data/dmp-interfaces/FundApps/Functional/Transaction" to variable "testdata.path"
    And I assign "T3_EOD_1.xml" to variable "INPUT_FILE_T1_1"
    And I assign "T3_EOD_2.xml" to variable "INPUT_FILE_T1_2"

    And I generate value with date format "YYYYMMdd" and assign to variable "VAR_SYSDATE"

    And I execute below query to "Update existing EXTR.TRD_ID to new oid"
	"""
    UPDATE FT_T_EXTR SET TRD_ID = NEW_OID() WHERE TRD_ID = '3263-10591';
    COMMIT
    """

    And I execute below query to "Update END_TMS to SYSDATE for last published SBEX_OID"
	"""
    UPDATE FT_CFG_SBEX SET END_TMS = SYSDATE WHERE SBEX_OID IN (SELECT SBEX_OID FROM (
    SELECT SBEX_OID, SBDF_OID,
    ROW_NUMBER() OVER (PARTITION BY SBDF_OID ORDER BY END_TMS DESC) AS RECORD_ORDER
    FROM FT_CFG_SBEX WHERE SUBS_EXEC_STAT_TYP = 'CLOSED' AND SBDF_OID IN (SELECT SBDF_OID FROM FT_CFG_SBDF
    WHERE SUBSCRIPTION_NME IN ('EIS_DMP_TO_FUNDAPPS_TRANSACTION_SUB','EIS_DMP_TO_TRANSACTION_DATAREPORT_SUB','EIS_DMP_TO_RDM_SSDR_TRADE_SUB'))) WHERE RECORD_ORDER = 1);
    COMMIT
    """

  Scenario: Load EOD File with Transaction T1

    Given I copy files below from local folder "${testdata.path}/inputfiles/Rule_EISUpdateAOILPubTms/testdata" to the host "dmp.ssh.inbound" folder "${dmp.ssh.inbound.path}":
      | ${INPUT_FILE_T1_1} |

    And I process files with below parameters and wait for the job to be completed
      | FILE_PATTERN  | ${INPUT_FILE_T1_1}                   |
      | MESSAGE_TYPE  | EIS_MT_BRS_EOD_TRANSACTION_LATAM |
      | BUSINESS_FEED |                                      |

    Then I expect workflow is processed in DMP with success record count as "1"

  Scenario: Extact SSDR Transaction File

    Given I remove below files with pattern in the host "dmp.ssh.inbound" from folder "${PUBLISHING_DIRECTORY_SSDR}" if exists:
      | TRANSACTION_SSDR*.csv |

    And I process publishing wrapper with below parameters and wait for the job to be completed
      | PUBLISHING_FILE_NAME | TRANSACTION_SSDR.csv          |
      | SUBSCRIPTION_NAME    | EIS_DMP_TO_RDM_SSDR_TRADE_SUB |
      | AOI_PROCESSING       | true                          |

  Scenario: Extact FundApps Transaction File

    Given I remove below files with pattern in the host "dmp.ssh.inbound" from folder "${PUBLISHING_DIRECTORY}" if exists:
      | TRANSACTION_FA*.csv |

    And I process publishing wrapper with below parameters and wait for the job to be completed
      | PUBLISHING_FILE_NAME | TRANSACTION_FA.csv                  |
      | SUBSCRIPTION_NAME    | EIS_DMP_TO_FUNDAPPS_TRANSACTION_SUB |
      | AOI_PROCESSING       | true                                |

  Scenario: Extract Transactions Data Report

    Given I remove below files with pattern in the host "dmp.ssh.inbound" from folder "${PUBLISHING_DIRECTORY_DR}" if exists:
      | TRANSACTION_DR*.csv |

    And I process publishing wrapper with below parameters and wait for the job to be completed
      | PUBLISHING_FILE_NAME | TRANSACTION_DR.csv                    |
      | SUBSCRIPTION_NAME    | EIS_DMP_TO_TRANSACTION_DATAREPORT_SUB |
      | AOI_PROCESSING       | true                                  |
      | COLUMN_SEPARATOR     | ,                                     |
      | COLUMN_TO_SORT       | 3                                     |

  Scenario: Load EOD File with Transaction T1 with touch count 1

    Given I copy files below from local folder "${testdata.path}/inputfiles/Rule_EISUpdateAOILPubTms/testdata" to the host "dmp.ssh.inbound" folder "${dmp.ssh.inbound.path}":
      | ${INPUT_FILE_T1_2} |

    And I process files with below parameters and wait for the job to be completed
      | FILE_PATTERN  | ${INPUT_FILE_T1_2}                   |
      | MESSAGE_TYPE  | EIS_MT_BRS_EOD_TRANSACTION_LATAM |
      | BUSINESS_FEED |                                      |

    Then I expect workflow is processed in DMP with success record count as "1"

    Then I expect value of column "AOIL_T1_EOD_COUNT_POSTRULE" in the below SQL query equals to "2":
    """
    SELECT COUNT(*) AS AOIL_T1_EOD_COUNT_POSTRULE FROM FT_T_AOIL AOIL,FT_CFG_AOFI AOFI WHERE AOFI.AOFD_OID = AOIL.AOFD_OID AND AOIL.XREF_TBL_ROW_OID IN (SELECT XREF_TBL_ROW_OID FROM FT_T_MSGP WHERE TRN_ID IN(
    SELECT TRN_ID FROM FT_T_TRID WHERE JOB_ID = '${JOB_ID}') AND XREF_TBL_TYP = 'EXTR')
    AND AOFI.AOFI_NME IN  ('AOI_EISExecutedTransactionDataReport_Economics','AOI_EISExecutedTransactionFundApps_Economics')
    AND AOIL.XREF_TBL_TYP = 'EXTR'
    AND AOIL.DATA_STAT_TYP = 'AOIPROCESSED'
    AND AOFI.END_TMS IS NULL AND AOIL.END_TMS IS NULL
    AND AOIL.LAST_CHG_USR_ID = 'EIS_UPDATEAOILPUBTMS_RULEPROCESSOR'
    """
