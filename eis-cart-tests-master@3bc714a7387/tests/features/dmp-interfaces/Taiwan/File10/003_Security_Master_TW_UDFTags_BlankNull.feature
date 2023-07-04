#https://jira.intranet.asia/browse/TOM-3682
#https://collaborate.intranet.asia/display/TOMR4/R3.IN-1Y+BRS-%3EDMP+%27Security%27+%3A+Taiwan+fund+security+identifiers

# This is a defect and EISTOMTEST-3898 has been raised for this issue.Included in the feature so that we do not miss this scenario as a part of Taiwan Regression

@gc_interface_securities
@dmp_regression_unittest
@dmp_taiwan
@tom_3682 @file10_taiwan_contexttype @tom_4816
Feature: Test changes to BRS security interface for TW implementation: TW security identifiers <JPMorganFC> and <TWN_MNY_TRPlat> with null value

  This feature will test the blank/null values 2 new UDF tags <JPMorganFC> and <TWN_MNY_TRPlat> (External Fund Code) in file10.
  Expected Result: Security with missing value will not be added to DMP

#  This is a defect and EISTOMTEST-3898 has been raised for this issue.Included in the feature so that we do not miss this scenario as a part of Taiwan Regression
  Scenario: TC1: Load Security Master F10 file with <JPMorganFC> and <TWN_MNY_TRPlat> labels and with Blank value in <Value> tag

    Given I assign "004_Security_Master_TW_Valid_Label_BlankNull_Value.xml" to variable "SECURITY_INPUT_FILENAME"
    And I assign "tests/test-data/dmp-interfaces/Taiwan/File10" to variable "testdata.path"
    And I extract value from the xml file "${testdata.path}/testdata/${SECURITY_INPUT_FILENAME}" with xpath "//UDF_set//LABEL[text()='TWN_MNY_TRPlat']/../VALUE" to variable "TW_MoneyTrust"
    And I extract value from the xml file "${testdata.path}/testdata/${SECURITY_INPUT_FILENAME}" with xpath "//UDF_set//LABEL[text()='JPMorganFC']/../VALUE" to variable "TW_JP_Code"

    # End date existing ISIDs to ensure new security created
    And I set end_tms to SYSDATE in database "dmp.db.GC" where iss_id in "'TWTOM3682'"

    When I copy files below from local folder "${testdata.path}/testdata" to the host "dmp.ssh.inbound" folder "${dmp.ssh.inbound.path}":
      | ${SECURITY_INPUT_FILENAME} |

    And I process files with below parameters and wait for the job to be completed
      | BUSINESS_FEED |                            |
      | FILE_PATTERN  | ${SECURITY_INPUT_FILENAME} |
      | MESSAGE_TYPE  | EIS_MT_BRS_SECURITY_NEW    |

    Then I extract new job id from jblg table into a variable "JOB_ID"

    And I expect value of column "JBLG_ROW_COUNT" in the below SQL query equals to "1":
    """
    SELECT count(*) as JBLG_ROW_COUNT FROM FT_T_JBLG WHERE JOB_ID = '${JOB_ID}'
    """

    And I expect value of column "NTEL_VALID_COUNT" in the below SQL query equals to "0":
      """
        SELECT COUNT(*) AS NTEL_VALID_COUNT FROM FT_T_NTEL
        WHERE NOTFCN_STAT_TYP = 'OPEN'
        AND NOTFCN_ID = 153
        AND MSG_SEVERITY_CDE = 50
        AND LAST_CHG_TRN_ID IN (SELECT TRN_ID FROM FT_T_TRID WHERE JOB_ID = '${JOB_ID}')
        AND PARM_VAL_TXT LIKE '%Table Initial Occurence: 45 Could not get ISS_ID from table object%'
      """


    And I expect value of column "ISID_ROW_COUNT" in the below SQL query equals to "1":
    """
      SELECT Count(*) ISID_ROW_COUNT FROM ft_t_isid WHERE id_ctxt_typ = 'BCUSIP'
      AND iss_id = 'TWTOM3682' AND end_tms IS NULL
    """

    And I expect value of column "NO_OF_ACTIVE_MONEY_TRUST_ID" in the below SQL query equals to "0":
    """
      SELECT COUNT(1) NO_OF_ACTIVE_MONEY_TRUST_ID FROM ft_t_isid
      WHERE end_tms IS NULL
      AND id_ctxt_typ = 'TWMNYTRST'
      AND instr_id IN
      (
      SELECT instr_id FROM ft_t_isid
      WHERE id_ctxt_typ = 'BCUSIP'
      AND iss_id = 'TWTOM3682'
      AND end_tms IS NULL
      )
    """

    And I expect value of column "NO_OF_ACTIVE_JPM_FUND_CODE" in the below SQL query equals to "0":
    """
    SELECT COUNT(1) NO_OF_ACTIVE_JPM_FUND_CODE FROM ft_t_isid
    WHERE end_tms IS NULL
    AND id_ctxt_typ = 'TWJPMFNDCDE'
    AND instr_id IN
    (
      SELECT instr_id FROM ft_t_isid
      WHERE id_ctxt_typ = 'BCUSIP'
      AND iss_id = 'TWTOM3682'
      AND end_tms IS NULL
    )
    """

##  This is a defect and EISTOMTEST-3899 has been raised for this issue.Included in the feature so that we do not miss this scenario as a part of Taiwan Regression
#  Scenario: TC2:  Load Security Master F10 file with valid value in <Value> tag and it contains more than 100 chars
#    Given I assign "006_Security_Master_TW_Valid_Label_LengthofValue_Morethan100Chars.xml" to variable "SECURITY_INPUT_FILENAME"
#    And I assign "tests/test-data/dmp-interfaces/Taiwan/File10" to variable "testdata.path"
#    And I extract value from the xml file "${testdata.path}/testdata/${SECURITY_INPUT_FILENAME}" with xpath "//UDF_set//LABEL[text()='TWN_MNY_TRPlat']/../VALUE" to variable "TW_MoneyTrust"
#    And I extract value from the xml file "${testdata.path}/testdata/${SECURITY_INPUT_FILENAME}" with xpath "//UDF_set//LABEL[text()='JPMorganFC']/../VALUE" to variable "TW_JP_Code1"
#
#     # End date existing ISIDs to ensure new security created
#    And I set end_tms to SYSDATE in database "dmp.db.GC" where iss_id in "'TWTOM3682'"
#
#    When I copy files below from local folder "${testdata.path}/testdata" to the host "dmp.ssh.inbound" folder "${dmp.ssh.inbound.path}":
#      | ${SECURITY_INPUT_FILENAME} |
#
#    And I process files with below parameters and wait for the job to be completed
#      | BUSINESS_FEED |                            |
#      | FILE_PATTERN  | ${SECURITY_INPUT_FILENAME} |
#      | MESSAGE_TYPE  | EIS_MT_BRS_SECURITY_NEW    |
#
#    Then I extract new job id from jblg table into a variable "JOB_ID"
#
#    And I expect value of column "JBLG_ROW_COUNT" in the below SQL query equals to "1":
#    """
#    SELECT count(*) as JBLG_ROW_COUNT FROM FT_T_JBLG WHERE JOB_ID = '${JOB_ID}'
#    """
#
#    And I expect value of column "NO_OF_ACTIVE_MONEY_TRUST_ID" in the below SQL query equals to "0":
#    """
#    SELECT Count(*) NO_OF_ACTIVE_MONEY_TRUST_ID FROM ft_t_isid WHERE iss_id = '${TW_MoneyTrust}' AND end_tms IS NULL
#    """
#
#    And I expect value of column "ISID_ROW_COUNT" in the below SQL query equals to "1":
#    """
#    SELECT Count(*) ISID_ROW_COUNT FROM ft_t_isid WHERE id_ctxt_typ = 'BCUSIP' AND iss_id = 'TWTOM3682' AND end_tms IS NULL
#    """