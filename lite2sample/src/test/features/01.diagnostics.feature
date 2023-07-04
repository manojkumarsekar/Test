@solvency @regression
Feature: Solvency validation scenarios
# Note: reports can be generated for months of data available in DB. targetMonth input should align with the same

  @EISGEISAPPS-1003 @ui @fileCompare @smoke
  Scenario Outline: TC_03: Verify the GHO CI-CD1-D2O Reports
    Given the user launch Solvency app
    When the user navigate from home to validation <reportName> page
    And  the user download <LBU> LBU <reportName> report for <targetMonth> month from validation pages
    Then the user expect CIC records in <sheetNames> sheets from downloaded <LBU> LBU <reportName> report to match with <referenceReportFile> reference files

    Examples:
      | reportName | LBU      | sheetNames                                             | referenceReportFile                                     | targetMonth |
      | CIC_D1_D2O | LBU_1090 | CIC_Error,D1_Error,GHO_INS_OP,ASSET_CHANGE,Missing_CCY | 4-00_GHOValidationReport_PITL_1090_Reference_Report.xls | current-5   |


  @EISGEISAPPS-1023 @ui @fileCompare @smoke
  Scenario Outline: TC_03: Verify the LBU and Consol Data Comparison Reports
    Given the user launch Solvency app
    When the user navigate from home to validation <reportName> page
    And  the user download <LBU> LBU <reportName> report for <targetMonth> month from LBUConsol reports page
    Then the user expect records in <sheetNames> sheets from downloaded <LBU> LBU <reportName> report for <targetMonth> month to match with <referenceReportFile> reference files
    Examples:
      | reportName       | LBU      | sheetNames                   | referenceReportFile                                            | targetMonth |
      | LBUConsol_Report | LBU_1090 | LBUandConsolDataComp_Reports | 4-00_LBUConsolCompareReport_TRP_PITL_1090_REFERENCE_REPORT.xls | current-5   |


  @EISGEISAPPS-920 @ui @fileCompare
  Scenario Outline: TC_03: Verify the Fx Rate Comparison Reports
    Given the user launch Solvency app
    When the user navigate from home to validation <reportName> page
    And  the user download <LBU> LBU <reportName> report for current-5 month from LBUConsol reports page
    Then the user expect records in <sheetNames> sheets from downloaded <LBU> LBU <reportName> report for <targetMonth> month to match with <referenceReportFile> reference files
    Examples:
      | reportName              | LBU      | sheetNames              | referenceReportFile                                        | targetMonth |
      | FxRateComparison_Report | LBU_1090 | FXRateComparison_Report | 4-00_FXRateComparisonReport_PITL_1090_REFERENCE_REPORT.xls | current-5   |



      @modelFeature @smoke
      Feature: Model feature file and scenarios to illustrate cart framework

        @ui @jira-test01
        Scenario: TC_01: Launch and login app
          Given I login to golden source UI with "task_assignee" role

        @ui @jira-test02
        Scenario Outline: TC_02: Search text in google app
          Given I launch google app
          When I search "<input>" in google app
          Then I close google app

          Examples:
            | input   |
            | search1 |
            | search2 |

        @db @jira-test03
        Scenario: TC_03: Execute a sql query statement
          Given I execute "SELECT bnch_oid from fT_T_bnid;" statement in dmp gc db

        @db @jira-test04
        Scenario: TC_04: Execute a sql query file
          Given I execute sql file "sample.sql" in dmp gc db

        @db @jira-test05
        Scenario: TC_05: Execute a sql query to get recordsMap
          And I query positions record map from dmp gc db

        @db @jira-test06
        Scenario: TC_06: Execute a sql query to get resultset
          And I query positions result set from dmp gc db

        @jira-test07
        Scenario: TC_07: Test csv lookup
          Then I assert all records from "partialMatchTarget.csv" csv exist in "reference.csv" csv

        @jira-test08 @spark @noRun
        Scenario: TC_08: Test csv lookup
          Then I assert all records as dataset from "partialMatchTarget.csv" csv exist in "reference.csv" csv

        @jira-test09
        Scenario: TC_09: Test csv comparison
          Then I expect "reference.csv" csv file match with "reference.csv" csv


          @factsheet
          Feature: Compare published files from Oracle-12c and Oracle-19c environments

          # preRequisites:
          #  Before running this feature, ensure the following activities are completed successfully
          #  1. Run CTRL-M load jobs as in TestSet EISGEISAPPS-721
          #  2. Run CTRL-M publish jobs as in TestSet EISGEISAPPS-723


            @preRequisite
            Scenario Outline: Copy published files from output folder of Oracle-12c env to source test-data folder
              Given the user copy published source files from <networkPath> to <sourcePath>

              @smoke  @EISGEISAPPS-1135
              Examples:
                | networkPath  | sourcePath            |
                | /PMIP/SG2123 | sourceEnv/PMIP/SG2123 |

              @EISGEISAPPS-1134
              Examples:
                | networkPath                     | sourcePath                               |
                | /AUDIT/RDM_PPMA_PRURDM          | sourceEnv/AUDIT/RDM_PPMA_PRURDM          |
                | /Automated Scripts/500100       | sourceEnv/Automated Scripts/500100       |
                | /Automated Scripts/500110       | sourceEnv/Automated Scripts/500110       |
                | /Automated Scripts/500120       | sourceEnv/Automated Scripts/500120       |
                | /Automated Scripts/500130       | sourceEnv/Automated Scripts/500130       |
                | /Automated Scripts/500140       | sourceEnv/Automated Scripts/500140       |
                | /Automated Scripts/500210       | sourceEnv/Automated Scripts/500210       |
                | /Automated Scripts/500220       | sourceEnv/Automated Scripts/500220       |
                | /Automated Scripts/500230       | sourceEnv/Automated Scripts/500230       |
                | /Automated Scripts/500235       | sourceEnv/Automated Scripts/500235       |
                | /Automated Scripts/500240       | sourceEnv/Automated Scripts/500240       |
                | /Automated Scripts/500270       | sourceEnv/Automated Scripts/500270       |
                | /Automated Scripts/500280       | sourceEnv/Automated Scripts/500280       |
                | /Automated Scripts/500300       | sourceEnv/Automated Scripts/500300       |
                | /Automated Scripts/500330       | sourceEnv/Automated Scripts/500330       |
                | /Automated Scripts/500331       | sourceEnv/Automated Scripts/500331       |
                | /Automated Scripts/500333       | sourceEnv/Automated Scripts/500333       |
                | /Automated Scripts/500335       | sourceEnv/Automated Scripts/500335       |
                | /Automated Scripts/500336       | sourceEnv/Automated Scripts/500336       |
                | /Automated Scripts/500337       | sourceEnv/Automated Scripts/500337       |
                | /Automated Scripts/500340       | sourceEnv/Automated Scripts/500340       |
                | /Automated Scripts/500350       | sourceEnv/Automated Scripts/500350       |
                | /Automated Scripts/500370       | sourceEnv/Automated Scripts/500370       |
                | /Automated Scripts/500420       | sourceEnv/Automated Scripts/500420       |
                | /Automated Scripts/500422       | sourceEnv/Automated Scripts/500422       |
                | /Automated Scripts/500480       | sourceEnv/Automated Scripts/500480       |
                | /Automated Scripts/500482       | sourceEnv/Automated Scripts/500482       |
                | /Automated Scripts/500483       | sourceEnv/Automated Scripts/500483       |
                | /Automated Scripts/500508       | sourceEnv/Automated Scripts/500508       |
                | /Automated Scripts/500560       | sourceEnv/Automated Scripts/500560       |
                | /Automated Scripts/500570       | sourceEnv/Automated Scripts/500570       |
                | /Automated Scripts/500610       | sourceEnv/Automated Scripts/500610       |
                | /Automated Scripts/500630       | sourceEnv/Automated Scripts/500630       |
                | /Automated Scripts/500640       | sourceEnv/Automated Scripts/500640       |
                | /Automated Scripts/500670       | sourceEnv/Automated Scripts/500670       |
                | /Automated Scripts/500680       | sourceEnv/Automated Scripts/500680       |
                | /Automated Scripts/500720       | sourceEnv/Automated Scripts/500720       |
                | /Automated Scripts/500740       | sourceEnv/Automated Scripts/500740       |
                | /CASH_FUND/CASHFUND             | sourceEnv/CASH_FUND/CASHFUND             |
                | /CHNAG/500730                   | sourceEnv/CHNAG/500730                   |
                | /EUR_INV_GRADE_BONDS/500190     | sourceEnv/EUR_INV_GRADE_BONDS/500190     |
                | /GEMCEF/500320                  | sourceEnv/GEMCEF/500320                  |
                | /GENF/500421                    | sourceEnv/GENF/500421                    |
                | /GMAG/500620                    | sourceEnv/GMAG/500620                    |
                | /GMNF/500460                    | sourceEnv/GMNF/500460                    |
                | /Japan_Fundamental_Value/500490 | sourceEnv/Japan_Fundamental_Value/500490 |
                | /OTHERS/500150                  | sourceEnv/OTHERS/500150                  |
                | /OTHERS/500410                  | sourceEnv/OTHERS/500410                  |
                | /OTHERS/500580                  | sourceEnv/OTHERS/500580                  |
                | /PDGF/SG9121                    | sourceEnv/PDGF/SG9121                    |
                | /PPMA/500160                    | sourceEnv/PPMA/500160                    |
                | /PPMA/500170                    | sourceEnv/PPMA/500170                    |
                | /PPMA/500180                    | sourceEnv/PPMA/500180                    |
                | /PPMA/500430                    | sourceEnv/PPMA/500430                    |
                | /PPMA/500440                    | sourceEnv/PPMA/500440                    |
                | /PPMA/500600                    | sourceEnv/PPMA/500600                    |
                | /PPMA/500700                    | sourceEnv/PPMA/500700                    |
                | /PRU_ASEAN_Equity/SG3833        | sourceEnv/PRU_ASEAN_Equity/SG3833        |
                | /Pru_Asian_Balanced/SG4455      | sourceEnv/Pru_Asian_Balanced/SG4455      |
                | /PRU_Asian_Infra/SG2138         | sourceEnv/PRU_Asian_Infra/SG2138         |
                | /PRU_Global_Balanced/SG2190     | sourceEnv/PRU_Global_Balanced/SG2190     |
                | /PRU_Global_Basics/SG2136       | sourceEnv/PRU_Global_Basics/SG2136       |
                | /PRU_Global_Tech/SG3827         | sourceEnv/PRU_Global_Tech/SG3827         |
                | /PRU_Pan_European/SG3828        | sourceEnv/PRU_Pan_European/SG3828        |
                | /PRU_Rhodium_FIP3_FIP4/SG3837   | sourceEnv/PRU_Rhodium_FIP3_FIP4/SG3837   |
                | /PRU_Rhodium_FIP3_FIP4/SG3839   | sourceEnv/PRU_Rhodium_FIP3_FIP4/SG3839   |
                | /PRU_Rhodium_FIP3_FIP4/SG3840   | sourceEnv/PRU_Rhodium_FIP3_FIP4/SG3840   |
                | /SGAGG/500710                   | sourceEnv/SGAGG/500710                   |
                | /PRU_Select_Bond/SG3830         | sourceEnv/PRU_Select_Bond/SG3830         |

          #   Files are not generated on the given location for the given source files
              @noRun
              Examples:
                | networkPath                         | sourcePath                                   |
                | /AREMAI/500360                      | sourceEnv/AREMAI/500360                      |
                | /ASIA_BONDS/500130                  | sourceEnv/ASIA_BONDS/500130                  |
                | /ASIA_BONDS/500331                  | sourceEnv/ASIA_BONDS/500331                  |
                | /ASIA_BONDS/500422                  | sourceEnv/ASIA_BONDS/500422                  |
                | /PPMA/Apr 2015/500160               | sourceEnv/PPMA/Apr 2015/500160               |
                | /PPMA/Apr 2015/500170               | sourceEnv/PPMA/Apr 2015/500170               |
                | /PPMA/Apr 2015/500180               | sourceEnv/PPMA/Apr 2015/500180               |
                | /PPMA/Apr 2015/500430               | sourceEnv/PPMA/Apr 2015/500430               |
                | /PPMA/Apr 2015/500440               | sourceEnv/PPMA/Apr 2015/500440               |
                | /Pru_Asian_Balanced/Apr 2015        | sourceEnv/Pru_Asian_Balanced/Apr 2015        |
                | /Pru_Asian_Balanced/Dec 2015/SG4455 | sourceEnv/Pru_Asian_Balanced/Dec 2015/SG4455 |
                | /Pru_FIP2/SG3838                    | sourceEnv/Pru_FIP2/SG3838                    |
                | /PRU_Global_Balanced/Apr 2015       | sourceEnv/PRU_Global_Balanced/Apr 2015       |
                | /PRU_Global_Titans/Apr 2015         | sourceEnv/PRU_Global_Titans/Apr 2015         |
                | /PRU_Select_Bond/Apr 2015           | sourceEnv/PRU_Select_Bond/Apr 2015           |


            @preRequisite
            Scenario Outline: Copy published files from output folder of Oracle-19c env to target test-data folder
              Given the user copy published target files from <networkPath> to <targetPath>

              @smoke  @EISGEISAPPS-1138
              Examples:
                | networkPath  | targetPath            |
                | /PMIP/SG2123 | targetEnv/PMIP/SG2123 |

              @EISGEISAPPS-1137
              Examples:
                | networkPath                     | targetPath                               |
                | /AUDIT/RDM_PPMA_PRURDM          | targetEnv/AUDIT/RDM_PPMA_PRURDM          |
                | /Automated Scripts/500100       | targetEnv/Automated Scripts/500100       |
                | /Automated Scripts/500110       | targetEnv/Automated Scripts/500110       |
                | /Automated Scripts/500120       | targetEnv/Automated Scripts/500120       |
                | /Automated Scripts/500130       | targetEnv/Automated Scripts/500130       |
                | /Automated Scripts/500140       | targetEnv/Automated Scripts/500140       |
                | /Automated Scripts/500210       | targetEnv/Automated Scripts/500210       |
                | /Automated Scripts/500220       | targetEnv/Automated Scripts/500220       |
                | /Automated Scripts/500230       | targetEnv/Automated Scripts/500230       |
                | /Automated Scripts/500235       | targetEnv/Automated Scripts/500235       |
                | /Automated Scripts/500240       | targetEnv/Automated Scripts/500240       |
                | /Automated Scripts/500270       | targetEnv/Automated Scripts/500270       |
                | /Automated Scripts/500280       | targetEnv/Automated Scripts/500280       |
                | /Automated Scripts/500300       | targetEnv/Automated Scripts/500300       |
                | /Automated Scripts/500330       | targetEnv/Automated Scripts/500330       |
                | /Automated Scripts/500331       | targetEnv/Automated Scripts/500331       |
                | /Automated Scripts/500333       | targetEnv/Automated Scripts/500333       |
                | /Automated Scripts/500335       | targetEnv/Automated Scripts/500335       |
                | /Automated Scripts/500336       | targetEnv/Automated Scripts/500336       |
                | /Automated Scripts/500337       | targetEnv/Automated Scripts/500337       |
                | /Automated Scripts/500340       | targetEnv/Automated Scripts/500340       |
                | /Automated Scripts/500350       | targetEnv/Automated Scripts/500350       |
                | /Automated Scripts/500370       | targetEnv/Automated Scripts/500370       |
                | /Automated Scripts/500420       | targetEnv/Automated Scripts/500420       |
                | /Automated Scripts/500422       | targetEnv/Automated Scripts/500422       |
                | /Automated Scripts/500480       | targetEnv/Automated Scripts/500480       |
                | /Automated Scripts/500482       | targetEnv/Automated Scripts/500482       |
                | /Automated Scripts/500483       | targetEnv/Automated Scripts/500483       |
                | /Automated Scripts/500508       | targetEnv/Automated Scripts/500508       |
                | /Automated Scripts/500560       | targetEnv/Automated Scripts/500560       |
                | /Automated Scripts/500570       | targetEnv/Automated Scripts/500570       |
                | /Automated Scripts/500610       | targetEnv/Automated Scripts/500610       |
                | /Automated Scripts/500630       | targetEnv/Automated Scripts/500630       |
                | /Automated Scripts/500640       | targetEnv/Automated Scripts/500640       |
                | /Automated Scripts/500670       | targetEnv/Automated Scripts/500670       |
                | /Automated Scripts/500680       | targetEnv/Automated Scripts/500680       |
                | /Automated Scripts/500720       | targetEnv/Automated Scripts/500720       |
                | /Automated Scripts/500740       | targetEnv/Automated Scripts/500740       |
                | /CASH_FUND/CASHFUND             | targetEnv/CASH_FUND/CASHFUND             |
                | /CHNAG/500730                   | targetEnv/CHNAG/500730                   |
                | /EUR_INV_GRADE_BONDS/500190     | targetEnv/EUR_INV_GRADE_BONDS/500190     |
                | /GEMCEF/500320                  | targetEnv/GEMCEF/500320                  |
                | /GENF/500421                    | targetEnv/GENF/500421                    |
                | /GMAG/500620                    | targetEnv/GMAG/500620                    |
                | /GMNF/500460                    | targetEnv/GMNF/500460                    |
                | /Japan_Fundamental_Value/500490 | targetEnv/Japan_Fundamental_Value/500490 |
                | /OTHERS/500150                  | targetEnv/OTHERS/500150                  |
                | /OTHERS/500410                  | targetEnv/OTHERS/500410                  |
                | /OTHERS/500580                  | targetEnv/OTHERS/500580                  |
                | /PDGF/SG9121                    | targetEnv/PDGF/SG9121                    |
                | /PPMA/500160                    | targetEnv/PPMA/500160                    |
                | /PPMA/500170                    | targetEnv/PPMA/500170                    |
                | /PPMA/500180                    | targetEnv/PPMA/500180                    |
                | /PPMA/500430                    | targetEnv/PPMA/500430                    |
                | /PPMA/500440                    | targetEnv/PPMA/500440                    |
                | /PPMA/500600                    | targetEnv/PPMA/500600                    |
                | /PPMA/500700                    | targetEnv/PPMA/500700                    |
                | /PRU_ASEAN_Equity/SG3833        | targetEnv/PRU_ASEAN_Equity/SG3833        |
                | /Pru_Asian_Balanced/SG4455      | targetEnv/Pru_Asian_Balanced/SG4455      |
                | /PRU_Asian_Infra/SG2138         | targetEnv/PRU_Asian_Infra/SG2138         |
                | /PRU_Global_Balanced/SG2190     | targetEnv/PRU_Global_Balanced/SG2190     |
                | /PRU_Global_Basics/SG2136       | targetEnv/PRU_Global_Basics/SG2136       |
                | /PRU_Global_Tech/SG3827         | targetEnv/PRU_Global_Tech/SG3827         |
                | /PRU_Pan_European/SG3828        | targetEnv/PRU_Pan_European/SG3828        |
                | /PRU_Rhodium_FIP3_FIP4/SG3837   | targetEnv/PRU_Rhodium_FIP3_FIP4/SG3837   |
                | /PRU_Rhodium_FIP3_FIP4/SG3839   | targetEnv/PRU_Rhodium_FIP3_FIP4/SG3839   |
                | /PRU_Rhodium_FIP3_FIP4/SG3840   | targetEnv/PRU_Rhodium_FIP3_FIP4/SG3840   |
                | /SGAGG/500710                   | targetEnv/SGAGG/500710                   |
                | /PRU_Select_Bond/SG3830         | targetEnv/PRU_Select_Bond/SG3830         |


          #   Files are not generated on the given location for the given source files
              @noRun
              Examples:
                | networkPath                         | targetPath                                   |
                | /AREMAI/500360                      | targetEnv/AREMAI/500360                      |
                | /ASIA_BONDS/500130                  | targetEnv/ASIA_BONDS/500130                  |
                | /ASIA_BONDS/500331                  | targetEnv/ASIA_BONDS/500331                  |
                | /ASIA_BONDS/500422                  | targetEnv/ASIA_BONDS/500422                  |
                | /PPMA/Apr 2015/500160               | targetEnv/PPMA/Apr 2015/500160               |
                | /PPMA/Apr 2015/500170               | targetEnv/PPMA/Apr 2015/500170               |
                | /PPMA/Apr 2015/500180               | targetEnv/PPMA/Apr 2015/500180               |
                | /PPMA/Apr 2015/500430               | targetEnv/PPMA/Apr 2015/500430               |
                | /PPMA/Apr 2015/500440               | targetEnv/PPMA/Apr 2015/500440               |
                | /Pru_Asian_Balanced/Apr 2015        | targetEnv/Pru_Asian_Balanced/Apr 2015        |
                | /Pru_Asian_Balanced/Dec 2015/SG4455 | targetEnv/Pru_Asian_Balanced/Dec 2015/SG4455 |
                | /Pru_FIP2/SG3838                    | targetEnv/Pru_FIP2/SG3838                    |
                | /PRU_Global_Balanced/Apr 2015       | targetEnv/PRU_Global_Balanced/Apr 2015       |
                | /PRU_Global_Titans/Apr 2015         | targetEnv/PRU_Global_Titans/Apr 2015         |
                | /PRU_Select_Bond/Apr 2015           | targetEnv/PRU_Select_Bond/Apr 2015           |

            Scenario Outline: Reconciliation of published files from Oracle 12c and 19c environments
              Then the user expect "<fileName>" csv file in "<sourcePath>" and "<targetPath>" to match with each other

            # Note:
            # the '@manual @noRun' test iterations need to be compared manually
            # due to volatility in grouping the records into 'OTHERS' category

              @EISGEISAPPS-688 @smoke
              Examples:
                | sourcePath            | targetPath            | fileName             |
                | sourceEnv/PMIP/SG2123 | targetEnv/PMIP/SG2123 | COUNTRY.csv          |
                | sourceEnv/PMIP/SG2123 | targetEnv/PMIP/SG2123 | COUNTRY_DETAILS.csv  |
                | sourceEnv/PMIP/SG2123 | targetEnv/PMIP/SG2123 | FUND_ALLOCATION.csv  |
                | sourceEnv/PMIP/SG2123 | targetEnv/PMIP/SG2123 | MATURITY.csv         |
                | sourceEnv/PMIP/SG2123 | targetEnv/PMIP/SG2123 | MATURITY_DETAILS.csv |
                | sourceEnv/PMIP/SG2123 | targetEnv/PMIP/SG2123 | RATINGS.csv          |
                | sourceEnv/PMIP/SG2123 | targetEnv/PMIP/SG2123 | RATINGS_DETAILS.csv  |
                | sourceEnv/PMIP/SG2123 | targetEnv/PMIP/SG2123 | SECTOR.csv           |
                | sourceEnv/PMIP/SG2123 | targetEnv/PMIP/SG2123 | SECTOR_DETAILS.csv   |
                | sourceEnv/PMIP/SG2123 | targetEnv/PMIP/SG2123 | TOP10_HOLDINGS.csv   |


              @EISGEISAPPS-639
              Examples:
                | sourcePath                         | targetPath                         | fileName            |
                | sourceEnv/Automated Scripts/500100 | targetEnv/Automated Scripts/500100 | COUNTRY.csv         |
                | sourceEnv/Automated Scripts/500100 | targetEnv/Automated Scripts/500100 | COUNTRY_DETAILS.csv |
                | sourceEnv/Automated Scripts/500100 | targetEnv/Automated Scripts/500100 | SECTOR.csv          |
                | sourceEnv/Automated Scripts/500100 | targetEnv/Automated Scripts/500100 | SECTOR_DETAILS.csv  |
                | sourceEnv/Automated Scripts/500100 | targetEnv/Automated Scripts/500100 | TOP10_HOLDINGS.csv  |



              @EISGEISAPPS-640
              Examples:
                | sourcePath                         | targetPath                         | fileName            |
                | sourceEnv/Automated Scripts/500110 | targetEnv/Automated Scripts/500110 | COUNTRY.csv         |
                | sourceEnv/Automated Scripts/500110 | targetEnv/Automated Scripts/500110 | COUNTRY_DETAILS.csv |
                | sourceEnv/Automated Scripts/500110 | targetEnv/Automated Scripts/500110 | SECTOR.csv          |
                | sourceEnv/Automated Scripts/500110 | targetEnv/Automated Scripts/500110 | SECTOR_DETAILS.csv  |
                | sourceEnv/Automated Scripts/500110 | targetEnv/Automated Scripts/500110 | TOP10_HOLDINGS.csv  |


              @EISGEISAPPS-641
              Examples:
                | sourcePath                         | targetPath                         | fileName            |
                | sourceEnv/Automated Scripts/500120 | targetEnv/Automated Scripts/500120 | COUNTRY.csv         |
                | sourceEnv/Automated Scripts/500120 | targetEnv/Automated Scripts/500120 | COUNTRY_DETAILS.csv |
                | sourceEnv/Automated Scripts/500120 | targetEnv/Automated Scripts/500120 | SECTOR.csv          |
                | sourceEnv/Automated Scripts/500120 | targetEnv/Automated Scripts/500120 | SECTOR_DETAILS.csv  |
                | sourceEnv/Automated Scripts/500120 | targetEnv/Automated Scripts/500120 | TOP10_HOLDINGS.csv  |


              @EISGEISAPPS-642
              Examples:
                | sourcePath                         | targetPath                         | fileName             |
                | sourceEnv/Automated Scripts/500130 | targetEnv/Automated Scripts/500130 | COUNTRY.csv          |
                | sourceEnv/Automated Scripts/500130 | targetEnv/Automated Scripts/500130 | COUNTRY_DETAILS.csv  |
                | sourceEnv/Automated Scripts/500130 | targetEnv/Automated Scripts/500130 | MATURITY.csv         |
                | sourceEnv/Automated Scripts/500130 | targetEnv/Automated Scripts/500130 | MATURITY_DETAILS.csv |
                | sourceEnv/Automated Scripts/500130 | targetEnv/Automated Scripts/500130 | RATINGS_BD.csv       |
                | sourceEnv/Automated Scripts/500130 | targetEnv/Automated Scripts/500130 | RATINGS.csv          |
                | sourceEnv/Automated Scripts/500130 | targetEnv/Automated Scripts/500130 | RATINGS_DETAILS.csv  |
                | sourceEnv/Automated Scripts/500130 | targetEnv/Automated Scripts/500130 | SECTOR.csv           |
                | sourceEnv/Automated Scripts/500130 | targetEnv/Automated Scripts/500130 | SECTOR_DETAILS.csv   |
                | sourceEnv/Automated Scripts/500130 | targetEnv/Automated Scripts/500130 | TOP10_HOLDINGS.csv   |



              @EISGEISAPPS-643
              Examples:
                | sourcePath                         | targetPath                         | fileName           |
                | sourceEnv/Automated Scripts/500140 | targetEnv/Automated Scripts/500140 | COUNTRY.csv        |
                | sourceEnv/Automated Scripts/500140 | targetEnv/Automated Scripts/500140 | SECTOR.csv         |
                | sourceEnv/Automated Scripts/500140 | targetEnv/Automated Scripts/500140 | TOP10_HOLDINGS.csv |


              @EISGEISAPPS-644
              Examples:
                | sourcePath                         | targetPath                         | fileName            |
                | sourceEnv/Automated Scripts/500210 | targetEnv/Automated Scripts/500210 | COUNTRY.csv         |
                | sourceEnv/Automated Scripts/500210 | targetEnv/Automated Scripts/500210 | COUNTRY_DETAILS.csv |
                | sourceEnv/Automated Scripts/500210 | targetEnv/Automated Scripts/500210 | SECTOR.csv          |
                | sourceEnv/Automated Scripts/500210 | targetEnv/Automated Scripts/500210 | SECTOR_DETAILS.csv  |
                | sourceEnv/Automated Scripts/500210 | targetEnv/Automated Scripts/500210 | TOP10_HOLDINGS.csv  |


              @EISGEISAPPS-645
              Examples:
                | sourcePath                         | targetPath                         | fileName            |
                | sourceEnv/Automated Scripts/500220 | targetEnv/Automated Scripts/500220 | COUNTRY.csv         |
                | sourceEnv/Automated Scripts/500220 | targetEnv/Automated Scripts/500220 | COUNTRY_DETAILS.csv |
                | sourceEnv/Automated Scripts/500220 | targetEnv/Automated Scripts/500220 | SECTOR.csv          |
                | sourceEnv/Automated Scripts/500220 | targetEnv/Automated Scripts/500220 | SECTOR_DETAILS.csv  |
                | sourceEnv/Automated Scripts/500220 | targetEnv/Automated Scripts/500220 | TOP10_HOLDINGS.csv  |


              @EISGEISAPPS-646
              Examples:
                | sourcePath                         | targetPath                         | fileName            |
                | sourceEnv/Automated Scripts/500230 | targetEnv/Automated Scripts/500230 | COUNTRY.csv         |
                | sourceEnv/Automated Scripts/500230 | targetEnv/Automated Scripts/500230 | COUNTRY_DETAILS.csv |
                | sourceEnv/Automated Scripts/500230 | targetEnv/Automated Scripts/500230 | SECTOR.csv          |
                | sourceEnv/Automated Scripts/500230 | targetEnv/Automated Scripts/500230 | SECTOR_DETAILS.csv  |
                | sourceEnv/Automated Scripts/500230 | targetEnv/Automated Scripts/500230 | TOP10_HOLDINGS.csv  |

              @EISGEISAPPS-647
              Examples:
                | sourcePath                         | targetPath                         | fileName            |
                | sourceEnv/Automated Scripts/500235 | targetEnv/Automated Scripts/500235 | COUNTRY.csv         |
                | sourceEnv/Automated Scripts/500235 | targetEnv/Automated Scripts/500235 | COUNTRY_DETAILS.csv |
                | sourceEnv/Automated Scripts/500235 | targetEnv/Automated Scripts/500235 | SECTOR.csv          |
                | sourceEnv/Automated Scripts/500235 | targetEnv/Automated Scripts/500235 | SECTOR_DETAILS.csv  |
                | sourceEnv/Automated Scripts/500235 | targetEnv/Automated Scripts/500235 | TOP10_HOLDINGS.csv  |


              @EISGEISAPPS-648
              Examples:
                | sourcePath                         | targetPath                         | fileName            |
                | sourceEnv/Automated Scripts/500240 | targetEnv/Automated Scripts/500240 | COUNTRY.csv         |
                | sourceEnv/Automated Scripts/500240 | targetEnv/Automated Scripts/500240 | COUNTRY_DETAILS.csv |
                | sourceEnv/Automated Scripts/500240 | targetEnv/Automated Scripts/500240 | SECTOR.csv          |
                | sourceEnv/Automated Scripts/500240 | targetEnv/Automated Scripts/500240 | SECTOR_DETAILS.csv  |
                | sourceEnv/Automated Scripts/500240 | targetEnv/Automated Scripts/500240 | TOP10_HOLDINGS.csv  |


              @EISGEISAPPS-649
              Examples:
                | sourcePath                         | targetPath                         | fileName            |
                | sourceEnv/Automated Scripts/500270 | targetEnv/Automated Scripts/500270 | COUNTRY.csv         |
                | sourceEnv/Automated Scripts/500270 | targetEnv/Automated Scripts/500270 | COUNTRY_DETAILS.csv |
                | sourceEnv/Automated Scripts/500270 | targetEnv/Automated Scripts/500270 | SECTOR.csv          |
                | sourceEnv/Automated Scripts/500270 | targetEnv/Automated Scripts/500270 | SECTOR_DETAILS.csv  |
                | sourceEnv/Automated Scripts/500270 | targetEnv/Automated Scripts/500270 | TOP10_HOLDINGS.csv  |


              @EISGEISAPPS-650
              Examples:
                | sourcePath                         | targetPath                         | fileName            |
                | sourceEnv/Automated Scripts/500280 | targetEnv/Automated Scripts/500280 | COUNTRY.csv         |
                | sourceEnv/Automated Scripts/500280 | targetEnv/Automated Scripts/500280 | COUNTRY_DETAILS.csv |
                | sourceEnv/Automated Scripts/500280 | targetEnv/Automated Scripts/500280 | SECTOR.csv          |
                | sourceEnv/Automated Scripts/500280 | targetEnv/Automated Scripts/500280 | SECTOR_DETAILS.csv  |
                | sourceEnv/Automated Scripts/500280 | targetEnv/Automated Scripts/500280 | TOP10_HOLDINGS.csv  |


              @EISGEISAPPS-651
              Examples:
                | sourcePath                         | targetPath                         | fileName            |
                | sourceEnv/Automated Scripts/500300 | targetEnv/Automated Scripts/500300 | COUNTRY.csv         |
                | sourceEnv/Automated Scripts/500300 | targetEnv/Automated Scripts/500300 | COUNTRY_DETAILS.csv |
                | sourceEnv/Automated Scripts/500300 | targetEnv/Automated Scripts/500300 | SECTOR.csv          |
                | sourceEnv/Automated Scripts/500300 | targetEnv/Automated Scripts/500300 | SECTOR_DETAILS.csv  |
                | sourceEnv/Automated Scripts/500300 | targetEnv/Automated Scripts/500300 | TOP10_HOLDINGS.csv  |


              @EISGEISAPPS-652
              Examples:
                | sourcePath                         | targetPath                         | fileName            |
                | sourceEnv/Automated Scripts/500330 | targetEnv/Automated Scripts/500330 | COUNTRY.csv         |
                | sourceEnv/Automated Scripts/500330 | targetEnv/Automated Scripts/500330 | COUNTRY_DETAILS.csv |
                | sourceEnv/Automated Scripts/500330 | targetEnv/Automated Scripts/500330 | SECTOR.csv          |
                | sourceEnv/Automated Scripts/500330 | targetEnv/Automated Scripts/500330 | SECTOR_DETAILS.csv  |
                | sourceEnv/Automated Scripts/500330 | targetEnv/Automated Scripts/500330 | TOP10_HOLDINGS.csv  |


              @EISGEISAPPS-653
              Examples:
                | sourcePath                         | targetPath                         | fileName             |
                | sourceEnv/Automated Scripts/500331 | targetEnv/Automated Scripts/500331 | COUNTRY.csv          |
                | sourceEnv/Automated Scripts/500331 | targetEnv/Automated Scripts/500331 | COUNTRY_DETAILS.csv  |
                | sourceEnv/Automated Scripts/500331 | targetEnv/Automated Scripts/500331 | MATURITY.csv         |
                | sourceEnv/Automated Scripts/500331 | targetEnv/Automated Scripts/500331 | MATURITY_DETAILS.csv |
                | sourceEnv/Automated Scripts/500331 | targetEnv/Automated Scripts/500331 | RATINGS_BD.csv       |
                | sourceEnv/Automated Scripts/500331 | targetEnv/Automated Scripts/500331 | RATINGS.csv          |
                | sourceEnv/Automated Scripts/500331 | targetEnv/Automated Scripts/500331 | RATINGS_DETAILS.csv  |
                | sourceEnv/Automated Scripts/500331 | targetEnv/Automated Scripts/500331 | SECTOR.csv           |
                | sourceEnv/Automated Scripts/500331 | targetEnv/Automated Scripts/500331 | SECTOR_DETAILS.csv   |
                | sourceEnv/Automated Scripts/500331 | targetEnv/Automated Scripts/500331 | TOP10_HOLDINGS.csv   |


              @EISGEISAPPS-654
              Examples:
                | sourcePath                         | targetPath                         | fileName            |
                | sourceEnv/Automated Scripts/500333 | targetEnv/Automated Scripts/500333 | COUNTRY.csv         |
                | sourceEnv/Automated Scripts/500333 | targetEnv/Automated Scripts/500333 | COUNTRY_DETAILS.csv |
                | sourceEnv/Automated Scripts/500333 | targetEnv/Automated Scripts/500333 | SECTOR.csv          |
                | sourceEnv/Automated Scripts/500333 | targetEnv/Automated Scripts/500333 | SECTOR_DETAILS.csv  |
                | sourceEnv/Automated Scripts/500333 | targetEnv/Automated Scripts/500333 | TOP10_HOLDINGS.csv  |


              @EISGEISAPPS-655
              Examples:
                | sourcePath                         | targetPath                         | fileName            |
                | sourceEnv/Automated Scripts/500335 | targetEnv/Automated Scripts/500335 | COUNTRY.csv         |
                | sourceEnv/Automated Scripts/500335 | targetEnv/Automated Scripts/500335 | COUNTRY_DETAILS.csv |
                | sourceEnv/Automated Scripts/500335 | targetEnv/Automated Scripts/500335 | SECTOR.csv          |
                | sourceEnv/Automated Scripts/500335 | targetEnv/Automated Scripts/500335 | SECTOR_DETAILS.csv  |
                | sourceEnv/Automated Scripts/500335 | targetEnv/Automated Scripts/500335 | TOP10_HOLDINGS.csv  |


              @EISGEISAPPS-656
              Examples:
                | sourcePath                         | targetPath                         | fileName            |
                | sourceEnv/Automated Scripts/500336 | targetEnv/Automated Scripts/500336 | COUNTRY.csv         |
                | sourceEnv/Automated Scripts/500336 | targetEnv/Automated Scripts/500336 | COUNTRY_DETAILS.csv |
                | sourceEnv/Automated Scripts/500336 | targetEnv/Automated Scripts/500336 | SECTOR.csv          |
                | sourceEnv/Automated Scripts/500336 | targetEnv/Automated Scripts/500336 | SECTOR_DETAILS.csv  |
                | sourceEnv/Automated Scripts/500336 | targetEnv/Automated Scripts/500336 | TOP10_HOLDINGS.csv  |


              @EISGEISAPPS-657
              Examples:
                | sourcePath                         | targetPath                         | fileName            |
                | sourceEnv/Automated Scripts/500337 | targetEnv/Automated Scripts/500337 | COUNTRY.csv         |
                | sourceEnv/Automated Scripts/500337 | targetEnv/Automated Scripts/500337 | COUNTRY_DETAILS.csv |
                | sourceEnv/Automated Scripts/500337 | targetEnv/Automated Scripts/500337 | SECTOR.csv          |
                | sourceEnv/Automated Scripts/500337 | targetEnv/Automated Scripts/500337 | SECTOR_DETAILS.csv  |
                | sourceEnv/Automated Scripts/500337 | targetEnv/Automated Scripts/500337 | TOP10_HOLDINGS.csv  |


              @EISGEISAPPS-658
              Examples:
                | sourcePath                         | targetPath                         | fileName             |
                | sourceEnv/Automated Scripts/500340 | targetEnv/Automated Scripts/500340 | COUNTRY.csv          |
                | sourceEnv/Automated Scripts/500340 | targetEnv/Automated Scripts/500340 | COUNTRY_DETAILS.csv  |
                | sourceEnv/Automated Scripts/500340 | targetEnv/Automated Scripts/500340 | MATURITY.csv         |
                | sourceEnv/Automated Scripts/500340 | targetEnv/Automated Scripts/500340 | MATURITY_DETAILS.csv |
                | sourceEnv/Automated Scripts/500340 | targetEnv/Automated Scripts/500340 | RATINGS_BD.csv       |
                | sourceEnv/Automated Scripts/500340 | targetEnv/Automated Scripts/500340 | RATINGS.csv          |
                | sourceEnv/Automated Scripts/500340 | targetEnv/Automated Scripts/500340 | RATINGS_DETAILS.csv  |
                | sourceEnv/Automated Scripts/500340 | targetEnv/Automated Scripts/500340 | SECTOR.csv           |
                | sourceEnv/Automated Scripts/500340 | targetEnv/Automated Scripts/500340 | SECTOR_DETAILS.csv   |
                | sourceEnv/Automated Scripts/500340 | targetEnv/Automated Scripts/500340 | TOP10_HOLDINGS.csv   |


              @EISGEISAPPS-659
              Examples:
                | sourcePath                         | targetPath                         | fileName             |
                | sourceEnv/Automated Scripts/500350 | targetEnv/Automated Scripts/500350 | COUNTRY.csv          |
                | sourceEnv/Automated Scripts/500350 | targetEnv/Automated Scripts/500350 | COUNTRY_DETAILS.csv  |
                | sourceEnv/Automated Scripts/500350 | targetEnv/Automated Scripts/500350 | MATURITY.csv         |
                | sourceEnv/Automated Scripts/500350 | targetEnv/Automated Scripts/500350 | MATURITY_DETAILS.csv |
                | sourceEnv/Automated Scripts/500350 | targetEnv/Automated Scripts/500350 | RATINGS_BD.csv       |
                | sourceEnv/Automated Scripts/500350 | targetEnv/Automated Scripts/500350 | RATINGS.csv          |
                | sourceEnv/Automated Scripts/500350 | targetEnv/Automated Scripts/500350 | RATINGS_DETAILS.csv  |
                | sourceEnv/Automated Scripts/500350 | targetEnv/Automated Scripts/500350 | SECTOR.csv           |
                | sourceEnv/Automated Scripts/500350 | targetEnv/Automated Scripts/500350 | SECTOR_DETAILS.csv   |
                | sourceEnv/Automated Scripts/500350 | targetEnv/Automated Scripts/500350 | TOP10_HOLDINGS.csv   |


              @EISGEISAPPS-660
              Examples:
                | sourcePath                         | targetPath                         | fileName             |
                | sourceEnv/Automated Scripts/500370 | targetEnv/Automated Scripts/500370 | COUNTRY.csv          |
                | sourceEnv/Automated Scripts/500370 | targetEnv/Automated Scripts/500370 | COUNTRY_DETAILS.csv  |
                | sourceEnv/Automated Scripts/500370 | targetEnv/Automated Scripts/500370 | MATURITY.csv         |
                | sourceEnv/Automated Scripts/500370 | targetEnv/Automated Scripts/500370 | MATURITY_DETAILS.csv |
                | sourceEnv/Automated Scripts/500370 | targetEnv/Automated Scripts/500370 | RATINGS_BD.csv       |
                | sourceEnv/Automated Scripts/500370 | targetEnv/Automated Scripts/500370 | RATINGS.csv          |
                | sourceEnv/Automated Scripts/500370 | targetEnv/Automated Scripts/500370 | RATINGS_DETAILS.csv  |
                | sourceEnv/Automated Scripts/500370 | targetEnv/Automated Scripts/500370 | SECTOR.csv           |
                | sourceEnv/Automated Scripts/500370 | targetEnv/Automated Scripts/500370 | SECTOR_DETAILS.csv   |
                | sourceEnv/Automated Scripts/500370 | targetEnv/Automated Scripts/500370 | TOP10_HOLDINGS.csv   |


              @EISGEISAPPS-661
              Examples:
                | sourcePath                         | targetPath                         | fileName            |
                | sourceEnv/Automated Scripts/500420 | targetEnv/Automated Scripts/500420 | COUNTRY.csv         |
                | sourceEnv/Automated Scripts/500420 | targetEnv/Automated Scripts/500420 | COUNTRY_DETAILS.csv |
                | sourceEnv/Automated Scripts/500420 | targetEnv/Automated Scripts/500420 | SECTOR.csv          |
                | sourceEnv/Automated Scripts/500420 | targetEnv/Automated Scripts/500420 | SECTOR_DETAILS.csv  |
                | sourceEnv/Automated Scripts/500420 | targetEnv/Automated Scripts/500420 | TOP10_HOLDINGS.csv  |


              @EISGEISAPPS-662
              Examples:
                | sourcePath                         | targetPath                         | fileName             |
                | sourceEnv/Automated Scripts/500422 | targetEnv/Automated Scripts/500422 | COUNTRY.csv          |
                | sourceEnv/Automated Scripts/500422 | targetEnv/Automated Scripts/500422 | COUNTRY_DETAILS.csv  |
                | sourceEnv/Automated Scripts/500422 | targetEnv/Automated Scripts/500422 | MATURITY.csv         |
                | sourceEnv/Automated Scripts/500422 | targetEnv/Automated Scripts/500422 | MATURITY_DETAILS.csv |
                | sourceEnv/Automated Scripts/500422 | targetEnv/Automated Scripts/500422 | RATINGS_BD.csv       |
                | sourceEnv/Automated Scripts/500422 | targetEnv/Automated Scripts/500422 | RATINGS.csv          |
                | sourceEnv/Automated Scripts/500422 | targetEnv/Automated Scripts/500422 | RATINGS_DETAILS.csv  |
                | sourceEnv/Automated Scripts/500422 | targetEnv/Automated Scripts/500422 | SECTOR.csv           |
                | sourceEnv/Automated Scripts/500422 | targetEnv/Automated Scripts/500422 | SECTOR_DETAILS.csv   |
                | sourceEnv/Automated Scripts/500422 | targetEnv/Automated Scripts/500422 | TOP10_HOLDINGS.csv   |


              @EISGEISAPPS-663
              Examples:
                | sourcePath                         | targetPath                         | fileName            |
                | sourceEnv/Automated Scripts/500480 | targetEnv/Automated Scripts/500480 | COUNTRY.csv         |
                | sourceEnv/Automated Scripts/500480 | targetEnv/Automated Scripts/500480 | COUNTRY_DETAILS.csv |
                | sourceEnv/Automated Scripts/500480 | targetEnv/Automated Scripts/500480 | SECTOR.csv          |
                | sourceEnv/Automated Scripts/500480 | targetEnv/Automated Scripts/500480 | SECTOR_DETAILS.csv  |
                | sourceEnv/Automated Scripts/500480 | targetEnv/Automated Scripts/500480 | TOP10_HOLDINGS.csv  |


              @EISGEISAPPS-664
              Examples:
                | sourcePath                         | targetPath                         | fileName            |
                | sourceEnv/Automated Scripts/500482 | targetEnv/Automated Scripts/500482 | COUNTRY.csv         |
                | sourceEnv/Automated Scripts/500482 | targetEnv/Automated Scripts/500482 | COUNTRY_DETAILS.csv |
                | sourceEnv/Automated Scripts/500482 | targetEnv/Automated Scripts/500482 | SECTOR.csv          |
                | sourceEnv/Automated Scripts/500482 | targetEnv/Automated Scripts/500482 | SECTOR_DETAILS.csv  |
                | sourceEnv/Automated Scripts/500482 | targetEnv/Automated Scripts/500482 | TOP10_HOLDINGS.csv  |


              @EISGEISAPPS-665
              Examples:
                | sourcePath                         | targetPath                         | fileName            |
                | sourceEnv/Automated Scripts/500483 | targetEnv/Automated Scripts/500483 | COUNTRY.csv         |
                | sourceEnv/Automated Scripts/500483 | targetEnv/Automated Scripts/500483 | COUNTRY_DETAILS.csv |
                | sourceEnv/Automated Scripts/500483 | targetEnv/Automated Scripts/500483 | SECTOR.csv          |
                | sourceEnv/Automated Scripts/500483 | targetEnv/Automated Scripts/500483 | SECTOR_DETAILS.csv  |
                | sourceEnv/Automated Scripts/500483 | targetEnv/Automated Scripts/500483 | TOP10_HOLDINGS.csv  |


              @EISGEISAPPS-666
              Examples:
                | sourcePath                         | targetPath                         | fileName             |
                | sourceEnv/Automated Scripts/500508 | targetEnv/Automated Scripts/500508 | COUNTRY.csv          |
                | sourceEnv/Automated Scripts/500508 | targetEnv/Automated Scripts/500508 | COUNTRY_DETAILS.csv  |
                | sourceEnv/Automated Scripts/500508 | targetEnv/Automated Scripts/500508 | MATURITY.csv         |
                | sourceEnv/Automated Scripts/500508 | targetEnv/Automated Scripts/500508 | MATURITY_DETAILS.csv |
                | sourceEnv/Automated Scripts/500508 | targetEnv/Automated Scripts/500508 | RATINGS_BD.csv       |
                | sourceEnv/Automated Scripts/500508 | targetEnv/Automated Scripts/500508 | RATINGS.csv          |
                | sourceEnv/Automated Scripts/500508 | targetEnv/Automated Scripts/500508 | RATINGS_DETAILS.csv  |
                | sourceEnv/Automated Scripts/500508 | targetEnv/Automated Scripts/500508 | SECTOR.csv           |
                | sourceEnv/Automated Scripts/500508 | targetEnv/Automated Scripts/500508 | SECTOR_DETAILS.csv   |
                | sourceEnv/Automated Scripts/500508 | targetEnv/Automated Scripts/500508 | TOP10_HOLDINGS.csv   |


              @EISGEISAPPS-667
              Examples:
                | sourcePath                         | targetPath                         | fileName            |
                | sourceEnv/Automated Scripts/500560 | targetEnv/Automated Scripts/500560 | COUNTRY.csv         |
                | sourceEnv/Automated Scripts/500560 | targetEnv/Automated Scripts/500560 | COUNTRY_DETAILS.csv |
                | sourceEnv/Automated Scripts/500560 | targetEnv/Automated Scripts/500560 | SECTOR.csv          |
                | sourceEnv/Automated Scripts/500560 | targetEnv/Automated Scripts/500560 | SECTOR_DETAILS.csv  |
                | sourceEnv/Automated Scripts/500560 | targetEnv/Automated Scripts/500560 | TOP10_HOLDINGS.csv  |


              @EISGEISAPPS-668
              Examples:
                | sourcePath                         | targetPath                         | fileName            |
                | sourceEnv/Automated Scripts/500570 | targetEnv/Automated Scripts/500570 | COUNTRY.csv         |
                | sourceEnv/Automated Scripts/500570 | targetEnv/Automated Scripts/500570 | COUNTRY_DETAILS.csv |
                | sourceEnv/Automated Scripts/500570 | targetEnv/Automated Scripts/500570 | SECTOR.csv          |
                | sourceEnv/Automated Scripts/500570 | targetEnv/Automated Scripts/500570 | SECTOR_DETAILS.csv  |
                | sourceEnv/Automated Scripts/500570 | targetEnv/Automated Scripts/500570 | TOP10_HOLDINGS.csv  |


              @EISGEISAPPS-669
              Examples:
                | sourcePath                         | targetPath                         | fileName            |
                | sourceEnv/Automated Scripts/500610 | targetEnv/Automated Scripts/500610 | COUNTRY.csv         |
                | sourceEnv/Automated Scripts/500610 | targetEnv/Automated Scripts/500610 | COUNTRY_DETAILS.csv |
                | sourceEnv/Automated Scripts/500610 | targetEnv/Automated Scripts/500610 | SECTOR.csv          |
                | sourceEnv/Automated Scripts/500610 | targetEnv/Automated Scripts/500610 | SECTOR_DETAILS.csv  |
                | sourceEnv/Automated Scripts/500610 | targetEnv/Automated Scripts/500610 | TOP10_HOLDINGS.csv  |


              @EISGEISAPPS-670
              Examples:
                | sourcePath                         | targetPath                         | fileName            |
                | sourceEnv/Automated Scripts/500630 | targetEnv/Automated Scripts/500630 | COUNTRY.csv         |
                | sourceEnv/Automated Scripts/500630 | targetEnv/Automated Scripts/500630 | COUNTRY_DETAILS.csv |
                | sourceEnv/Automated Scripts/500630 | targetEnv/Automated Scripts/500630 | SECTOR.csv          |
                | sourceEnv/Automated Scripts/500630 | targetEnv/Automated Scripts/500630 | SECTOR_DETAILS.csv  |
                | sourceEnv/Automated Scripts/500630 | targetEnv/Automated Scripts/500630 | TOP10_HOLDINGS.csv  |


              @EISGEISAPPS-671
              Examples:
                | sourcePath                         | targetPath                         | fileName            |
                | sourceEnv/Automated Scripts/500640 | targetEnv/Automated Scripts/500640 | COUNTRY.csv         |
                | sourceEnv/Automated Scripts/500640 | targetEnv/Automated Scripts/500640 | COUNTRY_DETAILS.csv |
                | sourceEnv/Automated Scripts/500640 | targetEnv/Automated Scripts/500640 | SECTOR.csv          |
                | sourceEnv/Automated Scripts/500640 | targetEnv/Automated Scripts/500640 | SECTOR_DETAILS.csv  |
                | sourceEnv/Automated Scripts/500640 | targetEnv/Automated Scripts/500640 | TOP10_HOLDINGS.csv  |


              @EISGEISAPPS-672
              Examples:
                | sourcePath                         | targetPath                         | fileName            |
                | sourceEnv/Automated Scripts/500670 | targetEnv/Automated Scripts/500670 | COUNTRY.csv         |
                | sourceEnv/Automated Scripts/500670 | targetEnv/Automated Scripts/500670 | COUNTRY_DETAILS.csv |
                | sourceEnv/Automated Scripts/500670 | targetEnv/Automated Scripts/500670 | SECTOR.csv          |
                | sourceEnv/Automated Scripts/500670 | targetEnv/Automated Scripts/500670 | SECTOR_DETAILS.csv  |
                | sourceEnv/Automated Scripts/500670 | targetEnv/Automated Scripts/500670 | TOP10_HOLDINGS.csv  |


              @EISGEISAPPS-673
              Examples:
                | sourcePath                         | targetPath                         | fileName             |
                | sourceEnv/Automated Scripts/500680 | targetEnv/Automated Scripts/500680 | COUNTRY.csv          |
                | sourceEnv/Automated Scripts/500680 | targetEnv/Automated Scripts/500680 | COUNTRY_DETAILS.csv  |
                | sourceEnv/Automated Scripts/500680 | targetEnv/Automated Scripts/500680 | MATURITY.csv         |
                | sourceEnv/Automated Scripts/500680 | targetEnv/Automated Scripts/500680 | MATURITY_DETAILS.csv |
                | sourceEnv/Automated Scripts/500680 | targetEnv/Automated Scripts/500680 | RATINGS_BD.csv       |
                | sourceEnv/Automated Scripts/500680 | targetEnv/Automated Scripts/500680 | RATINGS.csv          |
                | sourceEnv/Automated Scripts/500680 | targetEnv/Automated Scripts/500680 | RATINGS_DETAILS.csv  |
                | sourceEnv/Automated Scripts/500680 | targetEnv/Automated Scripts/500680 | SECTOR.csv           |
                | sourceEnv/Automated Scripts/500680 | targetEnv/Automated Scripts/500680 | SECTOR_DETAILS.csv   |
                | sourceEnv/Automated Scripts/500680 | targetEnv/Automated Scripts/500680 | TOP10_HOLDINGS.csv   |


              @EISGEISAPPS-674
              Examples:
                | sourcePath                         | targetPath                         | fileName             |
                | sourceEnv/Automated Scripts/500720 | targetEnv/Automated Scripts/500720 | COUNTRY.csv          |
                | sourceEnv/Automated Scripts/500720 | targetEnv/Automated Scripts/500720 | COUNTRY_DETAILS.csv  |
                | sourceEnv/Automated Scripts/500720 | targetEnv/Automated Scripts/500720 | MATURITY.csv         |
                | sourceEnv/Automated Scripts/500720 | targetEnv/Automated Scripts/500720 | MATURITY_DETAILS.csv |
                | sourceEnv/Automated Scripts/500720 | targetEnv/Automated Scripts/500720 | RATINGS_BD.csv       |
                | sourceEnv/Automated Scripts/500720 | targetEnv/Automated Scripts/500720 | RATINGS.csv          |
                | sourceEnv/Automated Scripts/500720 | targetEnv/Automated Scripts/500720 | RATINGS_DETAILS.csv  |
                | sourceEnv/Automated Scripts/500720 | targetEnv/Automated Scripts/500720 | SECTOR.csv           |
                | sourceEnv/Automated Scripts/500720 | targetEnv/Automated Scripts/500720 | SECTOR_DETAILS.csv   |
                | sourceEnv/Automated Scripts/500720 | targetEnv/Automated Scripts/500720 | TOP10_HOLDINGS.csv   |


              @EISGEISAPPS-675
              Examples:
                | sourcePath                         | targetPath                         | fileName            |
                | sourceEnv/Automated Scripts/500740 | targetEnv/Automated Scripts/500740 | COUNTRY.csv         |
                | sourceEnv/Automated Scripts/500740 | targetEnv/Automated Scripts/500740 | COUNTRY_DETAILS.csv |
                | sourceEnv/Automated Scripts/500740 | targetEnv/Automated Scripts/500740 | SECTOR.csv          |
                | sourceEnv/Automated Scripts/500740 | targetEnv/Automated Scripts/500740 | SECTOR_DETAILS.csv  |
                | sourceEnv/Automated Scripts/500740 | targetEnv/Automated Scripts/500740 | TOP10_HOLDINGS.csv  |


              @EISGEISAPPS-676
              Examples:
                | sourcePath                   | targetPath                   | fileName                   |
                | sourceEnv/CASH_FUND/CASHFUND | targetEnv/CASH_FUND/CASHFUND | REM_PERIOD_TO_MATURITY.csv |
                | sourceEnv/CASH_FUND/CASHFUND | targetEnv/CASH_FUND/CASHFUND | TOP10_HOLDINGS.csv         |


              @EISGEISAPPS-677
              Examples:
                | sourcePath             | targetPath             | fileName           |
                | sourceEnv/CHNAG/500730 | targetEnv/CHNAG/500730 | SECTOR.csv         |
                | sourceEnv/CHNAG/500730 | targetEnv/CHNAG/500730 | SECTOR_DETAILS.csv |
                | sourceEnv/CHNAG/500730 | targetEnv/CHNAG/500730 | TOP10_HOLDINGS.csv |


              @EISGEISAPPS-678
              Examples:
                | sourcePath                           | targetPath                           | fileName           |
                | sourceEnv/EUR_INV_GRADE_BONDS/500190 | targetEnv/EUR_INV_GRADE_BONDS/500190 | COUNTRY.csv        |
                | sourceEnv/EUR_INV_GRADE_BONDS/500190 | targetEnv/EUR_INV_GRADE_BONDS/500190 | MATURITY.csv       |
                | sourceEnv/EUR_INV_GRADE_BONDS/500190 | targetEnv/EUR_INV_GRADE_BONDS/500190 | RATINGS_BD.csv     |
                | sourceEnv/EUR_INV_GRADE_BONDS/500190 | targetEnv/EUR_INV_GRADE_BONDS/500190 | RATINGS.csv        |
                | sourceEnv/EUR_INV_GRADE_BONDS/500190 | targetEnv/EUR_INV_GRADE_BONDS/500190 | SECTOR.csv         |
                | sourceEnv/EUR_INV_GRADE_BONDS/500190 | targetEnv/EUR_INV_GRADE_BONDS/500190 | TOP10_HOLDINGS.csv |


              @EISGEISAPPS-679
              Examples:
                | sourcePath              | targetPath              | fileName            |
                | sourceEnv/GEMCEF/500320 | targetEnv/GEMCEF/500320 | COUNTRY.csv         |
                | sourceEnv/GEMCEF/500320 | targetEnv/GEMCEF/500320 | COUNTRY_DETAILS.csv |
                | sourceEnv/GEMCEF/500320 | targetEnv/GEMCEF/500320 | SECTOR.csv          |
                | sourceEnv/GEMCEF/500320 | targetEnv/GEMCEF/500320 | SECTOR_DETAILS.csv  |
                | sourceEnv/GEMCEF/500320 | targetEnv/GEMCEF/500320 | TOP10_HOLDINGS.csv  |


              @EISGEISAPPS-680
              Examples:
                | sourcePath            | targetPath            | fileName           |
                | sourceEnv/GENF/500421 | targetEnv/GENF/500421 | TOP10_HOLDINGS.csv |


              @EISGEISAPPS-681
              Examples:
                | sourcePath            | targetPath            | fileName                    |
                | sourceEnv/GMAG/500620 | targetEnv/GMAG/500620 | FUND_ALLOCATION.csv         |
                | sourceEnv/GMAG/500620 | targetEnv/GMAG/500620 | FUND_ALLOCATION_DETAILS.csv |
                | sourceEnv/GMAG/500620 | targetEnv/GMAG/500620 | TOP10_HOLDINGS.csv          |


              @EISGEISAPPS-682
              Examples:
                | sourcePath            | targetPath            | fileName            |
                | sourceEnv/GMNF/500460 | targetEnv/GMNF/500460 | FUND_ALLOCATION.csv |
                | sourceEnv/GMNF/500460 | targetEnv/GMNF/500460 | TOP10_HOLDINGS.csv  |


              @EISGEISAPPS-683
              Examples:
                | sourcePath                               | targetPath                               | fileName           |
                | sourceEnv/Japan_Fundamental_Value/500490 | targetEnv/Japan_Fundamental_Value/500490 | SECTOR.csv         |
                | sourceEnv/Japan_Fundamental_Value/500490 | targetEnv/Japan_Fundamental_Value/500490 | SECTOR_DETAILS.csv |
                | sourceEnv/Japan_Fundamental_Value/500490 | targetEnv/Japan_Fundamental_Value/500490 | TOP10_HOLDINGS.csv |


              @EISGEISAPPS-684
              Examples:
                | sourcePath              | targetPath              | fileName            |
                | sourceEnv/OTHERS/500150 | targetEnv/OTHERS/500150 | COUNTRY.csv         |
                | sourceEnv/OTHERS/500150 | targetEnv/OTHERS/500150 | COUNTRY_DETAILS.csv |
                | sourceEnv/OTHERS/500150 | targetEnv/OTHERS/500150 | SECTOR.csv          |
                | sourceEnv/OTHERS/500150 | targetEnv/OTHERS/500150 | SECTOR_DETAILS.csv  |
                | sourceEnv/OTHERS/500150 | targetEnv/OTHERS/500150 | TOP10_HOLDINGS.csv  |


              @EISGEISAPPS-685
              Examples:
                | sourcePath              | targetPath              | fileName            |
                | sourceEnv/OTHERS/500410 | targetEnv/OTHERS/500410 | COUNTRY.csv         |
                | sourceEnv/OTHERS/500410 | targetEnv/OTHERS/500410 | COUNTRY_DETAILS.csv |
                | sourceEnv/OTHERS/500410 | targetEnv/OTHERS/500410 | SECTOR.csv          |
                | sourceEnv/OTHERS/500410 | targetEnv/OTHERS/500410 | SECTOR_DETAILS.csv  |
                | sourceEnv/OTHERS/500410 | targetEnv/OTHERS/500410 | TOP10_HOLDINGS.csv  |


              @EISGEISAPPS-686
              Examples:
                | sourcePath              | targetPath              | fileName            |
                | sourceEnv/OTHERS/500580 | targetEnv/OTHERS/500580 | COUNTRY.csv         |
                | sourceEnv/OTHERS/500580 | targetEnv/OTHERS/500580 | COUNTRY_DETAILS.csv |
                | sourceEnv/OTHERS/500580 | targetEnv/OTHERS/500580 | SECTOR.csv          |
                | sourceEnv/OTHERS/500580 | targetEnv/OTHERS/500580 | SECTOR_DETAILS.csv  |
                | sourceEnv/OTHERS/500580 | targetEnv/OTHERS/500580 | TOP10_HOLDINGS.csv  |


              @EISGEISAPPS-687
              Examples:
                | sourcePath            | targetPath            | fileName            |
                | sourceEnv/PDGF/SG9121 | targetEnv/PDGF/SG9121 | COUNTRY.csv         |
                | sourceEnv/PDGF/SG9121 | targetEnv/PDGF/SG9121 | COUNTRY_DETAILS.csv |
                | sourceEnv/PDGF/SG9121 | targetEnv/PDGF/SG9121 | SECTOR_DETAILS.csv  |
                | sourceEnv/PDGF/SG9121 | targetEnv/PDGF/SG9121 | TOP10_HOLDINGS.csv  |

              @EISGEISAPPS-689
              Examples:
                | sourcePath            | targetPath            | fileName           |
                | sourceEnv/PPMA/500160 | targetEnv/PPMA/500160 | MATURITY.csv       |
                | sourceEnv/PPMA/500160 | targetEnv/PPMA/500160 | RATINGS_BD.csv     |
                | sourceEnv/PPMA/500160 | targetEnv/PPMA/500160 | RATINGS.csv        |
                | sourceEnv/PPMA/500160 | targetEnv/PPMA/500160 | SECTOR.csv         |
                | sourceEnv/PPMA/500160 | targetEnv/PPMA/500160 | TOP10_HOLDINGS.csv |



              @EISGEISAPPS-690
              Examples:
                | sourcePath            | targetPath            | fileName           |
                | sourceEnv/PPMA/500170 | targetEnv/PPMA/500170 | MATURITY.csv       |
                | sourceEnv/PPMA/500170 | targetEnv/PPMA/500170 | RATINGS_BD.csv     |
                | sourceEnv/PPMA/500170 | targetEnv/PPMA/500170 | RATINGS.csv        |
                | sourceEnv/PPMA/500170 | targetEnv/PPMA/500170 | SECTOR.csv         |
                | sourceEnv/PPMA/500170 | targetEnv/PPMA/500170 | TOP10_HOLDINGS.csv |


              @EISGEISAPPS-691
              Examples:
                | sourcePath            | targetPath            | fileName           |
                | sourceEnv/PPMA/500180 | targetEnv/PPMA/500180 | MATURITY.csv       |
                | sourceEnv/PPMA/500180 | targetEnv/PPMA/500180 | RATINGS_BD.csv     |
                | sourceEnv/PPMA/500180 | targetEnv/PPMA/500180 | RATINGS.csv        |
                | sourceEnv/PPMA/500180 | targetEnv/PPMA/500180 | SECTOR.csv         |
                | sourceEnv/PPMA/500180 | targetEnv/PPMA/500180 | TOP10_HOLDINGS.csv |


              @EISGEISAPPS-692
              Examples:
                | sourcePath            | targetPath            | fileName           |
                | sourceEnv/PPMA/500430 | targetEnv/PPMA/500430 | MATURITY.csv       |
                | sourceEnv/PPMA/500430 | targetEnv/PPMA/500430 | RATINGS_BD.csv     |
                | sourceEnv/PPMA/500430 | targetEnv/PPMA/500430 | RATINGS.csv        |
                | sourceEnv/PPMA/500430 | targetEnv/PPMA/500430 | SECTOR.csv         |
                | sourceEnv/PPMA/500430 | targetEnv/PPMA/500430 | TOP10_HOLDINGS.csv |


              @EISGEISAPPS-693
              Examples:
                | sourcePath            | targetPath            | fileName           |
                | sourceEnv/PPMA/500440 | targetEnv/PPMA/500440 | MATURITY.csv       |
                | sourceEnv/PPMA/500440 | targetEnv/PPMA/500440 | RATINGS_BD.csv     |
                | sourceEnv/PPMA/500440 | targetEnv/PPMA/500440 | RATINGS.csv        |
                | sourceEnv/PPMA/500440 | targetEnv/PPMA/500440 | SECTOR.csv         |
                | sourceEnv/PPMA/500440 | targetEnv/PPMA/500440 | TOP10_HOLDINGS.csv |


              @EISGEISAPPS-694
              Examples:
                | sourcePath            | targetPath            | fileName           |
                | sourceEnv/PPMA/500600 | targetEnv/PPMA/500600 | MATURITY.csv       |
                | sourceEnv/PPMA/500600 | targetEnv/PPMA/500600 | RATINGS_BD.csv     |
                | sourceEnv/PPMA/500600 | targetEnv/PPMA/500600 | RATINGS.csv        |
                | sourceEnv/PPMA/500600 | targetEnv/PPMA/500600 | SECTOR.csv         |
                | sourceEnv/PPMA/500600 | targetEnv/PPMA/500600 | TOP10_HOLDINGS.csv |


              @EISGEISAPPS-695
              Examples:
                | sourcePath            | targetPath            | fileName           |
                | sourceEnv/PPMA/500700 | targetEnv/PPMA/500700 | MATURITY.csv       |
                | sourceEnv/PPMA/500700 | targetEnv/PPMA/500700 | RATINGS_BD.csv     |
                | sourceEnv/PPMA/500700 | targetEnv/PPMA/500700 | RATINGS.csv        |
                | sourceEnv/PPMA/500700 | targetEnv/PPMA/500700 | SECTOR.csv         |
                | sourceEnv/PPMA/500700 | targetEnv/PPMA/500700 | TOP10_HOLDINGS.csv |


              @EISGEISAPPS-701
              Examples:
                | sourcePath                        | targetPath                        | fileName            |
                | sourceEnv/PRU_ASEAN_Equity/SG3833 | targetEnv/PRU_ASEAN_Equity/SG3833 | COUNTRY.csv         |
                | sourceEnv/PRU_ASEAN_Equity/SG3833 | targetEnv/PRU_ASEAN_Equity/SG3833 | COUNTRY_DETAILS.csv |
                | sourceEnv/PRU_ASEAN_Equity/SG3833 | targetEnv/PRU_ASEAN_Equity/SG3833 | SECTOR_DETAILS.csv  |
                | sourceEnv/PRU_ASEAN_Equity/SG3833 | targetEnv/PRU_ASEAN_Equity/SG3833 | TOP10_HOLDINGS.csv  |

              @EISGEISAPPS-704
              Examples:
                | sourcePath                          | targetPath                          | fileName             |
                | sourceEnv/Pru_Asian_Balanced/SG4455 | targetEnv/Pru_Asian_Balanced/SG4455 | COUNTRY.csv          |
                | sourceEnv/Pru_Asian_Balanced/SG4455 | targetEnv/Pru_Asian_Balanced/SG4455 | COUNTRY_DETAILS.csv  |
                | sourceEnv/Pru_Asian_Balanced/SG4455 | targetEnv/Pru_Asian_Balanced/SG4455 | FUND_ALLOCATION.csv  |
                | sourceEnv/Pru_Asian_Balanced/SG4455 | targetEnv/Pru_Asian_Balanced/SG4455 | MATURITY.csv         |
                | sourceEnv/Pru_Asian_Balanced/SG4455 | targetEnv/Pru_Asian_Balanced/SG4455 | MATURITY_DETAILS.csv |
                | sourceEnv/Pru_Asian_Balanced/SG4455 | targetEnv/Pru_Asian_Balanced/SG4455 | RATINGS.csv          |
                | sourceEnv/Pru_Asian_Balanced/SG4455 | targetEnv/Pru_Asian_Balanced/SG4455 | RATINGS_DETAILS.csv  |
                | sourceEnv/Pru_Asian_Balanced/SG4455 | targetEnv/Pru_Asian_Balanced/SG4455 | SECTOR.csv           |
                | sourceEnv/Pru_Asian_Balanced/SG4455 | targetEnv/Pru_Asian_Balanced/SG4455 | SECTOR_DETAILS.csv   |
                | sourceEnv/Pru_Asian_Balanced/SG4455 | targetEnv/Pru_Asian_Balanced/SG4455 | TOP10_HOLDINGS.csv   |


              @EISGEISAPPS-705
              Examples:
                | sourcePath                       | targetPath                       | fileName            |
                | sourceEnv/PRU_Asian_Infra/SG2138 | targetEnv/PRU_Asian_Infra/SG2138 | COUNTRY.csv         |
                | sourceEnv/PRU_Asian_Infra/SG2138 | targetEnv/PRU_Asian_Infra/SG2138 | COUNTRY_DETAILS.csv |
                | sourceEnv/PRU_Asian_Infra/SG2138 | targetEnv/PRU_Asian_Infra/SG2138 | SECTOR.csv          |
                | sourceEnv/PRU_Asian_Infra/SG2138 | targetEnv/PRU_Asian_Infra/SG2138 | SECTOR_DETAILS.csv  |
                | sourceEnv/PRU_Asian_Infra/SG2138 | targetEnv/PRU_Asian_Infra/SG2138 | TOP10_HOLDINGS.csv  |


              @EISGEISAPPS-708
              Examples:
                | sourcePath                           | targetPath                           | fileName            |
                | sourceEnv/PRU_Global_Balanced/SG2190 | targetEnv/PRU_Global_Balanced/SG2190 | COUNTRY.csv         |
                | sourceEnv/PRU_Global_Balanced/SG2190 | targetEnv/PRU_Global_Balanced/SG2190 | COUNTRY_DETAILS.csv |
                | sourceEnv/PRU_Global_Balanced/SG2190 | targetEnv/PRU_Global_Balanced/SG2190 | FUND_ALLOCATION.csv |
                | sourceEnv/PRU_Global_Balanced/SG2190 | targetEnv/PRU_Global_Balanced/SG2190 | SECTOR.csv          |
                | sourceEnv/PRU_Global_Balanced/SG2190 | targetEnv/PRU_Global_Balanced/SG2190 | SECTOR_DETAILS.csv  |
                | sourceEnv/PRU_Global_Balanced/SG2190 | targetEnv/PRU_Global_Balanced/SG2190 | TOP10_HOLDINGS.csv  |


              @EISGEISAPPS-709
              Examples:
                | sourcePath                         | targetPath                         | fileName           |
                | sourceEnv/PRU_Global_Basics/SG2136 | targetEnv/PRU_Global_Basics/SG2136 | COUNTRY.csv        |
                | sourceEnv/PRU_Global_Basics/SG2136 | targetEnv/PRU_Global_Basics/SG2136 | SECTOR.csv         |
                | sourceEnv/PRU_Global_Basics/SG2136 | targetEnv/PRU_Global_Basics/SG2136 | TOP10_HOLDINGS.csv |


              @EISGEISAPPS-710
              Examples:
                | sourcePath                       | targetPath                       | fileName           |
                | sourceEnv/PRU_Global_Tech/SG3827 | targetEnv/PRU_Global_Tech/SG3827 | COUNTRY.csv        |
                | sourceEnv/PRU_Global_Tech/SG3827 | targetEnv/PRU_Global_Tech/SG3827 | SECTOR.csv         |
                | sourceEnv/PRU_Global_Tech/SG3827 | targetEnv/PRU_Global_Tech/SG3827 | TOP10_HOLDINGS.csv |


              @EISGEISAPPS-712
              Examples:
                | sourcePath                        | targetPath                        | fileName           |
                | sourceEnv/PRU_Pan_European/SG3828 | targetEnv/PRU_Pan_European/SG3828 | COUNTRY.csv        |
                | sourceEnv/PRU_Pan_European/SG3828 | targetEnv/PRU_Pan_European/SG3828 | SECTOR.csv         |
                | sourceEnv/PRU_Pan_European/SG3828 | targetEnv/PRU_Pan_European/SG3828 | TOP10_HOLDINGS.csv |


              @EISGEISAPPS-713
              Examples:
                | sourcePath                             | targetPath                             | fileName            |
                | sourceEnv/PRU_Rhodium_FIP3_FIP4/SG3837 | targetEnv/PRU_Rhodium_FIP3_FIP4/SG3837 | COUNTRY_DETAILS.csv |
                | sourceEnv/PRU_Rhodium_FIP3_FIP4/SG3837 | targetEnv/PRU_Rhodium_FIP3_FIP4/SG3837 | MATURITY.csv        |
                | sourceEnv/PRU_Rhodium_FIP3_FIP4/SG3837 | targetEnv/PRU_Rhodium_FIP3_FIP4/SG3837 | RATINGS.csv         |
                | sourceEnv/PRU_Rhodium_FIP3_FIP4/SG3837 | targetEnv/PRU_Rhodium_FIP3_FIP4/SG3837 | SECTOR_DETAILS.csv  |
                | sourceEnv/PRU_Rhodium_FIP3_FIP4/SG3837 | targetEnv/PRU_Rhodium_FIP3_FIP4/SG3837 | TOP10_HOLDINGS.csv  |


              @EISGEISAPPS-714
              Examples:
                | sourcePath                             | targetPath                             | fileName            |
                | sourceEnv/PRU_Rhodium_FIP3_FIP4/SG3839 | targetEnv/PRU_Rhodium_FIP3_FIP4/SG3839 | COUNTRY.csv         |
                | sourceEnv/PRU_Rhodium_FIP3_FIP4/SG3839 | targetEnv/PRU_Rhodium_FIP3_FIP4/SG3839 | COUNTRY_DETAILS.csv |
                | sourceEnv/PRU_Rhodium_FIP3_FIP4/SG3839 | targetEnv/PRU_Rhodium_FIP3_FIP4/SG3839 | MATURITY.csv        |
                | sourceEnv/PRU_Rhodium_FIP3_FIP4/SG3839 | targetEnv/PRU_Rhodium_FIP3_FIP4/SG3839 | RATINGS.csv         |
                | sourceEnv/PRU_Rhodium_FIP3_FIP4/SG3839 | targetEnv/PRU_Rhodium_FIP3_FIP4/SG3839 | SECTOR_DETAILS.csv  |
                | sourceEnv/PRU_Rhodium_FIP3_FIP4/SG3839 | targetEnv/PRU_Rhodium_FIP3_FIP4/SG3839 | TOP10_HOLDINGS.csv  |


              @EISGEISAPPS-715
              Examples:
                | sourcePath                             | targetPath                             | fileName            |
                | sourceEnv/PRU_Rhodium_FIP3_FIP4/SG3840 | targetEnv/PRU_Rhodium_FIP3_FIP4/SG3840 | COUNTRY_DETAILS.csv |
                | sourceEnv/PRU_Rhodium_FIP3_FIP4/SG3840 | targetEnv/PRU_Rhodium_FIP3_FIP4/SG3840 | MATURITY.csv        |
                | sourceEnv/PRU_Rhodium_FIP3_FIP4/SG3840 | targetEnv/PRU_Rhodium_FIP3_FIP4/SG3840 | RATINGS.csv         |
                | sourceEnv/PRU_Rhodium_FIP3_FIP4/SG3840 | targetEnv/PRU_Rhodium_FIP3_FIP4/SG3840 | SECTOR_DETAILS.csv  |
                | sourceEnv/PRU_Rhodium_FIP3_FIP4/SG3840 | targetEnv/PRU_Rhodium_FIP3_FIP4/SG3840 | TOP10_HOLDINGS.csv  |


              @EISGEISAPPS-718
              Examples:
                | sourcePath             | targetPath             | fileName           |
                | sourceEnv/SGAGG/500710 | targetEnv/SGAGG/500710 | SECTOR.csv         |
                | sourceEnv/SGAGG/500710 | targetEnv/SGAGG/500710 | SECTOR_DETAILS.csv |


              @EISGEISAPPS-717
              Examples:
                | sourcePath                       | targetPath                       | fileName             |
                | sourceEnv/PRU_Select_Bond/SG3830 | targetEnv/PRU_Select_Bond/SG3830 | COUNTRY.csv          |
                | sourceEnv/PRU_Select_Bond/SG3830 | targetEnv/PRU_Select_Bond/SG3830 | COUNTRY_DETAILS.csv  |
                | sourceEnv/PRU_Select_Bond/SG3830 | targetEnv/PRU_Select_Bond/SG3830 | MATURITY.csv         |
                | sourceEnv/PRU_Select_Bond/SG3830 | targetEnv/PRU_Select_Bond/SG3830 | MATURITY_DETAILS.csv |
                | sourceEnv/PRU_Select_Bond/SG3830 | targetEnv/PRU_Select_Bond/SG3830 | RATINGS.csv          |
                | sourceEnv/PRU_Select_Bond/SG3830 | targetEnv/PRU_Select_Bond/SG3830 | RATINGS_DETAILS.csv  |
                | sourceEnv/PRU_Select_Bond/SG3830 | targetEnv/PRU_Select_Bond/SG3830 | SECTOR.csv           |
                | sourceEnv/PRU_Select_Bond/SG3830 | targetEnv/PRU_Select_Bond/SG3830 | SECTOR_DETAILS.csv   |
                | sourceEnv/PRU_Select_Bond/SG3830 | targetEnv/PRU_Select_Bond/SG3830 | TOP10_HOLDINGS.csv   |


              @EISGEISAPPS-718
              Examples:
                | sourcePath             | targetPath             | fileName            |
                | sourceEnv/SGAGG/500710 | targetEnv/SGAGG/500710 | COUNTRY.csv         |
                | sourceEnv/SGAGG/500710 | targetEnv/SGAGG/500710 | COUNTRY_DETAILS.csv |


          #    File having mismatch due to random selection on sql output
              @manual @noRun
              Examples:
                | sourcePath                             | targetPath                             | fileName    |
                | sourceEnv/PRU_Rhodium_FIP3_FIP4/SG3840 | targetEnv/PRU_Rhodium_FIP3_FIP4/SG3840 | COUNTRY.csv |
                | sourceEnv/PRU_Rhodium_FIP3_FIP4/SG3840 | targetEnv/PRU_Rhodium_FIP3_FIP4/SG3840 | SECTOR.csv  |
                | sourceEnv/PRU_Rhodium_FIP3_FIP4/SG3839 | targetEnv/PRU_Rhodium_FIP3_FIP4/SG3839 | SECTOR.csv  |
                | sourceEnv/PRU_Rhodium_FIP3_FIP4/SG3837 | targetEnv/PRU_Rhodium_FIP3_FIP4/SG3837 | COUNTRY.csv |
                | sourceEnv/PRU_Rhodium_FIP3_FIP4/SG3837 | targetEnv/PRU_Rhodium_FIP3_FIP4/SG3837 | SECTOR.csv  |
                | sourceEnv/PRU_ASEAN_Equity/SG3833      | targetEnv/PRU_ASEAN_Equity/SG3833      | SECTOR.csv  |
                | sourceEnv/PDGF/SG9121                  | targetEnv/PDGF/SG9121                  | SECTOR.csv  |

          #    Files comparison skipped for files not generated
              @noRun
              Examples:
                | sourcePath                                   | targetPath                                   | fileName               |
                | sourceEnv/AREMAI/500360                      | targetEnv/AREMAI/500360                      | COUNTRY.csv            |
                | sourceEnv/AREMAI/500360                      | targetEnv/AREMAI/500360                      | COUNTRY_DETAILS.csv    |
                | sourceEnv/AREMAI/500360                      | targetEnv/AREMAI/500360                      | FUND_ALLOCATION.csv    |
                | sourceEnv/AREMAI/500360                      | targetEnv/AREMAI/500360                      | MATURITY.csv           |
                | sourceEnv/AREMAI/500360                      | targetEnv/AREMAI/500360                      | MATURITY_DETAILS.csv   |
                | sourceEnv/AREMAI/500360                      | targetEnv/AREMAI/500360                      | RATINGS.csv            |
                | sourceEnv/AREMAI/500360                      | targetEnv/AREMAI/500360                      | RATINGS_DETAILS.csv    |
                | sourceEnv/AREMAI/500360                      | targetEnv/AREMAI/500360                      | SECTOR.csv             |
                | sourceEnv/AREMAI/500360                      | targetEnv/AREMAI/500360                      | SECTOR_DETAILS.csv     |
                | sourceEnv/AREMAI/500360                      | targetEnv/AREMAI/500360                      | TOP10_HOLDINGS.csv     |
                | sourceEnv/ASIA_BONDS/500130                  | targetEnv/ASIA_BONDS/500130                  | RATINGS.csv            |
                | sourceEnv/ASIA_BONDS/500331                  | targetEnv/ASIA_BONDS/500331                  | RATINGS (comments).csv |
                | sourceEnv/ASIA_BONDS/500331                  | targetEnv/ASIA_BONDS/500331                  | RATINGS.csv            |
                | sourceEnv/ASIA_BONDS/500422                  | targetEnv/ASIA_BONDS/500422                  | RATINGS.csv            |
                | sourceEnv/PPMA/Apr 2015/500160               | targetEnv/PPMA/Apr 2015/500160               | ISSUER.csv             |
                | sourceEnv/PPMA/Apr 2015/500160               | targetEnv/PPMA/Apr 2015/500160               | RATING.csv             |
                | sourceEnv/PPMA/Apr 2015/500160               | targetEnv/PPMA/Apr 2015/500160               | SECTOR.csv             |
                | sourceEnv/PPMA/Apr 2015/500170               | targetEnv/PPMA/Apr 2015/500170               | ISSUER.csv             |
                | sourceEnv/PPMA/Apr 2015/500170               | targetEnv/PPMA/Apr 2015/500170               | RATING.csv             |
                | sourceEnv/PPMA/Apr 2015/500170               | targetEnv/PPMA/Apr 2015/500170               | SECTOR.csv             |
                | sourceEnv/PPMA/Apr 2015/500180               | targetEnv/PPMA/Apr 2015/500180               | ISSUER.csv             |
                | sourceEnv/PPMA/Apr 2015/500180               | targetEnv/PPMA/Apr 2015/500180               | RATING.csv             |
                | sourceEnv/PPMA/Apr 2015/500180               | targetEnv/PPMA/Apr 2015/500180               | SECTOR.csv             |
                | sourceEnv/PPMA/Apr 2015/500430               | targetEnv/PPMA/Apr 2015/500430               | ISSUER.csv             |
                | sourceEnv/PPMA/Apr 2015/500430               | targetEnv/PPMA/Apr 2015/500430               | RATING.csv             |
                | sourceEnv/PPMA/Apr 2015/500430               | targetEnv/PPMA/Apr 2015/500430               | SECTOR.csv             |
                | sourceEnv/PPMA/Apr 2015/500440               | targetEnv/PPMA/Apr 2015/500440               | ISSUER.csv             |
                | sourceEnv/PPMA/Apr 2015/500440               | targetEnv/PPMA/Apr 2015/500440               | RATING.csv             |
                | sourceEnv/PPMA/Apr 2015/500440               | targetEnv/PPMA/Apr 2015/500440               | SECTOR.csv             |
                | sourceEnv/Pru_Asian_Balanced/Apr 2015        | targetEnv/Pru_Asian_Balanced/Apr 2015        | Country.csv            |
                | sourceEnv/Pru_Asian_Balanced/Apr 2015        | targetEnv/Pru_Asian_Balanced/Apr 2015        | Sector.csv             |
                | sourceEnv/Pru_Asian_Balanced/Apr 2015        | targetEnv/Pru_Asian_Balanced/Apr 2015        | Security_name.csv      |
                | sourceEnv/Pru_Asian_Balanced/Dec 2015/SG4455 | targetEnv/Pru_Asian_Balanced/Dec 2015/SG4455 | Country.csv            |
                | sourceEnv/Pru_Asian_Balanced/Dec 2015/SG4455 | targetEnv/Pru_Asian_Balanced/Dec 2015/SG4455 | Sector.csv             |
                | sourceEnv/Pru_Asian_Balanced/Dec 2015/SG4455 | targetEnv/Pru_Asian_Balanced/Dec 2015/SG4455 | Security_name.csv      |
                | sourceEnv/Pru_FIP2/SG3838                    | targetEnv/Pru_FIP2/SG3838                    | COUNTRY.csv            |
                | sourceEnv/Pru_FIP2/SG3838                    | targetEnv/Pru_FIP2/SG3838                    | COUNTRY_DETAILS.csv    |
                | sourceEnv/Pru_FIP2/SG3838                    | targetEnv/Pru_FIP2/SG3838                    | MATURITY.csv           |
                | sourceEnv/Pru_FIP2/SG3838                    | targetEnv/Pru_FIP2/SG3838                    | RATINGS.csv            |
                | sourceEnv/Pru_FIP2/SG3838                    | targetEnv/Pru_FIP2/SG3838                    | SECTOR.csv             |
                | sourceEnv/Pru_FIP2/SG3838                    | targetEnv/Pru_FIP2/SG3838                    | SECTOR_DETAILS.csv     |
                | sourceEnv/Pru_FIP2/SG3838                    | targetEnv/Pru_FIP2/SG3838                    | TOP10_HOLDINGS.csv     |
                | sourceEnv/PRU_Global_Balanced/Apr 2015       | targetEnv/PRU_Global_Balanced/Apr 2015       | COUNTRY.csv            |
                | sourceEnv/PRU_Global_Balanced/Apr 2015       | targetEnv/PRU_Global_Balanced/Apr 2015       | HOLDINGS.csv           |
                | sourceEnv/PRU_Global_Balanced/Apr 2015       | targetEnv/PRU_Global_Balanced/Apr 2015       | SECTOR.csv             |
                | sourceEnv/PRU_Global_Titans/Apr 2015         | targetEnv/PRU_Global_Titans/Apr 2015         | Asset_Alloc.csv        |
                | sourceEnv/PRU_Global_Titans/Apr 2015         | targetEnv/PRU_Global_Titans/Apr 2015         | AssetNames.csv         |
                | sourceEnv/PRU_Select_Bond/Apr 2015           | targetEnv/PRU_Select_Bond/Apr 2015           | Country.csv            |
                | sourceEnv/PRU_Select_Bond/Apr 2015           | targetEnv/PRU_Select_Bond/Apr 2015           | Maturity_alloc.csv     |
                | sourceEnv/PRU_Select_Bond/Apr 2015           | targetEnv/PRU_Select_Bond/Apr 2015           | Ratings.csv            |
                | sourceEnv/PRU_Select_Bond/Apr 2015           | targetEnv/PRU_Select_Bond/Apr 2015           | SecurityNames.csv      |