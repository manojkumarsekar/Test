@web @gs_ui_regression @eisdev_6840 @eisdev_7041 @eisdev_7167
@gc_ui_account_master @gc_ui_worklist @eisdev_7153 @eisdev_7180 @eisdev_7458

#eisdev_6840 - Added new gherkin line for method segregation and added new parties fields for verifications
# eisdev_7180 - Account master enhancements for breaking the BDD
#EISDEV-7458 : Disable drools for MainEntityID and MainEntityIdCtxtTyp and move to java rule to suppress additional changes shown for those 2 fields on UI

Feature: Create and Update Account Master with Parties details

  This feature file can be used to check the Parties details in the account master insert and update functionality over UI.
  This handles both the maker checker event require to update account master.
  It checks if ATENTYP and ATENID is created in ACST

  Scenario: Update Portfolio/Account Master with Parties details

    Given I assign "60% MSCI World index + 40% FTSE World Government Bond Index SGD G" to variable "VAR_BNP_PRIM_BM"
    And I assign "Fund Has No Benchmark in VND" to variable "VAR_BNP_SEC_BM"
    And I assign "Quantshop MGS Bond Index 3-7 Years MYR" to variable "VAR_BNP_PRIM_BM_NEW"
    And I assign "VIETNAM 5 YEARS GOVERNMENT BOND VND" to variable "VAR_BNP_SEC_BM_NEW"
    And I assign "QSMGS3-7" to variable "VAR_DOP_BM_NEW_CODE"
    And I login to golden source UI with "task_assignee" role

    And I generate value with date format "MSs" and assign to variable "VAR_RANDOM"

    When I add Portfolio Details for the Account Master as below
      | Portfolio Name          | TST_PORTFOLIO_${VAR_RANDOM} |
      | Portfolio Legal Name    | Test_LegalPortfolio         |
      | Inception Date          | T                           |
      | Base Currency           | USD-US Dollar               |
      | Processed/Non Processed | NON-PROCESSED               |

    When I add Legacy Identifiers details for the Account Master as below
      | CRTS Portfolio Code | CRTS_${VAR_RANDOM} |

    When  I add LBU Identifiers details for the Account Master as below
      | TSTAR Portfolio Code    | TSTAR_${VAR_RANDOM} |
      | Korea MD Portfolio Code | TMD_${VAR_RANDOM}   |

    When I add XReference details for the Account Master as below
      | IRP Code | IRP_${VAR_RANDOM} |

    When I add Regulatory for the Account Master as below
      | MAS Category | A2-FUNDS UNDER ADVISORY SERVICE |

    When I add the parties details in account master with following details
      | Investment Manager                 | EASTSPRING INVESTMENTS (SINGAPORE) LIMITED |
      | Investment Manager Location        | SG-Singapore                               |
      | Investment Manager Level 3 LE Name | PRUDENCE FOUNDATION                        |
      | Investment Manager Level 4 LE Name | BOCI-PRUDENTIAL ASSET MANAGEMENT LIMITED   |

    And I save the valid data

    When I relogin to golden source UI with "task_authorizer" role
    Then I approve a record from My WorkList with entity name "TST_PORTFOLIO_${VAR_RANDOM}"

    Then I expect value of column "ATENTYP_CREATE_VERIFICATION" in the below SQL query equals to "PASS":
    """
      select case when count(1) = 1 then 'PASS' else 'FAIL' end ATENTYP_CREATE_VERIFICATION
      from ft_t_acid crtsid, ft_t_acid eisprtid, ft_t_acst acst
      where crtsid.acct_id_ctxt_typ = 'CRTSID' and crtsid.acct_alt_id = 'CRTS_${VAR_RANDOM}'
      and crtsid.end_tms is null and eisprtid.acct_id_ctxt_typ = 'EISPRTID'
      and eisprtid.acct_id = crtsid.acct_id and eisprtid.end_tms is null
      and eisprtid.acct_id = acst.acct_id and acst.stat_def_id = 'ATENTYP'
      and eisprtid.acct_id_ctxt_typ = acst.stat_char_val_txt
    """

    Then I expect value of column "ATENID_CREATE_VERIFICATION" in the below SQL query equals to "PASS":
    """
      select case when count(1) = 1 then 'PASS' else 'FAIL' end ATENID_CREATE_VERIFICATION
      from ft_t_acid crtsid, ft_t_acid eisprtid, ft_t_acst acst
      where crtsid.acct_id_ctxt_typ = 'CRTSID' and crtsid.acct_alt_id = 'CRTS_${VAR_RANDOM}'
      and crtsid.end_tms is null and eisprtid.acct_id_ctxt_typ = 'EISPRTID'
      and eisprtid.acct_id = crtsid.acct_id and eisprtid.end_tms is null
      and eisprtid.acct_id = acst.acct_id and acst.stat_def_id = 'ATENID'
      and eisprtid.acct_alt_id = acst.stat_char_val_txt
    """

    When I relogin to golden source UI with "task_assignee" role

    Given I open account master "TST_PORTFOLIO_${VAR_RANDOM}" for the given portfolio

    When I update portfolio details in account master with following details
      | Processed/Non Processed | PROCESSED |

    Then I update Fund Details in account Master as below
      | Fund Category | LIFE - LIFE |

    When I update parties in account master details for portfolio with below details
      | Investment Manager Level 3 LE Name | PRUDENTIAL SINGAPORE HOLDINGS PTE. LIMITED |
      | Investment Manager Level 4 LE Name | PCA LIFE ASSURANCE CO. LTD.                |

    And I save the valid data

    Then I expect a record in My WorkList with entity name "TST_PORTFOLIO_${VAR_RANDOM}"

    When I relogin to golden source UI with "task_authorizer" role
    Then I approve a record from My WorkList with entity name "TST_PORTFOLIO_${VAR_RANDOM}"

    When I relogin to golden source UI with "task_assignee" role

    Then I expect Account Master "TST_PORTFOLIO_${VAR_RANDOM}" is created

    Then I expect portfolio details in Account Master is updated as below
      | Processed/Non Processed | PROCESSED |

    Then I expect fund details in Account Master is updated as below
      | Fund Category | LIFE - LIFE |

    Then I expect parties details in Account Master is updated as below
      | Investment Manager Level 3 LE Name | PRUDENTIAL SINGAPORE HOLDINGS PTE. LIMITED |
      | Investment Manager Level 4 LE Name | PCA LIFE ASSURANCE CO. LTD.                |
