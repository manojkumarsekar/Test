# =====================================================================
# Date            JIRA        Comments
# ============    ========    ========
# 07/02/2019      TOM-4044    First Version
# =====================================================================


#https://jira.intranet.asia/browse/TOM-4044
#https://jira.pruconnect.net/browse/EISDEV-7270
#EXM Rel 8 - Removing scenarios for exception validations with blank price

@gc_interface_prices
@dmp_regression_unittest
@dmp_taiwan
@tom_4044 @fa_pos_dmp_price_connection_001 @eisdev_7270
Feature: Taiwan | Price | SSB Positions | Inbound Processing

  Scenario: TC_1: Clear ISPC data

    #This step is to clear ISPC so that file loads will be done and records gets uploaded successfully.
    Given I execute below queries
    """
    DELETE FROM FT_T_ISPC WHERE INSTR_ID IN
    (
      SELECT INSTR_ID FROM FT_T_ISID
      WHERE ISS_ID IN ('USY20721AE96','USN54360AE78','USN54360AF44','USN54360AD95','USY20721AL30')
      AND ID_CTXT_TYP IN('ISIN')
      AND END_TMS IS NULL
    )
    AND PRC_SRCE_TYP = 'ESTW'
    AND PRC_TYP = 'CLOSE';
    COMMIT
    """

  Scenario: TC_2: Load the data successfully for all records.

    Given I assign "TC-01_EITW_SSB_DMP_PRICE.csv" to variable "INPUT_FILENAME_1"
    And I assign "tests/test-data/dmp-interfaces/Taiwan/Price/Inbound" to variable "TESTDATA_PATH"

    Given I copy files below from local folder "${TESTDATA_PATH}" to the host "dmp.ssh.inbound" folder "${dmp.ssh.inbound.path}":
      | ${INPUT_FILENAME_1} |

    Given I process files with below parameters and wait for the job to be completed
      | BUSINESS_FEED |                         |
      | FILE_PATTERN  | *EITW_SSB_DMP_PRICE.csv |
      | MESSAGE_TYPE  | EITW_MT_SSB_PRICE       |

    Then I extract new job id from jblg table into a variable "JOB_ID1"

  Scenario: TC_3: With the help of CGSCInvokeJavaRule rule price currency and mkt_oid is copied in ISPC table
  Verify data in FT_T_ISPC. Validation 1: Check all rows have loaded into ISPC:

    Then I expect value of column "VERIFY_ISPC_COUNT_USY20721AE96" in the below SQL query equals to "1":
    """
    SELECT COUNT(*) AS VERIFY_ISPC_COUNT_USY20721AE96
    FROM FT_T_ISPC
    WHERE INSTR_ID IN (SELECT INSTR_ID FROM FT_T_ISID WHERE ISS_ID = 'USY20721AE96')
    AND UNIT_CPRC = '10'
    AND PRC_TYP = 'CLOSE'
    AND PRC_CURR_CDE= 'USD'
    AND MKT_OID = '=0000000AC'
    AND PRCNG_METH_TYP = 'ESIPX'
    AND PRC_QT_METH_TYP = 'PRCQUOTE'
    AND PRC_SRCE_TYP = 'ESTW'
    AND PRC_VALID_TYP = 'UNVERIFD'
    AND ADDNL_PRC_QUAL_TYP = '245'
    AND ORIG_DATA_PROV_ID = 'ESTWSS'
    AND DATA_SRC_ID = 'SSB'
    """

  Scenario: TC_4: Records loaded in ISGP table for SOI's created for SSB and Common SOI for HSBC & SSB both.
  Verify MY Data from ISGP table if the entries of participant has been done for the records loaded in ISPC table.

    Then I expect value of column "VERIFY_ISGP_COUNT_USY20721AE96" in the below SQL query equals to "2":
      """
      SELECT COUNT(*) AS VERIFY_ISGP_COUNT_USY20721AE96
      FROM FT_T_ISGP
      WHERE INSTR_ID IN (SELECT INSTR_ID FROM FT_T_ISID WHERE ISS_ID = 'USY20721AE96')
      AND PRNT_ISS_GRP_OID IN ('SSBPRCSOI','HSBCSSBSOI')
      AND PRT_PURP_TYP = 'MEMBER'
      AND DATA_STAT_TYP = 'ACTIVE'
      AND PRT_DESC IN ('SSB Pricing Securities of Interest','HSBC and SSB Pricing Securities of Interest')
      """

  Scenario: TC_5: Price data is loaded even though one of the identifier is missing.

    Given I assign "TC-04_EITW_SSB_DMP_PRICE.csv" to variable "INPUT_FILENAME_4"
    And I assign "tests/test-data/dmp-interfaces/Taiwan/Price/Inbound" to variable "TESTDATA_PATH"

    Given I copy files below from local folder "${TESTDATA_PATH}" to the host "dmp.ssh.inbound" folder "${dmp.ssh.inbound.path}":
      | ${INPUT_FILENAME_4} |

    Given I process files with below parameters and wait for the job to be completed
      | BUSINESS_FEED |                         |
      | FILE_PATTERN  | *EITW_SSB_DMP_PRICE.csv |
      | MESSAGE_TYPE  | EITW_MT_SSB_PRICE       |

    Then I extract new job id from jblg table into a variable "JOB_ID1"

    Then I expect value of column "VERIFY_ISPC_COUNT_USN54360AD95" in the below SQL query equals to "1":
    """
    SELECT COUNT(*) AS VERIFY_ISPC_COUNT_USN54360AD95
    FROM FT_T_ISPC
    WHERE JOB_ID = '${JOB_ID1}'
    AND INSTR_ID IN (SELECT INSTR_ID FROM FT_T_ISID WHERE ISS_ID = 'USN54360AD95')
    AND UNIT_CPRC = '9.875'
    AND PRC_CURR_CDE= 'USD'
    AND MKT_OID = '=0000000AC'
    AND PRC_TYP = 'CLOSE'
    AND PRCNG_METH_TYP = 'ESIPX'
    AND PRC_QT_METH_TYP = 'PRCQUOTE'
    AND PRC_SRCE_TYP = 'ESTW'
    AND PRC_VALID_TYP = 'UNVERIFD'
    AND ADDNL_PRC_QUAL_TYP = '245'
    AND ORIG_DATA_PROV_ID = 'ESTWSS'
    AND DATA_SRC_ID = 'SSB'
    """

    Then I expect value of column "VERIFY_ISGP_COUNT_USN54360AD95" in the below SQL query equals to "2":
    """
    SELECT COUNT(*) AS VERIFY_ISGP_COUNT_USN54360AD95
    FROM FT_T_ISGP
    WHERE INSTR_ID IN (SELECT INSTR_ID FROM FT_T_ISID WHERE ISS_ID = 'USN54360AD95')
    AND PRNT_ISS_GRP_OID IN ('SSBPRCSOI','HSBCSSBSOI')
    AND PRT_PURP_TYP = 'MEMBER'
    AND DATA_STAT_TYP = 'ACTIVE'
    AND PRT_DESC IN ('SSB Pricing Securities of Interest','HSBC and SSB Pricing Securities of Interest')
    """

    Then I expect value of column "VERIFY_ISPC_COUNT_USY20721AL30" in the below SQL query equals to "1":
    """
    SELECT COUNT(*) AS VERIFY_ISPC_COUNT_USY20721AL30
    FROM FT_T_ISPC
    WHERE JOB_ID = '${JOB_ID1}'
    AND INSTR_ID IN (SELECT INSTR_ID FROM FT_T_ISID WHERE ISS_ID = 'USY20721AL30')
    AND UNIT_CPRC = '9'
    AND PRC_TYP = 'CLOSE'
    AND PRC_CURR_CDE= 'USD'
    AND MKT_OID = '=0000000AC'
    AND PRCNG_METH_TYP = 'ESIPX'
    AND PRC_QT_METH_TYP = 'PRCQUOTE'
    AND PRC_SRCE_TYP = 'ESTW'
    AND PRC_VALID_TYP = 'UNVERIFD'
    AND ADDNL_PRC_QUAL_TYP = '245'
    AND ORIG_DATA_PROV_ID = 'ESTWSS'
    AND DATA_SRC_ID = 'SSB'
    """

    Then I expect value of column "VERIFY_ISGP_COUNT_USY20721AL30" in the below SQL query equals to "2":
    """
    SELECT COUNT(*) AS VERIFY_ISGP_COUNT_USY20721AL30
    FROM FT_T_ISGP
    WHERE INSTR_ID IN (SELECT INSTR_ID FROM FT_T_ISID WHERE ISS_ID = 'USY20721AL30')
    AND PRNT_ISS_GRP_OID IN ('SSBPRCSOI','HSBCSSBSOI')
    AND PRT_PURP_TYP = 'MEMBER'
    AND DATA_STAT_TYP = 'ACTIVE'
    AND PRT_DESC IN ('SSB Pricing Securities of Interest','HSBC and SSB Pricing Securities of Interest')
    """

    Then I expect value of column "VERIFY_ISPC_COUNT_USN54360AE78" in the below SQL query equals to "1":
    """
    SELECT COUNT(*) AS VERIFY_ISPC_COUNT_USN54360AE78
    FROM FT_T_ISPC
    WHERE JOB_ID = '${JOB_ID1}'
    AND INSTR_ID IN (SELECT INSTR_ID FROM FT_T_ISID WHERE ISS_ID = 'USN54360AE78')
    AND UNIT_CPRC = '9.5412'
    AND PRC_CURR_CDE= 'USD'
    AND MKT_OID = '=0000000AC'
    AND PRC_TYP = 'CLOSE'
    AND PRCNG_METH_TYP = 'ESIPX'
    AND PRC_QT_METH_TYP = 'PRCQUOTE'
    AND PRC_SRCE_TYP = 'ESTW'
    AND PRC_VALID_TYP = 'UNVERIFD'
    AND ADDNL_PRC_QUAL_TYP = '245'
    AND ORIG_DATA_PROV_ID = 'ESTWSS'
    AND DATA_SRC_ID = 'SSB'
    """

    Then I expect value of column "VERIFY_ISGP_COUNT_USN54360AE78" in the below SQL query equals to "2":
    """
    SELECT COUNT(*) AS VERIFY_ISGP_COUNT_USN54360AE78
    FROM FT_T_ISGP
    WHERE INSTR_ID IN (SELECT INSTR_ID FROM FT_T_ISID WHERE ISS_ID = 'USN54360AE78')
    AND PRNT_ISS_GRP_OID IN ('SSBPRCSOI','HSBCSSBSOI')
    AND PRT_PURP_TYP = 'MEMBER'
    AND DATA_STAT_TYP = 'ACTIVE'
    AND PRT_DESC IN ('SSB Pricing Securities of Interest','HSBC and SSB Pricing Securities of Interest')
    """


    Then I expect value of column "VERIFY_ISPC_COUNT_USN54360AF44" in the below SQL query equals to "1":
    """
    SELECT COUNT(*) AS VERIFY_ISPC_COUNT_USN54360AF44
    FROM FT_T_ISPC
    WHERE JOB_ID = '${JOB_ID1}'
    AND INSTR_ID IN (SELECT INSTR_ID FROM FT_T_ISID WHERE ISS_ID = 'USN54360AF44')
    AND UNIT_CPRC = '8.95'
    AND PRC_CURR_CDE= 'USD'
    AND MKT_OID = '=0000000AC'
    AND PRC_TYP = 'CLOSE'
    AND PRCNG_METH_TYP = 'ESIPX'
    AND PRC_QT_METH_TYP = 'PRCQUOTE'
    AND PRC_SRCE_TYP = 'ESTW'
    AND PRC_VALID_TYP = 'UNVERIFD'
    AND ADDNL_PRC_QUAL_TYP = '245'
    AND ORIG_DATA_PROV_ID = 'ESTWSS'
    AND DATA_SRC_ID = 'SSB'
    """

    Then I expect value of column "VERIFY_ISGP_COUNT_USN54360AF44" in the below SQL query equals to "2":
    """
    SELECT COUNT(*) AS VERIFY_ISGP_COUNT_USN54360AF44
    FROM FT_T_ISGP
    WHERE INSTR_ID IN (SELECT INSTR_ID FROM FT_T_ISID WHERE ISS_ID = 'USN54360AF44')
    AND PRNT_ISS_GRP_OID IN ('SSBPRCSOI','HSBCSSBSOI')
    AND PRT_PURP_TYP = 'MEMBER'
    AND DATA_STAT_TYP = 'ACTIVE'
    AND PRT_DESC IN ('SSB Pricing Securities of Interest','HSBC and SSB Pricing Securities of Interest')
    """

  Scenario: TC_6: This scenario will test the notification raised in case mandatory fields such as price and Price date separately.

  Verify notification : AND PARM_VAL_TXT = 'User defined Error thrown! . Cannot process record as required fields Price Date, Price is not present in the input record.'
  =============================================================================================================================================
  Load SSB position file with below details:
  =============================================================================================================================================
  POS_DATE	MKT_PRICE	BRS_SEC_ID	CUSIP	    ISIN	        SEDOL	Comments
  10.12           	    EG1787985	USY20721AJ83	B1R98F7	Price Date is missing
  20190130                   	    N54360AD9	USN54360AD95	    	Price is missing
  =============================================================================================================================================

    Given I assign "TC-02_EITW_SSB_DMP_PRICE.csv" to variable "INPUT_FILENAME_2"
    And I assign "tests/test-data/dmp-interfaces/Taiwan/Price/Inbound" to variable "TESTDATA_PATH"

    Given I copy files below from local folder "${TESTDATA_PATH}" to the host "dmp.ssh.inbound" folder "${dmp.ssh.inbound.path}":
      | ${INPUT_FILENAME_2} |

    Given I process files with below parameters and wait for the job to be completed
      | BUSINESS_FEED |                         |
      | FILE_PATTERN  | *EITW_SSB_DMP_PRICE.csv |
      | MESSAGE_TYPE  | EITW_MT_SSB_PRICE       |

    Then I extract new job id from jblg table into a variable "JOB_ID1"

    Then I expect value of column "VERIFY_NTEL_USY20721AJ83" in the below SQL query equals to "1":
    """
    SELECT COUNT(*) AS VERIFY_NTEL_USY20721AJ83
    FROM FT_T_NTEL
    WHERE LAST_CHG_TRN_ID IN (SELECT TRN_ID FROM FT_T_TRID WHERE JOB_ID = '${JOB_ID1}'
    AND MAIN_ENTITY_ID = 'USY20721AJ83')
    AND NOTFCN_ID = '60001'
    AND NOTFCN_STAT_TYP = 'OPEN'
    """

  Scenario: TC_7: Price data failed to load as none of the identifier is present in the file
  Verify notification : AND PARM_VAL_TXT = 'User defined Error thrown! . Cannot process record as required fields Price is not present in the input record.'

    Given I assign "TC-05_EITW_SSB_DMP_PRICE.csv" to variable "INPUT_FILENAME_5"
    And I assign "tests/test-data/dmp-interfaces/Taiwan/Price/Inbound" to variable "TESTDATA_PATH"

    Given I copy files below from local folder "${TESTDATA_PATH}" to the host "dmp.ssh.inbound" folder "${dmp.ssh.inbound.path}":
      | ${INPUT_FILENAME_5} |

    Given I process files with below parameters and wait for the job to be completed
      | BUSINESS_FEED |                         |
      | FILE_PATTERN  | *EITW_SSB_DMP_PRICE.csv |
      | MESSAGE_TYPE  | EITW_MT_SSB_PRICE       |

    Then I extract new job id from jblg table into a variable "JOB_ID1"

    Then I expect value of column "VERIFY_NTEL_NOIDENTIFIER" in the below SQL query equals to "1":
     """
     SELECT COUNT(*) AS VERIFY_NTEL_NOIDENTIFIER
     FROM FT_T_NTEL
     WHERE LAST_CHG_TRN_ID IN (SELECT TRN_ID FROM FT_T_TRID WHERE JOB_ID = '${JOB_ID1}'
     AND MAIN_ENTITY_ID = 'NOIDENTIFIER')
     AND NOTFCN_ID = '60001'
     AND NOTFCN_STAT_TYP = 'OPEN'
     """

    Then I expect value of column "VERIFY_ISPC_COUNT_USY20721AE96" in the below SQL query equals to "1":
      """
      SELECT COUNT(*) AS VERIFY_ISPC_COUNT_USY20721AE96
      FROM FT_T_ISPC
      WHERE INSTR_ID IN (SELECT INSTR_ID FROM FT_T_ISID WHERE ISS_ID = 'USY20721AE96')
      AND UNIT_CPRC = '10'
      AND PRC_CURR_CDE= 'USD'
      AND MKT_OID = '=0000000AC'
      AND PRC_TYP = 'CLOSE'
      AND PRCNG_METH_TYP = 'ESIPX'
      AND PRC_QT_METH_TYP = 'PRCQUOTE'
      AND PRC_SRCE_TYP = 'ESTW'
      AND PRC_VALID_TYP = 'UNVERIFD'
      AND ADDNL_PRC_QUAL_TYP = '245'
      AND ORIG_DATA_PROV_ID = 'ESTWSS'
      AND DATA_SRC_ID = 'SSB'
      """

  Scenario: TC_8: If for a Security on same date has different price from one source, then exception will be raised.

    Given I assign "TC-06_EITW_SSB_DMP_PRICE.csv" to variable "INPUT_FILENAME_6"
    And I assign "tests/test-data/dmp-interfaces/Taiwan/Price/Inbound" to variable "TESTDATA_PATH"

    Given I copy files below from local folder "${TESTDATA_PATH}" to the host "dmp.ssh.inbound" folder "${dmp.ssh.inbound.path}":
      | ${INPUT_FILENAME_6} |

    Given I process files with below parameters and wait for the job to be completed
      | BUSINESS_FEED |                         |
      | FILE_PATTERN  | *EITW_SSB_DMP_PRICE.csv |
      | MESSAGE_TYPE  | EITW_MT_SSB_PRICE       |

    Then I extract new job id from jblg table into a variable "JOB_ID1"


    Then I expect value of column "VERIFY_NTEL_USY20721AE96" in the below SQL query equals to "1":
    """
    SELECT COUNT(*) AS VERIFY_NTEL_USY20721AE96
    FROM FT_T_NTEL
    WHERE LAST_CHG_TRN_ID IN (SELECT TRN_ID FROM FT_T_TRID WHERE JOB_ID = '${JOB_ID1}'
    AND MAIN_ENTITY_ID = 'USY20721AE96')
    AND NOTFCN_ID = '60001'
    AND NOTFCN_STAT_TYP = 'OPEN'
    """

  Scenario: TC_9: If for a Security on same date has same price from one source, then new row will be inserted.

    Then I expect value of column "VERIFY_ISPC_COUNT_USY20721AE96" in the below SQL query equals to "2":
    """
    SELECT COUNT(*) AS VERIFY_ISPC_COUNT_USY20721AE96
    FROM FT_T_ISPC
    WHERE INSTR_ID IN (SELECT INSTR_ID FROM FT_T_ISID WHERE ISS_ID = 'USY20721AE96')
    AND UNIT_CPRC = '10'
    AND PRC_CURR_CDE= 'USD'
    AND MKT_OID = '=0000000AC'
    AND PRC_TYP = 'CLOSE'
    AND PRCNG_METH_TYP = 'ESIPX'
    AND PRC_QT_METH_TYP = 'PRCQUOTE'
    AND PRC_SRCE_TYP = 'ESTW'
    AND PRC_VALID_TYP = 'UNVERIFD'
    AND ADDNL_PRC_QUAL_TYP = '245'
    AND ORIG_DATA_PROV_ID = 'ESTWSS'
    AND DATA_SRC_ID = 'SSB'
    """