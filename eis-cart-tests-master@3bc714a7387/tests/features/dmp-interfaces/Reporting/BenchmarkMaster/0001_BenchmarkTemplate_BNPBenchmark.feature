#https://jira.intranet.asia/browse/TOM-5198

#No regression tag observed. Hence, modular tag (Ex: gc_interface or dw_interface) has not given.
@tom_5198
Feature: This feature is to test the creation of Benchmark through template uploader with the newly added field for Reporting - BNP Performance Benchmark Flag

  Scenario: TC_1: Clear old test data and setup variables

    Given I assign "tests/test-data/dmp-interfaces/Reporting/BenchmarkMaster" to variable "testdata.path"

    And I execute below query
    """
    UPDATE ft_t_bnid SET END_TMS = SYSDATE-1, START_TMS = START_TMS-1 WHERE bnch_oid IN (SELECT bnch_oid from fT_T_bnid where bnchmrk_id ='TC5198RDMCode' AND END_TMS IS NULL);
    UPDATE ft_t_bnid SET END_TMS = SYSDATE-1, START_TMS = START_TMS-1 WHERE bnch_oid IN (SELECT bnch_oid from fT_T_bnid where bnchmrk_id ='TC5198RDMCode2' AND END_TMS IS NULL)
    """

  Scenario: TC_2: Setup new benchmark in DMP

    Given I assign "TOM-5198-BenchmarkTemplate-R6-attributes.csv" to variable "BENCHMARK_FILENAME"
    And I copy files below from local folder "${testdata.path}/testdata/infiles" to the host "dmp.ssh.inbound" folder "${dmp.ssh.inbound.path}":
      | ${BENCHMARK_FILENAME} |

    Then I process files with below parameters and wait for the job to be completed
      | BUSINESS_FEED |                       |
      | FILE_PATTERN  | ${BENCHMARK_FILENAME} |
      | MESSAGE_TYPE  | EIS_MT_RDM_BENCHMARK  |

    Then I extract new job id from jblg table into a variable "JOB_ID"

    And I expect value of column "JBLG_ROW_COUNT" in the below SQL query equals to "1":
      """
      SELECT COUNT(1) AS JBLG_ROW_COUNT FROM FT_T_JBLG WHERE JOB_ID = '${JOB_ID}' AND TASK_SUCCESS_CNT ='1' and TASK_FAILED_CNT = '1'
      """

  Scenario: TC_3: Expect BNPPERF flag is populated for benchmark_id = TC5198RDMCode

    Then I expect value of column "BNPPERF_CNT" in the below SQL query equals to "1":
        """
        select count(1) as BNPPERF_CNT from fT_T_bnst where bnch_oid in ( select bnch_oid from fT_T_bnid where bnchmrk_id ='TC5198RDMCode' AND END_TMS IS NULL)
        AND STAT_DEF_ID = 'BNPPERF' AND STAT_CHAR_VAL_TXT='Y'
        """

  Scenario: TC_4: Verify error is thrown when mandatory BNPPERF flag value is missing in file record with benchamrk_id = TC5198RDMCode2

    Then I expect value of column "NTEL_CNT" in the below SQL query equals to "1":
        """
        select count(1) as NTEL_CNT from fT_T_NTEL where NOTFCN_STAT_TYP='OPEN'
        AND NOTFCN_ID = '194'
        AND APPL_ID = 'STRDATA'
        AND PART_ID = 'STRDATA'
        AND MSG_SEVERITY_CDE = 50
        AND MAIN_ENTITY_ID = 'TC5198RDMCode2'
        AND MAIN_ENTITY_ID_CTXT_TYP = 'RDMCODE'
        AND CHAR_VAL_TXT = 'The Benchmark Definition could not be set up in GoldenSource as per the minimum completeness requirements of the k104722k Model. The BNST_BNPPERFFLG (stored in the Benchmark Statistic table) was not available from EIS.'
        AND LAST_CHG_TRN_ID IN (SELECT TRN_ID FROM FT_T_TRID WHERE JOB_ID = '${JOB_ID}')
        """