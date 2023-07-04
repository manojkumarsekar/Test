#https://jira.pruconnect.net/browse/EISDEV-5949
#https://collaborate.pruconnect.net/pages/viewpage.action?spaceKey=EISTT&title=TBMA%7CUpload+FI+Price+and+Publish+to+BRS

@gc_interface_securities @gc_interface_prices
@dmp_regression_integrationtest
@eisdev_5949 @001_price_th_fixed_income @dmp_thailand_price @dmp_thailand
Feature: Test changes to DMP to BRS Price interface to publish price for Fixed Income securities sourced from TBMA

  This feature will test prices uploaded from TBMA is getting published in price interface to BRS.
  PURPOSE (ESITHA) & SOURCE(ESITH).

  Scenario: TC1: Initialize all the variables

    Given I assign "001_R3.IN.TDAYPRICE04_DMP_BRS_Security_TH_FixedIncome.xml" to variable "SECURITY_INPUT_FILENAME"
    And I assign "001_R3.IN.TDAYPRICE04_DMP_BRS_Price_TH_FixedIncome.xml" to variable "PRICE_INPUT_FILENAME"

    And I assign "tests/test-data/dmp-interfaces/Thailand/Price/Outbound" to variable "testdata.path"

    And I extract value from the xml file "${testdata.path}/testdata/${SECURITY_INPUT_FILENAME}" with tagName "CUSIP" to variable "BCUSIP"
    And I extract value from the xml file "${testdata.path}/testdata/${SECURITY_INPUT_FILENAME}" with xpath "//CUSIP_ALIAS_set//PURPOSE[text()='THAIID']/../IDENTIFIER" to variable "F10_Thai_ID"

    And I extract value from the xml file "${testdata.path}/testdata/${PRICE_INPUT_FILENAME}" with tagName "symbol" to variable "TMBA_Thai_ID"
    And I extract value from the xml file "${testdata.path}/testdata/${PRICE_INPUT_FILENAME}" with tagName "Clean_Price" to variable "TMBA_Price"

    And I generate value with date format "YYYYMMdd" and assign to variable "VAR_SYSDATE"
    And I assign "esi_brs_p_price_tbma" to variable "ACTUAL_PUBLISHED_FILENAME"
    And I assign "tbma_price_expected.csv" to variable "EXPECTED_PUBLISHED_FILENAME"
    And I assign "/dmp/out/brs/eod" to variable "PUBLISHING_DIR"

  Scenario: TC2: Load Security Master F10 file to setup Thai ID on Security

    # End date existing ISIDs to ensure new security created
    Given I set end_tms to SYSDATE in database "dmp.db.GC" where iss_id in "'${BCUSIP}'"

    Then I copy files below from local folder "${testdata.path}/testdata" to the host "dmp.ssh.inbound" folder "${dmp.ssh.inbound.path}":
      | ${SECURITY_INPUT_FILENAME} |

    Given I process files with below parameters and wait for the job to be completed
      | BUSINESS_FEED |                            |
      | FILE_PATTERN  | ${SECURITY_INPUT_FILENAME} |
      | MESSAGE_TYPE  | EIS_MT_BRS_SECURITY_NEW    |

    Then I expect workflow is processed in DMP with total record count as "1"

  Scenario: TC3: Check if Thai ID is created in database

    Then I expect value of column "THAIID_DB" in the below SQL query equals to "${TMBA_Thai_ID}":
    """
	SELECT iss_id AS THAIID_DB
	FROM   ft_t_isid
	WHERE  end_tms IS NULL
		AND id_ctxt_typ = 'TSC'
		AND instr_id IN (SELECT instr_id
							FROM   ft_t_isid
							WHERE  id_ctxt_typ = 'BCUSIP'
								AND iss_id = '${BCUSIP}'
								AND end_tms IS NULL)
	"""

  Scenario: TC4: Load TBMA price file to load price

    Given I copy files below from local folder "${testdata.path}/testdata" to the host "dmp.ssh.inbound" folder "${dmp.ssh.inbound.path}":
      | ${PRICE_INPUT_FILENAME} |

    When I process files with below parameters and wait for the job to be completed
      | BUSINESS_FEED |                         |
      | FILE_PATTERN  | ${PRICE_INPUT_FILENAME} |
      | MESSAGE_TYPE  | EITH_MT_TBMA_SECURITY   |

    Then I expect workflow is processed in DMP with total record count as "1"

  Scenario: TC5: Check if Price got loaded on the security

    Then I expect value of column "PriceInISPC" in the below SQL query equals to "${TMBA_Price}":
    """
	SELECT unit_cprc AS PriceInISPC
	FROM   ft_t_ispc
	WHERE  prc_typ = 'CLOSE'
	AND prc_srce_typ = 'ESITH'
	AND prcng_meth_typ = 'ESITHA'
	AND instr_id IN (SELECT instr_id
							FROM   ft_t_isid
							WHERE  id_ctxt_typ = 'BCUSIP'
								AND iss_id = '${BCUSIP}'
								AND end_tms IS NULL)
    """

  Scenario: TC6: Trigger Price publishing for CSV file into directory for TBMA Price

    Given I remove below files in the host "dmp.ssh.inbound" from folder "${PUBLISHING_DIR}" if exists:
      | ${ACTUAL_PUBLISHED_FILENAME}_${VAR_SYSDATE}_1.csv |

    When I process publishing wrapper with below parameters and wait for the job to be completed
      | PUBLISHING_FILE_NAME | ${ACTUAL_PUBLISHED_FILENAME}.csv                               |
      | SUBSCRIPTION_NAME    | EIS_DMP_TO_BRS_PRICE_VIEW_SUB                                  |
      | SQL                  | &lt;sql&gt; TRUNC(PRC1_ADJST_TMS) =TRUNC(SYSDATE) &lt;/sql&gt; |

    Then I expect below files to be present in the host "dmp.ssh.inbound" into folder "${PUBLISHING_DIR}" after processing:
      | ${ACTUAL_PUBLISHED_FILENAME}_${VAR_SYSDATE}_1.csv |

    Then I copy files below from remote folder "${PUBLISHING_DIR}" on host "dmp.ssh.inbound" into local folder "${testdata.path}/outfiles/actual":
      | ${ACTUAL_PUBLISHED_FILENAME}_${VAR_SYSDATE}_1.csv |

  Scenario: TC7: Check if published file contains all the records which were loaded for TBMA Price

    When I capture current time stamp into variable "recon.timestamp"
    Then I expect each record in file "${testdata.path}/outfiles/expected/${EXPECTED_PUBLISHED_FILENAME}" should exist in file "${testdata.path}/outfiles/actual/${ACTUAL_PUBLISHED_FILENAME}_${VAR_SYSDATE}_1.csv" and exceptions to be written to "${testdata.path}/outfiles/actual/exceptions_${recon.timestamp}.csv" file