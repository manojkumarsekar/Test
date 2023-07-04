package com.eastspring.tom.cart.core.mdl;


import org.apache.commons.lang3.builder.ToStringBuilder;

import java.util.ArrayList;
import java.util.List;

public class FileTransformation {
    private String id;
    private String namedResultFile;
    private String scope;
    private List<String> cols;
    private String charToStrip;
    private String from;
    private String to;
    private String srcFile;
    private String dstFile;

    public FileTransformation() {
        this.id = null;
        this.namedResultFile = null;
        this.scope = null;
        this.cols = new ArrayList<>();
        this.charToStrip = null;
        this.from = null;
        this.to = null;
        this.srcFile = null;
        this.dstFile = null;
    }

    public String getId() {
        return id;
    }

    public void setId(String id) {
        this.id = id;
    }

    public String getNamedResultFile() {
        return namedResultFile;
    }

    public void setNamedResultFile(String namedResultFile) {
        this.namedResultFile = namedResultFile;
    }

    public String getScope() {
        return scope;
    }

    public void setScope(String scope) {
        this.scope = scope;
    }

    public List<String> getCols() {
        return cols;
    }

    public void setCols(List<String> cols) {
        this.cols = cols;
    }

    public String getCharToStrip() {
        return charToStrip;
    }

    public void setCharToStrip(String charToStrip) {
        this.charToStrip = charToStrip;
    }

    public String getFrom() {
        return from;
    }

    public void setFrom(String from) {
        this.from = from;
    }

    public String getTo() {
        return to;
    }

    public void setTo(String to) {
        this.to = to;
    }

    public String getSrcFile() {
        return srcFile;
    }

    public void setSrcFile(String srcFile) {
        this.srcFile = srcFile;
    }

    public String getDstFile() {
        return dstFile;
    }

    public void setDstFile(String dstFile) {
        this.dstFile = dstFile;
    }

    public String toString() {
        return ToStringBuilder.reflectionToString(this);
    }
}
