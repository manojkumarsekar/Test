#https://jira.intranet.asia/browse/TOM-3127
#EISDEV-7458 : Disable drools for MainEntityID and MainEntityIdCtxtTyp and move to java rule to suppress additional changes shown for those 2 fields on UI

@gc_ui_benchmark
@tom_3127 @web @gs_ui_regression @dmp_workflow @eisdev_7458
Feature: Enhance JSON comparison for multi-occuring datagroups

  Current implementation for JSON comparison is done purely for single occurring data groups.
  Effectively, it drills down to the child to get the GSO field and compares on the basis of field name.
  So, for multi-occurring data groups there would be multiple GSO fields (if there are more than one occurrence)
  and comparison would take last occurrence and compare against that.
  This needs to be enhanced to take into consideration the Natural Key defined on the data group
  and derive the key of the map on the basis of fields defined in Natural Key.

  Scenario: TC_0: Dummy Run - This is to avoid NO RECORD in FT_T_JBLG table situation

    Given I set the workflow template parameter "SQL_QUERY" to
      """
      WITH jblg AS
      (
        SELECT MAX(job_Start_tms) tms
        FROM ft_t_jblg
        WHERE job_config_txt = 'Audit Generation Job'
        AND job_stat_typ = 'CLOSED'
      )
      SELECT * FROM
      (
        SELECT DISTINCT cross_ref_id cross_ref_id,nvl(to_char(j.tms,'ddmmyyyyHH24miss'),'01011900000000'), 'O'  FROM ft_ev_evot, jblg j
        WHERE tbl_id in ( 'DUMMY') and (last_chg_tms > j.tms)
        UNION
        SELECT DISTINCT instr_id cross_ref_id,nvl(to_char(j.tms,'ddmmyyyyHH24miss'),'01011900000000'), 'I' FROM ft_ev_evis, jblg j
        WHERE (last_chg_tms > j.tms)
      ) t
      """
    And I set the workflow template parameter "NO_OF_THREADS" to "10"

    When I send a web service request using template file "tests/test-data/intf-specs/gswf/template/EIS_CompareJSON/request.xmlt" and save the response to file "testout/evidence/gswf/resp/asyncResponse.xml"

  Scenario: TC_1: Create and Update Benchmark

    Given I login to golden source UI with "task_assignee" role
    And I generate value with date format "DHs" and assign to variable "VAR_RANDOM"

    When I create a benchmark with following details
      | ESI Benchmark Name        | TOM3127_${VAR_RANDOM} |
      | Official Benchmark Name   | TOM3127_${VAR_RANDOM} |
      | Benchmark Category        | Fixed                 |
      | Currency                  | SGD-Singapore Dollar  |
      | Hedged/Unhedged Indicator | O - Original          |
      | Rebalance Frequency       | AN - Annually         |
      | Benchmark Level Access    | Country Level         |
      | Benchmark Provider Name   | UOB                   |
      | CRTS Benchmark Code       | CRTSCD${VAR_RANDOM}   |

    And I save the valid data

    When I relogin to golden source UI with "task_authorizer" role
    And I approve a record from My WorkList with entity name "TOM3127_${VAR_RANDOM}"

    When I relogin to golden source UI with "task_assignee" role

    When I update benchmark "TOM3127_${VAR_RANDOM}" with following details
      | Benchmark Level Access | Sector Level |

    And I save the valid data

    When I relogin to golden source UI with "task_authorizer" role
    And I approve a record from My WorkList with entity name "TOM3127_${VAR_RANDOM}"

    When I relogin to golden source UI with "task_assignee" role
    Then I expect the Benchmark "TOM3127_${VAR_RANDOM}" is updated as below
      | Benchmark Level Access | Sector Level |

  Scenario: TC_2: Close browsers
    Then I close all opened web browsers

  Scenario: TC_3: Run and Test the workflow "EIS_CompareJSON"

    Given I set the workflow template parameter "SQL_QUERY" to
      """
      WITH jblg AS
      (
        SELECT MAX(job_Start_tms) tms
        FROM ft_t_jblg
        WHERE job_config_txt = 'Audit Generation Job'
        AND job_stat_typ = 'CLOSED'
      )
      SELECT * FROM
      (
        SELECT DISTINCT cross_ref_id cross_ref_id,nvl(to_char(j.tms,'ddmmyyyyHH24miss'),'01011900000000'), 'O'  FROM ft_ev_evot, jblg j
        WHERE tbl_id in ( 'ACCT','BNCH', 'ISPC', 'ISSU') and (last_chg_tms > j.tms)
        UNION
        SELECT DISTINCT instr_id cross_ref_id,nvl(to_char(j.tms,'ddmmyyyyHH24miss'),'01011900000000'), 'I' FROM ft_ev_evis, jblg j
        WHERE (last_chg_tms > j.tms)
      ) t
      """
    And I set the workflow template parameter "NO_OF_THREADS" to "10"


    When I send a web service request using template file "tests/test-data/intf-specs/gswf/template/EIS_CompareJSON/request.xmlt" and save the response to file "testout/evidence/gswf/resp/asyncResponse.xml"
    Then I extract a value from the XML file "testout/evidence/gswf/resp/asyncResponse.xml" using XPath query in file "tests/test-data/intf-specs/gswf/template/EIS_CompareJSON/flowResultIdQuery.xpath" to variable "flowResultId"

      #Workflow Verifications
    Then I poll for maximum 20 seconds and expect the result of the SQL query below equals to "DONE":
      """
      SELECT WF_RUNTIME_STAT_TYP FROM FT_WF_WFRI WHERE INSTANCE_ID='${flowResultId}'
      """

    Then I poll for maximum 20 seconds and expect the result of the SQL query below equals to "CLOSED":
      """
      SELECT JOB_STAT_TYP FROM FT_T_JBLG WHERE INSTANCE_ID='${flowResultId}'
      """

    And I execute below query and extract values of "JOB_START_TMS" into same variables
    """
    SELECT JOB_START_TMS FROM FT_T_JBLG WHERE INSTANCE_ID='${flowResultId}'
    """

  Scenario: TC_4: Verify Audit Report

    Given I login to golden source UI with "task_assignee" role

    When I search Audit Log Report with below details
      | Main Entity Type | Benchmark             |
      | Main Entity Name | TOM3127_${VAR_RANDOM} |

    Then I expect GS table should have 1 rows

    And I again search Audit Log Report with below details
      | GSO Field Name | Benchmark Level Access |
      | Previous Value | COUNTRY                |
      | Current Value  | SECTOR                 |

    Then I expect GS table should have 1 rows

  Scenario: TC_5: Close browsers
    Then I close all opened web browsers
