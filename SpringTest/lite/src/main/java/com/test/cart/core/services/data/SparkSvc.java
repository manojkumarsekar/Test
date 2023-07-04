package com.eastspring.qa.cart.core.services.data;

import com.eastspring.qa.cart.core.report.CartLogger;
import org.apache.spark.sql.Dataset;
import org.apache.spark.sql.Row;
import org.apache.spark.sql.SparkSession;

import java.nio.file.Path;
import java.util.HashMap;
import java.util.Map;


public class SparkSvc {

    private SparkSession spark;

    // ToDo: add source-type based services (db, csv & excel) along with spark session manager
    public void createSession() {
        CartLogger.debug("Initializing Spark session");
        spark = SparkSession
                .builder()
                .master("local")
                .getOrCreate();
        CartLogger.debug("Spark session is created");
    }

    public SparkSession getSession() {
        if (spark == null) createSession();
        return spark;
    }

    public void endSession() {
        if (spark != null) {
            spark.close();
            CartLogger.debug("Spark session is closed");
            spark = null;
        }
    }

    public Dataset<Row> getCSVDataset(Path filePath, boolean isFirstRecordAHeader) {
        HashMap<String, String> options = new HashMap<>();
        options.put("delimiter", ",");
        options.put("header", String.valueOf(isFirstRecordAHeader));
        return getCSVDataset(filePath, options);
    }

    public Dataset<Row> getCSVDataset(Path filePath, Map<String, String> options) {
        return getSession().read().options(options).csv(filePath.toString());
    }

    public Dataset<Row> getExcelDataset(Path filePath, String sheetName, boolean isFirstRecordAHeader) {
        HashMap<String, String> options = new HashMap<>();
        options.put("header", String.valueOf(isFirstRecordAHeader));
        options.put("inferSchema", "true");
        options.put("dataAddress", "'" + sheetName + "'!A1");
        return getExcelDataset(filePath, options);
    }

    public Dataset<Row> getExcelDataset(Path filePath, Map<String, String> options) {
        return getSession()
                .read()
                .options(options)
                .format("com.crealytics.spark.excel")
                .load(filePath.toString());
    }

}