# ===============================================================================================
# Date            JIRA        Comments
# ===============================================================================================
# 23/06/2019      TOM-4698    SSDR Data Reports - Transactions
# ===============================================================================================

@fund_apps  @tom_4698 @dmp_fundapps_regression @tom_5000 @tom_5148
Feature: 001 | FundApps | Data Report | Verify Transactions Data Report

  This report should contain delta data for all the transactions received between last published report and publish time
  In scope transactions are those received from the below sources
  ESGA, KOREA, PPM, ESJP, TMBAM, MNG, WFOE, BOCI, BRS
  #Removing M&G transactions due to demerger

  Scenario: Assign Variables
    Given I assign "tests/test-data/dmp-interfaces/FundApps/Regression/Outbound/DataReport_Transactions" to variable "TESTDATA_PATH"
    And I assign "/dmp/out/eis/datareports" to variable "PUBLISHING_DIRECTORY"
    And I assign "TC01_SSDR_Transaction_Report" to variable "PUBLISHING_FILE_NAME"
    And I generate value with date format "YYYYMMdd" and assign to variable "VAR_SYSDATE"
    And I assign "TC1_001_BRS_EOD_NONLATAM.xml" to variable "INPUTFILE_NAME1"
    And I assign "TC1_002_BOCIEISLTRANSN.csv" to variable "INPUTFILE_NAME2"
    And I assign "TC1_003_EIMKEISLTRANSN.csv" to variable "INPUTFILE_NAME3"
    And I assign "TC1_004_ESGAEISLTRANSN.csv" to variable "INPUTFILE_NAME4"
    And I assign "TC1_005_ESJPEISLTRANSN.csv" to variable "INPUTFILE_NAME5"
    And I assign "TC1_006_JNAMEISLTRANSN.csv" to variable "INPUTFILE_NAME6"
    And I assign "TC1_008_TMBAMEISLTRAN.csv" to variable "INPUTFILE_NAME8"
    And I assign "TC1_009_WFOEEISLTRANSN.csv" to variable "INPUTFILE_NAME9"

    And I execute below query and extract values of "CURR_DATE" into same variables
     """
     select TO_CHAR(sysdate, 'DD/MM/YYYY') AS CURR_DATE from dual
     """

    And I execute below query and extract values of "CURR_DATE_1" into same variables
     """
     select TO_CHAR(sysdate+1, 'DD/MM/YYYY') AS CURR_DATE_1 from dual
     """

    And I execute below query and extract values of "CURR_DATE_2" into same variables
     """
     select TO_CHAR(sysdate, 'MM/DD/YYYY') AS CURR_DATE_2 from dual
     """

    And I execute below query and extract values of "CURR_DATE_3" into same variables
     """
     select TO_CHAR(sysdate+1, 'MM/DD/YYYY') AS CURR_DATE_3 from dual
     """

    And I execute below query and extract values of "TRD_VAR_NUM" into same variables
        """
        SELECT LPAD(VREQ_FILE_SEQ.NEXTVAL+1,8,'0') AS TRD_VAR_NUM FROM DUAL
        """

    And I create input file "${INPUTFILE_NAME1}" using template "TC1_001_BRS_EOD_NONLATAM_Template.xml" with below codes from location "${TESTDATA_PATH}/inputfiles"
      |  |  |

    And I create input file "${INPUTFILE_NAME2}" using template "TC1_002_BOCIEISLTRANSN_Template.csv" with below codes from location "${TESTDATA_PATH}/inputfiles"
      |  |  |

    And I create input file "${INPUTFILE_NAME3}" using template "TC1_003_EIMKEISLTRANSN_Template.csv" with below codes from location "${TESTDATA_PATH}/inputfiles"
      |  |  |

    And I create input file "${INPUTFILE_NAME4}" using template "TC1_004_ESGAEISLTRANSN_Template.csv" with below codes from location "${TESTDATA_PATH}/inputfiles"
      |  |  |

    And I create input file "${INPUTFILE_NAME5}" using template "TC1_005_ESJPEISLTRANSN_Template.csv" with below codes from location "${TESTDATA_PATH}/inputfiles"
      |  |  |

    And I create input file "${INPUTFILE_NAME6}" using template "TC1_006_JNAMEISLTRANSN_Template.csv" with below codes from location "${TESTDATA_PATH}/inputfiles"
      |  |  |

    And I create input file "${INPUTFILE_NAME8}" using template "TC1_008_TMBAMEISLTRAN_Template.csv" with below codes from location "${TESTDATA_PATH}/inputfiles"
      |  |  |

    And I create input file "${INPUTFILE_NAME9}" using template "TC1_009_WFOEEISLTRANSN_Template.csv" with below codes from location "${TESTDATA_PATH}/inputfiles"
      |  |  |

  #Publish Transaction Loaded from Other feature file.
  Scenario: Publish Transactions Report

    Given I remove below files with pattern in the host "dmp.ssh.inbound" from folder "${PUBLISHING_DIRECTORY}" if exists:
      | ${PUBLISHING_FILE_NAME}*.csv |

    And I process publishing wrapper with below parameters and wait for the job to be completed
      | PUBLISHING_FILE_NAME | ${PUBLISHING_FILE_NAME}.csv           |
      | SUBSCRIPTION_NAME    | EIS_DMP_TO_TRANSACTION_DATAREPORT_SUB |
      | AOI_PROCESSING       | true                                  |
      | COLUMN_SEPARATOR     | ,                                     |
      | COLUMN_TO_SORT       | 3                                     |

    Then I remove below files with pattern in the host "dmp.ssh.inbound" from folder "${PUBLISHING_DIRECTORY}" if exists:
      | ${PUBLISHING_FILE_NAME}* |

  Scenario: Load ADX TRAN File

    When I copy files below from local folder "${TESTDATA_PATH}/inputfiles/testdata" to the host "dmp.ssh.inbound" folder "${dmp.ssh.inbound.path}":
      | ${INPUTFILE_NAME1} |

    And I process files with below parameters and wait for the job to be completed
      | FILE_PATTERN  | ${INPUTFILE_NAME1}                   |
      | MESSAGE_TYPE  | EIS_MT_BRS_EOD_TRANSACTION_NON_LATAM |
      | BUSINESS_FEED |                                      |

    Then I extract new job id from jblg table into a variable "JOB_ID1"

    And I expect value of column "JBLG_ROW_COUNT" in the below SQL query equals to "1":
    """
    SELECT count(*) as JBLG_ROW_COUNT FROM FT_T_JBLG
    WHERE JOB_ID = '${JOB_ID1}'
    AND JOB_STAT_TYP ='CLOSED'
    """

  Scenario: Load BOCI Transaction Data File

    When I copy files below from local folder "${TESTDATA_PATH}/inputfiles/testdata" to the host "dmp.ssh.inbound" folder "${dmp.ssh.inbound.path}":
      | ${INPUTFILE_NAME2} |

    And I process files with below parameters and wait for the job to be completed
      | FILE_PATTERN  | ${INPUTFILE_NAME2}  |
      | MESSAGE_TYPE  | EIS_MT_BOCI_DMP_TXN |
      | BUSINESS_FEED |                     |

    Then I extract new job id from jblg table into a variable "JOB_ID2"

    And I expect value of column "JBLG_ROW_COUNT" in the below SQL query equals to "1":
    """
    SELECT count(*) as JBLG_ROW_COUNT FROM FT_T_JBLG
    WHERE JOB_ID = '${JOB_ID2}'
    AND JOB_STAT_TYP ='CLOSED'
    """

  Scenario: Load EIMK Transaction Data File

    When I copy files below from local folder "${TESTDATA_PATH}/inputfiles/testdata" to the host "dmp.ssh.inbound" folder "${dmp.ssh.inbound.path}":
      | ${INPUTFILE_NAME3} |

    And I process files with below parameters and wait for the job to be completed
      | FILE_PATTERN  | ${INPUTFILE_NAME3}  |
      | MESSAGE_TYPE  | EIS_MT_EIMK_DMP_TXN |
      | BUSINESS_FEED |                     |

    Then I extract new job id from jblg table into a variable "JOB_ID3"

    And I expect value of column "JBLG_ROW_COUNT" in the below SQL query equals to "1":
    """
    SELECT count(*) as JBLG_ROW_COUNT FROM FT_T_JBLG
    WHERE JOB_ID = '${JOB_ID3}'
    AND JOB_STAT_TYP ='CLOSED'
    """

  Scenario: Load ESGA Transaction Data File

    When I copy files below from local folder "${TESTDATA_PATH}/inputfiles/testdata" to the host "dmp.ssh.inbound" folder "${dmp.ssh.inbound.path}":
      | ${INPUTFILE_NAME4} |

    And I process files with below parameters and wait for the job to be completed
      | FILE_PATTERN  | ${INPUTFILE_NAME4}  |
      | MESSAGE_TYPE  | EIS_MT_ESGA_DMP_TXN |
      | BUSINESS_FEED |                     |

    Then I extract new job id from jblg table into a variable "JOB_ID4"

    And I expect value of column "JBLG_ROW_COUNT" in the below SQL query equals to "1":
    """
    SELECT count(*) as JBLG_ROW_COUNT FROM FT_T_JBLG
    WHERE JOB_ID = '${JOB_ID4}'
    AND JOB_STAT_TYP ='CLOSED'
    """

  Scenario: Load ESJP Transaction Data File

    When I copy files below from local folder "${TESTDATA_PATH}/inputfiles/testdata" to the host "dmp.ssh.inbound" folder "${dmp.ssh.inbound.path}":
      | ${INPUTFILE_NAME5} |

    And I process files with below parameters and wait for the job to be completed
      | FILE_PATTERN  | ${INPUTFILE_NAME5}  |
      | MESSAGE_TYPE  | EIS_MT_ESJP_DMP_TXN |
      | BUSINESS_FEED |                     |

    Then I extract new job id from jblg table into a variable "JOB_ID5"

    And I expect value of column "JBLG_ROW_COUNT" in the below SQL query equals to "1":
    """
    SELECT count(*) as JBLG_ROW_COUNT FROM FT_T_JBLG
    WHERE JOB_ID = '${JOB_ID5}'
    AND JOB_STAT_TYP ='CLOSED'
    """

  Scenario: Load JNAM Transaction Data File

    When I copy files below from local folder "${TESTDATA_PATH}/inputfiles/testdata" to the host "dmp.ssh.inbound" folder "${dmp.ssh.inbound.path}":
      | ${INPUTFILE_NAME6} |

    And I process files with below parameters and wait for the job to be completed
      | FILE_PATTERN  | ${INPUTFILE_NAME6}  |
      | MESSAGE_TYPE  | EIS_MT_JNAM_DMP_TXN |
      | BUSINESS_FEED |                     |

    Then I extract new job id from jblg table into a variable "JOB_ID6"

    And I expect value of column "JBLG_ROW_COUNT" in the below SQL query equals to "1":
    """
    SELECT count(*) as JBLG_ROW_COUNT FROM FT_T_JBLG
    WHERE JOB_ID = '${JOB_ID6}'
    AND JOB_STAT_TYP ='CLOSED'
    """

  Scenario: Load TMBAM Transaction Data File

    When I copy files below from local folder "${TESTDATA_PATH}/inputfiles/testdata" to the host "dmp.ssh.inbound" folder "${dmp.ssh.inbound.path}":
      | ${INPUTFILE_NAME8} |

    And I process files with below parameters and wait for the job to be completed
      | FILE_PATTERN  | ${INPUTFILE_NAME8}   |
      | MESSAGE_TYPE  | EIS_MT_TMBAM_DMP_TXN |
      | BUSINESS_FEED |                      |

    Then I extract new job id from jblg table into a variable "JOB_ID8"

    And I expect value of column "JBLG_ROW_COUNT" in the below SQL query equals to "1":
    """
    SELECT count(*) as JBLG_ROW_COUNT FROM FT_T_JBLG
    WHERE JOB_ID = '${JOB_ID8}'
    AND JOB_STAT_TYP ='CLOSED'
    """

  Scenario: Load WFOE Transaction Data File

    When I copy files below from local folder "${TESTDATA_PATH}/inputfiles/testdata" to the host "dmp.ssh.inbound" folder "${dmp.ssh.inbound.path}":
      | ${INPUTFILE_NAME9} |

    And I process files with below parameters and wait for the job to be completed
      | FILE_PATTERN  | ${INPUTFILE_NAME9}  |
      | MESSAGE_TYPE  | EIS_MT_WFOE_DMP_TXN |
      | BUSINESS_FEED |                     |

    Then I extract new job id from jblg table into a variable "JOB_ID9"

    And I expect value of column "JBLG_ROW_COUNT" in the below SQL query equals to "1":
    """
    SELECT count(*) as JBLG_ROW_COUNT FROM FT_T_JBLG
    WHERE JOB_ID = '${JOB_ID9}'
    AND JOB_STAT_TYP ='CLOSED'
    """

  Scenario: Publish Transactions Report

    Given I remove below files with pattern in the host "dmp.ssh.inbound" from folder "${PUBLISHING_DIRECTORY}" if exists:
      | ${PUBLISHING_FILE_NAME}_*.csv |

    And I process publishing wrapper with below parameters and wait for the job to be completed
      | PUBLISHING_FILE_NAME | ${PUBLISHING_FILE_NAME}.csv           |
      | SUBSCRIPTION_NAME    | EIS_DMP_TO_TRANSACTION_DATAREPORT_SUB |
      | AOI_PROCESSING       | true                                  |
      | COLUMN_SEPARATOR     | ,                                     |
      | COLUMN_TO_SORT       | 3                                     |

    Then I expect below files to be present in the host "dmp.ssh.inbound" into folder "${PUBLISHING_DIRECTORY}" after processing:
      | ${PUBLISHING_FILE_NAME}_${VAR_SYSDATE}_1.csv |

    Then I copy files below from remote folder "${PUBLISHING_DIRECTORY}" on host "dmp.ssh.inbound" into local folder "${TESTDATA_PATH}/outfiles/runtime":
      | ${PUBLISHING_FILE_NAME}_${VAR_SYSDATE}_1.csv |

    Then I remove below files with pattern in the host "dmp.ssh.inbound" from folder "${PUBLISHING_DIRECTORY}" if exists:
      | ${PUBLISHING_FILE_NAME}*.csv |

  Scenario: Verify Published Transactions

    Given I expect value of column "PUB_TRAN_COUNT" in the below SQL query equals to "8":
    """
    SELECT COUNT(*) AS PUB_TRAN_COUNT FROM FT_T_PBAT PBAT, FT_T_EXTR EXTR
    WHERE PBAT.SBEX_OID IN
    (
    SELECT SBEX_OID AS RUNTIME_PUB_TMS FROM (SELECT SUBSCRIPTION_NME,START_TMS,SBEX_OID, ROW_NUMBER()
    OVER (PARTITION BY SUBSCRIPTION_NME ORDER BY START_TMS DESC) AS RECORD_ORDER
    FROM FT_V_PUB1
    WHERE PUB_STATUS = 'CLOSED' AND SUBSCRIPTION_NME = 'EIS_DMP_TO_TRANSACTION_DATAREPORT_SUB') WHERE RECORD_ORDER =1
    )
    AND PBAT.PUBLISHED_TBL_ID = 'EXTR'
    AND PBAT.PUB_CROSS_REF_ID = EXTR.EXEC_TRD_ID
    AND EXTR.TRD_ID LIKE '%4698TC1TRN%${TRD_VAR_NUM}'
    """