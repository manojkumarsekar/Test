#https://jira.pruconnect.net/browse/EISDEV-7334

@gc_interface_securities
@dmp_regression_unittest
@eisdev_7334 @005_sm_esith_esitf_id_diffbcusip @dmp_thailand_securities @dmp_thailand
Feature: Test implicit syncing of ESITH & ESITF Identifier on different BCUSIP values with same THAIID

  This feature will test the implicit sync of ESITH & ESITF IDs
  EISTH & ESITF not present in the file but present in database should be end-dated if they are on the same BCUSIP
  as the file previously loaded. Else they will be added with ISS_USAGE_TYP for new BCUSIP value

  Scenario: TC1: Initialize all the variables

    Given I assign "005_R3.IN.1Y_BRS_DMP_SecurityMaster_TH_ESITH_ESITF_New.xml" to variable "SECURITY_INPUT_FILENAME_1"
    And I assign "005_R3.IN.1Y_BRS_DMP_SecurityMaster_TH_ESITH_ESITF_Update.xml" to variable "SECURITY_INPUT_FILENAME_2"

    And I assign "tests/test-data/dmp-interfaces/Thailand/Security/File10" to variable "testdata.path"

    And I extract value from the xml file "${testdata.path}/testdata/${SECURITY_INPUT_FILENAME_1}" with tagName "CUSIP" to variable "BCUSIP"

  Scenario: TC2: Load Security Master F10 file

    # End date existing ISIDs to ensure new security created
    Given I set end_tms to SYSDATE in database "dmp.db.GC" where iss_id in "'BES3P9AH8'"
    And I set end_tms to SYSDATE in database "dmp.db.GC" where iss_id in "'BES3RAAN0'"

    When I process "${testdata.path}/testdata/${SECURITY_INPUT_FILENAME_1}" file with below parameters
      | BUSINESS_FEED |                              |
      | FILE_PATTERN  | ${SECURITY_INPUT_FILENAME_1} |
      | MESSAGE_TYPE  | EIS_MT_BRS_SECURITY_NEW      |

    Then I expect workflow is processed in DMP with total record count as "1"

  Scenario: TC3: Check count of ESITF ID in database

    Then I expect value of column "ESITF_COUNT" in the below SQL query equals to "3":
    """
	SELECT count(1) AS ESITF_COUNT FROM ft_t_isid WHERE end_tms IS NULL
	AND id_ctxt_typ = 'TFHIPORTID' AND instr_id IN
	(SELECT instr_id FROM ft_t_isid WHERE id_ctxt_typ = 'BCUSIP' AND iss_id = 'BES3P9AH8' AND end_tms IS NULL)
	"""

  Scenario: TC4: Load Security Master F10 Update file

    When I process "${testdata.path}/testdata/${SECURITY_INPUT_FILENAME_2}" file with below parameters
      | BUSINESS_FEED |                              |
      | FILE_PATTERN  | ${SECURITY_INPUT_FILENAME_2} |
      | MESSAGE_TYPE  | EIS_MT_BRS_SECURITY_NEW      |

    Then I expect workflow is processed in DMP with total record count as "1"

  Scenario: TC5: Check count of ESITF ID in database

    Then I expect value of column "ESITF_COUNT" in the below SQL query equals to "4":
    """
	SELECT count(1) AS ESITF_COUNT FROM ft_t_isid WHERE end_tms IS NULL
	AND id_ctxt_typ = 'TFHIPORTID' AND instr_id IN
	(SELECT instr_id FROM ft_t_isid WHERE id_ctxt_typ = 'BCUSIP' AND iss_id = 'BES3RAAN0' AND end_tms IS NULL)
	"""