package com.eastspring.tom.cart.core.mdl;

import org.apache.commons.lang3.builder.ToStringBuilder;

public class ColumnMetadata {
    private String columnName;
    private String columnType;
    private int precision;
    private int scale;

    public ColumnMetadata(String columnName, String columnType, int precision, int scale) {
        this.columnName = columnName;
        this.columnType = columnType;
        this.precision = precision;
        this.scale = scale;
    }

    public String getColumnName() {
        return columnName;
    }

    public String getBracketedColumnName() {
        return "[" + columnName + "]";
    }

    public void setColumnName(String columnName) {
        this.columnName = columnName;
    }

    public String getColumnType() {
        return columnType;
    }

    public void setColumnType(String columnType) {
        this.columnType = columnType;
    }

    public int getPrecision() {
        return precision;
    }

    public void setPrecision(int precision) {
        this.precision = precision;
    }

    public int getScale() {
        return scale;
    }

    public void setScale(int scale) {
        this.scale = scale;
    }

    public String toString() {
        return ToStringBuilder.reflectionToString(this);
    }
}
