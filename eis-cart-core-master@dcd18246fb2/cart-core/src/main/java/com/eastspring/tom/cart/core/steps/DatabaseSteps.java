package com.eastspring.tom.cart.core.steps;


import com.eastspring.tom.cart.core.CartException;
import com.eastspring.tom.cart.core.CartExceptionType;
import com.eastspring.tom.cart.core.svc.DatabaseSvc;
import com.eastspring.tom.cart.core.svc.JdbcSvc;
import com.eastspring.tom.cart.core.svc.StateSvc;
import com.eastspring.tom.cart.core.svc.WorkspaceDirSvc;
import com.eastspring.tom.cart.core.utl.FileDirUtil;
import com.eastspring.tom.cart.core.utl.SqlStringUtil;
import com.eastspring.tom.cart.core.utl.WorkspaceUtil;
import com.eastspring.tom.cart.cst.SqlQueryConstants;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;

import java.io.File;
import java.util.List;
import java.util.Map;
import java.util.Set;

public class DatabaseSteps {
    private static final Logger LOGGER = LoggerFactory.getLogger(DatabaseSteps.class);

    public static final String VERIFICATION_EXPECTED_RESULT = "|RESULT|\n|1|\n";
    public static final String SQL_QUERY_PATH = "SQL Query Path [{}]";

    @Autowired
    private DatabaseSvc databaseSvc;

    @Autowired
    private JdbcSvc jdbcSvc;

    @Autowired
    private FileDirUtil fileDirUtil;

    @Autowired
    private WorkspaceUtil workspaceUtil;

    @Autowired
    private StateSvc stateSvc;

    @Autowired
    private SqlStringUtil sqlStringUtil;

    @Autowired
    private WorkspaceDirSvc workspaceDirSvc;

    public void setDatabaseConnectionToConfig(String dbConfigPrefix) {
        databaseSvc.setDatabaseConnectionToConfig(dbConfigPrefix);
    }

    public void resetDatabaseConnectionWithConfig(final String dbConfigPrefix){
        databaseSvc.resetDatabaseConnectionToConfig(dbConfigPrefix);
    }

    public void verifyNamedOracleConnection(String connectionName) {
        jdbcSvc.createNamedConnection(connectionName);
        String result = jdbcSvc.executeQueryOnNamedConnection(connectionName, SqlQueryConstants.VERIFY_ORACLE_SQL_QUERY);
        LOGGER.debug("  query result: [{}]", result);
        if (result == null || !VERIFICATION_EXPECTED_RESULT.equals(result)) {
            throw new CartException(CartExceptionType.VERIFICATION_FAILED, "connection validation query failed");
        }
    }

    public void verifyNamedSQLServerConnection(String connectionName) {
        jdbcSvc.createNamedConnection(connectionName);
        String result = jdbcSvc.executeQueryOnNamedConnection(connectionName, SqlQueryConstants.VERIFY_MSSQL_SQL_QUERY);
        LOGGER.debug("query result: [{}]", result);
        if (result == null || !VERIFICATION_EXPECTED_RESULT.equals(result)) {
            throw new CartException(CartExceptionType.VERIFICATION_FAILED, "connection validation query failed");
        }
    }

    public void pollUntilMaxTimeVerifySqlResult(Integer maxPollTime, String expected, String sqlQuery) {
        final String effectiveSql = this.getSql(sqlQuery);
        databaseSvc.pollUntilMaxTimeVerifySqlResult(maxPollTime, expected, effectiveSql);
    }

    public void iExpectValueOfColumnShouldMatch(final String columnName, final String expectedValue, final String sqlQuery) {
        String sqlQueryToExecute = this.getSql(sqlQuery);
        final String expandExpectedValue = stateSvc.expandVar(expectedValue);
        LOGGER.debug("Column Value to verify is [{}]: Expected value is [{}]", columnName, expandExpectedValue);
        databaseSvc.verifySqlResultOfColumn(columnName, expandExpectedValue, sqlQueryToExecute, 1);
    }

    public void iExpectValueOfColumnShouldMatchWithinRetries(final String columnName, final String expectedValue, final Integer retries, final String sqlQuery) {
        String sqlQueryToExecute = this.getSql(sqlQuery);
        final String expandExpectedValue = stateSvc.expandVar(expectedValue);
        LOGGER.debug("Column Value to verify is [{}]: Expected value is [{}]", columnName, expandExpectedValue);
        databaseSvc.verifySqlResultOfColumn(columnName, expandExpectedValue, sqlQueryToExecute, retries);
    }

    public void iExpectValueOfColumnShouldMatch(String expectedValue, Map<String, String> columnQueryMap) {
        final Set<String> setOfColumns = columnQueryMap.keySet();
        final String expandExpectedValue = stateSvc.expandVar(expectedValue);
        String sqlQueryToExecute;
        for (String columnName : setOfColumns) {
            sqlQueryToExecute = this.getSql(columnQueryMap.get(columnName));
            LOGGER.debug("Column Value to verify is [{}]: Expected value is [{}]", columnName, expandExpectedValue);
            databaseSvc.verifySqlResultOfColumn(columnName, expandExpectedValue, sqlQueryToExecute, 1);
        }
    }

    public void invokeSqlStoredProcedure(String connName, String spName, List<String> inParams, List<String> outParams) {
        jdbcSvc.executeStoredProcedureOnNamedConnection(connName, spName, inParams, outParams);
    }

    public void expectRecordsInTableWithQuery(String sqlQuery) {
        int result = Integer.parseInt(databaseSvc.executeSingleValueQueryOnNamedConnection(sqlQuery));
        if (result == 0) {
            LOGGER.error("verification failed, table does not have records");
            throw new CartException(CartExceptionType.VERIFICATION_FAILED, "verification failed, table does not have records");
        }
        LOGGER.debug("Table has [{}] records", result);
    }

    public void executeQueryAndExtractValues(String sqlQuery, List<String> listOfColumns) {
        String effectiveSql = this.getSql(sqlQuery);
        databaseSvc.executeSqlQueryAssignResultsToVars(effectiveSql, listOfColumns);
    }

    public void executeQueryAndExtractValues(String sqlQuery, String columnName) {
        String effectiveSql = this.getSql(sqlQuery);
        databaseSvc.executeSqlQueryAssignResultsToVars(effectiveSql, columnName);
    }


    public void executePlSqlBlock(final String plSqlBlock) {
        databaseSvc.executePlSqlBlock(this.getSql(plSqlBlock));
    }

    public void executeMultipleSqls(final String queries, final String delimiter) {
        List<String> queriesList = sqlStringUtil.splitQueries(queries, delimiter);
        for (String query : queriesList) {
            String effectiveSql = this.getSql(query);
            databaseSvc.executeMultipleQueries(effectiveSql, delimiter);
        }
    }

    public void exportTableToCSVFile(String filePath, String sqlQuery) {
        databaseSvc.exportQueryTableDataToCSVFile(filePath, sqlQuery);
    }

    public void saveBlobToFile(final String sqlQuery, final String filename) {
        final String effectiveSql = getSql(sqlQuery);
        final String expandFileName = stateSvc.expandVar(filename);
        databaseSvc.executeSqlQuerySaveBlobToFile(effectiveSql, expandFileName);
    }

    private String getSql(String sqlFile) {
        String effectiveSql = sqlFile;
        if (sqlFile.endsWith(".sql")) {
            final String filePathExpanded = workspaceDirSvc.normalize(stateSvc.expandVar(sqlFile.trim()));
            LOGGER.debug(SQL_QUERY_PATH, filePathExpanded);
            effectiveSql = fileDirUtil.readFileToString(filePathExpanded);
        }
        return effectiveSql;
    }

    public void connectToReconDatabase(final String connName) {
        databaseSvc.setDatabaseConnectionToConfig(connName);
        /*String scriptsPath = fileDirUtil.getMavenMainResourcesPath("recon.engine.scripts");
        databaseSvc.executeMultipleQueries(fileDirUtil.readFileToString(scriptsPath + File.separator + "ColumnCategory.sql"));
        databaseSvc.executeMultipleQueries(fileDirUtil.readFileToString(scriptsPath + File.separator + "ComparisonRequest.sql"));
        databaseSvc.executeMultipleQueries(fileDirUtil.readFileToString(scriptsPath + File.separator + "Compare.sql"), "###");*/
    }

    public void importFlatFileIntoDatabase(final String filepath, final String tableName) {
        final String expandFilePath = workspaceDirSvc.normalize(stateSvc.expandVar(filepath));
        final String expandTableName = stateSvc.expandVar(tableName);
        char separator;
        if (expandFilePath.endsWith(".csv")) {
            separator = ',';
        } else if (expandFilePath.endsWith(".psv")) {
            separator = '|';
        } else {
            LOGGER.error("Importing flat file into database currently supports for CSV and PSV files");
            throw new CartException(CartExceptionType.UNDEFINED, "Importing flat file into database currently supports for CSV and PSV files");
        }
        databaseSvc.loadFlatFileIntoDatabase(expandFilePath, expandTableName, separator);
        LOGGER.debug("File [{}] exported as Table [{}]", new File(filepath).getName(), tableName);
    }
}
