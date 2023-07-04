package com.eastspring.tom.cart.core.svc;

import com.eastspring.tom.cart.core.CartCoreTestConfig;
import com.eastspring.tom.cart.core.CartException;
import com.eastspring.tom.cart.core.utl.FormatterUtil;
import com.eastspring.tom.cart.core.utl.SqlStringUtil;
import org.junit.Assert;
import org.junit.Before;
import org.junit.Test;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.MockitoAnnotations;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import java.util.ArrayList;
import java.util.Arrays;
import java.util.List;

import static org.mockito.Mockito.when;

public class JdbcSvcTest {
    private static final Logger LOGGER = LoggerFactory.getLogger(JdbcSvcTest.class);

    public static final String CONNECTION_NAME = "com.eastspring.tom.db.myconnection";

    @InjectMocks
    private JdbcSvc jdbcSvc;

    @Mock
    private StateSvc stateSvc;

    @Mock
    private SqlStringUtil sqlStringUtil;

    @Before
    public void initMocks() {
        MockitoAnnotations.initMocks(this);
        CartCoreTestConfig.configureLogging(JdbcSvcTest.class);
        when(stateSvc.getStringVar("com.eastspring.tom.db.myconnection.type")).thenReturn("jdbc_a");
        when(stateSvc.getStringVar("com.eastspring.tom.db.myconnection.jdbc.url")).thenReturn("jdbc:h2:mem:");
        when(stateSvc.getStringVar("com.eastspring.tom.db.myconnection.jdbc.class")).thenReturn("org.h2.Driver");
        when(stateSvc.getStringVar("com.eastspring.tom.db.myconnection.jdbc.user")).thenReturn("sa");
        when(stateSvc.getStringVar("com.eastspring.tom.db.myconnection.jdbc.pass")).thenReturn("");
        when(stateSvc.getStringVar("com.eastspring.tom.db.myconnection.jdbc.description")).thenReturn("H2 Database Connection");
    }

    public static final String CONN_NAME = "TOM_DEV1";


    @Test
    public void testCreateNamedConnection_success() {
        Throwable exceptionThrown = null;
        try {
            jdbcSvc.createNamedConnection(CONNECTION_NAME);
            jdbcSvc.createNamedConnection(CONNECTION_NAME);
        } catch (Throwable t) {
            exceptionThrown = t;
        }
        Assert.assertNull(exceptionThrown);
    }

    @Test
    public void testCreateNamedConnection_driverClassNotFound() {
        when(stateSvc.getStringVar("com.eastspring.tom.db.myconnection.type")).thenReturn("jdbc_a");
        when(stateSvc.getStringVar("com.eastspring.tom.db.myconnection.jdbc.url")).thenReturn("jdbc:h2:mem:");
        when(stateSvc.getStringVar("com.eastspring.tom.db.myconnection.jdbc.class")).thenReturn("org.h2.RandomWrongDriver");
        when(stateSvc.getStringVar("com.eastspring.tom.db.myconnection.jdbc.user")).thenReturn("sa");
        when(stateSvc.getStringVar("com.eastspring.tom.db.myconnection.jdbc.pass")).thenReturn("");
        when(stateSvc.getStringVar("com.eastspring.tom.db.myconnection.jdbc.description")).thenReturn("H2 Database Connection");
        Throwable exceptionThrown = null;
        try {
            jdbcSvc.createNamedConnection(CONNECTION_NAME);
        } catch (Throwable t) {
            exceptionThrown = t;
        }
        Assert.assertNotNull(exceptionThrown);
        Assert.assertEquals(CartException.class, exceptionThrown.getClass());
        Assert.assertEquals("jdbc driver class [org.h2.RandomWrongDriver] not found in classpath; either provide the correct driver class name or provide the driver in the classpath", exceptionThrown.getMessage());
    }

    @Test
    public void testCreateNamedConnection_failedToCreateConnection() {
        when(stateSvc.getStringVar("com.eastspring.tom.db.myconnection.type")).thenReturn("jdbc_a");
        when(stateSvc.getStringVar("com.eastspring.tom.db.myconnection.jdbc.url")).thenReturn("jdbc:h2:3mem:");
        when(stateSvc.getStringVar("com.eastspring.tom.db.myconnection.jdbc.class")).thenReturn("org.h2.Driver");
        when(stateSvc.getStringVar("com.eastspring.tom.db.myconnection.jdbc.user")).thenReturn("sa");
        when(stateSvc.getStringVar("com.eastspring.tom.db.myconnection.jdbc.pass")).thenReturn("");
        when(stateSvc.getStringVar("com.eastspring.tom.db.myconnection.jdbc.description")).thenReturn("H2 Database Connection");
        Throwable exceptionThrown = null;
        try {
            jdbcSvc.createNamedConnection(CONNECTION_NAME);
        } catch (Throwable t) {
            exceptionThrown = t;
        }
        Assert.assertNotNull(exceptionThrown);
        Assert.assertEquals(CartException.class, exceptionThrown.getClass());
        Assert.assertEquals("failed to create connection", exceptionThrown.getMessage());
    }

    @Test
    public void testCreateNamedConnection_unknownType() {
        when(stateSvc.getStringVar("com.eastspring.tom.db.myconnection.type")).thenReturn("something_else");
        Throwable exceptionThrown = null;
        try {
            jdbcSvc.createNamedConnection(CONNECTION_NAME);
        } catch (Throwable t) {
            exceptionThrown = t;
        }
        Assert.assertNotNull(exceptionThrown);
        Assert.assertEquals(CartException.class, exceptionThrown.getClass());
        Assert.assertEquals("unsupported connection type [something_else]", exceptionThrown.getMessage());
    }

    @Test
    public void testExecuteOnNamedConnection_success() {
        Throwable exceptionThrown = null;
        try {
            jdbcSvc.createNamedConnection("com.eastspring.tom.db.myconnection");
            jdbcSvc.executeOnNamedConnection("com.eastspring.tom.db.myconnection", "CREATE TABLE abc (name varchar(20))");
        } catch (Throwable t) {
            t.printStackTrace();
            exceptionThrown = t;
        }
        Assert.assertNull(exceptionThrown);
    }

    @Test
    public void testExecuteOnNamedConnection_connectionNotCreated() {
        Throwable exceptionThrown = null;
        try {
            jdbcSvc.executeOnNamedConnection("com.eastspring.tom.db.myconnection", "CREATE TABLE abc (name varchar(20))");
        } catch (Throwable t) {
            exceptionThrown = t;
        }
        Assert.assertNotNull(exceptionThrown);
        Assert.assertEquals(CartException.class, exceptionThrown.getClass());
        Assert.assertEquals("named connection [com.eastspring.tom.db.myconnection] is null, probably it has not been created?", exceptionThrown.getMessage());
    }


    @Test
    public void testExecuteQueryOnNamedConnection_success() {
        Throwable exceptionThrown = null;
        String result = null;
        try {
            jdbcSvc.createNamedConnection("com.eastspring.tom.db.myconnection");
            jdbcSvc.executeOnNamedConnection("com.eastspring.tom.db.myconnection", "CREATE TABLE abc (name varchar(20))");
            jdbcSvc.executeOnNamedConnection("com.eastspring.tom.db.myconnection", "INSERT INTO abc (name) VALUES ('john doe')");
            result = jdbcSvc.executeQueryOnNamedConnection("com.eastspring.tom.db.myconnection", "SELECT name FROM abc");
        } catch (Throwable t) {
            t.printStackTrace();
            exceptionThrown = t;
        }
        Assert.assertNull(exceptionThrown);
        Assert.assertNotNull(result);
        Assert.assertEquals("|NAME|\n|john doe|\n", result);
    }

    @Test
    public void testExecuteQueryOnNamedConnection_connectionNotCreated() {
        Throwable exceptionThrown = null;
        try {
            jdbcSvc.executeQueryOnNamedConnection("com.eastspring.tom.db.myconnection", "CREATE TABLE abc (name varchar(20))");
        } catch (Throwable t) {
            exceptionThrown = t;
        }
        Assert.assertNotNull(exceptionThrown);
        Assert.assertEquals(CartException.class, exceptionThrown.getClass());
        Assert.assertEquals("named connection [com.eastspring.tom.db.myconnection] is null, probably it has not been created?", exceptionThrown.getMessage());
    }

    @Test
    public void testNewReconciliationMethod() {
        // TODO: leverage on this for reconciliation
        JdbcSvc jdbcSvc = new JdbcSvc();
        FormatterUtil formatterUtil = new FormatterUtil();
        SqlStringUtil stringUtil = new SqlStringUtil();
        String csvFilename = "myfile.csv";
        String tableName1 = "BASELINE_TABLE";
        String tableName2 = "TARGET_TABLE";
        String expectedFinalResult = "CALL CSVWRITE('myfile.csv', 'SELECT a.SEQ_ID, a.NAME, a.PORTFOLIO_ID, a.MONTHLY_AMOUNT, a.DESCRIPTION FROM BASELINE_TABLE a LEFT JOIN TARGET_TABLE b ON a.NAME=b.NAME AND a.PORTFOLIO_ID=b.PORTFOLIO_ID WHERE b.NAME IS NULL', 'charset=UTF-8 fieldSeparator=,')";
        List<String> columnList = Arrays.asList("SEQ_ID", "NAME", "PORTFOLIO_ID", "MONTHLY_AMOUNT", "DESCRIPTION");
        List<String> keyColumnList = Arrays.asList("NAME", "PORTFOLIO_ID");

        StringBuilder formatterSb = new StringBuilder("CALL CSVWRITE('%s', 'SELECT ");
        formatterSb.append(stringUtil.zipJoin(columnList, ", ", "a.", ""));
        formatterSb.append(" FROM %s a LEFT JOIN %s b ON ");
        formatterSb.append(stringUtil.zipJoinJoinClause(keyColumnList, "a", "b"));
        formatterSb.append(" WHERE b.");
        formatterSb.append(keyColumnList.get(0));
        formatterSb.append(" IS NULL', 'charset=UTF-8 fieldSeparator=,')");
        LOGGER.debug("formatter: {}", formatterSb.toString());
        String sqlStmt = formatterUtil.format("CALL CSVWRITE('%s', 'SELECT a.SEQ_ID, a.NAME, a.PORTFOLIO_ID, a.MONTHLY_AMOUNT, a.DESCRIPTION FROM %s a LEFT JOIN %s b ON a.NAME=b.NAME AND a.PORTFOLIO_ID=b.PORTFOLIO_ID WHERE b.NAME IS NULL', 'charset=UTF-8 fieldSeparator=,')", csvFilename, tableName1, tableName2);
        LOGGER.debug("sqlStmt: {}", sqlStmt);
        String secondSql = formatterUtil.format(formatterSb.toString(), csvFilename, tableName1, tableName2);
        Assert.assertEquals(expectedFinalResult, secondSql);
    }

    @Test
    public void testExecuteStoredProcedureOnNamedConnection_nullConnectionName() {
        String spCommand = "SP_COMMAND";
        List<String> inParams = Arrays.asList("abc", "def");
        List<String> outParams = new ArrayList<>();

        Exception thrownException = null;
        try {
            jdbcSvc.executeStoredProcedureOnNamedConnection(null, spCommand, inParams, outParams);
        } catch (Exception e) {
            thrownException = e;
        }
        Assert.assertNotNull(thrownException);
        Assert.assertTrue(thrownException instanceof CartException);
        Assert.assertEquals("named connection [null] is null, probably it has not been created?", thrownException.getMessage());
    }

    @Test
    public void testExecuteStoredProcedureOnNamedConnection_connectionReturnedIsNull() {
        String connectionName = "connection.name";
        String spCommand = "SP_COMMAND";
        List<String> inParams = Arrays.asList("abc", "def");
        List<String> outParams = new ArrayList<>();
        Exception thrownException = null;
        try {
            jdbcSvc.executeStoredProcedureOnNamedConnection(connectionName, spCommand, inParams, outParams);
        } catch (Exception e) {
            thrownException = e;
        }
        Assert.assertNotNull(thrownException);
        Assert.assertTrue(thrownException instanceof CartException);
        Assert.assertEquals("named connection [connection.name] is null, probably it has not been created?", thrownException.getMessage());
    }

    //    @Test
    // TODO: fix this test
    public void testExecuteStoredProcedureOnNamedConnection_callable() {
        String connectionName = "connection.name";
        String spCommand = "SP_COMMAND";
        List<String> inParams = Arrays.asList("abc", "def");
        List<String> outParams = new ArrayList<>();
        when(stateSvc.getStringVar("connection.name.type")).thenReturn("jdbc_a");
        when(stateSvc.getStringVar("connection.name.jdbc.url")).thenReturn("jdbc:h2:mem:");
        when(stateSvc.getStringVar("connection.name.jdbc.class")).thenReturn("org.h2.Driver");
        when(stateSvc.getStringVar("connection.name.jdbc.user")).thenReturn("sa");
        when(stateSvc.getStringVar("connection.name.jdbc.pass")).thenReturn("");
        when(stateSvc.getStringVar("connection.name.jdbc.description")).thenReturn("my_jdbc_description");
        String callableStatement = "{call SP_COMMAND ('abc', 'def')}";
        when(sqlStringUtil.getPreparedCallableStatementWithParams(spCommand, inParams.size())).thenReturn(callableStatement);

        Exception thrownException = null;
        try {
            jdbcSvc.createNamedConnection(connectionName);
            jdbcSvc.executeStoredProcedureOnNamedConnection(connectionName, spCommand, inParams, outParams);
        } catch (Exception e) {
            thrownException = e;
        }

        Assert.assertNotNull(thrownException);
        Assert.assertTrue(thrownException instanceof CartException);
        Assert.assertEquals("unsupported connection type [null]", thrownException.getMessage());
    }

}
