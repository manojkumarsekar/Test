package com.eastspring.tom.cart.core.tool;

public class FragmentThis {
    private String filename;
    private String line;

    public FragmentThis(String filename, String line) {
        this.filename = filename;
        this.line = line;
    }

    public String getFilename() {
        return filename;
    }

    public String getLine() {
        return line;
    }
}
