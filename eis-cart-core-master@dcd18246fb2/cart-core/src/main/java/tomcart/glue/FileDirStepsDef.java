package tomcart.glue;

import com.eastspring.tom.cart.core.CartBootstrap;
import com.eastspring.tom.cart.core.steps.FileDirSteps;
import cucumber.api.java8.En;

/**
 * @author Daniel Baktiar
 * @since 2017-09
 */
public class FileDirStepsDef implements En {
    private FileDirSteps fileDirSteps = (FileDirSteps) CartBootstrap.getBean(FileDirSteps.class);

    public FileDirStepsDef() {
        Then("I expect to see the file {string} exists", (String filename) -> fileDirSteps.verifyFileExists(filename));
        Then("I expect to see the size of the file {string} to be non-zero", (String filename) -> fileDirSteps.verifyFileSizeNonZero(filename));
        Then("I create the folder {string} if it does not exist", (String folder) -> fileDirSteps.createFolderIfNotExist(folder));
        Then("I expect file {string} should have {int} records", (String filename, Integer expectedRows) -> fileDirSteps.verifyNoOfRecordsInFile(filename, expectedRows));
        Given("I rename file {string} as {string}", (String srcFile, String dstFile) -> fileDirSteps.renameFile(srcFile, dstFile));
        Given("I (save|copy) file {string} as {string}", (String srcFile, String dstFile) -> fileDirSteps.saveAs(srcFile, dstFile));
        Given("I copy latest file from {string} with pattern {string} to {string} and assign file name to variable {string}", (String srcPath, String filePattern, String dstFilePath, String fileNameVariable) -> fileDirSteps.copyLatestFileWithPattern(srcPath, filePattern, dstFilePath, fileNameVariable));
        When("I convert file {string} encoding format from {string} to {string}", (String filepath, String srcEncoding, String targetEncoding) -> {
           fileDirSteps.convertEncoding(filepath, srcEncoding, targetEncoding);
        });
    }
}

