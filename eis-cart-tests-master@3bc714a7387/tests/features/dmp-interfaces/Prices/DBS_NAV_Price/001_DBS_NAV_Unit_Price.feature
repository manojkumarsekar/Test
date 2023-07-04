# =================================================================================================================================================
# Date            JIRA        Comments
# =================================================================================================================================================
# 22/06/2019      TOM-4387    DBS Unit NAV prices from Indonesia to Aladdin
# 24/06/2019      TOM-4829    Populate Currency from MKIS, Updated Output template file and Description in scenario file
# =================================================================================================================================================
# Test Scenarios
# =================================================================================================================================================
# Date (dd/mm/yyyy)  | Nav / unit (6 d.p.) | Fund code    | Use Case                  | Load                             | Publish
# =================================================================================================================================================
# {CURR_DATE }       | 1255.74783          | HK0460       | Valid Record              | Record should be loaded          | Record should be Published
#                    | 2255.24             | HK0275       | Missing Date              | Exception Should be Thrown       | Record should not be published
# {CURR_DATE }       | 3255.34             |              | Missing Fund Code in File | Exception Should be Thrown       | Record should not be published
# {CURR_DATE }       |                     | HK0274       | Missing NAV               | Exception Should be Thrown       | Record should not be published
# {CURR_DATE }       | 3255.74             | HK0273       | Valid Record              | Record should be loaded          | Record should be Published
# {CURR_DATE }       | 67.00               | INVALIDFC    | Missing Fund Code in DB   | Exception Should be Thrown       | Record should not be published

#No regression tag observed. Hence, modular tag (Ex: gc_interface or dw_interface) has not given.
#@dmp_regression_integrationtest
@tom_4387 @tom_4829
Feature: 001 | Price | NAV Price from DBS Indonesia to DMP | Verify Price Load/Publish

  Verify Price received frin DBS for Indonesia are available in EOD Price Feed. Data should be published as part of EOD file.
  For MY, Prices with BRS_PURPOSE = ESIIDN, BRS_SOURCE = EISDN and Security Currency = MYR should be proccessed.
  Exception should be thrown for others.

  Scenario: Clear the data and Assign Variables

    Given I assign "NAV_DBS.csv" to variable "INPUT_FILENAME"
    And I assign "tests/test-data/dmp-interfaces/Prices/DBS_NAV_Price" to variable "testdata.path"
    And I generate value with date format "dd/MM/YYYY" and assign to variable "CURR_DATE"
    And I generate value with date format "YYYYMMdd" and assign to variable "VAR_SYSDATE"
    And I assign "esi_brs_p_price" to variable "PUBLISHING_FILE_NAME"
    And I assign "esi_brs_p_price_template.csv" to variable "TEMPLATE_FILE"
    And I assign "/dmp/out/brs/eod" to variable "PUBLISHING_DIRECTORY"

    And I create input file "NAV_DBS.csv" using template "NAV_DBS_Template.csv" from location "${testdata.path}/infiles"

  Scenario: Load NAV File

    Given I assign "NAV_DBS.csv" to variable "DBS_NAV_FILE"

    When I copy files below from local folder "${testdata.path}/infiles/testdata" to the host "dmp.ssh.inbound" folder "${dmp.ssh.inbound.path}":
      | ${INPUT_FILENAME} |

    When I process files with below parameters and wait for the job to be completed
      | BUSINESS_FEED |                           |
      | FILE_PATTERN  | ${INPUT_FILENAME}         |
      | MESSAGE_TYPE  | ESII_MT_DBS_DMP_NAV_PRICE |

    Then I extract new job id from jblg table into a variable "JOB_ID"

  Scenario: Data Verification : Valid Record : ISPC, PRC1 and ISGP

    Then I expect value of column "VERIFY_ISPC_COUNT_HK0460" in the below SQL query equals to "1":
    """
    SELECT COUNT(*) AS VERIFY_ISPC_COUNT_HK0460
    FROM FT_T_ISPC
    WHERE JOB_ID = '${JOB_ID}'
    AND INSTR_ID IN (SELECT INSTR_ID FROM FT_T_ISID WHERE ISS_ID = 'HK0460')
    AND UNIT_CPRC = '1255.74783'
    """

    Then I expect value of column "VERIFY_ISPC_COUNT_HK0273" in the below SQL query equals to "1":
    """
    SELECT COUNT(*) AS VERIFY_ISPC_COUNT_HK0273
    FROM FT_T_ISPC
    WHERE JOB_ID = '${JOB_ID}'
    AND INSTR_ID IN (SELECT INSTR_ID FROM FT_T_ISID WHERE ISS_ID = 'HK0273')
    AND UNIT_CPRC = '3255.74'
    """

    Then I expect value of column "VERIFY_PRC1_COUNT" in the below SQL query equals to "2":

    """
    SELECT COUNT(*) AS VERIFY_PRC1_COUNT
    FROM FT_V_PRC1
    WHERE PRC1_JOB_ID = '${JOB_ID}'
    AND PRC1_GRP_NME ='DBSPRCSOI'
    """

    Then I expect value of column "VERIFY_ISGP_COUNT" in the below SQL query equals to "2":
    """
    SELECT COUNT(*) AS VERIFY_ISGP_COUNT
    FROM FT_T_ISGP
    WHERE INSTR_ID IN (SELECT INSTR_ID FROM FT_T_ISID WHERE ISS_ID IN ('HK0460','HK0273'))
    AND PRNT_ISS_GRP_OID IN (SELECT ISS_GRP_OID FROM FT_T_ISGR WHERE ISS_GRP_ID = 'DBSPRCSOI')
    AND DATA_STAT_TYP = 'ACTIVE'
    """

  Scenario: Data Verification : Missing Price Date

    Given I expect value of column "VERIFY_MISSING_PRC_DTE" in the below SQL query equals to "1":
    """
    SELECT COUNT(*) AS VERIFY_MISSING_PRC_DTE
    FROM FT_T_NTEL
    WHERE LAST_CHG_TRN_ID IN (SELECT TRN_ID FROM FT_T_TRID WHERE JOB_ID = '${JOB_ID}')
    AND MAIN_ENTITY_ID like '%HK0275%'
    AND NOTFCN_ID = '60001'
    AND PARM_VAL_TXT like '%Cannot process file as required fields, Date%(dd/mm/yyyy) is not present in the input record%'
    AND NOTFCN_STAT_TYP = 'OPEN'
    """

  Scenario: Data Verification : Missing NAV

    Given I expect value of column "VERIFY_MISSING_PRC_NAV" in the below SQL query equals to "1":
    """
    SELECT COUNT(*) AS VERIFY_MISSING_PRC_NAV
    FROM FT_T_NTEL
    WHERE LAST_CHG_TRN_ID IN (SELECT TRN_ID FROM FT_T_TRID WHERE JOB_ID = '${JOB_ID}')
    AND MAIN_ENTITY_ID like '%HK0274%'
    AND NOTFCN_ID = '60001'
    AND PARM_VAL_TXT like '%Cannot process file as required fields, Nav%/%unit (6 d.p.) is not present in the input record.%'
    AND NOTFCN_STAT_TYP = 'OPEN'
    """

  Scenario: Data Verification : Missing Fund Code in File

    Given I expect value of column "VERIFY_MISSING_FD_CDE_FILE" in the below SQL query equals to "1":
    """
    SELECT COUNT(*) AS VERIFY_MISSING_FD_CDE_FILE
    FROM FT_T_NTEL
    WHERE LAST_CHG_TRN_ID IN (SELECT TRN_ID FROM FT_T_TRID WHERE JOB_ID = '${JOB_ID}')
    AND MAIN_ENTITY_ID like '%:%'
    AND NOTFCN_ID = '60001'
    AND PARM_VAL_TXT like '%Cannot process file as required fields, Fund Code is not present in the input record%'
    AND NOTFCN_STAT_TYP = 'OPEN'
    """

  Scenario: Data Verification : Missing Fund Code in Database

    Given I expect value of column "VERIFY_MISSING_FD_CDE_DB" in the below SQL query equals to "1":
    """
    SELECT COUNT(*) AS VERIFY_MISSING_FD_CDE_DB
    FROM FT_T_NTEL
    WHERE LAST_CHG_TRN_ID IN (SELECT TRN_ID FROM FT_T_TRID WHERE JOB_ID = '${JOB_ID}')
    AND MAIN_ENTITY_ID like '%INVALIDFC%'
    AND NOTFCN_ID = '541'
    AND PARM_VAL_TXT = 'Issue BROKERFUNDCD INVALIDFC'
    AND CHAR_VAL_TXT = 'GoldenSource could not process the incoming Issue in the message as there is dependency on the existence of the Issue with ID [BROKERFUNDCD-INVALIDFC being referenced] in the database.'
    AND NOTFCN_STAT_TYP = 'OPEN'
    """

  Scenario: Publish loaded price from DMP to BRS

  #Extract Data
    Given I remove below files in the host "dmp.ssh.inbound" from folder "${PUBLISHING_DIRECTORY}" if exists:
      | ${PUBLISHING_FILE_NAME}_*.csv |

    Then I process publishing wrapper with below parameters and wait for the job to be completed
      | PUBLISHING_FILE_NAME | ${PUBLISHING_FILE_NAME}.csv                                                                     |
      | SUBSCRIPTION_NAME    | EIS_DMP_TO_BRS_PRICE_VIEW_SUB                                                                   |
      | SQL                  | <![CDATA[<sql>TRUNC(PRC1_ADJST_TMS) = TRUNC(sysdate) and PRC1_GRP_NME != 'INTMANOVRD' </sql>]]> |

    Then I expect below files to be present in the host "dmp.ssh.inbound" into folder "${PUBLISHING_DIRECTORY}" after processing:
      | ${PUBLISHING_FILE_NAME}_${VAR_SYSDATE}_1.csv |

    Then I copy files below from remote folder "${PUBLISHING_DIRECTORY}" on host "dmp.ssh.inbound" into local folder "${testdata.path}/outfiles/runtime":
      | ${PUBLISHING_FILE_NAME}_${VAR_SYSDATE}_1.csv |

    And I remove below files in the host "dmp.ssh.inbound" from folder "${PUBLISHING_DIRECTORY}" if exists:
      | ${PUBLISHING_FILE_NAME}_${VAR_SYSDATE}_1.csv |

  Scenario: Reconcile Data

    Given I create input file "esi_brs_p_price_reference.csv" using template "esi_brs_p_price_template.csv" with below codes from location "${testdata.path}/outfiles"
      |  |  |

    Then I expect each record in file "${testdata.path}/outfiles/testdata/esi_brs_p_price_reference.csv" should exist in file "${testdata.path}/outfiles/runtime/${PUBLISHING_FILE_NAME}_${VAR_SYSDATE}_1.csv" and exceptions to be written to "${testdata.path}/outfiles/exceptions_${recon.timestamp}.csv" file

  Scenario: Refresh SOI

    Given I process RefreshSOI workflow with below parameters and wait for the job to be completed

      | GROUP_NAME   | DBSPRCSOI                            |
      | NO_OF_BRANCH | 5                                    |
      | QUERY_NAME   | EIS_REFRESH_MANUAL_PRICE_HSBCSSB_SOI |

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
    WHERE TRUNC(PRC1_ADJST_TMS) = TRUNC(SYSDATE) AND PRC1_GRP_NME ='DBSPRCSOI'
    """