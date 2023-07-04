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