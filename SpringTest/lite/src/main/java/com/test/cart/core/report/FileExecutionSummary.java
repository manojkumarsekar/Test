package com.eastspring.qa.cart.core.report;

import com.eastspring.qa.cart.core.exceptions.CartException;
import com.eastspring.qa.cart.core.exceptions.CartExceptionType;
import org.apache.commons.csv.CSVRecord;
import com.eastspring.qa.cart.core.utils.file.CsvUtil;

import java.io.IOException;
import java.lang.reflect.Field;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.StandardOpenOption;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.List;
import java.util.stream.Collectors;


class ExecutionSummary {
    public static class DataSet {
        public String suiteName;
        public String testName;
        public String testID;
        public String testTags;
        public String status;
        public String exceptionType;
        public String executionTime;
        public String executionTimeInMinutes;
    }

    private ExecutionSummary() {
    }

    private static void createCSV(Path csvFile) throws IOException {
        Files.deleteIfExists(csvFile);
        if (!Files.exists(csvFile)) Files.createFile(csvFile);
        Field[] headers = DataSet.class.getFields();
        String headerRow = Arrays.stream(headers).map(header -> header.getName())
                .collect(Collectors.joining(","));
        Files.write(csvFile, headerRow.getBytes(), StandardOpenOption.APPEND);
        Files.write(csvFile, System.lineSeparator().getBytes(), StandardOpenOption.APPEND);
    }

    static void writeSummaryToCSV(Path csvFile, List<DataSet> executionSummary) {
        try {
            createCSV(csvFile);
            for (DataSet dataLine : executionSummary) {
                Field[] fields = dataLine.getClass().getFields();
                String row = Arrays.stream(fields).map(field -> {
                    try {
                        return field.get(dataLine).toString();
                    } catch (IllegalAccessException e) {
                        return "";
                    }
                }).collect(Collectors.joining(","));
                Files.write(csvFile, row.getBytes(), StandardOpenOption.APPEND);
                Files.write(csvFile, System.lineSeparator().getBytes(), StandardOpenOption.APPEND);
            }
        } catch (IOException io) {
            throw new CartException(CartExceptionType.IO_ERROR, "Failed to write summary to " + csvFile.getFileName(), io.getMessage());
        }
    }

    public static List<DataSet> readCSVSummary(Path csvFile) {
        List<CSVRecord> csvRecords = CsvUtil.getRecords(csvFile, true);
        List<DataSet> executionSummary = new ArrayList<>();
        for (CSVRecord csvRecord : csvRecords) {
            DataSet dataSet = new DataSet();
            dataSet.suiteName = csvRecord.get("suiteName");
            dataSet.testName = csvRecord.get("testName");
            dataSet.testID = csvRecord.get("testID");
            dataSet.status = csvRecord.get("status");
            dataSet.exceptionType = csvRecord.get("exceptionType");
            dataSet.executionTime = csvRecord.get("executionTime");
            dataSet.executionTimeInMinutes = csvRecord.get("executionTimeInMinutes");
            executionSummary.add(dataSet);
        }
        return executionSummary;
    }


}