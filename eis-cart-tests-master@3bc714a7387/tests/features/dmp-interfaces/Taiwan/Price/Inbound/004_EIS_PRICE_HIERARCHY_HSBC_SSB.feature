# =====================================================================
# Date            JIRA        Comments
# ============    ========    ========
# 14/02/2019      TOM-4171    First Version
# =====================================================================

#https://jira.intranet.asia/browse/TOM-4171
#https://jira.intranet.asia/browse/TOM-4044--https://jira.intranet.asia/browse/TOM-4045--The whole scenarios needs to be run for this feature file as those tickets were part of the development
# EISDEV-7120 In order to speed up the execution time of golden price calculation, added the instruments and set RUNPVCFORPRVI as "False" part of parameters

@gc_interface_prices @gc_interface_refresh_soi
@dmp_taiwan
@dmp_regression_integrationtest
@tom_4171 @tom_4171_001 @pvc @eisdev_7120
Feature: Taiwan | Price Hierarchy HSBC and SSB | Workflow

  =============================================================================================================================================
  Load HSBC position file with below details:
  =============================================================================================================================================
  POS_DATE	MKT_PRICE	BRS_SEC_ID	CUSIP	    ISIN	        SEDOL	Comments
  20190130	9.875           	    N54360AD9	USN54360AD95	B1Z61D9	Load data
  20190130	9               	            	USY20721AL30	B7FMHX1	Load data
  20190130	9.5412           	    N54360AE7	USN54360AE78	    	Load data
  20190130	8.95            	    N54360AF4	USN54360AF44	B5B4JZ3	Load data
  =============================================================================================================================================

  Scenario: TC_1: Clear ISPS, GPCS, ISPC and ISGP data

    And I execute below query to clear ISPC and ISGP data so that file loads will be done and workflow can be tested successfully
    """
    DELETE from ft_t_gpcs WHERE ISS_PRC_ID IN (SELECT ISS_PRC_ID FROM FT_T_ISPC WHERE INSTR_ID IN (SELECT INSTR_ID FROM FT_T_ISID WHERE ISS_ID IN('USY20721AE96','USN54360AE78','USN54360AF44','USN54360AD95','USY20721AL30')
    AND ID_CTXT_TYP IN('ISIN') AND END_TMS IS NULL) AND PRC_SRCE_TYP = 'ESTW' AND PRC_TYP = 'CLOSE');
    DELETE FROM FT_T_ISPS WHERE ISS_PRC_ID IN (SELECT ISS_PRC_ID FROM FT_T_ISPC WHERE INSTR_ID IN (SELECT INSTR_ID FROM FT_T_ISID WHERE ISS_ID IN('USY20721AE96','USN54360AE78','USN54360AF44','USN54360AD95','USY20721AL30')
    AND ID_CTXT_TYP IN('ISIN') AND END_TMS IS NULL) AND PRC_SRCE_TYP = 'ESTW' AND PRC_TYP = 'CLOSE');
    DELETE FROM FT_T_ISPC WHERE INSTR_ID IN (SELECT INSTR_ID FROM FT_T_ISID WHERE ISS_ID IN('USY20721AE96','USN54360AE78','USN54360AF44','USN54360AD95','USY20721AL30')
    AND ID_CTXT_TYP IN('ISIN') AND END_TMS IS NULL) AND PRC_SRCE_TYP = 'ESTW' AND PRC_TYP = 'CLOSE';
    DELETE FROM FT_T_ISGP where PRNT_ISS_GRP_OID IN ('HSBCSSBSOI','HSBCPRCSOI','SSBPRCSOI');
    COMMIT
    """

  Scenario: TC_2: Load the data for successfully for HSBC and SSB records.

    Given I assign "TC-04_EITW_HSBC_DMP_PRICE.csv" to variable "INPUT_FILENAME_1"
    And I assign "tests/test-data/dmp-interfaces/Taiwan/Price/Inbound" to variable "TESTDATA_PATH"

    #Load Data
    Given I copy files below from local folder "${TESTDATA_PATH}" to the host "dmp.ssh.inbound" folder "${dmp.ssh.inbound.path}":
      | ${INPUT_FILENAME_1} |

    Given I process files with below parameters and wait for the job to be completed
      | BUSINESS_FEED            |                          |
      | FILE_PATTERN             | *EITW_HSBC_DMP_PRICE.csv |
      | MESSAGE_TYPE             | EITW_MT_HSBC_PRICE       |
      | PRICE_POINT_EVENT_DEF_ID | ESIPRPTEOD               |

    Given I assign "TC-04_EITW_SSB_DMP_PRICE.csv" to variable "INPUT_FILENAME_1"
    And I assign "tests/test-data/dmp-interfaces/Taiwan/Price/Inbound" to variable "TESTDATA_PATH"

    #Load Data
    Given I copy files below from local folder "${TESTDATA_PATH}" to the host "dmp.ssh.inbound" folder "${dmp.ssh.inbound.path}":
      | ${INPUT_FILENAME_1} |

    Given I process files with below parameters and wait for the job to be completed
      | BUSINESS_FEED            |                         |
      | FILE_PATTERN             | *EITW_SSB_DMP_PRICE.csv |
      | MESSAGE_TYPE             | EITW_MT_SSB_PRICE       |
      | PRICE_POINT_EVENT_DEF_ID | ESIPRPTEOD              |

  Scenario: TC_3: verify ISPC data

    Then I expect value of column "VERIFY_ISPC_COUNT" in the below SQL query equals to "8":
    """
    SELECT COUNT(*) AS VERIFY_ISPC_COUNT
    FROM FT_T_ISPC
    WHERE INSTR_ID IN (SELECT INSTR_ID FROM FT_T_ISID WHERE ISS_ID IN ( 'USN54360AD95','USY20721AL30','USN54360AE78','USN54360AF44'))
    AND PRC_TYP = 'CLOSE'
    AND PRC_CURR_CDE= 'USD'
    AND MKT_OID = '=0000000AC'
    AND PRCNG_METH_TYP = 'ESIPX'
    AND PRC_QT_METH_TYP = 'PRCQUOTE'
    AND PRC_SRCE_TYP = 'ESTW'
    AND PRC_VALID_TYP = 'UNVERIFD'
    """

    Then I expect value of column "VERIFY_ISPC_COUNT_HSBC" in the below SQL query equals to "4":
    """
    SELECT COUNT(*) AS VERIFY_ISPC_COUNT_HSBC
    FROM FT_T_ISPC
    WHERE INSTR_ID IN (SELECT INSTR_ID FROM FT_T_ISID WHERE ISS_ID IN ( 'USN54360AD95','USY20721AL30','USN54360AE78','USN54360AF44'))
    AND PRC_TYP = 'CLOSE'
    AND PRC_CURR_CDE= 'USD'
    AND MKT_OID = '=0000000AC'
    AND PRCNG_METH_TYP = 'ESIPX'
    AND PRC_QT_METH_TYP = 'PRCQUOTE'
    AND PRC_SRCE_TYP = 'ESTW'
    AND PRC_VALID_TYP = 'UNVERIFD'
    AND PRC_TMS = TO_DATE ('30/01/2019', 'DD/MM/YYYY')
    AND ADDNL_PRC_QUAL_TYP = '1'
    AND DATA_SRC_ID = 'HSBC'
    AND ORIG_DATA_PROV_ID = 'ESTWHS'
    """

    Then I expect value of column "VERIFY_ISPC_COUNT_SSB" in the below SQL query equals to "4":
    """
    SELECT COUNT(*) AS VERIFY_ISPC_COUNT_SSB
    FROM FT_T_ISPC
    WHERE INSTR_ID IN (SELECT INSTR_ID FROM FT_T_ISID WHERE ISS_ID IN ( 'USN54360AD95','USY20721AL30','USN54360AE78','USN54360AF44'))
    AND PRC_TYP = 'CLOSE'
    AND PRC_CURR_CDE= 'USD'
    AND MKT_OID = '=0000000AC'
    AND PRCNG_METH_TYP = 'ESIPX'
    AND PRC_QT_METH_TYP = 'PRCQUOTE'
    AND PRC_SRCE_TYP = 'ESTW'
    AND PRC_VALID_TYP = 'UNVERIFD'
    AND PRC_TMS = TO_DATE ('30/01/2019', 'DD/MM/YYYY')
    AND ADDNL_PRC_QUAL_TYP = '245'
    AND DATA_SRC_ID = 'SSB'
    AND ORIG_DATA_PROV_ID = 'ESTWSS'
    """

  Scenario: TC_4: Records loaded in ISGP table for SOI's created for HSBC and Common SOI for HSBC & SSB both.
  Verify MY Data from ISGP table if the entries of participant has been done for the records loaded in ISPC table.

    Then I expect value of column "VERIFY_ISGP_COUNT" in the below SQL query equals to "12":
    """
    SELECT COUNT(*) AS VERIFY_ISGP_COUNT
    FROM FT_T_ISGP
    WHERE INSTR_ID IN (SELECT INSTR_ID FROM FT_T_ISID WHERE ISS_ID IN ( 'USN54360AD95','USY20721AL30','USN54360AE78','USN54360AF44'))
    AND PRNT_ISS_GRP_OID IN ('HSBCPRCSOI','HSBCSSBSOI','SSBPRCSOI')
    AND PRT_PURP_TYP = 'MEMBER'
    AND END_TMS IS NULL
    AND PRT_DESC IN ('HSBC Pricing Securities of Interest','HSBC and SSB Pricing Securities of Interest','SSB Pricing Securities of Interest')
    """

  Scenario: TC_5: Process Golden Price Calculation Workflow

    Given I process Goldenprice calculation with below parameters and wait for the job to be completed
      | PROCESSING_DATE                       | 20190130                                            |
      | RUNPVCFORPRVI                         | false                                               |
      | ISSUE_GROUP1                          | HSBCSSBSOI                                          |
      | RUN_UNLISTED_WARRANT_PRICE_DERIVATION | false                                               |
      | RUN_THAI_PRICE_DERIVATION             | false                                               |
      | INSTRUMENTS                           | USN54360AD95,USY20721AL30,USN54360AE78,USN54360AF44 |

  Scenario: TC_6: Verify Golden Price Calculation in FT_T_GPCS with GoldenPrice_Column in Hierarchy

    Then I expect value of column "GOLDEN_PRICE_COUNT" in the below SQL query equals to "4":
    """
    SELECT COUNT(*) AS GOLDEN_PRICE_COUNT FROM FT_T_GPCS
    WHERE INSTR_ID IN (SELECT INSTR_ID FROM FT_T_ISID WHERE ISS_ID IN ( 'USN54360AD95','USY20721AL30','USN54360AE78','USN54360AF44'))
    AND CMNT_REAS_TYP = 'GOLDENPRICE'
    AND PRC_TMS = TO_DATE ('30/01/2019', 'DD/MM/YYYY')
    AND GPRC_IND = 'Y'
    AND PRC_VALID_LIST_TXT = 'CAL;GOLDENPRICE'
    AND PPED_OID = 'ESIPRPTEOD'
    AND GPCS_TYP = 'VALID'
    AND PRCNG_METH_TYP = 'ESIPX'
    AND PRC_QT_METH_TYP = 'PRCQUOTE'
    AND PRC_SRCE_TYP = 'ESTW'
    AND DATA_SRC_ID = 'HSBC'
    """

  Scenario: TC_7: Verify Golden Price Calculation in FT_T_ISPS with GoldenPrice_Column in Hierarchy

    Then I expect value of column "ISSUEPRICE_VALIDATION_COUNT" in the below SQL query equals to "0":
    """
    SELECT COUNT(*) AS ISSUEPRICE_VALIDATION_COUNT FROM FT_T_ISPS
    WHERE ISS_PRC_ID IN ( SELECT ISS_PRC_ID FROM FT_T_ISPC WHERE INSTR_ID IN (SELECT INSTR_ID FROM FT_T_ISID WHERE ISS_ID IN( 'USN54360AD95','USY20721AL30','USN54360AE78','USN54360AF44')) AND PRC_SRCE_TYP = 'ESTW' AND PRC_TYP = 'CLOSE' AND DATA_SRC_ID='HSBC' )
    AND PPED_OID = 'ESIPRPTEOD'
    AND PRC_STAT_TYP = 'VALID'
    AND PRVI_OID = 'ESPXPRC'
    AND PRC_VALIDATION_TYP = 'GOLDENPRICE'
    """

    Then I expect value of column "ISSUEPRICE_VALIDATION_COUNT" in the below SQL query equals to "4":
    """
    SELECT COUNT(*) AS ISSUEPRICE_VALIDATION_COUNT FROM FT_T_ISPS
    WHERE ISS_PRC_ID IN ( SELECT ISS_PRC_ID FROM FT_T_ISPC WHERE INSTR_ID IN (SELECT INSTR_ID FROM FT_T_ISID WHERE ISS_ID IN( 'USN54360AD95','USY20721AL30','USN54360AE78','USN54360AF44')) AND PRC_SRCE_TYP = 'ESTW' AND PRC_TYP = 'CLOSE' AND DATA_SRC_ID='HSBC' )
    AND PPED_OID = 'ESIPRPTEOD'
    AND PRC_STAT_TYP = 'VALID'
    AND PRC_VALIDATION_TYP = 'CAL'
    """

  Scenario: TC_8: Marking particpant as deleted (update end_tms) in case the position not received for the day and thereby not validating the prices of that instrument.

    When I process RefreshSOI workflow with below parameters and wait for the job to be completed

      | GROUP_NAME   | HSBCPRCSOI                           |
      | NO_OF_BRANCH | 10                                   |
      | QUERY_NAME   | EIS_REFRESH_MANUAL_PRICE_HSBCSSB_SOI |

    Then I expect value of column "ISGP_COUNT" in the below SQL query equals to "4":
    """
    SELECT COUNT(*) AS ISGP_COUNT FROM FT_T_ISGP
    WHERE PRNT_ISS_GRP_OID = 'HSBCPRCSOI'
    AND DATA_STAT_TYP = 'INACTIVE'
    AND LAST_CHG_USR_ID = 'BATCHJOBREFRESHSOIMANUAL'
    """

    When I process RefreshSOI workflow with below parameters and wait for the job to be completed
      | GROUP_NAME   | SSBPRCSOI                            |
      | NO_OF_BRANCH | 10                                   |
      | QUERY_NAME   | EIS_REFRESH_MANUAL_PRICE_HSBCSSB_SOI |


    Then I expect value of column "ISGP_COUNT" in the below SQL query equals to "4":
    """
    SELECT COUNT(*) AS ISGP_COUNT FROM FT_T_ISGP
    WHERE PRNT_ISS_GRP_OID = 'SSBPRCSOI'
    AND DATA_STAT_TYP = 'INACTIVE'
    AND LAST_CHG_USR_ID = 'BATCHJOBREFRESHSOIMANUAL'
    """

    And I execute below query to clear ISPC and ISGP data so that file loads will be done and workflow can be tested successfully
    """
    DELETE from ft_t_gpcs WHERE ISS_PRC_ID IN (SELECT ISS_PRC_ID FROM FT_T_ISPC WHERE INSTR_ID IN (SELECT INSTR_ID FROM FT_T_ISID WHERE ISS_ID IN('USY20721AE96','USN54360AE78','USN54360AF44','USN54360AD95','USY20721AL30')
    AND ID_CTXT_TYP IN('ISIN') AND END_TMS IS NULL) AND PRC_SRCE_TYP = 'ESTW' AND PRC_TYP = 'CLOSE');
    DELETE FROM FT_T_ISPS WHERE ISS_PRC_ID IN (SELECT ISS_PRC_ID FROM FT_T_ISPC WHERE INSTR_ID IN (SELECT INSTR_ID FROM FT_T_ISID WHERE ISS_ID IN('USY20721AE96','USN54360AE78','USN54360AF44','USN54360AD95','USY20721AL30')
    AND ID_CTXT_TYP IN('ISIN') AND END_TMS IS NULL) AND PRC_SRCE_TYP = 'ESTW' AND PRC_TYP = 'CLOSE');
    DELETE FROM FT_T_ISPC WHERE INSTR_ID IN (SELECT INSTR_ID FROM FT_T_ISID WHERE ISS_ID IN('USY20721AE96','USN54360AE78','USN54360AF44','USN54360AD95','USY20721AL30')
    AND ID_CTXT_TYP IN('ISIN') AND END_TMS IS NULL) AND PRC_SRCE_TYP = 'ESTW' AND PRC_TYP = 'CLOSE';
    COMMIT
    """

    # Step 2 - Load the data from HSBC but only for 3 instrments again.

    # =============================================================================================================================================
    # Load HSBC position file with below details:
    # =============================================================================================================================================
    # POS_DATE	MKT_PRICE	BRS_SEC_ID	CUSIP	    ISIN	        SEDOL	Comments
    # 20190130	9.875           	    N54360AD9	USN54360AD95	B1Z61D9	Load data
    # 20190130	9               	            	USY20721AL30	B7FMHX1	Load data
    # 20190130	9.5412           	    N54360AE7	USN54360AE78	    	Load data
    # =============================================================================================================================================

    Given I assign "TC-07_EITW_HSBC_DMP_PRICE.csv" to variable "INPUT_FILENAME_1"
    And I assign "tests/test-data/dmp-interfaces/Taiwan/Price/Inbound" to variable "TESTDATA_PATH"

        #Load Data
    Given I copy files below from local folder "${TESTDATA_PATH}" to the host "dmp.ssh.inbound" folder "${dmp.ssh.inbound.path}":
      | ${INPUT_FILENAME_1} |

    Given I process files with below parameters and wait for the job to be completed
      | BUSINESS_FEED            |                          |
      | FILE_PATTERN             | *EITW_HSBC_DMP_PRICE.csv |
      | MESSAGE_TYPE             | EITW_MT_HSBC_PRICE       |
      | PRICE_POINT_EVENT_DEF_ID | ESIPRPTEOD               |

  # Step 3 - Load the data from SSB but only for two instruments again.

  # =============================================================================================================================================
  # Load SSB position file with below details:
  # =============================================================================================================================================
  # POS_DATE	MKT_PRICE	BRS_SEC_ID	CUSIP	    ISIN	        SEDOL	Comments
  # 20190130	9.875           	    N54360AD9	USN54360AD95	B1Z61D9	Load data
  # 20190130	9               	            	USY20721AL30	B7FMHX1	Load data
  # =============================================================================================================================================

    Given I assign "TC-07_EITW_SSB_DMP_PRICE.csv" to variable "INPUT_FILENAME_1"
    And I assign "tests/test-data/dmp-interfaces/Taiwan/Price/Inbound" to variable "TESTDATA_PATH"

        #Load Data
    Given I copy files below from local folder "${TESTDATA_PATH}" to the host "dmp.ssh.inbound" folder "${dmp.ssh.inbound.path}":
      | ${INPUT_FILENAME_1} |

    Given I process files with below parameters and wait for the job to be completed
      | BUSINESS_FEED            |                         |
      | FILE_PATTERN             | *EITW_SSB_DMP_PRICE.csv |
      | MESSAGE_TYPE             | EITW_MT_SSB_PRICE       |
      | PRICE_POINT_EVENT_DEF_ID | ESIPRPTEOD              |

    Given I process Goldenprice calculation with below parameters and wait for the job to be completed
      | PROCESSING_DATE                       | 20190130                                            |
      | RUNPVCFORPRVI                         | false                                               |
      | ISSUE_GROUP1                          | HSBCSSBSOI                                          |
      | RUN_UNLISTED_WARRANT_PRICE_DERIVATION | false                                               |
      | RUN_THAI_PRICE_DERIVATION             | false                                               |
      | INSTRUMENTS                           | USN54360AD95,USY20721AL30,USN54360AE78,USN54360AF44 |

    Then I expect value of column "GOLDEN_PRICE_COUNT" in the below SQL query equals to "3":
    """
    SELECT COUNT(*) AS GOLDEN_PRICE_COUNT FROM FT_T_GPCS
    WHERE INSTR_ID IN (SELECT INSTR_ID FROM FT_T_ISID WHERE ISS_ID IN ( 'USN54360AD95','USY20721AL30','USN54360AE78','USN54360AF44'))
    AND CMNT_REAS_TYP = 'GOLDENPRICE'
    AND PRC_TMS = TO_DATE ('30/01/2019', 'DD/MM/YYYY')
    AND GPRC_IND = 'Y'
    AND PRC_VALID_LIST_TXT = 'CAL;GOLDENPRICE'
    AND PPED_OID = 'ESIPRPTEOD'
    AND GPCS_TYP = 'VALID'
    AND PRCNG_METH_TYP = 'ESIPX'
    AND PRC_QT_METH_TYP = 'PRCQUOTE'
    AND PRC_SRCE_TYP = 'ESTW'
    AND DATA_SRC_ID = 'HSBC'
    """

    Then I expect value of column "ISSUEPRICE_VALIDATION_COUNT" in the below SQL query equals to "0":
    """
    SELECT COUNT(*) AS ISSUEPRICE_VALIDATION_COUNT FROM FT_T_ISPS
    WHERE ISS_PRC_ID IN ( SELECT ISS_PRC_ID FROM FT_T_ISPC WHERE INSTR_ID IN (SELECT INSTR_ID FROM FT_T_ISID WHERE ISS_ID IN( 'USN54360AD95','USY20721AL30','USN54360AE78','USN54360AF44')) AND PRC_SRCE_TYP = 'ESTW' AND PRC_TYP = 'CLOSE' AND DATA_SRC_ID='HSBC' )
    AND PPED_OID = 'ESIPRPTEOD'
    AND PRC_STAT_TYP = 'VALID'
    AND PRVI_OID = 'ESPXPRC'
    AND PRC_VALIDATION_TYP = 'GOLDENPRICE'
    """

    Then I expect value of column "ISSUEPRICE_VALIDATION_COUNT" in the below SQL query equals to "3":
    """
    SELECT COUNT(*) AS ISSUEPRICE_VALIDATION_COUNT FROM FT_T_ISPS
    WHERE ISS_PRC_ID IN ( SELECT ISS_PRC_ID FROM FT_T_ISPC WHERE INSTR_ID IN (SELECT INSTR_ID FROM FT_T_ISID WHERE ISS_ID IN( 'USN54360AD95','USY20721AL30','USN54360AE78','USN54360AF44')) AND PRC_SRCE_TYP = 'ESTW' AND PRC_TYP = 'CLOSE' AND DATA_SRC_ID='HSBC' )
    AND PPED_OID = 'ESIPRPTEOD'
    AND PRC_STAT_TYP = 'VALID'
    AND PRC_VALIDATION_TYP = 'CAL'
    """
