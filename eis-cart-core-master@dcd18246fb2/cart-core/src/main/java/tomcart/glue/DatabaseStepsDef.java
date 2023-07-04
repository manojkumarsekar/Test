package tomcart.glue;

import com.eastspring.tom.cart.core.CartBootstrap;
import com.eastspring.tom.cart.core.steps.DatabaseSteps;
import com.eastspring.tom.cart.core.utl.DataTableUtil;
import cucumber.api.java8.En;
import io.cucumber.datatable.DataTable;

import java.util.Arrays;
import java.util.List;
import java.util.Map;
import java.util.stream.Collectors;

/**
 * @author Daniel Baktiar
 * @since 2017-09
 */
public class DatabaseStepsDef implements En {

    private DatabaseSteps dbSteps = (DatabaseSteps) CartBootstrap.getBean(DatabaseSteps.class);
    private DataTableUtil dataTableUtil = (DataTableUtil) CartBootstrap.getBean(DataTableUtil.class);

    public static final String DEFAULT_QUERY_DELIMITER = ";";

    public DatabaseStepsDef() {
        Then("I expect to be able to connect to Oracle database with named connection {string}", (String connectionName) -> dbSteps.verifyNamedOracleConnection(connectionName));

        Given("I set the database connection to configuration {string}", (String dbConfigPrefix) -> dbSteps.setDatabaseConnectionToConfig(dbConfigPrefix));

        Given("I reset the database connection with configuration {string}", (String dbConfigPrefix) -> dbSteps.resetDatabaseConnectionWithConfig(dbConfigPrefix));

        Then("I expect to be able to connect to SQL Server database with named connection {string}", (String connectionName) -> dbSteps.verifyNamedSQLServerConnection(connectionName));

        Then("I poll for maximum {int} seconds and expect the result of the SQL query below equals to {string}:", (Integer maxPollTime, String expected, String sqlQuery) ->
                dbSteps.pollUntilMaxTimeVerifySqlResult(maxPollTime, expected, sqlQuery));

        Then("I invoke SQL stored procedure {string} on named connection {string} with these parameters:", (String spName, String connName, DataTable dataTable) -> {
            Map<String, String> map = dataTableUtil.getTwoColumnAsMap(dataTable);

            List<String> inParams = map.entrySet().stream()
                    .filter(val -> val.getValue().equalsIgnoreCase("IN"))
                    .map(Map.Entry::getKey)
                    .collect(Collectors.toList());

            List<String> outParams = map.entrySet().stream()
                    .filter(val -> val.getValue().equalsIgnoreCase("OUT"))
                    .map(Map.Entry::getKey)
                    .collect(Collectors.toList());

            dbSteps.invokeSqlStoredProcedure(connName, spName, inParams, outParams);
        });


        Then("I expect value of column {string} in the below SQL query equals to {string}:",
                (String columnName, String expectedResult, String multiLineSqlQuery) ->
                        dbSteps.iExpectValueOfColumnShouldMatch(columnName, expectedResult, multiLineSqlQuery)
        );

        Then("I expect value of column {string} in the below SQL query equals to {string} with {int} retries:",
                (String columnName, String expectedResult, Integer noOfRetries, String multiLineSqlQuery) ->
                        dbSteps.iExpectValueOfColumnShouldMatchWithinRetries(columnName, expectedResult, noOfRetries, multiLineSqlQuery)
        );

        Then("I expect value of column in the below SQL query equals to {string}",
                (String expectedResult, DataTable columnQueryDataTable) -> {
                    Map<String, String> columnQueryMap = dataTableUtil.getTwoColumnAsMap(columnQueryDataTable);
                    dbSteps.iExpectValueOfColumnShouldMatch(expectedResult, columnQueryMap);
                });

        Then("I expect records should be present in table as per below query:", (String sqlQuery) -> dbSteps.expectRecordsInTableWithQuery(sqlQuery));

        Then("I execute query {string} and extract values of {string} into same variables", (String sqlQuery, String colonSeperatedColumns) -> {
            List<String> listOfColumns = Arrays.asList(colonSeperatedColumns.split(";"));
            dbSteps.executeQueryAndExtractValues(sqlQuery, listOfColumns);
        });

        Then("I execute below query and extract values of {string} into same variables", (String colonSeperatedColumns, String multiLineQuery) -> {
            List<String> listOfColumns = Arrays.asList(colonSeperatedColumns.split(";"));
            dbSteps.executeQueryAndExtractValues(multiLineQuery, listOfColumns);
        });

        Then("I execute below query and extract values of {string} column into incremental variables", (String columnName, String multiLineQuery) -> {
            dbSteps.executeQueryAndExtractValues(multiLineQuery, columnName);
        });

        Then("I execute below PLSQL block to{}", (String information, String plSqlBlock) -> dbSteps.executePlSqlBlock(plSqlBlock));

        Then("I execute below (query|queries)", (String multiLineQuery) -> dbSteps.executeMultipleSqls(multiLineQuery, DEFAULT_QUERY_DELIMITER));

        Then("I execute below (query|queries) to{}", (String information, String multiLineQuery) -> dbSteps.executeMultipleSqls(multiLineQuery, DEFAULT_QUERY_DELIMITER));

        Then("I execute below queries which are separated by {string}", (String separator, String multiLineQuery) -> dbSteps.executeMultipleSqls(multiLineQuery, separator));

        Given("I export below sql query results to CSV file {string}", (String csvFilePath, String multiLineSqlQuery) -> dbSteps.exportTableToCSVFile(csvFilePath, multiLineSqlQuery));

        When("I save binaries to a file {string} with below query:", (String filename, String multilineQuery) -> dbSteps.saveBlobToFile(multilineQuery, filename));

        Then("I connect to reconciliations database", () -> dbSteps.connectToReconDatabase("recon"));

        Given("I upload {string} file as a table {string} into recon database", (String filepath, String tableName) -> dbSteps.importFlatFileIntoDatabase(filepath, tableName));
    }
}
