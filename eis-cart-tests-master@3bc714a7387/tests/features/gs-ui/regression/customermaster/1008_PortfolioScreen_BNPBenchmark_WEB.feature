#https://jira.intranet.asia/browse/TOM-5123
#EISDEV-7167 - Added new fields for Benchmarks,Drifted Benchmark and DOP Tolerance in Account Master screen
# eisdev_7180 - Account master enhancements for breaking the BDD

@tom_5123 @web @gs_ui_regression @reporting_dmp_ui @tom_5139 @gc_ui_account_master @eisdev_7167 @eisdev_7180

Feature: Test the additional fields added for Reporting
  BNP Primary Benchmark - 60% MSCI World index + 40% FTSE World Government Bond Index SGD G
  BNP Secondary Benchmark - Fund Has No Benchmark in VND

  Scenario: Create New Portfolio/Account Master

    Given I login to golden source UI with "task_assignee" role
    And I generate value with date format "MSs" and assign to variable "VAR_RANDOM"
    And I assign "60% MSCI World index + 40% FTSE World Government Bond Index SGD G" to variable "VAR_BNP_PRIM_BM"
    And I assign "Quantshop MGS Bond Index 3-7 Years MYR" to variable "VAR_BNP_PRIM_BM_NEW"
    And I assign "Fund Has No Benchmark in VND" to variable "VAR_BNP_SEC_BM"
    And I assign "VIETNAM 5 YEARS GOVERNMENT BOND VND" to variable "VAR_BNP_SEC_BM_NEW"

    When I add Portfolio Details for the Account Master as below
      | Portfolio Name          | TST_PORTFOLIO_${VAR_RANDOM} |
      | Portfolio Legal Name    | Test_LegalPortfolio         |
      | Inception Date          | T                           |
      | Base Currency           | USD-US Dollar               |
      | Processed/Non Processed | NON-PROCESSED               |

    When I add Fund Details for the Account Master as below
      | Fund Category | LIFE - LIFE |

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

    When I add the Benchmark details in account master with following details
      | BNP Primary L1 ESI Benchmark Name   | ${VAR_BNP_PRIM_BM} |
      | BNP Secondary L1 ESI Benchmark Name | ${VAR_BNP_SEC_BM}  |
      | BNP Primary L3 ESI Benchmark Name   | ${VAR_BNP_PRIM_BM  |

    When I add the DOPDriftedBenchmark details in account master with following details
      | ESI Benchmark Name | ${VAR_BNP_PRIM_BM} |

    And I save the valid data

    When I relogin to golden source UI with "task_authorizer" role

    Then I approve a record from My WorkList with entity name "TST_PORTFOLIO_${VAR_RANDOM}"

    When I relogin to golden source UI with "task_assignee" role

    Given I open account master "TST_PORTFOLIO_${VAR_RANDOM}" for the given portfolio

    And I update Benchmark in account master with below details
      | BNP Primary L1 ESI Benchmark Name   | ${VAR_BNP_PRIM_BM_NEW} |
      | BNP Secondary L1 ESI Benchmark Name | ${VAR_BNP_SEC_BM_NEW}  |
      | BNP Primary L3 ESI Benchmark Name   | ${VAR_BNP_PRIM_BM_NEW} |

    And I update DOPDriftedBenchmark in account master with below details
      | ESI Benchmark Name | ${VAR_BNP_PRIM_BM_NEW} |

    And I save the modified data

    Then I expect a record in My WorkList with entity name "TST_PORTFOLIO_${VAR_RANDOM}"

    When I relogin to golden source UI with "task_authorizer" role
    Then I approve a record from My WorkList with entity name "TST_PORTFOLIO_${VAR_RANDOM}"

    When I relogin to golden source UI with "task_assignee" role

    Then I expect Account Master "TST_PORTFOLIO_${VAR_RANDOM}" is created

    Then I expect Benchmark details in Account Master is updated as below
      | BNP Primary L1 ESI Benchmark Name   | ${VAR_BNP_PRIM_BM_NEW} |
      | BNP Secondary L1 ESI Benchmark Name | ${VAR_BNP_SEC_BM_NEW}  |
      | BNP Primary L3 ESI Benchmark Name   | ${VAR_BNP_PRIM_BM_NEW} |

    Then I expect DOPBenchmark details in Account Master is updated as below
      | ESI Benchmark Name     | ${VAR_BNP_PRIM_BM_NEW}    |
      | Aladdin Benchmark Code | ${ALADDIN_BENCHMARK_CODE} |

