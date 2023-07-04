#https://jira.pruconnect.net/browse/EISDEV-6063
#https://collaborate.pruconnect.net/pages/viewpage.action?spaceKey=EISTT&title=Thai+Local+ID%7CF10+Interface%7CBRS+to+DMP#businessRequirements-goals

@gc_interface_securities
@dmp_regression_unittest
@eisdev_6063 @001_sm_thai_id @dmp_thailand_securities @dmp_thailand
Feature: Test changes to BRS security interface for TH implementation: TH security identifier Thai ID

  This feature will test the Thai ID in file10 is mapped properly in DMP without any issue.
  Also, make sure that if same security is loaded again with different values in THAIID context type then it should not
  create another record in ISID table rather update the existing one.

  Scenario: TC1: Initialize all the variables

    Given I assign "001_R3.IN.1Y_BRS_DMP_SecurityMaster_TH_ThaID_New.xml" to variable "SECURITY_INPUT_FILENAME_1"
    And I assign "001_R3.IN.1Y_BRS_DMP_SecurityMaster_TH_ThaID_Update.xml" to variable "SECURITY_INPUT_FILENAME_2"

    And I assign "tests/test-data/dmp-interfaces/Thailand/Security/File10" to variable "testdata.path"

    And I extract value from the xml file "${testdata.path}/testdata/${SECURITY_INPUT_FILENAME_1}" with tagName "CUSIP" to variable "BCUSIP"
    And I extract value from the xml file "${testdata.path}/testdata/${SECURITY_INPUT_FILENAME_1}" with xpath "//CUSIP_ALIAS_set//PURPOSE[text()='THAIID']/../IDENTIFIER" to variable "TH_Thai_ID_New"
    And I extract value from the xml file "${testdata.path}/testdata/${SECURITY_INPUT_FILENAME_2}" with xpath "//CUSIP_ALIAS_set//PURPOSE[text()='THAIID']/../IDENTIFIER" to variable "TH_Thai_ID_Update"

  Scenario: TC2: Load Security Master F10 file with <CODE>60030<CODE> & <PURPOSE>THAIID</PURPOSE> labels

    # End date existing ISIDs to ensure new security created
    Given I set end_tms to SYSDATE in database "dmp.db.GC" where iss_id in "'${BCUSIP}'"

    Then I copy files below from local folder "${testdata.path}/testdata" to the host "dmp.ssh.inbound" folder "${dmp.ssh.inbound.path}":
      | ${SECURITY_INPUT_FILENAME_1} |

    Given I process files with below parameters and wait for the job to be completed
      | BUSINESS_FEED |                              |
      | FILE_PATTERN  | ${SECURITY_INPUT_FILENAME_1} |
      | MESSAGE_TYPE  | EIS_MT_BRS_SECURITY_NEW      |

    Then I expect workflow is processed in DMP with total record count as "1"

  Scenario: TC3: Check if Thai ID is created in database

    Then I expect value of column "THAIID_NEW" in the below SQL query equals to "${TH_Thai_ID_New}":
    """
	SELECT iss_id AS THAIID_NEW
	FROM   ft_t_isid
	WHERE  end_tms IS NULL
		AND id_ctxt_typ = 'TSC'
		AND instr_id IN (SELECT instr_id
							FROM   ft_t_isid
							WHERE  id_ctxt_typ = 'BCUSIP'
								AND iss_id = '${BCUSIP}'
								AND end_tms IS NULL)
	"""

  Scenario: TC4: Load new security F10 file with modified identifiers <Value> tag to ensure old identifiers updated

    Given I copy files below from local folder "${testdata.path}/testdata" to the host "dmp.ssh.inbound" folder "${dmp.ssh.inbound.path}":
      | ${SECURITY_INPUT_FILENAME_2} |

    When I process files with below parameters and wait for the job to be completed
      | BUSINESS_FEED |                              |
      | FILE_PATTERN  | ${SECURITY_INPUT_FILENAME_2} |
      | MESSAGE_TYPE  | EIS_MT_BRS_SECURITY_NEW      |

    Then I expect workflow is processed in DMP with total record count as "1"

  Scenario: TC5: Check if Thai ID is updated with the new value and Old THai ID is not present in database

    Then I expect value of column "THAIID_UPDATE" in the below SQL query equals to "${TH_Thai_ID_Update}":
    """
	SELECT iss_id AS THAIID_UPDATE
	FROM   ft_t_isid
	WHERE  end_tms IS NULL
		AND id_ctxt_typ = 'TSC'
		AND instr_id IN (SELECT instr_id
							FROM   ft_t_isid
							WHERE  id_ctxt_typ = 'BCUSIP'
								AND iss_id = '${BCUSIP}'
								AND end_tms IS NULL)
    """

    Then I expect value of column "NO_OF_ACTIVE_THAI_ID" in the below SQL query equals to "1":
    """
	SELECT Count(1) NO_OF_ACTIVE_THAI_ID
	FROM   ft_t_isid
	WHERE  end_tms IS NULL
		AND id_ctxt_typ = 'TSC'
		AND instr_id IN (SELECT instr_id
							FROM   ft_t_isid
							WHERE  id_ctxt_typ = 'BCUSIP'
								AND iss_id = '${BCUSIP}'
								AND end_tms IS NULL)
    """

    Then I expect value of column "OLD_THAI_ID" in the below SQL query equals to "0":
    """
	SELECT Count(1) OLD_THAI_ID
	FROM   ft_t_isid
	WHERE  end_tms IS NULL
		AND id_ctxt_typ = 'TSC'
		AND iss_ID = '${TH_Thai_ID_New}'
		AND instr_id IN (SELECT instr_id
							FROM   ft_t_isid
							WHERE  id_ctxt_typ = 'BCUSIP'
								AND iss_id = '${BCUSIP}'
								AND end_tms IS NULL)
    """