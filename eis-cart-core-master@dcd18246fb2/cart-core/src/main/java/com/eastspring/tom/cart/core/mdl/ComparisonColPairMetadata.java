package com.eastspring.tom.cart.core.mdl;

import org.apache.commons.lang3.builder.ToStringBuilder;

public class ComparisonColPairMetadata {
    private boolean passhtruColumn;
    private String genericColumnName;
    private String sourceColumnName;
    private String targetColumnName;
    private String matchColumnName;
    private String tolerance;
    private int sourceColumnIndex;
    private int targetColumnIndex;
    private int matchColumnIndex;
    private MatchTolerance matchTolerance;
    private ComparisonResult comparisonResult;

    public ComparisonColPairMetadata() {
        this.passhtruColumn = false;
        this.genericColumnName = null;
        this.sourceColumnName = null;
        this.targetColumnName = null;
        this.matchColumnName = null;
        this.tolerance = null;
        this.sourceColumnIndex = -1;
        this.targetColumnIndex = -1;
        this.matchColumnIndex = -1;
        this.matchTolerance = MatchTolerance.EXACT;
        this.comparisonResult = null;
    }

    public boolean isPasshtruColumn() {
        return passhtruColumn;
    }

    public void setPasshtruColumn(boolean passhtruColumn) {
        this.passhtruColumn = passhtruColumn;
    }

    public String getGenericColumnName() {
        return genericColumnName;
    }

    public void setGenericColumnName(String genericColumnName) {
        this.genericColumnName = genericColumnName;
    }

    public String getSourceColumnName() {
        return sourceColumnName;
    }

    public void setSourceColumnName(String sourceColumnName) {
        this.sourceColumnName = sourceColumnName;
    }

    public String getTargetColumnName() {
        return targetColumnName;
    }

    public void setTargetColumnName(String targetColumnName) {
        this.targetColumnName = targetColumnName;
    }

    public String getMatchColumnName() {
        return matchColumnName;
    }

    public void setMatchColumnName(String matchColumnName) {
        this.matchColumnName = matchColumnName;
    }

    public String getTolerance() {
        return tolerance;
    }

    public void setTolerance(String tolerance) {
        this.tolerance = tolerance;
    }

    public int getSourceColumnIndex() {
        return sourceColumnIndex;
    }

    public void setSourceColumnIndex(int sourceColumnIndex) {
        this.sourceColumnIndex = sourceColumnIndex;
    }

    public int getTargetColumnIndex() {
        return targetColumnIndex;
    }

    public void setTargetColumnIndex(int targetColumnIndex) {
        this.targetColumnIndex = targetColumnIndex;
    }

    public int getMatchColumnIndex() {
        return matchColumnIndex;
    }

    public void setMatchColumnIndex(int matchColumnIndex) {
        this.matchColumnIndex = matchColumnIndex;
    }

    public MatchTolerance getMatchTolerance() {
        return matchTolerance;
    }

    public void setMatchTolerance(MatchTolerance matchTolerance) {
        this.matchTolerance = matchTolerance;
    }

    public ComparisonResult getComparisonResult() {
        return comparisonResult;
    }

    public void setComparisonResult(ComparisonResult comparisonResult) {
        this.comparisonResult = comparisonResult;
    }

    public String toString() {
        return ToStringBuilder.reflectionToString(this);
    }
}