package com.eastspring.tom.cart.core.mdl;


import org.apache.commons.lang3.builder.ToStringBuilder;

public class Comparison {
    private String knownDate;
    private String bnpDnaSignature;
    private String csvFile;

    public Comparison() {
        this.knownDate = null;
        this.bnpDnaSignature = null;
        this.csvFile = null;
    }

    public Comparison(String knownDate, String bnpDnaSignature, String csvFile) {
        this.knownDate = knownDate;
        this.bnpDnaSignature = bnpDnaSignature;
        this.csvFile = csvFile;
    }

    public String getKnownDate() {
        return knownDate;
    }

    public void setKnownDate(String knownDate) {
        this.knownDate = knownDate;
    }

    public String getBnpDnaSignature() {
        return bnpDnaSignature;
    }

    public void setBnpDnaSignature(String bnpDnaSignature) {
        this.bnpDnaSignature = bnpDnaSignature;
    }

    public String getCsvFile() {
        return csvFile;
    }

    public void setCsvFile(String csvFile) {
        this.csvFile = csvFile;
    }

    @Override
    public String toString() {
        return ToStringBuilder.reflectionToString(this);
    }
}