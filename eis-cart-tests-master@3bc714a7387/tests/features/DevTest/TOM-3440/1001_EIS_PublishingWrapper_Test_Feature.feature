#https://jira.intranet.asia/browse/TOM-3440

@gc_interface_recon @gc_interface_cash
@dmp_smoke
@tom_3440 @dmp_workflow @tom_4170
Feature: Testing Publishing wrapper Event with Directory and Email settings

  GS Publishing Workflow change for Listing ID Recon Report Email Publishing

  Scenario: Initialising Variables

    Given I assign "test_U_VAL" to variable "PUBLISHING_FILE_NAME"
    And I generate value with date format "YYYYMMdd" and assign to variable "VAR_SYSDATE"

    #By default Publishing job polling time is 300sec. Since these are testing jobs, we don't want to wait 300sec in case of failures
    #so setting to 120sec and removing this variable at the end
    And I assign "120" to variable "workflow.max.polling.time"

  Scenario: TC_1: Triggering Publishing Wrapper Event for CSV file into email

    Given I assign "/dmp/out/eis/edm" to variable "PUBLISHING_DIR"

    And I execute below query
	"""
	DELETE FROM FT_CFG_SBEX
	WHERE SBEX_OID =
	(
	  SELECT MAX(SBEX.SBEX_OID) FROM FT_CFG_SBEX SBEX, FT_CFG_SBDF SBDF
	  WHERE SBEX.SBDF_OID=SBDF.SBDF_OID
	  AND SBDF.SUBSCRIPTION_NME = 'EIS_DMP_TO_EDM_LISTING_ID_RECON_SUB'
	)
	"""

    Then I remove below files with pattern in the host "dmp.ssh.inbound" from folder "${PUBLISHING_DIR}" if exists:
      | *${PUBLISHING_FILE_NAME}* |

    When I process publishing wrapper with below parameters and wait for the job to be completed
      | PUBLISHING_FILE_NAME   | ${PUBLISHING_FILE_NAME}.csv                     |
      | SUBSCRIPTION_NAME      | EIS_DMP_TO_EDM_LISTING_ID_RECON_SUB             |
      | PUBLISHING_DESTINATION | email                                           |
      | EMAIL_BODY             | Recon Report                                    |
      | EMAIL_FROM             | gomathi.sankar.ramakrishnan@eastspring.com      |
      | EMAIL_GROUP            |                                                 |
      | EMAIL_SUBJECT          | TOM-3440 Publishing Wrapper Email CSV File Test |
      | EMAIL_TO               | gomathi.sankar.ramakrishnan@eastspring.com      |

   # This test to ensure file is not posted to Directory as we set publishing destination as Email
    Then I expect below files to be deleted to the host "dmp.ssh.inbound" from folder "${PUBLISHING_DIR}" after processing:
      | ${PUBLISHING_FILE_NAME}_${VAR_SYSDATE}_1.csv |

  Scenario: TC_2: Triggering Publishing Wrapper Event for CSV file into directory

    Given I assign "/dmp/out/eis/edm" to variable "PUBLISHING_DIR"

    And I execute below query
	"""
	DELETE FROM FT_CFG_SBEX WHERE SBEX_OID = (SELECT MAX(SBEX.SBEX_OID) FROM FT_CFG_SBEX SBEX, FT_CFG_SBDF SBDF	WHERE SBEX.SBDF_OID=SBDF.SBDF_OID
	AND SBDF.SUBSCRIPTION_NME = 'EIS_DMP_TO_EDM_LISTING_ID_RECON_SUB')
	"""

    Then I remove below files with pattern in the host "dmp.ssh.inbound" from folder "${PUBLISHING_DIR}" if exists:
      | *${PUBLISHING_FILE_NAME}* |

    When I process publishing wrapper with below parameters and wait for the job to be completed
      | PUBLISHING_FILE_NAME   | ${PUBLISHING_FILE_NAME}.csv         |
      | SUBSCRIPTION_NAME      | EIS_DMP_TO_EDM_LISTING_ID_RECON_SUB |
      | PUBLISHING_DESTINATION | directory                           |

    Then I expect below files to be present in the host "dmp.ssh.inbound" into folder "${PUBLISHING_DIR}" after processing:
      | ${PUBLISHING_FILE_NAME}_${VAR_SYSDATE}_1.csv |

  Scenario: TC_3: Triggering Publishing Wrapper Event for xml file into email

    Given I assign "1001_ITAP_Test_File_For_Verification.xml" to variable "INPUT_FILENAME"
    And I assign "tests/test-data/DevTest/TOM-3440" to variable "testdata.path"

    And I copy files below from local folder "${testdata.path}/infiles" to the host "dmp.ssh.inbound" folder "${dmp.ssh.inbound.path}":
      | ${INPUT_FILENAME} |

    When I process files with below parameters and wait for the job to be completed
      | BUSINESS_FEED |                             |
      | FILE_PATTERN  | ${INPUT_FILENAME}           |
      | MESSAGE_TYPE  | EIS_MT_BRS_CASHALLOC_FILE11 |

    Given I assign "/dmp/out/bnp/intraday" to variable "PUBLISHING_DIR"

    And I execute below query
	"""
	DELETE FROM FT_CFG_SBEX WHERE SBEX_OID=(SELECT MAX(SBEX.SBEX_OID) FROM FT_CFG_SBEX SBEX, FT_CFG_SBDF SBDF WHERE SBEX.SBDF_OID=SBDF.SBDF_OID
	AND SBDF.SUBSCRIPTION_NME = 'EIS_DMP_TO_BNP_CASHALLOCATION_ITAP_SUB')
	"""

    Then I remove below files with pattern in the host "dmp.ssh.inbound" from folder "${PUBLISHING_DIR}" if exists:
      | *${PUBLISHING_FILE_NAME}* |

    When I process publishing wrapper with below parameters and wait for the job to be completed
      | PUBLISHING_FILE_NAME   | ${PUBLISHING_FILE_NAME}.xml                     |
      | SUBSCRIPTION_NAME      | EIS_DMP_TO_BNP_CASHALLOCATION_ITAP_SUB          |
      | PUBLISHING_DESTINATION | email                                           |
      | EMAIL_BODY             | Recon Report                                    |
      | EMAIL_FROM             | gomathi.sankar.ramakrishnan@eastspring.com      |
      | EMAIL_GROUP            |                                                 |
      | EMAIL_SUBJECT          | TOM-3440 Publishing Wrapper Email XML File Test |
      | EMAIL_TO               | gomathi.sankar.ramakrishnan@eastspring.com      |

  # This test to ensure file is not posted to Directory as we set publishing destination as Email
    Then I expect below files to be deleted to the host "dmp.ssh.inbound" from folder "${PUBLISHING_DIR}" after processing:
      | ${PUBLISHING_FILE_NAME}_${VAR_SYSDATE}_1.xml |

  Scenario: TC_4: Triggering Publishing Wrapper Event for xml file into directory

    Given I assign "1001_ITAP_Test_File_For_Verification.xml" to variable "INPUT_FILENAME"
    And I assign "tests/test-data/DevTest/TOM-3440" to variable "testdata.path"

    And I copy files below from local folder "${testdata.path}/infiles" to the host "dmp.ssh.inbound" folder "${dmp.ssh.inbound.path}":
      | ${INPUT_FILENAME} |

    When I process files with below parameters and wait for the job to be completed
      | BUSINESS_FEED |                             |
      | FILE_PATTERN  | ${INPUT_FILENAME}           |
      | MESSAGE_TYPE  | EIS_MT_BRS_CASHALLOC_FILE11 |

    Given I assign "/dmp/out/bnp/intraday" to variable "PUBLISHING_DIR"

    And I execute below query
	"""
	DELETE FROM FT_CFG_SBEX WHERE SBEX_OID=(SELECT MAX(SBEX.SBEX_OID) FROM FT_CFG_SBEX SBEX, FT_CFG_SBDF SBDF WHERE SBEX.SBDF_OID=SBDF.SBDF_OID
	AND SBDF.SUBSCRIPTION_NME = 'EIS_DMP_TO_BNP_CASHALLOCATION_ITAP_SUB')
	"""

    Then I remove below files with pattern in the host "dmp.ssh.inbound" from folder "${PUBLISHING_DIR}" if exists:
      | *${PUBLISHING_FILE_NAME}* |


    When I process publishing wrapper with below parameters and wait for the job to be completed
      | PUBLISHING_FILE_NAME   | ${PUBLISHING_FILE_NAME}.xml            |
      | SUBSCRIPTION_NAME      | EIS_DMP_TO_BNP_CASHALLOCATION_ITAP_SUB |
      | PUBLISHING_DESTINATION | directory                              |

    Then I expect below files to be present in the host "dmp.ssh.inbound" into folder "${PUBLISHING_DIR}" after processing:
      | ${PUBLISHING_FILE_NAME}_${VAR_SYSDATE}_1.xml |

  Scenario: Cleanup max polling time variable

    And I remove variable "workflow.max.polling.time" from memory