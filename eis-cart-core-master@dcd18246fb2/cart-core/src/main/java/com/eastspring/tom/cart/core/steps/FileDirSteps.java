package com.eastspring.tom.cart.core.steps;

import com.eastspring.tom.cart.core.svc.FileDirSvc;
import com.eastspring.tom.cart.core.svc.StateSvc;
import com.eastspring.tom.cart.core.svc.WorkspaceDirSvc;
import com.eastspring.tom.cart.core.utl.FileDirUtil;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;

public class FileDirSteps {

    private static final Logger LOGGER = LoggerFactory.getLogger(FileDirSteps.class);

    @Autowired
    private FileDirSvc fileDirSvc;

    @Autowired
    private StateSvc stateSvc;

    @Autowired
    private WorkspaceDirSvc workspaceDirSvc;

    @Autowired
    private FileDirUtil fileDirUtil;


    public void verifyFileExists(String filename) {
        final String expandFileName = stateSvc.expandVar(filename);
        fileDirSvc.verifyFileExists(workspaceDirSvc.normalize(expandFileName));
    }

    public void verifyFileSizeNonZero(String filename) {
        final String expandFileName = stateSvc.expandVar(filename);
        fileDirSvc.verifyFileSizeNonZero(workspaceDirSvc.normalize(expandFileName));
    }

    public void createFolderIfNotExist(String folder) {
        fileDirSvc.forceMakeDirs(folder);
    }

    public void verifyNoOfRecordsInFile(final String filename, final Integer recordCnt) {
        final String expandFilename = workspaceDirSvc.normalize(stateSvc.expandVar(filename));
        final String expandCount = stateSvc.expandVar(String.valueOf(recordCnt));
        fileDirSvc.verifyFileRecordCount(expandFilename, Long.parseLong(expandCount));
    }

    public void renameFile(final String srcFile, final String dstFile) {
        final String expandSrcFile = workspaceDirSvc.normalize(stateSvc.expandVar(srcFile));
        final String expandDstFile = workspaceDirSvc.normalize(stateSvc.expandVar(dstFile));
        fileDirSvc.rename(expandSrcFile, expandDstFile);
    }

    public void saveAs(final String srcFile, final String dstFile) {
        final String expandSrcFile = workspaceDirSvc.normalize(stateSvc.expandVar(srcFile));
        final String expandDstFile = workspaceDirSvc.normalize(stateSvc.expandVar(dstFile));
        fileDirSvc.saveAs(expandSrcFile, expandDstFile);
    }

    public void copyLatestFileWithPattern(final String srcPath, final String filePattern, final String dstFilePath, final String fileNameVariable) {
        final String expandSrcFilePath = workspaceDirSvc.normalize(stateSvc.expandVar(srcPath));
        final String expandDstFilePath = workspaceDirSvc.normalize(stateSvc.expandVar(dstFilePath));
        final String expandPattern = stateSvc.expandVar(filePattern);
        String dstFileName = fileDirUtil.copyLatestFileWithPattern(expandSrcFilePath, expandPattern, expandDstFilePath);
        stateSvc.setStringVar(fileNameVariable, dstFileName);
    }

    //TODO - will raise separate ticket to replace this with encodingUtility function
    public void convertEncoding(final String filepath, final String srcEncoding, final String targetEncoding) {
        final String expandFilepath = workspaceDirSvc.normalize(stateSvc.expandVar(filepath));
        final String expandSrcEncoding = stateSvc.expandVar(srcEncoding);
        final String expandTargetEncoding = stateSvc.expandVar(targetEncoding);

        final String outFile = fileDirUtil.convertFileEncoding(expandFilepath, expandSrcEncoding, expandTargetEncoding);
        LOGGER.debug("File [{}] created with [{}] encoding", outFile, targetEncoding);
    }

}
