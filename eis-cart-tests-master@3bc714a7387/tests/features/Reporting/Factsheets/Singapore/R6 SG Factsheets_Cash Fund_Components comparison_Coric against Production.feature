#https://jira.intranet.asia/browse/TOM-4919

@ignore_hooks @factsheet_cashfund_components

  Feature: Comparison of vendor generated factsheet against current production for Cash Fund

    Background: Setting up prerequisites

      Given I assign "tests/test-data/Reporting/Factsheet/Singapore/pdf" to variable "PDF_TESTDATA_PATH"

     @key_information_cashfund
     Scenario: Compare the Key information component in Coric factsheet against Morningstar factsheet
       #Extract the values in Coric factsheet and Morningstar factsheet and compare the Key information component
       #filename.pdf to be replaced with actual pdf names once available

      Given I load pdf file "${PDF_TESTDATA_PATH}/Coric/filename.pdf" for processing
      Then I extract pdf file page 1 data into variable "CORIC_PAGE1_DATA"
      Given I load pdf file "${PDF_TESTDATA_PATH}/Morningstar/filename.pdf" for processing
      Then I extract pdf file page 1 data into variable "MORNINGSTAR_PAGE1_DATA"

      And I expect pdf file should contains below values with given expected number of occurrences

        |KEY INFORMATION  | 1 |

      And I evaluate|verify below regex values in the target string "${CORIC_PAGE1_DATA}" with occurrence index 1

        | Fund size \(mil\) REGEX{CORIC_FUND_SIZE_VAR}                                         |
        | Fund base currency REGEX{CORIC_FUND_CCY_VAR}                                         |
        | Fund dealing frequency REGEX{CORIC_FUND_FREQ_VAR}                                    |
        | Net asset value REGEX{CORIC_FUND_NAV_VAR}                                            |
        | ISIN REGEX{CORIC_ISIN_VAR}                                                           |
        | Bloomberg ticker REGEX{CORIC_BB_TICK_VAR}                                            |
        | Inception date REGEX{CORIC_INDATE_VAR}                                               |
        | (?s)Benchmark \(BM\)\\s?\\r?\\nREGEX{CORIC_BM_VAR}INVESTMENT OBJECTIVE               |
        | Subscription method REGEX{CORIC_SUBS_VAR}                                            |
        | Min initial investment REGEX{CORIC_MIN_INI_INV_VAR}                                  |
        | Min subsequent investment REGEX{CORIC_MIN_SUB_INV_VAR}                               |
        | Initial sales charges\% \(max\) REGEX{CORIC_INI_SALES_VAR}                           |
        | (?)Annual management fee\% \(Current\)\\s?\\r?\\nREGEX{CORIC_ANN_FEE_VAR}COUNTERPARTY|

      And I evaluate|verify below regex values in the target string "${MORNINGSTAR_PAGE1_DATA}" with occurrence index 1

        | Fund size \(mil\) REGEX{MS_FUND_SIZE_VAR}                                         |
        | Fund base currency REGEX{MS_FUND_CCY_VAR}                                         |
        | Fund dealing frequency REGEX{MS_FUND_FREQ_VAR}                                    |
        | Net asset value REGEX{MS_FUND_NAV_VAR}                                            |
        | ISIN REGEX{MS_ISIN_VAR}                                                           |
        | Bloomberg ticker REGEX{MS_BB_TICK_VAR}                                            |
        | Inception date REGEX{MS_INDATE_VAR}                                               |
        | (?s)Benchmark \(BM\)\\s?\\r?\\nREGEX{MS_BM_VAR}INVESTMENT OBJECTIVE               |
        | Subscription method REGEX{MS_SUBS_VAR}                                            |
        | Min initial investment REGEX{MS_MIN_INI_INV_VAR}                                  |
        | Min subsequent investment REGEX{MS_MIN_SUB_INV_VAR}                               |
        | Initial sales charges\% \(max\) REGEX{MS_INI_SALES_VAR}                           |
        | (?)Annual management fee\% \(Current\)\\s?\\r?\\nREGEX{MS_ANN_FEE_VAR}COUNTERPARTY|


      And I expect the value of var "${CORIC_FUND_SIZE_VAR}" equals to "${MS_FUND_SIZE_VAR}"
      And I expect the value of var "${CORIC_FUND_CCY_VAR}" equals to "${MS_FUND_CCY_VAR}"
      And I expect the value of var "${CORIC_FUND_FREQ_VAR}" equals to "${MS_FUND_FREQ_VAR}"
      And I expect the value of var "${CORIC_FUND_NAV_VAR}" equals to "${MS_FUND_NAV_VAR}"
      And I expect the value of var "${CORIC_ISIN_VAR}" equals to "${MS_ISIN_VAR}"
      And I expect the value of var "${CORIC_BB_TICK_VAR}" equals to "${MS_BB_TICK_VAR}"
      And I expect the value of var "${CORIC_INDATE_VAR}" equals to "${MS_INDATE_VAR}"
      And I expect the value of var "${CORIC_BM_VAR}" equals to "${MS_BM_VAR}"
      And I expect the value of var "${CORIC_SUBS_VAR}" equals to "${MS_SUBS_VAR}"
      And I expect the value of var "${CORIC_MIN_INI_INV_VAR}" equals to "${MS_MIN_INI_INV_VAR}"
      And I expect the value of var "${CORIC_MIN_SUB_INV_VAR}" equals to "${MS_MIN_SUB_INV_VAR}"
      And I expect the value of var "${CORIC_INI_SALES_VAR}" equals to "${MS_INI_SALES_VAR}"
      And I expect the value of var "${CORIC_ANN_FEE_VAR}" equals to "${MS_ANN_FEE_VAR}"
       

    @investment_objective_cashfund
    Scenario: Compare the Investment Objective in Coric factsheet against Morningstar factsheet
       #Extract the values in Coric factsheet and Morningstar factsheet and compare the Investment Objective
       #filename.pdf to be replaced with actual pdf names once available

      Given I load pdf file "${PDF_TESTDATA_PATH}/Coric/filename.pdf" for processing
      Then I extract pdf file page 1 data into variable "CORIC_PAGE1_DATA"
      Given I load pdf file "${PDF_TESTDATA_PATH}/Morningstar/filename.pdf" for processing
      Then I extract pdf file page 1 data into variable "MORNINGSTAR_PAGE1_DATA"

      And I evaluate|verify below regex values in the target string "${CORIC_PAGE1_DATA}" with occurrence index 1

        |(?s)INVESTMENT OBJECTIVE\\s?\\r?\\n?REGEX{CORIC_INV_OBJ_VAR}FUND MEASURES|

      And I evaluate|verify below regex values in the target string "${MORNINGSTAR_PAGE1_DATA}" with occurrence index 1

        |(?s)INVESTMENT OBJECTIVE\\s?\\r?\\n?REGEX{MS_INV_OBJ_VAR}PERFORMANCE|

      And I expect the value of var "${CORIC_INV_OBJ_VAR}" equals to "${MS_INV_OBJ_VAR}"


    @performance_cashfund
    Scenario: Compare the Performance Table in Coric factsheet against Morningstar factsheet
       #Extract the values in Coric factsheet and Morningstar factsheet and compare the Performance
       #filename.pdf to be replaced with actual pdf names once available

      Given I load pdf file "${PDF_TESTDATA_PATH}/Coric/filename.pdf" for processing
      Then I extract pdf file page 1 data into variable "CORIC_PAGE1_DATA"
      Given I load pdf file "${PDF_TESTDATA_PATH}/Morningstar/filename.pdf" for processing
      Then I extract pdf file page 1 data into variable "MORNINGSTAR_PAGE1_DATA"

      And I evaluate|verify below regex values in the target string "${CORIC_PAGE1_DATA}" with occurrence index 2

        | Offer-bid REGEX{CORIC_PERF_OFF_BID_VAR} |
        | Bid-bid REGEX{CORIC_PERF_BID_BID_VAR}   |
        | Benchmark REGEX{CORIC_PERF_BM_VAR}      |

      And I evaluate|verify below regex values in the target string "${MORNINGSTAR_PAGE1_DATA}" with occurrence index 1

        | Offer-bid REGEX{MS_PERF_OFF_BID_VAR} |
        | Bid-bid REGEX{MS_PERF_BID_BID_VAR}   |
        | Benchmark REGEX{MS_PERF_BM_VAR}      |

      And I expect the value of var "${CORIC_PERF_OFF_BID_VAR}" equals to "${MS_PERF_OFF_BID_VAR}"
      And I expect the value of var "${CORIC_PERF_BID_BID_VAR}" equals to "${MS_PERF_BID_BID_VAR}"
      And I expect the value of var "${CORIC_PERF_BM_VAR}" equals to "${MS_PERF_BM_VAR}"


    @remaining_placement_cashfund
    Scenario: Compare the Remaining Placement to Maturity in Coric factshee against Morningstar factsheet
       #Extract the values in Coric factsheet and Morningstar factsheet and compare the Remaining Placement to Maturity
       # filename.pdf to be replaced with actual pdf names once available

      Given I load pdf file "${PDF_TESTDATA_PATH}/Coric/filename.pdf" for processing
      Then I extract pdf file page 1 data into variable "CORIC_PAGE1_DATA"
      Given I load pdf file "${PDF_TESTDATA_PATH}/Morningstar/filename.pdf" for processing
      Then I extract pdf file page 1 data into variable "MORNINGSTAR_PAGE1_DATA"

      And I evaluate|verify below regex values in the target string "${CORIC_PAGE1_DATA}" with occurrence index 1

        |(?s)REMAINING PLACEMENT PERIOD TO MATURITY \(\%\)\\s?\\r?\\n?REGEX{CORIC_REM_MATU_VAR}Factsheet|

      And I evaluate|verify below regex values in the target string "${MORNINGSTAR_PAGE1_DATA}" with occurrence index 1

        |(?s)REMAINING PLACEMENT PERIOD TO MATURITY \(\%\)\\s?\\r?\\n?REGEX{MS_REM_MATU_VAR}Factsheet|

      And I expect the value of var "${CORIC_REM_MATU_VAR}" equals to "${MS_REM_MATU_VAR}"


    @counterparty_cashfund
    Scenario: Compare the Counterparty table in Coric factsheet against Morningstar factsheet
       #Extract the values in Coric factsheet and Morningstar factsheet and compare the Counterparty table
       #filename.pdf to be replaced with actual pdf names once available

      Given I load pdf file "${PDF_TESTDATA_PATH}/Coric/filename.pdf" for processing
      Then I extract pdf file page 1 data into variable "CORIC_PAGE1_DATA"
      Given I load pdf file "${PDF_TESTDATA_PATH}/Morningstar/filename.pdf" for processing
      Then I extract pdf file page 1 data into variable "MORNINGSTAR_PAGE1_DATA"

      And I evaluate|verify below regex values in the target string "${CORIC_PAGE1_DATA}" with occurrence index 1

        |(?s)COUNTERPARTY\\s?\\r?\\n?REGEX{CORIC_COUNTERPARTY_VAR}INVESTMENT OBJECTIVE|

      And I evaluate|verify below regex values in the target string "${MORNINGSTAR_PAGE1_DATA}" with occurrence index 1

        |(?s)COUNTERPARTY\\s?\\r?\\n?REGEX{MS_COUNTERPARTY_VAR}INVESTMENT OBJECTIVE|

      And I expect the value of var "${CORIC_COUNTERPARTY_VAR}" equals to "${MS_COUNTERPARTY_VAR}"