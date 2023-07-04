package com.eastspring.tom.cart.core.mdl;

import org.apache.commons.lang3.builder.ToStringBuilder;

public class KeyMetadata {
    private int columnIndex;

    public KeyMetadata() {
        this.columnIndex = 0;
    }

    public KeyMetadata(int columnIndex) {
        this.columnIndex = columnIndex;
    }

    public int getColumnIndex() {
        return columnIndex;
    }

    public void setColumnIndex(int columnIndex) {
        this.columnIndex = columnIndex;
    }

    public String toString() {
        return ToStringBuilder.reflectionToString(this);
    }
}
