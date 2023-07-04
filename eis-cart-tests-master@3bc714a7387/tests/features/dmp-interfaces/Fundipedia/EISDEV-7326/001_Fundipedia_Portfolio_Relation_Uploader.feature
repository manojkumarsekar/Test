#https://jira.pruconnect.net/browse/EISDEV-7326
#https://collaborate.pruconnect.net/display/EISPRM/Portfolio+Relationship
#https://collaborate.pruconnect.net/pages/viewpage.action?spaceKey=EISTOMR4&title=ShareClass+Integration

# ===================================================================================================================================================================================
# Date            JIRA           Comments
# ===================================================================================================================================================================================
# 25/02/2020      EISDEV-7326    MDX to Store Portfolio relationship data received from Fundipedia
# ===================================================================================================================================================================================


@dmp_regression_unittest @gc_interface_shareclass @gc_interface_fundipedia
@eisdev_7326

Feature: Fundipedia Portfolio relation uploader

  This feature tests the portfolio relation uploader for Fundipedia

  Scenario: Initialize all the variables and setup data

    Given I assign "tests/test-data/dmp-interfaces/Fundipedia/EISDEV-7326" to variable "testdata.path"
    And I assign "Portfolio_relation_test.xml" to variable "INPUT_FILE_NAME"
    When I execute below query to "Clear data for the given trades from ft_t_extr"
    """
    delete from ft_t_accr where
     rep_acct_id in (select acct_id from ft_t_acid where acct_alt_id='ALGENF_M' and acct_id_ctxt_typ='CRTSID')
     and acct_id in (select acct_id from ft_t_acid where acct_alt_id='ASUMIP' and acct_id_ctxt_typ='CRTSID')
    """

  Scenario: Load the portfolio relation uploader file

    When I process "${testdata.path}/${INPUT_FILE_NAME}" file with below parameters
      | FILE_PATTERN  | ${INPUT_FILE_NAME}                   |
      | MESSAGE_TYPE  | EIS_MT_FUNDIPEDIA_DMP_PORTFOLIO_REL |
      | BUSINESS_FEED |                                      |
    Then I expect workflow is processed in DMP with total record count as "2"
    Then I expect workflow is processed in DMP with success record count as "1"

  Scenario: Verify the fundipedia fields saved correctly against the portfolio

    Then I expect value of column "RELATION_COUNT" in the below SQL query equals to "1":
    """
      select count(1) as RELATION_COUNT from ft_t_accr where
      rep_acct_id in (select acct_id from ft_t_acid where acct_alt_id='ALGENF_M' and acct_id_ctxt_typ='CRTSID')
      and acct_id in (select acct_id from ft_t_acid where acct_alt_id='ASUMIP' and acct_id_ctxt_typ='CRTSID')
    """





