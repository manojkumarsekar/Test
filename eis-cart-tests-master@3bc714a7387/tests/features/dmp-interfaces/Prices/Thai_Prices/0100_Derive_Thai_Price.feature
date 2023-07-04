# ===================================================================================================================================================================================
# Date            JIRA        Comments
# ===================================================================================================================================================================================
# 16/09/2020      EISDEV-6332 Derive Thai Price
# 21/09/2020      EISDEV-6956 Logic Change for Scenario 8
# 11/12/2020      EISDEV-7105 Logic Changes for Thai Price.
# ===================================================================================================================================================================================

@gc_interface_prices @ignore @to_be_fixed_eisdev_7446
@bloomberg_rr
@dmp_regression_integrationtest
@gc_interface_request_reply @gc_interface_refresh_soi
@eisdev_6332 @eisdev_6956 @eisdev_7105
Feature: 001 | Price | Derive Thai Price

#  User Scenarios
#  ScenarioDesc 1  : Thai Foreign Security is in not in Holdings. Do not Derive Price
#  ScenarioDesc 2  : Thai Foreign Security is in Holdings and AVAILABLE_FII_LIMIT of local security > 0 and T date local price is received, derive foreign price from T dated Local Price
#  ScenarioDesc 3  : Thai Foreign Security is in Holdings and AVAILABLE_FII_LIMIT of local security > 0 and T date is a holiday and price from BBG is received with T-X date.
#                    Derive foreign price from T-X dated local price
#  ScenarioDesc 4  : Thai Foreign Security is in Holdings and AVAILABLE_FII_LIMIT of local security > 0 and Bloomberg always sends last available price.
#                    If there is no price received from for T or T-X from BBG means the price does not exist. Hence do not derive.
#  ScenarioDesc 5  : Thai Foreign Security is in Holdings and AVAILABLE_FII_LIMIT of local security = NULL and T date local price is received, derive foreign price from T dated Local Price
#  ScenarioDesc 6  : Thai Foreign Security is in Holdings and AVAILABLE_FII_LIMIT of local security = NULL and T date is a holiday and price from BBG is received with T-X date.
#                    Derive foreign price from T-X dated local price
#  ScenarioDesc 7  : Thai Foreign Security is in Holdings and AVAILABLE_FII_LIMIT of local security = NULL and Bloomberg always sends last available price.
#                    If there is no price received from for T or T-X from BBG means the price does not exist. Hence do not derive.
#  ScenarioDesc 8  : Thai Foreign Security is in Holdings and AVAILABLE_FII_LIMIT of Foreign Security = 0 and T dated Price foreign is available. Derive foreign price from T dated foreign Price
#  ScenarioDesc 9  : Thai Foreign Security is in Holdings and AVAILABLE_FII_LIMIT of Foreign Security = 0 and T dated Price foreign is not available. T Dated Local Price is available.
#                    Use formula (T dated Local Security Price  + (Last Observed Foreign Security Price - TX datd Local Security Price) where LOP FS Date = LOP LS Date. T-1 of both last observed price is available
#  ScenarioDesc 10 : Thai Foreign Security is in Holdings and AVAILABLE_FII_LIMIT of Foreign Security = 0 and T dated Price foreign is not available. T Dated Local Price is available.
#                    Use formula (T dated Local Security Price  + (Last Observed Foreign Security Price - TX datd Local Security Price) where LOP FS Date = LOP LS Date.
#                    T-1 of FS is available and LS is not. Match based on the T-X date
#  ScenarioDesc 11 : Thai Foreign Security is in Holdings and AVAILABLE_FII_LIMIT of Foreign Security = 0 and T dated Price foreign is not available.
#                    T Dated Local Price is not available. Derive foreign price based on last observed foreign price
#  ScenarioDesc 12 : Thai Foreign Security is in Holdings and AVAILABLE_FII_LIMIT of Foreign Security = 0 and T dated Price foreign is not available.
#                    T Dated Local Price is not available. Last Observed Foreign price is not available. Derived foreign price based on local price for T date
#  ScenarioDesc 13 : Thai Foreign Security is in Holdings and AVAILABLE_FII_LIMIT of Foreign Security = 0 and T dated Price foreign is not available.
#                    T Dated Local Price is not available. Last Observed Foreign price is not available. T dated Local Price is not available. Do not Derive.

  Scenario: Assign Variables

    Given I assign "tests/test-data/dmp-interfaces/Prices/Thai_Prices" to variable "testdata.path"
    And I assign "eis_brs_pos.xml" to variable "INPUTFILE_NAME"
    Given I assign "/dmp/in/bloomberg" to variable "BB_DOWNLOAD_DIR"
    And I assign "/dmp/out/bloomberg" to variable "BB_UPLOAD_DIR"
    And I assign "gs_smforprc_response_template.out" to variable "RESPONSE_TEMPLATENAME_SECMASTER"
    And I assign "gs_price_template.out" to variable "INPUT_FILENAME_BBG_TEMPLATE"
    And I assign "gs_price.out" to variable "INPUT_FILENAME_BBG"
    And I assign "esi_brs_thai_price" to variable "PUBLISHING_FILE_NAME"
    And I assign "/dmp/out/brs/eod" to variable "PUBLISHING_DIRECTORY"
    And I assign "expected_esi_brs_thai_price.csv" to variable "REFERENCE_EIS_BRS_THAI_PRICE"
    And I generate value with date format "YYYYMMdd" and assign to variable "VAR_SYSDATE"

    And I execute below query and extract values of "TPLUS1_DATE" into same variables
     """
     select TO_CHAR(sysdate+1, 'YYYYMMDD') AS TPLUS1_DATE from dual
     """
    And I execute below query and extract values of "TMINUS1_DATE" into same variables
     """
     select TO_CHAR(sysdate-1, 'YYYYMMDD') AS TMINUS1_DATE from dual
     """
    And I generate value with date format "yyyyMMdd" and assign to variable "T_DATE"

  Scenario: Set-up Identifiers

    Given I execute below query to "Set-up test identifiers"
    """
    ${testdata.path}/sql/set_up_identifiers.sql;
    """

  Scenario: Clean up ISPC, GPCS, ISPS

    Given I execute below query to "Clean up ISPC, GPCS, ISPS for SYSDATE-1"
    """
    ${testdata.path}/sql/cleanup_ispc_dtp1.sql;
    """

  Scenario: Set up FS to LS Linkage for Test Security in DB, If not set up

    Given I execute below queries which are separated by "##"
    """
    ${testdata.path}/sql/th_fs_ls_tagging.sql
    """

  Scenario: Set up Positions for Test Securities

    Given I execute below query to "Create BALH for Test Security with AS_OF_TMS = SYSDATE+1"
    """
    ${testdata.path}/sql/balh_sysdate_plus1.sql;
    """

  Scenario: Refresh ESITHAIFL SOI

    Given I process RefreshSOI workflow with below parameters and wait for the job to be completed
      | GROUP_NAME   | ESITHAIFL                          |
      | NO_OF_BRANCH | 5                                  |
      | QUERY_NAME   | EIS_REFRESH_THAI_FOREIGN_PRICE_SOI |

  Scenario: Refresh ESITHAILL SOI

    Given I process RefreshSOI workflow with below parameters and wait for the job to be completed
      | GROUP_NAME   | ESITHAILL                        |
      | NO_OF_BRANCH | 5                                |
      | QUERY_NAME   | EIS_REFRESH_THAI_LOCAL_PRICE_SOI |

  Scenario: Request BBG Secmaster for Local Securities to set up Available FII Limit

    Given I execute below query and extract values of "SEQ" into same variables
        """
        SELECT LPAD(VREQ_FILE_SEQ.NEXTVAL+1,8,'0') AS SEQ FROM DUAL
        """

    And I execute below query and extract values of "RESPONSE_SECMASTER" into same variables
        """
        SELECT SUBSTR(FILE_PATTERN_TYP,0,INSTR(FILE_PATTERN_TYP,'*')-1)|| '${SEQ}' || '.out' AS RESPONSE_SECMASTER
        FROM FT_CFG_VRTY
        WHERE VND_RQST_TYP = 'EIS_Secmaster_for_Price'
        """

    When I copy files below from local folder "${testdata.path}/infiles/template" to the host "dmp.ssh.inbound" folder "${BB_DOWNLOAD_DIR}":
      | ${RESPONSE_TEMPLATENAME_SECMASTER} |

    And I rename file "${BB_DOWNLOAD_DIR}/${RESPONSE_TEMPLATENAME_SECMASTER}" as "${BB_DOWNLOAD_DIR}/${RESPONSE_SECMASTER}" in the named host "dmp.ssh.inbound"

    And I process BBPerSecurity workflow with below parameters and wait for the job to be completed
      | BB_DOWNLOAD_DIR | ${BB_DOWNLOAD_DIR}      |
      | BB_UPLOAD_DIR   | ${BB_UPLOAD_DIR}        |
      | FIRM_NAME       | dl790188                |
      | REQUEST_TYPE    | EIS_Secmaster_for_Price |
      | SN              | 191305                  |
      | USER_NUMBER     | 3650834                 |
      | WORK_STATION    | 0                       |
      | GROUP_NAME      | ESITHAILL               |

    Then I expect below files to be present in the host "dmp.ssh.inbound" into folder "${BB_UPLOAD_DIR}" after processing:
      | gs_smforprc${SEQ}.req |

    Then I expect workflow is processed in DMP with total record count as "12"

  Scenario: Verify Available FII Limit is set up in INLM for one of the Local Security

    Given I expect value of column "AVAILABLE_FII_LIMIT_TH0637010Y00" in the below SQL query equals to "17.7311":

     """
     select LIMIT_CAMT as AVAILABLE_FII_LIMIT_TH0637010Y00
     from ft_t_inlm where instr_id in(
     select instr_id from ft_t_isid where iss_id = 'TH0637010Y00'
     and ID_CTXT_TYP = 'ISIN' and end_tms is null) and LIMIT_TYP = 'FIICPCT'
     """

  Scenario: Load BBG Price for Foreign Securities and Local Securities for T+1, T Date, T-1 Date

    And I create input file "${INPUT_FILENAME_BBG}" using template "${INPUT_FILENAME_BBG_TEMPLATE}" from location "${testdata.path}/infiles"

    Given I copy files below from local folder "${testdata.path}/infiles/testdata" to the host "dmp.ssh.inbound" folder "${dmp.ssh.inbound.path}":
      | ${INPUT_FILENAME_BBG} |

    When I process files with below parameters and wait for the job to be completed
      | BUSINESS_FEED |                                  |
      | FILE_PATTERN  | ${INPUT_FILENAME_BBG_TDATE}      |
      | MESSAGE_TYPE  | EIS_MT_BBG_SECURITY_PER_SECURITY |

  Scenario: Mock up scenarios - Available FII Limit

    * I reset the database connection with configuration "dmp.db.GC"
    * I assign "GS_GC" to variable "dmp.db.GC.jdbc.user"
    * I set the database connection to configuration "dmp.db.GC"

    And I execute below query to "Mock up Scenarios. Set up INLM"
    """
    ${testdata.path}/sql/set_up_available_FII_limit.sql;
    """

    * I assign "GS_GC_APP" to variable "dmp.db.GC.jdbc.user"
    * I reset the database connection with configuration "dmp.db.GC"

  Scenario: Mock up scenarios for Derivation

    And I execute below query to "Mock up Scenarios. Delete ISPC"
     """
     ${testdata.path}/sql/bbg_price_update.sql;
     """

  Scenario: Run EIS_PricingProcessConsolidated for Golden Price Derivation

    Given I process Goldenprice calculation with below parameters and wait for the job to be completed
      | PROCESSING_DATE                       | ${TPLUS1_DATE} |
      | RUN_FAIR_VALUE_DERIVATION             | false          |
      | RUN_UNLISTED_WARRANT_PRICE_DERIVATION | false          |
      | RUN_THAI_PRICE_DERIVATION             | true           |
      | INSTRUMENTS                           | TH0999010Z03   |
      | RUNPVCFORPRVI                         | false          |

  Scenario: Verify Price in ISPC

    Given I expect value of column "DERIVAED_FP_TDATE" in the below SQL query equals to "9":

     """
     SELECT count(*) as DERIVAED_FP_TDATE
     FROM   ft_t_ispc
     WHERE  prc_typ = 'DERIVE'
     AND prc_srce_typ = 'ESTHF'
     AND prc_valid_typ = 'VALID'
     AND prcng_meth_typ = 'ESITHP'
     AND Trunc(prc_tms) = Trunc(sysdate+1)
     """

  Scenario: Verify Price in DTP1

    Given I expect value of column "DTP_COUNT" in the below SQL query equals to "9":

     """
     select count(*) as DTP_COUNT
     from ft_t_dtp1 where
     trunc(process_date) = trunc(sysdate+1)
     """

  Scenario: Publish EOD Price File

    Given I process publishing wrapper with below parameters and wait for the job to be completed
      | PUBLISHING_FILE_NAME | ${PUBLISHING_FILE_NAME}.csv                                                                     |
      | SUBSCRIPTION_NAME    | EIS_DMP_TO_BRS_PRICE_VIEW_SUB                                                                   |
      | SQL                  | <![CDATA[<sql>TRUNC(PRC1_ADJST_TMS) = TRUNC(sysdate+1) and PRC1_GRP_NME = 'ESITHAIFL' </sql>]]> |

    Then I expect below files to be present in the host "dmp.ssh.inbound" into folder "${PUBLISHING_DIRECTORY}" after processing:
      | ${PUBLISHING_FILE_NAME}_${VAR_SYSDATE}_1.csv |

    Then I copy files below from remote folder "${PUBLISHING_DIRECTORY}" on host "dmp.ssh.inbound" into local folder "${testdata.path}/outfiles/runtime":
      | ${PUBLISHING_FILE_NAME}_${VAR_SYSDATE}_1.csv |

    And I remove below files in the host "dmp.ssh.inbound" from folder "${PUBLISHING_DIRECTORY}" if exists:
      | ${PUBLISHING_FILE_NAME}_${VAR_SYSDATE}_1.csv |

  Scenario Outline: Validate Output for <scenario_description>
    Given I expect column "PRICE" value to be "<expected_price>" where column "ISIN" value is "<isin>" in CSV file "${testdata.path}/outfiles/runtime/${PUBLISHING_FILE_NAME}_${VAR_SYSDATE}_1.csv"

    Examples: Scenarios with Available FII Limit of Foreign Price > 0
      | scenario_description | isin         | expected_price |
      | TC 2                 | TH0637010Y18 | 56.75          |
      | TC 3                 | TH8319010Z14 | 36             |

    Examples: Scenarios with Available FII Limit of Foreign Price is Null
      | scenario_description | isin         | expected_price |
      | TC 5                 | TH0264A10Z12 | 22.1           |
      | TC 6                 | TH0375010Z14 | 3.4            |

    Examples: Scenarios with Available FII Limit of Foreign Price = 0
      | scenario_description | isin         | expected_price |
      | TC 8                 | TH0450010Y16 | 16             |
      | TC 9                 | TH9597010015 | 25.8           |
      | TC 10                | TH0465010013 | 215.1          |
      | TC 11                | TH0015010018 | 90.75          |
      | TC 12                | TH1027010012 | 35.25          |

  Scenario: Clean up and Restore

    * I reset the database connection with configuration "dmp.db.GC"
    * I assign "GS_GC" to variable "dmp.db.GC.jdbc.user"
    * I set the database connection to configuration "dmp.db.GC"

    Given I execute below query to "Clean up test data and restore prod data"
    """
    ${testdata.path}/sql/cleanup_restore.sql;
    """

  Scenario: Setting back GC_GC_APP user to dmp.db.GC.jdbc.user property and reset the DB connection
    * I assign "GS_GC_APP" to variable "dmp.db.GC.jdbc.user"
    * I reset the database connection with configuration "dmp.db.GC"