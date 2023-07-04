package com.eastspring.qa.cart.core.utils.data;

import com.eastspring.qa.cart.core.lookUps.AttachmentType;
import org.apache.commons.collections.CollectionUtils;
import org.apache.spark.sql.Dataset;
import org.apache.spark.sql.Row;
import com.eastspring.qa.cart.core.exceptions.CartException;
import com.eastspring.qa.cart.core.exceptions.CartExceptionType;
import com.eastspring.qa.cart.core.report.CartLogger;

import java.nio.charset.StandardCharsets;
import java.text.SimpleDateFormat;
import java.util.*;


public class DataRecordCompareUtil {

    public enum CompareMode {
        MATCH_ALL_RECORDS,
        MATCH_ALL_RECORDS_IN_ORDER,
        LOOKUP_TARGET_IN_REFERENCE
    }

    public static void compareStringLists(List<String> targetRecords, List<String> referenceRecords,
                                          CompareMode mode) {
        int referenceRecordCount = referenceRecords.size();
        int targetRecordCount = targetRecords.size();
        if ((
                (mode.equals(CompareMode.MATCH_ALL_RECORDS) || mode.equals(CompareMode.MATCH_ALL_RECORDS_IN_ORDER)) &&
                        referenceRecordCount != targetRecordCount
        ) || mode.equals(CompareMode.LOOKUP_TARGET_IN_REFERENCE) && targetRecordCount > referenceRecordCount) {
            String errorMessage = "Target record count [" + targetRecordCount + "] is not as expected. " +
                    "Reference records count [" + referenceRecordCount + "].";
            if (mode.equals(CompareMode.MATCH_ALL_RECORDS_IN_ORDER)) {
                throw new CartException(CartExceptionType.ASSERTION_ERROR, errorMessage +
                        "Test records cannot be compared in same order");
            } else {
                CartLogger.error(errorMessage);
            }
        }

        if (mode.equals(CompareMode.LOOKUP_TARGET_IN_REFERENCE)) {
            lookupStringList(targetRecords, referenceRecords);
        } else if (mode.equals(CompareMode.MATCH_ALL_RECORDS)) {
            equateStringList(targetRecords, referenceRecords);
        } else if (mode.equals(CompareMode.MATCH_ALL_RECORDS_IN_ORDER)) {
            equateStringListInOrder(targetRecords, referenceRecords);
        } else {
            throw new CartException(CartExceptionType.INCOMPLETE_PARAMS,
                    "Invalid input for compare-mode " + mode);
        }
    }

    private static void lookupStringList(List<String> targetRecords, List<String> referenceRecords) {
        String timeStamp = new SimpleDateFormat("yyyyMMdd_hhmmssSS").format(new Date());
        Collection<String> excludedRecords = CollectionUtils.removeAll(targetRecords, referenceRecords);
        if (excludedRecords.size() > 0) {
            CartLogger.insertFileToReport(
                    String.join(System.lineSeparator(), excludedRecords).getBytes(StandardCharsets.UTF_8),
                    "MissingRecordsInTarget_" + timeStamp,
                    AttachmentType.TXT
            );
            throw new CartException(CartExceptionType.ASSERTION_ERROR,
                    "Target file got '[{}]' unexpected records in comparison to reference file. " +
                            "Refer attachment [{}] for records from target that are not found in reference file",
                    excludedRecords.size(), "MissingRecordsInTarget_" + timeStamp);
        }
        CartLogger.info("All records in target file are found in reference file");
    }

    private static void equateStringListInOrder(List<String> targetRecords, List<String> referenceRecords) {
        String timeStamp = new SimpleDateFormat("yyyyMMdd_hhmmssSS").format(new Date());
        List<String> mismatchRecords = new ArrayList<>();
        mismatchRecords.add("Record index^targetRecord^referenceRecord");
        for (int i = 0; i < targetRecords.size(); i++) {
            String targetRecord = targetRecords.get(i);
            String referenceRecord = referenceRecords.get(i);
            if (!targetRecord.equals(referenceRecord)) {
                mismatchRecords.add(i + 1 + "^" + targetRecord + "^" + referenceRecord);
            }
        }
        if (mismatchRecords.size() > 1) {
            int mismatchRecordCount = mismatchRecords.size() - 1;
            CartLogger.insertFileToReport(
                    String.join(System.lineSeparator(), mismatchRecords).getBytes(StandardCharsets.UTF_8),
                    "MismatchRecords_" + timeStamp,
                    AttachmentType.TXT
            );
            CartLogger.error("[{}] records in target file does not match with reference file. " +
                    "Refer attachment [{}]", mismatchRecordCount, "MismatchRecords_" + timeStamp);
        }
        CartLogger.info("Target and reference files contain same set of records");
    }

    private static void equateStringList(List<String> targetRecords, List<String> referenceRecords) {
        String timeStamp = new SimpleDateFormat("yyyyMMdd_hhmmssSS").format(new Date());
        Collection<String> excludedTargetRecords = CollectionUtils.removeAll(targetRecords, referenceRecords);
        Collection<String> excludedReferenceRecords = CollectionUtils.removeAll(referenceRecords, targetRecords);
        if (!excludedTargetRecords.isEmpty() || !excludedReferenceRecords.isEmpty()) {
            int etRecordCount = excludedTargetRecords.size();
            CartLogger.insertFileToReport(
                    String.join(System.lineSeparator(), excludedTargetRecords).getBytes(StandardCharsets.UTF_8),
                    "ExtraRecordsInTarget_" + timeStamp,
                    AttachmentType.TXT
            );
            CartLogger.error("Target file contain [{}] unexpected records in addition to reference file records. " +
                    "Refer attachment [{}]", etRecordCount, "ExtraRecordsInTarget_" + timeStamp);
            int erRecordCount = excludedReferenceRecords.size();
            CartLogger.insertFileToReport(
                    String.join(System.lineSeparator(), excludedReferenceRecords).getBytes(StandardCharsets.UTF_8),
                    "MissingRecordsInTarget_" + timeStamp,
                    AttachmentType.TXT
            );
            CartLogger.error("Target file does not contain [{}] records from reference file. " +
                    "Refer attachment [{}]", erRecordCount, "MissingRecordsInTarget_" + timeStamp);
            throw new CartException(CartExceptionType.ASSERTION_ERROR,
                    "Target file does not contain all expected records");
        } else {
            CartLogger.info("Target and reference files contain same set of records");
        }
    }

    public static void compareDatasetRows(Dataset<Row> targetRecords, Dataset<Row> referenceRecords,
                                          CompareMode mode) {
        Dataset<Row> excludedTargetRecords = targetRecords.except(referenceRecords);
        Dataset<Row> excludedReferenceRecords = referenceRecords.except(targetRecords);
        if (mode.equals(CompareMode.LOOKUP_TARGET_IN_REFERENCE)) {
            lookupDataSetRows(excludedTargetRecords);
        } else if (mode.equals(CompareMode.MATCH_ALL_RECORDS)) {
            equateDataSetRows(excludedTargetRecords, excludedReferenceRecords);
        } else {
            throw new CartException(CartExceptionType.INCOMPLETE_PARAMS,
                    "Invalid input for compare-mode " + mode);
        }
    }

    private static void lookupDataSetRows(Dataset<Row> excludedTargetRecords) {
        if (!excludedTargetRecords.isEmpty()) {
            excludedTargetRecords.show();
            long excRecordCount = excludedTargetRecords.count();
            throw new CartException(CartExceptionType.ASSERTION_ERROR,
                    "Target file got '[{}]' unexpected records in comparison to reference file",
                    excRecordCount);
        } else {
            CartLogger.info("All records in target file are found in reference file");
        }
    }

    private static void equateDataSetRows(Dataset<Row> excludedTargetRecords, Dataset<Row> excludedReferenceRecords) {
        if (!excludedTargetRecords.isEmpty() || !excludedReferenceRecords.isEmpty()) {
            excludedTargetRecords.show();
            long etRecordCount = excludedTargetRecords.count();
            CartLogger.error("Target file contain " + etRecordCount + " unexpected records in comparison to reference file");
            excludedReferenceRecords.show();
            long erRecordCount = excludedReferenceRecords.count();
            CartLogger.error("Reference file contain " + erRecordCount + " unexpected records in comparison to target file");
            throw new CartException(CartExceptionType.ASSERTION_ERROR,
                    "Target file does not contain all expected records");
        } else {
            CartLogger.info("Target and reference files contain same set of records");
        }
    }
}