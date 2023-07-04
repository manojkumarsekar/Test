package com.eastspring.tom.cart.core.mdl;

import com.eastspring.tom.cart.core.annotations.DBTable;

public class ComparisonRequest {

    @DBTable(columnName = "SourceTable")
    private String sourceTable;

    @DBTable(columnName = "TargetTable")
    private String targetTable;

    @DBTable(columnName = "SourceRecordCount")
    private Integer sourceRecordCount;

    @DBTable(columnName = "TargetRecordCount")
    private Integer targetRecordCount;

    @DBTable(columnName = "ComparisonStatus")
    private String comparisonStatus;

    @DBTable(columnName = "SourceDuplicate")
    private String sourceDuplicateView;

    @DBTable(columnName = "SourceDuplicateRecordCount")
    private Integer sourceDuplicateRecordCount;

    @DBTable(columnName = "TargetDuplicate")
    private String targetDuplicateView;

    @DBTable(columnName = "TargetDuplicateRecordCount")
    private Integer targetDuplicateRecordCount;

    @DBTable(columnName = "SourceSurplus")
    private String sourceSurplusView;

    @DBTable(columnName = "SourceSurplusRecordCount")
    private Integer sourceSurplusRecordCount;

    @DBTable(columnName = "TargetSurplus")
    private String targetSurplusView;

    @DBTable(columnName = "TargetSurplusRecordCount")
    private Integer targetSurplusRecordCount;

    @DBTable(columnName = "Mismatch")
    private String mismatchView;

    @DBTable(columnName = "MismatchRecordCount")
    private Integer mismatchRecordCount;

    @DBTable(columnName = "Match")
    private String matchView;

    @DBTable(columnName = "MatchRecordCount")
    private Integer matchRecordCount;

    @DBTable(columnName = "MismatchSmell")
    private String mismatchSmellView;

    public String getSourceTable() {
        return sourceTable;
    }

    public String getTargetTable() {
        return targetTable;
    }

    public Integer getSourceRecordCount() {
        return sourceRecordCount;
    }

    public Integer getTargetRecordCount() {
        return targetRecordCount;
    }

    public String getComparisonStatus() {
        return comparisonStatus;
    }

    public String getSourceDuplicateView() {
        return sourceDuplicateView;
    }

    public Integer getSourceDuplicateRecordCount() {
        return sourceDuplicateRecordCount;
    }

    public String getTargetDuplicateView() {
        return targetDuplicateView;
    }

    public Integer getTargetDuplicateRecordCount() {
        return targetDuplicateRecordCount;
    }

    public String getSourceSurplusView() {
        return sourceSurplusView;
    }

    public Integer getSourceSurplusRecordCount() {
        return sourceSurplusRecordCount;
    }

    public String getTargetSurplusView() {
        return targetSurplusView;
    }

    public Integer getTargetSurplusRecordCount() {
        return targetSurplusRecordCount;
    }

    public String getMismatchView() {
        return mismatchView;
    }

    public Integer getMismatchRecordCount() {
        return mismatchRecordCount;
    }

    public String getMatchView() {
        return matchView;
    }

    public Integer getMatchRecordCount() {
        return matchRecordCount;
    }

    public String getMismatchSmellView() {
        return mismatchSmellView;
    }

}
