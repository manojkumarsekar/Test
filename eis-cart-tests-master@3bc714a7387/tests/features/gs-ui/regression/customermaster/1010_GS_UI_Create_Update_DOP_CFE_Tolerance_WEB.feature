@web @gc_ui_account_master @gs_ui_regression @eisdev_6756 @eisdev_6756_web @eisdev_71671 @eisdev_7180

#eisdev_6756 - Validating DOP Cash Flow Entry Tolerance, Actual Portfolio to maintain static data at the Portfolio Level for DOP Portfolios only
# EISDEV-7167 - Added new fields for Benchmarks,Drifted Benchmark and DOP Tolerance in Account Master screen
# eisdev_7180 - Account master enhancements for breaking the BDD

Feature: Create or Update Account Master with DOP Cash Flow Tolerance and Actual portfolio Mapping

  This feature file can be used to check the DOP Cash Flow Entry Tolerance (Target, Upper and Lower) and Actual portfolio relationship in the account master insert and update functionality over UI.
  This handles both  maker and checker event require to update account master.

  As part of eisdev_6756 - 4 new fields are added in the account master - DOP Cash Flow Tolerance Section.
  1. DOP vs Actual Portfolio - It is lookup to account master, Link between DOP portfolio and Actual Portfolio, This detail store into ft_t_accr table where rl_typ=DOPAPPRT
  2. Target Percent  - This detail store into FT_T_FNVD.TRGT_ALLOC_CPCT
  3, Lower Tolerance Percent    - This detail store into FT_T_FNVD.MIN_SHR_CAMT
  4, Upper Tolerance Percent    - This detail store into FT_T_FNVD.MAX_SHR_CAMT

  Scenario: Update Portfolio/Account Master with DOP Cash Flow Tolerance Section

    Given I login to golden source UI with "task_assignee" role

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

    When I add the parties details in account master with following details
      | Investment Manager          | EASTSPRING INVESTMENTS (SINGAPORE) LIMITED |
      | Investment Manager Location | SG-Singapore                               |

    When I add the DOPCashflowdetails in account master with following details
      | DOP vs Actual Portfolio | TS LIFE |
      | Target Percent          | 0.1     |
      | Lower Tolerance Percent | 0.0     |
      | Upper Tolerance Percent | 0.2     |

    And I save the valid data

    When I relogin to golden source UI with "task_authorizer" role
    Then I approve a record from My WorkList with entity name "TST_PORTFOLIO_${VAR_RANDOM}"

    When I relogin to golden source UI with "task_assignee" role

    Given I open account master "TST_PORTFOLIO_${VAR_RANDOM}" for the given portfolio

    And I update DOPCashflowdetails in account master with below details
      | DOP vs Actual Portfolio | PRU ASS LIFE FD |
      | Target Percent          | 0.3             |
      | Lower Tolerance Percent | 0.1             |
      | Upper Tolerance Percent | 0.4             |

    And I save the modified data

    Then I expect a record in My WorkList with entity name "TST_PORTFOLIO_${VAR_RANDOM}"

    When I relogin to golden source UI with "task_authorizer" role
    Then I approve a record from My WorkList with entity name "TST_PORTFOLIO_${VAR_RANDOM}"

    When I relogin to golden source UI with "task_assignee" role

    Then I expect Account Master "TST_PORTFOLIO_${VAR_RANDOM}" is created

    Then I expect DOPCashFlow details in Account Master is updated as below
      | DOP vs Actual Portfolio | PRU ASS LIFE FD |
      | Target Percent          | 0.3             |
      | Lower Tolerance Percent | 0.1             |
      | Upper Tolerance Percent | 0.4             |

