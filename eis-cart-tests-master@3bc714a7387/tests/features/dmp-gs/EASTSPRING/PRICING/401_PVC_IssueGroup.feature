# ===================================================================================================================================================================================
# Date            JIRA        Comments
# ===================================================================================================================================================================================
# 20/10/2020      EISDEV-7046 Verify Workflow is passed when Issue Group is provided. This feature file is to ensure the new param passed is called successfully and workflow is executed without error
# ===================================================================================================================================================================================

@gc_interface_prices
@bloomberg_rr
@eisdev_7046
@pvc_issue_group
@pvc
@dmp_regression_unittest
Feature: Price Validation Consolidation | Issue Group

  Scenario: Run EIS_PricingProcessConsolidated for Golden Price Derivation

    Given I generate value with date format "yyyyMMdd" and assign to variable "PRC_TMS"

    Given I process Goldenprice calculation with below parameters and wait for the job to be completed
      | PROCESSING_DATE                       | ${PRC_TMS} |
      | RUN_FAIR_VALUE_DERIVATION             | false      |
      | RUN_UNLISTED_WARRANT_PRICE_DERIVATION | false      |
      | RUN_THAI_PRICE_DERIVATION             | false      |
      | ISSUE_GROUP1                          | OTHERPRCVL |
      | ISSUE_GROUP2                          | FIXEDPRCVL |
      | RUNPVCFORPRVI                         | false      |

  Scenario: Verify GP Calculation is called for the given instrument id from the provided issue group

    Given I execute below query and extract values of "INSTR_ID_COUNT" into same variables
    """
    select count(distinct instr_id) as INSTR_ID_COUNT from ft_t_isgp where prnt_iss_grp_oid in ('OTHERPRCVL','FIXEDPRCVL') and end_tms is null
    """

    Given I expect value of column "PVC_INSTR_ID" in the below SQL query equals to "${INSTR_ID_COUNT}":

     """
     select count(instr_id) as PVC_INSTR_ID from ft_o_isjb where job_id in(
     select job_id from (SELECT job_id, Row_number()
     OVER (partition BY job_input_txt ORDER BY job_end_tms DESC) AS RECORD_ORDER
     FROM   ft_t_jblg WHERE  job_input_txt = 'PriceValidationConsolidatedWorkflow'
     and job_end_tms is not null) where record_order = 1)
     """