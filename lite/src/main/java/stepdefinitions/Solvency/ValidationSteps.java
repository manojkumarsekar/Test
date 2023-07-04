package stepdefinitions.Solvency;

import com.eastspring.qa.cart.core.report.CartLogger;
import com.eastspring.qa.cart.core.utils.core.WorkspaceUtil;
import com.eastspring.qa.cart.core.utils.data.DataRecordCompareUtil;
import com.eastspring.qa.cart.core.utils.file.ExcelUtil;
import com.eastspring.qa.cart.core.utils.testData.TestDataFileUtil;
import com.eastspring.qa.solvency.lookup.LBURegionCode;
import com.eastspring.qa.solvency.lookup.ReportType;
import com.eastspring.qa.solvency.utils.business.LBUFileUtil;
import com.eastspring.qa.solvency.utils.business.ReportFileUtil;
import com.eastspring.qa.solvency.utils.business.ValidationReportFileUtil;
import com.eastspring.qa.solvency.utils.common.DateTimeUtil;
import io.cucumber.java.en.Given;
import io.cucumber.java.en.Then;
import java.nio.file.Paths;
import java.text.SimpleDateFormat;
import java.util.List;
import java.nio.file.Path;


import org.assertj.core.api.SoftAssertions;


public class ValidationSteps extends BaseSolvencySteps {

    String actualReportFileName;


    @Then("^the user download (.+) LBU (.+) report for ((?:last|current|.*)) month from validation page$")
    public void downloadGHOIntegirtyReports(String regionCode, String reportType, String targetMonth) {
        ReportType validationReportType = ValidationReportFileUtil.lookupReportType(reportType);
        LBURegionCode lbuRegionCode = LBUFileUtil.lookupLbuCode(regionCode);
        String currentYear = new SimpleDateFormat("yyyy").format(DateTimeUtil.getMonthEndDate(targetMonth));
        String lastMonth = new SimpleDateFormat("MMMM").format(DateTimeUtil.getMonthEndDate(targetMonth));
        actualReportFileName = ValidationReportFileUtil.getActualReportFileName(lbuRegionCode, validationReportType, targetMonth);
        validationPage.selectRegion();
        validationPage.selectLBU(lbuRegionCode.code);
        validationPage.selectYear(currentYear);
        validationPage.selectMonth(lastMonth);
        validationPage.clickGHOIntegritySubmitButton();
        validationPage.waitUntilFileIsDownloaded(actualReportFileName);
    }

    @Given("^the user download (.+) LBU (.+) report for ((?:last|current|.*)) month from LBUConsol reports page$")
    public void downloadLBUConsoleReport(String regionCode, String reportType, String targetMonth) {
        ReportType validationReportType = ValidationReportFileUtil.lookupReportType(reportType);
        LBURegionCode lbuRegionCode = LBUFileUtil.lookupLbuCode(regionCode);
        String currentYear = new SimpleDateFormat("yyyy").format(DateTimeUtil.getMonthEndDate(targetMonth));
        String lastMonth = new SimpleDateFormat("MMMM").format(DateTimeUtil.getMonthEndDate(targetMonth));
        actualReportFileName = ValidationReportFileUtil.getActualReportFileName(lbuRegionCode, validationReportType, targetMonth);
        validationPage.selectRegion();
        validationPage.selectLBU(lbuRegionCode.code);
        validationPage.selectLBUCOLYear(currentYear);
        validationPage.lstLBUColYear(lastMonth);
        reportpage.clickSubmitButton();
        validationPage.waitUntilFileIsDownloaded(actualReportFileName);

    }

    @Then("^the user download (.+) LBU (.+) report for ((?:last|current|.*)) month from validation pages$")
    public void downloadReports(String regionCode, String reportType, String targetMonth) {
        ReportType validationReportType = ValidationReportFileUtil.lookupReportType(reportType);
        LBURegionCode lbuRegionCode = LBUFileUtil.lookupLbuCode(regionCode);
        String currentYear = new SimpleDateFormat("yyyy").format(DateTimeUtil.getMonthEndDate(targetMonth));
        String lastMonth = new SimpleDateFormat("MMMM").format(DateTimeUtil.getMonthEndDate(targetMonth));
        actualReportFileName = ValidationReportFileUtil.getActualReportFileName(lbuRegionCode, validationReportType, targetMonth);
        validationPage.selectRegion();
        validationPage.selectLBU(lbuRegionCode.code);
        validationPage.selectYear(currentYear);
        validationPage.selectMonth(lastMonth);
        reportpage.clickSubmitButton();
        validationPage.waitUntilFileIsDownloaded(actualReportFileName);

    }

    @Then("^the user expect records in (.+) sheets from downloaded (.+) LBU (.+) report for ((?:last|current|.*)) month to match with (.+) reference files$")
    public void FxRateComparisonReport(String sheetNames, String regionCode, String reportType,String targetMonth, String referenceReportName) {
        ReportType validationReportType = ValidationReportFileUtil.lookupReportType(reportType);
        LBURegionCode lbuRegionCode = LBUFileUtil.lookupLbuCode(regionCode);
        ReportFileUtil.assertReferenceReportFileName(validationReportType, lbuRegionCode, referenceReportName);
        actualReportFileName = ValidationReportFileUtil.getActualReportFileName(lbuRegionCode, validationReportType, targetMonth);
        SoftAssertions softAssertions = new SoftAssertions();
        try {
            Path targetFilePath = TestDataFileUtil.getTestDataFilePath(referenceReportName);
            Path referenceFilePath = Paths.get(WorkspaceUtil.getExecutionReportsDir(), actualReportFileName);
            List<String> targetRecords = ExcelUtil.getRecordsAsStringList(targetFilePath, sheetNames, ";", true);
            List<String> referenceRecords = ExcelUtil.getRecordsAsStringList(referenceFilePath, sheetNames, ";", true);
            CartLogger.info("Compare records from '[{}]' sheet in target ([{}]) and reference ([{}]) reports", sheetNames, actualReportFileName, referenceReportName);
            DataRecordCompareUtil.compareStringLists(targetRecords, referenceRecords, DataRecordCompareUtil.CompareMode.MATCH_ALL_RECORDS);
        } catch (Exception ie) {
            CartLogger.error("Encountered error while comparing data from sheet '[{}]' in actual report [{}] with reference file [{}]. " +
                    "Exception message:  [{}]", sheetNames, actualReportFileName, referenceReportName, ie.getMessage());

            softAssertions.fail("Encountered error while comparing data from sheet " + sheetNames + " in actual report " + actualReportFileName + " with reference file " + referenceReportName + ". ");

        }
        softAssertions.assertAll();
    }

    @Then("^the user expect CIC records in (.+) sheets from downloaded (.+) LBU (.+) report to match with (.+) reference files$")
    public void CICDComparisonReports(String sheetNames, String regionCode, String reportType, String referenceReportName) {
        ReportType validationReportType = ValidationReportFileUtil.lookupReportType(reportType);
        LBURegionCode lbuRegionCode = LBUFileUtil.lookupLbuCode(regionCode);
        ReportFileUtil.assertReferenceReportFileName(validationReportType, lbuRegionCode, referenceReportName);
        SoftAssertions softAssertions = new SoftAssertions();
        String[] sheetNameList = sheetNames.split(",");
        for (String sheetName : sheetNameList) {
            try {
                Path targetFilePath = TestDataFileUtil.getTestDataFilePath(referenceReportName);
                Path referenceFilePath = Paths.get(WorkspaceUtil.getExecutionReportsDir(), actualReportFileName);
                List<String> targetRecords = ExcelUtil.getRecordsAsStringList(targetFilePath, sheetName, ";", true);
                List<String> referenceRecords = ExcelUtil.getRecordsAsStringList(referenceFilePath, sheetName, ";", true);
                CartLogger.info("Compare records from '[{}]' sheet in target ([{}]) and reference ([{}]) reports", sheetNames, actualReportFileName, referenceReportName);
                DataRecordCompareUtil.compareStringLists(targetRecords, referenceRecords, DataRecordCompareUtil.CompareMode.MATCH_ALL_RECORDS);
            } catch (Exception ie) {
                CartLogger.error("Encountered error while comparing data from sheet '[{}]' in actual report [{}] with reference file [{}]. " +
                        "Exception message:  [{}]", sheetNames, actualReportFileName, referenceReportName, ie.getMessage());

                softAssertions.fail("Encountered error while comparing data from sheet " + sheetNames + " in actual report " + actualReportFileName + " with reference file " + referenceReportName + ". ");

            }

        }
        softAssertions.assertAll();
    }


}