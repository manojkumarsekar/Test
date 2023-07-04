#https://jira.intranet.asia/browse/TOM-4954
#This development is to create an outbound transaction file which will be consumed by FundApps. The extract criteria of this file is same to that of FundApps Transaction data reports and the same gso has been used
#This development item also removes from the filter criteria intraday transactions which came as a change and TOM-5030 is the JIRA for the same
#  This feature file is checking the AOI feature
#TOM-5184: Removing MNG related transactions due to demerger

@tom_4954_aoi @fa_txn @tom_5184
Feature: 002 | FundApps | Verify Attribute Of Intersets

  AOI for Transaction Data Report is Defined on "Quantity, Transaction Type, Security and Fund Code" Fields.
  If an update is received on any of the defined fields, transaction details should be published.

  Day 1
  Security_ID | Fund_ID | Transaction_ID  | Transaction_Type | Transaction_Date | Quantity | Trade_Price
  US46140H4039| I05     | -4698TC2TRN01   | S                | CURR_DATE        | 19000    | 612.369141
  LU0629158030| I16     | -4698TC2TRN02   | S                | CURR_DATE        | 29000    | 712.369141
  SG2C81967185| RF4     | -4698TC2TRN03   | S                | CURR_DATE        | 39000    | 812.369141
  TH0930010002| I25     | -4698TC2TRN04   | S                | CURR_DATE        | 49000    | 912.369141
  TH0101A10Z01| LF6     | -4698TC2TRN05   | S                | CURR_DATE        | 59000    | 1012.369141

  Day 2
  Security_ID | Fund_ID | Transaction_ID  | Transaction_Type | Transaction_Date | Quantity | Trade_Price | Use Case              | Expected Behaviour
  US46140H4039| I05     | -4698TC2TRN01   | S                | CURR_DATE        | 19000    | 612.369141  | No Change             | Record Should Not be Published
  LU0629158030| I16     | -4698TC2TRN02   | S                | CURR_DATE        | 90000    | 712.369141  | Quantity Change       | Record Should be Published
  SG2C81967185| RF4     | -4698TC2TRN03   | P                | CURR_DATE        | 39000    | 812.369141  | Trasaction Type Change| Record Should be Published
  TH0930010002| T01     | -4698TC2TRN04   | S                | CURR_DATE        | 49000    | 912.369141  | Fund Change           | Record Should be Published
  TH0148A10Z06| LF6     | -4698TC2TRN05   | S                | CURR_DATE        | 59000    | 1012.369141 | Security Change       | Record Should be Published

  Scenario: Assign Variables
    Given I assign "tests/test-data/dmp-interfaces/FundApps/Functional/Outbound/Outbound_FA_Txn" to variable "TESTDATA_PATH"
    And I assign "/dmp/out/fundapps" to variable "PUBLISHING_DIRECTORY"
    And I assign "TC02_FA_AOI_Txn" to variable "PUBLISHING_FILE_NAME1"
    And I assign "TC02_FA_AOI_Txn_Update" to variable "PUBLISHING_FILE_NAME2"
    And I generate value with date format "YYYYMMdd" and assign to variable "VAR_SYSDATE"
    And I assign "TC2_001_TMBAM_AOI.csv" to variable "INPUTFILE_NAME1"
    And I assign "TC2_002_TMBAM_AOI.csv" to variable "INPUTFILE_NAME2"

    And I execute below query and extract values of "CURR_DATE" into same variables
     """
     select TO_CHAR(sysdate, 'DD/MM/YYYY') AS CURR_DATE from dual
     """

    And I execute below query and extract values of "CURR_DATE_1" into same variables
     """
     select TO_CHAR(sysdate+1, 'DD/MM/YYYY') AS CURR_DATE_1 from dual
     """

    And I execute below query and extract values of "TRD_VAR_NUM" into same variables
        """
        SELECT LPAD(VREQ_FILE_SEQ.NEXTVAL+1,8,'0') AS TRD_VAR_NUM FROM DUAL
        """

    And I create input file "${INPUTFILE_NAME1}" using template "TC2_001_TMBAM_AOI_Template.csv" from location "${TESTDATA_PATH}/inputfiles"

    And I create input file "${INPUTFILE_NAME2}" using template "TC2_002_TMBAM_AOI_Template.csv" from location "${TESTDATA_PATH}/inputfiles"


  Scenario: Load TMBAM Transaction Data File

    When I copy files below from local folder "${TESTDATA_PATH}/inputfiles/testdata" to the host "dmp.ssh.inbound" folder "${dmp.ssh.inbound.path}":
      | ${INPUTFILE_NAME1} |

    And I process files with below parameters and wait for the job to be completed
      | FILE_PATTERN  | ${INPUTFILE_NAME1} |
      | MESSAGE_TYPE  | EIS_MT_TMBAM_DMP_TXN |
      | BUSINESS_FEED |                    |

    Then I extract new job id from jblg table into a variable "JOB_ID1"

    And I expect value of column "JBLG_ROW_COUNT" in the below SQL query equals to "1":
    """
    SELECT count(*) as JBLG_ROW_COUNT FROM FT_T_JBLG
    WHERE JOB_ID = '${JOB_ID1}'
    AND JOB_STAT_TYP ='CLOSED'
    """

  Scenario: Publish Transactions Report

    Given I remove below files with pattern in the host "dmp.ssh.inbound" from folder "${PUBLISHING_DIRECTORY}" if exists:
      | ${PUBLISHING_FILE_NAME1}*.csv |

    And I process publishing wrapper with below parameters and wait for the job to be completed
      | PUBLISHING_FILE_NAME | ${PUBLISHING_FILE_NAME1}.csv          |
      | SUBSCRIPTION_NAME    | EIS_DMP_TO_FUNDAPPS_TRANSACTION_SUB |
      | AOI_PROCESSING       | true                                  |

    Then I expect below files to be present in the host "dmp.ssh.inbound" into folder "${PUBLISHING_DIRECTORY}" after processing:
      | ${PUBLISHING_FILE_NAME1}_${VAR_SYSDATE}_1.csv |

    Then I copy files below from remote folder "${PUBLISHING_DIRECTORY}" on host "dmp.ssh.inbound" into local folder "${TESTDATA_PATH}/outfiles/runtime":
      | ${PUBLISHING_FILE_NAME1}_${VAR_SYSDATE}_1.csv |

    Then I remove below files with pattern in the host "dmp.ssh.inbound" from folder "${PUBLISHING_DIRECTORY}" if exists:
      | ${PUBLISHING_FILE_NAME1} |

  Scenario: Verify Published Transactions

    Given I expect value of column "PUB_TRAN_COUNT" in the below SQL query equals to "5":
    """
    SELECT COUNT(*) AS PUB_TRAN_COUNT FROM FT_T_PBAT PBAT, FT_T_EXTR EXTR
    WHERE PBAT.SBEX_OID IN
    (
    SELECT SBEX_OID AS RUNTIME_PUB_TMS FROM (SELECT SUBSCRIPTION_NME,START_TMS,SBEX_OID, ROW_NUMBER()
    OVER (PARTITION BY SUBSCRIPTION_NME ORDER BY START_TMS DESC) AS RECORD_ORDER
    FROM FT_V_PUB1
    WHERE PUB_STATUS = 'CLOSED' AND SUBSCRIPTION_NME = 'EIS_DMP_TO_FUNDAPPS_TRANSACTION_SUB') WHERE RECORD_ORDER =1
    )
    AND PBAT.PUBLISHED_TBL_ID = 'EXTR'
    AND PBAT.PUB_CROSS_REF_ID = EXTR.EXEC_TRD_ID
    AND EXTR.TRD_ID LIKE '%4954TC2TRN%${TRD_VAR_NUM}'
    """

  Scenario: Load TMBAM Transaction Data File with Updated Quantity

    When I copy files below from local folder "${TESTDATA_PATH}/inputfiles/testdata" to the host "dmp.ssh.inbound" folder "${dmp.ssh.inbound.path}":
      | ${INPUTFILE_NAME2} |

    And I process files with below parameters and wait for the job to be completed
      | FILE_PATTERN  | ${INPUTFILE_NAME2} |
      | MESSAGE_TYPE  | EIS_MT_TMBAM_DMP_TXN |
      | BUSINESS_FEED |                    |

    Then I extract new job id from jblg table into a variable "JOB_ID2"

    And I expect value of column "JBLG_ROW_COUNT" in the below SQL query equals to "1":
    """
    SELECT count(*) as JBLG_ROW_COUNT FROM FT_T_JBLG
    WHERE JOB_ID = '${JOB_ID2}'
    AND JOB_STAT_TYP ='CLOSED'
    """

  Scenario: Publish Transactions Report

    Given I remove below files with pattern in the host "dmp.ssh.inbound" from folder "${PUBLISHING_DIRECTORY}" if exists:
      | ${PUBLISHING_FILE_NAME2}*.csv |

    And I process publishing wrapper with below parameters and wait for the job to be completed
      | PUBLISHING_FILE_NAME | ${PUBLISHING_FILE_NAME2}.csv          |
      | SUBSCRIPTION_NAME    | EIS_DMP_TO_FUNDAPPS_TRANSACTION_SUB |
      | AOI_PROCESSING       | true                                  |


    Then I expect below files to be present in the host "dmp.ssh.inbound" into folder "${PUBLISHING_DIRECTORY}" after processing:
      | ${PUBLISHING_FILE_NAME2}_${VAR_SYSDATE}_1.csv |

    Then I copy files below from remote folder "${PUBLISHING_DIRECTORY}" on host "dmp.ssh.inbound" into local folder "${TESTDATA_PATH}/outfiles/runtime":
      | ${PUBLISHING_FILE_NAME2}_${VAR_SYSDATE}_1.csv |

    Then I remove below files with pattern in the host "dmp.ssh.inbound" from folder "${PUBLISHING_DIRECTORY}" if exists:
      | ${PUBLISHING_FILE_NAME2}* |

  Scenario: Verify Published Transactions based on AOI Configuration

    Given I expect value of column "PUB_AOI_TRAN_COUNT" in the below SQL query equals to "4":
    """
    SELECT COUNT(*) AS PUB_AOI_TRAN_COUNT FROM FT_T_PBAT PBAT, FT_T_EXTR EXTR
    WHERE PBAT.SBEX_OID IN
    (
    SELECT SBEX_OID AS RUNTIME_PUB_TMS FROM (SELECT SUBSCRIPTION_NME,START_TMS,SBEX_OID, ROW_NUMBER()
    OVER (PARTITION BY SUBSCRIPTION_NME ORDER BY START_TMS DESC) AS RECORD_ORDER
    FROM FT_V_PUB1
    WHERE PUB_STATUS = 'CLOSED' AND SUBSCRIPTION_NME = 'EIS_DMP_TO_FUNDAPPS_TRANSACTION_SUB') WHERE RECORD_ORDER =1
    )
    AND PBAT.PUBLISHED_TBL_ID = 'EXTR'
    AND PBAT.PUB_CROSS_REF_ID = EXTR.EXEC_TRD_ID
    AND EXTR.TRD_ID LIKE '%4954TC2TRN%${TRD_VAR_NUM}'
    """