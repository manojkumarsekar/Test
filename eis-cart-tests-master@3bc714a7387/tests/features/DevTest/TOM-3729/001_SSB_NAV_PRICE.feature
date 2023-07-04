#https://jira.intranet.asia/browse/TOM-3729 (To laod unit NAV for SSB)
#https://jira.intranet.asia/browse/TOM-4333 (To publish unit NAV from SSB)
#https://jira.intranet.asia/browse/TOM-4424 (fields added in MDX to setup ACCV and PRFH)
#https://jira.pruconnect.net/browse/EISDEV-6055 : Updated clear data script to make this feature file re-runnable
#https://jira.pruconnect.net/browse/EISDEV-6194 : this portfolio is now included in exclusion, Updated script to load the data.

@gc_interface_prices
@dmp_regression_integrationtest
@tom_3729 @tom_4424 @tom_4333 @esidev_6055 @hsbc_ssb_nav @eisdev_6194
Feature: Loading SSB Price file to populate FT_T_ISPC table

  Scenario: TC_1: clear data

    Given I assign "MissingFund_SSB.csv" to variable "INPUT_FILENAME_1"
    And I assign "MissingDividendRate.csv" to variable "INPUT_FILENAME_2"
    And I assign "MissingBAL_SHARE.csv" to variable "INPUT_FILENAME_3"
    And  I assign "SSB_NAV.csv" to variable "INPUT_FILENAME_4"
    And I assign "InvalidFund_SSB.csv" to variable "INPUT_FILENAME_5"


    And I assign "tests/test-data/DevTest/TOM-3729" to variable "testdata.path"

    # Clear data for the given PRICE for FT_T_ISPC Table
    And I execute below query
    """
    ${testdata.path}/sql/ClearDataACCVandISPC.sql
    """

    When I copy files below from local folder "${testdata.path}/testdata" to the host "dmp.ssh.inbound" folder "${dmp.ssh.inbound.path}":
      | ${INPUT_FILENAME_1} |
      | ${INPUT_FILENAME_2} |
      | ${INPUT_FILENAME_3} |
      | ${INPUT_FILENAME_4} |
      | ${INPUT_FILENAME_5} |


  Scenario: TC_2: Load SSB Price file for missing fund

    Given I process files with below parameters and wait for the job to be completed
      | BUSINESS_FEED |                        |
      | FILE_PATTERN  | ${INPUT_FILENAME_1}    |
      | MESSAGE_TYPE  | EITW_MT_SSB_NAV_PRICE |

    Then I extract new job id from jblg table into a variable "JOB_ID"

     # Checking ISPC
    Then I expect value of column "ID_COUNT_NTEL" in the below SQL query equals to "1":
    """
    SELECT COUNT(*) AS ID_COUNT_NTEL FROM FT_T_NTEL
    WHERE NOTFCN_ID='60001'
    AND NOTFCN_STAT_TYP='OPEN'
    AND PARM_VAL_TXT='User defined Error thrown! . Cannot process file as required fields, FUND_NO is not present in the input record.'
    AND LAST_CHG_TRN_ID IN ( SELECT TRN_ID FROM FT_T_TRID WHERE JOB_ID = '${JOB_ID}')
    """


 # Clear data for the given PRICE for FT_T_ISPC Table
    And I execute below query
    """
    ${testdata.path}/sql/ClearDataACCVandISPC.sql
    """

    And I execute below query to "Remove TD001 from ACGR TWBDAM"
    """
    UPDATE FT_T_ACGP SET END_TMS = SYSDATE WHERE ACCT_ID IN (SELECT ACCT_ID FROM FT_T_ACID WHERE ACCT_ALT_ID = 'TD00102') AND PRNT_ACCT_GRP_OID = 'Apsxq?d3G1';
    commit;
    """

  Scenario: TC_5: Load HSBC Price file to setup ACCv and PRFh

    Given I process files with below parameters and wait for the job to be completed
      | BUSINESS_FEED |                       |
      | FILE_PATTERN  | ${INPUT_FILENAME_4}   |
      | MESSAGE_TYPE  | EITW_MT_SSB_NAV_PRICE |

        # Checking ISPC
    Then I expect value of column "ID_COUNT_ISPC" in the below SQL query equals to "1":
    """
    SELECT COUNT(*) AS ID_COUNT_ISPC FROM FT_T_ISPC
    WHERE INSTR_ID IN (SELECT INSTR_ID FROM FT_T_ISID WHERE ISS_ID = 'JP1300511G61' AND END_TMS IS NULL)
    AND PRCNG_METH_TYP='ESIPX'
    AND DATA_SRC_ID='SSB'
    AND PRC_SRCE_TYP = 'ESTWSS'
    AND UNIT_CPRC='10.9'
    AND Trunc(adjst_tms) = Trunc(sysdate)
    """

         # Checking ACCV
    Then I expect value of column "ID_COUNT_ACCV" in the below SQL query equals to "1":
    """
    SELECT COUNT(*) AS ID_COUNT_ACCV FROM FT_T_ACCV
    WHERE ACCT_ID IN (SELECT ACCT_ID FROM FT_T_ACID WHERE ACCT_ALT_ID = 'TD00102' AND END_TMS IS NULL)
    AND VALU_CURR_CDE='TWD'
    AND VALU_VAL_CAMT='175068967'
    AND NAV_CRTE = '10.9'
    AND SHR_OUTST_CQTY = '334'
    AND DATA_SRC_ID='SSB'
    AND Trunc(valu_adjst_tms) = Trunc(sysdate)
    """

    #Checking PRFH
    Then I expect value of column "ID_COUNT_PRFH" in the below SQL query equals to "1":
    """
    SELECT COUNT(*) AS ID_COUNT_PRFH FROM FT_T_PRFH
    WHERE ACCT_ID IN (SELECT ACCT_ID FROM FT_T_ACID WHERE ACCT_ALT_ID = 'TD00102' AND END_TMS IS NULL)
    AND CURR_CDE='TWD'
    AND INVS_CLSF_TYP='SSB NAV'
    AND TOT_ADD_CAMT = '44'
    AND TOT_WDRWL_CAMT = '55'
    AND TOT_NET_DIV_CAMT ='1'
    """

    # Checking ISGP
    Then I expect value of column "ID_COUNT_ISGP" in the below SQL query equals to "1":
    """
    SELECT COUNT(*) AS ID_COUNT_ISGP FROM FT_T_ISGP
    WHERE PRT_DESC='SSB Nav Pricing Securities of Interest'
    AND DATA_SRC_ID='SSB'
    AND INSTR_ID IN (SELECT INSTR_ID FROM FT_T_ISID WHERE ISS_ID = 'JP1300511G61' AND END_TMS IS NULL)
    """


  Scenario: TC_6: Publish NAV files

    Given I assign "esi_nav_ssb" to variable "PUBLISHING_FILE_NAME"
    And I generate value with date format "YYYYMMdd" and assign to variable "VAR_SYSDATE"
    And I assign "/dmp/out/brs/eod" to variable "PUBLISHING_DIR"

    And I remove below files in the host "dmp.ssh.inbound" from folder "${PUBLISHING_DIR}" if exists:
      | ${PUBLISHING_FILE_NAME}_${VAR_SYSDATE}_1.csv |

    When I process publishing wrapper with below parameters and wait for the job to be completed
      | PUBLISHING_FILE_NAME | ${PUBLISHING_FILE_NAME}.csv   |
      | SUBSCRIPTION_NAME    | EIS_DMP_TO_BRS_PRICE_VIEW_SUB |
      | SQL                  | &lt;sql&gt; TRUNC(PRC1_ADJST_TMS) =TRUNC(SYSDATE ) &lt;/sql&gt; |

    Then I expect below files to be present in the host "dmp.ssh.inbound" into folder "${PUBLISHING_DIR}" after processing:
      | ${PUBLISHING_FILE_NAME}_${VAR_SYSDATE}_1.csv |

    Then I copy files below from remote folder "${PUBLISHING_DIR}" on host "dmp.ssh.inbound" into local folder "tests/test-data/DevTest/TOM-3729/outfiles":
      | ${PUBLISHING_FILE_NAME}_${VAR_SYSDATE}_1.csv |

    Scenario: TC_7: Check the price for PORTFOLIO in NAV outbound file

    Given I assign "${testdata.path}/outfiles/${PUBLISHING_FILE_NAME}_${VAR_SYSDATE}_1.csv" to variable "CSV_FILE"

 #Check if ISIN has value JP1300511G61 in the outbound
    Given I expect column "ISIN" value to be "JP1300511G61" where columns values are as below in CSV file "${CSV_FILE}"
      | DATE      | 20190417     |
      | PRICE     | 10.9         |
      | CLIENT_ID | ESL3565880   |
      | SEDOL     | BD5VSM6      |
      | SOURCE    | ESTWSS       |
      | CUSIP     | J2S39KNW2    |