package com.eastspring.qa.cart.core.utils.testData;

import com.eastspring.qa.cart.core.exceptions.CartException;
import com.eastspring.qa.cart.core.exceptions.CartExceptionType;
import com.eastspring.qa.cart.core.utils.file.FileDirUtil;
import org.apache.commons.csv.CSVRecord;
import com.eastspring.qa.cart.core.utils.core.WorkspaceUtil;
import com.eastspring.qa.cart.core.utils.file.CsvUtil;
import com.eastspring.qa.cart.core.utils.file.ExcelUtil;

import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;
import java.util.stream.Collectors;


public class TestDataFileUtil {

    public static List<Map<String, String>> getCSVAsMap(String fileName) {
        return getCSVRecords(fileName, true).stream()
                .map(CSVRecord::toMap)
                .collect(Collectors.toList());
    }

    public static List<String> getCSVAsString(String testDataFileName) {
        return CsvUtil.getRecordsAsStringList(getTestDataFilePath(testDataFileName), false);
    }

    public static List<String> getCSVRecordsAsString(String testDataFileName, boolean isFirstRecordAHeader) {
        return CsvUtil.getRecordsAsStringList(getTestDataFilePath(testDataFileName), isFirstRecordAHeader);
    }

    public static List<CSVRecord> getCSVRecords(String testDataFileName, boolean isFirstRecordAHeader) {
        return CsvUtil.getRecords(getTestDataFilePath(testDataFileName), isFirstRecordAHeader);
    }

    public static List<String> getExcelAsString(String testDataFileName, String sheetName, String delimiter) {
        return ExcelUtil.getRecordsAsStringList(getTestDataFilePath(testDataFileName), sheetName, delimiter);
    }

    public static List<LinkedHashMap<String, String>> getExcelAsMap(String testDataFileName, String sheetName) {
        return ExcelUtil.getRecordsAsStringMap(getTestDataFilePath(testDataFileName), sheetName);
    }

    public static List<String> getCsvHeaderNamesAsList(String testDataFileName) {
        return CsvUtil.getHeaders(getTestDataFilePath(testDataFileName));
    }

    public static String readFileAsString(String testDataFileName) {
        return FileDirUtil.readFileToString(getTestDataFilePath(testDataFileName).toString());
    }

    public static Path getTestDataFilePath(String fileName) {
        String envFileDir = WorkspaceUtil.getTestDataDir();
        String commonFileDir = WorkspaceUtil.getCommonTestDataDir();

        if (Files.exists(Paths.get(envFileDir, fileName))) {
            return Paths.get(envFileDir, fileName);
        } else if (Files.exists(Paths.get(commonFileDir, fileName))) {
            return Paths.get(commonFileDir, fileName);
        } else {
            throw new CartException(CartExceptionType.IO_ERROR,
                    " File [{}] not found in common and env test data directories",
                    fileName);
        }
    }

}