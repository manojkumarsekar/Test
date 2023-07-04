#https://jira.intranet.asia/browse/TOM-2539
#https://jira.intranet.asia/browse/TOM-3496

@dmp_regression_unittest
@tom_3496 @dmp_securities_linking @1002_eis_bbg_data_load
Feature: Loading BBG data to test BB,BBLOANID and LOANXID populate

  This fix is for the error occurred in production.

  If ID_CTXT_TYP = ‘LOANXID’ and ISS_ID starts with LX then update ID_CTXT_TYP to ‘MRKTLOANID’
  If ID_CTXT_TYP = ‘LOANXID’ and ISS_ID starts with BL then update ID_CTXT_TYP to ‘BBLOANID’

  Scenario: Load files for BBG

    Given I assign "BBG_TC_02.csv" to variable "INPUT_FILENAME"
    And I assign "tests/test-data/DevTest/TOM-3496" to variable "testdata.path"

    Given I extract below values for row 1 from BBGPSV file "${INPUT_FILENAME}" in local folder "${testdata.path}" and assign to variables:
      | ID_BB | BBLOANID |

    Given I extract below values for row 2 from BBGPSV file "${INPUT_FILENAME}" in local folder "${testdata.path}" and assign to variables:
      | ID_BB | LOANXID |

    Given I extract below values for row 3 from BBGPSV file "${INPUT_FILENAME}" in local folder "${testdata.path}" and assign to variables:
      | ID_BB | BB |

    Given I assign below value to variable "MIXR_SQL"
    """
    delete fT_T_mixr 
    where isid_oid in (select isid_oid from ft_T_isid where iss_id in ('${BB}','${BBLOANID}','${LOANXID}')AND ID_CTXT_TYP IN ('BB','BBLOANID','LOANXID'))
    """

    And I assign below value to variable "ISID_SQL"
	"""
	delete FT_T_ISID
	WHERE ISS_ID IN ('${BB}','${BBLOANID}','${LOANXID}') AND ID_CTXT_TYP IN ('BB','BBLOANID','LOANXID') 
	"""

    Then I set the database connection to configuration "dmp.db.VD"
    And I execute below query
	"""
	${MIXR_SQL};
	${ISID_SQL};
	"""

    And I set the database connection to configuration "dmp.db.GC"
    And I execute below query
	"""
	${MIXR_SQL};
	${ISID_SQL};
	"""

    When I copy files below from local folder "${testdata.path}" to the host "dmp.ssh.inbound" folder "${dmp.ssh.inbound.path}":
      | ${INPUT_FILENAME} |

    Given I process files with below parameters and wait for the job to be completed
      | BUSINESS_FEED |                                  |
      | FILE_PATTERN  | ${INPUT_FILENAME}                |
      | MESSAGE_TYPE  | EIS_MT_BBG_SECURITY_PER_SECURITY |

    Then I expect value of column "ID_COUNT_BB" in the below SQL query equals to "3":
      """
      SELECT COUNT(*) AS ID_COUNT_BB FROM FT_T_ISID
	  WHERE ISS_ID IN('${BB}','${BBLOANID}','${LOANXID}')
	  AND ID_CTXT_TYP IN ('BB','BBLOANID','LOANXID')
	  AND END_TMS IS NULL
      """