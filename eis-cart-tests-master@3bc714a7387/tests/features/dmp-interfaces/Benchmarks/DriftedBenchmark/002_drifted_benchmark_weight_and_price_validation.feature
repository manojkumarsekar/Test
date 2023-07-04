#https://jira.intranet.asia/browse/TOM-3255
#https://jira.intranet.asia/browse/EISST-1368 Expected test data for BENCHMARK COMPONENT IDENTIFIER BPM1PUHG1 is
# changed as SM_SEC_GROUP to FUND and SM_SEC_TYPE to OPEN_END
# TOM-3726 : Moved file from DevTest to DMP Interfaces

@gc_interface_benchmark @gc_interface_risk_analytics
@dmp_regression_integrationtest
@dmp_gs_upgrade
@tom_4065 @tom_3255 @dmp_benchmark_weight_and_price_validation @tom_3726
Feature: 002 | Drifted Benchmark | Test to confirm that FT_V_DBM1 returns expected exceptions for EOD Weight,
  EOD Price and SOD Weight scenarios; and confirm that outbound is suppressing blank EOD Weights

  This feature file loads an EOD Benchmark file (esi_security_analytics_models_*.csv) and publishes Benchmark output file (esi_security_analytics_models_*.csv).
  This feature file mocks SOD Weights from EOD Weights to test validations in FT_V_DBM1 view

  Note: A single input file is used to test the following four aspects:-
  a) Inbound: EOD Weights (details below)
  b) Inbound: EOD Prices (details below)
  c) Inbound: SOD Weights (is mocked from EOD Weights, details below)
  d) Outbound: Blank EOD Weights filtered during publishing

  Requirement:
  FT_V_DBM1 should return records that have exceptions in EOD Weight and EOD Price criteria.
  Publishing should suppress blank EOD Weight records.

  Exception Criteria with illustration:-
  (Assuming and setting EOD & SOD Weight tolerance to 0.0005)

  1.1) Sum of EOD Weights is 100 (exact, with few components NULL). Expected outcome:- No notification to be sent
  1.2) Sum of EOD Weights is 99.9995 (exactly on tolerance border, with few components NULL). Expected outcome:- No notification to be sent
  1.3) Sum of EOD Weights is 100.0005 (exactly on tolerance border, with few components NULL). Expected outcome:- No notification to be sent
  1.4) Sum of EOD Weights is 99.9994 (just outside tolerance border). Expected outcome:- Notification to be sent
  1.5) Sum of EOD Weights is 100.0006 (just outside tolerance border). Expected outcome:- Notification to be sent
  1.6) Sum of EOD Weights is NULL (all components of benchmark are blank). Expected outcome:- Notification to be sent

  2.1) EOD Price is NULL for all components of a Benchmark. Expected outcome:- Notification to be sent
  2.2) EOD Price is NULL for some components of a Benchmark. Expected outcome:- Notification to be sent
  2.3) EOD Price is NOT NULL for all components of a Benchmark. Expected outcome:- No notification to be sent

  3.1) Sum of SOD Weights is 100 (exact, with few components NULL). Expected outcome:- No notification to be sent
  3.2) Sum of SOD Weights is 99.99995 (exactly on tolerance border, with few components NULL). Expected outcome:- No notification to be sent
  3.3) Sum of SOD Weights is 100.00005 (exactly on tolerance border, with few components NULL). Expected outcome:- No notification to be sent
  3.4) Sum of SOD Weights is 99.99994 (just outside tolerance border). Expected outcome:- Notification to be sent
  3.5) Sum of SOD Weights is 100.00006 (just outside tolerance border). Expected outcome:- Notification to be sent
  3.6) Sum of SOD Weights is NULL (all components of benchmark are blank). Expected outcome:- No notification to be sent

  1. EOD Weight sample data:-
  ----------------------------------------------------------------------------------------------------------------------------------------------
  |Benchmark    |Component1 |Component2 |Component3 |Total            |Expected Result                                                          |
  |             |EOD Weight |EOD Weight |EOD Weight |EOD Weight       |                                                                         |
  -----------------------------------------------------------------------------------------------------------------------------------------------
  |GMP_ABTSLF   |50         |50         |NULL       |100              |View returns no EOD_WEIGHT exception for benchmark. Hence no email sent  |
  |GMP_AHOBI6   |50         |49.9995    |NULL       |99.9995          |View returns no EOD_WEIGHT exception for benchmark. Hence no email sent  |
  |GMP_AHOBIN   |50         |50.0005    |NULL       |100.0005         |View returns no EOD_WEIGHT exception for benchmark. Hence no email sent  |
  |GMP_AHOBLF   |50         |49.9994    |NULL       |99.9994          |View returns EOD_WEIGHT exception for benchmark. Hence email sent        |
  |GMP_AHOHKD   |50         |50.0006    |NULL       |100.0006         |View returns EOD_WEIGHT exception for benchmark. Hence email sent        |
  |GMP_AHOPGH   |NULL       |NULL       |NULL       |NULL             |View returns EOD_WEIGHT exception for benchmark. Hence email sent        |
  -----------------------------------------------------------------------------------------------------------------------------------------------

  2. EOD Price sample data:-
  ---------------------------------------------------------------------------------------------------------------------------
  |Benchmark    |Component1 |Component2 |Component3 |Expected Result                                                        |
  |             |EOD Price  |EOD Price  |EOD Price  |                                                                       |
  --------------------------------------------------|------------------------------------------------------------------------
  |GMP_ABTSLF   |NULL       |NULL       |NULL       |View returns EOD_PRICE exception for benchmark. Hence email sent       |
  |GMP_AHOBI6   |20         |30         |NULL       |View returns EOD_PRICE exception for benchmark. Hence email sent       |
  |GMP_AHOBIN   |25         |35         |45         |View returns no EOD_PRICE exception for benchmark. Hence no email sent |
  ---------------------------------------------------------------------------------------------------------------------------

  3. SOD Weight sample data:-
  ----------------------------------------------------------------------------------------------------------------------------------------------
  |Benchmark    |Component1 |Component2 |Component3 |Total            |Expected Result                                                          |
  |             |SOD Weight |SOD Weight |SOD Weight |SOD Weight       |                                                                         |
  -----------------------------------------------------------------------------------------------------------------------------------------------
  |GMP_ABTSLF   |50         |50         |NULL       |100              |View returns no SOD_WEIGHT exception for benchmark. Hence no email sent  |
  |GMP_AHOBI6   |50         |49.9995    |NULL       |99.9995          |View returns no SOD_WEIGHT exception for benchmark. Hence no email sent  |
  |GMP_AHOBIN   |50         |50.0005    |NULL       |100.0005         |View returns no SOD_WEIGHT exception for benchmark. Hence no email sent  |
  |GMP_AHOBLF   |50         |49.9994    |NULL       |99.9994          |View returns SOD_WEIGHT exception for benchmark. Hence email sent        |
  |GMP_AHOHKD   |50         |50.0006    |NULL       |100.0006         |View returns SOD_WEIGHT exception for benchmark. Hence email sent        |
  |GMP_AHOPGH   |NULL       |NULL       |NULL       |NULL             |View returns no SOD_WEIGHT exception for benchmark. Hence no email sent  |
  -----------------------------------------------------------------------------------------------------------------------------------------------

  Load a Benchmark file with six benchmarks, each benchmark containing three components with EOD Weights and EOD Prices as above.
  Check the data returned by view FT_V_DBM1

  Scenario: Clear the data as a Prerequisite

    Given I assign "esi_security_analytics_models_eod_weight_price.xml" to variable "INPUT_FILENAME"
    And I assign "esi_security_analytics_models_eod_weight_price_template.xml" to variable "INPUT_TEMPLATENAME"

    And I assign "tests/test-data/dmp-interfaces/Benchmarks/DriftedBenchmark" to variable "testdata.path"
    And I assign "esi_bnp_drifted_bmk_weights" to variable "PUBLISHING_FILE_NAME"
    And I assign "esi_bnp_drifted_bmk_weights_template.csv" to variable "PUBLISHING_TEMPLATENAME"

    And I generate value with date format "YYYYMMdd" and assign to variable "VAR_SYSDATE"
    And I assign "${PUBLISHING_FILE_NAME}_${VAR_SYSDATE}_1.csv" to variable "PUBLISHING_FILE_FULL_NAME"
    And I assign "/dmp/out/bnp/eod" to variable "PUBLISHING_DIR"
    And I assign "esi_bnp_drifted_bmk_weights.csv" to variable "MASTER_FILE"
    And I remove below files with pattern in the host "dmp.ssh.inbound" from folder "${PUBLISHING_DIR}" if exists:
      | ${PUBLISHING_FILE_NAME}_*_1.csv |

    Given I execute below query to "Set a EOD Weight Tolerance of 0.0005. Clear Benchmark data from BNVL and BNVC."
    """
    ${testdata.path}/sql/ClearData.sql
    """

  Scenario: Generate input data from template

    And I modify date "${VAR_SYSDATE}" with "-1d" from source format "YYYYMMdd" to destination format "MM/dd/YYYY" and assign to "DYNAMIC_DATE"

    And I create input file "${INPUT_FILENAME}" using template "${INPUT_TEMPLATENAME}" from location "${testdata.path}/infiles"

  Scenario: Generate output expected data from template

    And I modify date "${VAR_SYSDATE}" with "-1d" from source format "YYYYMMdd" to destination format "dd-MM-YYYY" and assign to "DYNAMIC_DATE"

    And I create input file "${PUBLISHING_FILE_NAME}.csv" using template "${PUBLISHING_TEMPLATENAME}" from location "${testdata.path}/outfiles/expected"

  Scenario: Load a Benchmark file with six benchmarks, each benchmark containing three components with EOD Weights and EOD Prices as above

    Given I copy files below from local folder "${testdata.path}/infiles/testdata" to the host "dmp.ssh.inbound" folder "${dmp.ssh.inbound.path}":
      | ${INPUT_FILENAME} |

    Given I set the workflow template parameter "FILE_PATTERN" to "${INPUT_FILENAME}"
    And I set the workflow template parameter "INPUT_DATA_DIR" to "${dmp.ssh.inbound.path}"
    And I set the workflow template parameter "MESSAGE_TYPE" to "EIS_MT_BRS_RISK_ANALYTICS"
    And I set the workflow template parameter "DATA_DETAILS_COUNT" to "50"
    And I set the workflow template parameter "EMAIL_SUBJECT" to "Drifted Benchmark Validation Alert"
    And I set the workflow template parameter "DATA_HEADER" to "as_of, attribute_type, benchmark_code, benchmark_component, attribute_value, exception_comment"
    And I set the workflow template parameter "DATA_SQL" to "SELECT as_of, attribute_type, benchmark_code, benchmark_component, attribute_value, exception_comment FROM ft_v_dbm1 ORDER BY 2, 3, 4"
    And I set the workflow template parameter "EMAIL_ADDRESS" to "eis-dmp-support-dev@eastspring.com"

    When I send a web service request using template file "tests/test-data/intf-specs/gswf/template/EIS_LoadFiles_PublishReport/request.xmlt" and save the response to file "testout/evidence/gswf/resp/response1.xml"
    Then I extract value from the XML file "testout/evidence/gswf/resp/response1.xml" with xpath "//*[local-name() = 'flowResultId']" to variable "flowResultId"

    Then I poll for maximum 60 seconds and expect the result of the SQL query below equals to "DONE":
    """
    SELECT WF_RUNTIME_STAT_TYP FROM FT_WF_WFRI WHERE INSTANCE_ID='${flowResultId}'
    """

    Given I execute below query to "Mock data - SOD Weights from EOD Weights. Update Benchmark Value TMS date to sysdate."
    """
    ${testdata.path}/sql/UpdateData.sql
    """

    Then I extract new job id from jblg table into a variable "JOB_ID"

    # Validation: JBLG NTEL error logged
    Then I expect value of column "EXCEPTION_MSG_CHECK" in the below SQL query equals to "0":
    """
    SELECT COUNT(*) AS EXCEPTION_MSG_CHECK FROM ft_t_ntel ntel
        JOIN ft_t_trid trid
        ON ntel.last_chg_trn_id = trid.trn_id
    WHERE trid.job_id = '${JOB_ID}'
    AND ntel.msg_typ = 'EIS_MT_BRS_RISK_ANALYTICS'
    AND ntel.notfcn_stat_typ = 'OPEN'
    """

    # Validation: Assert that 6 Benchmarks with 3 components each are loaded in BNVL  (6 x 3 = 18)
    Then I expect value of column "BNVL_COUNT" in the below SQL query equals to "18":
    """
    ${testdata.path}/sql/BNVLCount.sql
    """
    ######################################## EOD Weight Validation #####################################################

    # Validation: FT_V_DBM1 EOD Weight Exception Count for GMP_ABTSLF is 0
    Then I expect value of column "GMP_ABTSLF_EOD_WGT_COUNT" in the below SQL query equals to "0":
    """
    SELECT COUNT(*) AS GMP_ABTSLF_EOD_WGT_COUNT FROM ft_v_dbm1
    WHERE as_of = TO_CHAR(sysdate - 1, 'YYYYMMDD')
    AND attribute_type = 'EOD_WEIGHT'
    AND benchmark_code = 'GMP_ABTSLF'
    """

    # Validation: FT_V_DBM1 EOD Weight Exception Count for GMP_AHOBI6 is 0
    Then I expect value of column "GMP_AHOBI6_EOD_WGT_COUNT" in the below SQL query equals to "0":
    """
    SELECT COUNT(*) AS GMP_AHOBI6_EOD_WGT_COUNT FROM ft_v_dbm1
    WHERE as_of = TO_CHAR(sysdate - 1, 'YYYYMMDD')
    AND attribute_type = 'EOD_WEIGHT'
    AND benchmark_code = 'GMP_AHOBI6'
    """

    # Validation: FT_V_DBM1 EOD Weight Exception Count for GMP_AHOBIN is 0
    Then I expect value of column "GMP_AHOBIN_EOD_WGT_COUNT" in the below SQL query equals to "0":
    """
    SELECT COUNT(*) AS GMP_AHOBIN_EOD_WGT_COUNT FROM ft_v_dbm1
    WHERE as_of = TO_CHAR(sysdate - 1, 'YYYYMMDD')
    AND attribute_type = 'EOD_WEIGHT'
    AND benchmark_code = 'GMP_AHOBIN'
    """

    # Validation: FT_V_DBM1 EOD Weight Exception Count for GMP_AHOBLF is 3
    Then I expect value of column "GMP_AHOBLF_EOD_WGT_COUNT" in the below SQL query equals to "3":
    """
    SELECT COUNT(*) AS GMP_AHOBLF_EOD_WGT_COUNT FROM ft_v_dbm1
    WHERE as_of = TO_CHAR(sysdate - 1, 'YYYYMMDD')
    AND attribute_type = 'EOD_WEIGHT'
    AND benchmark_code = 'GMP_AHOBLF'
    """

    # Validation: FT_V_DBM1 EOD Weight Exception Count for GMP_AHOHKD is 3
    Then I expect value of column "GMP_AHOHKD_EOD_WGT_COUNT" in the below SQL query equals to "3":
    """
    SELECT COUNT(*) AS GMP_AHOHKD_EOD_WGT_COUNT FROM ft_v_dbm1
    WHERE as_of = TO_CHAR(sysdate - 1, 'YYYYMMDD')
    AND attribute_type = 'EOD_WEIGHT'
    AND benchmark_code = 'GMP_AHOHKD'
    """

    # Validation: FT_V_DBM1 EOD Weight Exception Count for GMP_AHOPGH is 3
    Then I expect value of column "GMP_AHOPGH_EOD_WGT_COUNT" in the below SQL query equals to "3":
    """
    SELECT COUNT(*) AS GMP_AHOPGH_EOD_WGT_COUNT FROM ft_v_dbm1
    WHERE as_of = TO_CHAR(sysdate - 1, 'YYYYMMDD')
    AND attribute_type = 'EOD_WEIGHT'
    AND benchmark_code = 'GMP_AHOPGH'
    """

    ######################################## EOD Price Validation ######################################################

    # Validation: FT_V_DBM1 EOD Price Exception Count for GMP_ABTSLF is 3
    Then I expect value of column "GMP_ABTSLF_EOD_PRICE_COUNT" in the below SQL query equals to "3":
    """
    SELECT COUNT(*) AS GMP_ABTSLF_EOD_PRICE_COUNT FROM ft_v_dbm1
    WHERE as_of = TO_CHAR(sysdate - 1, 'YYYYMMDD')
    AND attribute_type = 'EOD_PRICE'
    AND benchmark_code = 'GMP_ABTSLF'
    """

    # Validation: FT_V_DBM1 EOD Price Exception Count for GMP_AHOBI6 is 0
    Then I expect value of column "GMP_AHOBI6_EOD_PRICE_COUNT" in the below SQL query equals to "1":
    """
    SELECT COUNT(*) AS GMP_AHOBI6_EOD_PRICE_COUNT FROM ft_v_dbm1
    WHERE as_of = TO_CHAR(sysdate - 1, 'YYYYMMDD')
    AND attribute_type = 'EOD_PRICE'
    AND benchmark_code = 'GMP_AHOBI6'
    """

    # Validation: FT_V_DBM1 EOD Price Exception Count for GMP_AHOBIN is 0
    Then I expect value of column "GMP_AHOBIN_EOD_PRICE_COUNT" in the below SQL query equals to "0":
    """
    SELECT COUNT(*) AS GMP_AHOBIN_EOD_PRICE_COUNT FROM ft_v_dbm1
    WHERE as_of = TO_CHAR(sysdate - 1, 'YYYYMMDD')
    AND attribute_type = 'EOD_PRICE'
    AND benchmark_code = 'GMP_AHOBIN'
    """

    ######################################## SOD Weight Validation #####################################################

    # Validation: FT_V_DBM1 SOD Weight Exception Count for GMP_ABTSLF is 0
    Then I expect value of column "GMP_ABTSLF_SOD_WGT_COUNT" in the below SQL query equals to "0":
    """
    SELECT COUNT(*) AS GMP_ABTSLF_SOD_WGT_COUNT FROM ft_v_dbm1
    WHERE as_of = TO_CHAR(sysdate - 1, 'YYYYMMDD')
    AND attribute_type = 'SOD_WEIGHT'
    AND benchmark_code = 'GMP_ABTSLF'
    """

    # Validation: FT_V_DBM1 SOD Weight Exception Count for GMP_AHOBI6 is 0
    Then I expect value of column "GMP_AHOBI6_SOD_WGT_COUNT" in the below SQL query equals to "0":
    """
    SELECT COUNT(*) AS GMP_AHOBI6_SOD_WGT_COUNT FROM ft_v_dbm1
    WHERE as_of = TO_CHAR(sysdate - 1, 'YYYYMMDD')
    AND attribute_type = 'SOD_WEIGHT'
    AND benchmark_code = 'GMP_AHOBI6'
    """

    # Validation: FT_V_DBM1 SOD Weight Exception Count for GMP_AHOBIN is 0
    Then I expect value of column "GMP_AHOBIN_SOD_WGT_COUNT" in the below SQL query equals to "0":
    """
    SELECT COUNT(*) AS GMP_AHOBIN_SOD_WGT_COUNT FROM ft_v_dbm1
    WHERE as_of = TO_CHAR(sysdate - 1, 'YYYYMMDD')
    AND attribute_type = 'SOD_WEIGHT'
    AND benchmark_code = 'GMP_AHOBIN'
    """

    # Validation: FT_V_DBM1 SOD Weight Exception Count for GMP_AHOBLF is 3
    Then I expect value of column "GMP_AHOBLF_SOD_WGT_COUNT" in the below SQL query equals to "3":
    """
    SELECT COUNT(*) AS GMP_AHOBLF_SOD_WGT_COUNT FROM ft_v_dbm1
    WHERE as_of = TO_CHAR(sysdate - 1, 'YYYYMMDD')
    AND attribute_type = 'SOD_WEIGHT'
    AND benchmark_code = 'GMP_AHOBLF'
    """

    # Validation: FT_V_DBM1 SOD Weight Exception Count for GMP_AHOHKD is 3
    Then I expect value of column "GMP_AHOHKD_SOD_WGT_COUNT" in the below SQL query equals to "3":
    """
    SELECT COUNT(*) AS GMP_AHOHKD_SOD_WGT_COUNT FROM ft_v_dbm1
    WHERE as_of = TO_CHAR(sysdate - 1, 'YYYYMMDD')
    AND attribute_type = 'SOD_WEIGHT'
    AND benchmark_code = 'GMP_AHOHKD'
    """

    # Validation: FT_V_DBM1 SOD Weight Exception Count for GMP_AHOPGH is 0
    Then I expect value of column "GMP_AHOPGH_SOD_WGT_COUNT" in the below SQL query equals to "0":
    """
    SELECT COUNT(*) AS GMP_AHOPGH_SOD_WGT_COUNT FROM ft_v_dbm1
    WHERE as_of = TO_CHAR(sysdate - 1, 'YYYYMMDD')
    AND attribute_type = 'SOD_WEIGHT'
    AND benchmark_code = 'GMP_AHOPGH'
    """

    ######################################## Drifted Benchmark Publishing ##############################################

  Scenario: Publish Drifted Benchmark and verify that output DOES NOT contain blank EOD Weights, eventhough the BNVL table contains Blank EOD Weights

    When I process publishing wrapper with below parameters and wait for the job to be completed
      | PUBLISHING_FILE_NAME | ${PUBLISHING_FILE_NAME}.csv           |
      | SUBSCRIPTION_NAME    | EIS_DMP_TO_BNP_DRIFTED_BM_WEIGHTS_SUB |

    Then I expect below files to be present in the host "dmp.ssh.inbound" into folder "${PUBLISHING_DIR}" after processing:
      | ${PUBLISHING_FILE_FULL_NAME} |

    Then I copy files below from remote folder "${PUBLISHING_DIR}" on host "dmp.ssh.inbound" into local folder "${testdata.path}/outfiles/runtime":
      | ${PUBLISHING_FILE_FULL_NAME} |

    # Validation: Assert that BNVL table contains one 8 records with blank EOD Weight
    Then I expect value of column "BLANK_EOD_WEIGHT_COUNT" in the below SQL query equals to "8":
    """
    ${testdata.path}/sql/BNVLCount_NULL.sql
    """

    # Validation: Assert that BNVL table contains one 10 records with NON-NULL for EOD Weight
    Then I expect value of column "NON_BLANK_EOD_WEIGHT_COUNT" in the below SQL query equals to "10":
    """
    ${testdata.path}/sql/BNVLCount_NON_NULL.sql
    """

    # Validation: The output file should NOT contain any record with blank values in EOD Weight even though the GC BNVL table contains 8 blank EOD Weight records.
    Then I expect column "EOD WEIGHT" values in the CSV file "${testdata.path}/outfiles/runtime/${PUBLISHING_FILE_FULL_NAME}" should not be with pattern "^$"

    # Validation: Reconcile Data with template that contains 10 records
    #And I expect reconciliation between generated CSV file "${testdata.path}/outfiles/runtime/${PUBLISHING_FILE_FULL_NAME}" and reference CSV file "${testdata.path}/outfiles/expected/testdata/${MASTER_FILE}" should be successful and exceptions to be written to "${testdata.path}/outfiles/exceptions_${recon.timestamp}.csv" file
    And I expect each record in file "${testdata.path}/outfiles/expected/testdata/${MASTER_FILE}" should exist in file "${testdata.path}/outfiles/runtime/${PUBLISHING_FILE_FULL_NAME}" and exceptions to be written to "${testdata.path}/outfiles/004_3_exceptions_${recon.timestamp}.csv" file
