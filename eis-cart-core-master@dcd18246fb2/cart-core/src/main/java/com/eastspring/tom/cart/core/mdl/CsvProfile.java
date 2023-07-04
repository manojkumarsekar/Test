package com.eastspring.tom.cart.core.mdl;

import org.apache.commons.lang3.builder.ToStringBuilder;

import java.util.HashMap;
import java.util.Map;

public class CsvProfile {
    private boolean hasHeader;
    private long rowCount;
    private String[] headers;
    private int minRowColsCount;
    private int maxRowColsCount;
    private Map<Integer, Integer> columnLengthMaxMap;
    private Map<Integer, Integer> columnLengthMinMap;

    public CsvProfile() {
        this.hasHeader = false;
        this.rowCount = 0;
        this.headers = null;
        this.minRowColsCount = 0;
        this.maxRowColsCount = 0;
        this.columnLengthMaxMap = new HashMap<>();
        this.columnLengthMinMap = new HashMap<>();
    }

    public CsvProfile(boolean hasHeader, long rowCount, String[] headers) {
        this.hasHeader = hasHeader;
        this.rowCount = rowCount;
        this.headers = headers;
        this.minRowColsCount = 0;
        this.maxRowColsCount = 0;
        this.columnLengthMaxMap = new HashMap<>();
        this.columnLengthMinMap = new HashMap<>();
    }

    public boolean isHasHeader() {
        return hasHeader;
    }

    public void setHasHeader(boolean hasHeader) {
        this.hasHeader = hasHeader;
    }

    public long getRowCount() {
        return rowCount;
    }

    public void setRowCount(long rowCount) {
        this.rowCount = rowCount;
    }

    public int getHeaderCount() {
        return headers != null ? headers.length : 0;
    }

    public String[] getHeaders() {
        return headers;
    }

    public void setHeaders(String[] headers) {
        this.headers = headers;
    }

    public int getMinRowColsCount() {
        return minRowColsCount;
    }

    public void setMinRowColsCount(int minRowColsCount) {
        this.minRowColsCount = minRowColsCount;
    }

    public int getMaxRowColsCount() {
        return maxRowColsCount;
    }

    public void setMaxRowColsCount(int maxRowColsCount) {
        this.maxRowColsCount = maxRowColsCount;
    }

    public Map<Integer, Integer> getColumnLengthMaxMap() {
        return columnLengthMaxMap;
    }

    public void setColumnLengthMaxMap(Map<Integer, Integer> columnLengthMaxMap) {
        this.columnLengthMaxMap = columnLengthMaxMap;
    }

    public Map<Integer, Integer> getColumnLengthMinMap() {
        return columnLengthMinMap;
    }

    public void setColumnLengthMinMap(Map<Integer, Integer> columnLengthMinMap) {
        this.columnLengthMinMap = columnLengthMinMap;
    }

    public String toString() {
        return ToStringBuilder.reflectionToString(this);
    }
}
