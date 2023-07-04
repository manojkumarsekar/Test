#https://jira.intranet.asia/browse/TOM-3464

@gc_ui_benchmark
@tom_3464 @web @gs_ui_smoke
Feature: Verify Main entity Id for Created Benchmark

  This is to test defect raised in UAT.

  Scenario: TC_1: Create Benchmark

    Given I login to golden source UI with "task_assignee" role
    And I generate value with date format "DHMs" and assign to variable "VAR_RANDOM"

    And I assign "TestBenchmark_${VAR_RANDOM}" to variable "BENCHMARK_NAME"

    When I create a benchmark with following details
      | ESI Benchmark Name        | ${BENCHMARK_NAME}    |
      | Official Benchmark Name   | SGX Benchmark        |
      | Benchmark Category        | Fixed                |
      | Currency                  | SGD-Singapore Dollar |
      | Hedged/Unhedged Indicator | A - Pending Active   |
      | Rebalance Frequency       | AN - Annually        |
      | Benchmark Level Access    | Country Level        |
      | Benchmark Provider Name   | MSCI                 |
    And I save the valid data

    When I relogin to golden source UI with "task_authorizer" role
    And I approve a record from My WorkList with entity name "${BENCHMARK_NAME}"

  Scenario: TC_2: Close browsers
    Then I close all opened web browsers

  Scenario: TC_3: Verify Main entity Id

    Then I expect value of column "MAIN_ENTITY_ID" in the below SQL query equals to "Null":
    """
    select case when MAIN_ENTITY_ID is null then 'Null' end as MAIN_ENTITY_ID from fT_T_trid
    where input_msg_typ='SD'
    and main_entity_nme ='${BENCHMARK_NAME}'
    order by last_upd_tms desc
    """