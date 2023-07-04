package com.eastspring.tom.cart.core.steps;

import com.eastspring.tom.cart.core.CartException;
import com.eastspring.tom.cart.core.CartExceptionType;
import com.eastspring.tom.cart.core.svc.RuntimeRemoteSvc;
import com.eastspring.tom.cart.core.svc.StateSvc;
import com.eastspring.tom.cart.core.svc.WorkspaceDirSvc;
import com.eastspring.tom.cart.core.utl.DataTableUtil;
import com.eastspring.tom.cart.core.utl.FileDirUtil;
import com.eastspring.tom.cart.core.utl.FormatterUtil;
import com.eastspring.tom.cart.core.utl.WorkspaceUtil;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;

import java.io.File;
import java.util.List;
import java.util.Map;

public class HostSteps {
    private static final Logger LOGGER = LoggerFactory.getLogger(HostSteps.class);

    public static final String HOSTMAP_NAME = "host";
    public static final String HOSTMAP_USER = "user";
    public static final String HOSTMAP_PORT = "port";
    public static final String CMD_TO_EXECUTE = "Cmd to Execute: [{}]";

    private String hostName;
    private String hostUser;
    private String hostPort;

    public String getHostName() {
        return hostName;
    }

    public String getHostUser() {
        return hostUser;
    }

    public String getHostPort() {
        return hostPort;
    }

    public void configureHostDetails(final String namedHost) {
        LOGGER.debug("configuring Host Details [{}]", namedHost);
        Map<String, String> namedHostMap = stateSvc.getValueMapFromPrefix(namedHost, true);
        hostName = namedHostMap.get(HOSTMAP_NAME);
        hostUser = namedHostMap.get(HOSTMAP_USER);
        hostPort = namedHostMap.get(HOSTMAP_PORT);
    }

    @Autowired
    private FileDirUtil fileDirUtil;

    @Autowired
    private RuntimeRemoteSvc runtimeRemoteSvc;

    @Autowired
    private StateSvc stateSvc;

    @Autowired
    private WorkspaceUtil workspaceUtil;

    @Autowired
    private DataTableUtil dataTableUtil;

    @Autowired
    private WorkspaceDirSvc workspaceDirSvc;

    @Autowired
    private FormatterUtil formatterUtil;

    public void copyLocalFilesToRemote(String localDir, List<String> fileList, String destNamedHost, String destRemoteDir) {
        this.configureHostDetails(destNamedHost);
        String expandDestRemoteDir = stateSvc.expandVar(destRemoteDir);
        LOGGER.debug("copyLocalFilesToRemote: port: [{}]", getHostPort());
        for (String file : fileList) {
            String expandFile = stateSvc.expandVar(file);
            String expandlocalDir = stateSvc.expandVar(localDir);
            String localSrcFile = workspaceDirSvc.normalize(expandlocalDir + File.separator + expandFile);
            runtimeRemoteSvc.sshUpload(getHostName(), Integer.valueOf(getHostPort()), getHostUser(), localSrcFile, expandDestRemoteDir);
        }
    }

    public void copyRemoteFilesToLocal(String srcNamedHost, String srcRemoteDir, String localDestDir, List<String> fileList) {
        this.configureHostDetails(srcNamedHost);
        String localDestDirFullpath = workspaceDirSvc.normalize(stateSvc.expandVar(localDestDir));
        String srcRemoteDirExpanded = stateSvc.expandVar(srcRemoteDir);
        LOGGER.debug("Downloading from {}@{}:{} to [{}]", getHostUser(), getHostName(), srcRemoteDirExpanded, localDestDir);

        fileDirUtil.forceMkdir(localDestDirFullpath);

        for (String file : fileList) {
            String expandFile = stateSvc.expandVar(file);
            runtimeRemoteSvc.sshDownload(getHostName(), Integer.valueOf(getHostPort()), getHostUser(), srcRemoteDirExpanded + '/' + expandFile, localDestDirFullpath);
        }
    }

    public void expectFileAvailableInFolderAfterProcessing(String destNamedHost, String folderLocation, List<String> fileList) {
        String expandFolderLocation = stateSvc.expandVar(folderLocation);
        this.configureHostDetails(destNamedHost);
        boolean fileCheckFlag = true;
        StringBuilder loggerErrorMessage = new StringBuilder();

        for (String file : fileList) {
            String expandedFileName = stateSvc.expandVar(file);

            if (!runtimeRemoteSvc.sshFileExists(getHostName(),
                    Integer.parseInt(getHostPort()), getHostUser(),
                    expandFolderLocation + "/" + expandedFileName,
                    10)) {
                fileCheckFlag = false;
                loggerErrorMessage.append(String.format("Verification Failed, file %s is NOT available in the Folder %s\n", expandedFileName, expandFolderLocation));
            } else {
                LOGGER.info("File [{}] is available in the Folder [{}] as Expected", expandedFileName, expandFolderLocation);
            }
        }
        if (!fileCheckFlag) {
            LOGGER.error("{}", loggerErrorMessage);
            throw new CartException(CartExceptionType.VERIFICATION_FAILED, loggerErrorMessage.toString());
        }
    }

    public void expectFileNotAvailableInFolderAfterProcessing(String destNamedHost, String folderLocation, List<String> fileList) {
        String expandFolderLocation = stateSvc.expandVar(folderLocation);
        this.configureHostDetails(destNamedHost);
        boolean fileCheckFlag = true;
        StringBuilder loggerErrorMessage = new StringBuilder();

        for (String file : fileList) {
            String expandedFileName = stateSvc.expandVar(file);
            if (runtimeRemoteSvc.sshFileExists(getHostName(), Integer.parseInt(getHostPort()), getHostUser(), expandFolderLocation + "/" + expandedFileName)) {
                fileCheckFlag = false;
                loggerErrorMessage.append(String.format("Verification Failed, file %s is available in the Folder %s\n", expandedFileName, expandFolderLocation));
            } else {
                LOGGER.info("File [{}] is NOT available in the Folder [{}] as Expected", expandedFileName, expandFolderLocation);
            }
        }
        if (!fileCheckFlag) {
            LOGGER.error("{}", loggerErrorMessage);
            throw new CartException(CartExceptionType.VERIFICATION_FAILED, loggerErrorMessage.toString());
        }
    }

    public void expectFilePatternAvailableInFolderAfterProcessing(String destNamedHost, String folderLocation, List<String> filePatternList) {
        String expandFolderLocation = stateSvc.expandVar(folderLocation);
        this.configureHostDetails(destNamedHost);
        boolean fileCheckFlag = true;
        StringBuilder loggerErrorMessage = new StringBuilder();

        for (String file : filePatternList) {
            String expandedFilePattern = stateSvc.expandVar(file);
            if (!runtimeRemoteSvc.sshFileExistsWithRegEx(getHostName(), Integer.parseInt(getHostPort()), getHostUser(), expandFolderLocation, expandedFilePattern)) {
                fileCheckFlag = false;
                loggerErrorMessage.append(String.format("Verification Failed, file with pattern %s is NOT available in the Folder %s\n", expandedFilePattern, expandFolderLocation));
            } else {
                LOGGER.info("File with pattern [{}] is available in the Folder [{}] as Expected", expandedFilePattern, expandFolderLocation);
            }
        }
        if (!fileCheckFlag) {
            LOGGER.error("{}", loggerErrorMessage);
            throw new CartException(CartExceptionType.VERIFICATION_FAILED, loggerErrorMessage.toString());
        }
    }

    public void expectFilePatternNotAvailableInFolderAfterProcessing(String destNamedHost, String folderLocation, List<String> filePatternList) {
        String expandFolderLocation = stateSvc.expandVar(folderLocation);
        this.configureHostDetails(destNamedHost);
        boolean fileCheckFlag = true;
        StringBuilder loggerErrorMessage = new StringBuilder();

        for (String file : filePatternList) {
            String expandedFilePattern = stateSvc.expandVar(file);
            if (runtimeRemoteSvc.sshFileExistsWithRegEx(getHostName(), Integer.parseInt(getHostPort()), getHostUser(), expandFolderLocation, expandedFilePattern)) {
                fileCheckFlag = false;
                loggerErrorMessage.append(String.format("Verification Failed, file with pattern %s is available in the Folder %s\n", expandedFilePattern, expandFolderLocation));
            } else {
                LOGGER.info("File with pattern [{}] is NOT available in the Folder [{}] as Expected", expandedFilePattern, expandFolderLocation);
            }
        }
        if (!fileCheckFlag) {
            LOGGER.error("{}", loggerErrorMessage);
            throw new CartException(CartExceptionType.VERIFICATION_FAILED, loggerErrorMessage.toString());
        }
    }

    public void removeFileIfExists(String destNamedHost, String folderLocation, List<String> fileList) {
        String expandFolderLocation = stateSvc.expandVar(folderLocation);
        this.configureHostDetails(destNamedHost);
        String cmdLine;
        LOGGER.debug("removeFileIfExists: port: [{}]", getHostPort());
        for (String file : fileList) {
            String expandedFileName = stateSvc.expandVar(file);
            if (runtimeRemoteSvc.sshFileExists(getHostName(), Integer.valueOf(getHostPort()), getHostUser(), expandFolderLocation + "/" + expandedFileName)) {
                cmdLine = "rm " + expandFolderLocation + "/" + expandedFileName;
                LOGGER.debug(CMD_TO_EXECUTE, cmdLine);
                runtimeRemoteSvc.sshRemoteExecute(getHostName(), Integer.valueOf(getHostPort()), getHostUser(), cmdLine);
            }
        }
    }

    public void removeFileIfPatternExists(String destNamedHost, String folderLocation, List<String> filePatternList) {
        String expandFolderLocation = stateSvc.expandVar(folderLocation);
        this.configureHostDetails(destNamedHost);
        String cmdLine;
        LOGGER.debug("removeFileIfExists: port: [{}]", getHostPort());
        for (String file : filePatternList) {
            String expandedFileName = stateSvc.expandVar(file);
            if (runtimeRemoteSvc.sshFileExistsWithRegEx(getHostName(), Integer.valueOf(getHostPort()), getHostUser(), expandFolderLocation, expandedFileName)) {
                cmdLine = "rm " + expandFolderLocation + "/" + expandedFileName;
                LOGGER.debug(CMD_TO_EXECUTE, cmdLine);
                runtimeRemoteSvc.sshRemoteExecute(getHostName(), Integer.valueOf(getHostPort()), getHostUser(), cmdLine);
            }
        }
    }

    public void renameFile(final String srcFile, final String dstFile, final String destNamedHost) {
        final String expandSrcFile = stateSvc.expandVar(srcFile);
        final String expandDstFile = stateSvc.expandVar(dstFile);
        this.configureHostDetails(destNamedHost);
        final String cmdLine = "mv " + expandSrcFile + " " + expandDstFile;
        LOGGER.debug(CMD_TO_EXECUTE, cmdLine);
        runtimeRemoteSvc.sshRemoteExecute(getHostName(), Integer.valueOf(getHostPort()), getHostUser(), cmdLine);
    }

    public void saveFileAs(final String srcFile, final String dstFile, final String destNamedHost) {
        final String expandSrcFile = stateSvc.expandVar(srcFile);
        final String expandDstFile = stateSvc.expandVar(dstFile);
        this.configureHostDetails(destNamedHost);
        final String cmdLine = "cp " + expandSrcFile + " " + expandDstFile;
        LOGGER.debug(CMD_TO_EXECUTE, cmdLine);
        runtimeRemoteSvc.sshRemoteExecute(getHostName(), Integer.valueOf(getHostPort()), getHostUser(), cmdLine);
    }

    public void validateUnixFormat(final String filename, final String destNamedHost) {
        final String expandFile = stateSvc.expandVar(filename);
        this.configureHostDetails(destNamedHost);
        final String cmdLine = "grep -U $'\015' " + expandFile + "|wc -l";
        LOGGER.debug(CMD_TO_EXECUTE, cmdLine);
        String output = runtimeRemoteSvc.sshRemoteExecute(getHostName(), Integer.valueOf(getHostPort()), getHostUser(), cmdLine).getOutput();
        LOGGER.debug("Cmd output [{}]", output);
        if (!output.trim().equals("0")) {
            LOGGER.error("File [{}] is not in Unix format", expandFile);
            throw new CartException(CartExceptionType.VERIFICATION_FAILED, "File [{}] is not in Unix format", expandFile);
        }
    }

    public void getLatestFileNameWithPattern(final String destNamedHost, final String filePath, final String pattern, final String var) {
        this.configureHostDetails(destNamedHost);
        String expandFilePath = stateSvc.expandVar(filePath);
        String expandFilePattern = stateSvc.expandVar(pattern);
        final String cmdLine = formatterUtil.format("cd %s;ls -r %s|sort -r|head -1", expandFilePath, expandFilePattern);
        LOGGER.debug(CMD_TO_EXECUTE, cmdLine);
        String output = runtimeRemoteSvc.sshRemoteExecute(getHostName(), Integer.valueOf(getHostPort()), getHostUser(), cmdLine).getOutput();
        LOGGER.debug("Cmd output [{}]", output.trim());
        stateSvc.setStringVar(var, output.trim());
    }

    public void ftpRemoteToLocalFolder(final String remoteFolder, final String ftpConfig, final String localFolder, final List<String> listToDownload, final String regExPattern) {
        Map<String, String> config = stateSvc.getValueMapFromPrefix(ftpConfig, true);
        String expandRemoteFolder = stateSvc.expandVar(remoteFolder);
        String expandLocalFolder = workspaceDirSvc.normalize(stateSvc.expandVar(localFolder));
        for (String item : listToDownload) {
            runtimeRemoteSvc.ftpDownload(config, expandRemoteFolder + "/" + item, expandLocalFolder + "/" + item, regExPattern);
        }
    }
}
