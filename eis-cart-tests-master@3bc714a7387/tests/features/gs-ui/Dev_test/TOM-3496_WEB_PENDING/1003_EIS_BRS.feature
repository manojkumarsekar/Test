#https://jira.intranet.asia/browse/TOM-2539
#https://jira.intranet.asia/browse/TOM-3496

@dmp_regression_unittest
@tom_3496 @dmp_securities_linking @1003_eis_brs_data_load
Feature: Loading BRS data to test BBLOANID, BB, LOANXID populate and NO_DATA

  This fix is for the error occurred in production.

  If ID_CTXT_TYP = ‘LOANXID’ and ISS_ID starts with LX then update ID_CTXT_TYP to ‘MRKTLOANID’
  If ID_CTXT_TYP = ‘LOANXID’ and ISS_ID starts with BL then update ID_CTXT_TYP to ‘BBLOANID’

  Scenario: TC_1: Test data preparation

    Given I assign "tests/test-data/DevTest/TOM-3496" to variable "testdata.path"
    And I assign "BRS_TC_04_BBLOAIND.xml" to variable "INPUT_FILENAME1"
    And I assign "BRS_TC_05_BB.xml" to variable "INPUT_FILENAME2"
    And I assign "BRS_TC_06_LOANXID.xml" to variable "INPUT_FILENAME3"
    And I assign "BRS_TC_07_NoDataLoad.xml" to variable "INPUT_FILENAME4"

    When I extract value from the xml file "${testdata.path}/${INPUT_FILENAME1}" with xpath "//CUSIP2_set//CODE[text()='B']/../IDENTIFIER" to variable "BBLOANID"
    And I extract value from the xml file "${testdata.path}/${INPUT_FILENAME2}" with xpath "//CUSIP2_set//CODE[text()='B']/../IDENTIFIER" to variable "BB"
    And I extract value from the xml file "${testdata.path}/${INPUT_FILENAME3}" with xpath "//CUSIP2_set//CODE[text()='8']/../IDENTIFIER" at index 0 to variable "LOANXID_1"
    And I extract value from the xml file "${testdata.path}/${INPUT_FILENAME3}" with xpath "//CUSIP2_set//CODE[text()='8']/../IDENTIFIER" at index 1 to variable "NO_DATA"
    And I extract value from the xml file "${testdata.path}/${INPUT_FILENAME4}" with xpath "//CUSIP2_set//CODE[text()='8']/../IDENTIFIER" at index 0 to variable "NO_DATA_1"
    And I extract value from the xml file "${testdata.path}/${INPUT_FILENAME4}" with xpath "//CUSIP2_set//CODE[text()='8']/../IDENTIFIER" at index 1 to variable "LOANXID_2"
    And I extract value from the xml file "${testdata.path}/${INPUT_FILENAME4}" with xpath "//CUSIP2_set//CODE[text()='8']/../IDENTIFIER" at index 2 to variable "NO_DATA_2"

    Then I set end_tms to SYSDATE in database "dmp.db.VD" where iss_id in "'${BBLOANID}','${BB}','${LOANXID_1}','${NO_DATA_1}','${NO_DATA_2}','${LOANXID_2}'"
    Then I set end_tms to SYSDATE in database "dmp.db.GC" where iss_id in "'${BBLOANID}','${BB}','${LOANXID_1}','${NO_DATA_1}','${NO_DATA_2}','${LOANXID_2}'"

    When I copy files below from local folder "${testdata.path}" to the host "dmp.ssh.inbound" folder "${dmp.ssh.inbound.path}":
      | ${INPUT_FILENAME1} |
      | ${INPUT_FILENAME2} |
      | ${INPUT_FILENAME3} |
      | ${INPUT_FILENAME4} |

  Scenario: TC_2: Load BRS Files

    Given I process files with below parameters and wait for the job to be completed
      | BUSINESS_FEED |                         |
      | FILE_PATTERN  | BRS_TC*.xml             |
      | MESSAGE_TYPE  | EIS_MT_BRS_SECURITY_NEW |

  Scenario: TC_3: Test for BBLOANID field

    Then I expect value of column "ID_COUNT_BB" in the below SQL query equals to "1":
      """
      SELECT COUNT(*) AS ID_COUNT_BB FROM FT_T_ISID
	  WHERE ISS_ID ='${BBLOANID}'
	  AND ID_CTXT_TYP ='BBLOANID'
	  AND END_TMS IS NULL
      """

  Scenario: TC_4: Test for BB field

    Then I expect value of column "ID_COUNT_BB" in the below SQL query equals to "1":
      """
      SELECT COUNT(*) AS ID_COUNT_BB FROM FT_T_ISID
	  WHERE ISS_ID ='${BB}'
	  AND ID_CTXT_TYP ='BB'
	  AND END_TMS IS NULL
      """

  Scenario: TC_5: Test for LOANXID and NO_DATA

    Then I expect value of column "ID_COUNT_BB" in the below SQL query equals to "1":
      """
      SELECT COUNT(*) AS ID_COUNT_BB FROM FT_T_ISID
	  WHERE ISS_ID ='${LOANXID_1}'
	  AND ID_CTXT_TYP ='LOANXID'
	  AND END_TMS IS NULL
      """

    Then I expect value of column "ID_COUNT_BB" in the below SQL query equals to "0":
      """
      SELECT COUNT(*) AS ID_COUNT_BB FROM FT_T_ISID
	  WHERE ISS_ID ='${NO_DATA}'
	  AND ID_CTXT_TYP ='NO_DATA'
	  AND END_TMS IS NULL
      """

  Scenario: TC_6: Load files for BRS data to test data should not be setup for BB,BBLOANID

    Then I expect value of column "ID_COUNT_BB" in the below SQL query equals to "1":
      """
      SELECT COUNT(*) AS ID_COUNT_BB FROM FT_T_ISID
	  WHERE ISS_ID IN('${LOANXID_2}')
	  AND ID_CTXT_TYP IN ('BB','BBLOANID','LOANXID')
	  AND END_TMS IS NULL
      """

    Then I expect value of column "ID_COUNT_BB" in the below SQL query equals to "0":
      """
      SELECT COUNT(*) AS ID_COUNT_BB FROM FT_T_ISID
	  WHERE ISS_ID ='${NO_DATA}'
	  AND ID_CTXT_TYP IN ('BB','BBLOANID','LOANXID_2')
	  AND END_TMS IS NULL
      """