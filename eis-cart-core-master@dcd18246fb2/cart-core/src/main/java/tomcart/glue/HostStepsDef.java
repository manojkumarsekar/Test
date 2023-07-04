package tomcart.glue;

import com.eastspring.tom.cart.core.CartBootstrap;
import com.eastspring.tom.cart.core.steps.HostSteps;
import com.eastspring.tom.cart.core.utl.DataTableUtil;
import cucumber.api.java8.En;
import io.cucumber.datatable.DataTable;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import java.util.List;

/**
 * @author Daniel Baktiar
 * @since 2017-09
 */
public class HostStepsDef implements En {
    private static final Logger LOGGER = LoggerFactory.getLogger(HostStepsDef.class);

    private HostSteps hostSteps = (HostSteps) CartBootstrap.getBean(HostSteps.class);
    private DataTableUtil dataTableUtil = (DataTableUtil) CartBootstrap.getBean(DataTableUtil.class);


    public HostStepsDef() {
        When("I copy files below from local folder {string} to the host {string} folder {string}:", (String localDir, String destNamedHost,
                                                                                                                   String destRemoteDir, DataTable fileTable) -> {
            LOGGER.debug("copying files from local folder to remote host:");
            LOGGER.debug("  destNamedHost: {}", destNamedHost);
            LOGGER.debug("  localDir: {}", localDir);
            LOGGER.debug("  destRemoteDir: {}", destRemoteDir);
            LOGGER.debug("  fileTable.size: {}", fileTable.cells().size());

            List<String> fileList = dataTableUtil.getFirstColsAsList(fileTable);
            hostSteps.copyLocalFilesToRemote(localDir, fileList, destNamedHost, destRemoteDir);
        });

        When("I copy files below from remote folder {string} on host {string} into local folder {string}:", (String srcRemoteDir, String srcHost, String localDestDir, DataTable fileTable) -> {
            LOGGER.debug("copying files from local folder to remote host:");
            LOGGER.debug("  srcRemoteDir: {}", srcRemoteDir);
            LOGGER.debug("  srcHost: {}", srcHost);
            LOGGER.debug("  localDestDir: {}", localDestDir);
            LOGGER.debug("  fileTable.size: {}", fileTable.cells().size());

            List<String> fileList = dataTableUtil.getFirstColsAsList(fileTable);
            hostSteps.copyRemoteFilesToLocal(srcHost, srcRemoteDir, localDestDir, fileList);
        });

        Then("I expect below files to be (archived to|retained to|present in) the host {string} into folder {string} after processing:", (String destNamedHost, String folderLocation, DataTable fileTable) -> {
            List<String> fileList = dataTableUtil.getFirstColsAsList(fileTable);
            hostSteps.expectFileAvailableInFolderAfterProcessing(destNamedHost, folderLocation, fileList);
        });

        Then("I expect below files (to be deleted to|are not available in) the host {string} from folder {string} after processing:", (String destNamedHost, String folderLocation, DataTable fileTable) -> {
            List<String> fileList = dataTableUtil.getFirstColsAsList(fileTable);
            hostSteps.expectFileNotAvailableInFolderAfterProcessing(destNamedHost, folderLocation, fileList);
        });

        Then("I expect below files with pattern to be (archived to|retained to|present in) the host {string} into folder {string} after processing:", (String destNamedHost, String folderLocation, DataTable fileTable) -> {
            List<String> fileList = dataTableUtil.getFirstColsAsList(fileTable);
            hostSteps.expectFilePatternAvailableInFolderAfterProcessing(destNamedHost, folderLocation, fileList);
        });

        Then("I expect below files with pattern (to be deleted to|are not available in) the host {string} from folder {string} after processing:", (String destNamedHost, String folderLocation, DataTable fileTable) -> {
            List<String> fileList = dataTableUtil.getFirstColsAsList(fileTable);
            hostSteps.expectFilePatternNotAvailableInFolderAfterProcessing(destNamedHost, folderLocation, fileList);
        });

        Then("I remove below files in the host {string} from folder {string} if exists:", (String destNamedHost, String folderLocation, DataTable fileTable) -> {
            List<String> fileList = dataTableUtil.getFirstColsAsList(fileTable);
            hostSteps.removeFileIfExists(destNamedHost, folderLocation, fileList);
        });

        Then("I remove below files with pattern in the host {string} from folder {string} if exists:", (String destNamedHost, String folderLocation, DataTable fileTable) -> {
            List<String> fileList = dataTableUtil.getFirstColsAsList(fileTable);
            hostSteps.removeFileIfPatternExists(destNamedHost, folderLocation, fileList);
        });

        When("I read latest file with the pattern {string} in the path {string} with the host {string} into variable {string}", (String filePattern, String filepath, String hostConfig, String var) -> {
            hostSteps.getLatestFileNameWithPattern(hostConfig, filepath, filePattern, var);
        });

        Then("I rename file {string} as {string} in the named host {string}", (String srcFile, String dstFile, String destNamedHost) -> hostSteps.renameFile(srcFile, dstFile, destNamedHost));

        Then("I (copy|save) file {string} as {string} in the named host {string}", (String srcFile, String dstFile, String destNamedHost) -> hostSteps.saveFileAs(srcFile, dstFile, destNamedHost));

        Then("I expect file {string} is in Unix format in the named host {string}", (String filename, String destNamedHost) -> hostSteps.validateUnixFormat(filename, destNamedHost));

        Then("I copy below files or folders from ftp location {string} on host named config {string} into local folder {string} having pattern {string}", (String ftpPath, String ftpConfig, String localPath, String regExPattern, DataTable files) -> {
            hostSteps.ftpRemoteToLocalFolder(ftpPath, ftpConfig, localPath, dataTableUtil.getFirstColsAsList(files), regExPattern);
        });

        Then("I copy below files or folders from ftp location {string} on host named config {string} into local folder {string}", (String ftpPath, String ftpConfig, String localPath, DataTable files) -> {
            hostSteps.ftpRemoteToLocalFolder(ftpPath, ftpConfig, localPath, dataTableUtil.getFirstColsAsList(files), ".*");
        });

    }
}
