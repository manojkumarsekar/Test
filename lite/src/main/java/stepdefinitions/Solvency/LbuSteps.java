package stepdefinitions.Solvency;

import com.eastspring.qa.cart.core.report.CartLogger;
import com.eastspring.qa.cart.core.utils.core.WorkspaceUtil;
import com.eastspring.qa.cart.core.utils.file.CsvUtil;
import com.eastspring.qa.cart.core.utils.file.FileDirUtil;
import com.eastspring.qa.cart.core.utils.testData.TestDataFileUtil;
import com.eastspring.qa.solvency.lookup.LBUFileType;
import com.eastspring.qa.solvency.lookup.LBURegionCode;
import com.eastspring.qa.solvency.utils.business.LBUFileUtil;
import com.eastspring.qa.solvency.utils.common.DateTimeUtil;
import io.cucumber.java.en.Given;
import io.cucumber.java.en.Then;
import com.eastspring.qa.cart.core.exceptions.CartException;
import com.eastspring.qa.cart.core.exceptions.CartExceptionType;
import io.cucumber.java.en.When;
import org.apache.commons.csv.CSVPrinter;
import org.springframework.beans.factory.annotation.Autowired;
import java.io.File;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.text.SimpleDateFormat;
import java.util.HashMap;
import java.util.List;
import java.util.stream.Collectors;
import org.apache.commons.csv.CSVRecord;


public class LbuSteps extends BaseSolvencySteps {

    @Autowired
    public FileDirUtil fileDirUtil;

    public static String testFileName;

    @Given("^the user prepare (.+) LBU ((?:position|portfolio)) file based on (.+) for ((?:last|current|.*)) month$")
    public void prepareTestLBUFile(String regionCode, String fileType, String inputBaseFileName, String targetMonth) {
        LBUFileType lbuFileType = LBUFileUtil.lookupFileType(fileType);
        LBURegionCode lbuRegionCode = LBUFileUtil.lookupLbuCode(regionCode);
        testFileName = LBUFileUtil.getTestFileName(lbuRegionCode, lbuFileType, targetMonth, inputBaseFileName);
        Path sourceFilePath = Paths.get(WorkspaceUtil.getTestDataDir(), inputBaseFileName);
        Path targetFilePath = Paths.get(WorkspaceUtil.getExecutionReportsDir(), testFileName);
        if (!Files.exists(sourceFilePath)) {
            throw new CartException(CartExceptionType.FILE_NOT_FOUND, "[{}] not found", sourceFilePath.toString());
        }
        if (fileType.equalsIgnoreCase("portfolio")) {
            fileDirUtil.copyFile(new File(sourceFilePath.toString()),
                    new File(targetFilePath.toString())
            );
        } else if(fileType.equalsIgnoreCase("position")) {
            replaceStampWithDate(sourceFilePath, targetFilePath, targetMonth);
        }
        else {
            throw new CartException(CartExceptionType.INVALID_PARAM, "FileName is not displayed");
        }
        if (!Files.exists(targetFilePath)) {
            throw new CartException(CartExceptionType.FILE_NOT_FOUND,
                    "Test file [{}] is not copied from source template [{}]",
                    sourceFilePath.toString(),
                    targetFilePath.toString());
        }
        CartLogger.info("Test file " + targetFilePath + " file in created");
    }

    @When("^the user upload prepared ((?:position|portfolio)) file in LBU upload page$")
    public void uploadLbuPortfolio(String fileType) {
        Path targetFilePath = Paths.get(WorkspaceUtil.getExecutionReportsDir(), testFileName);
        if (!lbuUploadPage.isFileFieldDisplayed()) {
            throw new CartException(CartExceptionType.ASSERTION_ERROR, "LBU details table is not displayed");
        }
        lbuUploadPage.setFilePath(targetFilePath.toString());
        if (fileType.equalsIgnoreCase("portfolio")) {
            fileUploadPopUpPage.switchToPortfolioWindow();
        } else {
            fileUploadPopUpPage.switchToPositionWindow();
        }
        fileUploadPopUpPage.close();
        lbuUploadPage.switchToWindow();
        CartLogger.info("Uploaded " + targetFilePath + " file in LBU upload page");
    }
    @Then("the user assert if LBU Detail table is displayed in Lbu upload page")
    public void verifyLbuDetails() {
        if (!lbuUploadPage.isLBUDetailTableDisplayed()) {
            throw new CartException(CartExceptionType.ASSERTION_ERROR, "LBU details table is not displayed");
        }
        CartLogger.info("LBU details table is displayed");
    }

    @Given("^the user expect uploaded LBU file records for ((?:last|current|.*)) to be present in solvency db$")
    public void compareLBUFileRecordCount(String targetMonth) {
        String monthEndTimeStamp = new SimpleDateFormat("dd-MMM-yy").format(DateTimeUtil.getMonthEndDate(targetMonth));
        List<String> testFileRecords = CsvUtil.getRecordsAsStringList(Paths.get(WorkspaceUtil.getExecutionReportsDir(), testFileName), true);
        CartLogger.info("Number of records in test file [{}]: " + testFileRecords.size(), testFileName);
        String sqlQueryFileName = testFileName.replaceAll(".csv", "");
        String query = "select * from Sii_tom_portfolio where FILENAME='" + sqlQueryFileName + "' and Effective_Date='" + monthEndTimeStamp + "'";
        List<HashMap<String, String>> records = gcDatabase.executeSQLQueryForMaps(query);
        CartLogger.info("Number of queried records: " + records.size());
        if (records.size() != testFileRecords.size()) {
            throw new CartException(CartExceptionType.ASSERTION_ERROR, "Record Count is mismatch in---> " + testFileName + "sql Query is" + query);
        }
    }

    private void replaceStampWithDate(Path sourceFilePath, Path targetFilePath, String targetMonth) {
        String monthEndTimeStamp = new SimpleDateFormat("yyyyMMdd").format(DateTimeUtil.getMonthEndDate(targetMonth));
        List<CSVRecord> targetRecords = CsvUtil.getRecords(sourceFilePath, false);
        List<List<String>> updateRecords = targetRecords.stream().map(record -> record.stream()
                .map(cell -> cell.replace("<lastMonthEndYYYYMMDD>", monthEndTimeStamp))
                .collect(Collectors.toList())).collect(Collectors.toList());
        try {
            CSVPrinter csvPrinter = CsvUtil.getDefaultCSVWriter(targetFilePath.toString());
            for (List<String> record : updateRecords) {
                csvPrinter.printRecord(record);
            }
            csvPrinter.close();
        } catch (Exception ie) {
            ie.printStackTrace();
        }
    }
}