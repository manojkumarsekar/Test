package com.eastspring.tom.cart.core.mdl;

public class CsvLoadInfo {
    private final String srcDir;
    private final String filename;
    private final String tableName;
    private final String encoding;

    public CsvLoadInfo(final String srcDir, final String filename, final String tableName, final String encoding) {
        this.srcDir = srcDir;
        this.filename = filename;
        this.tableName = tableName;
        this.encoding = encoding;
    }

    public String getSrcDir() {
        return srcDir;
    }

    public String getFilename() {
        return filename;
    }

    public String getTableName() {
        return tableName;
    }

    public String getEncoding() {
        return encoding;
    }
}
