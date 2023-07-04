#TOM-4335 - avoid deleting all data from ft_t_wagp and ft_t_wagr which was affecting other regression tests

@dw_interface_portfolios
@dmp_dw_regression
@tom_3574 @tom_4335
Feature: Test keystreaming of BNP month-end portfolio file

  Each portfolio is owned by a client. The client is represented in the BNP field "CLIENT_PORTFOLIO_GROUPING_NAME".
  A client may own more than one portfolio. This test is to ensure that we do not create multiple account groups for
  a single client when loading BNP's portfolio file.

  Background:

    Given I set the DMP workflow web service endpoint to named configuration "dwh.ws.WORKFLOW"
    And I set the database connection to configuration "dmp.db.DW"

  Scenario: Set max polling time variable

  #By default job polling time is 300sec for inbound. Since these are testing jobs, we don't want to wait 40sec in case of failures
  #so setting to 80sec and removing this variable at the end
    Given I assign "80" to variable "workflow.max.polling.time"

  Scenario: TC_1: Clear old test data and setup variables

    Given I assign "tests/test-data/DevTest/TOM-3574" to variable "testdata.path"
    And I assign "2012-DEC-31" to variable "ME_DATE"

    And I execute below query
      """
      DELETE ft_t_wagp WHERE rptg_prd_end_dte = TO_DATE('${ME_DATE}','yyyy-mon-dd');
      DELETE ft_t_wagr WHERE version_end_tmsmp = TO_DATE('${ME_DATE}','yyyy-mon-dd');
      """

    And I modify date "${ME_DATE}" with "+0d" from source format "yyyy-MMM-dd" to destination format "yyyyMMdd" and assign to "ME_DATE_YYYYMMDD"
    #
    # Using input file substitution to create a new version of the expected output, to be used in the eventual reconciliation
    #
    And I create input file "ESIPME_PFL_${ME_DATE_YYYYMMDD}.out" using template "ESIPME_PFL_template.out" with below codes from location "${testdata.path}"
      |  |  |

  Scenario: TC_2: Load BNP portfolio file

    Given I copy files below from local folder "${testdata.path}/testdata" to the host "dmp.ssh.inbound" folder "${dmp.ssh.inbound.path}":
      | ESIPME_PFL_${ME_DATE_YYYYMMDD}.out |

    And I process files with below parameters and wait for the job to be completed
      | BUSINESS_FEED |                                    |
      | FILE_PATTERN  | ESIPME_PFL_${ME_DATE_YYYYMMDD}.out |
      | MESSAGE_TYPE  | EIS_MT_BNP_MOPK_PFL                |

  Scenario: TC_3: Confirm we do not have any duplicate groups created

    Then I expect value of column "DUPE_WAGR_COUNT" in the below SQL query equals to "0":
      """
      SELECT COUNT(*) AS DUPE_WAGR_COUNT
      FROM   (SELECT acct_grp_nme FROM ft_t_wagr WHERE version_end_tmsmp = TO_DATE('${ME_DATE}','yyyy-mon-dd') GROUP BY acct_grp_nme HAVING COUNT(*) > 1)
      """

  Scenario: Cleanup max polling time variable
    Then I remove variable "workflow.max.polling.time" from memory