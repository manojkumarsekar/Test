#https://jira.intranet.asia/browse/TOM-2539
#https://jira.intranet.asia/browse/TOM-3496

@dmp_regression_unittest
@tom_3496 @dmp_securities_linking @1005_eis_vsh_data_load
Feature: Loading BRS data to test BB,BBLOANID and LOANXID populate for VSH

  This fix is for the error occurred in production.

  If ID_CTXT_TYP = 'LOANXID' and ISS_ID starts with LX then update ID_CTXT_TYP to ‘MRKTLOANID’
  If ID_CTXT_TYP = 'LOANXID' and ISS_ID starts with BL then update ID_CTXT_TYP to ‘BBLOANID’

  Scenario: TC_1: Test data preparation

    Given I assign "VSH_Test_BBG.csv" to variable "INPUT_FILENAME_BB"
    And I assign "VSH_BRS.xml" to variable "INPUT_FILENAME_BRS"
    And I assign "tests/test-data/DevTest/TOM-3496" to variable "testdata.path"

    Given I extract below values for row 1 from BBGPSV file "${INPUT_FILENAME_BB}" in local folder "${testdata.path}" and assign to variables:
      | ID_BB | BBLOANID_BB |

    And I extract value from the xml file "${testdata.path}/${INPUT_FILENAME_BRS}" with xpath "//CUSIP2_set//CODE[text()='B']/../IDENTIFIER" to variable "BBLOANID_BRS"

    And I set the database connection to configuration "dmp.db.VD"
    Then I execute below query
	"""
	delete FT_T_ISID WHERE ISS_ID IN('${BBLOANID_BB}','${BBLOANID_BRS}') AND ID_CTXT_TYP ='BBLOANID';
	"""

    And I set the database connection to configuration "dmp.db.GC"
    Then I execute below query
	"""	
	delete FT_T_ISID WHERE ISS_ID IN('${BBLOANID_BB}','${BBLOANID_BRS}') AND ID_CTXT_TYP ='BBLOANID'
	"""

    When I copy files below from local folder "${testdata.path}" to the host "dmp.ssh.inbound" folder "${dmp.ssh.inbound.path}":
      | ${INPUT_FILENAME_BB}  |
      | ${INPUT_FILENAME_BRS} |

  Scenario: TC_2: Load files for BBG data to test BB,BBLOANID and LOANXID populate for VSH

    Given I process files with below parameters and wait for the job to be completed
      | BUSINESS_FEED |                                  |
      | FILE_PATTERN  | ${INPUT_FILENAME_BB}             |
      | MESSAGE_TYPE  | EIS_MT_BBG_SECURITY_PER_SECURITY |

    Then I expect value of column "ID_COUNT_BB" in the below SQL query equals to "1" with 3 retries:
      """
      SELECT COUNT(*) AS ID_COUNT_BB FROM FT_T_ISID
	  WHERE ISS_ID ='${BBLOANID_BB}'
	  AND ID_CTXT_TYP ='BBLOANID'
	  AND END_TMS IS NULL
      """

  Scenario: TC_3: Load files BRS file test BBLOANID for VSH

    Given I process files with below parameters and wait for the job to be completed
      | BUSINESS_FEED |                         |
      | FILE_PATTERN  | ${INPUT_FILENAME_BRS}   |
      | MESSAGE_TYPE  | EIS_MT_BRS_SECURITY_NEW |

    Then I expect value of column "ID_COUNT_BB" in the below SQL query equals to "1" with 3 retries:
      """
      SELECT COUNT(*) AS ID_COUNT_BB FROM FT_T_ISID
	  WHERE ISS_ID ='${BBLOANID_BRS}'
	  AND ID_CTXT_TYP ='BBLOANID'
	  AND END_TMS IS NULL
      """

  Scenario: TC_4: Loading BBG data again to test VSH

    Given I copy files below from local folder "${testdata.path}" to the host "dmp.ssh.inbound" folder "${dmp.ssh.inbound.path}":
      | ${INPUT_FILENAME_BB} |

    When I process files with below parameters and wait for the job to be completed
      | BUSINESS_FEED |                                  |
      | FILE_PATTERN  | ${INPUT_FILENAME_BB}             |
      | MESSAGE_TYPE  | EIS_MT_BBG_SECURITY_PER_SECURITY |

    Then I expect value of column "ID_COUNT_BB" in the below SQL query equals to "0":
      """
      SELECT COUNT(*) AS ID_COUNT_BB FROM FT_T_ISID
	  WHERE ISS_ID ='${BBLOANID_BB}'
	  AND ID_CTXT_TYP ='BBLOANID'
	  AND END_TMS IS NULL
      """