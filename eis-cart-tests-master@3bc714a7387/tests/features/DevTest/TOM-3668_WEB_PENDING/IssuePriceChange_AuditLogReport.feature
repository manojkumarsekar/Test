#https://jira.intranet.asia/browse/TOM-3668

@tom_3668 @web @gs_ui_issueprice @dmp_workflow
Feature: Enhance JSON comparison for multi-occuring datagroups

  Current implementation for JSON comparison is done purely for single occurring data groups.
  Effectively, it drills down to the child to get the GSO field and compares on the basis of field name.
  So, for multi-occurring data groups there would be multiple GSO fields (if there are more than one occurrence)
  and comparison would take last occurrence and compare against that.
  This needs to be enhanced to take into consideration the Natural Key defined on the data group
  and derive the key of the map on the basis of fields defined in Natural Key.

  Scenario: TC_1: Create New Security Master
    Given I login to golden source UI with "task_assignee" role

    When I add Instrument Details for the Issue as below
      | Instrument Name          | TST_INSTNAME           |
      | Instrument Description   | TST_INSTDESC           |
      | Instrument Type          | Equity Share           |
      | Pricing Method           | 100 Pieces             |
      | Instrument System Status | Active                 |
      | Source Currency          | SGD - Singapore Dollar |
      | Target Currency          | USD - US Dollar        |

    And I add Market Listing for the Issue as below
      | Exchange Name             | UBS AG LONDON BRANCH EMEA TRADING |
      | Primary Market Indicator  | Original                          |
      | Market Status             | Acquired                          |
      | Trading Currency          | HKD - Hong Kong Dollar            |
      | Market Listing Created On | T                                 |
      | RDM Code                  | 123456                            |
    And I save the Issue details
    Then I expect the Issue record is moved to My WorkList for approval

    When I relogin to golden source UI with "task_authorizer" role
    Then I approve Issue record

    When I relogin to golden source UI with "task_assignee" role
    Then I expect Issue is created


  Scenario: TC_2: Close browsers
    Then I close all opened web browsers

  Scenario: TC_3: Create and Update IssuePrice

    Given I login to golden source UI with "task_assignee" role

    When I create a Pricing:Issue Price with following details
      | Instrument Name            | TST_INSTNAME            |
      | Price                      | 100                     |
      | Price Date/Time            | 29-Oct-2018             |
      | Price Type                 | 1 Week                  |
      | Price Source               | BNPAN                   |
      | Price Validity             | High Confidence         |
      | Pricing Method Type        | 1 week                  |
      | Price Quote Method         | 1/10                    |
      | Adjusted Through Date/Time | 29-Oct-2018 03:34:56 PM |


    And I save changes

    When I relogin to golden source UI with "task_authorizer" role
    And I approve a record from My WorkList with entity name "TST_INSTNAME"

    When I relogin to golden source UI with "task_assignee" role

    When I update issueprice "TST_INSTNAME" with following details
      | Price           | 200                                    |
      | Instrument Name | Malayan Banking Berhad 3.3% 29/08/2018 |

    And I save changes

    When I relogin to golden source UI with "task_authorizer" role
    And I approve a record from My WorkList with entity name "TST_INSTNAME"

    When I relogin to golden source UI with "task_assignee" role
    Then I expect the IssuePrice "Malayan Banking Berhad 3.3% 29/08/2018" is updated as below
      | Price           | 200                                    |
      | Instrument Name | Malayan Banking Berhad 3.3% 29/08/2018 |

  Scenario: TC_4: Close browsers
    Then I close all opened web browsers

  Scenario: TC_5: Run and Test the workflow "EIS_CompareJSON"

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

    And I execute below query and extract values of "ISID_EISSECID" into same variables
    """
     SELECT ISS_ID FROM FT_T_ISID WHERE  ID_CTXT_TYP = 'EISSECID' AND
      INSTR_ID = (SELECT INSTR_ID FROM FT_t_ISSU WHERE PREF_ISS_NME=  'TST_INSTNAME')
    """

  Scenario: TC_6: Verify Audit Report

    Given I login to golden source UI with "task_assignee" role


    When I search Audit Log Report with below details
      | Main Entity Type | EISIssuePrice                          |
      | Main Entity Name | Malayan Banking Berhad 3.3% 29/08/2018 |

    And I again search Audit Log Report with below details
      | GSO Field Name | Price |
      | Previous Value | 100   |
      | Current Value  | 200   |

    Then I expect GS table should have 1 rows

    And I again search Audit Log Report with below details
      | GSO Field Name | Instrument Name                        |
      | Previous Value | TST_INSTNAME                           |
      | Current Value  | Malayan Banking Berhad 3.3% 29/08/2018 |

    Then I expect GS table should have 1 rows

    And I again search Audit Log Report with below details
      | GSO Field Name | Preferred Identifier Value |
      | Previous Value | ${ISID_EISSECID}           |
      | Current Value  | ESL6491843                 |

    Then I expect GS table should have 1 rows

    And I again search Audit Log Report with below details
      | GSO Field Name | Preferred Identifier Type |
      | Previous Value | EISSECID                  |
      | Current Value  | EISLSTID                  |

    Then I expect GS table should have 1 rows


  Scenario: TC_7: Close browsers
    Then I close all opened web browsers
