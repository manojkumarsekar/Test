# =====================================================================
# Date            JIRA        Comments
# ============    ========    ========
# 22/11/2018      TOM-3887    First Version
# =====================================================================

#https://collaborate.intranet.asia/pages/viewpage.action?pageId=45858641

@gc_interface_performance_returns
@dmp_regression_unittest
@tom_3559 @performance_returns_1m @performance_returns_1m_ntel_log
Feature: NTEL exception logs should be retained. Ensure that they are not overwritten by subsequent loads

  Perform in-memory translation of BNP Performance Returns file and publish to BRS
  Two files are loaded in succession for two different months. e.g. May and Jun.
  Both files have record with same IRPID, but different ValueDate, and both records have exception.
  The exceptions of June should not overwrite the exceptions for May.

  Sample Data Explained:-

  File 1:-
  |Fund Code|EntityName       | ABOR / IBOR|Return_Source|Return_Type                    |ValueDate|1M Fund Gross Absolute Return|Test Case Comment                 |Expected Result         |
  |0        |AGPEFJ_TEST      | IBOR       |TWRR         |Gross of all fees / wthdg taxes|31/5/2018|-0.015542742                 |First Record failed with ntel log |NTEL Log is preserved   |
  |1        |PRU_FM_FI_PIF-HIG| IBOR       |TWRR         |Gross of all fees / wthdg taxes|31/5/2018|-0.015542742                 |Valid Values in all fields        |Published to BRS        |

  File 2:-
  |Fund Code|EntityName       | ABOR / IBOR|Return_Source|Return_Type                    |ValueDate|1M Fund Gross Absolute Return|Test Case Comment                 |Expected Result         |
  |0        |AGPEFJ_TEST      | IBOR       |TWRR         |Gross of all fees / wthdg taxes|30/6/2018|-0.015542742                 |First Record failed with ntel log |NTEL Log is preserved   |
  |1        |PRU_FM_FI_PIF-HIG| IBOR       |TWRR         |Gross of all fees / wthdg taxes|30/6/2018|-0.015542742                 |Valid Values in all fields        |Published to BRS        |


  Scenario: Clear the data as a Prerequisite

    Given I assign "ESI_FE_PerformanceReturns1M_20180531.csv" to variable "INPUT_FILENAME1"
    Given I assign "ESI_FE_PerformanceReturns1M_20180630.csv" to variable "INPUT_FILENAME2"
    And I assign "esi_brs_performance_returns" to variable "OUTPUT_FILENAME"
    And I generate value with date format "YYYYMMdd" and assign to variable "VAR_SYSDATE"
    And I assign "/dmp/out/brs/irp" to variable "PUBLISHING_DIR"
    And I assign "tests/test-data/DevTest/TOM-3559" to variable "testdata.path"

    # Clear data for the given IRPID from ACID table
    And I execute below query
    """
    ${testdata.path}/sql/PerformanceReturns1M_ClearData.sql
    """
    # Publish May month file
    # Delete the output file if it exist
    Given I remove below files in the host "dmp.ssh.inbound" from folder "${PUBLISHING_DIR}" if exists:
      | ${OUTPUT_FILENAME}_${VAR_SYSDATE}.csv |

    When I copy files below from local folder "${testdata.path}/testdata" to the host "dmp.ssh.inbound" folder "${dmp.ssh.inbound.path}":
      | ${INPUT_FILENAME1} |

    # Transform BNP Performance Returns file to BRS format

    When I set the workflow template parameter "FILE" to "${dmp.ssh.inbound.path}/${INPUT_FILENAME1}"
    And I set the workflow template parameter "MESSAGE_TYPE" to "EIS_MT_BNP_PERFORMANCE_RETURNS"

    When I send a web service request using template file "tests/test-data/intf-specs/gswf/template/EIS_StandardFileLoadTransformation/request.xmlt" and save the response to file "testout/evidence/gswf/resp/asyncResponse.xml"
    Then I extract a value from the XML file "testout/evidence/gswf/resp/asyncResponse.xml" using XPath query in file "tests/test-data/intf-specs/gswf/template/EIS_StandardFileLoadTransformation/flowResultIdQuery.xpath" to variable "flowResultId"

    Then I poll for maximum 20 seconds and expect the result of the SQL query below equals to "DONE":
      """
      SELECT WF_RUNTIME_STAT_TYP FROM FT_WF_WFRI WHERE INSTANCE_ID='${flowResultId}'
      """

    # Publish June month file
    # Delete the output file if it exist
    Given I remove below files in the host "dmp.ssh.inbound" from folder "${PUBLISHING_DIR}" if exists:
      | ${OUTPUT_FILENAME}_${VAR_SYSDATE}.csv |

    When I copy files below from local folder "${testdata.path}/testdata" to the host "dmp.ssh.inbound" folder "${dmp.ssh.inbound.path}":
      | ${INPUT_FILENAME2} |

    # Transform BNP Performance Returns file to BRS format

    When I set the workflow template parameter "FILE" to "${dmp.ssh.inbound.path}/${INPUT_FILENAME2}"
    And I set the workflow template parameter "MESSAGE_TYPE" to "EIS_MT_BNP_PERFORMANCE_RETURNS"

    When I send a web service request using template file "tests/test-data/intf-specs/gswf/template/EIS_StandardFileLoadTransformation/request.xmlt" and save the response to file "testout/evidence/gswf/resp/asyncResponse.xml"
    Then I extract a value from the XML file "testout/evidence/gswf/resp/asyncResponse.xml" using XPath query in file "tests/test-data/intf-specs/gswf/template/EIS_StandardFileLoadTransformation/flowResultIdQuery.xpath" to variable "flowResultId"

    Then I poll for maximum 20 seconds and expect the result of the SQL query below equals to "DONE":
      """
      SELECT WF_RUNTIME_STAT_TYP FROM FT_WF_WFRI WHERE INSTANCE_ID='${flowResultId}'
      """
      
   # Validation: If EntityName is missing for May file, then error should be logged in NTEL
    Then I expect value of column "FIRST_JOB_EXCEPTION_MSG_CHECK" in the below SQL query equals to "1":
    """
    SELECT COUNT(*) AS FIRST_JOB_EXCEPTION_MSG_CHECK
    FROM ft_t_ntel ntel
      JOIN ft_t_trid trid
        ON ntel.last_chg_trn_id = trid.trn_id
    WHERE trid.job_id =
    (
      SELECT job_id
      FROM
      (
          SELECT job_id
          FROM ft_t_jblg
          WHERE job_stat_typ = 'CLOSED'
          AND job_msg_typ = 'EIS_MT_BNP_PERFORMANCE_RETURNS'
          AND trunc(job_start_tms) = trunc(sysdate)
          AND job_input_txt LIKE '%${INPUT_FILENAME1}%'
          ORDER BY job_start_tms DESC
      )
      WHERE rownum = 1
    )
    AND ntel.notfcn_stat_typ = 'OPEN'
    AND ntel.notfcn_id = '60001'
    AND ntel.source_id = 'TRANSLATION'
    AND ntel.msg_typ = 'EIS_MT_BNP_PERFORMANCE_RETURNS'
    AND ntel.main_entity_id_ctxt_typ = 'IRPID:ValueDate'
    AND ntel.parm_val_txt LIKE '%Cannot process BNP Performance Returns (1M) record as IRPID is missing in DMP for EntityName%'
    """

   # Validation: If EntityName is missing for June file, then error should be logged in NTEL
    Then I expect value of column "SECOND_JOB_EXCEPTION_MSG_CHECK" in the below SQL query equals to "1":
    """
    SELECT COUNT(*) AS SECOND_JOB_EXCEPTION_MSG_CHECK
    FROM ft_t_ntel ntel
      JOIN ft_t_trid trid
        ON ntel.last_chg_trn_id = trid.trn_id
    WHERE trid.job_id =
    (
      SELECT job_id
      FROM
      (
          SELECT job_id
          FROM ft_t_jblg
          WHERE job_stat_typ = 'CLOSED'
          AND job_msg_typ = 'EIS_MT_BNP_PERFORMANCE_RETURNS'
          AND trunc(job_start_tms) = trunc(sysdate)
          AND job_input_txt LIKE '%${INPUT_FILENAME2}%'
          ORDER BY job_start_tms DESC
      )
      WHERE rownum = 1
    )
    AND ntel.notfcn_stat_typ = 'OPEN'
    AND ntel.notfcn_id = '60001'
    AND ntel.source_id = 'TRANSLATION'
    AND ntel.msg_typ = 'EIS_MT_BNP_PERFORMANCE_RETURNS'
    AND ntel.main_entity_id_ctxt_typ = 'IRPID:ValueDate'
    AND ntel.parm_val_txt LIKE '%Cannot process BNP Performance Returns (1M) record as IRPID is missing in DMP for EntityName%'
    """