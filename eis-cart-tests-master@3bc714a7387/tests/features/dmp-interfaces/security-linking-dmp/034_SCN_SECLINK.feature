#It covers sec_link_046 as well
#It covers SCN 34 and SCN 35
#AND SCN 36 AND SCN 37
@gc_interface_securities
@dmp_regression_unittest
@dmp_securities_linking @sec_link_034
Feature: SCN34: Security Linking Criteria: Data Management Platform (Golden Source)
  Security update on existing security in DMP through any feed file load from BRS/RDM/BNP

  Background:
    Given I assign "tests/test-data/dmp-interfaces/security-linking-dmp/SCN_SECLINK_034" to variable "testdata.path"

  Scenario: TC_1:Prerequisite Scenario
    Given I assign "SCN_SECLINK__BRS_034.xml" to variable "INPUT_FILENAME"
    Then I extract value from the xml file "${testdata.path}/data-feeds/${INPUT_FILENAME}" with tagName "CUSIP" to variable "ISS_ID"

    Then I set end_tms to SYSDATE in database "dmp.db.GC" where iss_id in "'${ISS_ID}'"
    Then I set end_tms to SYSDATE in database "dmp.db.VD" where iss_id in "'${ISS_ID}'"

  Scenario: TC_2:Verify if CUSIP is stored in DMP from BRS

    Given I assign "SCN_SECLINK__BRS_034.xml" to variable "INPUT_FILENAME"
    Then I extract value from the xml file "${testdata.path}/data-feeds/${INPUT_FILENAME}" with tagName "CUSIP" to variable "BCUSIP"

    When I copy files below from local folder "${testdata.path}/data-feeds" to the host "dmp.ssh.inbound" folder "${dmp.ssh.inbound.path}":
      | ${INPUT_FILENAME} |

    And I process files with below parameters and wait for the job to be completed
      | FILE_PATTERN  | ${INPUT_FILENAME}       |
      | MESSAGE_TYPE  | EIS_MT_BRS_SECURITY_NEW |
      | BUSINESS_FEED |                         |

    Then I extract value from the xml file "${testdata.path}/data-feeds/${INPUT_FILENAME}" with tagName "CUSIP" to variable "BCUSIP"
    And I extract value from the xml file "${testdata.path}/data-feeds/${INPUT_FILENAME}" with tagName "CURRENCY" to variable "CURRENCY"
    And I extract value from the xml file "${testdata.path}/data-feeds/${INPUT_FILENAME}" with xpath "//CUSIP2_set//CODE[text()='B']/../IDENTIFIER" to variable "BRSBBCUSIP"
    And I extract value from the xml file "${testdata.path}/data-feeds/${INPUT_FILENAME}" with xpath "//CUSIP2_set//CODE[text()='C']/../IDENTIFIER" to variable "SEDOL"
    And I extract value from the xml file "${testdata.path}/data-feeds/${INPUT_FILENAME}" with xpath "//CUSIP2_set//CODE[text()='N']/../IDENTIFIER" to variable "CINS"
    And I extract value from the xml file "${testdata.path}/data-feeds/${INPUT_FILENAME}" with xpath "//CUSIP2_set//CODE[text()='R']/../IDENTIFIER" to variable "RTASSET"

    Then I expect value of column "BRS_ISID_BCUSIP_COUNT" in the below SQL query equals to "1":
    """
    SELECT COUNT(*) AS BRS_ISID_BCUSIP_COUNT FROM FT_T_ISID
    WHERE INSTR_ID = (SELECT INSTR_ID FROM FT_T_ISID WHERE ISS_ID = '${ISS_ID}' AND END_TMS IS NULL)
    AND TRUNC(LAST_CHG_TMS) = TRUNC(SYSDATE)
    AND ID_CTXT_TYP='BCUSIP'
    AND LAST_CHG_USR_ID = 'EIS_BRS_DMP_SECURITY'
    AND ISS_ID = '${BCUSIP}'
    """

    Then I expect value of column "BRS_ISID_BRSBBCUSIP_COUNT" in the below SQL query equals to "1":
    """
    SELECT COUNT(*) AS BRS_ISID_BRSBBCUSIP_COUNT FROM FT_T_ISID
    WHERE INSTR_ID = (SELECT INSTR_ID FROM FT_T_ISID WHERE ISS_ID = '${ISS_ID}' AND END_TMS IS NULL)
    AND TRUNC(LAST_CHG_TMS) = TRUNC(SYSDATE)
    AND ID_CTXT_TYP='BRSBBCUSIP'
    AND LAST_CHG_USR_ID = 'EIS_BRS_DMP_SECURITY'
    AND ISS_ID = '${BRSBBCUSIP}'
    """

    Then I expect value of column "BRS_ISID_SEDOL_COUNT" in the below SQL query equals to "1":
    """
    SELECT COUNT(*) AS BRS_ISID_SEDOL_COUNT FROM FT_T_ISID
    WHERE INSTR_ID = (SELECT INSTR_ID FROM FT_T_ISID WHERE ISS_ID = '${ISS_ID}' AND END_TMS IS NULL)
    AND TRUNC(LAST_CHG_TMS) = TRUNC(SYSDATE)
    AND ID_CTXT_TYP='SEDOL'
    AND LAST_CHG_USR_ID = 'EIS_BRS_DMP_SECURITY'
    AND ISS_ID = '${SEDOL}'
    """

    Then I expect value of column "BRS_ISID_CINS_COUNT" in the below SQL query equals to "1":
    """
    SELECT COUNT(*) AS BRS_ISID_CINS_COUNT FROM FT_T_ISID
    WHERE INSTR_ID = (SELECT INSTR_ID FROM FT_T_ISID WHERE ISS_ID = '${ISS_ID}' AND END_TMS IS NULL)
    AND TRUNC(LAST_CHG_TMS) = TRUNC(SYSDATE)
    AND ID_CTXT_TYP='CINS'
    AND LAST_CHG_USR_ID = 'EIS_BRS_DMP_SECURITY'
    AND ISS_ID = '${CINS}'
    """

    Then I expect value of column "BRS_ISID_RTASSET_COUNT" in the below SQL query equals to "1":
    """
    SELECT COUNT(*) AS BRS_ISID_RTASSET_COUNT FROM FT_T_ISID
    WHERE INSTR_ID = (SELECT INSTR_ID FROM FT_T_ISID WHERE ISS_ID = '${ISS_ID}' AND END_TMS IS NULL)
    AND TRUNC(LAST_CHG_TMS) = TRUNC(SYSDATE)
    AND ID_CTXT_TYP='RTASSET'
    AND LAST_CHG_USR_ID = 'EIS_BRS_DMP_SECURITY'
    AND ISS_ID = '${RTASSET}'
    """

  Scenario: TC_3:Verify if TICKER is stored in DMP from BRS

    And I extract value from the xml file "${testdata.path}/data-feeds/${INPUT_FILENAME}" with tagName "TICKER" to variable "TICKER"

    Then I expect value of column "BRS_ISID_TICKER_COUNT" in the below SQL query equals to "1":
    """
    SELECT COUNT(*) AS BRS_ISID_TICKER_COUNT FROM FT_T_ISID
    WHERE INSTR_ID = (SELECT INSTR_ID FROM FT_T_ISID WHERE ISS_ID = '${ISS_ID}' AND END_TMS IS NULL)
    AND TRUNC(LAST_CHG_TMS) = TRUNC(SYSDATE)
    AND ID_CTXT_TYP='TICKER'
    AND LAST_CHG_USR_ID = 'EIS_BRS_DMP_SECURITY'
    AND ISS_ID = '${TICKER}'
    """

  Scenario: TC_4: Verify if Bloomberg FIGI code is stored in DMP from BRS

    And I extract value from the xml file "${testdata.path}/data-feeds/${INPUT_FILENAME}" with xpath "//CUSIP2_set//CODE[text()='9999']/../IDENTIFIER" to variable "BBGID"

    Then I expect value of column "BRS_ISID_BBGID_COUNT" in the below SQL query equals to "1":
    """
    SELECT COUNT(*) AS BRS_ISID_BBGID_COUNT FROM FT_T_ISID
    WHERE INSTR_ID = (SELECT INSTR_ID FROM FT_T_ISID WHERE ISS_ID = '${ISS_ID}' AND END_TMS IS NULL)
    AND TRUNC(LAST_CHG_TMS) = TRUNC(SYSDATE)
    AND ID_CTXT_TYP='BBGLOBAL'
    AND LAST_CHG_USR_ID = 'EIS_BRS_DMP_SECURITY'
    AND ISS_ID = '${BBGID}'
    """

  Scenario: TC_5: Verify tag <CODE>70</CODE> attribute is stored in the ISIN field

    And I extract value from the xml file "${testdata.path}/data-feeds/${INPUT_FILENAME}" with xpath "//CUSIP_ALIAS_set//CODE[text()='70']/../IDENTIFIER" to variable "ISIN"

    Then I expect value of column "BRS_ISID_ISIN_COUNT" in the below SQL query equals to "1":
    """
    SELECT COUNT(*) AS BRS_ISID_ISIN_COUNT FROM FT_T_ISID
    WHERE INSTR_ID = (SELECT INSTR_ID FROM FT_T_ISID WHERE ISS_ID = '${ISS_ID}' AND END_TMS IS NULL)
    AND TRUNC(LAST_CHG_TMS) = TRUNC(SYSDATE)
    AND ID_CTXT_TYP='ISIN'
    AND LAST_CHG_USR_ID = 'EIS_BRS_DMP_SECURITY'
    AND ISS_ID = '${ISIN}'
    """

  Scenario: Clear the data after tests
    Then I set end_tms to SYSDATE in database "dmp.db.VD" where iss_id in "'${ISS_ID}'"
    Then I set end_tms to SYSDATE in database "dmp.db.GC" where iss_id in "'${ISS_ID}'"

