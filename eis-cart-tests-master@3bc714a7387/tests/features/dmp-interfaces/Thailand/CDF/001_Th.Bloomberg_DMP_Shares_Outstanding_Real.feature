#https://jira.pruconnect.net/browse/EISDEV-6630
#https://collaborate.pruconnect.net/pages/viewpage.action?spaceKey=EISTT&title=Shares+Outstanding%7CBberg%7COn+Demand+Request%7CPublish+CDF+to+BRS

#https://jira.pruconnect.net/browse/EISDEV-6881
#Fund_total_assets should be multiplied by 1000000 before sending to BRS in the CDF file
# EISDEV-7037: Wrapper class created for BB request and replay

@dmp_regression_integrationtest @eisdev_7037
@eisdev_6630 @001_cdf_6630 @001_th_bloomberg_cdf @bbpersecurity @dmp_thailand_cdf @dmp_thailand @dmp_interfaces @eisdev_6881
@gc_interface_portfolios @gc_interface_positions @gc_interface_cdf @gc_interface_request_reply
@dmp_regression_integrationtest

Feature: Request reply feature to get Current Shares Outstanding Real Value from Bloomberg

  This testcase validate the BB Request and Reply.

  Below Steps are followed to validate this testing

  1. Load Portgroup file to create account participant for D22 & 217
  2. Load positions for one TMBAM(D22) & TFUND(217) using the "EIS_MT_BRS_EOD_POSITION_NON_LATAM" Messagetype
  3. Generate the request file it should contains newly loaded positions
  4. Mock up response file for corresponding loaded position and copy to dmp.ssh.outbound.path with current date and time
  5. Publish CDF file and perform recon

  Scenario:TC1: Initialize all the variables

    Given I assign "tests/test-data/dmp-interfaces/Thailand/CDF" to variable "testdata.path"

    #Portgroup
    And I assign "001_Th.Bloomberg_DMP_Shares_Outstanding_Real_port_group.xml" to variable "INPUT_PORTGROUP"

    #Position
    And I assign "001_Th.Bloomberg_DMP_Shares_Outstanding_Real_position_template.xml" to variable "INPUT_POSITION_TEMPLATENAME"
    And I assign "001_Th.Bloomberg_DMP_Shares_Outstanding_Real_position.xml" to variable "INPUT_POSITION_FILENAME"

    #Publishing
    And I assign "esi_brs_sec_cdf_th" to variable "PUBLISHING_FILE_NAME"
    And I assign "/dmp/out/brs/1a_security" to variable "PUBLISHING_DIR"
    And I generate value with date format "YYYYMMdd" and assign to variable "VAR_SYSDATE"
    And I assign "001_Th.Bloomberg_DMP_Shares_Outstanding_Real_CDF_out_template.csv" to variable "CDF_MASTER_REFERENCE"
    And I assign "${PUBLISHING_FILE_NAME}_${VAR_SYSDATE}_1.csv" to variable "CDF_CURR_FILE"


  Scenario:TC2: Load Port group file to create participant for D22 & 217

    Given I process "${testdata.path}/testdata/${INPUT_PORTGROUP}" file with below parameters
      | BUSINESS_FEED |                            |
      | FILE_PATTERN  | ${INPUT_PORTGROUP}         |
      | MESSAGE_TYPE  | EIS_MT_BRS_PORTFOLIO_GROUP |

    Then I expect workflow is processed in DMP with total record count as "2"

  Scenario: TC_3: Create Position file with POS_DATE as SYSDATE and Load into DMP

    Given I create input file "${INPUT_POSITION_FILENAME}" using template "${INPUT_POSITION_TEMPLATENAME}" with below codes from location "${testdata.path}"
      | POS_DATE | DateTimeFormat:M/dd/YYYY |

    # Ensure there are no future dated positions (created by other feature files, so rows should be small in number)
    And I execute below query to "clear future dated positions"
     """
     ${testdata.path}/sql/clean_future_dated_balh.sql
     """

    When I process "${testdata.path}/testdata/${INPUT_POSITION_FILENAME}" file with below parameters
      | FILE_PATTERN  | ${INPUT_POSITION_FILENAME}        |
      | MESSAGE_TYPE  | EIS_MT_BRS_EOD_POSITION_NON_LATAM |
      | BUSINESS_FEED |                                   |

    Then I expect workflow is processed in DMP with total record count as "4"

    #This check to verify BALH table MAX(AS_OF_TMS) rowcount with PositionFileLoad.xml file rowcount
    Then I expect value of column "BALH_COUNT" in the below SQL query equals to "4":
     """
     ${testdata.path}/sql/check_positions_loaded.sql
     """

  Scenario: TC_4: Check the BB Request Reply for EIS_Secmaster

    Given I assign "${dmp.ssh.inbound.path}/bloomberg" to variable "BB_DOWNLOAD_DIR"
    And I assign "${dmp.ssh.outbound.path}/bloomberg" to variable "BB_UPLOAD_DIR"
    And I assign "gs_secmaster_response_template.out" to variable "RESPONSE_TEMPLATENAME"

    #This step is to clear ISMC
    And I execute below query to "clear ISMC"
	"""
	DELETE FROM FT_T_ISMC WHERE INSTR_ID IN (SELECT INSTR_ID FROM FT_T_ISID WHERE ISS_ID IN ('BES38VQ40','BRSRX5LK6','SB3R77J28','BRSRWYNW6') AND END_TMS IS NULL)
	AND CAPITAL_TYP = 'OUTSTAND' AND END_TMS IS NULL
	"""

    # Clear VREQ
    And I execute below query to "clear VREQ for re-runs"
	"""
	UPDATE FT_T_VREQ SET VND_RQST_TYP = 'Dummy' WHERE TRUNC (VND_RQST_TMS) = TRUNC (SYSDATE) AND   VND_RQST_TYP = 'EIS_Secmaster' AND
	VND_RQST_XREF_ID_CTXT_TYP = 'ISIN' AND VND_RQST_XREF_ID IN ('LU0326391785', 'TH1060010002', 'LU0229866941', 'TH0347010017')
	"""

    # We are copying the response file on server because request reply workflow will generate request file and expect response file with same date.
    # Since, we are not connecting to BBG for testing this is to simulate the process of request reply

    Given Setup BB request reply prerequisites with following details
      | VND_RQST_TYP            | EIS_Secmaster                                        |
      | RESPONSE_TEMPLATE_PATH  | tests/test-data/dmp-interfaces/Thailand/CDF/template |
      | RESPONSE_TEMPLATE_FILES | ${RESPONSE_TEMPLATENAME}                             |
      | BB_PATH                 | ${BB_DOWNLOAD_DIR}                                   |

    Given I process BBPerSecurity workflow with below parameters and wait for the job to be completed
      | BB_DOWNLOAD_DIR | ${BB_DOWNLOAD_DIR} |
      | BB_UPLOAD_DIR   | ${BB_UPLOAD_DIR}   |
      | FIRM_NAME       | dl790188           |
      | REQUEST_TYPE    | EIS_Secmaster      |
      | SN              | 191305             |
      | USER_NUMBER     | 3650834            |
      | WORK_STATION    | 0                  |

     #This check to verify if 4 securities which satisfied condition for EISSecmaster were requested and response was loaded.
    Then I expect value of column "VREQ_STATUS_CHECK" in the below SQL query equals to "PASS":
     """
      SELECT
          CASE
              WHEN COUNT (1) = 4   THEN 'PASS'
              ELSE 'FAIL'
          END
      AS VREQ_STATUS_CHECK
      FROM FT_T_VREQ
      WHERE TRUNC (VND_RQST_TMS) = TRUNC (SYSDATE) AND   VND_RQST_TYP = 'EIS_Secmaster' AND   VND_RQST_XREF_ID_CTXT_TYP = 'ISIN' AND   VND_RQST_XREF_ID IN (
         'LU0326391785', 'TH1060010002', 'LU0229866941', 'TH0347010017'
      ) AND   (
          VND_RQST_STAT_TYP = 'CLOSED' OR    (
              VND_RQST_STAT_TYP = 'FAILED' AND VND_RQST_STAT_TXT = 'Processing messages in the engine failed.'
          )
      )
     """

    #This check to verify if ISMC requested and response was loaded.
    Then I expect value of column "ISMC_CHECK" in the below SQL query equals to "PASS":
     """
      SELECT
	CASE
		WHEN COUNT (1) = 2 THEN 'PASS'
		ELSE 'FAIL'
	END
      AS ISMC_CHECK
      FROM FT_T_ISMC
      WHERE INSTR_ID IN ( SELECT INSTR_ID
                    FROM FT_T_ISID
                    WHERE ISS_ID IN ('LU0326391785', 'TH1060010002', 'LU0229866941', 'TH0347010017'
        ) AND   END_TMS IS NULL
        ) AND   CAPITAL_TYP = 'FUNDTOT' AND END_TMS IS NULL
      """

  Scenario: TC_5: Triggering Publishing Wrapper Event for CSV file into directory for CDF

    Given I remove below files in the host "dmp.ssh.inbound" from folder "${PUBLISHING_DIR}" if exists:
      | ${PUBLISHING_FILE_NAME}*.csv |

    When I process publishing wrapper with below parameters and wait for the job to be completed
      | PUBLISHING_FILE_NAME | ${PUBLISHING_FILE_NAME}.csv |
      | SUBSCRIPTION_NAME    | EIS_DMP_TO_BRS_CDF_SUB      |

    Then I expect below files to be present in the host "dmp.ssh.inbound" into folder "${PUBLISHING_DIR}" after processing:
      | ${PUBLISHING_FILE_NAME}_${VAR_SYSDATE}_1.csv |

    Then I copy files below from remote folder "${PUBLISHING_DIR}" on host "dmp.ssh.inbound" into local folder "${testdata.path}/outfiles/actual":
      | ${PUBLISHING_FILE_NAME}_${VAR_SYSDATE}_1.csv |

  Scenario: TC_4: Check if published file contains all the records which were loaded for Shares outstanding

    Then I expect all records from file1 of type CSV exists in file2
      | File1 | ${testdata.path}/outfiles/expected/${CDF_MASTER_REFERENCE} |
      | File2 | ${testdata.path}/outfiles/actual/${CDF_CURR_FILE}          |
