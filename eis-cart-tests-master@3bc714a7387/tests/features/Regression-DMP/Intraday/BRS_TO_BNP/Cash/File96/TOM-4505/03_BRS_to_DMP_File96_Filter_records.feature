# TOM-4505
# File96-1-2 : BRS to DMP file96 Interface
# Parent Ticket : https://jira.intranet.asia/browse/TOM-3437
# Current Ticket : https://jira.intranet.asia/browse/TOM-4505
# Requirement Link : https://collaborate.intranet.asia/display/TOM/Intraday+Flows%3A+Cash+Allocations

#below feature is added under ignore list because of existing issue. Once its resolved, we ll remove the @ignore tag
@gc_interface_cash
@dmp_regression_unittest
@ignore
@03_tom_4505_brs_dmp_f96
Feature: File96-1: File96 Interface Testing (BRS to DMP) - filtering criteria

  Below Scenarios are handled as part of this feature:
  1) Verify that the records should be processed if it is confirmed by itap and the account is part of 'SGLUKLNP' group
  2) Verify that the records should NOT be processed if it is confirmed by itap and the account is not the part of 'SGLUKLNP' group
  3) Verify that the records should be processed if it is not confirmed by itap

  Scenario: Load file 96 from BRS to DMP and Process the records confirmed by itap

    Given I assign "tests/test-data/Regression-DMP/Intraday/BRS_TO_BNP/Cash/File96/TOM-4505" to variable "testdata.path"
    And I assign "esi_newcash_filter_criteria_data.xml" to variable "INPUT_FILE_NAME"
    And I assign "esi_newcash_itap_filter_template.xml" to variable "INPUT_FILE_ITAP_FILTER_TEMPLATE"

    And I generate value with date format "mmss" and assign to variable "TIMESTAMP"

    #feching the potfolio name belongs to 'SGLUKLNP' account group
    And I execute below query and extract values of "PORTFOLIOS_PORTFOLIO_NAME1" into same variables
    """
    SELECT * FROM (SELECT ACCT_ALT_ID as PORTFOLIOS_PORTFOLIO_NAME1
    FROM FT_T_ACID
    INNER JOIN FT_T_ACGP
    ON FT_T_ACID.ACCT_ID =FT_T_ACGP.ACCT_ID
    WHERE PRNT_ACCT_GRP_OID=(SELECT ACCT_GRP_OID FROM FT_T_ACGR WHERE ACCT_GRP_ID='SGLUKLNP'))
    WHERE rownum <= 1
    """

    #feching the potfolio name does not belongs to 'SGLUKLNP' account group
    And I execute below query and extract values of "PORTFOLIOS_PORTFOLIO_NAME2" into same variables
    """
    SELECT * FROM (SELECT ACCT_ALT_ID as PORTFOLIOS_PORTFOLIO_NAME2
    FROM FT_T_ACID
    INNER JOIN FT_T_ACGP
    ON FT_T_ACID.ACCT_ID =FT_T_ACGP.ACCT_ID
    WHERE PRNT_ACCT_GRP_OID in (SELECT ACCT_GRP_OID FROM FT_T_ACGR WHERE ACCT_GRP_ID <> 'SGLUKLNP'))
    WHERE rownum <= 1
    """

    Given I create input file "${INPUT_FILE_NAME}" using template "${INPUT_FILE_ITAP_FILTER_TEMPLATE}" with below codes from location "${testdata.path}"
      | NEW_CASH_ID5  | ${TIMESTAMP}5 |
      | NEW_CASH_ID6  | ${TIMESTAMP}6 |
      | NEW_CASH_ID7  | ${TIMESTAMP}7 |
      | CONFIRMED_BY1 | itap          |
      | CONFIRMED_BY2 | Auto          |

    And I copy files below from local folder "${testdata.path}/testdata" to the host "dmp.ssh.inbound" folder "${dmp.ssh.inbound.path}":
      | ${INPUT_FILE_NAME} |

    When I process files with below parameters and wait for the job to be completed
      | BUSINESS_FEED |                             |
      | FILE_PATTERN  | ${INPUT_FILE_NAME}          |
      | MESSAGE_TYPE  | EIS_MT_BRS_CASHALLOC_FILE96 |

    Then I extract new job id from jblg table into a variable "JOB_ID"

    Then I expect value of column "SUCCESS_COUNT" in the below SQL query equals to "2":
    """
    SELECT TASK_SUCCESS_CNT AS SUCCESS_COUNT FROM FT_T_JBLG WHERE JOB_ID='${JOB_ID}'
    """

    Then I expect value of column "FILTERED_COUNT" in the below SQL query equals to "1":
     """
     SELECT TASK_FILTERED_CNT AS FILTERED_COUNT FROM FT_T_JBLG WHERE JOB_ID='${JOB_ID}'
     """

  Scenario: Validating that the record is processed when it is confirmed by itap and portfolio name belongs to "SGLUKLNP" account group

    Given I extract value from the xml file "${testdata.path}/testdata/${INPUT_FILE_NAME}" with xpath "//NEWCASH_ID" at index 0 to variable "NEWCASH_ID"

    Then I expect value of column "NEWCASH_ID" in the below SQL query equals to "PASS":
    """
    SELECT CASE WHEN COUNT(DISTINCT 1) = 1 THEN 'PASS' ELSE 'FAIL' END AS NEWCASH_ID
    FROM FT_T_EXTR EXTR
    INNER JOIN FT_T_ETID ETID
    ON ETID.EXEC_TRD_ID = EXTR.EXEC_TRD_ID
    INNER JOIN FT_T_ACID ACID
    ON ACID.ACCT_ID=EXTR.ACCT_ID
    WHERE ETID.EXEC_TRN_ID = REGEXP_SUBSTR('${NEWCASH_ID}','[^.]*')
    AND ACID.ACCT_ALT_ID ='${PORTFOLIOS_PORTFOLIO_NAME1}'
    AND ETID.EXEC_TRN_ID_CTXT_TYP = 'BRSTRNID'
    AND ACID.ACCT_ID_CTXT_TYP  in('ESPORTCDE ','ALTCRTSID ','CRTSID')
    """

  Scenario: Validating that the record is not processed when it is confirmed by itap and portfolio name does not belong to "SGLUKLNP" account group

    Given I extract value from the xml file "${testdata.path}/testdata/${INPUT_FILE_NAME}" with xpath "//NEWCASH_ID" at index 1 to variable "NEWCASH_ID"

    Then I expect value of column "NEWCASH_ID" in the below SQL query equals to "PASS":
    """
    SELECT CASE WHEN COUNT(DISTINCT 1) = 0 THEN 'PASS' ELSE 'FAIL' END AS NEWCASH_ID
    FROM FT_T_EXTR EXTR
    INNER JOIN FT_T_ETID ETID
    ON ETID.EXEC_TRD_ID = EXTR.EXEC_TRD_ID
    INNER JOIN FT_T_ACID ACID
    ON ACID.ACCT_ID=EXTR.ACCT_ID
    WHERE ETID.EXEC_TRN_ID = REGEXP_SUBSTR('${NEWCASH_ID}','[^.]*')
    AND ACID.ACCT_ALT_ID ='${PORTFOLIOS_PORTFOLIO_NAME2}'
    AND ETID.EXEC_TRN_ID_CTXT_TYP = 'BRSTRNID'
    AND ACID.ACCT_ID_CTXT_TYP  in('ESPORTCDE ','ALTCRTSID ','CRTSID')
    """

  Scenario: Validating that the record is processed when it is not confirmed by itap and portfolio name does not belong to "SGLUKLNP" account group

    Given I extract value from the xml file "${testdata.path}/testdata/${INPUT_FILE_NAME}" with xpath "//NEWCASH_ID" at index 2 to variable "NEWCASH_ID"

    Then I expect value of column "NEWCASH_ID" in the below SQL query equals to "PASS":
    """
    SELECT CASE WHEN COUNT(DISTINCT 1) = 1 THEN 'PASS' ELSE 'FAIL' END AS NEWCASH_ID
    FROM FT_T_EXTR EXTR
    INNER JOIN FT_T_ETID ETID
    ON ETID.EXEC_TRD_ID = EXTR.EXEC_TRD_ID
    INNER JOIN FT_T_ACID ACID
    ON ACID.ACCT_ID=EXTR.ACCT_ID
    WHERE ETID.EXEC_TRN_ID = REGEXP_SUBSTR('${NEWCASH_ID}','[^.]*')
    AND ACID.ACCT_ALT_ID ='${PORTFOLIOS_PORTFOLIO_NAME2}'
    AND ETID.EXEC_TRN_ID_CTXT_TYP = 'BRSTRNID'
    AND ACID.ACCT_ID_CTXT_TYP  in('ESPORTCDE ','ALTCRTSID ','CRTSID')
    """
