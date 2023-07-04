package stepdefinitions;


import com.eastspring.qa.cart.core.exceptions.CartException;
import com.eastspring.qa.cart.core.exceptions.CartExceptionType;
import com.eastspring.qa.cart.core.utils.file.ExcelUtil;
import io.cucumber.java.en.*;
import org.apache.spark.sql.Dataset;
import org.apache.spark.sql.Row;
import com.eastspring.qa.cart.core.report.CartLogger;
import com.eastspring.qa.cart.core.services.data.SparkSvc;
import com.eastspring.qa.cart.core.utils.data.DataRecordCompareUtil;
import com.eastspring.qa.cart.core.utils.testData.TestDataFileUtil;
import com.eastspring.qa.cart.pages.DiagnosticPage;
import org.springframework.beans.factory.annotation.Autowired;

import java.nio.file.Path;
import java.util.List;


public class DiagnosticSteps {

    @Autowired
    protected DiagnosticPage diagnosticPage;

    @Autowired
    protected SparkSvc sparkSvc;

    @Given("the user run a dummy step")
    public void dummyStep() {
        CartLogger.info("I run a dummy step");
    }

    @Given("the user open a browser")
    public void openBrowser() {
        diagnosticPage.openWebUrl("https://home");
        diagnosticPage.capturePageScreenShot();
    }

    @Then("the user close the browser")
    public void closeBrowser() {
        diagnosticPage.quitBrowser();
    }

    @Then("the user expect {string} csv match with {string} csv as dataset")
    public void compareCSVFiles(String targetFileName, String referenceFileName) {
        sparkSvc.getSession();
        Dataset<Row> targetRecords = sparkSvc.getCSVDataset(TestDataFileUtil.getTestDataFilePath(targetFileName), true);
        Dataset<Row> referenceRecords = sparkSvc.getCSVDataset(TestDataFileUtil.getTestDataFilePath(referenceFileName), true);
        DataRecordCompareUtil.compareDatasetRows(targetRecords, referenceRecords, DataRecordCompareUtil.CompareMode.MATCH_ALL_RECORDS);
//        sparkSvc.endSession();
    }

    @Then("the user assert all records from {string} csv exist in {string} csv")
    public void lookupCSVFiles(String targetFileName, String referenceFileName) {
        List<String> targetRecords = TestDataFileUtil.getCSVAsString(targetFileName);
        List<String> referenceRecords = TestDataFileUtil.getCSVAsString(referenceFileName);
        // assuming the files contain headers
        if (!targetRecords.isEmpty() && !referenceRecords.isEmpty()) {
            if (!targetRecords.get(0).equals(referenceRecords.get(0))) {
                throw new CartException(CartExceptionType.ASSERTION_ERROR,
                        "The headers in target and reference files doesn't match. Abort comparison");
            }
        }
        DataRecordCompareUtil.compareStringLists(targetRecords, referenceRecords, DataRecordCompareUtil.CompareMode.LOOKUP_TARGET_IN_REFERENCE);
    }

    @Then("the user assert all records as dataset from {string} csv exist in {string} csv")
    public void lookupCSVFilesV2(String targetFileName, String referenceFileName) {
        sparkSvc.getSession();
        Dataset<Row> targetRecords = sparkSvc.getCSVDataset(TestDataFileUtil.getTestDataFilePath(targetFileName), true);
        Dataset<Row> referenceRecords = sparkSvc.getCSVDataset(TestDataFileUtil.getTestDataFilePath(referenceFileName), true);
        DataRecordCompareUtil.compareDatasetRows(targetRecords, referenceRecords, DataRecordCompareUtil.CompareMode.LOOKUP_TARGET_IN_REFERENCE);
    }

    @Then("the user expect records in {string} sheet from {string} excel match with {string} excel")
    public void compareExcelFiles(String sheetName, String targetFileName, String referenceFileName) {
        Path targetFilePath = TestDataFileUtil.getTestDataFilePath(targetFileName);
        Path referenceFilePath = TestDataFileUtil.getTestDataFilePath(referenceFileName);
        List<String> targetRecords = ExcelUtil.getRecordsAsStringList(targetFilePath, sheetName, ";", true);
        List<String> referenceRecords = ExcelUtil.getRecordsAsStringList(referenceFilePath, sheetName, ";", true);
        DataRecordCompareUtil.compareStringLists(targetRecords, referenceRecords, DataRecordCompareUtil.CompareMode.MATCH_ALL_RECORDS_IN_ORDER);
    }

    @Then("the user assert all records as dataset in {string} sheet from {string} excel exist in {string} excel")
    public void lookupExcelFiles(String sheetName, String targetFileName, String referenceFileName) {
        sparkSvc.getSession();
        Dataset<Row> targetRecords = sparkSvc.getExcelDataset(
                TestDataFileUtil.getTestDataFilePath(targetFileName),
                sheetName, true);
        Dataset<Row> referenceRecords = sparkSvc.getExcelDataset(
                TestDataFileUtil.getTestDataFilePath(referenceFileName),
                sheetName, true);
        DataRecordCompareUtil.compareDatasetRows(targetRecords, referenceRecords, DataRecordCompareUtil.CompareMode.LOOKUP_TARGET_IN_REFERENCE);
        sparkSvc.endSession();
    }
}