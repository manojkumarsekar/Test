#https://jira.intranet.asia/browse/TOM-3706
#https://jira.intranet.asia/browse/TOM-4002 - As part of this ticket Price Source for VN and MY was changed to ESM

@gc_interface_prices
@dmp_regression_integrationtest
@tom_3706 @tom_4002 @sg_vn_intraday_parallel @manual_uploader
Feature: 005 | Price | Manual Override | VN and SG Intraday Parallel Run | Verify Price Load/Publish

  Scenario: Verify Parallel Price Load/Publish for Singapore and Vietnam Intraday Processing.
  Publish only Intraday Prices successfully loaded into DMP in a particular run to respective file

   =============================================================================================================================================
  CLIENT_ID	PRICE_DATE	PRICE	     BRS_PURPOSE	BRS_SOURCE	EDM_SOURCE    Expected Output
   =============================================================================================================================================
   SG
  =============================================================================================================================================
  ESL6923692	23/11/2018	2.4659	     ESIPX	        ESM	        ESI   Data Should be Loaded and Published based on EISLSTID
  ESL5499123	23/11/2018	1.417	     ESIPX	        ESM	        ESI   Data Should be Loaded and Published based on EISLSTID
  ESL3080537	23/11/2018	1.311	     ESIPX	        ESM	        ESI   Data Should be Loaded and Published based on EISLSTID
  =============================================================================================================================================
   VN
   =============================================================================================================================================
  ESL5952722	15/11/2018	120	        ESIVNM	        ESM 	    ESI   Data Should be Loaded and Published based on EISLSTID
  ESL5458195	19/11/2018	130	        ESIVNM	        ESM 	    ESI   Data Should be Loaded and Published based on EISLSTID
  BRSYF61E5	18/11/2018	140	        ESIVNM	        ESM 	    ESI   Data Should be Loaded and Published based on BCUSIP
  =============================================================================================================================================

  #Pre-requisite

  #Assign Variables
    Given I assign "/dmp/out/brs/intraday" to variable "PUBLISHING_DIRECTORY"
    And I assign "005_SG_Intraday_Update_Price" to variable "PUBLISHING_FILE_NAME"
    And I assign "005_VN_Intraday_Update_Price" to variable "PUBLISHING_FILE_NAME_2"
    And I generate value with date format "YYYYMMdd" and assign to variable "VAR_SYSDATE"
    And I generate value with date format "hhmmss" and assign to variable "TIMESTAMP"
    And I assign "tests/test-data/dmp-interfaces/Prices/Manual_Override" to variable "TESTDATA_PATH"
    And I assign "005_eis_dmp_price_SG_Update.xlsx" to variable "INPUT_FILENAME"
    And I assign "005_eis_dmp_price_VN_Update.xlsx" to variable "INPUT_FILENAME_2"

  #Load SG Data
    Given I copy files below from local folder "${TESTDATA_PATH}/testdata" to the host "dmp.ssh.inbound" folder "${dmp.ssh.inbound.path}":
      | ${INPUT_FILENAME} |

    When I process files with below parameters and wait for the job to be completed
      | BUSINESS_FEED |                                      |
      | FILE_PATTERN  | ${INPUT_FILENAME}                    |
      | MESSAGE_TYPE  | EIS_MT_EDM_INT_PRICE_MASTER_TEMPLATE |

    Then I extract new job id from jblg table into a variable "JOB_ID"

  #Verify SG Data:
    Then I expect value of column "VERIFY_ISPC_COUNT_ESL6923692" in the below SQL query equals to "1":
    """
    SELECT COUNT(*) AS VERIFY_ISPC_COUNT_ESL6923692
    FROM FT_T_ISPC
    WHERE JOB_ID = '${JOB_ID}'
    AND INSTR_ID IN (SELECT INSTR_ID FROM FT_T_ISID WHERE ISS_ID = 'ESL6923692')
    AND UNIT_CPRC = '2.4659'
    """

    Then I expect value of column "VERIFY_ISPC_COUNT_ESL5499123" in the below SQL query equals to "1":
    """
    SELECT COUNT(*) AS VERIFY_ISPC_COUNT_ESL5499123
    FROM FT_T_ISPC
    WHERE JOB_ID = '${JOB_ID}'
    AND INSTR_ID IN (SELECT INSTR_ID FROM FT_T_ISID WHERE ISS_ID = 'ESL5499123')
    AND UNIT_CPRC = '1.417'
    """

    Then I expect value of column "VERIFY_ISPC_COUNT_ESL3080537" in the below SQL query equals to "1":
    """
    SELECT COUNT(*) AS VERIFY_ISPC_COUNT_ESL3080537
    FROM FT_T_ISPC
    WHERE JOB_ID = '${JOB_ID}'
    AND INSTR_ID IN (SELECT INSTR_ID FROM FT_T_ISID WHERE ISS_ID = 'ESL3080537')
    AND UNIT_CPRC = '1.311'
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
    WHERE INSTR_ID IN (SELECT INSTR_ID FROM FT_T_ISID WHERE ISS_ID IN ('ESL6923692','ESL5499123','ESL3080537'))
    AND PRNT_ISS_GRP_OID IN (SELECT ISS_GRP_OID FROM FT_T_ISGR WHERE ISS_GRP_ID = 'INTMANOVRD')
    AND DATA_STAT_TYP = 'ACTIVE'
    """

  #Load VN Data
    Given I copy files below from local folder "${TESTDATA_PATH}/testdata" to the host "dmp.ssh.inbound" folder "${dmp.ssh.inbound.path}":
      | ${INPUT_FILENAME_2} |

    When I process files with below parameters and wait for the job to be completed
      | BUSINESS_FEED |                                     |
      | FILE_PATTERN  | ${INPUT_FILENAME_2}                 |
      | MESSAGE_TYPE  | EIS_MT_VN_INT_PRICE_MASTER_TEMPLATE |

    Then I extract new job id from jblg table into a variable "JOB_ID_2"

  #Verify VN Data:
    Then I expect value of column "VERIFY_ISPC_COUNT_ESL5952722" in the below SQL query equals to "1":
    """
    SELECT COUNT(*) AS VERIFY_ISPC_COUNT_ESL5952722
    FROM FT_T_ISPC
    WHERE JOB_ID = '${JOB_ID_2}'
    AND INSTR_ID IN (SELECT INSTR_ID FROM FT_T_ISID WHERE ISS_ID = 'ESL5952722')
    AND UNIT_CPRC = '120'
    """

    Then I expect value of column "VERIFY_ISPC_COUNT_ESL5458195" in the below SQL query equals to "1":
    """
    SELECT COUNT(*) AS VERIFY_ISPC_COUNT_ESL5458195
    FROM FT_T_ISPC
    WHERE JOB_ID = '${JOB_ID_2}'
    AND INSTR_ID IN (SELECT INSTR_ID FROM FT_T_ISID WHERE ISS_ID = 'ESL5458195')
    AND UNIT_CPRC = '130'
    """

    Then I expect value of column "VERIFY_ISPC_COUNT_BRSYF61E5" in the below SQL query equals to "1":
    """
    SELECT COUNT(*) AS VERIFY_ISPC_COUNT_BRSYF61E5
    FROM FT_T_ISPC
    WHERE JOB_ID = '${JOB_ID_2}'
    AND INSTR_ID IN (SELECT INSTR_ID FROM FT_T_ISID WHERE ISS_ID = 'BRSYF61E5')
    AND UNIT_CPRC = '140'
    """

    Then I expect value of column "VERIFY_PRC1_COUNT" in the below SQL query equals to "6":

    """
    SELECT COUNT(*) AS VERIFY_PRC1_COUNT
    FROM FT_V_PRC1
    WHERE PRC1_JOB_ID IN ('${JOB_ID}','${JOB_ID_2}')
    """

    Then I expect value of column "VERIFY_ISGP_COUNT" in the below SQL query equals to "6":
    """
    SELECT COUNT(*) AS VERIFY_ISGP_COUNT
    FROM FT_T_ISGP
    WHERE INSTR_ID IN (SELECT INSTR_ID FROM FT_T_ISID WHERE ISS_ID IN ('ESL5952722','ESL5458195','BRSYF61E5','ESL6923692','ESL5499123','ESL3080537'))
    AND PRNT_ISS_GRP_OID IN (SELECT ISS_GRP_OID FROM FT_T_ISGR WHERE ISS_GRP_ID = 'INTMANOVRD')
    AND DATA_STAT_TYP = 'ACTIVE'
    """

  #Extract SG Data
    Given I process publishing wrapper with below parameters and wait for the job to be completed
      | PUBLISHING_FILE_NAME | ${PUBLISHING_FILE_NAME}_${TIMESTAMP}.csv |
      | SUBSCRIPTION_NAME    | EIS_DMP_TO_BRS_SG_INT_PRICE_VIEW_SUB     |

    Then I expect below files to be present in the host "dmp.ssh.inbound" into folder "${PUBLISHING_DIRECTORY}" after processing:
      | ${PUBLISHING_FILE_NAME}_${TIMESTAMP}_${VAR_SYSDATE}_1.csv |

    Then I copy files below from remote folder "${PUBLISHING_DIRECTORY}" on host "dmp.ssh.inbound" into local folder "${TESTDATA_PATH}/outfiles/runtime":
      | ${PUBLISHING_FILE_NAME}_${TIMESTAMP}_${VAR_SYSDATE}_1.csv |

    And I remove below files in the host "dmp.ssh.inbound" from folder "${PUBLISHING_DIRECTORY}" if exists:
      | ${PUBLISHING_FILE_NAME}_${TIMESTAMP}_${VAR_SYSDATE}_1.csv |


  #Extract VN Data
    Given I process publishing wrapper with below parameters and wait for the job to be completed
      | PUBLISHING_FILE_NAME | ${PUBLISHING_FILE_NAME_2}_${TIMESTAMP}.csv |
      | SUBSCRIPTION_NAME    | EIS_DMP_TO_BRS_VN_INT_PRICE_VIEW_SUB       |

    Then I expect below files to be present in the host "dmp.ssh.inbound" into folder "${PUBLISHING_DIRECTORY}" after processing:
      | ${PUBLISHING_FILE_NAME_2}_${TIMESTAMP}_${VAR_SYSDATE}_1.csv |

    Then I copy files below from remote folder "${PUBLISHING_DIRECTORY}" on host "dmp.ssh.inbound" into local folder "${TESTDATA_PATH}/outfiles/runtime":
      | ${PUBLISHING_FILE_NAME_2}_${TIMESTAMP}_${VAR_SYSDATE}_1.csv |

    And I remove below files in the host "dmp.ssh.inbound" from folder "${PUBLISHING_DIRECTORY}" if exists:
      | ${PUBLISHING_FILE_NAME_2}_${TIMESTAMP}_${VAR_SYSDATE}_1.csv |

  #Reconcile Data
    When I capture current time stamp into variable "recon.timestamp"

    Then I expect reconciliation between generated CSV file "${TESTDATA_PATH}/outfiles/runtime/${PUBLISHING_FILE_NAME}_${TIMESTAMP}_${VAR_SYSDATE}_1.csv" and reference CSV file "${TESTDATA_PATH}/outfiles/template/005_SG_Intraday_Update_Price_Template.csv" should be successful and exceptions to be written to "${TESTDATA_PATH}/outfiles/005_1_exceptions_${recon.timestamp}.csv" file

    Then I expect reconciliation between generated CSV file "${TESTDATA_PATH}/outfiles/runtime/${PUBLISHING_FILE_NAME_2}_${TIMESTAMP}_${VAR_SYSDATE}_1.csv" and reference CSV file "${TESTDATA_PATH}/outfiles/template/005_VN_Intraday_Update_Price_Template.csv" should be successful and exceptions to be written to "${TESTDATA_PATH}/outfiles/005_3_exceptions_${recon.timestamp}.csv" file