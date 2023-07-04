#https://jira.pruconnect.net/browse/EISDEV-6156
#Price Functional specification : https://collaborate.pruconnect.net/display/EISTT/TBMA%7CUpload+FI+Price+and+Publish+to+BRS#businessRequirements-1328663913
#Rating Functional specification : https://collaborate.pruconnect.net/pages/viewpage.action?spaceKey=EISTT&title=TBMA%7CUpload+TRIS+Ratings+and+Publish+to+BRS#businessRequirements-1328663913

@gc_interface_issuer @gc_interface_securities
@dmp_regression_integrationtest
@eisdev_6156 @002_price_rating_th @dmp_thailand_price @dmp_thailand
Feature: TBMA-TRIS Price and Rating data load negative scenarios

  This feature tests the loading of records for an invalid symbol and with missing mandatory tags.
  The file with below records is loaded.
  1. Symbol is not present in the inbound file
  2. As Of Date value is not present in the inbound file
  3. The symbol used in the inbound fie is not present in DMP
  4. A valid record for a valid symbol
  The records 1 - 3 should not get loaded and record 4 should get loaded successfully


  Scenario: TC_1: Setup variables

    Given I assign "tests/test-data/dmp-interfaces/Thailand/Price/Inbound" to variable "testdata.path"
    And I assign "002_Th.Aldn-23_TBMA_DMP_PrerequisiteFile.security.xml" to variable "PREREQUISITE_SECURITY_FILE"
    And I assign "002_Th.Aldn-23_TBMA_DMP_PrerequisiteFile.issuer.xml" to variable "PREREQUISITE_ISSUER_FILE"
    And I extract value from the xml file "${testdata.path}/testdata/${PREREQUISITE_SECURITY_FILE}" with tagName "CUSIP" to variable "BCUSIP"
    And I extract value from the xml file "${testdata.path}/testdata/${PREREQUISITE_SECURITY_FILE}" with xpath "//CUSIP_ALIAS_set//PURPOSE[text()='THAIID']/../IDENTIFIER" to variable "TH_Thai_ID"
    And I assign "002_Th.Aldn-23_TBMA_DMP_Price_Rating_TH_NegativeScenarios.xml" to variable "TRIS_SOURCE_INPUT_FILENAME"
    And I assign "ANAN204A" to variable "SYMBOL_NOT_IN_DMP"

    # End date existing ISIDs to ensure new security created
    And I set end_tms to SYSDATE in database "dmp.db.GC" where iss_id in "'${BCUSIP}','${SYMBOL_NOT_IN_DMP}'"

  Scenario: TC2: Load Issuer file required as pre requisite

    Then I copy files below from local folder "${testdata.path}/testdata" to the host "dmp.ssh.inbound" folder "${dmp.ssh.inbound.path}":
      | ${PREREQUISITE_ISSUER_FILE} |

    Given I process files with below parameters and wait for the job to be completed
      | BUSINESS_FEED |                             |
      | FILE_PATTERN  | ${PREREQUISITE_ISSUER_FILE} |
      | MESSAGE_TYPE  | EIS_MT_BRS_ISSUER           |

    Then I expect workflow is processed in DMP with total record count as "1"

  Scenario: TC3: Load Security file required as pre requisite

    Then I copy files below from local folder "${testdata.path}/testdata" to the host "dmp.ssh.inbound" folder "${dmp.ssh.inbound.path}":
      | ${PREREQUISITE_SECURITY_FILE} |

    Given I process files with below parameters and wait for the job to be completed
      | BUSINESS_FEED |                               |
      | FILE_PATTERN  | ${PREREQUISITE_SECURITY_FILE} |
      | MESSAGE_TYPE  | EIS_MT_BRS_SECURITY_NEW       |

    Then I expect workflow is processed in DMP with total record count as "1"

  Scenario: TC4: Check if Thai ID is created in database

    Then I expect value of column "THAIID_NEW" in the below SQL query equals to "${TH_Thai_ID}":
    """
	SELECT iss_id AS THAIID_NEW
	FROM   ft_t_isid
	WHERE  end_tms IS NULL
	AND id_ctxt_typ = 'TSC'
	AND instr_id IN
	(SELECT instr_id
	 FROM ft_t_isid
	 WHERE  id_ctxt_typ = 'BCUSIP'
	 AND iss_id = '${BCUSIP}'
	 AND end_tms IS NULL)
	"""

  Scenario: TC5: Load TBMA-TRIS Source input file with four records one with no symbol, one with no as of date,one with all data present but symbol not in DMP and one valid record

    Given I copy files below from local folder "${testdata.path}/testdata" to the host "dmp.ssh.inbound" folder "${dmp.ssh.inbound.path}":
      | ${TRIS_SOURCE_INPUT_FILENAME} |

    When I process files with below parameters and wait for the job to be completed
      | BUSINESS_FEED |                               |
      | FILE_PATTERN  | ${TRIS_SOURCE_INPUT_FILENAME} |
      | MESSAGE_TYPE  | EITH_MT_TBMA_SECURITY         |

  Scenario: TC6: Verify only one record is successful,with 1 record partial and two filtered records

    Then I expect workflow is processed in DMP with total record count as "4"

    And success record count as "1"

    And partial record count as "1"

    And filtered record count as "2"

  Scenario: TC7: Verify the price and rating updated for valid security

    Then I expect value of column "VALID_SECURITY_PRICE_COUNT" in the below SQL query equals to "1":
    """
    SELECT count(unit_cprc) as VALID_SECURITY_PRICE_COUNT ,MAX(adjst_tms) as ADJST_TMS
	FROM   ft_t_ispc
	WHERE  prcng_meth_typ='ESITHA'
	AND    instr_id IN (SELECT instr_id
	FROM   ft_t_isid
	WHERE  id_ctxt_typ = 'BCUSIP'
	AND    iss_id = '${BCUSIP}'
	AND    end_tms IS NULL)
    GROUP BY unit_cprc
    """

    And I expect value of column "VALID_SECURITY_RATING_COUNT" in the below SQL query equals to "1":
     """
    SELECT count(rtng_cde) AS VALID_SECURITY_RATING_COUNT
    FROM   ft_t_isrt
    WHERE  end_tms IS NULL
    AND    sys_eff_end_tms IS NULL
    AND    last_chg_usr_id='EITH_TBMA_DMP_SECURITY'
    AND    instr_id IN (SELECT instr_id
    FROM   ft_t_isid
    WHERE  id_ctxt_typ = 'BCUSIP'
    AND    iss_id = '${BCUSIP}'
    AND    end_tms IS NULL)
    """