#https://collaborate.intranet.asia/display/TOMTN/Taiwan+Security+-+BBG+Total+Equity
#https://jira.intranet.asia/browse/TOM-4135
#https://jira.intranet.asia/browse/TOM-5117 - test we're not sending null tickers in total equity request
#EISDEV-5507: Added PHYSICAL_RQST_IND = Y clause to check for only those Requests which went to BB
#EISDEV-6318: Duplicate VREQs generated for multilisted securities fix. As a result, the count of expected VREQs reduces
#EISDEV-7037: Wrapper class created for BB request and replay

@gc_interface_positions @gc_interface_request_reply @eisdev_7037
@dmp_regression_integrationtest
@dmp_taiwan
@tom_4135 @tw_total_equity_rr @tom_5117 @tw_total_equity @dmp_gs_upgrade @eisdev_5507 @eisdev_6318
Feature: Request reply feature to get Total Equity from BB for 3 different periods (Annually, Semi-Annually & Quarterly)

  This testcase validate the BB Request and Reply.

  Below Steps are followed to validate this testing

  1. Load positions for 2 TW funds configured to fetch
  2. Generate the request file it should contains newly loaded positions Plus other rows
  3. Mock up response file for corresponding loaded position and copy to dmp.ssh.outbound.path with current date and time

  Scenario: TC_1: Create Position file with POS_DATE as SYSDATE and Load into DMP

    Given I assign "PositionFileLoad_template.xml" to variable "INPUT_TEMPLATENAME"
    And I assign "PositionFileLoad.xml" to variable "INPUT_FILENAME"
    And I assign "tests/test-data/dmp-interfaces/Taiwan/Total_Equity" to variable "testdata.path"

    And I execute below query and extract values of "PORTFOLIO_CRTS_1;PORTFOLIO_CRTS_2" into same variables
     """
     ${testdata.path}/sql/fetch_portfolio_codes.sql
     """

    And I create input file "${INPUT_FILENAME}" using template "${INPUT_TEMPLATENAME}" with below codes from location "${testdata.path}/position"
      | POS_DATE | DateTimeFormat:M/dd/YYYY |

    And I copy files below from local folder "${testdata.path}/position/testdata" to the host "dmp.ssh.inbound" folder "${dmp.ssh.inbound.path}":
      | ${INPUT_FILENAME} |

    # Ensure there are no future dated positions (created by other feature files, so rows should be small in number)
    And I execute below query
     """
     ${testdata.path}/sql/clean_future_dated_balh.sql
     """

    And I execute below query
     """
     UPDATE ft_t_isid SET end_tms = sysdate-1, start_tms = sysdate-1 WHERE id_ctxt_typ = 'BNDEQYTCKER' AND end_tms is null
     AND instr_id IN (SELECT instr_id FROM ft_t_isid WHERE iss_id IN ('XS1453462076','USG21886AB53') AND end_tms IS NULL)
     """

    And I execute below query
     """
     DELETE FROM FT_T_ISAM WHERE ISS_AMT_TYP IN ('TOTEQYS','TOTEQYQ','TOTEQYA')
     AND END_TMS IS NULL AND INSTR_ID IN (SELECT INSTR_ID FROM FT_T_ISID WHERE
     ISS_ID IN ('823 HK','883 HK','UOB SP','3328 HK')
     AND ID_CTXT_TYP IN ('BNDEQYTCKER','BBCPTICK') AND END_TMS IS NULL)
     """

    When I process files with below parameters and wait for the job to be completed
      | BUSINESS_FEED |                                   |
      | FILE_PATTERN  | ${INPUT_FILENAME}                 |
      | MESSAGE_TYPE  | EIS_MT_BRS_EOD_POSITION_NON_LATAM |

    #This check to verify BALH table MAX(AS_OF_TMS) rowcount with PositionFileLoad.xml file rowcount
    Then I expect value of column "BALH_COUNT" in the below SQL query equals to "7":
     """
     ${testdata.path}/sql/check_positions_loaded.sql
     """


  Scenario: TC_2: Check the BB Request Reply for EIS_Secmaster

    Given I assign "${dmp.ssh.inbound.path}/bloomberg" to variable "BB_UPLOAD_DIR"
    And I assign "${dmp.ssh.outbound.path}/bloomberg" to variable "BB_DOWNLOAD_DIR"
    And I assign "gs_secmaster_4135_001.out" to variable "RESPONSE_TEMPLATENAME"


    # Clear VREQ
    And I execute below query
	"""
    UPDATE FT_T_VREQ SET VND_RQST_TYP = 'Dummy' WHERE TRUNC (VND_RQST_TMS) = TRUNC (SYSDATE) AND   VND_RQST_TYP = 'EIS_Secmaster' AND
    VND_RQST_XREF_ID_CTXT_TYP = 'ISIN' AND VND_RQST_XREF_ID IN ('USG21886AB53', 'XS1453462076')
	"""
    # We are copying the response file on server because request reply workflow will generate request file and expect response file with same date.
    # Since, we are not connecting to BBG for testing this is to simulate the process of request reply

    Given Setup BB request reply prerequisites with following details
      | VND_RQST_TYP            | EIS_Secmaster                                                        |
      | RESPONSE_TEMPLATE_PATH  | tests/test-data/dmp-interfaces/Taiwan/Total_Equity/response/template |
      | RESPONSE_TEMPLATE_FILES | ${RESPONSE_TEMPLATENAME}                                             |
      | BB_PATH                 | ${BB_DOWNLOAD_DIR}                                                   |

    Given I process BBPerSecurity workflow with below parameters and wait for the job to be completed
      | BB_DOWNLOAD_DIR | ${BB_DOWNLOAD_DIR} |
      | BB_UPLOAD_DIR   | ${BB_UPLOAD_DIR}   |
      | FIRM_NAME       | dl790188           |
      | REQUEST_TYPE    | EIS_Secmaster      |
      | SN              | 191305             |
      | USER_NUMBER     | 3650834            |
      | WORK_STATION    | 0                  |

     #This check to verify if only 2 securities which satisfied condition for EIS_Secmaster were requested and response was loaded.
    Then I expect value of column "VREQ_STATUS_CHECK" in the below SQL query equals to "PASS":
    """
    SELECT CASE WHEN COUNT (1) = 2 THEN 'PASS' ELSE 'FAIL' END AS VREQ_STATUS_CHECK
    FROM FT_T_VREQ WHERE TRUNC (VND_RQST_TMS) = TRUNC (SYSDATE) AND VND_RQST_TYP = 'EIS_Secmaster'
    AND VND_RQST_XREF_ID_CTXT_TYP = 'ISIN' AND VND_RQST_XREF_ID IN ('USG21886AB53', 'XS1453462076')
    AND ( VND_RQST_STAT_TYP = 'CLOSED' OR (VND_RQST_STAT_TYP = 'FAILED'
    AND VND_RQST_STAT_TXT = 'Processing messages in the engine failed.'))
    """

    #This check to verify if BND_TO_EQY_TICKER was loaded requested and response was loaded.
    Then I expect value of column "ISID_COUNT" in the below SQL query equals to "2":
    """
    SELECT COUNT(*) AS ISID_COUNT FROM FT_T_ISID WHERE ID_CTXT_TYP = 'BNDEQYTCKER'
    AND END_TMS IS NULL AND INSTR_ID IN (SELECT INSTR_ID FROM FT_T_ISID
    WHERE ISS_ID IN ('USG21886AB53', 'XS1453462076')
    AND END_TMS IS NULL AND ID_CTXT_TYP = 'ISIN')
    """


  Scenario: TC_3: Check the BB Request Reply for EIS_FundamentalsTE

    Given I assign "${dmp.ssh.inbound.path}/bloomberg" to variable "BB_UPLOAD_DIR"
    And I assign "${dmp.ssh.outbound.path}/bloomberg" to variable "BB_DOWNLOAD_DIR"
    And I assign "gs_fundametals_4135_001.out" to variable "RESPONSE_TEMPLATENAME"

    # Clear VREQ
    And I execute below query
    """
    UPDATE FT_T_VREQ SET VND_RQST_TYP = 'Dummy' WHERE TRUNC (VND_RQST_TMS) = TRUNC (SYSDATE) AND   VND_RQST_TYP = 'EIS_FundamentalsTE' AND
    VND_RQST_XREF_ID_CTXT_TYP = 'TICKER' AND VND_RQST_XREF_ID IN ('823','883','UOB','3328')
    """
#    # We are copying the response file on server because request reply workflow will generate request file and expect response file with same date.
#    # Since, we are not connecting to BBG for testing this is to simulate the process of request reply

    Given Setup BB request reply prerequisites with following details
      | VND_RQST_TYP           | EIS_FundamentalsTE                                                   |
      | RESPONSE_TEMPLATE_PATH | tests/test-data/dmp-interfaces/Taiwan/Total_Equity/response/template |
      | RESPONSE_TEMPLATE_FILES | ${RESPONSE_TEMPLATENAME}          |
      | BB_PATH                 | ${BB_DOWNLOAD_DIR}                |

    Given I process BBPerSecurity workflow with below parameters and wait for the job to be completed
      | BB_DOWNLOAD_DIR | ${BB_DOWNLOAD_DIR} |
      | BB_UPLOAD_DIR   | ${BB_UPLOAD_DIR}   |
      | FIRM_NAME       | dl790188           |
      | REQUEST_TYPE    | EIS_FundamentalsTE |
      | SN              | 191305             |
      | USER_NUMBER     | 3650834            |
      | WORK_STATION    | 0                  |

    #This check to verify if only 2 securities which satisfied condition for EIS_Secmaster were requested and response was loaded.
    Then I expect value of column "VREQ_STATUS_CHECK" in the below SQL query equals to "PASS":
     """
      SELECT CASE WHEN COUNT (1) = 4 THEN 'PASS' ELSE 'FAIL' END AS VREQ_STATUS_CHECK
      FROM FT_T_VREQ WHERE TRUNC (VND_RQST_TMS) = TRUNC (SYSDATE) AND VND_RQST_TYP = 'EIS_FundamentalsTE'
      AND VND_RQST_XREF_ID_CTXT_TYP = 'TICKER' AND VND_RQST_XREF_ID IN ('823','883','UOB','3328')
      AND ( VND_RQST_STAT_TYP = 'CLOSED' OR (VND_RQST_STAT_TYP = 'FAILED'
      AND VND_RQST_STAT_TXT = 'Processing messages in the engine failed.'))
     """

    #This check to verify if Total Equity is getting stored for all three duration
    Then I expect value of column "ISAM_STATUS_CHECK" in the below SQL query equals to "PASS":
     """
      SELECT CASE WHEN COUNT (1) > 14 THEN 'PASS' ELSE 'FAIL' END AS ISAM_STATUS_CHECK FROM FT_T_ISAM WHERE ISS_AMT_TYP IN ('TOTEQYS','TOTEQYQ','TOTEQYA')
      AND END_TMS IS NULL AND INSTR_ID IN (SELECT INSTR_ID FROM FT_T_ISID WHERE
      ISS_ID IN ('823 HK','883 HK','UOB SP','3328 HK')
      AND ID_CTXT_TYP IN ('BNDEQYTCKER','BBCPTICK') AND END_TMS IS NULL)
     """

  Scenario: TC_4: Check no total equity requests made for securities with no ticker

    #Obfuscate ticker for one of our test securities
    Given I execute below query
    """
    UPDATE ft_t_isid 
    SET    id_ctxt_typ = id_ctxt_typ || '$' 
    WHERE  id_ctxt_typ IN ('BBCPTICK', 'BNDEQYTCKER') 
    AND    end_tms IS NULL 
    AND    instr_id IN (SELECT instr_id FROM ft_t_isid WHERE id_ctxt_typ = 'ISIN' AND end_tms IS NULL AND iss_id IN ('USG21886AB53', 'XS1453462076'))
    """

    #Check there are no requests without an identifying ticker being sent to BBG
    Then I expect value of column "VREQ_ID_NULL_COUNT" in the below SQL query equals to "0":
    """
    SELECT COUNT(1) AS VREQ_ID_NULL_COUNT
    FROM   TABLE(XMLSEQUENCE(eis_bbrequest('EIS','dl790188',NULL,'EIS_FundamentalsTE','191305','3650834','0','N').Extract('//Request'))) x 
    WHERE  VALUE(x).EXTRACT('/Request/Identifier') IS NULL
    """

  Scenario: TC_5: Teardown test data

    Given I execute below query
     """
     ${testdata.path}/sql/teardown_testdata.sql
     """

    #Un-obfuscate ticker for one of our test securities in case they're used by any other tests (part of different scenario so it runs even if TC_4 fails)
    Given I execute below query
    """
    UPDATE ft_t_isid 
    SET    id_ctxt_typ = REPLACE(id_ctxt_typ, '$')
    WHERE  id_ctxt_typ IN ('BBCPTICK$', 'BNDEQYTCKER$') 
    AND    end_tms IS NULL 
    AND    instr_id IN (SELECT instr_id FROM ft_t_isid WHERE id_ctxt_typ = 'ISIN' AND end_tms IS NULL AND iss_id IN ('USG21886AB53', 'XS1453462076'))
    """