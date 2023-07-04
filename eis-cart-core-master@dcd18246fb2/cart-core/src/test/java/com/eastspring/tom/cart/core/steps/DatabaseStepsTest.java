package com.eastspring.tom.cart.core.steps;

import com.eastspring.tom.cart.core.CartCoreTestConfig;
import com.eastspring.tom.cart.core.CartException;
import com.eastspring.tom.cart.core.svc.DatabaseSvc;
import com.eastspring.tom.cart.core.svc.JdbcSvc;
import com.eastspring.tom.cart.core.svc.StateSvc;
import com.eastspring.tom.cart.core.svc.WorkspaceDirSvc;
import com.eastspring.tom.cart.core.utl.FileDirUtil;
import com.eastspring.tom.cart.core.utl.SqlStringUtil;
import com.eastspring.tom.cart.core.utl.WorkspaceUtil;
import com.eastspring.tom.cart.cst.SqlQueryConstants;
import org.junit.Assert;
import org.junit.Before;
import org.junit.Test;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.Mockito;
import org.mockito.MockitoAnnotations;

import java.util.ArrayList;
import java.util.Arrays;
import java.util.Collections;
import java.util.HashMap;
import java.util.HashSet;
import java.util.List;
import java.util.Map;
import java.util.Set;

import static com.eastspring.tom.cart.core.steps.DatabaseSteps.VERIFICATION_EXPECTED_RESULT;
import static com.eastspring.tom.cart.cst.SqlQueryConstants.VERIFY_MSSQL_SQL_QUERY;
import static org.junit.Assert.assertEquals;
import static org.junit.Assert.assertNotNull;
import static org.junit.Assert.assertTrue;
import static org.mockito.ArgumentMatchers.anyString;
import static org.mockito.ArgumentMatchers.eq;
import static org.mockito.Mockito.times;
import static org.mockito.Mockito.verify;
import static org.mockito.Mockito.when;
import static tomcart.glue.DatabaseStepsDef.DEFAULT_QUERY_DELIMITER;


public class DatabaseStepsTest {

    public static final String NAMED_CONNECTION_1 = "my.named.CONNECTION.1";
    public static final String RESULT_NOT_AS_EXPECTED = "|DIFFERENT_RESULT|\n|5|\n";

    @InjectMocks
    private DatabaseSteps steps;

    @Mock
    private DatabaseSvc databaseSvc;

    @Mock
    private FileDirUtil fileDirUtil;

    @Mock
    private JdbcSvc jdbcSvc;

    @Mock
    private StateSvc stateSvc;

    @Mock
    private WorkspaceUtil workspaceUtil;

    @Mock
    private SqlStringUtil sqlStringUtil;

    @Mock
    private WorkspaceDirSvc workspaceDirSvc;

    @Before
    public void initMocks() {
        MockitoAnnotations.initMocks(this);
        CartCoreTestConfig.configureLogging(DatabaseStepsTest.class);
    }

    @Test
    public void testSetDatabaseConnectionToConfig() throws Exception {
        steps.setDatabaseConnectionToConfig("ABC");
        Mockito.verify(databaseSvc).setDatabaseConnectionToConfig("ABC");
    }

    @Test
    public void testVerifyNamedOracleConnection_resultAsExpected() {
        when(jdbcSvc.executeQueryOnNamedConnection(NAMED_CONNECTION_1, SqlQueryConstants.VERIFY_ORACLE_SQL_QUERY))
                .thenReturn(DatabaseSteps.VERIFICATION_EXPECTED_RESULT);
        steps.verifyNamedOracleConnection(NAMED_CONNECTION_1);
    }

    @Test
    public void testVerifyNamedOracleConnection_nullResult() {
        when(jdbcSvc.executeQueryOnNamedConnection(NAMED_CONNECTION_1, SqlQueryConstants.VERIFY_ORACLE_SQL_QUERY))
                .thenReturn(null);
        Exception exceptionThrown = null;
        try {
            steps.verifyNamedOracleConnection(NAMED_CONNECTION_1);
        } catch (CartException e) {
            exceptionThrown = e;
        }
        assertNotNull(exceptionThrown);
        Assert.assertTrue(exceptionThrown instanceof CartException);
        Assert.assertEquals("connection validation query failed", exceptionThrown.getMessage());
    }

    @Test
    public void testVerifyNamedOracleConnection_resultNotAsExpected() {
        when(jdbcSvc.executeQueryOnNamedConnection(NAMED_CONNECTION_1, SqlQueryConstants.VERIFY_ORACLE_SQL_QUERY))
                .thenReturn(RESULT_NOT_AS_EXPECTED);
        Exception exceptionThrown = null;
        try {
            steps.verifyNamedOracleConnection(NAMED_CONNECTION_1);
        } catch (CartException e) {
            exceptionThrown = e;
        }
        assertNotNull(exceptionThrown);
        Assert.assertTrue(exceptionThrown instanceof CartException);
        Assert.assertEquals("connection validation query failed", exceptionThrown.getMessage());
    }

    @Test
    public void testVerifyNamedSQLServerConnection_success() throws Exception {
        when(jdbcSvc.executeQueryOnNamedConnection("ABC", VERIFY_MSSQL_SQL_QUERY)).thenReturn(VERIFICATION_EXPECTED_RESULT);
        steps.verifyNamedSQLServerConnection("ABC");
        verify(jdbcSvc).executeQueryOnNamedConnection("ABC", VERIFY_MSSQL_SQL_QUERY);
    }

    @Test
    public void testVerifyNamedSQLServerConnection_nullResult() throws Exception {
        when(jdbcSvc.executeQueryOnNamedConnection("ABC", VERIFY_MSSQL_SQL_QUERY)).thenReturn(null);
        Exception thrown = null;
        try {
            steps.verifyNamedSQLServerConnection("ABC");
        } catch (Exception e) {
            thrown = e;
        }
        assertNotNull(thrown);
        assertTrue(thrown instanceof CartException);
        assertEquals("connection validation query failed", thrown.getMessage());
        verify(jdbcSvc).executeQueryOnNamedConnection("ABC", VERIFY_MSSQL_SQL_QUERY);
    }

    @Test
    public void testVerifyNamedSQLServerConnection_resultNotAsExpected() throws Exception {
        when(jdbcSvc.executeQueryOnNamedConnection("ABC", VERIFY_MSSQL_SQL_QUERY)).thenReturn(RESULT_NOT_AS_EXPECTED);
        Exception thrown = null;
        try {
            steps.verifyNamedSQLServerConnection("ABC");
        } catch (Exception e) {
            thrown = e;
        }
        assertNotNull(thrown);
        assertTrue(thrown instanceof CartException);
        assertEquals("connection validation query failed", thrown.getMessage());
        verify(jdbcSvc).executeQueryOnNamedConnection("ABC", VERIFY_MSSQL_SQL_QUERY);
    }

    @Test
    public void testPollUnitlMaxTimeVerifySqlResult() throws Exception {
        steps.pollUntilMaxTimeVerifySqlResult(20, "XYZ", "SELECT abc FROM def WHERE ghi='jkl'");
        verify(databaseSvc).pollUntilMaxTimeVerifySqlResult(20, "XYZ", "SELECT abc FROM def WHERE ghi='jkl'");
    }

    @Test
    public void testInvokeSqlStoredProcedure() throws Exception {
        List<String> inParams = new ArrayList<String>() {{
            add("abc");
            add("DEF");
        }};
        List<String> outParams = new ArrayList<>();
        steps.invokeSqlStoredProcedure("INTERNAL.CONN", "my_sp_name", inParams, outParams);
        verify(jdbcSvc).executeStoredProcedureOnNamedConnection("INTERNAL.CONN", "my_sp_name", inParams, outParams);
    }

    @Test
    public void testExpectRecordsInTableWithQuery_haveRecords() throws Exception {
        when(databaseSvc.executeSingleValueQueryOnNamedConnection("SELECT 5 FROM DUAL")).thenReturn("5");
        steps.expectRecordsInTableWithQuery("SELECT 5 FROM DUAL");
    }

    @Test(expected = CartException.class)
    public void testExpectRecordsInTableWithQuery_noRecords() throws Exception {
        when(databaseSvc.executeSingleValueQueryOnNamedConnection("SELECT * FROM emptytable")).thenReturn("0");
        steps.expectRecordsInTableWithQuery("SELECT * FROM emptytable");
    }

    @Test
    public void testExecuteQueryAndExtractValues() throws Exception {
        List<String> columns = Arrays.asList("p", "q", "r");
        steps.executeQueryAndExtractValues("SELECT * FROM b WHERE c=d", columns);
        verify(databaseSvc, times(1)).executeSqlQueryAssignResultsToVars("SELECT * FROM b WHERE c=d", columns);
    }

    @Test
    public void testExportTableToCSVFile() throws Exception {
        steps.exportTableToCSVFile("/tmp/abc.csv", "SELECT a FROM b WHERE c=d");
        verify(databaseSvc, times(1)).exportQueryTableDataToCSVFile("/tmp/abc.csv", "SELECT a FROM b WHERE c=d");
    }

    @Test
    public void testVerifySqlResultOfColumn_sqlString_dotSql() throws Exception {
        when(stateSvc.expandVar("test.sql")).thenReturn("/tmp/abc/test.sql");
        when(stateSvc.expandVar("ValueExpected")).thenReturn("ValueExpected");

        when(workspaceDirSvc.normalize(anyString())).thenReturn("/tmp/abc/test.sql");
        when(fileDirUtil.readFileToString("/tmp/abc/test.sql")).thenReturn("SELECT a FROM b WHERE c=d");

        steps.iExpectValueOfColumnShouldMatch("abc", "ValueExpected", "test.sql");
        verify(databaseSvc, times(1)).verifySqlResultOfColumn("abc", "ValueExpected", "SELECT a FROM b WHERE c=d", 1);
    }

    @Test
    public void testVerifySqlResultOfColumn_sqlString_directString() throws Exception {
        when(stateSvc.expandVar("ValueExpected")).thenReturn("ValueExpected");
        steps.iExpectValueOfColumnShouldMatch("abc", "ValueExpected", "SELECT a FROM b WHERE c=d");
        verify(databaseSvc, times(1)).verifySqlResultOfColumn("abc", "ValueExpected", "SELECT a FROM b WHERE c=d", 1);
    }

    @Test
    public void testVerifySqlResultOfColumn_mapValue() throws Exception {
        Set<String> setOfColumns = new HashSet<>();
        setOfColumns.add("col1");
        setOfColumns.add("col2");
        Map<String, String> columnQueryMap = new HashMap<>();
        columnQueryMap.put("col1", "SELECT 1 FROM DUAL");
        columnQueryMap.put("col2", "SELECT 2 FROM DUAL");
        when(stateSvc.expandVar("expectedValue")).thenReturn("expectedValue");
        steps.iExpectValueOfColumnShouldMatch("expectedValue", columnQueryMap);
        verify(databaseSvc, times(1)).verifySqlResultOfColumn("col1", "expectedValue", "SELECT 1 FROM DUAL", 1);
        verify(databaseSvc, times(1)).verifySqlResultOfColumn("col2", "expectedValue", "SELECT 2 FROM DUAL", 1);
    }

    @Test
    public void testVerifySqlResultOfColumn_mapValue_dotSql() throws Exception {
        Set<String> setOfColumns = new HashSet<>();
        setOfColumns.add("col1");
        Map<String, String> columnQueryMap = new HashMap<>();
        columnQueryMap.put("col1", "test.sql");

        when(stateSvc.expandVar("test.sql")).thenReturn("test.sql");
        when(workspaceDirSvc.normalize(anyString())).thenReturn("/basedir/test.sql");

        when(fileDirUtil.readFileToString("/basedir/test.sql")).thenReturn("SELECT 1 FROM DUAL");
        when(stateSvc.expandVar("expectedValue")).thenReturn("expectedValue");

        steps.iExpectValueOfColumnShouldMatch("expectedValue", columnQueryMap);

        verify(databaseSvc, times(1)).verifySqlResultOfColumn("col1", "expectedValue", "SELECT 1 FROM DUAL", 1);
    }

    @Test
    public void testExecuteQueryAndExtractValues1_directSql() {
        List<String> listOfColumns = Arrays.asList("column1", "column2");
        steps.executeQueryAndExtractValues("SELECT 1 FROM DUAL", listOfColumns);
        verify(databaseSvc, times(1)).executeSqlQueryAssignResultsToVars("SELECT 1 FROM DUAL", listOfColumns);
    }

    @Test
    public void testExecuteQueryAndExtractValues_sqlInFile() {
        List<String> listOfColumns = Arrays.asList("column1", "column2");

        when(stateSvc.expandVar("filename.sql")).thenReturn("filename.sql");

        when(workspaceDirSvc.normalize(anyString())).thenReturn("./filename.sql");
        when(fileDirUtil.readFileToString("./filename.sql")).thenReturn("SELECT 1 FROM DUAL");

        steps.executeQueryAndExtractValues("filename.sql", listOfColumns);
        verify(databaseSvc, times(1)).executeSqlQueryAssignResultsToVars("SELECT 1 FROM DUAL", listOfColumns);
    }

    @Test
    public void testExecuteQuery_singleSqlQuery() {
        when(sqlStringUtil.splitQueries("SELECT 1 FROM DUAL", DEFAULT_QUERY_DELIMITER)).thenReturn(Collections.singletonList("SELECT 1 FROM DUAL"));
        steps.executeMultipleSqls("SELECT 1 FROM DUAL", DEFAULT_QUERY_DELIMITER);
        verify(databaseSvc, times(1)).executeMultipleQueries("SELECT 1 FROM DUAL", DEFAULT_QUERY_DELIMITER);
    }

    @Test
    public void testExecuteQuery_multipleSqlQueries() {
        String queries = "SELECT 1 FROM DUAL;SELECT 2 FROM DUAL;SELECT 3 FROM DUAL";
        when(sqlStringUtil.splitQueries(queries, DEFAULT_QUERY_DELIMITER)).thenReturn(Arrays.asList("SELECT 1 FROM DUAL", "SELECT 2 FROM DUAL", "SELECT 3 FROM DUAL"));
        steps.executeMultipleSqls(queries, DEFAULT_QUERY_DELIMITER);
        verify(databaseSvc, times(3)).executeMultipleQueries(anyString(), eq(DEFAULT_QUERY_DELIMITER));
    }

    @Test
    public void testExecuteQuery_multipleSqlFiles() throws Exception {

        when(databaseSvc.getCurrentConfigPrefix()).thenReturn("db.config");

        when(stateSvc.expandVar(anyString()))
                .thenReturn("insert.sql")
                .thenReturn("update.sql");

        when(workspaceDirSvc.normalize(anyString())).thenReturn("insert.sql").thenReturn("update.sql");

        when(fileDirUtil.readFileToString(anyString()))
                .thenReturn("insert query1;insert query2")
                .thenReturn("update query");

        String queries = "insert.sql;update.sql;delete plain query";
        when(sqlStringUtil.splitQueries(queries, DEFAULT_QUERY_DELIMITER)).thenReturn(Arrays.asList("insert.sql", "update.sql", "delete plain query"));

        steps.executeMultipleSqls(queries, DEFAULT_QUERY_DELIMITER);

        verify(databaseSvc, times(1)).executeMultipleQueries("insert query1;insert query2", DEFAULT_QUERY_DELIMITER);
        verify(databaseSvc, times(1)).executeMultipleQueries("update query", DEFAULT_QUERY_DELIMITER);
        verify(databaseSvc, times(1)).executeMultipleQueries("delete plain query", DEFAULT_QUERY_DELIMITER);
    }

    @Test
    public void testExecuteQuery_multipleSqlFiles_withDelimiter() throws Exception {

        when(databaseSvc.getCurrentConfigPrefix()).thenReturn("db.config");

        when(stateSvc.expandVar(anyString()))
                .thenReturn("insert.sql")
                .thenReturn("update.sql");

        when(workspaceDirSvc.normalize(anyString())).thenReturn("insert.sql").thenReturn("update.sql");

        when(fileDirUtil.readFileToString(anyString()))
                .thenReturn("insert query1 ### insert query2")
                .thenReturn("update query");

        String queries = "insert.sql ### update.sql ### delete plain query";
        String delimiter = "###";
        when(sqlStringUtil.splitQueries(queries, delimiter)).thenReturn(Arrays.asList("insert.sql", "update.sql", "delete plain query"));

        steps.executeMultipleSqls(queries, delimiter);

        verify(databaseSvc, times(1)).executeMultipleQueries("insert query1 ### insert query2", delimiter);
        verify(databaseSvc, times(1)).executeMultipleQueries("update query", delimiter);
        verify(databaseSvc, times(1)).executeMultipleQueries("delete plain query", delimiter);
    }

    @Test
    public void testIExpectValueOfColumnShouldMatchWithinRetries() {
        when(stateSvc.expandVar("ValueExpected")).thenReturn("ValueExpected");
        steps.iExpectValueOfColumnShouldMatchWithinRetries("abc", "ValueExpected", 3, "SELECT a FROM b WHERE c=d");
        verify(databaseSvc, times(1)).verifySqlResultOfColumn("abc", "ValueExpected", "SELECT a FROM b WHERE c=d", 3);

    }
}
