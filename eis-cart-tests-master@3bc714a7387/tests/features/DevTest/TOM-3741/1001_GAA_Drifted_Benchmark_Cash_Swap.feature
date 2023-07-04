# =====================================================================
# Date            JIRA        Comments
# ============    ========    ========
# 18/10/2018      TOM-3741    First Version
# =====================================================================

#https://jira.intranet.asia/browse/TOM-3741

@gc_interface_risk_analytics
@dmp_regression_unittest
@tom_3741 @esi_drifted_benchmark_cash_swap
Feature: Load Risk Analytics Model file. CASH_SWAP security should be created, and relation should be created between BCUSIP and PARENT_BCUSIP
# =====================================================================
# Load a "esi_security_analytics_models.xml" file containing 1 record (BCUSIP "BPM1VCHRF")

#<ANALYTICS>
#  <INSTRUMENTS ASOF_DATE="10/11/2018" CREATE_DATE="10/11/2018" RECORDS="1">
#    <INSTRUMENT>
#      <SM_SEC_TYPE>SWAP</SM_SEC_TYPE>
#      <SM_SEC_GROUP>CASH</SM_SEC_GROUP>
#      <CUSIP>BPM1VCHRF</CUSIP>
#      <PARENT_CUSIP>BPM1VCHR0</PARENT_CUSIP>
#    </INSTRUMENT>
#  </INSTRUMENTS>
#</ANALYTICS>

# CASH_SWAP security should be created, and relation created between BCUSIP and PARENT_BCUSIP
# =====================================================================

  Scenario: Set Variables
    Given I assign "esi_security_analytics_models.xml" to variable "INPUT_FILENAME"
    And I assign "tests/test-data/DevTest/TOM-3741" to variable "testdata.path"

  Scenario: Load Risk Analytics Model file
    Given I copy files below from local folder "${testdata.path}/testdata" to the host "dmp.ssh.inbound" folder "${dmp.ssh.inbound.path}":
      | ${INPUT_FILENAME} |

    When I process files with below parameters and wait for the job to be completed
      | BUSINESS_FEED |                           |
      | FILE_PATTERN  | ${INPUT_FILENAME}         |
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

    # Validation: CASH_SWAP security should be created, and relation created between BCUSIP and PARENT_BCUSIP
    Then I expect value of column "CASH_SWAP_COUNT" in the below SQL query equals to "1":
    """
    SELECT COUNT(*) AS CASH_SWAP_COUNT FROM ft_t_ridf ridf
    JOIN ft_t_riss riss
        ON ridf.rld_iss_feat_id = riss.rld_iss_feat_id
    WHERE ridf.rel_typ = 'SWAP' -- relation type
    AND riss.iss_part_rl_typ = 'UNDLYING' -- relation
    AND ridf.end_tms IS NULL
    AND riss.end_tms IS NULL
    AND ridf.instr_id =
    (
        SELECT isid.instr_id
        FROM ft_t_issu issu
            JOIN ft_t_isid isid
                ON issu.instr_id = isid.instr_id
                    AND issu.end_tms IS NULL
                    AND isid.end_tms IS NULL
                    AND issu.iss_typ = 'SWAPRATE'
                    AND isid.id_ctxt_typ = 'BCUSIP'
                    AND isid.iss_id = 'BPM1VCHR0' -- parent
    )
    AND riss.instr_id =
    (
        SELECT isid.instr_id
        FROM ft_t_issu issu
            JOIN ft_t_isid isid
                ON issu.instr_id = isid.instr_id
                    AND issu.end_tms IS NULL
                    AND isid.end_tms IS NULL
                    AND issu.iss_typ = 'CASHSEC'    -- child issue type
                    AND isid.id_ctxt_typ = 'BCUSIP'
                    AND isid.iss_id = 'BPM1VCHRF' -- child
    )
    """



