#https://jira.intranet.asia/browse/TOM-3524
#https://collaborate.intranet.asia/pages/viewpage.action?pageId=45847009

@gc_interface_risk_analytics @gc_interface_factsheet_clsf
@dmp_regression_integrationtest
@tom_3524
Feature: COMPOSITEHK Ratings are currently stored incorrectly in ISCM instead of ISRT

  It is a fix for production defect
  Ratings in EIS_MT_BRS_RISK_ANALYTICS stored in-correct place.

  Load a file with two instrument ratings, both having COMP_HK_RATING as "alpha"
  These instrument COMP_HK_RATING rating should not get loaded into ISCM
  These ratings COMP_HK_RATINGs should get loaded into ISRT
  "alpha" should get defined in RTVL

  Load a file with two instrument ratings, after changing one of the COMP_HK_RATING (from alpha) to "beta"
  These instrument COMP_HK_RATING rating should not get loaded into ISCM
  One of the Two instruments with "alpha" should get updated into "beta" in ISRT
  "beta" should get defined into RTVL

  Publish Factsheet reports
  Factsheet report file should get published
  There should be one or more records in the Factsheet report file with INDUS_CLASS=Ratings and SHORT_DESC=COMPOSITEHK

  Scenario: TC_1: Clear the data as a Prerequisite

    Given I assign "risk_analytics_test_01.xml" to variable "INPUT_FILENAME1"
    And I assign "risk_analytics_test_02.xml" to variable "INPUT_FILENAME2"
    And I assign "tests/test-data/DevTest/TOM-3524" to variable "testdata.path"

    Given I execute below query to "Clear data for the given instruments from ISRT and RTVL, for ratings 'alpha' and 'beta'"
    """
    ${testdata.path}/sql/ClearData_TC1.sql
    """

  Scenario: TC_2: Load Risk Analytics files and Publish

     Load a file with two instrument, both having COMP_HK_RATING as "alpha"
     Should not get loaded into ISCM
     "alpha" should get loaded into RTVL
     Two instruments with "alpha" should get loaded into ISRT

    Given I copy files below from local folder "${testdata.path}/testdata" to the host "dmp.ssh.inbound" folder "${dmp.ssh.inbound.path}":
      | ${INPUT_FILENAME1} |
      | ${INPUT_FILENAME2} |

    When I process files with below parameters and wait for the job to be completed
      | BUSINESS_FEED |                           |
      | FILE_PATTERN  | ${INPUT_FILENAME1}        |
      | MESSAGE_TYPE  | EIS_MT_BRS_RISK_ANALYTICS |

    Then I extract new job id from jblg table into a variable "JOB_ID"

    # Validation: JBLG NTEL error logged
    Then I expect value of column "EXCEPTION_MSG1_CHECK" in the below SQL query equals to "0":
    """
    SELECT COUNT(*) AS EXCEPTION_MSG1_CHECK
    FROM ft_t_ntel ntel
        JOIN ft_t_trid trid
        ON ntel.last_chg_trn_id = trid.trn_id
    WHERE trid.job_id = '${JOB_ID}'
    AND ntel.msg_typ = 'EIS_MT_BRS_RISK_ANALYTICS'
    AND ntel.notfcn_stat_typ = 'OPEN'
    """

    Then I expect value of column "CMPHKRTG_COUNT" in the below SQL query equals to "0":
      """
      SELECT COUNT(*) AS CMPHKRTG_COUNT FROM ft_t_iscm iscm
      WHERE iscm.cmnt_reas_typ = 'COMPHKRTG'
      AND iscm.end_tms IS NULL
      AND iscm.last_chg_usr_id = 'EIS_BRS_DMP_RISK_ANALYTICS'
      """

    Then I expect value of column "RTVL_CMPHKRTG_ALPHA_COUNT" in the below SQL query equals to "1":
      """
      SELECT COUNT(*) AS RTVL_CMPHKRTG_ALPHA_COUNT  FROM ft_t_rtvl
      WHERE rtng_cde = 'alpha'
      AND rtng_set_oid = (SELECT rtng_set_oid FROM ft_t_rtng WHERE RTNG_SET_MNEM = 'CMPHKRTG' AND end_tms IS NULL)
      AND end_tms IS NULL
      """

    Then I expect value of column "ISRT_CMPHKRTG_ALPHA_COUNT" in the below SQL query equals to "2":
      """
      SELECT COUNT(*) AS ISRT_CMPHKRTG_ALPHA_COUNT FROM ft_t_isrt
      WHERE rtng_cde = 'alpha'
      AND rtng_set_oid = (SELECT rtng_set_oid FROM ft_t_rtng WHERE RTNG_SET_MNEM = 'CMPHKRTG' AND end_tms IS NULL)
      AND end_tms IS NULL
      """

    # =====================================================================
    # Load a same file again (with two instrument), change one of the COMP_HK_RATING to "beta"
    # Should not get loaded into ISCM
    # "beta" should get loaded into RTVL
    # One of the Two instruments with "alpha" should get changed into "beta" in ISRT
    # =====================================================================

    When I process files with below parameters and wait for the job to be completed
      | BUSINESS_FEED |                           |
      | FILE_PATTERN  | ${INPUT_FILENAME2}        |
      | MESSAGE_TYPE  | EIS_MT_BRS_RISK_ANALYTICS |

    Then I extract new job id from jblg table into a variable "JOB_ID"

    # Validation: JBLG NTEL error logged
    Then I expect value of column "EXCEPTION_MSG1_CHECK" in the below SQL query equals to "0":
    """
    SELECT COUNT(*) AS EXCEPTION_MSG1_CHECK
    FROM ft_t_ntel ntel
        JOIN ft_t_trid trid
        ON ntel.last_chg_trn_id = trid.trn_id
    WHERE trid.job_id = '${JOB_ID}'
    AND ntel.msg_typ = 'EIS_MT_BRS_RISK_ANALYTICS'
    AND ntel.notfcn_stat_typ = 'OPEN'
    """

    Then I expect value of column "CMPHKRTG_COUNT" in the below SQL query equals to "0":
      """
      SELECT COUNT(*) AS CMPHKRTG_COUNT FROM ft_t_iscm iscm
      WHERE iscm.cmnt_reas_typ = 'COMPHKRTG'
      AND iscm.end_tms IS NULL
      AND iscm.last_chg_usr_id = 'EIS_BRS_DMP_RISK_ANALYTICS'
      """

    Then I expect value of column "RTVL_CMPHKRTG_ALPHA_BETA_COUNT" in the below SQL query equals to "2":
      """
      SELECT COUNT(*) AS RTVL_CMPHKRTG_ALPHA_BETA_COUNT FROM ft_t_rtvl
      WHERE rtng_cde IN ('alpha', 'beta')
      AND rtng_set_oid IN
      (
          SELECT rtng_set_oid
          FROM ft_t_rtng
          WHERE rtng_set_mnem = 'CMPHKRTG'
          AND end_tms IS NULL
      )
      AND end_tms IS NULL
      """

    Then I expect value of column "ISRT_CMPHKRTG_ALPHA_BETA_COUNT" in the below SQL query equals to "2":
      """
      SELECT COUNT(*) AS ISRT_CMPHKRTG_ALPHA_BETA_COUNT  FROM ft_t_isrt
      WHERE rtng_cde IN ('alpha', 'beta')
      AND rtng_set_oid IN
      (
          SELECT rtng_set_oid
          FROM ft_t_rtng
          WHERE rtng_set_mnem = 'CMPHKRTG'
          AND end_tms IS NULL
      )
      AND instr_id IN
      (
          SELECT instr_id
          FROM ft_t_isid
          WHERE iss_id IN ('SB0LMTQ39', 'S67717207')
          AND id_ctxt_typ = 'BCUSIP'
          AND end_tms IS NULL
      )
      AND end_tms IS NULL
      """

    Then I expect value of column "ISRT_CMPHKRTG_ALPHA_END_COUNT" in the below SQL query equals to "1":
      """
      SELECT COUNT(*) AS ISRT_CMPHKRTG_ALPHA_END_COUNT FROM ft_t_isrt
      WHERE rtng_cde = 'alpha'
      AND rtng_set_oid IN
      (
          SELECT rtng_set_oid
          FROM ft_t_rtng
          WHERE rtng_set_mnem = 'CMPHKRTG'
          AND end_tms IS NULL
      )
      AND instr_id IN
      (
          SELECT instr_id
          FROM ft_t_isid
          WHERE iss_id IN ('SB0LMTQ39', 'S67717207')
          AND id_ctxt_typ = 'BCUSIP'
          AND end_tms IS NULL
      )
      AND end_tms IS NOT NULL
      """

    # =====================================================================
    # Publish Factsheet Report
    # Factsheet report file should get published
    # BCUSIP S67717207 should have COMPOSITEHK Ratings "alpha"
    # BCUSIP SB0LMTQ39 should have COMPOSITEHK Ratings "beta"
    # =====================================================================

    Given I assign "factsheet_automated_test" to variable "PUBLISHING_FILE_NAME"
    And I assign "/dmp/out/eis/factsheet" to variable "PUBLISHING_DIRECTORY"

    And I generate value with date format "YYYYMMdd" and assign to variable "VAR_SYSDATE"

    And I remove below files in the host "dmp.ssh.inbound" from folder "${PUBLISHING_DIRECTORY}" if exists:
      | ${PUBLISHING_FILE_NAME}_${VAR_SYSDATE}_1.csv |

    When I process publishing wrapper with below parameters and wait for the job to be completed
      | PUBLISHING_FILE_NAME | ${PUBLISHING_FILE_NAME}.csv                                                                                                                                      |
      | SUBSCRIPTION_NAME    | EIS_DMP_TO_MPS_FACTSHEET_CLSF_SUB                                                                                                                                |
      | SQL                  | &lt;sql&gt; instr_id IN (SELECT instr_id FROM ft_t_isid WHERE iss_id IN ('SB0LMTQ39', 'S67717207') AND id_ctxt_typ = 'BCUSIP' AND end_tms IS NULL ) &lt;/sql&gt; |

    Then I expect below files to be present in the host "dmp.ssh.inbound" into folder "${PUBLISHING_DIRECTORY}" after processing:
      | ${PUBLISHING_FILE_NAME}_${VAR_SYSDATE}_1.csv |

    Then I copy files below from remote folder "${PUBLISHING_DIRECTORY}" on host "dmp.ssh.inbound" into local folder "${testdata.path}/outfiles":
      | ${PUBLISHING_FILE_NAME}_${VAR_SYSDATE}_1.csv |

  Scenario: TC_3: Check if COMPOSITE_HK Rating is in the outbound

    Given I assign "${testdata.path}/outfiles/${PUBLISHING_FILE_NAME}_${VAR_SYSDATE}_1.csv" to variable "CSV_FILE"

    # BCUSIP S67717207 should have COMPOSITEHK Ratings "alpha"
    Given I expect column "INDUS_CLASS_CODE" value to be "alpha" where columns values are as below in CSV file "${CSV_FILE}"
      | CUSIP       | S67717207   |
      | SHORT_DESC  | COMPOSITEHK |
      | INDUS_CLASS | Ratings     |

    # BCUSIP SB0LMTQ39 should have COMPOSITEHK Ratings "beta"
    Given I expect column "INDUS_CLASS_CODE" value to be "beta" where columns values are as below in CSV file "${CSV_FILE}"
      | CUSIP       | SB0LMTQ39   |
      | SHORT_DESC  | COMPOSITEHK |
      | INDUS_CLASS | Ratings     |



