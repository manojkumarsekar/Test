package com.eastspring.qa.cart.core.services.db;

import com.eastspring.qa.cart.core.CartBootstrap;
import com.eastspring.qa.cart.core.exceptions.CartException;
import com.eastspring.qa.cart.core.exceptions.CartExceptionType;
import com.eastspring.qa.cart.core.report.CartLogger;
import com.eastspring.qa.cart.core.configmanagers.AppConfigManager;

import java.sql.*;
import java.util.*;
import java.util.stream.Collectors;


class DatabaseTaskSvc {

    public static final String DEFAULT_QUERY_DELIMITER = ";";
    protected static final String NAMED_CONNECTION_IS_NULL_PROBABLY_IT_HAS_NOT_BEEN_CREATED = "named connection [{}] is null, probably it has not been created?";
    private static final String FAILED_TO_EXECUTE_QUERY_ON_NAMED_CONNECTION = "failed to execute query [{}] on named connection [{}]";

    private final String configPrefix;

    private DBConnectionManagerSvc dbConnectionManagerSvc;

    private AppConfigManager appConfigManager;

    public DatabaseTaskSvc(String configPrefix) {
        this.configPrefix = configPrefix;
    }

    protected DBConnectionManagerSvc getConnectionManager() {
        if (this.dbConnectionManagerSvc == null) {
            this.dbConnectionManagerSvc = (DBConnectionManagerSvc) CartBootstrap.getBean(DBConnectionManagerSvc.class);
        }
        return this.dbConnectionManagerSvc;
    }

    protected AppConfigManager getAppConfigManager() {
        if (this.appConfigManager == null) {
            this.appConfigManager = (AppConfigManager) CartBootstrap.getBean(AppConfigManager.class);
        }
        return this.appConfigManager;
    }

    protected void createNamedConnection() {
        getConnectionManager().createJDBCConnection(this.configPrefix);
    }

    protected void getConnection() {
        getConnectionManager().getConnection(this.configPrefix);
    }

    protected void manageConnection() {
        if (!(getConnectionManager().isConnectionEstablished(this.configPrefix))) {
            createNamedConnection();
        }
    }

    protected void terminateConnection() {
        getConnectionManager().closeConnection(this.configPrefix);
    }

    protected boolean isConnectionEstablished() {
        return getConnectionManager().isConnectionEstablished(this.configPrefix);
    }

    protected void executeMultipleStatements(final String sqlQueries) {
        this.executeMultipleStatements(sqlQueries, DEFAULT_QUERY_DELIMITER);
    }

    protected void executeMultipleStatements(final String sqlQueries, final String delimiter) {
        List<String> queriesList = this.splitQueries(sqlQueries, delimiter);
        for (String query : queriesList) {
            CartLogger.debug("Executing Query: [{}]", query);
            executeStatementOnNamedConnection(this.configPrefix, query);
        }
    }

    protected HashMap<Statement, ResultSet> executeQueryForResultSet(String query) {
        return executeQueryOnNamedConnection(this.configPrefix, query);
    }

    protected List<HashMap<String, String>> executeQueryForMaps(String query) {
        HashMap<Statement, ResultSet> stmtResultMap = executeQueryForResultSet(query);
        Statement stmt = (Statement) stmtResultMap.keySet().toArray()[0];
        ResultSet rs = (ResultSet) stmtResultMap.values().toArray()[0];
        List<HashMap<String, String>> records = new ArrayList<>();
        List<String> columnNames = new ArrayList<>();
        int recordCount = 0;
        int columnCount = 0;
        try {
            while (rs.next()) {
                HashMap<String, String> recordMap = new HashMap<>();
                ResultSetMetaData metaData = rs.getMetaData();
                columnCount = metaData.getColumnCount();
                recordCount++;
                for (int i = 1; i <= columnCount; i++) {
                    columnNames.add(metaData.getColumnName(i));
                    recordMap.put(columnNames.get(i - 1), rs.getString(i));
                }
                records.add(recordMap);
            }
            rs.close();
            stmt.close();
        } catch (SQLRecoverableException recover) {
            CartLogger.error("Ignoring SQL Recoverable Exception");
        } catch (SQLException e) {
            throw new CartException(CartExceptionType.PROCESSING_FAILED,
                    "Failed to execute query and return record map.",
                    e.getMessage());
        }
        CartLogger.debug("Successfully executed and retrieved '" + recordCount + "' records with '" + columnCount + "' columns");
        return records;
    }

    private List<String> splitQueries(final String queries, final String delimiter) {
        return Arrays.stream(queries.split(delimiter))
                .map(String::trim)
                .collect(Collectors.toList());
    }

    public boolean executeStatementOnNamedConnection(String connName, String sqlStatement) {
        Connection conn = getConnection(connName);
        boolean result;
        try {
            Statement stmt = conn.createStatement();
            result = stmt.execute(sqlStatement);
            stmt.close();
        } catch (SQLException e) {
            throw new CartException(e, CartExceptionType.PROCESSING_FAILED, FAILED_TO_EXECUTE_QUERY_ON_NAMED_CONNECTION
                    , sqlStatement, connName);
        }
        CartLogger.debug("Successfully executed statement on named connection");
        return result;
    }

    public HashMap<Statement, ResultSet> executeQueryOnNamedConnection(String connName, String sqlStatement) {
        Connection conn = getConnection(connName);
        HashMap<Statement, ResultSet> returnMap = new HashMap<>();
        ResultSet result;

        try {
            Statement stmt = conn.createStatement();
            result = stmt.executeQuery(sqlStatement);
            returnMap.put(stmt, result);
        } catch (SQLException e) {
            throw new CartException(e, CartExceptionType.PROCESSING_FAILED, FAILED_TO_EXECUTE_QUERY_ON_NAMED_CONNECTION
                    , sqlStatement, connName);
        }
        CartLogger.debug("Successfully executed query on named connection and retrieved result set");
        return returnMap;
    }

    private Connection getConnection(String connName) {
        Connection conn = getConnectionManager().getConnection(connName);
        if (conn == null) {
            throw new CartException(CartExceptionType.PROCESSING_FAILED, NAMED_CONNECTION_IS_NULL_PROBABLY_IT_HAS_NOT_BEEN_CREATED, connName);
        }
        return conn;
    }

}