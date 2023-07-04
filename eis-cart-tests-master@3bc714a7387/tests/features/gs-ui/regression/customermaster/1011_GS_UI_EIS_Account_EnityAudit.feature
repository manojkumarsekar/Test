#https://jira.intranet.asia/browse/TOM-3362
# EISDEV-6367 - Add Dummy Run - This is to avoid NO RECORD in FT_T_JBLG table situation
# eisdev_7202 - Account master enhancements for breaking the BDD
# EISDEV-7458 - Disable drools for MainEntityID and MainEntityIdCtxtTyp and move to java rule to suppress additional changes shown for those 2 fields on UI

@tom_3362 @gs_ui_regression @dmp_workflow @eisdev_6367 @gc_ui_account_master @eisdev_7202 @eisdev_7180 @eisdev_7458
Feature: Create and Update Account Master for Entity Audit

  This is a defect in UAT
  1. Price log is not getting reflected in Audit log report when we update for first time. When I update the same Issue Price again it is getting reflected in Audit log record.
  2. Data Status field is coming in Audit log which I have not updated after 2nd time update.

  This feature file is to test the entity level audit feature for account screen using maker checker event.

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

  Scenario: TC_1: Clear the data as a Prerequisite

    Given I assign "tests/test-data/DevTest/TOM-3362" to variable "testdata.path"

    # Clear data for the given instruments from ACID , AUD1 , ACCT tables
    Given I execute below query
    """
    ${testdata.path}/sql/ClearData.sql
    """

  @web
  Scenario: TC_2: Create the record from UI

    Given I login to golden source UI with "administrators" role
    And I generate value with date format "DHMs" and assign to variable "VAR_RANDOM"


    When I add Portfolio Details for the Account Master as below
      | Portfolio Name          | 3362_PORTFOLIO_${VAR_RANDOM} |
      | Portfolio Legal Name    | 3362_PORTFOLIO_${VAR_RANDOM} |
      | Inception Date          | T                            |
      | Base Currency           | USD-US Dollar                |
      | Processed/Non Processed | NON-PROCESSED                |


    When I add Legacy Identifiers details for the Account Master as below
      | CRTS Portfolio Code | ${VAR_RANDOM}_CRTS |

    When  I add LBU Identifiers details for the Account Master as below
      | TSTAR Portfolio Code    | ${VAR_RANDOM}_TSTAR |
      | Korea MD Portfolio Code | ${VAR_RANDOM}_KOREA |

    When I add XReference details for the Account Master as below
      | IRP Code | ${VAR_RANDOM}_IRP |

    When I add the parties details in account master with following details
      | Investment Manager          | EASTSPRING INVESTMENTS (SINGAPORE) LIMITED |
      | Investment Manager Location | SG-Singapore                               |

    And I save the valid data
    Then I pause for 1 seconds

    When I relogin to golden source UI with "administrators" role
    Then I pause for 1 seconds

    Given I open account master "3362_PORTFOLIO_${VAR_RANDOM}" for the given portfolio

    When I update portfolio details in account master with following details
      | Processed/Non Processed | PROCESSED |

    Then I update Fund Details in account Master as below
      | Fund Category | LIFE - LIFE |

    And I save the valid data

  @web
  Scenario: TC_3: Closing Browsers
    Then I close all opened web browsers

  Scenario: TC_4: Run and Test the workflow "EIS_CompareJSON"

    Given I set the workflow template parameter "SQL_QUERY" to
      """
      WITH jblg AS
      (
        SELECT max(job_Start_tms) tms
        FROM fT_T_jblg
        WHERE job_config_txt = 'Audit Generation Job'
        AND job_stat_typ = 'CLOSED'
      )
      select * from (
      SELECT DISTINCT cross_ref_id cross_ref_id,nvl(to_char(j.tms,'ddmmyyyyHH24miss'),'01011900000000') , 'O'
      FROM ft_ev_evot,
      jblg j
      WHERE TBL_ID in ( 'ACCT','BNCH', 'ISPC', 'ISSU') and (last_chg_tms > j.tms)
      union
      SELECT DISTINCT instr_id cross_ref_id,nvl(to_char(j.tms,'ddmmyyyyHH24miss'),'01011900000000') , 'I'
      FROM ft_ev_evis,
      jblg j
      WHERE (last_chg_tms > j.tms)
      ) t
      """
    And I set the workflow template parameter "NO_OF_THREADS" to "10"

    When I send a web service request using template file "tests/test-data/intf-specs/gswf/template/EIS_CompareJSON/request.xmlt" and save the response to file "testout/evidence/gswf/resp/asyncResponse.xml"
    Then I extract a value from the XML file "testout/evidence/gswf/resp/asyncResponse.xml" using XPath query in file "tests/test-data/intf-specs/gswf/template/EIS_CompareJSON/flowResultIdQuery.xpath" to variable "flowResultId"


    #Workflow Verifications
    Then I poll for maximum 60 seconds and expect the result of the SQL query below equals to "DONE":
    """
    SELECT WF_RUNTIME_STAT_TYP FROM FT_WF_WFRI WHERE INSTANCE_ID='${flowResultId}'
    """

    Then I poll for maximum 60 seconds and expect the result of the SQL query below equals to "CLOSED":
    """
    SELECT JOB_STAT_TYP FROM FT_T_JBLG WHERE INSTANCE_ID='${flowResultId}'
    """

    Then I poll for maximum 1 seconds and expect the result of the SQL query below equals to "PASS":
    """
    SELECT 'PASS' FROM FT_T_AUD1 WHERE EXT_MAIN_ENT_NME = '3362_PORTFOLIO_${VAR_RANDOM}'
    AND EXT_GSO_FIELD_NAME IN ('Fund Category', 'Processed/Non Processed')
    GROUP BY EXT_MAIN_ENT_NME
    HAVING COUNT(1) = 2
    """
