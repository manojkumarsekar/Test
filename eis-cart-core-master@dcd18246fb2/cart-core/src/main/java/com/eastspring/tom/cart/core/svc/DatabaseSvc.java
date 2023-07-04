package com.eastspring.tom.cart.core.svc;

import com.eastspring.tom.cart.core.CartException;
import com.eastspring.tom.cart.core.CartExceptionType;
import com.eastspring.tom.cart.core.mdl.RefactorSqlMetadata;
import com.eastspring.tom.cart.core.utl.*;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;

import java.util.Arrays;
import java.util.Collections;
import java.util.List;
import java.util.Map;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

import static tomcart.glue.DatabaseStepsDef.DEFAULT_QUERY_DELIMITER;

public class DatabaseSvc {

    private static final Logger LOGGER = LoggerFactory.getLogger(DatabaseSvc.class);

    public static final String UNABLE_TO_RETRIEVE_RECORDS_WITH_QUERY = "Unable to retrieve records with Query [{}]";

    @Autowired
    private DateTimeUtil dateTimeUtil;

    @Autowired
    private JdbcSvc jdbcSvc;

    @Autowired
    private StateSvc stateSvc;

    @Autowired
    private ThreadSvc threadSvc;

    @Autowired
    private CsvSvc csvSvc;

    @Autowired
    private FileDirUtil fileDirUtil;

    @Autowired
    private WorkspaceUtil workspaceUtil;

    @Autowired
    private ScenarioUtil scenarioUtil;

    @Autowired
    private SqlStringUtil sqlStringUtil;

    public static final int POLL_INTERVAL_SECONDS = 2;

    private String currentConfigPrefix = "<undefined>";

    public String getCurrentConfigPrefix() {
        return currentConfigPrefix;
    }

    public void setDatabaseConnectionToConfig(String dbConfigPrefix) {
        currentConfigPrefix = dbConfigPrefix;
        jdbcSvc.createNamedConnection(currentConfigPrefix);
    }

    public void resetDatabaseConnectionToConfig(String dbConfigPrefix) {
        jdbcSvc.disconnectNamedConnection(dbConfigPrefix);
    }

    public void executeSqlQueryAssignResultsToVarsWithPrefix(String varPrefix, String sqlQuery) {
        String expandedSqlQuery = stateSvc.expandVar(sqlQuery);
        Map<String, String> result = jdbcSvc.executeSingleRowQueryOnNamedConnection(currentConfigPrefix, expandedSqlQuery);
        LOGGER.debug("assigning variable with prefix [{}]:", varPrefix);
        for (String key : result.keySet()) { // NOSONAR
            String varName = varPrefix + key;
            stateSvc.setStringVar(varName, result.get(key));
            LOGGER.debug("  stateSvc.setStringVar({}, {})", varName, result.get(key));
        }
    }

    public String executeSingleValueQueryOnNamedConnection(String sqlQuery) {
        String expandedSqlQuery = stateSvc.expandVar(sqlQuery);
        Map<String, String> queryResultMap = jdbcSvc.executeSingleRowQueryOnNamedConnection(currentConfigPrefix, expandedSqlQuery);
        String result;
        LOGGER.debug("result map [{}]");
        if (queryResultMap.size() > 0) {
            String key = (String) (queryResultMap.keySet().toArray())[0];
            result = queryResultMap.get(key);
            LOGGER.debug("single value query result: {}", result);
        } else {
            result = null;
        }

        return result;
    }

    public String executeSingleValueQueryOnNamedConnection(String sqlQuery, String columnName) {
        String expandedSqlQuery = stateSvc.expandVar(sqlQuery);
        Map<String, String> queryResultMap = jdbcSvc.executeSingleRowQueryOnNamedConnection(currentConfigPrefix, expandedSqlQuery);
        String result;
        if (queryResultMap.size() > 0) {
            result = queryResultMap.get(columnName);
            LOGGER.debug("single value query result for column: {} is {}", columnName, result);
        } else {
            result = null;
        }
        return result;
    }

    public void executeSqlQueryAssignResultsToVars(String sqlQuery, List<String> columnsList) {
        String expandedSqlQuery = stateSvc.expandVar(sqlQuery);
        Map<String, String> queryResultMap = jdbcSvc.executeSingleRowQueryOnNamedConnection(currentConfigPrefix, expandedSqlQuery);
        String result;

        if (queryResultMap.size() <= 0) {
            LOGGER.error(UNABLE_TO_RETRIEVE_RECORDS_WITH_QUERY, expandedSqlQuery);
            throw new CartException(CartExceptionType.PROCESSING_FAILED, UNABLE_TO_RETRIEVE_RECORDS_WITH_QUERY, expandedSqlQuery);
        }

        for (String columnName : columnsList) {
            if (!queryResultMap.containsKey(columnName)) {
                LOGGER.error("Query result does not contain Column [{}]", columnName);
                throw new CartException(CartExceptionType.INVALID_INVOCATION_PARAMS, "Query result does not contain Column [{}]", columnName);
            }
            result = queryResultMap.get(columnName);
            stateSvc.setStringVar(columnName, result);
        }
    }

    public void executeSqlQueryAssignResultsToVars(String sqlQuery, String columnName) {
        String expandedSqlQuery = stateSvc.expandVar(sqlQuery);
        List<String> queryResultList = jdbcSvc.getColumnValuesOnNamedConnection(currentConfigPrefix, expandedSqlQuery, columnName);
        Integer resultNum = 1;
        if (queryResultList.size() <= 0) {
            LOGGER.error(UNABLE_TO_RETRIEVE_RECORDS_WITH_QUERY, expandedSqlQuery);
            throw new CartException(CartExceptionType.PROCESSING_FAILED, UNABLE_TO_RETRIEVE_RECORDS_WITH_QUERY, expandedSqlQuery);
        }

        for (String result : queryResultList) {
            stateSvc.setStringVar(columnName + resultNum, result);

            ++resultNum; // appending the variable names with numbers
        }
    }

    /**
     * Gets column value map from sql result.
     *
     * @param sqlQuery the sql query
     * @return the column value map from sql result {@link Map}
     */
    public Map<String, String> getColumnValueMapFromSqlResult(final String sqlQuery) {
        String expandedSqlQuery = stateSvc.expandVar(sqlQuery);
        Map<String, String> queryResultMap = jdbcSvc.executeSingleRowQueryOnNamedConnection(currentConfigPrefix, expandedSqlQuery);

        if (queryResultMap.size() <= 0) {
            LOGGER.error(UNABLE_TO_RETRIEVE_RECORDS_WITH_QUERY, expandedSqlQuery);
            throw new CartException(CartExceptionType.PROCESSING_FAILED, UNABLE_TO_RETRIEVE_RECORDS_WITH_QUERY, expandedSqlQuery);
        }
        return queryResultMap;
    }

    public void pollUntilMaxTimeVerifySqlResult(Integer maxPollTime, String expected, String sqlQuery) {
        long millisStart = dateTimeUtil.currentTimeMillis();
        long millisCurrent = millisStart;
        boolean verificationSuccess = false;
        String result = null;

        while ((millisCurrent - millisStart) / 1000 <= maxPollTime && !verificationSuccess) {
            result = this.executeSingleValueQueryOnNamedConnection(sqlQuery);
            if (result != null && expected.equals(result.trim())) {
                verificationSuccess = true;
            }
            threadSvc.sleepSeconds(DatabaseSvc.POLL_INTERVAL_SECONDS);
            millisCurrent = dateTimeUtil.currentTimeMillis();
        }

        if (!verificationSuccess) {
            LOGGER.error("Verification failed, were expecting value to turn to [{}] within {} seconds, but actual is [{}]", expected, maxPollTime, result);
            throw new CartException(CartExceptionType.VERIFICATION_FAILED, "Verification failed, were expecting value to turn to [{}] within {} seconds but actual is [{}]", expected, maxPollTime, result);
        }
    }

    public void verifySqlResultOfColumn(String columnName, String expectedValue, String sqlQuery, Integer noOfRetries) {
        final String expandedSqlQuery = stateSvc.expandVar(sqlQuery);

        if (!expandedSqlQuery.contains(columnName)) {
            LOGGER.error("Query does not have column [{}]", columnName);
            throw new CartException(CartExceptionType.INVALID_INVOCATION_PARAMS, "Query does not have column [{}]", columnName);
        }

        Map<String, String> queryResultMap = jdbcSvc.executeSingleRowQueryOnNamedConnection(currentConfigPrefix, expandedSqlQuery);

        if (queryResultMap.size() <= 0) {
            LOGGER.error(UNABLE_TO_RETRIEVE_RECORDS_WITH_QUERY, expandedSqlQuery);
            throw new CartException(CartExceptionType.PROCESSING_FAILED, UNABLE_TO_RETRIEVE_RECORDS_WITH_QUERY, expandedSqlQuery);
        }

        String columnVal = queryResultMap.get(columnName.toUpperCase());
        if (columnVal == null) {
            LOGGER.error("");
            throw new CartException(CartExceptionType.PROCESSING_FAILED, "");
        }

        boolean isSuccess = expectedValue.equals(columnVal.trim());

        if (noOfRetries > 1 && !isSuccess) {
            int retryCnt = 2;
            while (retryCnt <= noOfRetries && !isSuccess) {
                LOGGER.debug("Retrying query...");
                queryResultMap = jdbcSvc.executeSingleRowQueryOnNamedConnection(currentConfigPrefix, expandedSqlQuery);
                isSuccess = expectedValue.equals(queryResultMap.get(columnName.toUpperCase()).trim());
                retryCnt++;
            }
        }


        RefactorSqlMetadata refactorSqlMetadata = this.refactorSQLQuery(expandedSqlQuery);
        if (refactorSqlMetadata.isQueryRefactored()) {
            final String countQuery = refactorSqlMetadata.getRefactoredQuery().replaceFirst("\\*", "COUNT(*) AS CNT");
            try {
                this.executeSqlQueryAssignResultsToVars(countQuery, Collections.singletonList("CNT"));
                if (Integer.parseInt(stateSvc.getStringVar("CNT")) < 20) {
                    String result = jdbcSvc.executeQueryOnNamedConnection(currentConfigPrefix, refactorSqlMetadata.getRefactoredQuery());
                    LOGGER.debug("Refactored Query Data From Table: {}", result);
                }
            } catch (CartException e) {
                //swallow
            }
        }

        if (isSuccess) {
            LOGGER.info("Column [{}] Verification is Successful, Actual Value is [{}]", columnName, columnVal.trim());
        } else {
            LOGGER.error("Verification failed, were expecting column [{}] value to be [{}], but it is [{}]", columnName, expectedValue, columnVal.trim());
            try {
                scenarioUtil.write("Please Check Executed Query => " + expandedSqlQuery);
            } catch (NullPointerException e) {
                //swallow
            }
            throw new CartException(CartExceptionType.VERIFICATION_FAILED, "Verification failed, were expecting column [{}] value to be [{}], but it is [{}]", columnName, expectedValue, columnVal.trim());
        }
    }

    public void executeMultipleQueries(final String sqlQueries) {
        this.executeMultipleQueries(sqlQueries, DEFAULT_QUERY_DELIMITER);
    }

    public void executeMultipleQueries(final String sqlQueries, final String delimiter) {
        List<String> queriesList = sqlStringUtil.splitQueries(sqlQueries, delimiter);
        for (String query : queriesList) {
            final String expandedSqlQuery = stateSvc.expandVar(query);
            LOGGER.debug("Executing Query: [{}]", expandedSqlQuery);
            jdbcSvc.executeOnNamedConnection(this.getCurrentConfigPrefix(), expandedSqlQuery);
        }
    }

    public void exportQueryTableDataToCSVFile(String csvFilePath, String sqlQuery) {
        String fullCSVFilePath = fileDirUtil.addPrefixIfNotAbsolute(stateSvc.expandVar(csvFilePath), workspaceUtil.getBaseDir());
        String expandedSqlQuery = stateSvc.expandVar(sqlQuery);
        jdbcSvc.exportSqlQueryNamedConnectionToCsv(this.getCurrentConfigPrefix(), expandedSqlQuery, fullCSVFilePath);
    }

    public void executePlSqlBlock(final String plSql) {
        jdbcSvc.executePlSqlBlock(this.getCurrentConfigPrefix(), plSql);
    }

    /**
     * If the SQL Query is in the format of (SELECT a,b,c,d FROM e)...ETC. Then this function will replace the content between SELECT and FROM with *
     *
     * @param sqlQuery
     * @return Object[] of size 2. If sqlQuery can be refactored, then Object[0] contains true and Object[1] contains refactored query.
     */
    public RefactorSqlMetadata refactorSQLQuery(final String sqlQuery) {
        RefactorSqlMetadata result = new RefactorSqlMetadata();

        result.setIsQueryRefactored(false);
        result.setRefactoredQuery(sqlQuery);

        try {
            Pattern pattern = Pattern.compile("SELECT (?!CASE)(.*)FROM (.*)", Pattern.CASE_INSENSITIVE | Pattern.MULTILINE | Pattern.DOTALL);
            Matcher matcher = pattern.matcher(sqlQuery);

            if (matcher.matches()) {
                int replaceStartsFrom = "SELECT".length() + 1;
                LOGGER.debug("starting index [{}]", replaceStartsFrom);

                int replaceEndTo = sqlQuery.indexOf(" FROM ");
                pattern = Pattern.compile("(.*)\nFROM (.*)", Pattern.CASE_INSENSITIVE | Pattern.MULTILINE | Pattern.DOTALL);
                matcher = pattern.matcher(sqlQuery);

                if (matcher.matches()) {
                    int replaceEndWithNewLine = sqlQuery.indexOf("FROM ") - 1;
                    replaceEndTo = replaceEndTo < replaceEndWithNewLine ? replaceEndTo : replaceEndWithNewLine;
                }

                LOGGER.debug("ending index [{}]", replaceEndTo);

                StringBuilder sb = new StringBuilder(sqlQuery);
                sb.replace(replaceStartsFrom, replaceEndTo, "*");

                result.setIsQueryRefactored(true);
                result.setRefactoredQuery(sb.toString());
                LOGGER.debug("Refactored Query: [{}]", result.getRefactoredQuery());
            }
        } catch (Exception e) {
            //ignore Exception
        }
        return result;
    }

    public void executeSqlQuerySaveBlobToFile(final String sqlQuery, final String filename) {
        jdbcSvc.executeSqlQuerySaveBlobToFile(this.getCurrentConfigPrefix(), sqlQuery, filename);
    }

    public void loadFlatFileIntoDatabase(final String filepath, final String tableName, final char separator) {
        List<String> columns = Arrays.asList(fileDirUtil.readFileLineToString(filepath, 1).split(Character.toString(separator)));
        jdbcSvc.createTableWithHeader(this.getCurrentConfigPrefix(), columns, tableName);
        jdbcSvc.loadFlatFile(this.getCurrentConfigPrefix(), filepath, tableName, true, separator);
    }


}
