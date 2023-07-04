#https://jira.pruconnect.net/browse/EISDEV-7412

@gc_interface_reuters @gc_interface_securities
@dmp_regression_integrationtest
@dmp_fundapps_regression @eisdev_7412

Feature: Test that SEDOL does not create multiple listings

  File1: B3PSBZ1 SEDOL on XSES listing should get loaded and create corresponding entries in ISID, MIXR, MKIS

  File2: B3PSBZ1 SEDOL on CHIJ listing should get loaded and update corresponding entries in ISID, MIXR, MKIS

  Scenario: Assign variables

    Given I assign "tests/test-data/dmp-interfaces/FundApps/Regression/Reuters/inbound" to variable "testdata.path"
    And I assign "gs_com00005861_test.csv" to variable "RT_INPUT_FILENAME1"
    And I assign "gs_com00005861_test2.csv" to variable "RT_INPUT_FILENAME2"
    And I set end_tms to SYSDATE in database "dmp.db.GC" where iss_id in "'B3PSBZ1'"

  Scenario: TC_1: Load the Reuters file to set up the instruments listing XSES

    When I process "${testdata.path}/${RT_INPUT_FILENAME1}" file with below parameters
      | FILE_PATTERN  | ${RT_INPUT_FILENAME1}    |
      | MESSAGE_TYPE  | EIS_MT_REUTERS_COMPOSITE |
      | BUSINESS_FEED |                          |
    Then I expect workflow is processed in DMP with success record count as "1"

  Scenario: TC_2: Verifications for Issu_identifier (ISID) and MIXR with market XSES

    Then I expect value of column "COUNT" in the below SQL query equals to "1":
    """
    select count(*) as COUNT from ft_t_isid isid, ft_t_mixr mixr
    where isid.isid_oid=mixr.isid_oid and isid.id_ctxt_typ='SEDOL'
    and isid.iss_id='B3PSBZ1' and isid.end_tms is null and mixr.end_tms is null
    """

    And I expect value of column "MKT" in the below SQL query equals to "XSES":
    """
    select mkid.mkt_id as MKT from ft_t_isid isid, ft_t_mixr mixr, ft_t_mkis mkis, ft_t_mkid mkid
    where isid.isid_oid=mixr.isid_oid
    and mkis.mkt_iss_oid=mixr.mkt_iss_oid and mkid.mkt_oid=mkis.mkt_oid and mkid.mkt_id_ctxt_typ='MIC'
    and mkis.end_tms is null and mkid.end_tms is null and isid.id_ctxt_typ='SEDOL'
    and isid.iss_id='B3PSBZ1' and isid.end_tms is null and mixr.end_tms is null
    """

  Scenario: TC_3: Load the Reuters file to set up the instruments listing CHIJ

    When I process "${testdata.path}/${RT_INPUT_FILENAME2}" file with below parameters
      | FILE_PATTERN  | ${RT_INPUT_FILENAME2}    |
      | MESSAGE_TYPE  | EIS_MT_REUTERS_COMPOSITE |
      | BUSINESS_FEED |                          |
    Then I expect workflow is processed in DMP with success record count as "1"

  Scenario: TC_4: Verifications for Issu_identifier (ISID) and MIXR with market XSES

    Then I expect value of column "COUNT" in the below SQL query equals to "1":
    """
    select count(*) as COUNT from ft_t_isid isid, ft_t_mixr mixr
    where isid.isid_oid=mixr.isid_oid and isid.id_ctxt_typ='SEDOL'
    and isid.iss_id='B3PSBZ1' and isid.end_tms is null and mixr.end_tms is null
    """

    And I expect value of column "MKT" in the below SQL query equals to "CHIJ":
    """
    select mkid.mkt_id as MKT from ft_t_isid isid, ft_t_mixr mixr, ft_t_mkis mkis, ft_t_mkid mkid
    where isid.isid_oid=mixr.isid_oid
    and mkis.mkt_iss_oid=mixr.mkt_iss_oid and mkid.mkt_oid=mkis.mkt_oid and mkid.mkt_id_ctxt_typ='MIC'
    and mkis.end_tms is null and mkid.end_tms is null and isid.id_ctxt_typ='SEDOL'
    and isid.iss_id='B3PSBZ1' and isid.end_tms is null and mixr.end_tms is null
    """

