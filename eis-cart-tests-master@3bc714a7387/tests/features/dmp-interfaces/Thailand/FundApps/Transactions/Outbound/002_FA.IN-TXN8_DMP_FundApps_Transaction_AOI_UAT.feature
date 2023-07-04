#https://jira.pruconnect.net/browse/EISDEV-6235
#Architectue Requirement: https://collaborate.pruconnect.net/display/support/SSDR+FundApps+Architecture?src=jira
#Functional specification : https://collaborate.pruconnect.net/pages/viewpage.action?spaceKey=EISTT&title=TH+SSDR+Changes%7CFund%7CPosition%7CTransaction

@gc_interface_transactions
@dmp_regression_integrationtest
@eisdev_6235 @002_fundapps_transaction_aoi @dmp_thailand_fundapps @dmp_thailand
Feature: 002 | FundApps | Verify Attribute Of Intersets for Thailand Parallel

  AOI for Transaction Data Report is Defined on "Quantity, Transaction Type, Security, FundCode, TransactionDate and Datasource" Fields.
  If an update is received on any of the defined fields, transaction details should be published.

  We tests the following Scenario with this feature file.
  1.Scenario TC2, TC3, TC4 and TC5: Day 1- Load, Publish and verify the Korea Transaction file.
  2.Scenario TC6, TC7 TC8 and TC9: Day 2- Load, Publish and verify the Korea Transaction file. It should publish only modified rows as per AOI.

  Day 1
  Security_ID | Fund_ID | Transaction_ID          |Transaction_Type | Transaction_Date | Quantity    | Trade_Price
  US9229083632|E90455   |KR001AOI${TRD_VAR_NUM_1} |P                |${CURR_DATE}      |2467.72      |30.469421
  US9229083632|E90460   |KR002AOI${TRD_VAR_NUM_1} |P                |${CURR_DATE}      |1969.19      |30.469381
  US9219438580|E90464   |KR003AOI${TRD_VAR_NUM_1} |P                |${CURR_DATE}      |240          |34.1615
  US92203J4076|E90469   |KR004AOI${TRD_VAR_NUM_1} |P                |${CURR_DATE}      |4889.91      |11.645
  US9219438580|E90471   |KR005AOI${TRD_VAR_NUM_1} |P                |${CURR_DATE}      |1210         |34.1681

  Day 2
  Security_ID | Fund_ID | Transaction_ID          | Transaction_Type | Transaction_Date | Quantity   | Trade_Price | Use Case              | Expected Behaviour
  US9229083632|E90455   |KR001AOI${TRD_VAR_NUM_1} |P                 |${CURR_DATE}      |2467.72     |30.469421    | No Change             | Record Should Not be Published
  US9229083632|E90460   |KR002AOI${TRD_VAR_NUM_1} |P                 |${CURR_DATE}      |2000        |30.469381    | Quantity Change       | Record Should be Published
  US9219438580|E90464   |KR003AOI${TRD_VAR_NUM_1} |S                 |${CURR_DATE}      |240         |34.1615      | Trasaction Type Change| Record Should be Published
  US92203J4076|E90480   |KR004AOI${TRD_VAR_NUM_1} |P                 |${CURR_DATE}      |4889.91     |11.645       | Fund Change           | Record Should be Published
  US46138G7060|E90471   |KR005AOI${TRD_VAR_NUM_1} |P                 |${CURR_DATE}      |1210        |34.1681      | Security Change       | Record Should be Published

  Scenario:TC1: Assign Variables

    Given I assign "tests/test-data/dmp-interfaces/Thailand/FundApps/Transactions/Outbound" to variable "TESTDATA_PATH"
    And I assign "/dmp/out/fundapps" to variable "PUBLISHING_DIRECTORY"
    And I assign "002_FA_IN_TXN8_FundApps_AOI" to variable "PUBLISHING_FILE_NAME_DAY1"
    And I assign "002_FA_IN_TXN8_FundApps_AOI_Update" to variable "PUBLISHING_FILE_NAME_DAY2"
    And I assign "002_FA_IN_TXN8_FundApps_AOI_Expected.csv" to variable "EXPECTED_FILE_NAME_DAY1"
    And I assign "002_FA_IN_TXN8_FundApps_AOI_Update_Expected.csv" to variable "EXPECTED_FILE_NAME_DAY2"
    And I generate value with date format "YYYYMMdd" and assign to variable "VAR_SYSDATE"
    And I assign "002_FA.IN-TXN8_DMP_FundApps_KR_AOI.csv" to variable "INPUTFILE_NAME_DAY1"
    And I assign "002_FA.IN-TXN8_DMP_FundApps_KR_AOI_Update.csv" to variable "INPUTFILE_NAME_DAY2"

    And I execute below query and extract values of "CURR_DATE;CURR_DATE_1;CURR_DATE_2" into same variables
     """
     select TO_CHAR(sysdate, 'DD/MM/YYYY') AS CURR_DATE ,TO_CHAR(sysdate+1, 'DD/MM/YYYY') AS CURR_DATE_1, TO_CHAR(sysdate, 'YYYY-MM-DD') AS CURR_DATE_2 from dual
     """

    And I execute below query and extract values of "TRD_VAR_NUM_1" into same variables
     """
     SELECT LPAD(VREQ_FILE_SEQ.NEXTVAL+1,8,'0') AS TRD_VAR_NUM_1 FROM DUAL
     """

    And I assign "'TB3','227'" to variable "PROD_PORTFOLIO_EXCLUSION"
    And I assign "'TB3','227','243','LF6'" to variable "UAT_PORTFOLIO_EXCLUSION"

    #Pre-requisite : Insert row into ACGP for FAPRDEXCLPORT & FAPRDEXCLPORT group
    And I execute below query to create paticipants for FAPRDEXCLPORT & FAPRDEXCLPORT
    """
    ${TESTDATA_PATH}/sql/InsertIntoACGPTable.sql
    """

    And I create input file "${INPUTFILE_NAME_DAY1}" using template "002_FA.IN-TXN8_DMP_FundApps_KR_AOI_Template.csv" from location "${TESTDATA_PATH}/inputfiles"

    And I create input file "${INPUTFILE_NAME_DAY2}" using template "002_FA.IN-TXN8_DMP_FundApps_KR_AOI_Update_Template.csv" from location "${TESTDATA_PATH}/inputfiles"

    And I create input file "${EXPECTED_FILE_NAME_DAY1}" using template "002_FA_IN_TXN8_FundApps_AOI_Expected_Template.csv" from location "${TESTDATA_PATH}/outfiles"

    And I create input file "${EXPECTED_FILE_NAME_DAY2}" using template "002_FA_IN_TXN8_FundApps_AOI_Update_Expected_Template.csv" from location "${TESTDATA_PATH}/outfiles"

  Scenario:TC2: Load KOREA Transaction Data File - Day1

    Given I process "${TESTDATA_PATH}/inputfiles/testdata/${INPUTFILE_NAME_DAY1}" file with below parameters
      | FILE_PATTERN  | ${INPUTFILE_NAME_DAY1} |
      | MESSAGE_TYPE  | EIS_MT_EIMK_DMP_TXN    |
      | BUSINESS_FEED |                        |

    Then I expect workflow is processed in DMP with total record count as "5"

  Scenario:TC3: Publish Transactions Report

    Given I remove below files with pattern in the host "dmp.ssh.inbound" from folder "${PUBLISHING_DIRECTORY}" if exists:
      | ${PUBLISHING_FILE_NAME_DAY1}* |

    And I process publishing wrapper with below parameters and wait for the job to be completed
      | PUBLISHING_FILE_NAME | ${PUBLISHING_FILE_NAME_DAY1}.csv        |
      | SUBSCRIPTION_NAME    | EIS_DMP_TO_FUNDAPPS_TRANSACTION_UAT_SUB |
      | AOI_PROCESSING       | true                                    |

    Then I expect below files to be present in the host "dmp.ssh.inbound" into folder "${PUBLISHING_DIRECTORY}" after processing:
      | ${PUBLISHING_FILE_NAME_DAY1}_${VAR_SYSDATE}_1.csv |

    Then I copy files below from remote folder "${PUBLISHING_DIRECTORY}" on host "dmp.ssh.inbound" into local folder "${TESTDATA_PATH}/outfiles/actual":
      | ${PUBLISHING_FILE_NAME_DAY1}_${VAR_SYSDATE}_1.csv |

    Then I remove below files with pattern in the host "dmp.ssh.inbound" from folder "${PUBLISHING_DIRECTORY}" if exists:
      | ${PUBLISHING_FILE_NAME_DAY1} |

  Scenario: TC4: Check if day1 published file contains all the records which were in expected file

    Given I capture current time stamp into variable "recon.timestamp"
    Then I expect each record in file "${TESTDATA_PATH}/outfiles/testdata/${EXPECTED_FILE_NAME_DAY1}" should exist in file "${TESTDATA_PATH}/outfiles/actual/${PUBLISHING_FILE_NAME_DAY1}_${VAR_SYSDATE}_1.csv" and exceptions to be written to "${TESTDATA_PATH}/outfiles/actual/002_FA_IN_TXN8_FundApps_AOI_Exceptions_${recon.timestamp}.csv" file

  Scenario:TC5: Verify Published Transactions

    Given I expect value of column "PUB_TRAN_COUNT" in the below SQL query equals to "5":
    """
    SELECT COUNT(*) AS PUB_TRAN_COUNT FROM FT_T_PBAT PBAT, FT_T_EXTR EXTR
    WHERE PBAT.SBEX_OID IN
    (
    SELECT SBEX_OID AS RUNTIME_PUB_TMS FROM (SELECT SUBSCRIPTION_NME,START_TMS,SBEX_OID, ROW_NUMBER()
    OVER (PARTITION BY SUBSCRIPTION_NME ORDER BY START_TMS DESC) AS RECORD_ORDER
    FROM FT_V_PUB1
    WHERE PUB_STATUS = 'CLOSED' AND SUBSCRIPTION_NME = 'EIS_DMP_TO_FUNDAPPS_TRANSACTION_UAT_SUB') WHERE RECORD_ORDER =1
    )
    AND PBAT.PUBLISHED_TBL_ID = 'EXTR'
    AND PBAT.PUB_CROSS_REF_ID = EXTR.EXEC_TRD_ID
    AND EXTR.TRD_ID in (
    'KR001AOI${TRD_VAR_NUM_1}', 'KR002AOI${TRD_VAR_NUM_1}','KR003AOI${TRD_VAR_NUM_1}', 'KR004AOI${TRD_VAR_NUM_1}','KR005AOI${TRD_VAR_NUM_1}')
    """

  Scenario:TC6: Load KOREA Transaction Data File with Updated Quantity - Day2

    Given I process "${TESTDATA_PATH}/inputfiles/testdata/${INPUTFILE_NAME_DAY2}" file with below parameters
      | FILE_PATTERN  | ${INPUTFILE_NAME_DAY2} |
      | MESSAGE_TYPE  | EIS_MT_EIMK_DMP_TXN    |
      | BUSINESS_FEED |                        |

    Then I expect workflow is processed in DMP with total record count as "5"

  Scenario:TC7: Publish Day2 Transactions Report

    Given I remove below files with pattern in the host "dmp.ssh.inbound" from folder "${PUBLISHING_DIRECTORY}" if exists:
      | ${PUBLISHING_FILE_NAME_DAY2}* |

    And I process publishing wrapper with below parameters and wait for the job to be completed
      | PUBLISHING_FILE_NAME | ${PUBLISHING_FILE_NAME_DAY2}.csv        |
      | SUBSCRIPTION_NAME    | EIS_DMP_TO_FUNDAPPS_TRANSACTION_UAT_SUB |
      | AOI_PROCESSING       | true                                    |


    Then I expect below files to be present in the host "dmp.ssh.inbound" into folder "${PUBLISHING_DIRECTORY}" after processing:
      | ${PUBLISHING_FILE_NAME_DAY2}_${VAR_SYSDATE}_1.csv |

    Then I copy files below from remote folder "${PUBLISHING_DIRECTORY}" on host "dmp.ssh.inbound" into local folder "${TESTDATA_PATH}/outfiles/actual":
      | ${PUBLISHING_FILE_NAME_DAY2}_${VAR_SYSDATE}_1.csv |

    Then I remove below files with pattern in the host "dmp.ssh.inbound" from folder "${PUBLISHING_DIRECTORY}" if exists:
      | ${PUBLISHING_FILE_NAME_DAY2}* |

  Scenario: TC8: Check if day2 published file contains all the records which were in expected file

    Given I capture current time stamp into variable "recon.timestamp"
    Then I expect each record in file "${TESTDATA_PATH}/outfiles/testdata/${EXPECTED_FILE_NAME_DAY2}" should exist in file "${TESTDATA_PATH}/outfiles/actual/${PUBLISHING_FILE_NAME_DAY2}_${VAR_SYSDATE}_1.csv" and exceptions to be written to "${TESTDATA_PATH}/outfiles/actual/002_FA_IN_TXN8_FundApps_AOI_Update_Exceptions_${recon.timestamp}.csv" file

  Scenario:TC9: Verify Day2 Published Transactions based on AOI Configuration

    Given I expect value of column "PUB_AOI_TRAN_COUNT" in the below SQL query equals to "4":
    """
    SELECT COUNT(*) AS PUB_AOI_TRAN_COUNT FROM FT_T_PBAT PBAT, FT_T_EXTR EXTR
    WHERE PBAT.SBEX_OID IN
    (
    SELECT SBEX_OID AS RUNTIME_PUB_TMS FROM (SELECT SUBSCRIPTION_NME,START_TMS,SBEX_OID, ROW_NUMBER()
    OVER (PARTITION BY SUBSCRIPTION_NME ORDER BY START_TMS DESC) AS RECORD_ORDER
    FROM FT_V_PUB1
    WHERE PUB_STATUS = 'CLOSED' AND SUBSCRIPTION_NME = 'EIS_DMP_TO_FUNDAPPS_TRANSACTION_UAT_SUB') WHERE RECORD_ORDER =1
    )
    AND PBAT.PUBLISHED_TBL_ID = 'EXTR'
    AND PBAT.PUB_CROSS_REF_ID = EXTR.EXEC_TRD_ID
    AND EXTR.TRD_ID IN (
    'KR001AOI${TRD_VAR_NUM_1}', 'KR002AOI${TRD_VAR_NUM_1}','KR003AOI${TRD_VAR_NUM_1}', 'KR004AOI${TRD_VAR_NUM_1}','KR005AOI${TRD_VAR_NUM_1}')
    """
