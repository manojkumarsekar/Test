package com.eastspring.tom.cart.core.mdl;

public class HighlightedExcelRequest {
    private String csvFileFullpath;
    private String highlightedExcelFileFullpath;
    private String sourceName;
    private String targetName;
    private String matchName;
    private String matchWithToleranceName;
    private String encoding;
    private char separator;

    public String getCsvFileFullpath() {
        return csvFileFullpath;
    }

    public void setCsvFileFullpath(String csvFileFullpath) {
        this.csvFileFullpath = csvFileFullpath;
    }

    public String getHighlightedExcelFileFullpath() {
        return highlightedExcelFileFullpath;
    }

    public void setHighlightedExcelFileFullpath(String highlightedExcelFileFullpath) {
        this.highlightedExcelFileFullpath = highlightedExcelFileFullpath;
    }

    public String getSourceName() {
        return sourceName;
    }

    public void setSourceName(String sourceName) {
        this.sourceName = sourceName;
    }

    public String getTargetName() {
        return targetName;
    }

    public void setTargetName(String targetName) {
        this.targetName = targetName;
    }

    public String getMatchName() {
        return matchName;
    }

    public void setMatchName(String matchName) {
        this.matchName = matchName;
    }

    public String getMatchWithToleranceName() {
        return matchWithToleranceName;
    }

    public void setMatchWithToleranceName(String matchWithToleranceName) {
        this.matchWithToleranceName = matchWithToleranceName;
    }

    public String getEncoding() {
        return encoding;
    }

    public void setEncoding(String encoding) {
        this.encoding = encoding;
    }

    public char getSeparator() {
        return separator;
    }

    public void setSeparator(char separator) {
        this.separator = separator;
    }
}

