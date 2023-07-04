package stepdefinitions.filecompare;

import com.eastspring.qa.cart.core.configmanagers.AppConfigManager;
import com.eastspring.qa.cart.core.exceptions.CartException;
import com.eastspring.qa.cart.core.exceptions.CartExceptionType;
import com.eastspring.qa.cart.core.report.CartLogger;
import com.eastspring.qa.cart.core.utils.core.WorkspaceUtil;
import com.eastspring.qa.cart.core.utils.data.DataRecordCompareUtil;
import com.eastspring.qa.cart.core.utils.file.CsvUtil;
import com.eastspring.qa.cart.core.utils.file.FileDirUtil;
import io.cucumber.java.en.Given;
import io.cucumber.java.en.Then;

import java.io.File;
import java.io.IOException;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.util.List;

import org.apache.commons.io.FileUtils;
import org.springframework.beans.factory.annotation.Autowired;


public class CompareSteps extends BaseSteps {


    @Autowired
    protected AppConfigManager appConfigManager;

    @Autowired
    protected FileDirUtil fileDirUtil;


    @Then("the user expect {string} csv file in {string} and {string} to match with each other")
    public void compareCSVFiles(String fileName, String sourcePath, String targetPath) {

        Path sourceFile = Paths.get(WorkspaceUtil.getExecutionReportsDir(), sourcePath, fileName);
        Path targetFile = Paths.get(WorkspaceUtil.getExecutionReportsDir(), targetPath, fileName);

        if (!fileDirUtil.verifyFileExists(sourceFile.toString())) {
            CartLogger.error("Source '[{}]' is not found", sourceFile.toString());
            throw new CartException(CartExceptionType.FILE_NOT_FOUND, "Source file '[{}]' is not found", sourceFile.toString());
        }

        if (!fileDirUtil.verifyFileExists(targetFile.toString())) {
            CartLogger.error("Target file '[{}]' is not found", targetFile.toString());
            throw new CartException(CartExceptionType.FILE_NOT_FOUND, "Target file '[{}]' is not found", targetFile.toString());
        }

        List<String> targetRecords = CsvUtil.getRecordsAsStringList(targetFile, false);
        List<String> referenceRecords = CsvUtil.getRecordsAsStringList(sourceFile, false);

        if (!targetRecords.isEmpty() && !referenceRecords.isEmpty() && !targetRecords.get(0).equals(referenceRecords.get(0))) {
            throw new CartException(CartExceptionType.ASSERTION_ERROR,
                    "The headers in target and reference files doesn't match. Abort comparison");
        }

        DataRecordCompareUtil.compareStringLists(targetRecords, referenceRecords, DataRecordCompareUtil.CompareMode.MATCH_ALL_RECORDS);

    }

    @Given("^the user copy published ((?:source|target)) files from (.+) to (.+)$")
    public void folderCopy(final String type, final String sourcePath, final String dstFilePath) {
        String networkDrive = type.equals("source") ? appConfigManager.get("factsheet.src.publish")
                : appConfigManager.get("factsheet.tar.publish");
        Path sourceDirectory = Paths.get(networkDrive, sourcePath);
        try {
            FileUtils.copyDirectory(new File(sourceDirectory.toString()),
                    new File(Paths.get(WorkspaceUtil.getExecutionReportsDir(), dstFilePath).toString()));
        } catch (IOException e) {
            CartLogger.error("Failed to copy '[{}]' to '[{}]'",
                    networkDrive, dstFilePath);
        }
    }


}



