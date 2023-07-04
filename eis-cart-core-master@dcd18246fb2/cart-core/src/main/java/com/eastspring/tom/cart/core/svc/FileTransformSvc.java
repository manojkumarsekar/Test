package com.eastspring.tom.cart.core.svc;

import com.codesnippets4all.json.parsers.JSONParser;
import com.codesnippets4all.json.parsers.JsonParserFactory;
import com.eastspring.tom.cart.core.CartException;
import com.eastspring.tom.cart.core.CartExceptionType;
import com.eastspring.tom.cart.core.mdl.CsvFileSpec;
import com.eastspring.tom.cart.core.mdl.FileTransformation;
import com.eastspring.tom.cart.core.utl.CsvUtil;
import com.eastspring.tom.cart.core.utl.FileDirUtil;
import com.eastspring.tom.cart.cst.EncodingConstants;
import com.opencsv.CSVReader;
import com.opencsv.CSVWriter;
import org.apache.commons.beanutils.BeanUtils;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;

import java.io.IOException;
import java.io.UnsupportedEncodingException;
import java.nio.file.Files;
import java.nio.file.Paths;
import java.util.*;
import java.util.function.BiFunction;

public class FileTransformSvc {
    public static final String TRIM_COLS = "trim-cols";
    private static final Logger LOGGER = LoggerFactory.getLogger(FileTransformSvc.class);
    public static final String CONVERT_ENCODING = "convert-encoding";
    public static final String CONVERT_DELIMITER = "convert-delimiter";
    public static final String OMIT_INITIAL_LINES = "omit-initial-lines";
    public static final String STRIP_CHAR_FROM_COLS = "strip-char-from-cols";
    public static final String FAILED_WHILE_PERFORMING_FILE_TRANSFORMATION = "failed while performing file transformation";
    public static final String ENCODING_NOT_SUPPORTED_WHILE_PROCESSING_CSV_FILE = "encoding not supported while processing CSV file [{}]";
    public static final String IO_ERROR_WHILE_READING_CSV_FILE = "IO error while reading CSV file [{}]";
    public static final String COLUMN_TO_NORMALIZE_NAME_LIST_MUST_NOT_BE_NULL = "column to normalize name list must not be null";

    @Autowired
    private CsvUtil csvUtil;

    @Autowired
    private FileDirUtil fileDirUtil;

    @Autowired
    private FileDirSvc fileDirSvc;

    @Autowired
    private StringFunctionSvc stringFunctionSvc;

    private Set<String> validIds;

    private Map configMap;

    public FileTransformSvc() {
        validIds = new HashSet<>();
        validIds.add(CONVERT_ENCODING);
        validIds.add(CONVERT_DELIMITER);
        validIds.add(OMIT_INITIAL_LINES);
        validIds.add(STRIP_CHAR_FROM_COLS);
        validIds.add(TRIM_COLS);
    }

    public Map readJsonConfigAsMap(String configFullpath) {
        JsonParserFactory factory = JsonParserFactory.getInstance();
        JSONParser parser = factory.newJsonParser();
        configMap = parser.parseJson(fileDirUtil.readFileToString(configFullpath));
        return configMap;
    }

    public List<FileTransformation> getTransformations() {
        List<FileTransformation> result = new ArrayList<>();
        List transformationMaps = (List) ((Map) configMap.get("source")).get("transformations");
        try {
            for (Object transformationObj : transformationMaps) {
                Map map = (Map) transformationObj;
                FileTransformation ft = new FileTransformation();
                BeanUtils.populate(ft, map);
                result.add(ft);
            }
        } catch (Exception e) {
            LOGGER.error(FAILED_WHILE_PERFORMING_FILE_TRANSFORMATION);
            throw new CartException(CartExceptionType.PROCESSING_FAILED, FAILED_WHILE_PERFORMING_FILE_TRANSFORMATION);
        }

        return result;
    }

    public void transform(FileTransformation ft) {
        if (ft == null) {
            LOGGER.error("file transformation must not be null");
            throw new CartException(CartExceptionType.UNSATISFIED_IMPLICIT_ASSUMPTION, "transformation must not be null");
        }
        String transformId = ft.getId();
        if (transformId == null) {
            LOGGER.error("file transformation id must not be null");
            throw new CartException(CartExceptionType.UNSATISFIED_IMPLICIT_ASSUMPTION, "transformation id must not be null");
        }
        if (!validIds.contains(transformId)) {
            LOGGER.error("unknown transformation id [{}]", transformId);
            throw new CartException(CartExceptionType.UNSATISFIED_IMPLICIT_ASSUMPTION, "unknown transformation id [{}]", transformId);
        }

        if (CONVERT_ENCODING.equals(transformId)) {
            fileDirSvc.copyWithEncodingConversion(ft.getSrcFile(), ft.getDstFile(), ft.getFrom(), ft.getTo());
        } else if (CONVERT_DELIMITER.equals(transformId)) {
            fileDirSvc.copyWithDelimiterConversion(ft.getSrcFile(), ft.getDstFile(), ft.getFrom(), ft.getTo());
        }
    }

    public void csvTransformColsByNamesDefault(List<String> colsToNormalize, String srcFile, String dstFile, BiFunction<String, Integer, String> lambda) {
        CsvFileSpec sourceCsvFileSpec = new CsvFileSpec(srcFile, EncodingConstants.UTF_8, CSVWriter.DEFAULT_SEPARATOR);
        CsvFileSpec targetCsvFileSpec = new CsvFileSpec(dstFile, EncodingConstants.UTF_8, CSVWriter.DEFAULT_SEPARATOR);
        csvTransformColsByNames(colsToNormalize, null, null, sourceCsvFileSpec, targetCsvFileSpec, lambda);
    }

    public void csvTransformColsByNames(List<String> colsToNormalize, List<String> colsToRemove, List<String> headerReplacement, CsvFileSpec sourceCsvFileSpec, CsvFileSpec targetCsvFileSpec, BiFunction<String, Integer, String> lambda) {
        if (colsToNormalize == null) {
            LOGGER.error(COLUMN_TO_NORMALIZE_NAME_LIST_MUST_NOT_BE_NULL);
            throw new CartException(CartExceptionType.INVALID_INVOCATION_PARAMS, COLUMN_TO_NORMALIZE_NAME_LIST_MUST_NOT_BE_NULL);
        }

        List<String> allColsNames = csvUtil.getCsvHeaderNamesAsList(sourceCsvFileSpec);


        int allColsCount = allColsNames.size();
        Set<Integer> colsToRemoveIdxSet = getColsToRemoveIdx(colsToRemove, allColsNames);
        List<Integer> colToNormalizeIndices = getColsToNormalizeSet(colsToNormalize, allColsNames, allColsCount);
        int colsToWriteCount = allColsCount - colsToRemoveIdxSet.size();

        long rowNum = 0;
        String[] csvRowSource;
        String[] csvRowToWrite;
        try (CSVReader reader = csvUtil.getCSVReader(sourceCsvFileSpec)) {
            try (CSVWriter writer = csvUtil.getCSVWriter(targetCsvFileSpec)) {
                boolean firstRow = true;
                while ((csvRowSource = reader.readNext()) != null) {
                    LOGGER.debug("  processing row#: {}", rowNum);
                    firstRow = isFirstRow(headerReplacement, lambda, colToNormalizeIndices, csvRowSource, firstRow);
                    csvRowToWrite = new String[colsToWriteCount];
                    int j = 0;
                    for(int i = 0; i < csvRowSource.length; i++) {
                        if(!colsToRemoveIdxSet.contains(i)) {
                            csvRowToWrite[j] = csvRowSource[i];
                            j++;
                        }
                    }
                    writer.writeNext(csvRowToWrite);
                    rowNum++;
                }
            }
        } catch (UnsupportedEncodingException e) {
            LOGGER.error("encoding not supported while processing CSV file [{}] at line #{}", sourceCsvFileSpec.getFilename(), rowNum + 1);
            throw new CartException(CartExceptionType.UNSATISFIED_IMPLICIT_ASSUMPTION, ENCODING_NOT_SUPPORTED_WHILE_PROCESSING_CSV_FILE, sourceCsvFileSpec.getFilename());
        } catch (IOException e) {
            LOGGER.error(IO_ERROR_WHILE_READING_CSV_FILE, sourceCsvFileSpec.getFilename());
            throw new CartException(CartExceptionType.IO_ERROR, IO_ERROR_WHILE_READING_CSV_FILE, sourceCsvFileSpec.getFilename());
        }
    }

    private boolean isFirstRow(List<String> headerReplacement, BiFunction<String, Integer, String> lambda, List<Integer> colToNormalizeIndices, String[] csvRowSource, boolean firstRow) {
        if (!firstRow) {
            for (Integer colToNormalizeIdx : colToNormalizeIndices) {
                csvRowSource[colToNormalizeIdx] = lambda.apply(csvRowSource[colToNormalizeIdx], colToNormalizeIdx);
            }
        } else {
            if (headerReplacement != null) {
                int csvRowLen = csvRowSource.length;
                for (int i = 0; i < csvRowLen; i++) {
                    csvRowSource[i] = headerReplacement.get(i);
                }
            }
            firstRow = false;
        }
        return firstRow;
    }

    public List<Integer> getColsToNormalizeSet(List<String> colsToNormalize, List<String> allColsNames, int allColsCount) {
        Set<String> colsToNormalizeSet = new HashSet<>(colsToNormalize);
        List<Integer> colToNormalizeIndices = new ArrayList<>();
        for (int i = 0; i < allColsCount; i++) {
            if (colsToNormalizeSet.contains(allColsNames.get(i))) {
                colToNormalizeIndices.add(i);
            }
        }
        return colToNormalizeIndices;
    }

    public Set<Integer> getColsToRemoveIdx(List<String> colsToRemove, List<String> allColsNames) {
        Set<Integer> colsToRemoveIdx = new HashSet<>();
        if(colsToRemove != null) {
            for(int i = 0; i < allColsNames.size(); i++) {
                String colName = allColsNames.get(i);
                if(colsToRemove.contains(colName)) {
                    colsToRemoveIdx.add(i);
                }
            }
        }

        return colsToRemoveIdx;
    }

    private CSVWriter getCSVWriter(String dstFile) throws IOException {
        return new CSVWriter(Files.newBufferedWriter(Paths.get(dstFile)), CSVWriter.DEFAULT_SEPARATOR, CSVWriter.DEFAULT_QUOTE_CHARACTER, CSVWriter.DEFAULT_ESCAPE_CHARACTER, CSVWriter.DEFAULT_LINE_END);
    }

    public void csvTransformRemoveColsByNames(List<String> colsToBeRemovedNames, String srcFile, String dstFile) {
        if (colsToBeRemovedNames == null) {
            LOGGER.error("column name list must not be null");
            throw new CartException(CartExceptionType.INVALID_INVOCATION_PARAMS, "column name list must not be null");
        }

        Set<String> colsToBeRemovedNamesSet = new HashSet<>(colsToBeRemovedNames);

        CsvFileSpec csvFileSpec = new CsvFileSpec(srcFile, EncodingConstants.UTF_8, CSVWriter.DEFAULT_SEPARATOR);
        List<String> allColsNames = csvUtil.getCsvHeaderNamesAsList(csvFileSpec);
        int allColsCount = allColsNames.size();

        List<Integer> colToRetainIndices = getColToRetainIndicesAsList(allColsNames, colsToBeRemovedNamesSet, allColsCount);
        csvTransformRetainColsByIndices(colToRetainIndices, srcFile, dstFile);
    }

    private List<Integer> getColToRetainIndicesAsList(List<String> allColsNames, Set<String> colsToBeRemovedNamesSet, int allColsCount) {
        List<Integer> colToRetainIndices = new ArrayList<>();
        for (int i = 0; i < allColsCount; i++) {
            if (!colsToBeRemovedNamesSet.contains(allColsNames.get(i))) {
                colToRetainIndices.add(i);
            }
        }
        return colToRetainIndices;
    }

    public void csvTransformRetainColsByIndices(List<Integer> colsToRetainIndices, String srcFile, String dstFile) {
        int colsToRetainCount = colsToRetainIndices.size();
        CsvFileSpec csvFileSpec = new CsvFileSpec(srcFile, EncodingConstants.UTF_8, CSVWriter.DEFAULT_SEPARATOR);
        try (CSVReader reader = csvUtil.getCSVReader(csvFileSpec)) {
            String[] nextLine;

            try (CSVWriter writer = getCSVWriter(dstFile)) {
                while ((nextLine = reader.readNext()) != null) {
                    String[] toBeWritten = new String[colsToRetainCount];
                    for (int i = 0; i < colsToRetainCount; i++) {
                        toBeWritten[i] = nextLine[colsToRetainIndices.get(i)];
                    }
                    if(LOGGER.isDebugEnabled()) {
                        LOGGER.debug("toBeWritten: {}", Objects.toString(Arrays.asList(toBeWritten)));
                    }
                    writer.writeNext(toBeWritten);
                }
            }
        } catch (UnsupportedEncodingException e) {
            LOGGER.error(ENCODING_NOT_SUPPORTED_WHILE_PROCESSING_CSV_FILE, csvFileSpec.getFilename());
            throw new CartException(CartExceptionType.UNSATISFIED_IMPLICIT_ASSUMPTION, ENCODING_NOT_SUPPORTED_WHILE_PROCESSING_CSV_FILE, csvFileSpec.getFilename());
        } catch (IOException e) {
            LOGGER.error(IO_ERROR_WHILE_READING_CSV_FILE, csvFileSpec.getFilename());
            throw new CartException(CartExceptionType.IO_ERROR, IO_ERROR_WHILE_READING_CSV_FILE, csvFileSpec.getFilename());
        }
    }
}
