#EISDEV-6595 : Initial Version
#EISDEV-6950 : Changed verification to look for BNCH with Max CmntTms
#EISDEV-7406 : Changes as delete BNCM process is no longer used for filter and it is based on date of records.

@gc_interface_benchmark
@gc_interface_index_weights
@dmp_regression_unittest
@eisdev_6595 @eisdev_6950 @eisdev_7406

Feature: 004 | Drifted Benchmark | GAA Blocks | Pre-Processing and Filtering Index Weights
  The current process is effectively 4 steps

  1.	Create securities from BRS API response for GAA block BCUSIPS
  2.	Supplement the securities with the AA_ identifiers from the GAA blocks file
  3.	Load the index weights
  4.	Load the constituent prices

  In order to avoid the exceptions encountered in today’s initial loads we’re proposing the pre-processing of the index weights file

  1.	Create a list of AA_ identifiers from index weights file, for GAA, SAA and MP prefixed benchmarks
  2.	Create securities from BRS API response for GAA block BCUSIPS (for those AA_ identifiers from 1)
  3.	Supplement the securities with the AA_ identifiers from the GAA blocks file (for those AA_ identifiers from 1)
  4.	Load the index weights (for those AA_ identifiers from 1, or by applying the same filters for GAA, SAA and MP benchmarks)
  5.	Load the constituent prices (for those AA_ identifiers from 1)

  This Feature file is to test step 1 and 4

  Scenario: Prerequisites

    Given I assign "tests/test-data/dmp-interfaces/Benchmarks/DriftedBenchmarkGAABlock" to variable "testdata.path"
    And I assign "index_weights_preprocessandload_template.xml" to variable "INPUTFILE_NAME_TEMPLATE"
    And I generate value with date format "YYYYMMdd" and assign to variable "VAR_SYSDATE"
    And I assign "index_weights_preprocessandload.xml" to variable "INPUTFILE_NAME"
    And I modify date "${VAR_SYSDATE}" with "-1d" from source format "YYYYMMdd" to destination format "MM/dd/YYYY" and assign to "DYNAMIC_DATE"

  Scenario: Set up Test Benchmark

    And I execute below query to "Revert data setup for feature file"
    """
    UPDATE FT_T_BNID SET bnchmrk_id='MP_TESTFILTER' where bnchmrk_id='MSEXJPSGO' and bnchmrk_id_ctxt_typ = 'BRSBNCHID' and end_tms is null;
    UPDATE FT_T_BNID SET bnchmrk_id='SAA_TESTFILTER' where bnchmrk_id='MSASISCXJP' and bnchmrk_id_ctxt_typ = 'BRSBNCHID' and end_tms is null;
    COMMIT
    """

  Scenario: Execute Preprocess load

    Given I create input file "${INPUTFILE_NAME}" using template "${INPUTFILE_NAME_TEMPLATE}" from location "${testdata.path}/InputFiles"

    And I copy files below from local folder "${testdata.path}/InputFiles/testdata" to the host "dmp.ssh.inbound" folder "${dmp.ssh.inbound.path}":
      | ${INPUTFILE_NAME} |

    When I process "${testdata.path}/InputFiles/testdata/${INPUTFILE_NAME2}" file with below parameters
      | FILE_PATTERN  | ${INPUTFILE_NAME}        |
      | MESSAGE_TYPE  | EIS_MT_BRS_INDEX_WEIGHTS_PREPROCESS |
      | BUSINESS_FEED |                          |

    Then I expect workflow is processed in DMP with total record count as "3"

    And filtered record count as "1"

  Scenario: Verification of BenchMark Consituent of Interest in BNCM. AA_PRUUHYD is linked to MP_ASPRAB and SAA_ASPRAB both benchmarks

    Then I expect value of column "BNCHCNSTINT" in the below SQL query equals to "5":
      """
      select count(*) as BNCHCNSTINT from ft_t_bncm
      where CMNT_REAS_TYP = 'BNCHCNSTINT'
      and CMNT_TXT in ('AA_TOPIX','AA_HUC0USD','AA_PRUUHYD','AA_PPJEQ')
      and CMNT_TMS = TO_DATE('${DYNAMIC_DATE}','MM/DD/YYYY')
      and BNCH_OID in (SELECT BNCH_OID FROM FT_T_BNID WHERE BNCHMRK_ID IN ('MP_TESTFILTER','SAA_TESTFILTER') AND END_TMS IS NULL)
      """

  Scenario: Load Index Weights file and Benchmark ASPBFSCOMF is Filtered

    And I copy files below from local folder "${testdata.path}/InputFiles/testdata" to the host "dmp.ssh.inbound" folder "${dmp.ssh.inbound.path}":
      | ${INPUTFILE_NAME} |

    When I process "${testdata.path}/InputFiles/testdata/${INPUTFILE_NAME2}" file with below parameters
      | FILE_PATTERN  | ${INPUTFILE_NAME}        |
      | MESSAGE_TYPE  | EIS_MT_BRS_INDEX_WEIGHTS |
      | BUSINESS_FEED |                          |

    Then I expect workflow is processed in DMP with total record count as "3"

    And filtered record count as "1"

  Scenario: Revert data setup

    And I execute below query to "Revert data setup for feature file"
    """
    UPDATE FT_T_BNID SET bnchmrk_id='MSEXJPSGO' where bnchmrk_id='MP_TESTFILTER' and bnchmrk_id_ctxt_typ = 'BRSBNCHID' and end_tms is null;
    UPDATE FT_T_BNID SET bnchmrk_id='MSASISCXJP' where bnchmrk_id='SAA_TESTFILTER' and bnchmrk_id_ctxt_typ = 'BRSBNCHID' and end_tms is null;
    COMMIT
    """