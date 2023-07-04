#https://collaborate.intranet.asia/pages/viewpage.action?pageId=45863571#MainDeck--2066775069
#https://jira.intranet.asia/browse/TOM-3374

#TOM-4099 - fetch appropriate portfolios from DB for use in tests
#TOM-4113 - clear future dated balance history (likely from other feature files)
#TOM-4559 - Taiwan | TWSE Classifications | Change to tag name
# EISDEV-7037: Wrapper class created for BB request and replay

@gc_interface_request_reply @gc_interface_positions @gc_interface_cdf @eisdev_7037
@dmp_taiwan

#Reducing burden on integration test by tagging this under too_slow tag. temporarily adding this under unit_tests as integration already overloaded
@too_slow
@dmp_regression_unittest
#@dmp_regression_integrationtest
@tom_3374 @dmp_interfaces @taiwan_dmp_interfaces @tw_classfn_out @tom_4099 @tom_4113 @tom_4559 @brs_cdf
Feature: Request reply feature to get Taiwan Classification data for Taiwan and Taipei exchange from BB and publish it to BRS in CDF file

  CDF fields to be sourced from Bloomberg and published to BRS
  This testcase validate the BB Request and Reply.

  Below Steps are followed to validate this testing

  1. Load positions for 2 TW funds having INCL.INDUS_CL_SET_ID = EXCHINDST  using the "EIS_MT_BRS_EOD_POSITION_NON_LATAM" Messagetype
  2. Generate the request file it should contains newly loaded positions Plus other rows
  3. Mock up response file for corresponding loaded position and copy to dmp.ssh.outbound.path with current date and time
  4. Publish data and check if the pubished file has CDF fields in it which was loaded in above steps

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

     #This check to verify BALH table MAX(AS_OF_TMS) rowcount WITH PositionFileLoad.xml file rowcount
    Then I expect value of column "BALH_COUNT" in the below SQL query equals to "6":
     """
     ${testdata.path}/sql/check_positions_loaded.sql
     """

  Scenario: TC_2: Check the BB Request Reply for EIS_Classifications

    Given I assign "${dmp.ssh.inbound.path}/bloomberg" to variable "BB_UPLOAD_DIR"
    And I assign "${dmp.ssh.outbound.path}/bloomberg" to variable "BB_DOWNLOAD_DIR"
    And I assign "gs_classification_without_mktsct_response_template.out;gs_classification_with_mktsct_response_template.out" to variable "RESPONSE_TEMPLATENAME"

     #ISCL for EXCHINDST is not setup for below ISIN's so the request goes to BB without Market Sector in it. Since, EXCHINDST is setup through BB loads.
    #BBMKTST will be created in this load itself and if we run this process again it will generate request with Market Sector in it.
    #This step is to clear EXCHINDST so that request file is generated without EXCHINDST.
    And I execute below query
	"""
	DELETE FROM FT_T_ISCL WHERE INSTR_ID IN (SELECT INSTR_ID FROM FT_T_ISID WHERE ISS_ID IN ('S61909503','S61878559','S63314702','S63485445','S68684398','S68699370') AND END_TMS IS NULL)
	AND INDUS_CL_SET_ID = 'EXCHINDST' AND END_TMS IS NULL
	"""

    And I execute below query
	"""
	DELETE FROM FT_T_ISCL WHERE INSTR_ID IN (SELECT INSTR_ID FROM FT_T_ISID WHERE ISS_ID IN ('S61909503','S61878559','S63314702','S63485445','S68684398','S68699370') AND END_TMS IS NULL)
	AND INDUS_CL_SET_ID = 'BBMKTSCT' AND END_TMS IS NULL
	"""
    Given Setup BB request reply prerequisites with following details
      | VND_RQST_TYP            | EIS_Classifications                     |
      | RESPONSE_TEMPLATE_PATH  | tests/test-data/dmp-interfaces/Taiwan/SecurityStaticData-ExchIndustry/response/template |
      | RESPONSE_TEMPLATE_FILES | ${RESPONSE_TEMPLATENAME}          |
      | BB_PATH                 | ${BB_DOWNLOAD_DIR}                |

    # We are copying the response file on server because request reply workflow will generate request file and expect response file with same date.
    # Since, we are not connecting to BBG for testing this is to simulate the process of request reply

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
              WHEN COUNT (1) >= 12   THEN 'PASS'
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

  Scenario: TC_3: Triggering Publishing Wrapper Event for CSV file into directory for CDF

    Given I assign "esi_brs_sec_cdf_id" to variable "PUBLISHING_FILE_NAME"
    And I generate value with date format "YYYYMMdd" and assign to variable "VAR_SYSDATE"
    And I assign "/dmp/out/brs/1a_security" to variable "PUBLISHING_DIR"

    And I remove below files in the host "dmp.ssh.inbound" from folder "${PUBLISHING_DIR}" if exists:
      | ${PUBLISHING_FILE_NAME}_${VAR_SYSDATE}_1.csv |

    When I process publishing wrapper with below parameters and wait for the job to be completed
      | PUBLISHING_FILE_NAME | ${PUBLISHING_FILE_NAME}.csv |
      | SUBSCRIPTION_NAME    | EIS_DMP_TO_BRS_CDF_SUB      |

    Then I expect below files to be present in the host "dmp.ssh.inbound" into folder "${PUBLISHING_DIR}" after processing:
      | ${PUBLISHING_FILE_NAME}_${VAR_SYSDATE}_1.csv |

    Then I copy files below from remote folder "${PUBLISHING_DIR}" on host "dmp.ssh.inbound" into local folder "${testdata.path}/outfiles/actual":
      | ${PUBLISHING_FILE_NAME}_${VAR_SYSDATE}_1.csv |

  Scenario: TC_4: Check if published file contains all the records which were loaded for Taiwan Classification data

    Given I assign "EIS_ID_CDF_REFERENCE.csv" to variable "CDF_MASTER_REFERENCE"
    And I assign "${PUBLISHING_FILE_NAME}_${VAR_SYSDATE}_1.csv" to variable "CDF_CURR_FILE"

    When I capture current time stamp into variable "recon.timestamp"
    Then I expect each record in file "${testdata.path}/outfiles/expected/${CDF_MASTER_REFERENCE}" should exist in file "${testdata.path}/outfiles/actual/${CDF_CURR_FILE}" and exceptions to be written to "${testdata.path}/outfiles/actual/exceptions_${recon.timestamp}.csv" file

  Scenario: TC_5: Teardown test data

    Given I execute below query
     """
     ${testdata.path}/sql/teardown_testdata.sql
     """