# =====================================================================
# Date            JIRA        Comments
# ============    ========    ========
# 02/10/2018      TOM-3599    First Version
# 22/11/2018      TOM-3887    First Version
# =====================================================================

#https://collaborate.intranet.asia/pages/viewpage.action?pageId=45858641

@gc_interface_performance_returns
@dmp_regression_unittest
@tom_3559 @performance_returns_1m @performance_returns_1m_first_row_failed_with_ntel_log
Feature: BNP Performance Returns (1M), with first row failed with exception logged in NTEL. Column Header and Data should be published.

  Perform in-memory translation of BNP Performance Returns file and publish to BRS
  The first record in the input file is an in-valid (with exception raised in NTEL) record

  Only IBOR, TWRR, "Gross of all fees / wthdg taxes" records are processed, the rest are filtered out.
  Exceptions are raised when any of EntityName, ValueDate, Gross Return are empty.
  Exceptions are raised when any of IRPID, BRSFundID are missing in DMP for the given EntityName

  Sample Data Explained:-
  |Fund Code|EntityName       | ABOR / IBOR|Return_Source|Return_Type                    |ValueDate|1M Fund Gross Absolute Return|Test Case Comment                 |Expected Result         |
  |0        |AGPEFJ_TEST      | IBOR       |TWRR         |Gross of all fees / wthdg taxes|31/5/2018|-0.015542742                 |First Record failed with ntel log |Header Column published |
  |1        |PRU_FM_FI_PIF-HIG| IBOR       |TWRR         |Gross of all fees / wthdg taxes|31/5/2018|-0.015542742                 |Valid Values in all fields        |Published to BRS        |
  |2        |ANAMFF           | IBOR       |TWRR         |Gross of all fees / wthdg taxes|15/5/2018|-0.015542739                 |Fund Closed mid-mpnth             |Published to BRS        |
  |3        |                 | IBOR       |TWRR         |Gross of all fees / wthdg taxes|31/5/2018|-0.015542738                 |Missing EntityName                |Exception Logged in DMP |
  |4        |ABTHAB           |            |TWRR         |Gross of all fees / wthdg taxes|31/5/2018|-0.015542737                 |Missing A/IBOR                    |Skipped                 |
  |5        |ALSVAN           | IBOR       |             |Gross of all fees / wthdg taxes|31/5/2018|-0.015542741                 |Missing Return_Source             |Skipped                 |
  |6        |ABTHDB           | IBOR       |TWRR         |                               |31/5/2018|-0.015542736                 |Missing Return_Type               |Skipped                 |
  |7        |ABTSL_M          | IBOR       |TWRR         |Gross of all fees / wthdg taxes|         |-0.015542735                 |Missing ValueDate                 |Exception Logged in DMP |
  |8        |AGOBAB           | IBOR       |TWRR         |Gross of all fees / wthdg taxes|31/5/2018|                             |Missing Gross Return              |Exception Logged in DMP |
  |9        |AGOBOA           | ABOR       |TWRR         |Gross of all fees / wthdg taxes|31/5/2018|-0.015542733                 |Invalid Value                     |Skipped                 |
  |10       |ANAMDF           | IBOR       |NAV          |Gross of all fees / wthdg taxes|31/5/2018|-0.015542732                 |Invalid Value                     |Skipped                 |
  |11       |AGOSAB           | IBOR       |TWRR         |Gross                          |31/5/2018|-0.015542732                 |Invalid Value                     |Skipped                 |
  |12       |AGPEFJ_TEST      | IBOR       |TWRR         |Gross of all fees / wthdg taxes|31/5/2018|-0.015542731                 |Invalid IRPID                     |Exception Logged in DMP |
  |13       |AKEINS           | IBOR       |TWRR         |Gross of all fees / wthdg taxes|31/5/2018|-0.01554273                  |Missing BRSFUNDID for IRPID       |Exception Logged in DMP |

  Scenario: Clear the data as a Prerequisite

    Given I assign "ESI_FE_PerformanceReturns1M_FirstRowFailedValidation_20181001.csv" to variable "INPUT_FILENAME"
    And I assign "esi_brs_performance_returns" to variable "OUTPUT_FILENAME"
    And I assign "esi_brs_performance_returns_template.csv" to variable "MASTER_FILENAME"
    And I generate value with date format "YYYYMMdd" and assign to variable "VAR_SYSDATE"
    And I assign "/dmp/out/brs/irp" to variable "PUBLISHING_DIR"
    And I assign "tests/test-data/DevTest/TOM-3559" to variable "testdata.path"

    # Clear data for the given IRPID from ACID table
    And I execute below query
    """
    ${testdata.path}/sql/PerformanceReturns1M_ClearData.sql
    """

    # Delete the output file if it exist
    Given I remove below files in the host "dmp.ssh.inbound" from folder "${PUBLISHING_DIR}" if exists:
      | ${OUTPUT_FILENAME}_${VAR_SYSDATE}.csv |

    When I copy files below from local folder "${testdata.path}/testdata" to the host "dmp.ssh.inbound" folder "${dmp.ssh.inbound.path}":
      | ${INPUT_FILENAME} |

    # Transform BNP Performance Returns file to BRS format

    When I set the workflow template parameter "FILE" to "${dmp.ssh.inbound.path}/${INPUT_FILENAME}"
    And I set the workflow template parameter "MESSAGE_TYPE" to "EIS_MT_BNP_PERFORMANCE_RETURNS"

    When I send a web service request using template file "tests/test-data/intf-specs/gswf/template/EIS_StandardFileLoadTransformation/request.xmlt" and save the response to file "testout/evidence/gswf/resp/asyncResponse.xml"
    Then I extract a value from the XML file "testout/evidence/gswf/resp/asyncResponse.xml" using XPath query in file "tests/test-data/intf-specs/gswf/template/EIS_StandardFileLoadTransformation/flowResultIdQuery.xpath" to variable "flowResultId"

    Then I poll for maximum 20 seconds and expect the result of the SQL query below equals to "DONE":
      """
      SELECT WF_RUNTIME_STAT_TYP FROM FT_WF_WFRI WHERE INSTANCE_ID='${flowResultId}'
      """

   # Validation: If EntityName is missing, then error should be logged in NTEL
    Then I expect value of column "EXCEPTION_MSG_CHECK" in the below SQL query equals to "1":
    """
    SELECT COUNT(*) AS EXCEPTION_MSG_CHECK
    FROM ft_t_ntel ntel
      JOIN ft_t_trid trid
        ON ntel.last_chg_trn_id = trid.trn_id
    WHERE ntel.notfcn_stat_typ = 'OPEN'
    AND ntel.notfcn_id = '60001'
    AND ntel.source_id = 'TRANSLATION'
    AND ntel.msg_typ = 'EIS_MT_BNP_PERFORMANCE_RETURNS'
    AND ntel.main_entity_id_ctxt_typ = 'IRPID:ValueDate'
    AND ntel.main_entity_id LIKE ':%'
    AND ntel.parm_val_txt LIKE '%Cannot process BNP Performance Returns (1M) record as EntityName is missing in BNP file%'
    AND trid.job_id =
    (
      SELECT job_id
      FROM
      (
          SELECT job_id
          FROM ft_t_jblg
          WHERE job_stat_typ = 'CLOSED'
          AND job_msg_typ = 'EIS_MT_BNP_PERFORMANCE_RETURNS'
          AND trunc(job_start_tms) = trunc(sysdate)
          AND job_input_txt LIKE '%${INPUT_FILENAME}%'
          ORDER BY job_start_tms DESC
      )
      WHERE rownum = 1
    )
    """

    # Validation: If ValueDate is missing, then error should be logged in NTEL
    Then I expect value of column "EXCEPTION_MSG_CHECK" in the below SQL query equals to "1":
    """
    SELECT COUNT(*) AS EXCEPTION_MSG_CHECK
    FROM ft_t_ntel ntel
      JOIN ft_t_trid trid
        ON ntel.last_chg_trn_id = trid.trn_id
    WHERE ntel.notfcn_stat_typ = 'OPEN'
    AND ntel.notfcn_id = '60001'
    AND ntel.source_id = 'TRANSLATION'
    AND ntel.msg_typ = 'EIS_MT_BNP_PERFORMANCE_RETURNS'
    AND ntel.main_entity_id_ctxt_typ = 'IRPID:ValueDate'
    AND ntel.main_entity_id LIKE 'ABTSL_M:%'
    AND ntel.parm_val_txt LIKE '%Cannot process BNP Performance Returns (1M) record as Value Date is missing or invalid in BNP file%'
    AND trid.job_id =
    (
      SELECT job_id
      FROM
      (
          SELECT job_id
          FROM ft_t_jblg
          WHERE job_stat_typ = 'CLOSED'
          AND job_msg_typ = 'EIS_MT_BNP_PERFORMANCE_RETURNS'
          AND trunc(job_start_tms) = trunc(sysdate)
          AND job_input_txt LIKE '%${INPUT_FILENAME}%'
          ORDER BY job_start_tms DESC
      )
      WHERE rownum = 1
    )
    """

    # Validation: If Gross Return is missing, then error should be logged in NTEL
    Then I expect value of column "EXCEPTION_MSG_CHECK" in the below SQL query equals to "1":
    """
    SELECT COUNT(*) AS EXCEPTION_MSG_CHECK
    FROM ft_t_ntel ntel
      JOIN ft_t_trid trid
        ON ntel.last_chg_trn_id = trid.trn_id
    WHERE ntel.notfcn_stat_typ = 'OPEN'
    AND ntel.notfcn_id = '60001'
    AND ntel.source_id = 'TRANSLATION'
    AND ntel.msg_typ = 'EIS_MT_BNP_PERFORMANCE_RETURNS'
    AND ntel.main_entity_id_ctxt_typ = 'IRPID:ValueDate'
    AND ntel.main_entity_id LIKE 'AGOBAB:%'
    AND ntel.parm_val_txt LIKE '%Cannot process BNP Performance Returns (1M) record as Gross Absolute Return is missing in BNP file%'
    AND trid.job_id =
    (
      SELECT job_id
      FROM
      (
          SELECT job_id
          FROM ft_t_jblg
          WHERE job_stat_typ = 'CLOSED'
          AND job_msg_typ = 'EIS_MT_BNP_PERFORMANCE_RETURNS'
          AND trunc(job_start_tms) = trunc(sysdate)
          AND job_input_txt LIKE '%${INPUT_FILENAME}%'
          ORDER BY job_start_tms DESC
      )
      WHERE rownum = 1
    )
    """

    # Validation: If IRPID is missing, then error should be logged in NTEL
    Then I expect value of column "EXCEPTION_MSG_CHECK" in the below SQL query equals to "1":
    """
    SELECT COUNT(*) AS EXCEPTION_MSG_CHECK
    FROM ft_t_ntel ntel
      JOIN ft_t_trid trid
        ON ntel.last_chg_trn_id = trid.trn_id
    WHERE ntel.notfcn_stat_typ = 'OPEN'
    AND ntel.notfcn_id = '60001'
    AND ntel.source_id = 'TRANSLATION'
    AND ntel.msg_typ = 'EIS_MT_BNP_PERFORMANCE_RETURNS'
    AND ntel.main_entity_id_ctxt_typ = 'IRPID:ValueDate'
    AND ntel.main_entity_id LIKE 'AGPEFJ_TEST:%'
    AND ntel.parm_val_txt LIKE '%Cannot process BNP Performance Returns (1M) record as IRPID is missing in DMP%'
    AND trid.job_id =
    (
      SELECT job_id
      FROM
      (
          SELECT job_id
          FROM ft_t_jblg
          WHERE job_stat_typ = 'CLOSED'
          AND job_msg_typ = 'EIS_MT_BNP_PERFORMANCE_RETURNS'
          AND trunc(job_start_tms) = trunc(sysdate)
          AND job_input_txt LIKE '%${INPUT_FILENAME}%'
          ORDER BY job_start_tms DESC
      )
      WHERE rownum = 1
    )
    """

    # Validation: If BRSFUNDID is missing, then error should be logged in NTEL
    Then I expect value of column "EXCEPTION_MSG_CHECK" in the below SQL query equals to "1":
    """
    SELECT COUNT(*) AS EXCEPTION_MSG_CHECK
    FROM ft_t_ntel ntel
      JOIN ft_t_trid trid
        ON ntel.last_chg_trn_id = trid.trn_id
    WHERE ntel.notfcn_stat_typ = 'OPEN'
    AND ntel.notfcn_id = '60001'
    AND ntel.source_id = 'TRANSLATION'
    AND ntel.msg_typ = 'EIS_MT_BNP_PERFORMANCE_RETURNS'
    AND ntel.main_entity_id_ctxt_typ = 'IRPID:ValueDate'
    AND ntel.main_entity_id LIKE 'AKEINS:%'
    AND ntel.parm_val_txt LIKE '%Cannot process BNP Performance Returns (1M) record as BRSFUNDID is missing in DMP%'
    AND trid.job_id =
    (
      SELECT job_id
      FROM
      (
          SELECT job_id
          FROM ft_t_jblg
          WHERE job_stat_typ = 'CLOSED'
          AND job_msg_typ = 'EIS_MT_BNP_PERFORMANCE_RETURNS'
          AND trunc(job_start_tms) = trunc(sysdate)
          AND job_input_txt LIKE '%${INPUT_FILENAME}%'
          ORDER BY job_start_tms DESC
      )
      WHERE rownum = 1
    )
    """

    Then I expect below files to be present in the host "dmp.ssh.inbound" into folder "${PUBLISHING_DIR}" after processing:
      | ${OUTPUT_FILENAME}_${VAR_SYSDATE}.csv |

    Then I copy files below from remote folder "${PUBLISHING_DIR}" on host "dmp.ssh.inbound" into local folder "${testdata.path}/outfiles":
      | ${OUTPUT_FILENAME}_${VAR_SYSDATE}.csv |

    #Reconcile output file with the standard template file
    And I expect reconciliation between generated CSV file "${testdata.path}/outfiles/${OUTPUT_FILENAME}_${VAR_SYSDATE}.csv" and reference CSV file "${testdata.path}/template/${MASTER_FILENAME}" should be successful and exceptions to be written to "${TESTDATA_PATH}/outfiles/exceptions_${recon.timestamp}.csv" file
