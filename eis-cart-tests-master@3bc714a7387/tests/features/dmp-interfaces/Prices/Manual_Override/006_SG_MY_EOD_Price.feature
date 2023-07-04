#https://jira.intranet.asia/browse/TOM-3706
#https://jira.intranet.asia/browse/TOM-4002 - As part of this ticket Price Source for VN and MY was changed to ESM
# https://jira.intranet.asia/browse/TOM-4387 - Added Filter for PRC1_GRP_NME = 'ESIMANOVRD'

@gc_interface_prices @gc_interface_refresh_soi
@dmp_regression_integrationtest
@tom_3706 @tom_4002 @my_sg_eod_price @tom_4387 @dmp_gs_upgrade @manual_uploader
Feature: 006 | Price | Manual Override | SG and MY EOD | Verify Price Load/Publish

  Scenario: Verify Price Updates for Singapore and Malaysia EOD Processing. Data should be published as part of EOD file.
  For MY, Prices with BRS_PURPOSE = ESIMYS, BRS_SOURCE = ESM and Security Currency = MYR should be proccessed.
  Exception should be thrown for others. Prices received in Intraday should not be published as part of EOD.

  =============================================================================================================================================
  CLIENT_ID	PRICE_DATE	PRICE	     BRS_PURPOSE	BRS_SOURCE	EDM_SOURCE    Expected Output
  =============================================================================================================================================
  MY
  =============================================================================================================================================
  ESL6882348	19/11/2018	87.44284749	 ESIMYS	        ESM 	    ESI	          Exception Should be Thrown for Currency Mismatch
  ESL8564059	15/11/2018	14.945	     ESIPX	        ESALL       ESI	          Exception Should be Thrown for Currency, Price Source and Price Purpose Mismatch
  BRSRT6PR0	23/11/2018  4.20007		 ESIMYS	        ESM 	    ESI           Data Should be Loaded and Published based on BCUSIP
  BRSRT5X36	23/11/2018  3.33093		 ESIMYS	        ESM 	    ESI           Data Should be Loaded and Published based on BCUSIP
  ESL1705533	23/11/2018  3.56456		 ESIMYS	        ESM 	    ESI           Data Should be Loaded and Published based on EISLSTID
  BES0JC9Y9    19/11/2018	110	         ESIMYS	        ESALL       ESI	          Exception Should be Thrown for Price Source Mismatch
  BRT7MKAC8    19/11/2018	111	         ESIPX	        ESM	        ESI           Exception Should be Thrown for Price Purpose Mismatch
  BRT7MKAA2    19/20/2018	112	         ESIMYS	        ESM 	    ESI	          Exception Should be raised for Invalid Date Format
  ESL1234567	19/11/2018	113	         ESIMYS         ESM 	    ESI 	      Exception Should be raised for Incorrect Client Id/BCUSIP
  =============================================================================================================================================
  SG
  =============================================================================================================================================
  ESL7931475	26/11/2018	1.249977	 ESIPX	        ESM	        ESI           Data Should be Loaded and Published based on EISLSTID
  ESL3409588	26/11/2018	1.13742	     ESIPX	        ESM	        ESI           Data Should be Loaded and Published based on EISLSTID
  ESL6279186	26/11/2018	1.07426	     ESIPX	        ESM	        ESI           Data Should be Loaded and Published based on EISLSTID
  =============================================================================================================================================

  #Pre-requisite

  #Assign Variables
    Given I assign "/dmp/out/brs/eod" to variable "PUBLISHING_DIRECTORY"
    And I assign "006_SG_MY_EOD_Price" to variable "PUBLISHING_FILE_NAME"
    And I generate value with date format "YYYYMMdd" and assign to variable "VAR_SYSDATE"
    And I generate value with date format "hhmmss" and assign to variable "TIMESTAMP"
    And I assign "tests/test-data/dmp-interfaces/Prices/Manual_Override" to variable "TESTDATA_PATH"
    And I assign "006_eis_dmp_price_MY_EOD.xlsx" to variable "INPUT_FILENAME"
    And I assign "006_eis_dmp_price_SG_EOD.xlsx" to variable "INPUT_FILENAME_2"

  #Load MY Data
    Given I copy files below from local folder "${TESTDATA_PATH}/testdata" to the host "dmp.ssh.inbound" folder "${dmp.ssh.inbound.path}":
      | ${INPUT_FILENAME} |

    When I process files with below parameters and wait for the job to be completed
      | BUSINESS_FEED |                                 |
      | FILE_PATTERN  | ${INPUT_FILENAME}               |
      | MESSAGE_TYPE  | EIS_MT_MY_PRICE_MASTER_TEMPLATE |

    Then I extract new job id from jblg table into a variable "JOB_ID"

  #Verify MY Data:
    Then I expect value of column "VERIFY_ISPC_COUNT_BRSRT6PR0" in the below SQL query equals to "1":
    """
    SELECT COUNT(*) AS VERIFY_ISPC_COUNT_BRSRT6PR0
    FROM FT_T_ISPC
    WHERE JOB_ID = '${JOB_ID}'
    AND INSTR_ID IN (SELECT INSTR_ID FROM FT_T_ISID WHERE ISS_ID = 'BRSRT6PR0')
    AND UNIT_CPRC = '4.20007'
    """

    Then I expect value of column "VERIFY_ISPC_COUNT_BRSRT5X36" in the below SQL query equals to "1":
    """
    SELECT COUNT(*) AS VERIFY_ISPC_COUNT_BRSRT5X36
    FROM FT_T_ISPC
    WHERE JOB_ID = '${JOB_ID}'
    AND INSTR_ID IN (SELECT INSTR_ID FROM FT_T_ISID WHERE ISS_ID = 'BRSRT5X36')
    AND UNIT_CPRC = '3.33093'
    """

    Then I expect value of column "VERIFY_ISPC_COUNT_ESL1705533" in the below SQL query equals to "1":
    """
    SELECT COUNT(*) AS VERIFY_ISPC_COUNT_ESL1705533
    FROM FT_T_ISPC
    WHERE JOB_ID = '${JOB_ID}'
    AND INSTR_ID IN (SELECT INSTR_ID FROM FT_T_ISID WHERE ISS_ID = 'ESL1705533')
    AND UNIT_CPRC = '3.56456'
    """

    Then I expect value of column "VERIFY_NTEL_ESL6882348" in the below SQL query equals to "1":
    """
    SELECT COUNT(*) AS VERIFY_NTEL_ESL6882348
    FROM FT_T_NTEL
    WHERE LAST_CHG_TRN_ID IN (SELECT TRN_ID FROM FT_T_TRID WHERE JOB_ID = '${JOB_ID}'
    AND MAIN_ENTITY_ID = 'ESL6882348')
    AND NOTFCN_ID = '60001'
    AND PARM_VAL_TXT = 'User defined Error thrown! . Cannot process record as fields, Price Currency are not valid in the input record.'
    AND NOTFCN_STAT_TYP = 'OPEN'
    """

    Then I expect value of column "VERIFY_NTEL_ESL8564059" in the below SQL query equals to "1":
    """
    SELECT COUNT(*) AS VERIFY_NTEL_ESL8564059
    FROM FT_T_NTEL
    WHERE LAST_CHG_TRN_ID IN (SELECT TRN_ID FROM FT_T_TRID WHERE JOB_ID = '${JOB_ID}'
    AND MAIN_ENTITY_ID = 'ESL8564059')
    AND NOTFCN_ID = '60001'
    AND PARM_VAL_TXT = 'User defined Error thrown! . Cannot process record as fields Price Purpose, Price Source, Price Currency are not valid in the input record.'
    AND NOTFCN_STAT_TYP = 'OPEN'
    """

    Then I expect value of column "VERIFY_NTEL_BES0JC9Y9" in the below SQL query equals to "1":
    """
    SELECT COUNT(*) AS VERIFY_NTEL_BES0JC9Y9
    FROM FT_T_NTEL
    WHERE LAST_CHG_TRN_ID IN (SELECT TRN_ID FROM FT_T_TRID WHERE JOB_ID = '${JOB_ID}'
    AND MAIN_ENTITY_ID = 'BES0JC9Y9')
    AND NOTFCN_ID = '60001'
    AND PARM_VAL_TXT = 'User defined Error thrown! . Cannot process record as fields, Price Source are not valid in the input record.'
    AND NOTFCN_STAT_TYP = 'OPEN'
    """

    Then I expect value of column "VERIFY_NTEL_BRT7MKAC8" in the below SQL query equals to "1":
    """
    SELECT COUNT(*) AS VERIFY_NTEL_BRT7MKAC8
    FROM FT_T_NTEL
    WHERE LAST_CHG_TRN_ID IN (SELECT TRN_ID FROM FT_T_TRID WHERE JOB_ID = '${JOB_ID}'
    AND MAIN_ENTITY_ID = 'BRT7MKAC8')
    AND NOTFCN_ID = '60001'
    AND PARM_VAL_TXT = 'User defined Error thrown! . Cannot process record as fields Price Purpose are not valid in the input record.'
    AND NOTFCN_STAT_TYP = 'OPEN'
    """

    Then I expect value of column "VERIFY_NTEL_ESL1234567" in the below SQL query equals to "1":
    """
    SELECT COUNT(*) AS VERIFY_NTEL_ESL1234567
    FROM FT_T_NTEL
    WHERE LAST_CHG_TRN_ID IN (SELECT TRN_ID FROM FT_T_TRID WHERE JOB_ID = '${JOB_ID}'
    AND MAIN_ENTITY_ID = 'ESL1234567')
    AND NOTFCN_ID = '60001'
    AND PARM_VAL_TXT = 'User defined Error thrown! . Cannot process record as fields, Price Currency, EISLSTID/BCUSIP are not valid in the input record.'
    AND NOTFCN_STAT_TYP = 'OPEN'
    """

    Then I expect value of column "VERIFY_NTEL_BRT7MKAA2" in the below SQL query equals to "1":
    """
    SELECT COUNT(*) AS VERIFY_NTEL_BRT7MKAA2
    FROM FT_T_NTEL
    WHERE LAST_CHG_TRN_ID IN (SELECT TRN_ID FROM FT_T_TRID WHERE JOB_ID = '${JOB_ID}'
    AND MAIN_ENTITY_ID = 'BRT7MKAA2')
    AND NOTFCN_ID = '60001'
    AND PARM_VAL_TXT = 'User defined Error thrown! . Cannot process record as fields, Price Date are not valid in the input record.'
    AND NOTFCN_STAT_TYP = 'OPEN'
    """

  #Load SG Data
    Given I copy files below from local folder "${TESTDATA_PATH}/testdata" to the host "dmp.ssh.inbound" folder "${dmp.ssh.inbound.path}":
      | ${INPUT_FILENAME_2} |

    When I process files with below parameters and wait for the job to be completed
      | BUSINESS_FEED |                                  |
      | FILE_PATTERN  | ${INPUT_FILENAME_2}              |
      | MESSAGE_TYPE  | EIS_MT_EDM_PRICE_MASTER_TEMPLATE |

    Then I extract new job id from jblg table into a variable "JOB_ID_2"

  #Verify SG Data

    Then I expect value of column "VERIFY_ISPC_COUNT_ESL7931475" in the below SQL query equals to "1":
    """
    SELECT COUNT(*) AS VERIFY_ISPC_COUNT_ESL7931475
    FROM FT_T_ISPC
    WHERE JOB_ID = '${JOB_ID_2}'
    AND INSTR_ID IN (SELECT INSTR_ID FROM FT_T_ISID WHERE ISS_ID = 'ESL7931475')
    AND UNIT_CPRC = '1.249977'
    """

    Then I expect value of column "VERIFY_ISPC_COUNT_ESL3409588" in the below SQL query equals to "1":
    """
    SELECT COUNT(*) AS VERIFY_ISPC_COUNT_ESL3409588
    FROM FT_T_ISPC
    WHERE JOB_ID = '${JOB_ID_2}'
    AND INSTR_ID IN (SELECT INSTR_ID FROM FT_T_ISID WHERE ISS_ID = 'ESL3409588')
    AND UNIT_CPRC = '1.13742'
    """

    Then I expect value of column "VERIFY_ISPC_COUNT_ESL6279186" in the below SQL query equals to "1":
    """
    SELECT COUNT(*) AS VERIFY_ISPC_COUNT_ESL6279186
    FROM FT_T_ISPC
    WHERE JOB_ID = '${JOB_ID_2}'
    AND INSTR_ID IN (SELECT INSTR_ID FROM FT_T_ISID WHERE ISS_ID = 'ESL6279186')
    AND UNIT_CPRC = '1.07426'
    """

  #Verify SG and MY Price Data in for View and ISGP

    Then I expect value of column "VERIFY_PRC1_COUNT" in the below SQL query equals to "6":

    """
    SELECT COUNT(*) AS VERIFY_PRC1_COUNT
    FROM FT_V_PRC1
    WHERE PRC1_JOB_ID IN ('${JOB_ID}','${JOB_ID_2}')
    AND PRC1_GRP_NME = 'ESIMANOVRD'
    """

    Then I expect value of column "VERIFY_ISGP_COUNT" in the below SQL query equals to "6":
    """
    SELECT COUNT(*) AS VERIFY_ISGP_COUNT
    FROM FT_T_ISGP
    WHERE INSTR_ID IN (SELECT INSTR_ID FROM FT_T_ISID WHERE ISS_ID IN ('BRSRT6PR0','BRSRT5X36','ESL1705533','ESL7931475','ESL3409588','ESL6279186'))
    AND PRNT_ISS_GRP_OID IN (SELECT ISS_GRP_OID FROM FT_T_ISGR WHERE ISS_GRP_ID = 'ESIMANOVRD')
    AND DATA_STAT_TYP = 'ACTIVE'
    """

  #Extract Data
    Given I process publishing wrapper with below parameters and wait for the job to be completed
      | PUBLISHING_FILE_NAME | ${PUBLISHING_FILE_NAME}_${TIMESTAMP}.csv                                                        |
      | SUBSCRIPTION_NAME    | EIS_DMP_TO_BRS_PRICE_VIEW_SUB                                                                   |
      | SQL                  | <![CDATA[<sql>TRUNC(PRC1_ADJST_TMS) = TRUNC(sysdate) and PRC1_GRP_NME != 'INTMANOVRD' </sql>]]> |

    Then I expect below files to be present in the host "dmp.ssh.inbound" into folder "${PUBLISHING_DIRECTORY}" after processing:
      | ${PUBLISHING_FILE_NAME}_${TIMESTAMP}_${VAR_SYSDATE}_1.csv |

    Then I copy files below from remote folder "${PUBLISHING_DIRECTORY}" on host "dmp.ssh.inbound" into local folder "${TESTDATA_PATH}/outfiles/runtime":
      | ${PUBLISHING_FILE_NAME}_${TIMESTAMP}_${VAR_SYSDATE}_1.csv |

    And I remove below files in the host "dmp.ssh.inbound" from folder "${PUBLISHING_DIRECTORY}" if exists:
      | ${PUBLISHING_FILE_NAME}_${TIMESTAMP}_${VAR_SYSDATE}_1.csv |

  #Reconcile Data
    When I capture current time stamp into variable "recon.timestamp"

    Then I expect each record in file "${TESTDATA_PATH}/outfiles/template/006_SG_MY_EOD_Price_Template.csv" should exist in file "${TESTDATA_PATH}/outfiles/runtime/${PUBLISHING_FILE_NAME}_${TIMESTAMP}_${VAR_SYSDATE}_1.csv" and exceptions to be written to "${TESTDATA_PATH}/outfiles/005_exceptions_${recon.timestamp}.csv" file


  #Refresh SOI
    Given I set the workflow template parameter "GROUP_NAME" to "ESIMANOVRD"
    And I set the workflow template parameter "NO_OF_BRANCH" to "5"
    And I set the workflow template parameter "QUERY_NAME" to "EIS_REFRESH_MANUAL_PRICE_SOI"

    When I send a web service request using template file "tests/test-data/intf-specs/gswf/template/EIS_RefreshSOI/request.xmlt" and save the response to file "testout/evidence/gswf/resp/asyncResponse.xml"
    Then I extract a value from the XML file "testout/evidence/gswf/resp/asyncResponse.xml" using XPath query in file "tests/test-data/intf-specs/gswf/template/EIS_RefreshSOI/flowResultIdQuery.xpath" to variable "flowResultId"

    Then I poll for maximum 600 seconds and expect the result of the SQL query below equals to "DONE":
    """
    SELECT WF_RUNTIME_STAT_TYP FROM FT_WF_WFRI WHERE INSTANCE_ID='${flowResultId}'
    """

    Then I pause for 30 seconds


  #Verify Data:
    Then I expect value of column "PRICE_COUNT_POST_REFRESH" in the below SQL query equals to "0":
    """
    SELECT COUNT(*) AS PRICE_COUNT_POST_REFRESH
    FROM FT_V_PRC1
    WHERE TRUNC(PRC1_ADJST_TMS) = TRUNC(SYSDATE) AND PRC1_GRP_NME ='ESIMANOVRD'
    """