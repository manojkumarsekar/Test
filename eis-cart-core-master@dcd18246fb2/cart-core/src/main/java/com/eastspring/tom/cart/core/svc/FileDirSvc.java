package com.eastspring.tom.cart.core.svc;

import com.eastspring.tom.cart.core.CartException;
import com.eastspring.tom.cart.core.CartExceptionType;
import com.eastspring.tom.cart.core.utl.EncodingUtil;
import com.eastspring.tom.cart.core.utl.FileDirUtil;
import com.eastspring.tom.cart.core.utl.WorkspaceUtil;
import org.apache.commons.io.FileUtils;
import org.apache.commons.lang3.builder.ToStringBuilder;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;

import java.io.File;
import java.io.IOException;

/**
 * @author Daniel Baktiar
 * @since 2017-09
 */
public class FileDirSvc {
    private static final Logger LOGGER = LoggerFactory.getLogger(FileDirSvc.class);
    public static final String FAILED_TO_MOVE_FILE = "failed to move file";
    public static final String FILE_DOES_NOT_EXIST = "file [{}] does not exist";
    public static final String SIZE_OF_FILE_IS_ZERO_EXPECTED_NON_ZERO = "size of file [{}] is zero, expected non-zero";
    public static final String NO_OF_RECORDS_IN_FILE_ARE_EXPECTED_ARE = "No. of records in file are [{}], expected are [{}]";

    @Autowired
    private EncodingUtil encodingUtil;

    @Autowired
    private FileDirUtil fileDirUtil;

    @Autowired
    private StateSvc stateSvc;

    @Autowired
    private WorkspaceUtil workspaceUtil;

    public String createTestEvidenceSubDir(String subDir) {
        String separator = subDir.startsWith("/") || subDir.startsWith("\\") ? "" : "/";
        String evidenceDir = workspaceUtil.getTestEvidenceDir() + separator + subDir;
        LOGGER.debug("createTestEvidenceSubDir: creating folder [{}]", evidenceDir);
        fileDirUtil.forceMkdir(evidenceDir);

        return evidenceDir;
    }


    public void verifyFileExists(String filename) {
        File file = new File(filename);
        if (!file.exists()) {
            LOGGER.error(FILE_DOES_NOT_EXIST, filename);
            throw new CartException(CartExceptionType.VERIFICATION_FAILED, FILE_DOES_NOT_EXIST, filename);
        }
    }

    public void verifyFileRecordCount(final String filename, final long expectedCount) {
        final long rowsCountInFile = fileDirUtil.getRowsCountInFile(filename);
        if (rowsCountInFile != expectedCount) {
            LOGGER.error(NO_OF_RECORDS_IN_FILE_ARE_EXPECTED_ARE, rowsCountInFile, expectedCount);
            throw new CartException(CartExceptionType.VERIFICATION_FAILED, NO_OF_RECORDS_IN_FILE_ARE_EXPECTED_ARE, rowsCountInFile, expectedCount);
        }
    }

    public void verifyFileSizeNonZero(String filename) {
        File file = new File(filename);
        if (!file.exists()) {
            LOGGER.error(FILE_DOES_NOT_EXIST, filename);
            throw new CartException(CartExceptionType.UNSATISFIED_IMPLICIT_ASSUMPTION, FILE_DOES_NOT_EXIST, filename);
        }
        if (file.length() == 0) {
            LOGGER.error(SIZE_OF_FILE_IS_ZERO_EXPECTED_NON_ZERO, filename);
            throw new CartException(CartExceptionType.VERIFICATION_FAILED, SIZE_OF_FILE_IS_ZERO_EXPECTED_NON_ZERO, filename);
        }
    }

    public static class FileDir {
        private String dir;
        private String file;

        public FileDir(String dir, String file) {
            this.dir = dir;
            this.file = file;
        }

        public String getDir() {
            return dir;
        }

        public String getFile() {
            return file;
        }

        public String toString() {
            return ToStringBuilder.reflectionToString(this);
        }
    }

    public FileDir decomposePath(String inputPath) {
        String normalized = inputPath.replaceAll("\\\\", "/");
        int lastIndexOfSlash = normalized.lastIndexOf('/');
        FileDir result;
        String baseDir = workspaceUtil.getBaseDir();
        if (lastIndexOfSlash < 0) {
            result = new FileDir(baseDir + "/", inputPath);
        } else {
            result = new FileDir(baseDir + "/" + normalized.substring(0, lastIndexOfSlash) + "/", normalized.substring(lastIndexOfSlash + 1));
        }
        LOGGER.debug("result: [{}]", result);
        return result;
    }


    public void moveFileToDir(String srcFile, String destDir) {
        try {
            FileUtils.moveFileToDirectory(new File(srcFile), new File(destDir), true);
        } catch (IOException e) {
            LOGGER.error(FAILED_TO_MOVE_FILE, e);
            throw new CartException(CartExceptionType.PROCESSING_FAILED, FAILED_TO_MOVE_FILE);
        }
    }

    public void rename(String src, String dst) {
        fileDirUtil.move(src, dst);
    }

    public void saveAs(String src, String dst) {
        fileDirUtil.copyFile(src, dst);
    }

    public void forceDelete(String filename) {
        fileDirUtil.forceDelete(filename);
    }

    public void forceMakeDirs(String dir) {
        fileDirUtil.forceMakeDirs(dir);
    }

    public void copyWithEncodingConversion(String srcFullpath, String dstFullpath, String srcEncoding, String dstEncoding) {
        encodingUtil.copyWithEncodingConversion(srcFullpath, dstFullpath, srcEncoding, dstEncoding);
    }

    /**
     * This is very ignorant and naive method to convert CSV file delimiters, ignoring the escaping.
     * make a not-so-ignorant version of this conversion
     *
     * @param srcFullpath
     * @param dstFullpath
     * @param delimiterFrom
     * @param delimiterTo
     */
    // TOM-2815 to revisit copyWithDelimiterConversion()
    public void copyWithDelimiterConversion(String srcFullpath, String dstFullpath, String delimiterFrom, String delimiterTo) {

        String fileContent = fileDirUtil.readFileToString(srcFullpath);
        fileDirUtil.writeStringToFile(dstFullpath, fileContent.replaceAll(delimiterFrom, delimiterTo));
    }
}
