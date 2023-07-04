package com.eastspring.tom.cart.dmp.utl;

import com.eastspring.tom.cart.core.CartException;
import com.eastspring.tom.cart.core.CartExceptionType;
import com.eastspring.tom.cart.core.svc.StateSvc;
import com.eastspring.tom.cart.core.svc.WorkspaceDirSvc;
import com.eastspring.tom.cart.core.utl.DateTimeUtil;
import com.eastspring.tom.cart.core.utl.FileDirUtil;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;

import java.io.File;
import java.util.ArrayList;
import java.util.List;

public class ReconFileHandler {

    private static final Logger LOGGER = LoggerFactory.getLogger(ReconFileHandler.class);

    private static final String FILE_NOT_AVAILABLE = "File [{}] not available or the available file is blank";

    @Autowired
    private WorkspaceDirSvc workspaceDirSvc;

    @Autowired
    private StateSvc stateSvc;

    @Autowired
    private FileDirUtil fileDirUtil;

    @Autowired
    private DateTimeUtil dateTimeUtil;

    @Autowired
    private DmpFileHandlingUtl dmpFileHandlingUtl;

    private static final String AUTO_CREATE = "AUTO_CREATE";

    private String sourceFile;
    private String targetFile;
    private String exceptionsFile;
    private List<String> excludedColumns = new ArrayList<>();
    private List<Integer> excludedColumnsIndices = new ArrayList<>();

    ReconFileHandler() {
    }

    public ReconFileHandler setFiles(final String sourceFile, final String targetFile, final String exceptionsFile) {
        this.sourceFile = sourceFile;
        this.targetFile = targetFile;
        this.exceptionsFile = exceptionsFile;
        return this;
    }

    public ReconFileHandler setFiles(final String sourceFile, final String targetFile) {
        this.sourceFile = sourceFile;
        this.targetFile = targetFile;
        this.exceptionsFile = AUTO_CREATE;
        return this;
    }

    private void verifyReconFileAvailable(final String fileAbsolutePath) {
        if (!fileDirUtil.verifyFileExists(fileAbsolutePath) || !this.fileIsNotEmpty(fileAbsolutePath)) {
            LOGGER.error(FILE_NOT_AVAILABLE, fileAbsolutePath);
            throw new CartException(CartExceptionType.IO_ERROR, FILE_NOT_AVAILABLE, fileAbsolutePath);
        }
    }

    public String resolveSourceFile() {
        final String filePath = workspaceDirSvc.normalize(stateSvc.expandVar(sourceFile));
        this.verifyReconFileAvailable(filePath);
        return filePath;
    }

    public String resolveTargetFile() {
        final String filePath = workspaceDirSvc.normalize(stateSvc.expandVar(targetFile));
        this.verifyReconFileAvailable(filePath);
        return filePath;
    }

    public String resolveExceptionFile() {
        if (exceptionsFile.equals(AUTO_CREATE)) {
            return fileDirUtil.getDirnameFromPath(resolveTargetFile()) + "/exceptions_" + dateTimeUtil.getTimestamp();
        }
        return workspaceDirSvc.normalize(stateSvc.expandVar(exceptionsFile));
    }

    public void setExcludedColumns(final List<String> excludedColumns) {
        this.excludedColumns = excludedColumns;
    }

    public void setExcludedColumnsIndices(final List<Integer> excludedColumnsIndices) {
        this.excludedColumnsIndices = excludedColumnsIndices;
    }

    public String[] generateFilesRemovingColumns(final String... filePaths) {
        if (this.excludedColumns.isEmpty() && this.excludedColumnsIndices.isEmpty()) {
            return filePaths;
        }

        try {
            return excludedColumns.isEmpty()
                    ? dmpFileHandlingUtl.getFilesExcludingColumns(this.excludedColumnsIndices, filePaths)
                    : dmpFileHandlingUtl.getFilesExcludingColumns(this.excludedColumns, filePaths);
        } finally {
            setExcludedColumns(new ArrayList<>());
            setExcludedColumnsIndices(new ArrayList<>());
        }


    }

    private boolean fileIsNotEmpty(String filePath){
        File file = new File(filePath);
        return file.length()>0;
    }


}
