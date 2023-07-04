#https://jira.pruconnect.net/browse/EISDEV-6235
#Architectue Requirement: https://collaborate.pruconnect.net/display/support/SSDR+FundApps+Architecture?src=jira
#Functional specification : https://collaborate.pruconnect.net/pages/viewpage.action?spaceKey=EISTT&title=TH+SSDR+Changes%7CFund%7CPosition%7CTransaction
#Feature file not applicable after the Thailand go live

@ignore
@eisdev_6235 @001_th_fundapps_transaction @dmp_thailand_fundapps @eisdev_6725 @eisdev_6780
Feature: 001 | Thailand FundApps | Transaction file sent to FundApps

  This interface helps to validate the FundApps Transaction file Production exclusion and UAT exclusion portfolio along with AOI(i.e Attributes of Interest) for Thailand Parallel
  Production Setup :
  Account group  : FAPRDEXCLPORT -  FundApps Production Excluded Portfolios       - Helps to define the list of portfolio
  IDMV  - FLD ID : FATXNPRD      -  FundApps Production Excluded Transaction Code - Helps to define the source(example BRSEOD)

  UAT  Setup     :
  Account group  : FAUATEXCLPORT -  FundApps UAT Excluded Portfolios       - Helps to define the list of portfolio
  IDMV  - FLD ID : FATXNPRD      -  FundApps UAT Excluded Transaction Code - Helps to define the source(example THANAEOD, TMBAMEOD)

  This report should contain delta data for all the transactions received between last published report and publish time
  In scope transactions are those received from the below sources
  BRS- 3 rows, KOREA - 2 rows, TMBAM - 2 rows, TFUND - 2 rows

  We tests the following Scenario with this feature file.
  1.Scenario TC2: Load BRS ADX Transaction File, it contains 3 rows and have following funds AGSALA, 227 and TB3.
  AGSALA - published in both UAT and Production file.  227 and TB3 - published in UAT only.
  2.Scenario TC3: Load KOREA Transaction Data File, it contains 2 rows, these rows should published in both UAT and Production file.
  3.Scenario TC4: Load TMBAM Transaction Data File, it contains 2 rows. these rows should published production only.
  4.Scenario TC5: Load TFUND Transaction Data File, it contains 2 rows. these rows should published production only.
  5.Scenario:TC6, TC7 and TC88 : Publish and Verify Production Transactions rows. it should be 7 rows.
  (BRS - 1, KOREA-2, TMBAM-2 and TFUND-2)
  6.Scenario:TC9, TC10 and TC11 : Publish and Verify UAT Transactions rows. it should be 5 rows.
  (BRS - 3, KOREA-2, TMBAM-0 and TFUND-0)

  Scenario:TC1: Initialize variables and create account participants for FAPRDEXCLPORT, FAUATEXCLPORT
    Given I assign "tests/test-data/dmp-interfaces/Thailand/FundApps/Transactions/Outbound" to variable "TESTDATA_PATH"
    And I assign "/dmp/out/fundapps" to variable "PUBLISHING_DIRECTORY"
    And I assign "001_FA_IN_TXN8_ESIToFA_PROD_Tranactions" to variable "PUBLISHING_PROD_FILE_NAME"
    And I assign "001_FA_IN_TXN8_ESIToFA_UAT_Transactions" to variable "PUBLISHING_UAT_FILE_NAME"
    And I assign "001_FA_IN_TXN8_ESIToFA_PROD_Transactions_Expected.csv" to variable "EXPECTED_PROD_PUBLISHED_FILENAME"
    And I assign "001_FA_IN_TXN8_ESIToFA_UAT_Transactions_Expected.csv" to variable "EXPECTED_UAT_PUBLISHED_FILENAME"
    And I generate value with date format "YYYYMMdd" and assign to variable "VAR_SYSDATE"
    And I assign "001_FA.IN-TXN8_DMP_FundApps_BRSEOD.xml" to variable "INPUTFILE_NAME_BRS"
    And I assign "001_FA.IN-TXN8_DMP_FundApps_KORTXN.csv" to variable "INPUTFILE_NAME_KOREA"
    And I assign "001_FA.IN-TXN8_DMP_FundApps_TMBAM.csv" to variable "INPUTFILE_NAME_TMBAM"
    And I assign "001_FA.IN-TXN8_DMP_FundApps_TFUND.csv" to variable "INPUTFILE_NAME_TFUND"

    And I execute below query and extract values of "CURR_DATE;CURR_DATE_1;CURR_DATE_2;CURR_DATE_3;CURR_DATE_4" into same variables
     """
     select TO_CHAR(sysdate, 'DD/MM/YYYY') AS CURR_DATE, TO_CHAR(sysdate+1, 'DD/MM/YYYY') AS CURR_DATE_1,
     TO_CHAR(sysdate, 'MM/DD/YYYY') AS CURR_DATE_2, TO_CHAR(sysdate+1, 'MM/DD/YYYY') AS CURR_DATE_3,TO_CHAR(sysdate, 'YYYY-MM-DD') AS CURR_DATE_4
     from dual
     """

    And I execute below query and extract values of "TRD_VAR_NUM_1" into same variables
     """
     SELECT LPAD(VREQ_FILE_SEQ.NEXTVAL+1,8,'0') AS TRD_VAR_NUM_1 FROM DUAL
     """

    And I execute below query and extract values of "VAR_EISSLSTID" into same variables
     """
     SELECT ISS_ID AS VAR_EISSLSTID FROM FT_T_ISID
     WHERE INSTR_ID IN
        (SELECT INSTR_ID FROM FT_T_ISID WHERE ISS_ID ='TH0268010Z03')
     AND ID_CTXT_TYP='EISLSTID'
     AND END_TMS IS NULL
     """

    And I assign "'TB3','227'" to variable "PROD_PORTFOLIO_EXCLUSION"
    And I assign "'TB3','227','243','LF6'" to variable "UAT_PORTFOLIO_EXCLUSION"

    #Pre-requisite : Insert row into ACGP for FAPRDEXCLPORT & FAPRDEXCLPORT group
    And I execute below query to create paticipants for FAPRDEXCLPORT & FAPRDEXCLPORT
    """
    ${TESTDATA_PATH}/sql/InsertIntoACGPTable.sql
    """

    And I create input file "${INPUTFILE_NAME_BRS}" using template "001_FA.IN-TXN8_DMP_FundApps_BRSEOD_Template.xml" from location "${TESTDATA_PATH}/inputfiles"

    And I create input file "${INPUTFILE_NAME_KOREA}" using template "001_FA.IN-TXN8_DMP_FundApps_KORTXN_Template.csv" from location "${TESTDATA_PATH}/inputfiles"

    And I create input file "${INPUTFILE_NAME_TMBAM}" using template "001_FA.IN-TXN8_DMP_FundApps_TMBAM_Template.csv" from location "${TESTDATA_PATH}/inputfiles"

    And I create input file "${INPUTFILE_NAME_TFUND}" using template "001_FA.IN-TXN8_DMP_FundApps_TFUND_Template.csv" from location "${TESTDATA_PATH}/inputfiles"

    And I create input file "${EXPECTED_PROD_PUBLISHED_FILENAME}" using template "001_FA_IN_TXN8_ESIToFA_PROD_Transactions_Expected_Template.csv" from location "${TESTDATA_PATH}/outfiles"

    And I create input file "${EXPECTED_UAT_PUBLISHED_FILENAME}" using template "001_FA_IN_TXN8_ESIToFA_UAT_Transactions_Expected_Template.csv" from location "${TESTDATA_PATH}/outfiles"


  Scenario:TC2: Load BRS ADX Transaction File

    Given I process "${TESTDATA_PATH}/inputfiles/testdata/${INPUTFILE_NAME_BRS}" file with below parameters
      | FILE_PATTERN  | ${INPUTFILE_NAME_BRS}                |
      | MESSAGE_TYPE  | EIS_MT_BRS_EOD_TRANSACTION_NON_LATAM |
      | BUSINESS_FEED |                                      |

    Then I expect workflow is processed in DMP with total record count as "3"

  Scenario:TC3: Load KOREA Transaction Data File

    Given I process "${TESTDATA_PATH}/inputfiles/testdata/${INPUTFILE_NAME_KOREA}" file with below parameters
      | FILE_PATTERN  | ${INPUTFILE_NAME_KOREA} |
      | MESSAGE_TYPE  | EIS_MT_EIMK_DMP_TXN     |
      | BUSINESS_FEED |                         |

    Then I expect workflow is processed in DMP with total record count as "2"

  Scenario:TC4: Load TMBAM Transaction Data File

    Given I process "${TESTDATA_PATH}/inputfiles/testdata/${INPUTFILE_NAME_TMBAM}" file with below parameters
      | FILE_PATTERN  | ${INPUTFILE_NAME_TMBAM} |
      | MESSAGE_TYPE  | EIS_MT_TMBAM_DMP_TXN    |
      | BUSINESS_FEED |                         |

    Then I expect workflow is processed in DMP with total record count as "2"

  Scenario:TC5: Load TFUND Transaction Data File

    Given I process "${TESTDATA_PATH}/inputfiles/testdata/${INPUTFILE_NAME_TFUND}" file with below parameters
      | FILE_PATTERN  | ${INPUTFILE_NAME_TFUND} |
      | MESSAGE_TYPE  | EIS_MT_THANA_DMP_TXN    |
      | BUSINESS_FEED |                         |

    Then I expect workflow is processed in DMP with total record count as "2"

  Scenario:TC6: Publish Production Transactions Report

    Given I remove below files with pattern in the host "dmp.ssh.inbound" from folder "${PUBLISHING_DIRECTORY}" if exists:
      | ${PUBLISHING_PROD_FILE_NAME}_*.csv |

    And I process publishing wrapper with below parameters and wait for the job to be completed
      | PUBLISHING_FILE_NAME | ${PUBLISHING_PROD_FILE_NAME}.csv    |
      | SUBSCRIPTION_NAME    | EIS_DMP_TO_FUNDAPPS_TRANSACTION_SUB |
      | AOI_PROCESSING       | true                                |

    Then I expect below files to be present in the host "dmp.ssh.inbound" into folder "${PUBLISHING_DIRECTORY}" after processing:
      | ${PUBLISHING_PROD_FILE_NAME}_${VAR_SYSDATE}_1.csv |

    Then I copy files below from remote folder "${PUBLISHING_DIRECTORY}" on host "dmp.ssh.inbound" into local folder "${TESTDATA_PATH}/outfiles/actual":
      | ${PUBLISHING_PROD_FILE_NAME}_${VAR_SYSDATE}_1.csv |

    Then I remove below files with pattern in the host "dmp.ssh.inbound" from folder "${PUBLISHING_DIRECTORY}" if exists:
      | ${PUBLISHING_PROD_FILE_NAME}*.csv |

  Scenario: TC7: Check if Production published file contains all the records which were in expected file

    Given I capture current time stamp into variable "recon.timestamp"
    Then I expect each record in file "${TESTDATA_PATH}/outfiles/testdata/${EXPECTED_PROD_PUBLISHED_FILENAME}" should exist in file "${TESTDATA_PATH}/outfiles/actual/${PUBLISHING_PROD_FILE_NAME}_${VAR_SYSDATE}_1.csv" and exceptions to be written to "${TESTDATA_PATH}/outfiles/actual/ESITOFA_PROD_TRANSACTION_EXCEPTIONS_${recon.timestamp}.csv" file

  Scenario:TC8: Verify Published Production Transactions

    Given I expect value of column "PUB_TRAN_COUNT" in the below SQL query equals to "7":
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
    AND EXTR.TRD_ID in ('3130-BRSFATRN001${TRD_VAR_NUM_1}','3103-BRSFATRN002${TRD_VAR_NUM_1}','3196-BRSFATRN003${TRD_VAR_NUM_1}',
    'KRFATRN001${TRD_VAR_NUM_1}', 'KRFATRN002${TRD_VAR_NUM_1}',
    'TFFATRN001${TRD_VAR_NUM_1}', 'TFFATRN002${TRD_VAR_NUM_1}',
    'TMFATRN001${TRD_VAR_NUM_1}', 'TMFATRN002${TRD_VAR_NUM_1}')
    """

  Scenario:TC9: Publish UAT Transactions Report

    Given I remove below files with pattern in the host "dmp.ssh.inbound" from folder "${PUBLISHING_DIRECTORY}" if exists:
      | ${PUBLISHING_UAT_FILE_NAME}_*.csv |

    And I process publishing wrapper with below parameters and wait for the job to be completed
      | PUBLISHING_FILE_NAME | ${PUBLISHING_UAT_FILE_NAME}.csv         |
      | SUBSCRIPTION_NAME    | EIS_DMP_TO_FUNDAPPS_TRANSACTION_UAT_SUB |
      | AOI_PROCESSING       | true                                    |

    Then I expect below files to be present in the host "dmp.ssh.inbound" into folder "${PUBLISHING_DIRECTORY}" after processing:
      | ${PUBLISHING_UAT_FILE_NAME}_${VAR_SYSDATE}_1.csv |

    Then I copy files below from remote folder "${PUBLISHING_DIRECTORY}" on host "dmp.ssh.inbound" into local folder "${TESTDATA_PATH}/outfiles/actual":
      | ${PUBLISHING_UAT_FILE_NAME}_${VAR_SYSDATE}_1.csv |

    Then I remove below files with pattern in the host "dmp.ssh.inbound" from folder "${PUBLISHING_DIRECTORY}" if exists:
      | ${PUBLISHING_UAT_FILE_NAME}*.csv |

  Scenario: TC10: Check if UAT published file contains all the records which were in expected file

    Given I capture current time stamp into variable "recon.timestamp"
    Then I expect each record in file "${TESTDATA_PATH}/outfiles/testdata/${EXPECTED_UAT_PUBLISHED_FILENAME}" should exist in file "${TESTDATA_PATH}/outfiles/actual/${PUBLISHING_UAT_FILE_NAME}_${VAR_SYSDATE}_1.csv" and exceptions to be written to "${TESTDATA_PATH}/outfiles/actual/ESITOFA_UAT_TRANSACTION_EXCEPTIONS_${recon.timestamp}.csv" file

  Scenario:TC11: Verify UAT Production Transactions

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
    AND EXTR.TRD_ID in ('3130-BRSFATRN001${TRD_VAR_NUM_1}','3103-BRSFATRN002${TRD_VAR_NUM_1}','3196-BRSFATRN003${TRD_VAR_NUM_1}',
    'KRFATRN001${TRD_VAR_NUM_1}', 'KRFATRN002${TRD_VAR_NUM_1}',
    'TFFATRN001${TRD_VAR_NUM_1}', 'TFFATRN002${TRD_VAR_NUM_1}',
    'TMFATRN001${TRD_VAR_NUM_1}', 'TMFATRN002${TRD_VAR_NUM_1}')
    """