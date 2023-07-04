#https://jira.pruconnect.net/browse/EISDEV-6532

@gc_interface_portfolios
@dmp_regression_unittest
@eisdev_6532
Feature: BRS DMP Security: Saving BCUSIP specific description

  Loading 2 records of same instrument but different listing, expectation is that there will be a separate description linked
  for each listing

  Scenario: TC_1: Load file

    Given I assign "esi_ADX_EOD_NON-ASIA_XQ_20210225_203000.sm.20210225.xml" to variable "INPUT_FILENAME_1"
    And I assign "tests/test-data/DevTest/EISDEV-6532" to variable "testdata.path"
    And I process "${testdata.path}/${INPUT_FILENAME_1}" file with below parameters
      | FILE_PATTERN  | ${INPUT_FILENAME_1}     |
      | MESSAGE_TYPE  | EIS_MT_BRS_SECURITY_NEW |
      | BUSINESS_FEED |                         |

    #Verification of  successfull File load
    Then I expect workflow is processed in DMP with total record count as "2"

  Scenario: TC_2: Verfication of ISDE

    Then I expect value of column "ISDE_B0MJ071" in the below SQL query equals to "1":
    """
    select count(*) as ISDE_B0MJ071 FROM ft_t_isde isde, ft_t_isid isid
    WHERE isid.instr_id=isde.instr_id
    and isid.isid_oid=isde.isid_oid
    and isid.iss_id='SB0MJ0719'
    and isid.id_ctxt_typ='BCUSIP'
    and isid.end_tms is null
    """

    Then I expect value of column "ISDE_SB0SKLV94" in the below SQL query equals to "1":
    """
    select count(*) as ISDE_SB0SKLV94 FROM ft_t_isde isde, ft_t_isid isid
    WHERE isid.instr_id=isde.instr_id
    and isid.isid_oid=isde.isid_oid
    and isid.iss_id='SB0SKLV94'
    and isid.id_ctxt_typ='BCUSIP'
    and isid.end_tms is null
    """