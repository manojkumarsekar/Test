package stepdefinitions.Solvency;


import com.eastspring.qa.cart.core.report.CartLogger;
import com.eastspring.qa.cart.core.utils.core.WorkspaceUtil;
import com.eastspring.qa.cart.core.utils.data.DataRecordCompareUtil;
import com.eastspring.qa.cart.core.utils.file.CsvUtil;
import com.eastspring.qa.cart.core.utils.file.ExcelUtil;
import com.eastspring.qa.cart.core.utils.testData.TestDataFileUtil;
import com.eastspring.qa.solvency.lookup.LBURegionCode;
import com.eastspring.qa.solvency.lookup.ReportType;
import com.eastspring.qa.solvency.utils.business.LBUFileUtil;
import com.eastspring.qa.solvency.utils.business.ReportFileUtil;
import com.eastspring.qa.solvency.utils.business.ValidationReportFileUtil;
import com.eastspring.qa.solvency.utils.common.DateTimeUtil;
import com.eastspring.qa.solvency.utils.common.ZipFolderUtil;
import io.cucumber.java.en.Given;
import io.cucumber.java.en.Then;
import org.assertj.core.api.SoftAssertions;

import java.nio.file.Path;
import java.nio.file.Paths;
import java.text.SimpleDateFormat;
import java.util.ArrayList;
import java.util.LinkedHashMap;
import java.util.List;

public class ReportSteps extends BaseSolvencySteps {

    String actualReportFileName;

    @Given("^the user download (.+) LBU (.+) report for ((?:last|current)) month from LBU reports page and unzip the (.+) file$")
    public void downloadLBUReport(String regionCode, String reportType, String targetMonth, String fileName) {
        ReportType validationReportType = ValidationReportFileUtil.lookupReportType(reportType);
        LBURegionCode lbuRegionCode = LBUFileUtil.lookupLbuCode(regionCode);
        String currentYear = new SimpleDateFormat("yyyy").format(DateTimeUtil.getMonthEndDate(targetMonth));
        String lastMonth = new SimpleDateFormat("MMMM").format(DateTimeUtil.getMonthEndDate(targetMonth));
        actualReportFileName = ReportFileUtil.getActualReportFileName(lbuRegionCode, validationReportType, targetMonth);
        validationPage.selectRegion();
        validationPage.selectLBU(lbuRegionCode.code);
        validationPage.selectYear(currentYear);
        validationPage.selectMonth(lastMonth);
        reportpage.clickSubmitButton();
        reportpage.waitUntilFileIsDownloaded(fileName);

    }

    @Given("^the user download ((?:LBU_1090|LBU_1081)) LBU (.+) report for ((?:last|current|.*)) month from Regional reports page$")
    public void downloadGHOReport(String regionCode, String reportType, String targetMonth) {
        ReportType validationReportType = ValidationReportFileUtil.lookupReportType(reportType);
        LBURegionCode lbuRegionCode = LBUFileUtil.lookupLbuCode(regionCode);
        String currentYear = new SimpleDateFormat("yyyy").format(DateTimeUtil.getMonthEndDate(targetMonth));
        String lastMonth = new SimpleDateFormat("MMMM").format(DateTimeUtil.getMonthEndDate(targetMonth));
        actualReportFileName = ReportFileUtil.getActualReportFileName(lbuRegionCode, validationReportType, targetMonth);
        validationPage.selectRegion();
        validationPage.selectLBU(lbuRegionCode.code);
        validationPage.selectYear(currentYear);
        validationPage.selectMonth(lastMonth);
        reportpage.clickSubmitButton();
        reportpage.waitUntilFileIsDownloaded(actualReportFileName);
    }

    @Given("^the user download ((?:LBU_1090|LBU_1081)) LBU (.+) report for ((?:last|current|.*)) month from LBU reports page$")
    public void downloadGHOIntegirtyReport(String regionCode, String reportType, String targetMonth) {
        ReportType validationReportType = ValidationReportFileUtil.lookupReportType(reportType);
        LBURegionCode lbuRegionCode = LBUFileUtil.lookupLbuCode(regionCode);
        String currentYear = new SimpleDateFormat("yyyy").format(DateTimeUtil.getMonthEndDate(targetMonth));
        String lastMonth = new SimpleDateFormat("MMMM").format(DateTimeUtil.getMonthEndDate(targetMonth));
        actualReportFileName = ReportFileUtil.getActualReportFileName(lbuRegionCode, validationReportType, targetMonth);
        validationPage.selectRegion();
        validationPage.selectLBU(lbuRegionCode.code);
        validationPage.selectYear(currentYear);
        validationPage.selectMonth(lastMonth);
        validationPage.clickSubmitButton();
        reportpage.waitUntilFileIsDownloaded(actualReportFileName);
    }


    @Then("^the user expect Regional records in (.+) sheets for ((?:last|remove-1)) row from downloaded ((?:LBU_1090|LBU_1081)) LBU (.+) report to match with (.+) reference file and exclude (.+) column$")
    public void validateRegionalReports(String sheetNames, String lastRow, String regionCode, String reportType, String referenceReportName, String columnName) {
        ReportType validationReportType = ValidationReportFileUtil.lookupReportType(reportType);
        LBURegionCode lbuRegionCode = LBUFileUtil.lookupLbuCode(regionCode);
        ReportFileUtil.assertReferenceReportFileName(validationReportType, lbuRegionCode, referenceReportName);
        int reduceLastRow = ReportFileUtil.getLastRowNumber(lastRow);
        String[] sheetNameList = sheetNames.split(",");
        SoftAssertions softAssertions = new SoftAssertions();
        for (String sheetName : sheetNameList) {
            try {
                Path targetFilePath = TestDataFileUtil.getTestDataFilePath(referenceReportName);
                Path referenceFilePath = Paths.get(WorkspaceUtil.getExecutionReportsDir(), referenceReportName);
                List<LinkedHashMap<String, String>> stringMapList1 = dataUploadPage.removeColumns(ExcelUtil.getRecordsAsStringMap(targetFilePath, sheetName, true), columnName);
                CartLogger.info("FileName " + stringMapList1);
                stringMapList1.remove(stringMapList1.size() - reduceLastRow);
                List<String> targetRecords = new ArrayList<String>();
                for (int i = 0; i < stringMapList1.size(); i++) {
                    System.out.println(stringMapList1.get(i));
                    targetRecords = new ArrayList<String>(stringMapList1.get(i).values());
                }
                List<LinkedHashMap<String, String>> stringMapList2 = dataUploadPage.removeColumns(ExcelUtil.getRecordsAsStringMap(referenceFilePath, sheetName, true), columnName);
                CartLogger.info("FileName " + stringMapList2);
                stringMapList2.remove(stringMapList2.size() - reduceLastRow);
                List<String> referenceRecords = new ArrayList<String>();
                for (int i = 0; i < stringMapList2.size(); i++) {
                    System.out.println(stringMapList2.get(i));
                    referenceRecords = new ArrayList<String>(stringMapList2.get(i).values());
                }
                CartLogger.info("Compare records from '[{}]' sheet in target ([{}]) and reference ([{}]) reports", sheetName, actualReportFileName, referenceReportName);
                DataRecordCompareUtil.compareStringLists(targetRecords, referenceRecords, DataRecordCompareUtil.CompareMode.MATCH_ALL_RECORDS);
            } catch (Exception ie) {
                CartLogger.error("Encountered error while comparing data from sheet '[{}]' in actual report [{}] with reference file [{}]. " +
                        "Exception message:  [{}]", sheetName, actualReportFileName, referenceReportName, ie.getMessage());
                softAssertions.fail("Encountered error while comparing data from sheet " + sheetName + " in actual report " + actualReportFileName + " with reference file " + referenceReportName + ". ");
            }
        }
        softAssertions.assertAll();
    }

    @Then("^the user unzip the expect records in (.+) sheets ((?:last|remove-1)) row from downloaded ((?:LBU_1090|LBU_1081)) LBU (.+) report unzip the (.+) to match with (.+) reference files$")
    public void validateGHOReports(String sheetNames, String lastRow, String regionCode, String reportType, String unzipFileName, String referenceReportName) {
        ReportType validationReportType = ValidationReportFileUtil.lookupReportType(reportType);
        LBURegionCode lbuRegionCode = LBUFileUtil.lookupLbuCode(regionCode);
        ReportFileUtil.assertReferenceReportFileName(validationReportType, lbuRegionCode, referenceReportName);
        ZipFolderUtil.unzipFolder(unzipFileName);
        int reduceLastRow = ReportFileUtil.getLastRowNumber(lastRow);
        SoftAssertions softAssertions = new SoftAssertions();
        try {

            List<String> targetRecords = CsvUtil.getRecordsAsStringList(Paths.get(WorkspaceUtil.getTestDataDir(), referenceReportName), true);
            targetRecords.remove(targetRecords.size() - reduceLastRow);
            List<String> referenceRecords = CsvUtil.getRecordsAsStringList(Paths.get(WorkspaceUtil.getExecutionReportsDir(), referenceReportName), true);
            referenceRecords.remove(referenceRecords.size() - reduceLastRow);
            CartLogger.info("Compare records from '[{}]' sheet in target ([{}]) and reference ([{}]) reports", sheetNames, actualReportFileName, referenceReportName);
            DataRecordCompareUtil.compareStringLists(targetRecords, referenceRecords, DataRecordCompareUtil.CompareMode.MATCH_ALL_RECORDS);
        } catch (Exception ie) {
            CartLogger.error("Encountered error while comparing data from sheet '[{}]' in actual report [{}] with reference file [{}]. " +
                    "Exception message:  [{}]", sheetNames, actualReportFileName, referenceReportName, ie.getMessage());
            softAssertions.fail("Encountered error while comparing data from sheet '[{}]' in actual report [{}] with reference file [{}]. " +
                    "Exception message:  [{}]", sheetNames, actualReportFileName, referenceReportName, ie.getMessage());

        }
        softAssertions.assertAll();
    }


    @Then("^the user expect Lbu consolidated records in (.+) sheets ((?:last|remove-4)) row from downloaded (.+) LBU (.+) report for ((?:last|current|.*)) month to match with (.+) reference files$")
    public void LBUConsolidated(String sheetNames,String lastRow, String regionCode, String reportType,String targetMonth,  String referenceReportName) {
        ReportType validationReportType = ValidationReportFileUtil.lookupReportType(reportType);
        LBURegionCode lbuRegionCode = LBUFileUtil.lookupLbuCode(regionCode);
        ReportFileUtil.assertReferenceReportFileName(validationReportType, lbuRegionCode, referenceReportName);
        actualReportFileName = ReportFileUtil.getActualReportFileName(lbuRegionCode, validationReportType, targetMonth);
        int numberOfRecordsToRemove = ReportFileUtil.getLastRowNumber(lastRow);
        SoftAssertions softAssertions = new SoftAssertions();
        try {
            Path targetFilePath = TestDataFileUtil.getTestDataFilePath(referenceReportName);
            Path referenceFilePath = Paths.get(WorkspaceUtil.getExecutionReportsDir(), actualReportFileName);
            List<String> targetRecords = ExcelUtil.getRecordsAsStringList(targetFilePath, sheetNames, ";", true);
            targetRecords = removeItems(targetRecords, numberOfRecordsToRemove);
            List<String> referenceRecords = ExcelUtil.getRecordsAsStringList(referenceFilePath, sheetNames, ";", true);
            referenceRecords = removeItems(referenceRecords, numberOfRecordsToRemove);
            CartLogger.info("Compare records from '[{}]' sheet in target ([{}]) and reference ([{}]) reports", sheetNames, actualReportFileName, referenceReportName);
            DataRecordCompareUtil.compareStringLists(targetRecords, referenceRecords, DataRecordCompareUtil.CompareMode.MATCH_ALL_RECORDS);
        } catch (Exception ie) {
            CartLogger.error("Encountered error while comparing data from sheet '[{}]' in actual report [{}] with reference file [{}]. " +
                    "Exception message:  [{}]", sheetNames, actualReportFileName, referenceReportName, ie.getMessage());

            softAssertions.fail("Encountered error while comparing data from sheet " + sheetNames + " in actual report " + actualReportFileName + " with reference file " + referenceReportName + ". ");

        }
        softAssertions.assertAll();

    }



    @Then("^the user expect GHO integrity records in (.+) sheets from downloaded (.+) LBU (.+) report for ((?:last|current-5)) month to match with (.+) reference files$")
    public void GHOIntegrity(String sheetNames, String regionCode, String reportType,String targetMonth, String referenceReportName) {
        ReportType validationReportType = ValidationReportFileUtil.lookupReportType(reportType);
        LBURegionCode lbuRegionCode = LBUFileUtil.lookupLbuCode(regionCode);
        ReportFileUtil.assertReferenceReportFileName(validationReportType, lbuRegionCode, referenceReportName);
        SoftAssertions softAssertions = new SoftAssertions();
        actualReportFileName = ReportFileUtil.getActualReportFileName(lbuRegionCode, validationReportType, targetMonth);
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

    private List<String> removeItems(List<String> inputList, int numberOfEndItems){
        for(int i=0; i< numberOfEndItems; i++){
            inputList.remove(inputList.size()-1);
        }
        return inputList;
    }



}