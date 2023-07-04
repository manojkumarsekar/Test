#https://jira.pruconnect.net/browse/EISDEV-6961

@gc_interface_securities
@dmp_regression_unittest
@eisdev_6961 @004_sm_rdmsctyp @dmp_thailand_securities @dmp_thailand
Feature: Test RDM Security type derivation for CDTY & TD

  This feature will test the derivation of RDM Security type
  SECGROUP  |  SECTYPE  |  RDMSCTYP
  CMDTY     |  CMDTY    |  CDTY
  CASH      |  TFN      |  TD

  Scenario: TC1: Initialize all the variables

    Given I assign "004_R3.IN.1Y_BRS_DMP_SecurityMaster_TH_RDMSCTYP.xml" to variable "SECURITY_INPUT_FILENAME"

    And I assign "tests/test-data/dmp-interfaces/Thailand/Security/File10" to variable "testdata.path"

  Scenario: TC2: Load Security Master F10 file

    # End date existing ISIDs to ensure new security created
    Given I set end_tms to SYSDATE in database "dmp.db.GC" where iss_id in "'BES34VUR8'"
    And I set end_tms to SYSDATE in database "dmp.db.GC" where iss_id in "'BES3F9C04'"

    When I process "${testdata.path}/testdata/${SECURITY_INPUT_FILENAME}" file with below parameters
      | BUSINESS_FEED |                              |
      | FILE_PATTERN  | ${SECURITY_INPUT_FILENAME} |
      | MESSAGE_TYPE  | EIS_MT_BRS_SECURITY_NEW      |

    Then I expect workflow is processed in DMP with total record count as "2"

  Scenario: TC3: Check count of ESITH & ESITF ID in database

    Then I expect value of column "RDMSCTYP_CDTY" in the below SQL query equals to "CDTY":
    """
	SELECT cl_value AS RDMSCTYP_CDTY FROM ft_t_iscl WHERE end_tms IS NULL
	AND indus_cl_set_id = 'RDMSCTYP' AND instr_id IN
	(SELECT instr_id FROM ft_t_isid WHERE id_ctxt_typ = 'BCUSIP' AND iss_id = 'BES34VUR8' AND end_tms IS NULL)
	"""

    Then I expect value of column "RDMSCTYP_TD" in the below SQL query equals to "TD":
    """
	SELECT cl_value AS RDMSCTYP_TD FROM ft_t_iscl WHERE end_tms IS NULL
	AND indus_cl_set_id = 'RDMSCTYP' AND instr_id IN
	(SELECT instr_id FROM ft_t_isid WHERE id_ctxt_typ = 'BCUSIP' AND iss_id = 'BES3F9C04' AND end_tms IS NULL)
	"""