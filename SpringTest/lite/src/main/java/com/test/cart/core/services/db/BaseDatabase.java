package com.eastspring.qa.cart.core.services.db;

import com.eastspring.qa.cart.core.exceptions.CartException;
import com.eastspring.qa.cart.core.exceptions.CartExceptionType;
import com.eastspring.qa.cart.core.utils.file.FileDirUtil;
import com.eastspring.qa.cart.core.utils.testData.TestDataFileUtil;

import java.nio.file.Path;
import java.sql.ResultSet;
import java.sql.Statement;
import java.util.HashMap;
import java.util.List;


public abstract class BaseDatabase extends DatabaseTaskSvc {

    public BaseDatabase(String configPrefix) {
        super(configPrefix);
    }

    public void executeSQLStatements(final String queries) {
        executeSQLStatements(queries, ";");
    }

    public void executeSQLStatements(final String queries, final String delimiter) {
        this.manageConnection();
        executeMultipleStatements(queries, delimiter);
    }

    public HashMap<Statement, ResultSet> executeSQLQueryForResultSet(final String query) {
        this.manageConnection();
        return executeQueryForResultSet(query);
    }

    public List<HashMap<String, String>> executeSQLQueryForMaps(final String query) {
        this.manageConnection();
        return executeQueryForMaps(query);
    }

    public void executeSQLFile(final String fileName) {
        this.executeSQLFile(fileName, ";");
    }

    public void executeSQLFile(final String fileName, final String delimiter) {
        this.manageConnection();
        String sqlQueries = getSqlFromFile(fileName);
        this.executeSQLStatements(sqlQueries, delimiter);
    }

    public void executeSQLFile(Path file, final String delimiter) {
        this.manageConnection();
        String sqlQueries = getSqlFromFile(file);
        this.executeSQLStatements(sqlQueries, delimiter);
    }

    //****************************************************************************************

    protected String getSqlFromFile(Path file) {
        if (!file.toString().endsWith(".sql")) throw new CartException(
                CartExceptionType.INVALID_DATA_TABLE,
                "Invalid sql file [{}] provided as input",
                file.toString()
        );
        return FileDirUtil.readFileToString(file.toString());
    }

    protected String getSqlFromFile(String sqlFileName) {
        if (!sqlFileName.endsWith(".sql")) throw new CartException(
                CartExceptionType.INVALID_DATA_TABLE,
                "Invalid sql file name [{}] provided as input",
                sqlFileName
        );
        return TestDataFileUtil.readFileAsString(sqlFileName);
    }
}

