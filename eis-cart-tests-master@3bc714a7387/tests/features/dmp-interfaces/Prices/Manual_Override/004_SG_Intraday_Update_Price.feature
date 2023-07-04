#https://jira.intranet.asia/browse/TOM-3706
#https://jira.intranet.asia/browse/TOM-4002 - As part of this ticket Price Source for VN and MY was changed to ESM

@gc_interface_prices
@dmp_regression_integrationtest
@tom_3706 @tom_4002 @sg_intraday_update_price @manual_uploader
Feature: 004 | Price | Manual Override | SG Intraday Update | Verify Price Load/Publish

  Scenario: Verify Price Updates for Singapore Intraday Processing. Publish only Intraday Prices successfully loaded into DMP in a particular run

   =============================================================================================================================================
  CLIENT_ID	PRICE_DATE	PRICE	     BRS_PURPOSE	BRS_SOURCE	EDM_SOURCE    Expected Output
   =============================================================================================================================================
  ESL8343478    22/11/2018    90.945     ESIPX            ESALL       ESI      Data Should be Loaded and Updated Price is Published based on EISLSTID - USD
  S64928385	 17/4/2018	   101	      ESIREV	       ESMAN	   ESI      Data Should be Loaded and Updated Price is Published based on EISLSTID - THB
  BRSRWYMA5     21/11/2018    2.5        ESIPX            ESALL       ESI      Data Should be Loaded and Updated Price is Published based on BCUSIP - USD
  ESL9550955	 17/4/2018	   252	      ESIREV	       ESMAN	   ESI      No Update Received, Data should "NOT" be Published
  =============================================================================================================================================

  #Pre-requisite

  #Assign Variables
    Given I assign "/dmp/out/brs/intraday" to variable "PUBLISHING_DIRECTORY"
    And I assign "004_SG_Intraday_Update_Price" to variable "PUBLISHING_FILE_NAME"
    And I generate value with date format "YYYYMMdd" and assign to variable "VAR_SYSDATE"
    And I generate value with date format "hhmmss" and assign to variable "TIMESTAMP"
    And I assign "tests/test-data/dmp-interfaces/Prices/Manual_Override" to variable "TESTDATA_PATH"
    And I assign "004_eis_dmp_price_SG_Update.xlsx" to variable "INPUT_FILENAME"

  #Load Data
    Given I copy files below from local folder "${TESTDATA_PATH}/testdata" to the host "dmp.ssh.inbound" folder "${dmp.ssh.inbound.path}":
      | ${INPUT_FILENAME} |

    When I process files with below parameters and wait for the job to be completed
      | BUSINESS_FEED |                                      |
      | FILE_PATTERN  | ${INPUT_FILENAME}                    |
      | MESSAGE_TYPE  | EIS_MT_EDM_INT_PRICE_MASTER_TEMPLATE |

    Then I extract new job id from jblg table into a variable "JOB_ID"

  #Verify Data:
    Then I expect value of column "VERIFY_ISPC_COUNT_ESL8343478" in the below SQL query equals to "1":
    """
    SELECT COUNT(*) AS VERIFY_ISPC_COUNT_ESL8343478
    FROM FT_T_ISPC
    WHERE JOB_ID = '${JOB_ID}'
    AND INSTR_ID IN (SELECT INSTR_ID FROM FT_T_ISID WHERE ISS_ID = 'ESL8343478')
    AND UNIT_CPRC = '90.945'
    """

    Then I expect value of column "VERIFY_ISPC_COUNT_S64928385" in the below SQL query equals to "1":
    """
    SELECT COUNT(*) AS VERIFY_ISPC_COUNT_S64928385
    FROM FT_T_ISPC
    WHERE JOB_ID = '${JOB_ID}'
    AND INSTR_ID IN (SELECT INSTR_ID FROM FT_T_ISID WHERE ISS_ID = 'S64928385')
    AND UNIT_CPRC = '101'
    """

    Then I expect value of column "VERIFY_ISPC_COUNT_BRSRWYMA5" in the below SQL query equals to "1":
    """
    SELECT COUNT(*) AS VERIFY_ISPC_COUNT_BRSRWYMA5
    FROM FT_T_ISPC
    WHERE JOB_ID = '${JOB_ID}'
    AND INSTR_ID IN (SELECT INSTR_ID FROM FT_T_ISID WHERE ISS_ID = 'BRSRWYMA5')
    AND UNIT_CPRC = '2.5'
    """

    Then I expect value of column "VERIFY_PRC1_COUNT" in the below SQL query equals to "3":
    """
    SELECT COUNT(*) AS VERIFY_PRC1_COUNT
    FROM FT_V_PRC1
    WHERE PRC1_JOB_ID = '${JOB_ID}'
    """

    Then I expect value of column "VERIFY_ISGP_COUNT" in the below SQL query equals to "3":
    """
    SELECT COUNT(*) AS VERIFY_ISGP_COUNT
    FROM FT_T_ISGP
    WHERE INSTR_ID IN (SELECT INSTR_ID FROM FT_T_ISID WHERE ISS_ID IN ('ESL8343478','S64928385','BRSRWYMA5'))
    AND PRNT_ISS_GRP_OID IN (SELECT ISS_GRP_OID FROM FT_T_ISGR WHERE ISS_GRP_ID = 'INTMANOVRD')
    AND DATA_STAT_TYP = 'ACTIVE'
    """

  #Extract Data
    Given I process publishing wrapper with below parameters and wait for the job to be completed
      | PUBLISHING_FILE_NAME | ${PUBLISHING_FILE_NAME}_${TIMESTAMP}.csv |
      | SUBSCRIPTION_NAME    | EIS_DMP_TO_BRS_SG_INT_PRICE_VIEW_SUB     |

    Then I expect below files to be present in the host "dmp.ssh.inbound" into folder "${PUBLISHING_DIRECTORY}" after processing:
      | ${PUBLISHING_FILE_NAME}_${TIMESTAMP}_${VAR_SYSDATE}_1.csv |

    Then I copy files below from remote folder "${PUBLISHING_DIRECTORY}" on host "dmp.ssh.inbound" into local folder "${TESTDATA_PATH}/outfiles/runtime":
      | ${PUBLISHING_FILE_NAME}_${TIMESTAMP}_${VAR_SYSDATE}_1.csv |

    And I remove below files in the host "dmp.ssh.inbound" from folder "${PUBLISHING_DIRECTORY}" if exists:
      | ${PUBLISHING_FILE_NAME}_${TIMESTAMP}_${VAR_SYSDATE}_1.csv |

  #Reconcile Data
    When I capture current time stamp into variable "recon.timestamp"

    Then I expect reconciliation between generated CSV file "${TESTDATA_PATH}/outfiles/runtime/${PUBLISHING_FILE_NAME}_${TIMESTAMP}_${VAR_SYSDATE}_1.csv" and reference CSV file "${TESTDATA_PATH}/outfiles/template/004_SG_Intraday_Update_Price_Template.csv" should be successful and exceptions to be written to "${TESTDATA_PATH}/outfiles/002_1_1_exceptions_${recon.timestamp}.csv" file