#https://jira.intranet.asia/browse/TOM-3470 - Inital ticket - development for Maaf CC, ISO done in this ticket
#https://jira.intranet.asia/browse/TOM-3498 - Changes CC option - As per jira description changed the setting

@gc_interface_market_feeds
@dmp_regression_unittest
@tom_3498 @load_maaf_iso
Feature: Load the Market as Feed - ISO

  This testcase validate the Market as Feed - ISO

  Below Steps are followed to validate this testing

  1. Load the Market as Feed - ISO file using the "MarketFeeds_ISO" Messagetype
  2. Validate the Create Market
  3. Validate the Delete Market where rows already available in the FT_T_MKID
  4. Validate the Delete Market where rows not available in the FT_T_MKID

  Scenario: TC_1: Load the Market as Feed - ISO File

    Given I assign "MAAF_ISO.txt" to variable "INPUT_FILENAME"
    And I assign "tests/test-data/DevTest/TOM-3498" to variable "testdata.path"
    And I assign "3579" to variable "CREATE_MARKET_VALUE"

    And I execute below query to "delete the rows if already exists for validate the create market"
	"""
	DELETE FROM FT_T_MKID WHERE MKT_ID = '${CREATE_MARKET_VALUE}'
	"""

    When I copy files below from local folder "${testdata.path}/testdata" to the host "dmp.ssh.inbound" folder "${dmp.ssh.inbound.path}":
      | ${INPUT_FILENAME} |

    When I process files with below parameters and wait for the job to be completed
      | BUSINESS_FEED |                   |
      | FILE_PATTERN  | ${INPUT_FILENAME} |
      | MESSAGE_TYPE  | MarketFeeds_ISO   |

    #Get the jobid for validate the joblog
    Then I extract new job id from jblg table into a variable "JOB_ID"

   # Validate the Create Market
    Then I expect value of column "MKID_CREATE_ROWCOUNT" in the below SQL query equals to "1":
     """
     SELECT CASE WHEN COUNT (0) >= 1 THEN 1 ELSE 0 END AS MKID_CREATE_ROWCOUNT FROM FT_T_MKID WHERE MKT_ID = '${CREATE_MARKET_VALUE}' AND END_TMS IS NULL
     """

    # Validate the Delete Market ='NO' CC option - where rows already available in the FT_T_MKID - It should not delete any rows
    Then I expect value of column "MKID_DELETE_COUNT" in the below SQL query equals to "1":
     """
     SELECT CASE WHEN COUNT(0) >= 1 THEN 1	ELSE 0 END AS MKID_DELETE_COUNT FROM FT_T_MKID WHERE MKT_ID = 'AIXE' AND END_TMS IS NULL
     """

    # Validate the Delete Market ='NO' CC option - where rows not available in the FT_T_MKID - It should return 0 rows
    Then I expect value of column "MKID_DELETE_COUNT" in the below SQL query equals to "0":
     """
     SELECT COUNT (0) AS MKID_DELETE_COUNT FROM FT_T_MKID WHERE MKT_ID = 'CHIY'
     """

    # Validate the job log should not have any failed count
    Then I expect value of column "ERROR_COUNT" in the below SQL query equals to "0":
    """
    SELECT COUNT (*) AS ERROR_COUNT
    FROM FT_T_JBLG JBLG
    INNER JOIN FT_T_TRID TRID ON JBLG.JOB_ID = TRID.JOB_ID
    INNER JOIN FT_T_NTEL NTEL ON TRID.TRN_ID = NTEL.LAST_CHG_TRN_ID
    WHERE JBLG.JOB_ID = '${JOB_ID}' AND   CRRNT_TRN_STAT_TYP = 'OPEN'
    """


