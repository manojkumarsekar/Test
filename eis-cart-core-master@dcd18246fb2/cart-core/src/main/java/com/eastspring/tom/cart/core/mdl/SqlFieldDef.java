package com.eastspring.tom.cart.core.mdl;

import org.apache.commons.lang3.builder.ToStringBuilder;

public class SqlFieldDef {
    private String fieldName;
    private FieldType fieldType;
    private int size;

    public enum FieldType {
        VARCHAR,
        DATE,
        NUMERIC
    }

    public SqlFieldDef(String fieldName, FieldType fieldType, int size) {
        this.fieldName = fieldName;
        this.fieldType = fieldType;
        this.size = size;
    }

    public String getFieldName() {
        return fieldName;
    }

    public void setFieldName(String fieldName) {
        this.fieldName = fieldName;
    }

    public FieldType getFieldType() {
        return fieldType;
    }

    public void setFieldType(FieldType fieldType) {
        this.fieldType = fieldType;
    }

    public int getSize() {
        return size;
    }

    public void setSize(int size) {
        this.size = size;
    }

    public String toString() {
        return ToStringBuilder.reflectionToString(this);
    }
}
