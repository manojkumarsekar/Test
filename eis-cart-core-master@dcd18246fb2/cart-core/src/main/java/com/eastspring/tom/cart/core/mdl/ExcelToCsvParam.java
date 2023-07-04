package com.eastspring.tom.cart.core.mdl;

import org.apache.commons.lang3.builder.ToStringBuilder;

public class ExcelToCsvParam {
    private String sheetName;
    private String srcFullpath;
    private String dstFullpath;
    private int skipRows;
    private int cellRowNum;
    private int currMaxCols;
    private int colsLimit;

    public String getSheetName() {
        return sheetName;
    }

    public void setSheetName(String sheetName) {
        this.sheetName = sheetName;
    }

    public String getSrcFullpath() {
        return srcFullpath;
    }

    public void setSrcFullpath(String srcFullpath) {
        this.srcFullpath = srcFullpath;
    }

    public String getDstFullpath() {
        return dstFullpath;
    }

    public void setDstFullpath(String dstFullpath) {
        this.dstFullpath = dstFullpath;
    }

    public int getSkipRows() {
        return skipRows;
    }

    public void setSkipRows(int skipRows) {
        this.skipRows = skipRows;
    }

    public int getCellRowNum() {
        return cellRowNum;
    }

    public void setCellRowNum(int cellRowNum) {
        this.cellRowNum = cellRowNum;
    }

    public int getCurrMaxCols() {
        return currMaxCols;
    }

    public void setCurrMaxCols(int currMaxCols) {
        this.currMaxCols = currMaxCols;
    }

    public int getColsLimit() {
        return colsLimit;
    }

    public void setColsLimit(int colsLimit) {
        this.colsLimit = colsLimit;
    }

    public String toString() {
        return ToStringBuilder.reflectionToString(this);
    }
}
