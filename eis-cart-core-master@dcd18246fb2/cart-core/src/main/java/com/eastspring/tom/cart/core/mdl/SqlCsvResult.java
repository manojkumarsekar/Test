package com.eastspring.tom.cart.core.mdl;

import org.apache.commons.lang3.builder.ToStringBuilder;

public class SqlCsvResult {
    private String sqlQuery;
    private CsvProfile csvProfile;

    public SqlCsvResult(String sqlQuery, CsvProfile csvProfile) {
        this.sqlQuery = sqlQuery;
        this.csvProfile = csvProfile;
    }

    public String getSqlQuery() {
        return sqlQuery;
    }

    public void setSqlQuery(String sqlQuery) {
        this.sqlQuery = sqlQuery;
    }

    public CsvProfile getCsvProfile() {
        return csvProfile;
    }

    public void setCsvProfile(CsvProfile csvProfile) {
        this.csvProfile = csvProfile;
    }

    public String toString() {
        return ToStringBuilder.reflectionToString(this);
    }
}
