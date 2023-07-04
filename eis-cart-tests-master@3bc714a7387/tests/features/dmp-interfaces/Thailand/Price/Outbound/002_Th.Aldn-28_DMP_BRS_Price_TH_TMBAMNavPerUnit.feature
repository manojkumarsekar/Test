#https://jira.pruconnect.net/browse/EISDEV-6179
#https://collaborate.pruconnect.net/pages/viewpage.action?spaceKey=EISTT&title=TMBAM%7CNAV+Per+unit+price%7CHIPORT%3EDMP%3EBRS

@gc_interface_securities @gc_interface_portfolios @gc_interface_nav @gc_interface_prices
@dmp_regression_integrationtest
@eisdev_6179 @002_price_th_tmbam_nav_per_unit @dmp_thailand_price @dmp_thailand
Feature: Test changes to DMP to BRS Price interface to publish price for NAV per Unit for TMBAM

  This feature will test prices uploaded from TMBAM nav file is getting published in price interface to BRS.
  PURPOSE (ESITHA) & SOURCE(ESITH).

  Scenario: TC1: Initialize all the variables

    Given I assign "002_Th.Aldn-28_DMP_BRS_Security_TH_TMBAMNavPerUnit.xml" to variable "SECURITY_INPUT_FILENAME"
    And I assign "002_Th.Aldn-28_DMP_BRS_Price_TH_TMBAMNavPerUnit.xml" to variable "NAV_INPUT_FILENAME"
    And I assign "002_Th.Aldn-28_DMP_BRS_Portfolio_TH_TMBAMNavPerUnit.xlsx" to variable "PORTFOLIO_INPUT_FILENAME"

    And I assign "tests/test-data/dmp-interfaces/Thailand/Price/Outbound" to variable "testdata.path"

    And I extract value from the xml file "${testdata.path}/testdata/${NAV_INPUT_FILENAME}" with xpath "/header/fund_info/row/nav_per_unit" to variable "nav_per_unit"

    And I generate value with date format "YYYYMMdd" and assign to variable "VAR_SYSDATE"
    And I assign "esi_brs_p_price_tmbam_nav_per_unit" to variable "ACTUAL_PUBLISHED_FILENAME"
    And I assign "tmbam_nav_per_unit_expected.csv" to variable "EXPECTED_PUBLISHED_FILENAME"
    And I assign "/dmp/out/brs/intraday" to variable "PUBLISHING_DIR"

  Scenario: TC2: Load Security file to setup security if not present

    Given I copy files below from local folder "${testdata.path}/testdata" to the host "dmp.ssh.inbound" folder "${dmp.ssh.inbound.path}":
      | ${SECURITY_INPUT_FILENAME} |

    Given I process files with below parameters and wait for the job to be completed
      | BUSINESS_FEED |                            |
      | FILE_PATTERN  | ${SECURITY_INPUT_FILENAME} |
      | MESSAGE_TYPE  | EIS_MT_BRS_SECURITY_NEW    |

    Then I expect workflow is processed in DMP with total record count as "1"

  Scenario: TC3: Load Portfolio File to setup portfolio if not present

    Given I copy files below from local folder "${testdata.path}/testdata" to the host "dmp.ssh.inbound" folder "${dmp.ssh.inbound.path}":
      | ${PORTFOLIO_INPUT_FILENAME} |

    Given I process files with below parameters and wait for the job to be completed
      | BUSINESS_FEED |                                      |
      | FILE_PATTERN  | ${PORTFOLIO_INPUT_FILENAME}          |
      | MESSAGE_TYPE  | EIS_MT_RDM_PORTFOLIO_MASTER_TEMPLATE |

    Then I expect workflow is processed in DMP with total record count as "1"

  Scenario: TC4: Load Nav file to load price nav per unit on security

    Given I copy files below from local folder "${testdata.path}/testdata" to the host "dmp.ssh.inbound" folder "${dmp.ssh.inbound.path}":
      | ${NAV_INPUT_FILENAME} |

    When I process files with below parameters and wait for the job to be completed
      | BUSINESS_FEED |                                |
      | FILE_PATTERN  | ${NAV_INPUT_FILENAME}          |
      | MESSAGE_TYPE  | EITH_MT_TMBAM_DMP_FA_NAV_PRICE |

    Then I expect workflow is processed in DMP with total record count as "1"

  Scenario: TC5: Check if Price got loaded on the security

    Then I expect value of column "PriceInISPC" in the below SQL query equals to "${nav_per_unit}":
    """
	SELECT unit_cprc AS PriceInISPC
	FROM   ft_t_ispc
	WHERE  prc_typ = 'CLOSE' AND rownum=1
	AND trunc(adjst_tms) = trunc(sysdate)
	AND instr_id IN (SELECT instr_id
							FROM   ft_t_isid
							WHERE  id_ctxt_typ = 'ISIN'
								AND iss_id = 'THENGY070000'
								AND end_tms IS NULL)
    """

  Scenario: TC6: Trigger Price publishing for CSV file into directory for TMBAM Nav Per Unit

    Given I remove below files in the host "dmp.ssh.inbound" from folder "${PUBLISHING_DIR}" if exists:
      | ${ACTUAL_PUBLISHED_FILENAME}_${VAR_SYSDATE}_1.csv |

    When I process publishing wrapper with below parameters and wait for the job to be completed
      | PUBLISHING_FILE_NAME | ${ACTUAL_PUBLISHED_FILENAME}.csv        |
      | SUBSCRIPTION_NAME    | EITH_DMP_TO_BRS_TMBAM_INT_UNITNAV_PRICE |

    Then I expect below files to be present in the host "dmp.ssh.inbound" into folder "${PUBLISHING_DIR}" after processing:
      | ${ACTUAL_PUBLISHED_FILENAME}_${VAR_SYSDATE}_1.csv |

    Then I copy files below from remote folder "${PUBLISHING_DIR}" on host "dmp.ssh.inbound" into local folder "${testdata.path}/outfiles/actual":
      | ${ACTUAL_PUBLISHED_FILENAME}_${VAR_SYSDATE}_1.csv |

  Scenario: TC7: Check if published file contains all the records which were loaded for TBMA Price

    Given I capture current time stamp into variable "recon.timestamp"
    Then I expect each record in file "${testdata.path}/outfiles/expected/${EXPECTED_PUBLISHED_FILENAME}" should exist in file "${testdata.path}/outfiles/actual/${ACTUAL_PUBLISHED_FILENAME}_${VAR_SYSDATE}_1.csv" and exceptions to be written to "${testdata.path}/outfiles/actual/exceptions_${recon.timestamp}.csv" file