#https://collaborate.intranet.asia/pages/viewpage.action?spaceKey=FUNDAPPS&title=20.+Multi-Listing+Security+Creation+Process
#https://jira.intranet.asia/browse/TOM-4473 - Dev ticket
#https://jira.intranet.asia/browse/TOM-4794- QA Ticket

@gc_interface_reuters
@dmp_regression_unittest
@dmp_fundapps_regression @tom_4794 @01_multilist_allY
Feature: Test the creation of listing flag for EUR, ASIA and US market group - all flags as Y

  This feature file is to test the creation of listing flag for EUR, ASIA and US market group
  1. When the MIC list received in the file have at least two MIC that belongs to ASIA market grp
  we set Asia flag = Y
  2.When the MIC list received in the file have at least one MIC that belongs to EUR market grp
  we set EUROPE flag = Y
  3. When the MIC list received in the file have at least one MIC that belongs to US market grp
  we set US flag = Y

  Scenario: Assign variables

    Given I assign "tests/test-data/dmp-interfaces/FundApps/Regression/ReutersTermsConditionsSecurity/MultiListing/infiles" to variable "testdata.path"
    And I assign "AllYFlag.csv" to variable "INPUT_FILENAME"
    And I extract below values for row 2 from CSV file "${INPUT_FILENAME}" in local folder "${testdata.path}" with reference to "User Defined Identifier" column and assign to variables:
      | ISIN | ISIN_CODE |
    And  I set end_tms to SYSDATE in database "dmp.db.GC" where iss_id in "'${ISIN_CODE}'"

  Scenario: TC_1: Load the reuters terms and conditions security file with MICList having 2 MICs from each market

    Given I copy files below from local folder "${testdata.path}" to the host "dmp.ssh.inbound" folder "${dmp.ssh.inbound.path}":
      | ${INPUT_FILENAME} |

    When I process files with below parameters and wait for the job to be completed
      | FILE_PATTERN  | ${INPUT_FILENAME}             |
      | MESSAGE_TYPE  | ReutersDSS_TermsandConditions |
      | BUSINESS_FEED |                               |

    Then I extract new job id from jblg table into a variable "JOB_ID"
    And I expect value of column "JBLG_ROW_COUNT" in the below SQL query equals to "1":
    """
	  SELECT count(*) as JBLG_ROW_COUNT FROM FT_T_JBLG WHERE JOB_ID = '${JOB_ID}'
	"""

  Scenario: TC_2: Verify IMKR_RL_TYP updated as 'LISTDMIC'

    Then I expect value of column "IMKR_RL_TYP_COUNT" in the below SQL query equals to "10":
    """
      SELECT COUNT(*) AS IMKR_RL_TYP_COUNT FROM FT_T_IMKR
      WHERE INSTR_ID IN (SELECT INSTR_ID FROM FT_T_ISID WHERE ISS_ID = '${ISIN_CODE}' AND END_TMS IS NULL)
      AND IMKR_RL_TYP='LISTDMIC'
      AND DATA_SRC_ID='REUTERS'
      AND END_TMS IS NULL
    """

  Scenario: TC_3: Verify MKT_ID_CTXT_TYP should be 'MIC' for all MKT_OID

    Then I expect value of column "MKID_COUNT" in the below SQL query equals to "10":
    """
       SELECT COUNT(*) AS MKID_COUNT FROM FT_T_MKID
       WHERE MKT_OID IN
                (SELECT DISTINCT(MKT_OID) FROM FT_T_IMKR WHERE INSTR_ID IN
                     (SELECT INSTR_ID FROM FT_T_ISID WHERE ISS_ID = '${ISIN_CODE}' AND END_TMS IS NULL))
        AND MKT_ID IN ('CHIJ','SBIJ','SBIU','XXXX','XNGS','SMFF','XTAI','BATS','SMBD','HSTC')
        AND MKT_ID_CTXT_TYP='MIC'
        AND END_TMS IS NULL
    """


  Scenario: TC_4: Verifications for listing flag creation
  Listing flag will be created - EURLST=Y, USLST=Y and ASIALST=Y


    Then I expect value of column "ISST_FLAG_COUNT" in the below SQL query equals to "3":
    """
      SELECT COUNT(*) AS ISST_FLAG_COUNT FROM FT_T_ISST
      WHERE STAT_DEF_ID IN('EURLST','USLST','ASIALST')
      AND STAT_CHAR_VAL_TXT = 'Y'
      AND INSTR_ID IN (SELECT INSTR_ID FROM FT_T_ISID WHERE ISS_ID = '${ISIN_CODE}' AND END_TMS IS NULL)
      AND DATA_SRC_ID='REUTERS'
      AND END_TMS IS NULL
    """

  Scenario: Clear the data after tests
    Then I set end_tms to SYSDATE in database "dmp.db.GC" where iss_id in "'${ISIN_CODE}'"
    And I set end_tms to SYSDATE in database "dmp.db.VD" where iss_id in "'${ISIN_CODE}'"