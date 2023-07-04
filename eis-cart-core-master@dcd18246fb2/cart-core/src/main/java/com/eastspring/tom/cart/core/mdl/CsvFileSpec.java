package com.eastspring.tom.cart.core.mdl;

import org.apache.commons.lang3.builder.ToStringBuilder;

public class CsvFileSpec {
    private String filename;
    private String encoding;
    private char separator;

    public CsvFileSpec(String filename, String encoding, char separator) {
        this.filename = filename;
        this.encoding = encoding;
        this.separator = separator;
    }

    public String getFilename() {
        return filename;
    }

    public String getEncoding() {
        return encoding;
    }

    public char getSeparator() {
        return separator;
    }

    public String toString() {
        return ToStringBuilder.reflectionToString(this);
    }
}
