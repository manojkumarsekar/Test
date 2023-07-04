#https://jira.intranet.asia/browse/TOM-2539
#https://jira.intranet.asia/browse/TOM-3496

@tom_3496 @dmp_securities_linking @1001_eis_rdm_eod_data_load
Feature: Loading RDM data to test BB,BBLOANID and LOANXID populate

  This fix is for the error occurred in production.

  If ID_CTXT_TYP = ‘LOANXID’ and ISS_ID starts with LX then update ID_CTXT_TYP to ‘MRKTLOANID’
  If ID_CTXT_TYP = ‘LOANXID’ and ISS_ID starts with BL then update ID_CTXT_TYP to ‘BBLOANID’

  Scenario: TC_1: Load files for RDM

    Given I assign "RDM_TC_01.csv" to variable "INPUT_FILENAME"
    And I assign "tests/test-data/DevTest/TOM-3496" to variable "testdata.path"

    And I extract below values for row 2 from CSV file "${INPUT_FILENAME}" in local folder "${testdata.path}" with reference to "CLIENT_ID" column and assign to variables:
      | LOANX_ID | BB |

    And I extract below values for row 3 from CSV file "${INPUT_FILENAME}" in local folder "${testdata.path}" with reference to "CLIENT_ID" column and assign to variables:
      | LOANX_ID | BBLOANID |

    And I extract below values for row 4 from CSV file "${INPUT_FILENAME}" in local folder "${testdata.path}" with reference to "CLIENT_ID" column and assign to variables:
      | LOANX_ID | LOANXID |

    Then I set end_tms to SYSDATE in database "dmp.db.VD" where iss_id in "'${BB}','${BBLOANID}','${LOANXID}'"
    Then I set end_tms to SYSDATE in database "dmp.db.GC" where iss_id in "'${BB}','${BBLOANID}','${LOANXID}'"

    When I copy files below from local folder "${testdata.path}" to the host "dmp.ssh.inbound" folder "${dmp.ssh.inbound.path}":
      | ${INPUT_FILENAME} |

    Given I process files with below parameters and wait for the job to be completed
      | BUSINESS_FEED |                     |
      | FILE_PATTERN  | ${INPUT_FILENAME}   |
      | MESSAGE_TYPE  | EIS_MT_RDM_SECURITY |

    Then I expect value of column "ID_COUNT_BB" in the below SQL query equals to "3":
      """
      SELECT COUNT(*) AS ID_COUNT_BB FROM FT_T_ISID
	  WHERE ISS_ID IN('${BB}','${BBLOANID}','${LOANXID}')
	  AND ID_CTXT_TYP IN ('BB','BBLOANID','LOANXID')
	  AND END_TMS IS NULL
      """

  Scenario: TC_2: Load files for RDM EOD

    Given I assign "RDM_EOD_TC_01.csv" to variable "INPUT_FILENAME"
    And I assign "tests/test-data/DevTest/TOM-3496" to variable "testdata.path"

    And I extract below values for row 2 from CSV file "${INPUT_FILENAME}" in local folder "${testdata.path}" with reference to "CLIENT_ID" column and assign to variables:
      | LOANX_ID | BB |

    And I extract below values for row 3 from CSV file "${INPUT_FILENAME}" in local folder "${testdata.path}" with reference to "CLIENT_ID" column and assign to variables:
      | LOANX_ID | BBLOANID |

    And I extract below values for row 4 from CSV file "${INPUT_FILENAME}" in local folder "${testdata.path}" with reference to "CLIENT_ID" column and assign to variables:
      | LOANX_ID | LOANXID |

    Then I set end_tms to SYSDATE in database "dmp.db.VD" where iss_id in "'${BB}','${BBLOANID}','${LOANXID}'"
    Then I set end_tms to SYSDATE in database "dmp.db.GC" where iss_id in "'${BB}','${BBLOANID}','${LOANXID}'"

    When I copy files below from local folder "${testdata.path}" to the host "dmp.ssh.inbound" folder "${dmp.ssh.inbound.path}":
      | ${INPUT_FILENAME} |

    Given I process files with below parameters and wait for the job to be completed
      | BUSINESS_FEED |                         |
      | FILE_PATTERN  | ${INPUT_FILENAME}       |
      | MESSAGE_TYPE  | EIS_MT_RDM_EOD_SECURITY |

    Then I expect value of column "ID_COUNT_BB" in the below SQL query equals to "3":
      """
      SELECT COUNT(*) AS ID_COUNT_BB FROM FT_T_ISID
	  WHERE ISS_ID IN('${BB}','${BBLOANID}','${LOANXID}')
	  AND ID_CTXT_TYP IN ('BB','BBLOANID','LOANXID')
	  AND END_TMS IS NULL
      """