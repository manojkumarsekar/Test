#https://jira.intranet.asia/browse/TOM-3682
#https://collaborate.intranet.asia/display/TOMR4/R3.IN-1Y+BRS-%3EDMP+%27Security%27+%3A+Taiwan+fund+security+identifiers

@gc_interface_securities
@dmp_regression_unittest
@dmp_taiwan
@tom_3682 @file10_taiwan_contexttype
Feature: Test changes to BRS security interface for TW implementation: TW security identifiers <JPMorganFC> and <TWN_MNY_TRPlat>

  This feature will test the 2 new UDF tags <JPMorganFC> and <TWN_MNY_TRPlat> (External Fund Code) in file10 is mapped properly in DMP without any issue.
  Also, make sure that if same security is loaded again with different values against <JPMorganFC> and <TWN_MNY_TRPlat> context type then it should not
  create another record in ISID table rather update the existing one.

  Scenario: TC1: Load Security Master F10 file with <JPMorganFC> and <TWN_MNY_TRPlat> labels and with valid value in <Value> tag

    Given I assign "001_Security_Master_TW_Valid_Label_Valid_Value.xml" to variable "SECURITY_INPUT_FILENAME"
    And I assign "tests/test-data/dmp-interfaces/Taiwan/File10" to variable "testdata.path"
    And I extract value from the xml file "${testdata.path}/testdata/${SECURITY_INPUT_FILENAME}" with xpath "//UDF_set//LABEL[text()='TWN_MNY_TRPlat']/../VALUE" to variable "TW_MoneyTrust"
    And I extract value from the xml file "${testdata.path}/testdata/${SECURITY_INPUT_FILENAME}" with xpath "//UDF_set//LABEL[text()='JPMorganFC']/../VALUE" to variable "TW_JP_Code"

    # End date existing ISIDs to ensure new security created
    And I set end_tms to SYSDATE in database "dmp.db.GC" where iss_id in "'TWTOM3682'"

    When I copy files below from local folder "${testdata.path}/testdata" to the host "dmp.ssh.inbound" folder "${dmp.ssh.inbound.path}":
      | ${SECURITY_INPUT_FILENAME} |

    Given I process files with below parameters and wait for the job to be completed
      | BUSINESS_FEED |                            |
      | FILE_PATTERN  | ${SECURITY_INPUT_FILENAME} |
      | MESSAGE_TYPE  | EIS_MT_BRS_SECURITY_NEW    |

    Then I extract new job id from jblg table into a variable "JOB_ID"

    And I expect value of column "JBLG_ROW_COUNT" in the below SQL query equals to "1":
    """
    SELECT count(*) as JBLG_ROW_COUNT FROM FT_T_JBLG WHERE JOB_ID = '${JOB_ID}'
    """

    And I expect value of column "MONEY_TRUST_ID" in the below SQL query equals to "${TW_MoneyTrust}":
    """
    SELECT iss_id AS MONEY_TRUST_ID FROM ft_t_isid
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

    And I expect value of column "JPM_FUND_CODE" in the below SQL query equals to "${TW_JP_Code}":
    """
    SELECT iss_id AS JPM_FUND_CODE FROM   ft_t_isid
    WHERE  end_tms IS NULL
    AND id_ctxt_typ = 'TWJPMFNDCDE'
    AND instr_id IN
    (
      SELECT instr_id FROM ft_t_isid
      WHERE id_ctxt_typ = 'BCUSIP'
      AND iss_id = 'TWTOM3682'
      AND end_tms IS NULL
    )
    """

  Scenario: TC2: Load new security F10 file with modified identifiers <Value> tag to ensure old identifiers updated

    Given I assign "002_Security_Master_TW_Valid_Label_Valid_Value_Check_DuplicateRecord.xml" to variable "SECURITY_INPUT_FILENAME"
    And I assign "tests/test-data/dmp-interfaces/Taiwan/File10" to variable "testdata.path"
    And I extract value from the xml file "${testdata.path}/testdata/${SECURITY_INPUT_FILENAME}" with xpath "//UDF_set//LABEL[text()='TWN_MNY_TRPlat']/../VALUE" to variable "TW_MoneyTrust1"
    And I extract value from the xml file "${testdata.path}/testdata/${SECURITY_INPUT_FILENAME}" with xpath "//UDF_set//LABEL[text()='JPMorganFC']/../VALUE" to variable "TW_JP_Code1"

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

    And I expect value of column "MONEY_TRUST_ID" in the below SQL query equals to "${TW_MoneyTrust1}":
    """
    SELECT iss_id AS MONEY_TRUST_ID FROM ft_t_isid
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

    And I expect value of column "NO_OF_ACTIVE_MONEY_TRUST_ID" in the below SQL query equals to "1":
    """
    SELECT COUNT(1) NO_OF_ACTIVE_MONEY_TRUST_ID FROM   ft_t_isid
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

    And I expect value of column "JPM_FUND_CODE" in the below SQL query equals to "${TW_JP_Code1}":
    """
    SELECT iss_id AS JPM_FUND_CODE FROM   ft_t_isid
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

    And I expect value of column "NO_OF_ACTIVE_JPM_FUND_CODE" in the below SQL query equals to "1":
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

