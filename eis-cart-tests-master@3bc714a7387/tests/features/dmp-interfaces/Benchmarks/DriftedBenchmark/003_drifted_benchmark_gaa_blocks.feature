#https://jira.pruconnect.net/browse/EISDEV-6515

#EISDEV-6515 : Initial Version. As part of this ticket. Inbound changes are verified for GAA blocks
#EISDEV-6555 : As part of this ticket, publishing changes are verified for GAA blocks
#EISDEV-6574: Added DBM1 verification
#EISDEV-6586: Verifying change in relation type from Primary Benchmark to DRFTBNCH reflects in outbound
#EISDEV-6592: Mapping of Index Weight Changed from DESC to NAME. Updating data file.
#EISDEV-6596: Filter on GAA records not received from Index weights.
#EISDEV-6925: Publish Currency from Benchmark Base currency for benchmarks with DRFTBNCH relation
#EISDEV-7470: Publish BCUSIP at listing level
#EISDEV-7406: Change in clear data sql

@gc_interface_index_weights @gc_interface_risk_analytics @gc_interface_benchmark
@dmp_regression_integrationtest
@eisdev_6515 @eisdev_6555 @eisdev_6574 @eisdev_6592 @eisdev_6586 @eisdev_6596 @eisdev_6925 @eisdev_7470 @eisdev_7406

Feature: 003 | Drifted Benchmark | GAA Blocks

  GAA Blocks benchmarks are set p through 2 files. Index_weights which consists of benchmark and AA security identifier with weights
  and esi_security_analytics_gaablocks which consists of BCUSIP to link the AA security identifier to and the other price/currency values.
  For this feature file, we will:
  1. Load the GAA blocks file to set up the AA security identifiers.
  2. Load Index weights to set up Benchmark Participant with weight for one of the securities
  3. Load GAA blocks file again to set up the prices for security with benchmark.
  One record in GAA blocks will be filtered as it is not present in Index weights.

  Scenario: TC_1:Prerequisites

    Given I assign "tests/test-data/dmp-interfaces/Benchmarks/DriftedBenchmarkGAABlock" to variable "testdata.path"
    And I assign "esi_security_analytics_gaablocks_test.xml" to variable "INPUTFILE_NAME1_TEMPLATE"
    And I assign "index_weights_test.xml" to variable "INPUTFILE_NAME2_TEMPLATE"
    And I generate value with date format "YYYYMMdd" and assign to variable "VAR_SYSDATE"
    And I assign "esi_security_analytics_gaablocks.xml" to variable "INPUTFILE_NAME1"
    And I assign "index_weights.xml" to variable "INPUTFILE_NAME2"
    And I modify date "${VAR_SYSDATE}" with "-1d" from source format "YYYYMMdd" to destination format "MM/dd/YYYY" and assign to "DYNAMIC_DATE"
    And I create input file "${INPUTFILE_NAME1}" using template "${INPUTFILE_NAME1_TEMPLATE}" from location "${testdata.path}/InputFiles"
    And I create input file "${INPUTFILE_NAME2}" using template "${INPUTFILE_NAME2_TEMPLATE}" from location "${testdata.path}/InputFiles"

    And I execute below query to "Clear existing data for clean data setup"
    """
    ${testdata.path}/sql/ClearDataAndSetup.sql
    """

  Scenario: TC_2: Load Index Weights file for preprocessing and setting up BNCM

    When I process "${testdata.path}/InputFiles/testdata/${INPUTFILE_NAME2}" file with below parameters
      | FILE_PATTERN  | ${INPUTFILE_NAME2}                  |
      | MESSAGE_TYPE  | EIS_MT_BRS_INDEX_WEIGHTS_PREPROCESS |
      | BUSINESS_FEED |                                     |

    Then I expect workflow is processed in DMP with total record count as "2"
    And success record count as "2"

  Scenario: TC_3: 1st Load GAA BLOCKS file

    When I process "${testdata.path}/InputFiles/testdata/${INPUTFILE_NAME1}" file with below parameters
      | FILE_PATTERN  | ${INPUTFILE_NAME1}                        |
      | MESSAGE_TYPE  | EIS_MT_BRS_RISK_ANALYTICS_GAA_BLOCKS_ISSU |
      | BUSINESS_FEED |                                           |

    Then I expect workflow is processed in DMP with total record count as "2"
    And filtered record count as "1"

  Scenario: Verification of ISID & MIXR table for setup of identifiers AA_MOD_DERTEST and AA_MOD_DERTEST2

    Then I expect value of column "ISID_COUNT" in the below SQL query equals to "1":
      """
      SELECT COUNT(*) as ISID_COUNT
        FROM   FT_T_ISID BCUSIP, FT_T_ISID BRSBNCHISSUID
        WHERE  BCUSIP.INSTR_ID = BRSBNCHISSUID.INSTR_ID
        AND    BCUSIP.ISS_ID in ('BPM1AB5CP','SB4L60K40')
        AND    BRSBNCHISSUID.ID_CTXT_TYP IN ('BRSBNCHISSUID')
        AND    BRSBNCHISSUID.ISS_ID in ('AA_MOD_DERTEST','AA_MOD_DERTEST2')
        AND    BCUSIP.ID_CTXT_TYP IN ('BCUSIP')
        AND    BRSBNCHISSUID.END_TMS IS NULL
        AND    BCUSIP.END_TMS IS NULL
      """

    Then I expect value of column "MIXR_COUNT" in the below SQL query equals to "1":
      """
      SELECT COUNT(*) as MIXR_COUNT
        FROM   FT_T_ISID BRSBNCHISSUID, FT_T_MIXR MIXR
        WHERE  BRSBNCHISSUID.ID_CTXT_TYP = 'BRSBNCHISSUID'
        AND    BRSBNCHISSUID.ISS_ID in ('AA_MOD_DERTEST','AA_MOD_DERTEST2')
        AND    BRSBNCHISSUID.ISID_OID = MIXR.ISID_OID
        AND    BRSBNCHISSUID.END_TMS IS NULL
        AND    MIXR.END_TMS IS NULL
      """

  Scenario: TC_4: Load Index Weights file

    When I process "${testdata.path}/InputFiles/testdata/${INPUTFILE_NAME2}" file with below parameters
      | FILE_PATTERN  | ${INPUTFILE_NAME2}       |
      | MESSAGE_TYPE  | EIS_MT_BRS_INDEX_WEIGHTS |
      | BUSINESS_FEED |                          |
    Then I expect workflow is processed in DMP with total record count as "2"
    And success record count as "2"

  Scenario: Verification of BNPT, BNVL table for the AA_MOD_DERTEST with both benchmarks

    Then I expect value of column "BNPTBNVL_COUNT" in the below SQL query equals to "2":
      """
      SELECT count(*) AS BNPTBNVL_COUNT
      FROM   FT_T_BNPT BNPT, FT_T_ISID BRSBNCHISSUID, FT_T_BNVL BNVL, FT_T_BNID BNID
      WHERE  BNPT.INSTR_ID = BRSBNCHISSUID.INSTR_ID
      AND    BRSBNCHISSUID.ID_CTXT_TYP IN ('BRSBNCHISSUID')
      AND    BRSBNCHISSUID.ISS_ID in ('AA_MOD_DERTEST')
      AND    BRSBNCHISSUID.END_TMS IS NULL
      AND    BNPT.END_TMS IS NULL
      AND    BNPT.BNPT_OID=BNVL.BNPT_OID
      AND    BNVL.CLOSE_WGT_BMRK_CRTE in ('-0.21','0.35')
      AND    BNID.BNCHMRK_ID_CTXT_TYP='BRSBNCHID'
      AND    BNID.BNCHMRK_ID in ('MP_TESTDOP','SAA_TESTDOP')
      AND    BNID.END_TMS IS NULL
      AND    BNID.BNCH_OID=BNPT.PRNT_BNCH_OID
      AND    BNID.BNCH_OID=BNVL.BNCH_OID
      AND    BNVL. BNCHMRK_VAL_TMS = TO_DATE('${DYNAMIC_DATE}','MM/dd/YYYY')
      """

  Scenario: TC_5: Reload GAA BLOCKS file

    When I process "${testdata.path}/InputFiles/testdata/${INPUTFILE_NAME1}" file with below parameters
      | FILE_PATTERN  | ${INPUTFILE_NAME1}                        |
      | MESSAGE_TYPE  | EIS_MT_BRS_RISK_ANALYTICS_GAA_BLOCKS_BNCH |
      | BUSINESS_FEED |                                           |
    Then I expect workflow is processed in DMP with total record count as "2"
    And success record count as "1"
    And filtered record count as "1"

  Scenario: Verification of BNPT, BNVL, BNPS and BNVC table for the AA_MOD_DERTEST with both benchmarks

    Then I expect value of column "BNPTBNVL_COUNT" in the below SQL query equals to "2":
      """
      SELECT count(*) AS BNPTBNVL_COUNT
      FROM   FT_T_BNPT BNPT, FT_T_ISID BRSBNCHISSUID, FT_T_BNVL BNVL, FT_T_BNID BNID
      WHERE  BNPT.INSTR_ID = BRSBNCHISSUID.INSTR_ID
      AND    BRSBNCHISSUID.ID_CTXT_TYP IN ('BRSBNCHISSUID')
      AND    BRSBNCHISSUID.ISS_ID in ('AA_MOD_DERTEST')
      AND    BRSBNCHISSUID.END_TMS IS NULL
      AND    BNPT.END_TMS IS NULL
      AND    BNPT.BNPT_OID=BNVL.BNPT_OID
      AND    BNVL.CLOSE_WGT_BMRK_CRTE in ('-0.21','0.35')
      AND    BNID.BNCHMRK_ID_CTXT_TYP='BRSBNCHID'
      AND    BNID.BNCHMRK_ID in ('MP_TESTDOP','SAA_TESTDOP')
      AND    BNID.END_TMS IS NULL
      AND    BNID.BNCH_OID=BNPT.PRNT_BNCH_OID
      AND    BNID.BNCH_OID=BNVL.BNCH_OID
      AND    BNVL. BNCHMRK_VAL_TMS = TO_DATE('${DYNAMIC_DATE}','MM/dd/YYYY')
      AND    BNVL.BNCHMRK_VAL_CURR_CDE='USD'
      AND    BNVL.OPEN_MKT_CPTLZN_CAMT=44665.5
      AND    BNVL.CLOSE_CPRC=446.655
      """

  Scenario: Verification of DBM1 table for the AA_MOD_DERTEST with both benchmarks exception for sum(weights)!=100

    Then I expect value of column "EXCEPTION_COUNT" in the below SQL query equals to "2":
    """
    SELECT count(*) as EXCEPTION_COUNT FROM ft_v_dbm1 where benchmark_code in ('MP_TESTDOP','SAA_TESTDOP') and exception_comment like 'Sum%'
    """

  Scenario: Publish Drifted Benchmark and verify that output contains data for benchmark starting with SAA_ and MP_

    Given I assign "esi_bnp_drifted_bmk_weights" to variable "PUBLISHING_FILE_NAME"

    And I assign "/dmp/out/bnp/eod" to variable "PUBLISHING_DIR"

    And I remove below files with pattern in the host "dmp.ssh.inbound" from folder "${PUBLISHING_DIR}" if exists:
      | ${PUBLISHING_FILE_NAME}_*_1.csv |

    And I process publishing wrapper with below parameters and wait for the job to be completed
      | PUBLISHING_FILE_NAME | ${PUBLISHING_FILE_NAME}.csv           |
      | SUBSCRIPTION_NAME    | EIS_DMP_TO_BNP_DRIFTED_BM_WEIGHTS_SUB |

    Then I expect below files to be present in the host "dmp.ssh.inbound" into folder "${PUBLISHING_DIR}" after processing:
      | ${PUBLISHING_FILE_NAME}_${VAR_SYSDATE}_1.csv |

    Then I copy files below from remote folder "${PUBLISHING_DIR}" on host "dmp.ssh.inbound" into local folder "${testdata.path}/outfiles/runtime":
      | ${PUBLISHING_FILE_NAME}_${VAR_SYSDATE}_1.csv |

    Then I exclude below columns from CSV file while doing reconciliations
      | AS OF |

    And I expect each record in file "${testdata.path}/outfiles/reference/esi_bnp_drifted_bmk_weights_template.csv" should exist in file "${testdata.path}/outfiles/runtime/${PUBLISHING_FILE_NAME}_${VAR_SYSDATE}_1.csv" and exceptions to be written to "${testdata.path}/outfiles/004_3_exceptions_${recon.timestamp}.csv" file

  Scenario: Revert data setup

    And I execute below query to "Revert data setup for feature file"
    """
    update ft_t_bnch set BASE_CURR_CDE = 'USD' where bnch_oid in (select bnch_oid from ft_t_BNID where BNCHMRK_ID_CTXT_TYP='BRSBNCHID' and BNCHMRK_ID='SAA_TESTDOP' and end_tms is null);
    UPDATE FT_T_BNID SET bnchmrk_id='SNP500TD' where bnchmrk_id='MP_TESTDOP' and bnchmrk_id_ctxt_typ = 'BRSBNCHID' and end_tms is null;
    UPDATE FT_T_BNID SET bnchmrk_id='EMBIGIDRUS' where bnchmrk_id='SAA_TESTDOP' and bnchmrk_id_ctxt_typ = 'BRSBNCHID' and end_tms is null;
    COMMIT
    """
