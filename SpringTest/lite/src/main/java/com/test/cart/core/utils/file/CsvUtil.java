package com.eastspring.qa.cart.core.utils.file;

import com.eastspring.qa.cart.core.exceptions.CartException;
import com.eastspring.qa.cart.core.exceptions.CartExceptionType;
import org.apache.commons.csv.CSVFormat;
import org.apache.commons.csv.CSVPrinter;
import org.apache.commons.csv.CSVRecord;

import java.io.*;
import java.nio.file.Path;
import java.util.ArrayList;
import java.util.List;
import java.util.Map;
import java.util.stream.Collectors;


public class CsvUtil {

    public static final String FILE_NOT_FOUND = "file [{}] not found";
    public static final String ERROR_READING_CSV = "IO error while processing CSV file [{}]";

    public static List<Map<String, String>> getRecordsAsStringMap(Path filePath) {
        return getRecords(filePath, true).stream()
                .map(CSVRecord::toMap)
                .collect(Collectors.toList());
    }

    public static List<String> getRecordsAsStringList(Path filePath, boolean isFirstRecordAHeader) {
        return getRecords(filePath, isFirstRecordAHeader).stream()
                .map(csvRecord -> csvRecord.stream().collect(Collectors.joining(",")))
                .collect(Collectors.toList());
    }

    public static List<CSVRecord> getRecords(Path filePath, boolean isFirstRecordAHeader) {
        Iterable<CSVRecord> csvRecords;
        List<CSVRecord> csvRecordList = new ArrayList<>();

        try {
            FileReader fReader = new FileReader(filePath.toString());
            if (isFirstRecordAHeader) {
                csvRecords = CSVFormat.DEFAULT.builder().setHeader().setSkipHeaderRecord(true).build().parse(fReader);
            } else {
                csvRecords = CSVFormat.DEFAULT.parse(fReader);
            }
        } catch (FileNotFoundException e) {
            throw new CartException(e, CartExceptionType.UNSATISFIED_IMPLICIT_ASSUMPTION, FILE_NOT_FOUND, filePath);
        } catch (IOException e) {
            throw new CartException(e, CartExceptionType.IO_ERROR, ERROR_READING_CSV, filePath, e.getMessage());
        }
        csvRecords.forEach(csvRecordList::add);
        return csvRecordList;
    }

    public static List<String> getHeaders(Path filePath) {
        CSVRecord firstRecord = getRecords(filePath, true).get(0);
        return firstRecord.getParser().getHeaderNames();
    }

    public static CSVPrinter getDefaultCSVWriter(String filename) throws IOException {
        return new CSVPrinter(
                new FileWriter(filename),
                CSVFormat.DEFAULT
        );
    }
}