#https://jira.pruconnect.net/browse/EISDEV-6222
#https://collaborate.pruconnect.net/pages/viewpage.action?spaceKey=EISTT&title=TFUND%7CNAV+Per+unit+price%7CHIPORT%3EDMP%3EBRS

@gc_interface_securities @gc_interface_portfolios @gc_interface_nav @gc_interface_prices
@dmp_regression_integrationtest
@eisdev_6222 @002_price_th_tfund_nav_per_unit @dmp_thailand_price @dmp_thailand
Feature: Test changes to DMP to BRS Price interface to publish price for NAV per Unit for TFUND

  This feature will test prices uploaded from TFUND nav file is getting published in price interface to BRS.
  PURPOSE (EISPX) & SOURCE(TFUND).

  Scenario: TC1: Initialize all the variables

    Given I assign "003_Th.Aldn-29_DMP_BRS_Security_TH_TFUNDNavPerUnit.xml" to variable "SECURITY_INPUT_FILENAME"
    And I assign "003_Th.Aldn-29_DMP_BRS_Price_TH_TFUNDNavPerUnit.xml" to variable "NAV_INPUT_FILENAME"
    And I assign "003_Th.Aldn-29_DMP_BRS_Portfolio_TH_TFUNDNavPerUnit.xlsx" to variable "PORTFOLIO_INPUT_FILENAME"

    And I assign "tests/test-data/dmp-interfaces/Thailand/Price/Outbound" to variable "testdata.path"

    And I generate value with date format "YYYYMMdd" and assign to variable "VAR_SYSDATE"
    And I assign "esi_brs_p_price_tfund_nav_per_unit" to variable "ACTUAL_PUBLISHED_FILENAME"
    And I assign "tfund_nav_per_unit_expected.csv" to variable "EXPECTED_PUBLISHED_FILENAME"
    And I assign "/dmp/out/brs/intraday" to variable "PUBLISHING_DIR"

  Scenario: TC2: Load Security file to setup security if not present

    Given I inactivate "'TW000T0825Y7'" instruments in VD database
    And I inactivate "'TW000T0825Y7'" instruments in GC database

    And I process "${testdata.path}/testdata/${SECURITY_INPUT_FILENAME}" file with below parameters
      | BUSINESS_FEED |                            |
      | FILE_PATTERN  | ${SECURITY_INPUT_FILENAME} |
      | MESSAGE_TYPE  | EIS_MT_BRS_SECURITY_NEW    |

    Then I expect workflow is processed in DMP with total record count as "1"

  Scenario: TC3: Load Portfolio File to setup portfolio if not present

    Given I process "${testdata.path}/testdata/${PORTFOLIO_INPUT_FILENAME}" file with below parameters
      | BUSINESS_FEED |                                      |
      | FILE_PATTERN  | ${PORTFOLIO_INPUT_FILENAME}          |
      | MESSAGE_TYPE  | EIS_MT_RDM_PORTFOLIO_MASTER_TEMPLATE |

    Then I expect workflow is processed in DMP with total record count as "1"

  Scenario: TC4: Load Nav file to load price nav per unit on security

    Given I process "${testdata.path}/testdata/${NAV_INPUT_FILENAME}" file with below parameters
      | BUSINESS_FEED |                                |
      | FILE_PATTERN  | ${NAV_INPUT_FILENAME}          |
      | MESSAGE_TYPE  | EITH_MT_TFUND_DMP_FA_NAV_PRICE |

    Then I expect workflow is processed in DMP with total record count as "1"

  Scenario: TC5: Check if Price got loaded on the security

    Then I expect value of column "PriceInISPC" in the below SQL query equals to "15.5454":
    """
	SELECT unit_cprc AS PriceInISPC
	FROM   ft_t_ispc
	WHERE  prc_typ = 'CLOSE' AND rownum=1
	AND trunc(adjst_tms) = trunc(sysdate)
	AND instr_id IN (SELECT instr_id
							FROM   ft_t_isid
							WHERE  id_ctxt_typ = 'ISIN'
								AND iss_id = 'TW000T0825Y7'
								AND end_tms IS NULL)
    """

  Scenario: TC6: Trigger Price publishing for CSV file into directory for TFUND Nav Per Unit

    Given I remove below files in the host "dmp.ssh.inbound" from folder "${PUBLISHING_DIR}" if exists:
      | ${ACTUAL_PUBLISHED_FILENAME}_${VAR_SYSDATE}_1.csv |

    When I process publishing wrapper with below parameters and wait for the job to be completed
      | PUBLISHING_FILE_NAME | ${ACTUAL_PUBLISHED_FILENAME}.csv        |
      | SUBSCRIPTION_NAME    | EITH_DMP_TO_BRS_TFUND_INT_UNITNAV_PRICE |

    Then I expect below files to be present in the host "dmp.ssh.inbound" into folder "${PUBLISHING_DIR}" after processing:
      | ${ACTUAL_PUBLISHED_FILENAME}_${VAR_SYSDATE}_1.csv |

    Then I copy files below from remote folder "${PUBLISHING_DIR}" on host "dmp.ssh.inbound" into local folder "${testdata.path}/outfiles/actual":
      | ${ACTUAL_PUBLISHED_FILENAME}_${VAR_SYSDATE}_1.csv |

  Scenario: TC7: Check if published file contains all the records which were loaded for TBMA Price

    Given I capture current time stamp into variable "recon.timestamp"
    Then I expect each record in file "${testdata.path}/outfiles/expected/${EXPECTED_PUBLISHED_FILENAME}" should exist in file "${testdata.path}/outfiles/actual/${ACTUAL_PUBLISHED_FILENAME}_${VAR_SYSDATE}_1.csv" and exceptions to be written to "${testdata.path}/outfiles/actual/exceptions_${recon.timestamp}.csv" file