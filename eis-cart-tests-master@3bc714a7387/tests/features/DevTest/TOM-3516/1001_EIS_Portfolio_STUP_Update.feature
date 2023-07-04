#https://jira.intranet.asia/browse/TOM-3338

@gc_interface_portfolios
@dmp_regression_unittest
@tom_3516 @1001_stup_verification
Feature: Loading Portfolio template data to test FT_T_STUP(Setup Status) table should be created for Account Entity

  Its fix for production defect

  MDDF and STUP entries for Portfolio entity were removed.
  We need add these entries back and enable cdc on these tables.
  At the same time we would need a control m job to re-valuate all the portfolios completeness again.

  After loading file Entry should be created in FT_T_STUP table for Account Entity.

  Scenario: TC_1: Load Portfolio file and Verify data in FT_T_STUP

    Given I assign "PORTFOLIO_TEMPLATE_TC1.xlsx" to variable "INPUT_FILENAME"

    And I assign "tests/test-data/DevTest/TOM-3516" to variable "testdata.path"

    When I copy files below from local folder "${testdata.path}" to the host "dmp.ssh.inbound" folder "${dmp.ssh.inbound.path}":
      | ${INPUT_FILENAME} |

    Given I extract below values for row 2 from EXCEL file "${INPUT_FILENAME}" in local folder "${testdata.path}" and assign to variables:
      | PORTFOLIO_NAME | VAR_ACCTNAME |
      | CRTS_ID        | VAR_CRTSID   |

    And I execute below query
	  """
	  DELETE fT_T_stup where tbl_typ='ACCT' AND CROSS_REF_ID in
	  (SELECT cross_ref_id as CROSS_REF_VAR FROM Ft_t_ACCT WHERE ACCT_Id in (SELECT ACCT_Id FROM Ft_t_ACID WHERE ACCT_ALT_ID='${VAR_CRTSID}'));
	  UPDATE FT_T_ACID SET END_TMS=SYSDATE WHERE ACCT_ID IN (SELECT ACCT_ID FROM Ft_T_ACID WHERE ACCT_ALT_ID = '${VAR_CRTSID}');
	  """

    When I copy files below from local folder "${testdata.path}" to the host "dmp.ssh.inbound" folder "${dmp.ssh.inbound.path}":
      | ${INPUT_FILENAME} |

    Given I process files with below parameters and wait for the job to be completed
      | BUSINESS_FEED |                                      |
      | FILE_PATTERN  | ${INPUT_FILENAME}                    |
      | MESSAGE_TYPE  | EIS_MT_RDM_PORTFOLIO_MASTER_TEMPLATE |

    Then I expect value of column "ID_COUNT" in the below SQL query equals to "1":
      """
      SELECT COUNT(*) AS ID_COUNT FROM FT_T_STUP
	  WHERE TBL_TYP='ACCT'
	  AND CROSS_REF_ID IN (SELECT cross_ref_id as CROSS_REF FROM Ft_t_ACCT WHERE ACCT_Id in 
	  (SELECT ACCT_Id FROM Ft_t_ACID WHERE ACCT_ALT_ID='${VAR_CRTSID}'  and end_tms is null))
	  AND END_TMS IS NULL
      """