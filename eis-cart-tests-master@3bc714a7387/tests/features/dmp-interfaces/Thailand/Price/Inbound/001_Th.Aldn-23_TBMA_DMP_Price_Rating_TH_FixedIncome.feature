#https://jira.pruconnect.net/browse/EISDEV-5948
#Architectue Requirement: https://collaborate.pruconnect.net/pages/viewpage.action?pageId=41968145
#Price Functional specification : https://collaborate.pruconnect.net/display/EISTT/TBMA%7CUpload+FI+Price+and+Publish+to+BRS#businessRequirements-1328663913
#Rating Functional specification : https://collaborate.pruconnect.net/pages/viewpage.action?spaceKey=EISTT&title=TBMA%7CUpload+TRIS+Ratings+and+Publish+to+BRS#businessRequirements-1328663913

@gc_interface_securities
@dmp_regression_integrationtest
@eisdev_5948 @001_price_rating_th_fixed_income @dmp_thailand_price @dmp_thailand
Feature: TBMA-TRIS Price and Rating data load into DMP

  The purpose of this interface is to get TRIS Ratings and price data from TBMA (Thai Bond Market Association) and load into DMP.
  The prices and ratings data both will come in a single file.
  DMP will use the Local Thai ID to look up the security and retrieve instrument number and load into Price,
  Rating and Rating Qualifiers tables.


  Scenario: TC1: Initialize variables and Deactivate Existing test maintain clean state before executing tests

    Given I assign "tests/test-data/dmp-interfaces/Thailand/Price/Inbound/testdata" to variable "testdata.path"

    #Security related variable
    And I assign "001_Th.Aldn-23_TBMA_DMP_Security_TH_FixedIncome.xml" to variable "SECURITY_INPUT_FILENAME"
    And I extract value from the xml file "${testdata.path}/${SECURITY_INPUT_FILENAME}" with tagName "CUSIP" to variable "BCUSIP"
    And I extract value from the xml file "${testdata.path}/${SECURITY_INPUT_FILENAME}" with xpath "//CUSIP_ALIAS_set//PURPOSE[text()='THAIID']/../IDENTIFIER" to variable "TH_Thai_ID_New"

    #TBMA TRIS related variable
    And I assign "001_Th.Aldn-23_TBMA_DMP_Price_Rating_TH_FixedIncome.xml" to variable "TRIS_SOURCE_INPUT_FILENAME"
    And I assign "001_Th.Aldn-23_TBMA_DMP_Price_Rating_TH_FixedIncome_DateChange_NoRatingChange.xml" to variable "TRIS_SOURCE_INPUT_FILENAME_CHANGEDATE_NORATINGCHAGE"
    And I assign "001_Th.Aldn-23_TBMA_DMP_Price_Rating_TH_FixedIncome.xml" to variable "TRIS_SOURCE_INPUT_FILENAME_CHANGEDATE_RATINGCHAGE"
    And I extract value from the xml file "${testdata.path}/${TRIS_SOURCE_INPUT_FILENAME}" with tagName "Clean_Price" to variable "FILE_TRIS_PRICE"
    And I extract value from the xml file "${testdata.path}/${TRIS_SOURCE_INPUT_FILENAME}" with tagName "TRIS" to variable "FILE_TRIS_RATING"
    And I extract value from the xml file "${testdata.path}/${TRIS_SOURCE_INPUT_FILENAME}" with tagName "asof" to variable "FILE_AS_OF"

    # End date existing ISIDs to ensure new security created
    And I set end_tms to SYSDATE in database "dmp.db.GC" where iss_id in "'${BCUSIP}'"

  Scenario: TC2: Load Security Master F10 file with <CODE>60030<CODE> & <PURPOSE>THAIID</PURPOSE> labels because it is prerequisite for TBMA load

    Given I copy files below from local folder "${testdata.path}" to the host "dmp.ssh.inbound" folder "${dmp.ssh.inbound.path}":
      | ${SECURITY_INPUT_FILENAME} |

    When I process files with below parameters and wait for the job to be completed
      | BUSINESS_FEED |                            |
      | FILE_PATTERN  | ${SECURITY_INPUT_FILENAME} |
      | MESSAGE_TYPE  | EIS_MT_BRS_SECURITY_NEW    |

    Then I expect workflow is processed in DMP with total record count as "1"

  Scenario: TC3: Check if Security Thai ID is created in database

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

  Scenario: TC4: Load TBMA-TRIS Source input file which include Price and Rating

    Given I copy files below from local folder "${testdata.path}" to the host "dmp.ssh.inbound" folder "${dmp.ssh.inbound.path}":
      | ${TRIS_SOURCE_INPUT_FILENAME} |

    When I process files with below parameters and wait for the job to be completed
      | BUSINESS_FEED |                               |
      | FILE_PATTERN  | ${TRIS_SOURCE_INPUT_FILENAME} |
      | MESSAGE_TYPE  | EITH_MT_TBMA_SECURITY         |

    Then I expect workflow is processed in DMP with total record count as "1"

  Scenario: TC5: Check if Price record is created in the FT_T_ISPC table with TRIS_PRICE = Clean_price from TBMA file

    Then I expect value of column "TRIS_PRICE" in the below SQL query equals to "${FILE_TRIS_PRICE}":
    """
    SELECT unit_cprc as TRIS_PRICE ,MAX(adjst_tms) as ADJST_TMS
	FROM   ft_t_ispc
	WHERE  prcng_meth_typ='ESITHA'
	AND    instr_id IN (SELECT instr_id
						FROM   ft_t_isid
						WHERE  id_ctxt_typ = 'BCUSIP'
						AND    iss_id = '${BCUSIP}'
						AND    end_tms IS NULL)
    GROUP BY unit_cprc
    """

  Scenario: TC6: Check if Rating record is created in the FT_T_ISRT table with the TRIS value in TBMA file

    Then I expect value of column "TRIS_RATING" in the below SQL query equals to "${FILE_TRIS_RATING}":
    """
    SELECT rtng_symbol_txt||'*' AS TRIS_RATING
	FROM   ft_t_isrt
	WHERE  end_tms IS NULL
    AND    sys_eff_end_tms IS NULL
    AND    to_char(rtng_eff_tms,'dd/MM/yyyy')='${FILE_AS_OF}'
    AND    last_chg_usr_id='EITH_TBMA_DMP_SECURITY'
	AND    instr_id IN (SELECT instr_id
						FROM   ft_t_isid
						WHERE  id_ctxt_typ = 'BCUSIP'
						AND    iss_id = '${BCUSIP}'
						AND    end_tms IS NULL)
    """

  Scenario: TC7: Check if Rating Qualifer record or entry is created in the RTQL table

    Then I expect value of column "RATING_QUALIFIER" in the below SQL query equals to "SF INDICATOR":
    """
    SELECT rtng_qual_typ AS RATING_QUALIFIER
    FROM   ft_t_rtql
    WHERE  end_tms IS NULL
    AND    last_chg_usr_id='EITH_TBMA_DMP_SECURITY'
    AND    iss_rtng_oid IN (SELECT iss_rtng_oid
	                        FROM   ft_t_isrt
	                        WHERE  end_tms IS NULL
                            AND    sys_eff_end_tms IS NULL
                            AND    to_char(rtng_eff_tms,'dd/MM/yyyy')='${FILE_AS_OF}'
                            AND    last_chg_usr_id='EITH_TBMA_DMP_SECURITY'
                            AND    instr_id IN (SELECT instr_id
							                    FROM   ft_t_isid
							                    WHERE  id_ctxt_typ = 'BCUSIP'
							                    AND    iss_id = '${BCUSIP}'
							                    AND    end_tms IS NULL))
    """

  Scenario: TC8: Same TRIS rating with different effective date, should not create a new record in ISRT table for that security

    Given I copy files below from local folder "${testdata.path}" to the host "dmp.ssh.inbound" folder "${dmp.ssh.inbound.path}":
      | ${TRIS_SOURCE_INPUT_FILENAME_CHANGEDATE_NORATINGCHAGE} |

    When I process files with below parameters and wait for the job to be completed
      | BUSINESS_FEED |                                                        |
      | FILE_PATTERN  | ${TRIS_SOURCE_INPUT_FILENAME_CHANGEDATE_NORATINGCHAGE} |
      | MESSAGE_TYPE  | EITH_MT_TBMA_SECURITY                                  |

    Then I expect workflow is processed in DMP with total record count as "1"

    And I expect value of column "CURRENT_RECORD_COUNT" in the below SQL query equals to "1":
    """
    SELECT count(0) AS CURRENT_RECORD_COUNT
	FROM   ft_t_isrt
	WHERE  end_tms IS NULL
    AND    sys_eff_end_tms IS NULL
    AND    last_chg_usr_id='EITH_TBMA_DMP_SECURITY'
    AND    to_char(rtng_eff_tms,'dd/MM/yyyy')='${FILE_AS_OF}'
    AND    rtng_symbol_txt = REPLACE('${FILE_TRIS_RATING}','*','')
	AND    instr_id IN (SELECT instr_id
						FROM   ft_t_isid
						WHERE  id_ctxt_typ = 'BCUSIP'
						AND    iss_id = '${BCUSIP}'
						AND    end_tms IS NULL)
    """