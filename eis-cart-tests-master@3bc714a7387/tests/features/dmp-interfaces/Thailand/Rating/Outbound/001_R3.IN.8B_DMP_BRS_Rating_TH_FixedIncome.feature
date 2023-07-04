#https://jira.pruconnect.net/browse/EISDEV-5953
#https://collaborate.pruconnect.net/display/EISTT/TBMA%7CUpload+TRIS+Ratings+and+Publish+to+BRS

@gc_interface_securities @gc_interface_ratings
@dmp_regression_integrationtest
@eisdev_5953 @001_rating_th_fixed_income @dmp_thailand_rating @dmp_thailand
Feature: Test changes to DMP to BRS rating interface to publish rating for Fixed Income securities sourced from TBMA

  This feature will test ratings uploaded from TBMA is getting published in rating interface to BRS. AGY=10402.
  There will be ratings with Qualifier (sf) and without qualifier coming from vendor which we need to publish as is to BRS.
  This feature file tests both the ratings and is loading 2 records.

  Scenario: TC1: Initialize all the variables

    Given I assign "001_R3.IN.8B_DMP_BRS_Security_TH_FixedIncome.xml" to variable "SECURITY_INPUT_FILENAME"
    And I assign "001_R3.IN.8B_DMP_BRS_Rating_TH_FixedIncome.xml" to variable "RATING_INPUT_FILENAME"

    And I assign "tests/test-data/dmp-interfaces/Thailand/Rating/Outbound" to variable "testdata.path"

    And I extract value from the xml file "${testdata.path}/testdata/${SECURITY_INPUT_FILENAME}" with tagName "CUSIP" at index 0 to variable "BCUSIPWithQualifier"
    And I extract value from the xml file "${testdata.path}/testdata/${SECURITY_INPUT_FILENAME}" with tagName "CUSIP" at index 1 to variable "BCUSIPWithoutQualifier"
    And I extract value from the xml file "${testdata.path}/testdata/${SECURITY_INPUT_FILENAME}" with xpath "//CUSIP_ALIAS_set//PURPOSE[text()='THAIID']/../IDENTIFIER" at index 0 to variable "F10ThaiIDWithQualifier"
    And I extract value from the xml file "${testdata.path}/testdata/${SECURITY_INPUT_FILENAME}" with xpath "//CUSIP_ALIAS_set//PURPOSE[text()='THAIID']/../IDENTIFIER" at index 1 to variable "F10ThaiIDWithoutQualifier"

    And I extract value from the xml file "${testdata.path}/testdata/${RATING_INPUT_FILENAME}" with tagName "symbol" at index 0 to variable "TMBAThaiIDWithQualifier"
    And I extract value from the xml file "${testdata.path}/testdata/${RATING_INPUT_FILENAME}" with tagName "symbol" at index 1 to variable "TMBAThaiIDWithoutQualifier"
    And I extract value from the xml file "${testdata.path}/testdata/${RATING_INPUT_FILENAME}" with tagName "TRIS" at index 0 to variable "TMBARatingWithQualifier"
    And I extract value from the xml file "${testdata.path}/testdata/${RATING_INPUT_FILENAME}" with tagName "TRIS" at index 1 to variable "TMBARatingWithoutQualifier"

    And I generate value with date format "YYYYMMdd" and assign to variable "VAR_SYSDATE"
    And I assign "esi_brs_p_ratings_tbma" to variable "ACTUAL_PUBLISHED_FILENAME"
    And I assign "tbma_rating_expected.csv" to variable "EXPECTED_PUBLISHED_FILENAME"
    And I assign "/dmp/out/brs/1a_security" to variable "PUBLISHING_DIR"

  Scenario: TC2: Load Security Master F10 file to setup Thai ID on Security

    # End date existing ISIDs to ensure new security created
    Given I set end_tms to SYSDATE in database "dmp.db.GC" where iss_id in "'${BCUSIPWithQualifier}','${BCUSIPWithoutQualifier}'"

    Then I copy files below from local folder "${testdata.path}/testdata" to the host "dmp.ssh.inbound" folder "${dmp.ssh.inbound.path}":
      | ${SECURITY_INPUT_FILENAME} |

    Given I process files with below parameters and wait for the job to be completed
      | BUSINESS_FEED |                            |
      | FILE_PATTERN  | ${SECURITY_INPUT_FILENAME} |
      | MESSAGE_TYPE  | EIS_MT_BRS_SECURITY_NEW    |

    Then I expect workflow is processed in DMP with total record count as "2"

  Scenario: TC3: Check if Thai ID is created in database

    Then I expect value of column "THAIID_DB_With_Qualifier" in the below SQL query equals to "${TMBAThaiIDWithQualifier}":
    """
	SELECT iss_id AS THAIID_DB_With_Qualifier
	FROM   ft_t_isid
	WHERE  end_tms IS NULL
		AND id_ctxt_typ = 'TSC'
		AND instr_id IN (SELECT instr_id
							FROM   ft_t_isid
							WHERE  id_ctxt_typ = 'BCUSIP'
								AND iss_id = '${BCUSIPWithQualifier}'
								AND end_tms IS NULL)
	"""

    Then I expect value of column "THAIID_DB_Without_Qualifier" in the below SQL query equals to "${TMBAThaiIDWithoutQualifier}":
    """
	SELECT iss_id AS THAIID_DB_Without_Qualifier
	FROM   ft_t_isid
	WHERE  end_tms IS NULL
		AND id_ctxt_typ = 'TSC'
		AND instr_id IN (SELECT instr_id
							FROM   ft_t_isid
							WHERE  id_ctxt_typ = 'BCUSIP'
								AND iss_id = '${BCUSIPWithoutQualifier}'
								AND end_tms IS NULL)
	"""

  Scenario: TC4: Load TBMA rating file to load rating

    Given I copy files below from local folder "${testdata.path}/testdata" to the host "dmp.ssh.inbound" folder "${dmp.ssh.inbound.path}":
      | ${RATING_INPUT_FILENAME} |

    When I process files with below parameters and wait for the job to be completed
      | BUSINESS_FEED |                          |
      | FILE_PATTERN  | ${RATING_INPUT_FILENAME} |
      | MESSAGE_TYPE  | EITH_MT_TBMA_SECURITY    |

    Then I expect workflow is processed in DMP with total record count as "2"

  Scenario: TC5: Check if Rating got loaded on the security

    Then I expect value of column "TMBARatingWithQualifierInDB" in the below SQL query equals to "${TMBARatingWithQualifier}":
    """
	SELECT rtng_symbol_txt AS TMBARatingWithQualifierInDB
	FROM   ft_t_isrt
	WHERE  rtng_set_oid = (select rtng_set_oid from ft_t_rtng where rtng_set_mnem = 'TRISTBMA')
	AND instr_id IN (SELECT instr_id
							FROM   ft_t_isid
							WHERE  id_ctxt_typ = 'BCUSIP'
								AND iss_id = '${BCUSIPWithQualifier}'
								AND end_tms IS NULL)
    """

    Then I expect value of column "TMBARatingWithoutQualifierInDB" in the below SQL query equals to "${TMBARatingWithoutQualifier}":
    """
	SELECT rtng_symbol_txt AS TMBARatingWithoutQualifierInDB
	FROM   ft_t_isrt
	WHERE  rtng_set_oid = (select rtng_set_oid from ft_t_rtng where rtng_set_mnem = 'TRISTBMA')
	AND instr_id IN (SELECT instr_id
							FROM   ft_t_isid
							WHERE  id_ctxt_typ = 'BCUSIP'
								AND iss_id = '${BCUSIPWithoutQualifier}'
								AND end_tms IS NULL)
    """

  Scenario: TC6: Trigger Rating publishing for CSV file into directory for TBMA Rating

    Given I remove below files in the host "dmp.ssh.inbound" from folder "${PUBLISHING_DIR}" if exists:
      | ${ACTUAL_PUBLISHED_FILENAME}*.csv |

    When I process publishing wrapper with below parameters and wait for the job to be completed
      | PUBLISHING_FILE_NAME | ${ACTUAL_PUBLISHED_FILENAME}.csv |
      | SUBSCRIPTION_NAME    | EIS_DMP_TO_BRS_BBGRATINGS_SUB    |

    Then I expect below files to be present in the host "dmp.ssh.inbound" into folder "${PUBLISHING_DIR}" after processing:
      | ${ACTUAL_PUBLISHED_FILENAME}_${VAR_SYSDATE}_1.csv |

    Then I copy files below from remote folder "${PUBLISHING_DIR}" on host "dmp.ssh.inbound" into local folder "${testdata.path}/outfiles/actual":
      | ${ACTUAL_PUBLISHED_FILENAME}_${VAR_SYSDATE}_1.csv |

  Scenario: TC7: Check if published file contains all the records which were loaded for TBMA Price

    When I capture current time stamp into variable "recon.timestamp"
    Then I expect each record in file "${testdata.path}/outfiles/expected/${EXPECTED_PUBLISHED_FILENAME}" should exist in file "${testdata.path}/outfiles/actual/${ACTUAL_PUBLISHED_FILENAME}_${VAR_SYSDATE}_1.csv" and exceptions to be written to "${testdata.path}/outfiles/actual/exceptions_${recon.timestamp}.csv" file