#https://jira.intranet.asia/browse/TOM-3706
#https://jira.intranet.asia/browse/TOM-4002 - As part of this ticket Price Source for VN and MY was changed to ESM
#eisdev-6770 : Add use case for future date price. Record should throw an exception.

@gc_interface_prices
@dmp_regression_integrationtest
@tom_3706 @tom_4002 @vn_intraday_price @manual_uploader @eisdev_6770
Feature: 001 | Price | Manual Override | VN Intraday | Verify Price Load/Publish
  Verify Price Load/Publish for Vietnam Intraday Processing. Prices with BRS_PURPOSE = ESIVNM, BRS_SOURCE = ESM and Security Currency = VND should be proccessed.
  Exception should be thrown for others. Publish only Intraday Prices successfully loaded into DMP in a particular run

  =============================================================================================================================================
  CLIENT_ID	PRICE_DATE	PRICE	     BRS_PURPOSE	BRS_SOURCE	EDM_SOURCE    Expected Output
  =============================================================================================================================================
  ESL6882348	19/11/2018	87.44284749	 ESIVNM	        ESM 	    ESI	          Exception Should be Thrown for Currency Mismatch
  ESL8564059	15/11/2018	14.945	     ESIPX	        ESALL	    ESI	          Exception Should be Thrown for Currency, Price Source and Price Purpose Mismatch
  ESL1855483	15/11/2018	100.23	     ESIVNM	        ESM 	    ESI	          Data Should be Loaded and Published based on EISLSTID
  ESL3483705	15/11/2018	130.23	     ESIVNM	        ESM	        ESI	          Data Should be Loaded and Published based on EISLSTID
  BPM1530Q9	    18/11/2018	76.23	     ESIVNM	        ESM	        ESI	          Data Should be Loaded and Published based on BCUSIP
  ESL5573594	19/11/2018	110	         ESIVNM	        ESMALL      ESI	          Exception Should be Thrown for Price Source Mismatch
  ESL4853278	19/11/2018	111	         ESIPX	        ESM  	    ESI           Exception Should be Thrown for Price Purpose Mismatch
  ESL3215263	19/20/2018	112	         ESIVNM	        ESM 	    ESI	          Exception Should be raised for Invalid Date Format
  ESL1234567	19/11/2018	113	         ESIVNM         ESM 	    ESI 	      Exception Should be raised for Incorrect Client Id/BCUSIP
  ESL6491843    15/11/2099	113	         ESIVNM         ESM 	    ESI 	      Exception Should be raised for Future Dated Price
  =============================================================================================================================================

  Scenario: Assign Variables
    Given I assign "/dmp/out/brs/intraday" to variable "PUBLISHING_DIRECTORY"
    And I assign "001_VN_Intraday_Price" to variable "PUBLISHING_FILE_NAME"
    And I generate value with date format "YYYYMMdd" and assign to variable "VAR_SYSDATE"
    And I generate value with date format "hhmmss" and assign to variable "TIMESTAMP"
    And I assign "tests/test-data/dmp-interfaces/Prices/Manual_Override" to variable "TESTDATA_PATH"
    And I assign "001_eis_dmp_price_VN.xlsx" to variable "INPUT_FILENAME"

  Scenario: Load Data
    Given I copy files below from local folder "${TESTDATA_PATH}/testdata" to the host "dmp.ssh.inbound" folder "${dmp.ssh.inbound.path}":
      | ${INPUT_FILENAME} |

    When I process files with below parameters and wait for the job to be completed
      | BUSINESS_FEED |                                     |
      | FILE_PATTERN  | ${INPUT_FILENAME}                   |
      | MESSAGE_TYPE  | EIS_MT_VN_INT_PRICE_MASTER_TEMPLATE |

    Then I extract new job id from jblg table into a variable "JOB_ID"

  Scenario: Verify ISPC Count for ESL1855483
    Given I expect value of column "VERIFY_ISPC_COUNT_ESL1855483" in the below SQL query equals to "1":
    """
    SELECT COUNT(*) AS VERIFY_ISPC_COUNT_ESL1855483
    FROM FT_T_ISPC
    WHERE JOB_ID = '${JOB_ID}'
    AND INSTR_ID IN (SELECT INSTR_ID FROM FT_T_ISID WHERE ISS_ID = 'ESL1855483')
    AND UNIT_CPRC = '100.23'
    """

  Scenario: Verify ISPC Count for ESL3483705
    Given I expect value of column "VERIFY_ISPC_COUNT_ESL3483705" in the below SQL query equals to "1":
    """
    SELECT COUNT(*) AS VERIFY_ISPC_COUNT_ESL3483705
    FROM FT_T_ISPC
    WHERE JOB_ID = '${JOB_ID}'
    AND INSTR_ID IN (SELECT INSTR_ID FROM FT_T_ISID WHERE ISS_ID = 'ESL3483705')
    AND UNIT_CPRC = '130.23'
    """

  Scenario: Verify ISPC Count for BPM1530Q9
    Given I expect value of column "VERIFY_ISPC_COUNT_BPM1530Q9" in the below SQL query equals to "1":
    """
    SELECT COUNT(*) AS VERIFY_ISPC_COUNT_BPM1530Q9
    FROM FT_T_ISPC
    WHERE JOB_ID = '${JOB_ID}'
    AND INSTR_ID IN (SELECT INSTR_ID FROM FT_T_ISID WHERE ISS_ID = 'BPM1530Q9')
    AND UNIT_CPRC = '76.23'
    """

  Scenario: Verify PRC1 Count
    Given I expect value of column "VERIFY_PRC1_COUNT" in the below SQL query equals to "3":
    """
    SELECT COUNT(*) AS VERIFY_PRC1_COUNT
    FROM FT_V_PRC1
    WHERE PRC1_JOB_ID = '${JOB_ID}'
    """

  Scenario: Verify ISGP Count
    Given I expect value of column "VERIFY_ISGP_COUNT" in the below SQL query equals to "3":
    """
    SELECT COUNT(*) AS VERIFY_ISGP_COUNT
    FROM FT_T_ISGP
    WHERE INSTR_ID IN (SELECT INSTR_ID FROM FT_T_ISID WHERE ISS_ID IN ('ESL1855483','BPM1530Q9','ESL3483705'))
    AND PRNT_ISS_GRP_OID IN (SELECT ISS_GRP_OID FROM FT_T_ISGR WHERE ISS_GRP_ID = 'INTMANOVRD')
    AND DATA_STAT_TYP = 'ACTIVE'
    """

  Scenario: Verify Exception for ESL6882348
    Given I expect 1 exceptions are captured with the following criteria
      | PARM_VAL_TXT     | User defined Error thrown! . Cannot process record as fields, Price Currency are not valid in the input record. |
      | NOTFCN_ID        | 60001                                                                                                           |
      | NOTFCN_STAT_TYP  | OPEN                                                                                                            |
      | MAIN_ENTITY_ID   | ESL6882348                                                                                                      |
      | MSG_SEVERITY_CDE | 40                                                                                                              |


  Scenario: Verify Exception for ESL8564059
    Given I expect 1 exceptions are captured with the following criteria
      | PARM_VAL_TXT     | User defined Error thrown! . Cannot process record as fields Price Purpose, Price Source, Price Currency are not valid in the input record. |
      | NOTFCN_ID        | 60001                                                                                                                                       |
      | NOTFCN_STAT_TYP  | OPEN                                                                                                                                        |
      | MAIN_ENTITY_ID   | ESL8564059                                                                                                                                  |
      | MSG_SEVERITY_CDE | 40                                                                                                                                          |

  Scenario: Verify Exception for ESL5573594
    Given I expect 1 exceptions are captured with the following criteria
      | PARM_VAL_TXT     | User defined Error thrown! . Cannot process record as fields, Price Source are not valid in the input record. |
      | NOTFCN_ID        | 60001                                                                                                         |
      | NOTFCN_STAT_TYP  | OPEN                                                                                                          |
      | MAIN_ENTITY_ID   | ESL5573594                                                                                                    |
      | MSG_SEVERITY_CDE | 40                                                                                                            |

  Scenario: Verify Exception for ESL4853278
    Given I expect 1 exceptions are captured with the following criteria
      | PARM_VAL_TXT     | User defined Error thrown! . Cannot process record as fields Price Purpose are not valid in the input record. |
      | NOTFCN_ID        | 60001                                                                                                         |
      | NOTFCN_STAT_TYP  | OPEN                                                                                                          |
      | MAIN_ENTITY_ID   | ESL4853278                                                                                                    |
      | MSG_SEVERITY_CDE | 40                                                                                                            |

  Scenario: Verify Exception for ESL1234567
    Given I expect 1 exceptions are captured with the following criteria
      | PARM_VAL_TXT     | User defined Error thrown! . Cannot process record as fields, Price Currency, EISLSTID/BCUSIP are not valid in the input record. |
      | NOTFCN_ID        | 60001                                                                                                                            |
      | NOTFCN_STAT_TYP  | OPEN                                                                                                                             |
      | MAIN_ENTITY_ID   | ESL1234567                                                                                                                       |
      | MSG_SEVERITY_CDE | 40                                                                                                                               |

  Scenario: Verify Exception for ESL3215263
    Given I expect 1 exceptions are captured with the following criteria
      | PARM_VAL_TXT     | User defined Error thrown! . Cannot process record as fields, Price Date are not valid in the input record. |
      | NOTFCN_ID        | 60001                                                                                                       |
      | NOTFCN_STAT_TYP  | OPEN                                                                                                        |
      | MAIN_ENTITY_ID   | ESL3215263                                                                                                  |
      | MSG_SEVERITY_CDE | 40                                                                                                          |

  Scenario: Verify Exception for ESL6491843
    Given I expect 1 exceptions are captured with the following criteria
      | PARM_VAL_TXT     | User defined Error thrown! . Cannot process record as fields, Price Date are not valid in the input record. |
      | NOTFCN_ID        | 60001                                                                                                       |
      | NOTFCN_STAT_TYP  | OPEN                                                                                                        |
      | MAIN_ENTITY_ID   | ESL6491843                                                                                                  |
      | MSG_SEVERITY_CDE | 40                                                                                                          |

  Scenario: Publish Prices
    Given I process publishing wrapper with below parameters and wait for the job to be completed
      | PUBLISHING_FILE_NAME | ${PUBLISHING_FILE_NAME}_${TIMESTAMP}.csv |
      | SUBSCRIPTION_NAME    | EIS_DMP_TO_BRS_VN_INT_PRICE_VIEW_SUB     |

    Then I expect below files to be present in the host "dmp.ssh.inbound" into folder "${PUBLISHING_DIRECTORY}" after processing:
      | ${PUBLISHING_FILE_NAME}_${TIMESTAMP}_${VAR_SYSDATE}_1.csv |

    Then I copy files below from remote folder "${PUBLISHING_DIRECTORY}" on host "dmp.ssh.inbound" into local folder "${TESTDATA_PATH}/outfiles/runtime":
      | ${PUBLISHING_FILE_NAME}_${TIMESTAMP}_${VAR_SYSDATE}_1.csv |

    And I remove below files in the host "dmp.ssh.inbound" from folder "${PUBLISHING_DIRECTORY}" if exists:
      | ${PUBLISHING_FILE_NAME}_${TIMESTAMP}_${VAR_SYSDATE}_1.csv |

  Scenario: Recon
    Given I expect reconciliation should be successful between given CSV files
      | ActualFile   | ${TESTDATA_PATH}/outfiles/runtime/${PUBLISHING_FILE_NAME}_${TIMESTAMP}_${VAR_SYSDATE}_1.csv |
      | ExpectedFile | ${TESTDATA_PATH}/outfiles/template/001_VN_Intraday_Price_Template.csv                       |