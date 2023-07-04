#https://collaborate.intranet.asia/display/TOMR4/R5.IN-CASH1+OCR-DMP+EOD+Cash+Statement
#https://jira.intranet.asia/browse/TOM-3390
#TOM-3390 : R5.IN-CASH1 OCR-DMP EOD Cash Statement
#TOM-4119 : Enclose field values with quotes, to mimic Kofax output
#TOM-4207 : Make SECDESC non-mandatory

@tom_3390 @dmp_interfaces @taiwan_dmp_interfaces @taiwan_cash_statement  @tom_4097 @tom_4119 @tom_4207
Feature: Loading Taiwan cash statement into DMP - validating file content

  1) Validate that missing andatory fields raise an exception
  2) Validate that security ID types are translated correctly and any invalid type raises an exception.
  3) Validate that an invalid statement date raises an exception.

  Scenario: TC_1: Clear old test data and setup variables

    Given I assign "tests/test-data/dmp-interfaces/Taiwan/CashStatement" to variable "testdata.path"
    And I assign "esi_TW_EODCash_2_template.csv" to variable "INPUT_TEMPLATE_FILENAME"
    And I assign "esi_TW_EODCash_2.csv" to variable "INPUT_FILENAME"

    And I execute below query and extract values of "SYSTEM_DATE" into same variables
      """
      SELECT TO_CHAR(SYSDATE,'DD/MM/YYYY') AS SYSTEM_DATE FROM DUAL
      """

    And I execute below query
    """
    DELETE ft_t_actr WHERE stmnt_dte >= TRUNC(SYSDATE) - 2
    """

    And I modify date "${SYSTEM_DATE}" with "-1d" from source format "dd/MM/yyyy" to destination format "yyyyMMdd" and assign to "SYSDATE_MINUS_1"
    And I modify date "${SYSTEM_DATE}" with "-10d" from source format "dd/MM/yyyy" to destination format "yyyyMMdd" and assign to "SYSDATE_MINUS_10"
    And I modify date "${SYSTEM_DATE}" with "+1d" from source format "dd/MM/yyyy" to destination format "yyyyMMdd" and assign to "SYSDATE_PLUS_1"

    And I create input file "${INPUT_FILENAME}" using template "${INPUT_TEMPLATE_FILENAME}" with below codes from location "${testdata.path}"
      |  |  |

  Scenario: TC_2: Load cash statement file

    Given I copy files below from local folder "${testdata.path}/testdata" to the host "dmp.ssh.inbound" folder "${dmp.ssh.inbound.path}":
      | ${INPUT_FILENAME} |

    When I process files with below parameters and wait for the job to be completed
      | BUSINESS_FEED |                              |
      | FILE_PATTERN  | ${INPUT_FILENAME}            |
      | MESSAGE_TYPE  | EIS_MT_TW_OCR_CASH_STATEMENT |

  Scenario: TC_3: Verify we have 4 rows successfully loaded

    Given I extract new job id from jblg table into a variable "JOB_ID"

    Then I expect value of column "JOB_RESULT" in the below SQL query equals to "5":
        """
        SELECT TO_CHAR(task_success_cnt) AS JOB_RESULT
        FROM   ft_t_jblg
        WHERE  job_id = '${JOB_ID}'
        """

  Scenario: TC_5: Validate that security ID types are translated correctly

    Then I expect value of column "LOAD_RESULT" in the below SQL query equals to "5":
    """
    SELECT COUNT(*) AS LOAD_RESULT
    FROM   (
            SELECT 'ISIN' FROM ft_t_actr WHERE stmnt_dte = TO_DATE('${SYSDATE_MINUS_1}','yyyymmdd') AND trn_iss_id_ctxt_typ = 'ISIN'
            UNION ALL
            SELECT 'SEDOL' FROM ft_t_actr WHERE stmnt_dte = TO_DATE('${SYSDATE_MINUS_1}','yyyymmdd') AND trn_iss_id_ctxt_typ = 'SEDOL'
            UNION ALL
            SELECT 'CUSIP' FROM ft_t_actr WHERE stmnt_dte = TO_DATE('${SYSDATE_MINUS_1}','yyyymmdd') AND trn_iss_id_ctxt_typ = 'CUSIP'
            UNION ALL
            SELECT 'OTHER' FROM ft_t_actr WHERE stmnt_dte = TO_DATE('${SYSDATE_MINUS_1}','yyyymmdd') AND trn_iss_id_ctxt_typ = 'OTHER'
           )
    """

  Scenario: TC_6: Validate that an invalid security ID type raises an exception

    Given I extract new job id from jblg table into a variable "JOB_ID"
    Then I expect value of column "FAILED_SEC_ID_TYPE_RECORDS" in the below SQL query equals to "1":
    """
    SELECT COUNT(*) AS FAILED_SEC_ID_TYPE_RECORDS
    FROM   ft_t_ntel ntel JOIN ft_t_trid trid ON (ntel.last_chg_trn_id = trid.trn_id)
    WHERE  trid.job_id = '${JOB_ID}'
    AND    trid.crrnt_severity_cde >= 40
    AND    ntel.notfcn_stat_typ = 'OPEN'
    AND    ntel.msg_typ = 'EIS_MT_TW_OCR_CASH_STATEMENT'
    AND    ntel.parm_val_txt LIKE '%Transaction Issue ID Context = YY%'
    """

  Scenario: TC_7: Validate that an invalid statement date raises an exception

    Given I extract new job id from jblg table into a variable "JOB_ID"
    Then I expect value of column "FAILED_STATEMENT_DATE_RECORDS" in the below SQL query equals to "3":
    """
    SELECT COUNT(*) AS FAILED_STATEMENT_DATE_RECORDS
    FROM   ft_t_ntel ntel JOIN ft_t_trid trid ON (ntel.last_chg_trn_id = trid.trn_id)
    WHERE  trid.job_id = '${JOB_ID}'
    AND    trid.crrnt_severity_cde >= 40
    AND    ntel.notfcn_stat_typ = 'OPEN'
    AND    ntel.msg_typ = 'EIS_MT_TW_OCR_CASH_STATEMENT'
    AND    ntel.parm_val_txt LIKE '%Cannot process the record as the statement date is either an invalid date or not within the last 7 days%'
    """

  Scenario: TC_7: Teardown test data
  
    Given I execute below query
    """
    DELETE ft_t_actr WHERE stmnt_dte >= TRUNC(SYSDATE) - 2
    """