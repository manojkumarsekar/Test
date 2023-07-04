package com.eastspring.tom.cart.core.steps;

import com.eastspring.tom.cart.core.CartException;
import com.eastspring.tom.cart.core.CartExceptionType;
import com.eastspring.tom.cart.core.mdl.ColumnFilterPredicate;
import com.eastspring.tom.cart.core.mdl.ExcelToCsvParam;
import com.eastspring.tom.cart.core.mdl.HighlightedExcelRequest;
import com.eastspring.tom.cart.core.mdl.MatchTolerance;
import com.eastspring.tom.cart.core.svc.*;
import com.eastspring.tom.cart.core.utl.*;
import com.google.common.base.Strings;
import org.apache.poi.openxml4j.exceptions.InvalidFormatException;
import org.apache.poi.ss.usermodel.*;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;

import java.io.File;
import java.io.FileWriter;
import java.io.IOException;
import java.nio.file.DirectoryStream;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.util.*;


public class ReconciliationSteps {
    private static final Logger LOGGER = LoggerFactory.getLogger(ReconciliationSteps.class);

    @Autowired
    private CompressionSvc compressionSvc;

    @Autowired
    private CsvSvc csvSvc;

    @Autowired
    private CsvUtil csvUtil;

    @Autowired
    private DatabaseSvc databaseSvc;

    @Autowired
    private DateTimeUtil dateTimeUtil;

    @Autowired
    private ExcelFileSvc excelFileSvc;

    @Autowired
    private FileDirUtil fileDirUtil;

    @Autowired
    private FlywayUtil flywayUtil;

    @Autowired
    private FmTemplateSvc fmTemplateSvc;

    @Autowired
    private FileTransformSvc fileTransformSvc;

    @Autowired
    private JdbcSvc jdbcSvc;

    @Autowired
    private ReconciliationSvc reconciliationSvc;

    @Autowired
    private SqlStringUtil sqlStringUtil;

    @Autowired
    private StateSvc stateSvc;

    @Autowired
    private WorkspaceDirSvc workspaceDirSvc;

    @Autowired
    private WorkspaceUtil workspaceUtil;

    @Autowired
    private WriterUtil writerUtil;


    public void reconcileFiles(String sourceFile, String targetFile, String leftOnlyFilename, String rightOnlyFilename) {
        // probably no longer used anymore
        // TOM-2812 to remove reconcileFiles() in ReconciliationSteps.java
        reconciliationSvc.initNamedInMemoryDb();

        String baseDir = workspaceUtil.getBaseDir();
        String prefixedSourceFile = fileDirUtil.addPrefixIfNotAbsolute(sourceFile, baseDir);
        String prefixedTargetFile = fileDirUtil.addPrefixIfNotAbsolute(targetFile, baseDir);
        String prefixedLeftOnlyFile = fileDirUtil.addPrefixIfNotAbsolute(leftOnlyFilename, baseDir);
        String prefixedRightOnlyFile = fileDirUtil.addPrefixIfNotAbsolute(rightOnlyFilename, baseDir);

        if (!fileDirUtil.verifyFileExists(prefixedSourceFile)) {
            LOGGER.error("left hand side file [{}] does not exist", sourceFile);
            throw new CartException(CartExceptionType.UNSATISFIED_IMPLICIT_ASSUMPTION, "left hand side file [{}] does not exist", sourceFile);
        }
        if (!fileDirUtil.verifyFileExists(prefixedTargetFile)) {
            LOGGER.error("right hand side file [{}] does not exist", targetFile);
            throw new CartException(CartExceptionType.UNSATISFIED_IMPLICIT_ASSUMPTION, "right hand side file [{}] does not exist", targetFile);
        }

        reconciliationSvc.reconcile(ReconciliationSvc.INMEM_DB_NAME, prefixedSourceFile, prefixedTargetFile, prefixedLeftOnlyFile, prefixedRightOnlyFile);
    }


    public void generateDbReconcileSummaryReport(String reportFile, String templateLocation, String templateFile) {
        reconciliationSvc.generateDbReconcileSummaryReport(reportFile, templateLocation, templateFile);
    }

    public void exportMatchMismatchToCsvFile(String matchFileFullpath, String mismatchFileFullpath, String sourceSurplusFileFullpath, String targetSurplusFileFullpath, int fixedDigits) {
        reconciliationSvc.exportMatchMismatchToCsvFile(matchFileFullpath, mismatchFileFullpath, sourceSurplusFileFullpath, targetSurplusFileFullpath, fixedDigits);
    }

    public void generateMismatchExcelFileFromMismatchCsvFile(HighlightedExcelRequest request) {
        // used in:
        // - Performance and Attribution reconciliation (L1 Report)
        reconciliationSvc.generateXLSFromMismatchCSV(request);
    }

    /**
     * <p>This method sets the global match tolerance.</p>
     * <p>The global match tolerance will be used a the default tolerance whenever possible on all numeric reconciliation
     * unless there are column level overrides.</p>
     *
     * @param tolerance global (blanket) match tolerance
     */
    public void setGlobalNumericalMatchTolerance(String tolerance) {
        reconciliationSvc.setGlobalNumericalMatchTolerance(tolerance);
    }

    public void setGlobalNumericalMatchToleranceType(String toleranceType) {
        reconciliationSvc.setGlobalNumericalMatchToleranceType(MatchTolerance.valueOf(toleranceType));
    }

    public void captureCurrentTimestampIntoVar(String varName) {
        String timestamp = dateTimeUtil.getTimestamp();
        stateSvc.setStringVar(varName, timestamp);
    }

    public void convertExcelToCsv(ExcelToCsvParam param) {
        Set<Integer> skipCols = new HashSet<>(Arrays.asList(1));

        try (FileWriter fileWriter = new FileWriter(param.getDstFullpath())) {
            processSheet(param.getSheetName(), param.getSrcFullpath(), param.getColsLimit(), skipCols, fileWriter);
        } catch (IOException e) {
            LOGGER.error("IOException while converting Excel file [{}] to CSV file [{}]", param.getSrcFullpath(), param.getDstFullpath());
            throw new CartException(CartExceptionType.IO_ERROR, "IOException while converting Excel file [{}] to CSV file [{}]", param.getSrcFullpath(), param.getDstFullpath());
        }
    }

    public void processSheet(String sheetName, String srcFullpath, int colsLimit, Set<Integer> skipCols, FileWriter fileWriter) throws IOException {
        int skipRows = 13;
        int currMaxCols = 10;
        int cellRowNum = 0;
        try (Workbook workbook = WorkbookFactory.create(new File(srcFullpath))) {
            Sheet s = workbook.getSheet(sheetName);

            Row row;
            while (true) {
                row = s.getRow(skipRows + cellRowNum);
                if (row == null) break;
                currMaxCols = getCurrMaxCols(colsLimit, cellRowNum, currMaxCols, skipCols, fileWriter, row);
                cellRowNum++;
            }
        } catch (InvalidFormatException e) {
            LOGGER.error("invalid format of workbook in file [{}]", srcFullpath);
            throw new CartException(CartExceptionType.UNSATISFIED_IMPLICIT_ASSUMPTION, "invalid format of workbook in file [{}]", srcFullpath);
        }
    }

    public int getCurrMaxCols(int colsLimit, int cellRowNum, int currMaxCols, Set<Integer> skipCols, FileWriter fileWriter, Row row) throws IOException {
        Cell cell;
        if (cellRowNum == 0) {
            currMaxCols = Math.min(colsLimit, calculateMaxCols(fileWriter, row));
        } else {
            for (int cellColNum = 0; cellColNum < currMaxCols; cellColNum++) {
                cell = row.getCell(cellColNum);
                if (skipCols.contains(cellColNum) && cell == null) break;
                excelFileSvc.writeCellToFileWriter(fileWriter, cell, cellColNum == currMaxCols - 1 ? "\n" : ",", cellRowNum, cellColNum);
            }
        }
        return currMaxCols;
    }

    public int calculateMaxCols(FileWriter fileWriter, Row row) throws IOException {
        int maxCols;
        Cell cell;
        maxCols = 0;
        while (true) {
            cell = row.getCell(maxCols);
            if (cell == null) break;
            maxCols++;
        }
        for (int i = 0; i < maxCols; i++) {
            cell = row.getCell(i);
            excelFileSvc.writeCellToFileWriter(fileWriter, cell, i == maxCols - 1 ? "\n" : ",", 0, i);
        }
        return maxCols;
    }


    /**
     * <p>This method filters files on the given base folder and return a list of {@link File} objects that
     * matches the signature. The signature may contain the asterisk wildcard (*).</p>
     *
     * @param baseDir   base folder
     * @param signature signature string, example "*JAN 2015*"
     * @return List of {@link String} filename whose name matches the given signature and is in the base folder
     */
    public List<String> filterFilesContainSignature(String baseDir, String signature) {
        Path dir = Paths.get(baseDir);
        List<String> files = new ArrayList<>();
        try (DirectoryStream<Path> stream = Files.newDirectoryStream(dir, signature)) {
            for (Path entry : stream) {
                files.add(fileDirUtil.normalizePathToUnix(entry.toString()));
            }
        } catch (IOException e) {
            LOGGER.error("failed while filtering by signature", e);
            throw new CartException(CartExceptionType.UNSATISFIED_IMPLICIT_ASSUMPTION, "failed while filtering by signature");
        }

        return files;
    }

    public String getCsvFromKDriveZip(String kDriveSrc, String zipFilePattern, String unzippedDir, String csvDestDir) {
        List<String> filePaths = filterFilesContainSignature(kDriveSrc, zipFilePattern);
        String excelFilename = compressionSvc.unzipSingleFile(filePaths.get(0), unzippedDir);
        String csvFileFullpath = fileDirUtil.normalizePath(csvDestDir + '/' + fileDirUtil.getFilenameFromPath(excelFilename).replaceAll(".xls", ".csv"));

        ExcelToCsvParam param = new ExcelToCsvParam();
        param.setSheetName("All Funds");
        param.setSrcFullpath(excelFilename);
        param.setDstFullpath(csvFileFullpath);
        param.setColsLimit(75);
        convertExcelToCsv(param);
        return csvFileFullpath;
    }


    public void loadCsvToReconDb(String srcDir, String filename, String tableName, String encoding, char separator, ColumnFilterPredicate columnFilterPredicate) {
        LOGGER.debug("srcDir: [{}]", srcDir);
        LOGGER.debug("filename: [{}]", filename);
        reconciliationSvc.loadCsvToReconDb(srcDir, filename, tableName, encoding, separator, columnFilterPredicate);
    }


    /**
     * <p>This method implements the capability to convert CSV column that is in a date format.</p>
     *
     * @param srcFile       source file
     * @param colNames      column names, comma separated
     * @param sourcePattern pattern for the source
     * @param targetPattern pattern for the target
     * @param dstFile       destination file
     */
    public void convertCsvColsDateFormat(String srcFile, String colNames, String sourcePattern, String targetPattern, String dstFile) {
        List<String> colsToConvert = Arrays.asList(colNames.split(","));
        String normalizedSrcFile = workspaceDirSvc.normalize(srcFile);
        String normalizedDstFile = workspaceDirSvc.normalize(dstFile);
        fileDirUtil.forceMkdir(fileDirUtil.getDirnameFromPath(normalizedDstFile));
        csvSvc.convertCsvColsDateFormat(normalizedSrcFile, colsToConvert, sourcePattern, targetPattern, normalizedDstFile);
    }

    /**
     * <p>This method implements the capability to convert CSV column that is in a date format.</p>
     *
     * @param srcFile      source file
     * @param colNames     column names, comma separated
     * @param decimalPoint number of decimal point
     * @param dstFile      destination file
     */
    public void convertCsvColsNumPrecision(String srcFile, String colNames, int decimalPoint, String dstFile) {
        List<String> colsToConvert = Arrays.asList(colNames.split(","));
        String normalizedSrcFile = workspaceDirSvc.normalize(srcFile);
        String normalizedDstFile = workspaceDirSvc.normalize(dstFile);
        fileDirUtil.forceMkdir(fileDirUtil.getDirnameFromPath(normalizedDstFile));
        csvSvc.convertColsNumPrecision(normalizedSrcFile, colsToConvert, decimalPoint, normalizedDstFile);
    }

    public void removePostfixFromCols(String postfixToRemove, String srcFile, String colNames, String dstFile) {
        List<String> colsToConvert = Arrays.asList(colNames.split(","));
        String normalizedSrcFile = workspaceDirSvc.normalize(srcFile);
        String normalizedDstFile = workspaceDirSvc.normalize(dstFile);
        fileDirUtil.forceMkdir(fileDirUtil.getDirnameFromPath(normalizedDstFile));
        csvSvc.removePostfixFromCols(postfixToRemove, normalizedSrcFile, colsToConvert, normalizedDstFile);
    }

    public void prepareDbReconciliationEngine() {
        reconciliationSvc.prepareDbReconciliationEngine();
    }


    /**
     * Perform reconciliation.
     * Stored ComparisonRequestId value into variable
     *
     * @param params the params
     */
    public void performReconciliation(final Map<String, String> params) {
        reconciliationSvc.reconcile(databaseSvc.getCurrentConfigPrefix(), params);
    }

    public void validateReconciliation() {
        String comparisonRequestId = stateSvc.getStringVar("ComparisonRequestId");
        if (Strings.isNullOrEmpty(comparisonRequestId)) {
            LOGGER.error("ComparisonRequestId is not captured during Recon process");
            throw new CartException(CartExceptionType.INCOMPLETE_PARAMS, "ComparisonRequestId is not captured during Recon process");
        }
        LOGGER.debug("Fetching ComparisonRequestId [{}] record", comparisonRequestId);
        reconciliationSvc.validateReconciliations(databaseSvc.getCurrentConfigPrefix(), Integer.valueOf(comparisonRequestId));
    }

}
