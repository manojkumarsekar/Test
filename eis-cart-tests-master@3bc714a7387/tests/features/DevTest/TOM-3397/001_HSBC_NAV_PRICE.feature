#https://jira.intranet.asia/browse/TOM-3397 (To laod unit NAV for HSBC)
#https://jira.intranet.asia/browse/TOM-4333 (To publish unit NAV from HSBC)
#https://jira.intranet.asia/browse/TOM-4423  (fields added in MDX to setup ACCV and PRFH)
#https://jira.pruconnect.net/browse/EISDEV-6055 As part of 6055, check is introduced to not load prices related to 'TWBDAM', added end_tms for ACGP for the test portfolio used. also modified test script to make the feature file re-runnable.
#EISDEV-6278 : Removed re-con based on multi-listing identifiers as they could change. keeping the check based on ISIN.

# Loading HSBC unit NAV file to store FT_T_ISPC,FT_T_ACCV and FT_T_PRFH table

@gc_interface_prices
@dmp_regression_integrationtest
@tom_3397 @tom_4333 @tom_4423 @esidev_6055 @hsbc_ssb_nav @eisdev_6278
Feature: Loading HSBC Price file to populate FT_T_ISPC table

  Scenario: TC_1: Load HSBC Price file

    Given I assign "MissingBAL_SHARE.csv" to variable "INPUT_FILENAME_1"
    And I assign "MisisngFund.csv" to variable "INPUT_FILENAME_2"
    And I assign "InvalidFund.csv" to variable "INPUT_FILENAME_3"
    And I assign "MissingDividendRate.csv" to variable "INPUT_FILENAME_4"
    And I assign "HSBC.csv" to variable "INPUT_FILENAME_5"
    And I assign "tests/test-data/DevTest/TOM-3397" to variable "testdata.path"

    And I execute below query to "Clear data for the given PRICE for FT_T_ISPC Table"
    """
    ${testdata.path}/sql/ClearData_HSBC_PRICE.sql
    """

    When I copy files below from local folder "${testdata.path}/testdata" to the host "dmp.ssh.inbound" folder "${dmp.ssh.inbound.path}":
      | ${INPUT_FILENAME_1} |
      | ${INPUT_FILENAME_2} |
      | ${INPUT_FILENAME_3} |
      | ${INPUT_FILENAME_4} |
      | ${INPUT_FILENAME_5} |

  Scenario: TC_3: Load HSBC Price file for missing fund

    Given I process files with below parameters and wait for the job to be completed
      | BUSINESS_FEED |                        |
      | FILE_PATTERN  | ${INPUT_FILENAME_2}    |
      | MESSAGE_TYPE  | EITW_MT_HSBC_NAV_PRICE |

    Then I extract new job id from jblg table into a variable "JOB_ID"

        # Checking ISPC
    Then I expect value of column "ID_COUNT_NTEL" in the below SQL query equals to "1":
    """
    SELECT COUNT(*) AS ID_COUNT_NTEL FROM FT_T_NTEL
    WHERE NOTFCN_ID='60001'
    AND NOTFCN_STAT_TYP='OPEN'
    AND PARM_VAL_TXT='User defined Error thrown! . Cannot process file as required fields, SITCA_CODE is not present in the input record.'
    AND LAST_CHG_TRN_ID IN ( SELECT TRN_ID FROM FT_T_TRID WHERE JOB_ID = '${JOB_ID}')
    """

    And I execute below query to "Clear data for the given PRICE for FT_T_ISPC Table"
    """
    ${testdata.path}/sql/ClearData_HSBC_PRICE.sql
    """

  Scenario: TC_5: Load HSBC Price file

    And I execute below query to "Remove TD001 from ACGR TWBDAM"
    """
    UPDATE FT_T_ACGP SET END_TMS = SYSDATE WHERE ACCT_ID IN (SELECT ACCT_ID FROM FT_T_ACID WHERE ACCT_ALT_ID = 'TD001') AND PRNT_ACCT_GRP_OID = 'Apsxq?d3G1';
    commit;
    """

    Given I process files with below parameters and wait for the job to be completed
      | BUSINESS_FEED |                        |
      | FILE_PATTERN  | ${INPUT_FILENAME_5}    |
      | MESSAGE_TYPE  | EITW_MT_HSBC_NAV_PRICE |

        # Checking ISPC
    Then I expect value of column "ID_COUNT_ISPC" in the below SQL query equals to "1":
    """
    SELECT COUNT(*) AS ID_COUNT_ISPC FROM FT_T_ISPC
    WHERE INSTR_ID IN (SELECT INSTR_ID FROM FT_T_ISID WHERE ISS_ID = 'CNE100001VR3' AND END_TMS IS NULL)
    AND PRCNG_METH_TYP='ESIPX'
    AND DATA_SRC_ID='HSBC'
    AND PRC_SRCE_TYP = 'ESTWHS'
    AND UNIT_CPRC='11.2282'
    AND Trunc(adjst_tms) = Trunc(sysdate)
    """

           # Checking ACCV
    Then I expect value of column "ID_COUNT_ACCV" in the below SQL query equals to "1":
    """
    SELECT COUNT(*) AS ID_COUNT_ACCV FROM FT_T_ACCV
    WHERE ACCT_ID IN (SELECT ACCT_ID FROM FT_T_ACID WHERE ACCT_ALT_ID = 'TD00101' AND END_TMS IS NULL)
    AND VALU_CURR_CDE='TWD'
    AND VALU_VAL_CAMT='175068967'
    AND NAV_CRTE = '11.2282'
    AND SHR_OUTST_CQTY = '15591947.1'
    AND DATA_SRC_ID='HSBC'
    AND Trunc(valu_adjst_tms) = Trunc(sysdate)
    """

    #Checking PRFH
    Then I expect value of column "ID_COUNT_PRFH" in the below SQL query equals to "1":
    """
    SELECT COUNT(*) AS ID_COUNT_PRFH FROM FT_T_PRFH
    WHERE ACCT_ID IN (SELECT ACCT_ID FROM FT_T_ACID WHERE ACCT_ALT_ID = 'TD00101' AND END_TMS IS NULL)
    AND CURR_CDE='TWD'
    AND INVS_CLSF_TYP='HSBC NAV'
    AND TOT_ADD_CAMT = '2875092'
    AND TOT_WDRWL_CAMT = '113345'
    AND TOT_NET_DIV_CAMT = '1'
    """

               # Checking ISGP
    Then I expect value of column "ID_COUNT_ISGP" in the below SQL query equals to "1":
    """
    SELECT COUNT(*) AS ID_COUNT_ISGP FROM FT_T_ISGP
    WHERE PRT_DESC='HSBC Nav Pricing Securities of Interest'
    AND DATA_SRC_ID='HSBC'
    AND INSTR_ID IN (SELECT INSTR_ID FROM FT_T_ISID WHERE ISS_ID = 'CNE100001VR3' AND END_TMS IS NULL)
    """


  Scenario: TC_6: Publish NAV files

    Given I assign "esi_nav_hsbc" to variable "PUBLISHING_FILE_NAME"
    And I generate value with date format "YYYYMMdd" and assign to variable "VAR_SYSDATE"
    And I assign "/dmp/out/brs/eod" to variable "PUBLISHING_DIR"

    And I remove below files in the host "dmp.ssh.inbound" from folder "${PUBLISHING_DIR}" if exists:
      | ${PUBLISHING_FILE_NAME}_${VAR_SYSDATE}_1.csv |

    When I process publishing wrapper with below parameters and wait for the job to be completed
      | PUBLISHING_FILE_NAME | ${PUBLISHING_FILE_NAME}.csv                                     |
      | SUBSCRIPTION_NAME    | EIS_DMP_TO_BRS_PRICE_VIEW_SUB                                   |
      | SQL                  | &lt;sql&gt; TRUNC(PRC1_ADJST_TMS) =TRUNC(SYSDATE ) &lt;/sql&gt; |

    Then I expect below files to be present in the host "dmp.ssh.inbound" into folder "${PUBLISHING_DIR}" after processing:
      | ${PUBLISHING_FILE_NAME}_${VAR_SYSDATE}_1.csv |

    Then I copy files below from remote folder "${PUBLISHING_DIR}" on host "dmp.ssh.inbound" into local folder "tests/test-data/DevTest/TOM-3397/outfiles":
      | ${PUBLISHING_FILE_NAME}_${VAR_SYSDATE}_1.csv |

  Scenario: TC_7: Check the price for PORTFOLIO in NAV outbound file

    Given I assign "${testdata.path}/outfiles/${PUBLISHING_FILE_NAME}_${VAR_SYSDATE}_1.csv" to variable "CSV_FILE"

    #Check if ISIN has value CNE100001VR3 in the outbound
    Given I expect column "ISIN" value to be "CNE100001VR3" where columns values are as below in CSV file "${CSV_FILE}"
      | DATE   | 20190417     |
      | PRICE  | 11.2282      |
      | ISIN   | CNE100001VR3 |
      | SOURCE | ESTWHS       |