#https://jira.intranet.asia/browse/TOM-4954
#This development is to create an outbound transaction file which will be consumed by FundApps. The extract criteria of this file is same to that of FundApps Transaction data reports and the same gso has been used
#This development item also removes from the filter criteria intraday transactions which came as a change and TOM-5030 is the JIRA for the same
#TOM-5184: Removing MNG related transactions due to demerger

@tom_4954 @fa_txn @tom_5184

Feature: 001 | FundApps | Transaction file sent to FundApps

  This report should contain delta data for all the transactions received between last published report and publish time
  In scope transactions are those received from the below sources
  ESGA, KOREA, MNG, BRS

  Scenario: Assign Variables
    Given I assign "tests/test-data/dmp-interfaces/FundApps/Functional/Outbound/Outbound_FA_Txn" to variable "TESTDATA_PATH"
    And I assign "/dmp/out/fundapps" to variable "PUBLISHING_DIRECTORY"
    And I assign "FA_Txn" to variable "PUBLISHING_FILE_NAME"
    And I generate value with date format "YYYYMMdd" and assign to variable "VAR_SYSDATE"
    And I assign "TC1_001_BRSEOD.xml" to variable "INPUTFILE_NAME1"
    And I assign "TC2_002_JPNTXN.csv" to variable "INPUTFILE_NAME2"
    And I assign "TC3_003_KORTXN.csv" to variable "INPUTFILE_NAME3"

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

    And I create input file "${INPUTFILE_NAME1}" using template "TC1_001_BRSEOD_Template.xml" from location "${TESTDATA_PATH}/inputfiles"

    And I create input file "${INPUTFILE_NAME2}" using template "TC2_002_JPNTXN_Template.csv" from location "${TESTDATA_PATH}/inputfiles"

    And I create input file "${INPUTFILE_NAME3}" using template "TC3_003_KORTXN_Template.csv" from location "${TESTDATA_PATH}/inputfiles"


  #Publish Transaction Loaded from Other feature file.
  Scenario: Publish Transactions Report

    Given I remove below files with pattern in the host "dmp.ssh.inbound" from folder "${PUBLISHING_DIRECTORY}" if exists:
      | ${PUBLISHING_FILE_NAME}*.csv |

    And I process publishing wrapper with below parameters and wait for the job to be completed
      | PUBLISHING_FILE_NAME | ${PUBLISHING_FILE_NAME}.csv         |
      | SUBSCRIPTION_NAME    | EIS_DMP_TO_FUNDAPPS_TRANSACTION_SUB |
      | AOI_PROCESSING       | true                                |

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

  Scenario: Load ESJP Transaction Data File

    When I copy files below from local folder "${TESTDATA_PATH}/inputfiles/testdata" to the host "dmp.ssh.inbound" folder "${dmp.ssh.inbound.path}":
      | ${INPUTFILE_NAME2} |

    And I process files with below parameters and wait for the job to be completed
      | FILE_PATTERN  | ${INPUTFILE_NAME2}  |
      | MESSAGE_TYPE  | EIS_MT_ESJP_DMP_TXN |
      | BUSINESS_FEED |                     |

    Then I extract new job id from jblg table into a variable "JOB_ID5"

    And I expect value of column "JBLG_ROW_COUNT" in the below SQL query equals to "1":
    """
    SELECT count(*) as JBLG_ROW_COUNT FROM FT_T_JBLG
    WHERE JOB_ID = '${JOB_ID5}'
    AND JOB_STAT_TYP ='CLOSED'
    """

  Scenario: Load KORTXN Transaction Data File (Korea Txn)

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

  Scenario: Publish Transactions Report

    Given I remove below files with pattern in the host "dmp.ssh.inbound" from folder "${PUBLISHING_DIRECTORY}" if exists:
      | ${PUBLISHING_FILE_NAME}_*.csv |

    And I process publishing wrapper with below parameters and wait for the job to be completed
      | PUBLISHING_FILE_NAME | ${PUBLISHING_FILE_NAME}.csv         |
      | SUBSCRIPTION_NAME    | EIS_DMP_TO_FUNDAPPS_TRANSACTION_SUB |
      | AOI_PROCESSING       | true                                |


    Then I expect below files to be present in the host "dmp.ssh.inbound" into folder "${PUBLISHING_DIRECTORY}" after processing:
      | ${PUBLISHING_FILE_NAME}_${VAR_SYSDATE}_1.csv |

    Then I copy files below from remote folder "${PUBLISHING_DIRECTORY}" on host "dmp.ssh.inbound" into local folder "${TESTDATA_PATH}/outfiles/runtime":
      | ${PUBLISHING_FILE_NAME}_${VAR_SYSDATE}_1.csv |

    Then I remove below files with pattern in the host "dmp.ssh.inbound" from folder "${PUBLISHING_DIRECTORY}" if exists:
      | ${PUBLISHING_FILE_NAME}*.csv |

  Scenario: Verify Published Transactions

    Given I expect value of column "PUB_TRAN_COUNT" in the below SQL query equals to "2":
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
    AND EXTR.TRD_ID LIKE '%4954TC1TRN%${TRD_VAR_NUM}'
    """