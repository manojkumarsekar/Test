# ==============================================================================
# Date            JIRA        Comments
# ============    ========    ========
# 30/01/2019      TOM-3011    First Version
# This feature file is to test im memory translation of sentiment file from BAML
# ==============================================================================

@gc_interface_sentiment
@dmp_regression_unittest
@tom_3011 @dmp_gs_upgrade
Feature: Sentiment In-memory Translation Validations

  Scenario: Translating sentiment file

    Given I assign "JapanContendersRankSentimentValidations.csv" to variable "INPUT_FILENAME"
    And I assign "galileo_ESISG_Japan_sentiment" to variable "OUTPUT_FILENAME"
    And I assign "galileo_ESISG_Japan_sentiment_template_validations.csv" to variable "MASTER_FILENAME"
    And I generate value with date format "YYYYMMdd" and assign to variable "VAR_SYSDATE"
    And I assign "/dmp/out/brs/eod" to variable "PUBLISHING_DIR"
    And I assign "tests/test-data/DevTest/TOM-3011" to variable "testdata.path"

    # Delete the output file if it exist
    Given I remove below files in the host "dmp.ssh.inbound" from folder "${PUBLISHING_DIR}" if exists:
      | ${OUTPUT_FILENAME}_${VAR_SYSDATE}.csv |

    When I copy files below from local folder "${testdata.path}/infiles" to the host "dmp.ssh.inbound" folder "${dmp.ssh.inbound.path}":
      | ${INPUT_FILENAME} |

    # Transform BNP Performance Returns file to BRS format
    When I set the workflow template parameter "FILE" to "${dmp.ssh.inbound.path}/${INPUT_FILENAME}"
    And I set the workflow template parameter "MESSAGE_TYPE" to "EIS_MT_BAML_SENTIMENT"

    When I send a web service request using template file "tests/test-data/intf-specs/gswf/template/EIS_StandardFileLoadTransformation/request.xmlt" and save the response to file "testout/evidence/gswf/resp/asyncResponse.xml"
    Then I extract a value from the XML file "testout/evidence/gswf/resp/asyncResponse.xml" using XPath query in file "tests/test-data/intf-specs/gswf/template/EIS_StandardFileLoadTransformation/flowResultIdQuery.xpath" to variable "flowResultId"

    Then I poll for maximum 120 seconds and expect the result of the SQL query below equals to "DONE":
      """
      SELECT WF_RUNTIME_STAT_TYP FROM FT_WF_WFRI WHERE INSTANCE_ID='${flowResultId}'
      """

    Then I execute below query and extract values of "JOB_ID" into same variables
      """
      SELECT job_id AS JOB_ID FROM
      (
        SELECT job_id
        FROM ft_t_jblg
        WHERE job_stat_typ = 'CLOSED'
        AND job_msg_typ = 'EIS_MT_BAML_SENTIMENT'
        AND trunc(job_start_tms) = trunc(sysdate)
        AND job_input_txt LIKE '%${INPUT_FILENAME}%'
        ORDER BY job_start_tms DESC
      )
      WHERE rownum = 1
      """

    Then I expect below files to be present in the host "dmp.ssh.inbound" into folder "${PUBLISHING_DIR}" after processing:
      | ${OUTPUT_FILENAME}_${VAR_SYSDATE}.csv |

    Then I copy files below from remote folder "${PUBLISHING_DIR}" on host "dmp.ssh.inbound" into local folder "${testdata.path}/outfiles":
      | ${OUTPUT_FILENAME}_${VAR_SYSDATE}.csv |

  Scenario: SEDOL validation

    # If Sedol is missing, then error should be logged in NTEL
    Then I expect value of column "SEDOL_BLN_EXCEPTION_CHECK" in the below SQL query equals to "1":
    """
    SELECT COUNT(*) AS SEDOL_BLN_EXCEPTION_CHECK
    FROM ft_t_ntel ntel
      JOIN ft_t_trid trid
        ON ntel.last_chg_trn_id = trid.trn_id
    WHERE ntel.notfcn_stat_typ = 'OPEN'
    AND ntel.notfcn_id = '60001'
    AND ntel.source_id = 'TRANSLATION'
    AND ntel.msg_typ = 'EIS_MT_BAML_SENTIMENT'
    AND ntel.main_entity_id_ctxt_typ = 'SEDOL'
    AND ntel.main_entity_id IS NULL
    AND ntel.parm_val_txt LIKE '%Cannot process the record as 7-Digit Sedol is blank%'
    AND trid.job_id = '${JOB_ID}'
    """

  Scenario: Quality validation

    # Validation: If Quality is missing, then error should be logged in NTEL
    Then I expect value of column "QTY_BLN_EXCEPTION_CHECK" in the below SQL query equals to "1":
    """
    SELECT COUNT(*) AS QTY_BLN_EXCEPTION_CHECK
    FROM ft_t_ntel ntel
      JOIN ft_t_trid trid
        ON ntel.last_chg_trn_id = trid.trn_id
    WHERE ntel.notfcn_stat_typ = 'OPEN'
    AND ntel.notfcn_id = '60001'
    AND ntel.source_id = 'TRANSLATION'
    AND ntel.msg_typ = 'EIS_MT_BAML_SENTIMENT'
    AND ntel.main_entity_id_ctxt_typ = 'SEDOL'
    AND ntel.main_entity_id IS NOT NULL
    AND ntel.parm_val_txt LIKE '%Cannot process the record as Quality is blank%'
    AND trid.job_id = '${JOB_ID}'
    """

    # Validation: If the value in the Quality could not be translated, then error should be logged in NTEL
    Then I expect value of column "QTY_TRN_EXCEPTION_CHECK" in the below SQL query equals to "1":
    """
    SELECT COUNT(*) AS QTY_TRN_EXCEPTION_CHECK
    FROM ft_t_ntel ntel
      JOIN ft_t_trid trid
        ON ntel.last_chg_trn_id = trid.trn_id
    WHERE ntel.notfcn_stat_typ = 'OPEN'
    AND ntel.notfcn_id = '60001'
    AND ntel.source_id = 'TRANSLATION'
    AND ntel.msg_typ = 'EIS_MT_BAML_SENTIMENT'
    AND ntel.main_entity_id_ctxt_typ = 'SEDOL'
    AND ntel.main_entity_id IS NOT NULL
    AND ntel.parm_val_txt LIKE '%Cannot process the record as value XX in the Quality column cannot be translated%'
    AND trid.job_id = '${JOB_ID}'
    """

  Scenario: Sentiment validation

    # Validation: If Sentiment is missing, then error should be logged in NTEL
    Then I expect value of column "SENT_BLN_EXCEPTION_CHECK" in the below SQL query equals to "1":
    """
    SELECT COUNT(*) AS SENT_BLN_EXCEPTION_CHECK
    FROM ft_t_ntel ntel
      JOIN ft_t_trid trid
        ON ntel.last_chg_trn_id = trid.trn_id
    WHERE ntel.notfcn_stat_typ = 'OPEN'
    AND ntel.notfcn_id = '60001'
    AND ntel.source_id = 'TRANSLATION'
    AND ntel.msg_typ = 'EIS_MT_BAML_SENTIMENT'
    AND ntel.main_entity_id_ctxt_typ = 'SEDOL'
    AND ntel.main_entity_id IS NOT NULL
    AND ntel.parm_val_txt LIKE '%Cannot process the record as Sentiment is blank%'
    AND trid.job_id = '${JOB_ID}'
    """

    # Validation: If the value in the Sentiment could not be translated, then error should be logged in NTEL
    Then I expect value of column "SENT_TRN_EXCEPTION_CHECK" in the below SQL query equals to "1":
    """
    SELECT COUNT(*) AS SENT_TRN_EXCEPTION_CHECK
    FROM ft_t_ntel ntel
      JOIN ft_t_trid trid
        ON ntel.last_chg_trn_id = trid.trn_id
    WHERE ntel.notfcn_stat_typ = 'OPEN'
    AND ntel.notfcn_id = '60001'
    AND ntel.source_id = 'TRANSLATION'
    AND ntel.msg_typ = 'EIS_MT_BAML_SENTIMENT'
    AND ntel.main_entity_id_ctxt_typ = 'SEDOL'
    AND ntel.main_entity_id IS NOT NULL
    AND ntel.parm_val_txt LIKE '%Cannot process the record as value XX in the Sentiment column cannot be translated%'
    AND trid.job_id = '${JOB_ID}'
    """

  Scenario: Sentiment validation

    # Validation: If Sentiment Momentum  is missing, then error should be logged in NTEL
    Then I expect value of column "SENT_MOM_BLN_EXCEPTION_CHECK" in the below SQL query equals to "1":
    """
    SELECT COUNT(*) AS SENT_MOM_BLN_EXCEPTION_CHECK
    FROM ft_t_ntel ntel
      JOIN ft_t_trid trid
        ON ntel.last_chg_trn_id = trid.trn_id
    WHERE ntel.notfcn_stat_typ = 'OPEN'
    AND ntel.notfcn_id = '60001'
    AND ntel.source_id = 'TRANSLATION'
    AND ntel.msg_typ = 'EIS_MT_BAML_SENTIMENT'
    AND ntel.main_entity_id_ctxt_typ = 'SEDOL'
    AND ntel.main_entity_id IS NOT NULL
    AND ntel.parm_val_txt LIKE '%Cannot process the record as Sentiment Momentum is blank%'
    AND trid.job_id = '${JOB_ID}'
    """

    # Validation: If the value in the Sentiment Momentum could not be translated, then error should be logged in NTEL
    Then I expect value of column "SENT_MOM_TRN_EXCEPTION_CHECK" in the below SQL query equals to "1":
    """
    SELECT COUNT(*) AS SENT_MOM_TRN_EXCEPTION_CHECK
    FROM ft_t_ntel ntel
      JOIN ft_t_trid trid
        ON ntel.last_chg_trn_id = trid.trn_id
    WHERE ntel.notfcn_stat_typ = 'OPEN'
    AND ntel.notfcn_id = '60001'
    AND ntel.source_id = 'TRANSLATION'
    AND ntel.msg_typ = 'EIS_MT_BAML_SENTIMENT'
    AND ntel.main_entity_id_ctxt_typ = 'SEDOL'
    AND ntel.main_entity_id IS NOT NULL
    AND ntel.parm_val_txt LIKE '%Cannot process the record as value XX in the Sentiment Momentum column cannot be translated%'
    AND trid.job_id = '${JOB_ID}'
    """

    #Reconcile output file with the standard template file
    And I expect reconciliation between generated CSV file "${testdata.path}/outfiles/${OUTPUT_FILENAME}_${VAR_SYSDATE}.csv" and reference CSV file "${testdata.path}/outfiles/reference/${MASTER_FILENAME}" should be successful and exceptions to be written to "${testdata.path}/outfiles/exceptions_${recon.timestamp}.csv" file
