#https://jira.intranet.asia/browse/TOM-3682
#https://collaborate.intranet.asia/display/TOMR4/R3.IN-1Y+BRS-%3EDMP+%27Security%27+%3A+Taiwan+fund+security+identifiers

@gc_interface_securities
@dmp_regression_unittest
@dmp_taiwan
@tom_3682 @file10_taiwan_contexttype
Feature: Test changes to BRS security interface for TW implementation: TW security identifiers lable <AMT_OUT_ISSUER> and <ESI_MY_UPC>

  This feature will test the 2 new UDF tags <AMT_OUT_ISSUER> and <ESI_MY_UPC> (External Fund Code) in file10.
  We need to make sure that <AMT_OUT_ISSUER> context type is not created and <ESI_MY_UPC> is created in DMP.
  Also, make sure that if same security is loaded again with different values against <AMT_OUT_ISSUER> and <ESI_MY_UPC> context type then it should not
  create another record in ISID table rather update the existing one.

  Scenario: TC1: Load Security Master F10 file with <AMT_OUT_ISSUER> and <ESI_MY_UPC> labels and with valid value in <Value> tag

    Given I assign "003_Security_Master_TW_UDFTagsOtherThanTaiwan_ValidValue.xml" to variable "SECURITY_INPUT_FILENAME"
    And I assign "tests/test-data/dmp-interfaces/Taiwan/File10" to variable "testdata.path"
    And I extract value from the xml file "${testdata.path}/testdata/${SECURITY_INPUT_FILENAME}" with xpath "//UDF_set//LABEL[text()='AMT_OUT_ISSUER']/../VALUE" to variable "AMT_ISSUER"
    And I extract value from the xml file "${testdata.path}/testdata/${SECURITY_INPUT_FILENAME}" with xpath "//UDF_set//LABEL[text()='ESI_MY_UPC']/../VALUE" to variable "MY_UPC"

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

    And I expect value of column "MY_UPC_CODE" in the below SQL query equals to "${MY_UPC}":
    """
    SELECT STAT_CHAR_VAL_TXT AS MY_UPC_CODE FROM ft_t_isst
    WHERE end_tms IS NULL
    AND STAT_DEF_ID = 'BRSSUBMY'
    AND instr_id IN
    (
      SELECT instr_id FROM ft_t_isid
      WHERE id_ctxt_typ = 'BCUSIP'
      AND iss_id = 'TWTOM3682'
      AND end_tms IS NULL
    )
    """

    Then I expect value of column "NO_OF_AMT_ISSUER_ID" in the below SQL query equals to "0":
    """
    SELECT Count(*) as NO_OF_AMT_ISSUER_ID FROM ft_t_isid WHERE iss_id = '${AMT_ISSUER}' AND end_tms IS NULL
    """

  Scenario: TC2:  Load Security Master F10 file with blank lable and with valid value in <Value> tag

    Given I assign "005_Security_Master_TW_BlankNull_Label_Valid_Value.xml" to variable "SECURITY_INPUT_FILENAME"
    And I assign "tests/test-data/dmp-interfaces/Taiwan/File10" to variable "testdata.path"
    And I extract value from the xml file "${testdata.path}/testdata/${SECURITY_INPUT_FILENAME}" with xpath "//UDF_set//LABEL[text()='']/../VALUE" to variable "TW_MoneyTrust"

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

    And I expect value of column "NO_OF_ACTIVE_MONEY_TRUST_ID" in the below SQL query equals to "0":
    """
    SELECT Count(*) NO_OF_ACTIVE_MONEY_TRUST_ID FROM ft_t_isid WHERE iss_id = '${TW_MoneyTrust}' AND end_tms IS NULL
    """

    And I expect value of column "ISID_ROW_COUNT" in the below SQL query equals to "1":
    """
    SELECT Count(*) ISID_ROW_COUNT FROM ft_t_isid WHERE id_ctxt_typ = 'BCUSIP' AND iss_id = 'TWTOM3682' AND end_tms IS NULL
    """
