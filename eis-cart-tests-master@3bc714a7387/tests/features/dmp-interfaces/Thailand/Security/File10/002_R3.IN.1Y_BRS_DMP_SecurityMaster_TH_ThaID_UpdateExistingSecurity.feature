#https://jira.pruconnect.net/browse/EISDEV-6149
#https://collaborate.pruconnect.net/pages/viewpage.action?spaceKey=EISTT&title=Thai+Local+ID%7CF10+Interface%7CBRS+to+DMP#businessRequirements-goals

@gc_interface_securities @gc_interface_issuer
@dmp_regression_integrationtest
@eisdev_6149 @002_sm_thai_id @dmp_thailand_securities @dmp_thailand
Feature: Test updating the Thai ID of an existing security

  This feature aims at testing the below flow:
  A security file is loaded with a security containing no Thai ID attributes
  Verification done to ensure no Thai ID present in DMP
  Security file is loaded again for the same security with the Thai ID
  Thai ID should be updated in the DMP for the existing security without any issues

  Scenario: TC_1: Setup variables

    Given I assign "002_R3.IN.1Y_BRS_DMP_SecurityMaster_TH_ThaID_CreateSecurity.xml" to variable "SECURITY_INPUT_FILENAME_1"
    And I assign "002_R3.IN.1Y_BRS_DMP_SecurityMaster_TH_ThaID_UpdateThai.xml" to variable "SECURITY_INPUT_FILENAME_2"
    And I assign "002_R3.IN.1Y_BRS_DMP_PrerequisiteFile.issuer.xml" to variable "PREREQUISITE_ISSUER_FILE"
    And I assign "tests/test-data/dmp-interfaces/Thailand/Security/File10" to variable "testdata.path"

    And I extract value from the xml file "${testdata.path}/testdata/${SECURITY_INPUT_FILENAME_1}" with tagName "CUSIP" to variable "BCUSIP"

  Scenario: TC2: Load Issuer file required as pre requisite

    Then I copy files below from local folder "${testdata.path}/testdata" to the host "dmp.ssh.inbound" folder "${dmp.ssh.inbound.path}":
      | ${PREREQUISITE_ISSUER_FILE} |

    Given I process files with below parameters and wait for the job to be completed
      | BUSINESS_FEED |                             |
      | FILE_PATTERN  | ${PREREQUISITE_ISSUER_FILE} |
      | MESSAGE_TYPE  | EIS_MT_BRS_ISSUER           |

    Then I expect workflow is processed in DMP with total record count as "1"

  Scenario: TC3: Load Security Master F10 file which has no <CODE>60030<CODE> & <PURPOSE>THAIID</PURPOSE> labels

    # End date existing ISIDs to ensure new security created
    Given I set end_tms to SYSDATE in database "dmp.db.GC" where iss_id in "'${BCUSIP}'"

    Then I copy files below from local folder "${testdata.path}/testdata" to the host "dmp.ssh.inbound" folder "${dmp.ssh.inbound.path}":
      | ${SECURITY_INPUT_FILENAME_1} |

    Given I process files with below parameters and wait for the job to be completed
      | BUSINESS_FEED |                              |
      | FILE_PATTERN  | ${SECURITY_INPUT_FILENAME_1} |
      | MESSAGE_TYPE  | EIS_MT_BRS_SECURITY_NEW      |

    Then I expect workflow is processed in DMP with total record count as "1"

  Scenario: TC4: Verify no Thai ID is present for the security

    Then I expect value of column "THAIID_COUNT" in the below SQL query equals to "0":
    """
	SELECT count(iss_id) AS THAIID_COUNT
	FROM   ft_t_isid
	WHERE  end_tms IS NULL
		AND id_ctxt_typ = 'TSC'
		AND instr_id IN (SELECT instr_id
							FROM   ft_t_isid
							WHERE  id_ctxt_typ = 'BCUSIP'
								AND iss_id = '${BCUSIP}'
								AND end_tms IS NULL)
	"""

  Scenario: TC5: Load Security Master F10 file for same security with <CODE>60030<CODE> & <PURPOSE>THAIID</PURPOSE> labels

    Given I extract value from the xml file "${testdata.path}/testdata/${SECURITY_INPUT_FILENAME_2}" with xpath "//CUSIP_ALIAS_set//PURPOSE[text()='THAIID']/../IDENTIFIER" to variable "TH_Thai_ID"

    Then I copy files below from local folder "${testdata.path}/testdata" to the host "dmp.ssh.inbound" folder "${dmp.ssh.inbound.path}":
      | ${SECURITY_INPUT_FILENAME_2} |

    Given I process files with below parameters and wait for the job to be completed
      | BUSINESS_FEED |                              |
      | FILE_PATTERN  | ${SECURITY_INPUT_FILENAME_2} |
      | MESSAGE_TYPE  | EIS_MT_BRS_SECURITY_NEW      |

    Then I expect workflow is processed in DMP with total record count as "1"


  Scenario: TC6: Check if Thai ID is created in database

    Then I expect value of column "THAIID_NEW" in the below SQL query equals to "${TH_Thai_ID}":
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