@gc_interface_securities
@dmp_regression_integrationtest
@dmp_securities_linking @sec_link_039
Feature: SCN39:Security Linking Criteria: Data Management Platform (Golden Source)
  Security update on existing security in DMP through any feed file load from BRS/RDM/BNP

  Background:
    Given I assign "tests/test-data/dmp-interfaces/security-linking-dmp/SCN_SECLINK_039" to variable "testdata.path"

  Scenario: TC_1:Prerequisite Scenario
    Given I assign "SCN_SECLINK__BRS_039.xml" to variable "INPUT_FILENAME1"
    Then I extract value from the xml file "${testdata.path}/data-feeds/${INPUT_FILENAME1}" with tagName "CUSIP" to variable "ISS_ID"

    Then I set end_tms to SYSDATE in database "dmp.db.GC" where iss_id in "'${ISS_ID}'"
    Then I set end_tms to SYSDATE in database "dmp.db.VD" where iss_id in "'${ISS_ID}'"

  Scenario: TC_2:Verify if ID_BB_GLOBAL from BNP is stored in DMP

    Given I assign "SCN_SECLINK__BRS_039.xml" to variable "INPUT_FILENAME1"
    And I assign "SCN_SECLINK__BNP_039.out" to variable "INPUT_FILENAME2"

    When I copy files below from local folder "${testdata.path}/data-feeds" to the host "dmp.ssh.inbound" folder "${dmp.ssh.inbound.path}":
      | ${INPUT_FILENAME1} |
      | ${INPUT_FILENAME2} |

    And I process files with below parameters and wait for the job to be completed
      | FILE_PATTERN  | ${INPUT_FILENAME1}      |
      | MESSAGE_TYPE  | EIS_MT_BRS_SECURITY_NEW |
      | BUSINESS_FEED |                         |

    And I process files with below parameters and wait for the job to be completed
      | FILE_PATTERN  | ${INPUT_FILENAME2}  |
      | MESSAGE_TYPE  | EIS_MT_BNP_SECURITY |
      | BUSINESS_FEED |                     |

    And I extract below values for row 2 from PSV file "${INPUT_FILENAME2}" in local folder "${testdata.path}/data-feeds" and assign to variables:
      | BLOOMBERG_GLOBAL_ID | BBGLOBAL |

    Then I expect value of column "BNP_ISID_BBGLOBAL_COUNT" in the below SQL query equals to "1":
    """
    SELECT COUNT(*) AS BNP_ISID_BBGLOBAL_COUNT FROM FT_T_ISID
    WHERE INSTR_ID IN (SELECT INSTR_ID FROM FT_T_ISID WHERE ISS_ID = '${ISS_ID}' AND END_TMS IS NULL)
    AND TRUNC(LAST_CHG_TMS) = TRUNC(SYSDATE)
    AND ID_CTXT_TYP='BNP_BBGLOBAL'
    AND LAST_CHG_USR_ID = 'EIS_BNP_DMP_SECURITY'
    AND ISS_USAGE_TYP = '${BBGLOBAL}'
    AND ISS_ID = '${BBGLOBAL}'
    """

  Scenario: Clear the data after tests
    Then I set end_tms to SYSDATE in database "dmp.db.VD" where iss_id in "'${ISS_ID}'"
    Then I set end_tms to SYSDATE in database "dmp.db.GC" where iss_id in "'${ISS_ID}'"
















