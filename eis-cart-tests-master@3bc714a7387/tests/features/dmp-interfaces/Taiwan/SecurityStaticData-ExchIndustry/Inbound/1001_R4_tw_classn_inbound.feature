#https://collaborate.intranet.asia/pages/viewpage.action?pageId=45863571#MainDeck--2066775069
#https://jira.intranet.asia/browse/TOM-3374

#TOM-4099 - fetch appropriate portfolios from DB for use in tests
#TOM-4113 - clear future dated balance history (likely from other feature files)
# EISDEV-7037: Wrapper class created for BB request and replay

@gc_interface_request_reply @gc_interface_positions @eisdev_7037
@dmp_taiwan

#Reducing burden on integration test by tagging this under too_slow tag. temporarily adding this under unit_tests as integration already overloaded
@too_slow
@dmp_regression_unittest
#@dmp_regression_integrationtest
@tom_3374 @tw_classfn_in @tom_4099 @tom_4113
Feature: Request reply feature to get Taiwan Classification data for Taiwan and Taipei exchange from BB

  This testcase validate the BB Request and Reply.

  Below Steps are followed to validate this testing

  1. Load positions for 2 TW funds having INCL.INDUS_CL_SET_ID = EXCHINDST  using the "EIS_MT_BRS_EOD_POSITION_NON_LATAM" Messagetype
  2. Generate the request file it should contains newly loaded positions Plus other rows
  3. Mock up response file for corresponding loaded position and copy to dmp.ssh.outbound.path with current date and time

  Scenario: TC_1: Create Position file with POS_DATE as SYSDATE and Load into DMP

    Given I assign "PositionFileLoad_template.xml" to variable "INPUT_TEMPLATENAME"
    And I assign "PositionFileLoad.xml" to variable "INPUT_FILENAME"
    And I assign "tests/test-data/dmp-interfaces/Taiwan/SecurityStaticData-ExchIndustry" to variable "testdata.path"

    And I execute below query and extract values of "PORTFOLIO_CRTS_1;PORTFOLIO_CRTS_2" into same variables
     """
     ${testdata.path}/sql/fetch_portfolio_codes.sql
     """

    And I create input file "${INPUT_FILENAME}" using template "${INPUT_TEMPLATENAME}" with below codes from location "${testdata.path}/position"
      | POS_DATE | DateTimeFormat:M/dd/YYYY |

    And I copy files below from local folder "${testdata.path}/position/testdata" to the host "dmp.ssh.inbound" folder "${dmp.ssh.inbound.path}":
      | ${INPUT_FILENAME} |

   # Ensure the two portfolios are participants in the BB request account group
   # Ensure there are no future dated positions (created by other feature files, so rows should be small in number)
    And I execute below query
     """
     ${testdata.path}/sql/insert_bb_request_participant.sql;
     ${testdata.path}/sql/clean_future_dated_balh.sql
     """

    When I process files with below parameters and wait for the job to be completed
      | BUSINESS_FEED |                                   |
      | FILE_PATTERN  | ${INPUT_FILENAME}                 |
      | MESSAGE_TYPE  | EIS_MT_BRS_EOD_POSITION_NON_LATAM |

     #This check to verify BALH table MAX(AS_OF_TMS) rowcount with PositionFileLoad.xml file rowcount
    Then I expect value of column "BALH_COUNT" in the below SQL query equals to "6":
     """
     ${testdata.path}/sql/check_positions_loaded.sql
     """

  Scenario: TC_2: Check the BB Request Reply for EIS_Classifications

    Given I assign "${dmp.ssh.inbound.path}/bloomberg" to variable "BB_UPLOAD_DIR"
    And I assign "${dmp.ssh.outbound.path}/bloomberg" to variable "BB_DOWNLOAD_DIR"
    And I assign "gs_classification_without_mktsct_response_template.out;gs_classification_with_mktsct_response_template.out" to variable "RESPONSE_TEMPLATENAME"

    #ISCL for BBMKTSCT is not setup for below ISIN's so the request goes to BB without Market Sector in it. Since, BBMKTSCT is setup through BB loads.
    #BBMKTST will be created in this load itself and if we run this process again it will generate request with Market Sector in it.
    #This step is to clear BBMKTSCT so that request file is generated without BBMKTSCT.
    And I execute below query
	"""
	DELETE FROM FT_T_ISCL WHERE INSTR_ID IN (SELECT INSTR_ID FROM FT_T_ISID WHERE ISS_ID IN ('S61909503','S61878559','S63314702','S63485445','S68684398','S68699370') AND END_TMS IS NULL)
	AND INDUS_CL_SET_ID = 'BBMKTSCT' AND END_TMS IS NULL
	"""

    # Clear ISCL for EXCHINDST
    And I execute below query
	"""
	DELETE FROM FT_T_ISCL WHERE INSTR_ID IN (SELECT INSTR_ID FROM FT_T_ISID WHERE ISS_ID IN ('S61909503','S61878559','S63314702','S63485445','S68684398','S68699370') AND END_TMS IS NULL)
	AND INDUS_CL_SET_ID = 'EXCHINDST' AND END_TMS IS NULL
	"""

    # Clear VREQ
    And I execute below query
	"""
	UPDATE FT_T_VREQ SET VND_RQST_TYP = 'Dummy' WHERE TRUNC (VND_RQST_TMS) = TRUNC (SYSDATE) AND   VND_RQST_TYP = 'EIS_Classifications' AND
	VND_RQST_XREF_ID_CTXT_TYP = 'ISIN' AND VND_RQST_XREF_ID IN ('TW0002002003', 'TW0002801008', 'TW0001402006', 'TW0001301000', 'TW0002347002', 'TW0001101004')
	"""

    # We are copying the response file on server because request reply workflow will generate request file and expect response file with same date.
    # Since, we are not connecting to BBG for testing this is to simulate the process of request reply

    Given Setup BB request reply prerequisites with following details
      | VND_RQST_TYP            | EIS_Classifications                                                                     |
      | RESPONSE_TEMPLATE_PATH  | tests/test-data/dmp-interfaces/Taiwan/SecurityStaticData-ExchIndustry/response/template |
      | RESPONSE_TEMPLATE_FILES | ${RESPONSE_TEMPLATENAME}                                                                |
      | BB_PATH                 | ${BB_DOWNLOAD_DIR}                                                                      |

    Given I process BBPerSecurity workflow with below parameters and wait for the job to be completed
      | BB_DOWNLOAD_DIR | ${BB_DOWNLOAD_DIR}  |
      | BB_UPLOAD_DIR   | ${BB_UPLOAD_DIR}    |
      | FIRM_NAME       | dl790188            |
      | REQUEST_TYPE    | EIS_Classifications |
      | SN              | 191305              |
      | USER_NUMBER     | 3650834             |
      | WORK_STATION    | 0                   |

     #This check to verify if only 6 securities which satisfied condition for EIS_Classifications were requested and response was loaded.
    Then I expect value of column "VREQ_STATUS_CHECK" in the below SQL query equals to "PASS":
     """
      SELECT
          CASE
              WHEN COUNT (1) = 12   THEN 'PASS'
              ELSE 'FAIL'
          END
      AS VREQ_STATUS_CHECK
      FROM FT_T_VREQ
      WHERE TRUNC (VND_RQST_TMS) = TRUNC (SYSDATE) AND   VND_RQST_TYP = 'EIS_Classifications' AND   VND_RQST_XREF_ID_CTXT_TYP = 'ISIN' AND   VND_RQST_XREF_ID IN (
         'TW0002002003','TW0002801008','TW0001402006','TW0001301000','TW0002347002','TW0001101004'
      ) AND   (
          VND_RQST_STAT_TYP = 'CLOSED' OR    (
              VND_RQST_STAT_TYP = 'FAILED' AND VND_RQST_STAT_TXT = 'Processing messages in the engine failed.'
          )
      )
     """

    #This check to verify if BBMKSTSCT requested and response was loaded.
    Then I expect value of column "ISCL_BBMKTSCT_CHECK" in the below SQL query equals to "PASS":
     """
      SELECT
	CASE
		WHEN COUNT (1) = 6 THEN 'PASS'
		ELSE 'FAIL'
	END
      AS ISCL_BBMKTSCT_CHECK
      FROM FT_T_ISCL
      WHERE INSTR_ID IN ( SELECT INSTR_ID
                    FROM FT_T_ISID
                    WHERE ISS_ID IN ('S61909503', 'S61878559', 'S63314702', 'S63485445', 'S68684398', 'S68699370'
        ) AND   END_TMS IS NULL
        ) AND   INDUS_CL_SET_ID = 'BBMKTSCT' AND END_TMS IS NULL
      """

    #This check to verify if EXCHINDST requested and response was loaded.
    Then I expect value of column "ISCL_EXCHINDST_CHECK" in the below SQL query equals to "PASS":
     """
      SELECT
	CASE
		WHEN COUNT (1) = 6 THEN 'PASS'
		ELSE 'FAIL'
	END
      AS ISCL_EXCHINDST_CHECK
      FROM FT_T_ISCL
      WHERE INSTR_ID IN ( SELECT INSTR_ID
                    FROM FT_T_ISID
                    WHERE ISS_ID IN ('S61909503', 'S61878559', 'S63314702', 'S63485445', 'S68684398', 'S68699370'
        ) AND   END_TMS IS NULL
        ) AND   INDUS_CL_SET_ID = 'EXCHINDST' AND END_TMS IS NULL
      """

  Scenario: TC_3: Check the BB Request Reply for EIS_Classifications.ISCL for BBMKTSCT is already present in DB for only one request should be generated.

    Given I assign "/dmp/out/bloomberg" to variable "BB_DOWNLOAD_DIR"
    And I assign "/dmp/in/bloomberg" to variable "BB_UPLOAD_DIR"
    And I assign "gs_classification_with_mktsct_response_template.out" to variable "RESPONSE_TEMPLATENAME"


   # Clear ISCL for EXCHINDST
    And I execute below query
	"""
	DELETE FROM FT_T_ISCL WHERE INSTR_ID IN (SELECT INSTR_ID FROM FT_T_ISID WHERE ISS_ID IN ('S61909503','S61878559','S63314702','S63485445','S68684398','S68699370') AND END_TMS IS NULL)
	AND INDUS_CL_SET_ID = 'EXCHINDST' AND END_TMS IS NULL
	"""

   # Clear VREQ
    And I execute below query
	"""
	UPDATE FT_T_VREQ SET VND_RQST_TYP = 'Dummy' WHERE TRUNC (VND_RQST_TMS) = TRUNC (SYSDATE) AND   VND_RQST_TYP = 'EIS_Classifications' AND
	VND_RQST_XREF_ID_CTXT_TYP = 'ISIN' AND VND_RQST_XREF_ID IN ('TW0002002003', 'TW0002801008', 'TW0001402006', 'TW0001301000', 'TW0002347002', 'TW0001101004')
	"""

   # We are copying the response file on server because request reply workflow will generate request file and expect response file with same date.
   # Since, we are not connecting to BBG for testing this is to simulate the process of request reply

    Given Setup BB request reply prerequisites with following details
      | VND_RQST_TYP            | EIS_Classifications                                                                     |
      | RESPONSE_TEMPLATE_PATH  | tests/test-data/dmp-interfaces/Taiwan/SecurityStaticData-ExchIndustry/response/template |
      | RESPONSE_TEMPLATE_FILES | ${RESPONSE_TEMPLATENAME}                                                                |
      | BB_PATH                 | ${BB_DOWNLOAD_DIR}                                                                      |

    Given I process BBPerSecurity workflow with below parameters and wait for the job to be completed
      | BB_DOWNLOAD_DIR | ${BB_DOWNLOAD_DIR}  |
      | BB_UPLOAD_DIR   | ${BB_UPLOAD_DIR}    |
      | FIRM_NAME       | dl790188            |
      | REQUEST_TYPE    | EIS_Classifications |
      | SN              | 191305              |
      | USER_NUMBER     | 3650834             |
      | WORK_STATION    | 0                   |

   #This check to verify if only 6 securities which satisfied condition for EIS_Classifications were requested and response was loaded.
    Then I expect value of column "VREQ_STATUS_CHECK" in the below SQL query equals to "PASS":
     """
      SELECT
          CASE
              WHEN COUNT (1) = 6   THEN 'PASS'
              ELSE 'FAIL'
          END
      AS VREQ_STATUS_CHECK
      FROM FT_T_VREQ
      WHERE TRUNC (VND_RQST_TMS) = TRUNC (SYSDATE) AND   VND_RQST_TYP = 'EIS_Classifications' AND   VND_RQST_XREF_ID_CTXT_TYP = 'ISIN' AND   VND_RQST_XREF_ID IN (
         'TW0002002003','TW0002801008','TW0001402006','TW0001301000','TW0002347002','TW0001101004'
      ) AND   (
          VND_RQST_STAT_TYP = 'CLOSED' OR    (
              VND_RQST_STAT_TYP = 'FAILED' AND   VND_RQST_STAT_TXT = 'Processing messages in the engine failed.'
          )
      )
     """

   #This check to verify if BBMKSTSCT requested and response was loaded.
    Then I expect value of column "ISCL_BBMKTSCT_CHECK" in the below SQL query equals to "PASS":
     """
      SELECT
	CASE
		WHEN COUNT (1) = 6 THEN 'PASS'
		ELSE 'FAIL'
	END
      AS ISCL_BBMKTSCT_CHECK
      FROM FT_T_ISCL
      WHERE INSTR_ID IN ( SELECT INSTR_ID
                    FROM FT_T_ISID
                    WHERE ISS_ID IN ('S61909503', 'S61878559', 'S63314702', 'S63485445', 'S68684398', 'S68699370'
        ) AND   END_TMS IS NULL
        ) AND   INDUS_CL_SET_ID = 'BBMKTSCT' AND END_TMS IS NULL
      """

   #This check to verify if EXCHINDST requested and response was loaded.
    Then I expect value of column "ISCL_EXCHINDST_CHECK" in the below SQL query equals to "PASS":
     """
      SELECT
	CASE
		WHEN COUNT (1) = 6 THEN 'PASS'
		ELSE 'FAIL'
	END
      AS ISCL_EXCHINDST_CHECK
      FROM FT_T_ISCL
      WHERE INSTR_ID IN ( SELECT INSTR_ID
                    FROM FT_T_ISID
                    WHERE ISS_ID IN ('S61909503', 'S61878559', 'S63314702', 'S63485445', 'S68684398', 'S68699370'
        ) AND   END_TMS IS NULL
        ) AND   INDUS_CL_SET_ID = 'EXCHINDST' AND END_TMS IS NULL
      """

  Scenario: TC_4: Check the BB Request Reply for EIS_Classifications.ISCL for BBMKTSCT is not present in DB for only one security so one request should go to fetch Market Sector
  followed by request to fetch actual data

    Given I assign "${dmp.ssh.inbound.path}/bloomberg" to variable "BB_DOWNLOAD_DIR"
    And I assign "${dmp.ssh.outbound.path}/bloomberg" to variable "BB_UPLOAD_DIR"
    And I assign "gs_classification_without_mktsct_response_template.out;gs_classification_with_mktsct_response_template.out" to variable "RESPONSE_TEMPLATENAME"


    #ISCL for BBMKTSCT is not setup for below ISIN's so the request goes to BB without Market Sector in it. Since, BBMKTSCT is setup through BB loads.
    #BBMKTST will be created in this load itself and if we run this process again it will generate request with Market Sector in it.
    #This step is to clear BBMKTSCT so that request file is generated without BBMKTSCT.
    And I execute below query
	"""
	DELETE FROM FT_T_ISCL WHERE INSTR_ID IN (SELECT INSTR_ID FROM FT_T_ISID WHERE ISS_ID IN ('S61878559','S63314702','S63485445','S68684398','S68699370') AND END_TMS IS NULL)
	AND INDUS_CL_SET_ID = 'BBMKTSCT' AND END_TMS IS NULL
	"""

    # Clear ISCL for EXCHINDST
    And I execute below query
	"""
	DELETE FROM FT_T_ISCL WHERE INSTR_ID IN (SELECT INSTR_ID FROM FT_T_ISID WHERE ISS_ID IN ('S61909503','S61878559','S63314702','S63485445','S68684398','S68699370') AND END_TMS IS NULL)
	AND INDUS_CL_SET_ID = 'EXCHINDST' AND END_TMS IS NULL
	"""

    # Clear VREQ
    And I execute below query
	"""
	UPDATE FT_T_VREQ SET VND_RQST_TYP = 'Dummy' WHERE TRUNC (VND_RQST_TMS) = TRUNC (SYSDATE) AND   VND_RQST_TYP = 'EIS_Classifications' AND
	VND_RQST_XREF_ID_CTXT_TYP = 'ISIN' AND VND_RQST_XREF_ID IN ('TW0002002003', 'TW0002801008', 'TW0001402006', 'TW0001301000', 'TW0002347002', 'TW0001101004')
	"""

    # We are copying the response file on server because request reply workflow will generate request file and expect response file with same date.
    # Since, we are not connecting to BBG for testing this is to simulate the process of request reply

    Given Setup BB request reply prerequisites with following details
      | VND_RQST_TYP            | EIS_Classifications                                                                     |
      | RESPONSE_TEMPLATE_PATH  | tests/test-data/dmp-interfaces/Taiwan/SecurityStaticData-ExchIndustry/response/template |
      | RESPONSE_TEMPLATE_FILES | ${RESPONSE_TEMPLATENAME}                                                                |
      | BB_PATH                 | ${BB_DOWNLOAD_DIR}                                                                      |


    Given I process BBPerSecurity workflow with below parameters and wait for the job to be completed
      | BB_DOWNLOAD_DIR | ${BB_DOWNLOAD_DIR}  |
      | BB_UPLOAD_DIR   | ${BB_UPLOAD_DIR}    |
      | FIRM_NAME       | dl790188            |
      | REQUEST_TYPE    | EIS_Classifications |
      | SN              | 191305              |
      | USER_NUMBER     | 3650834             |
      | WORK_STATION    | 0                   |

     #This check to verify if only 6 securities which satisfied condition for EIS_Classifications were requested and response was loaded.
    Then I expect value of column "VREQ_STATUS_CHECK" in the below SQL query equals to "PASS":
     """
      SELECT
          CASE
              WHEN COUNT (1) = 11   THEN 'PASS'
              ELSE 'FAIL'
          END
      AS VREQ_STATUS_CHECK
      FROM FT_T_VREQ
      WHERE TRUNC (VND_RQST_TMS) = TRUNC (SYSDATE) AND   VND_RQST_TYP = 'EIS_Classifications' AND   VND_RQST_XREF_ID_CTXT_TYP = 'ISIN' AND   VND_RQST_XREF_ID IN (
         'TW0002002003','TW0002801008','TW0001402006','TW0001301000','TW0002347002','TW0001101004'
      ) AND   (
          VND_RQST_STAT_TYP = 'CLOSED' OR    (
              VND_RQST_STAT_TYP = 'FAILED' AND VND_RQST_STAT_TXT = 'Processing messages in the engine failed.'
          )
      )
     """

    #This check to verify if BBMKSTSCT requested and response was loaded.
    Then I expect value of column "ISCL_BBMKTSCT_CHECK" in the below SQL query equals to "PASS":
     """
      SELECT
	CASE
		WHEN COUNT (1) = 6 THEN 'PASS'
		ELSE 'FAIL'
	END
      AS ISCL_BBMKTSCT_CHECK
      FROM FT_T_ISCL
      WHERE INSTR_ID IN ( SELECT INSTR_ID
                    FROM FT_T_ISID
                    WHERE ISS_ID IN ('S61909503', 'S61878559', 'S63314702', 'S63485445', 'S68684398', 'S68699370'
        ) AND   END_TMS IS NULL
        ) AND   INDUS_CL_SET_ID = 'BBMKTSCT' AND END_TMS IS NULL
      """

    #This check to verify if EXCHINDST requested and response was loaded.
    Then I expect value of column "ISCL_EXCHINDST_CHECK" in the below SQL query equals to "PASS":
     """
      SELECT
	CASE
		WHEN COUNT (1) = 6 THEN 'PASS'
		ELSE 'FAIL'
	END
      AS ISCL_EXCHINDST_CHECK
      FROM FT_T_ISCL
      WHERE INSTR_ID IN ( SELECT INSTR_ID
                    FROM FT_T_ISID
                    WHERE ISS_ID IN ('S61909503', 'S61878559', 'S63314702', 'S63485445', 'S68684398', 'S68699370'
        ) AND   END_TMS IS NULL
        ) AND   INDUS_CL_SET_ID = 'EXCHINDST' AND END_TMS IS NULL
      """

  Scenario: TC_5: Teardown test data

    Given I execute below query
     """
     ${testdata.path}/sql/teardown_testdata.sql
     """