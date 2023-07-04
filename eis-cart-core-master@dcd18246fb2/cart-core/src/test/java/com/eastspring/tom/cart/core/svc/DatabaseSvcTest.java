package com.eastspring.tom.cart.core.svc;

import com.eastspring.tom.cart.core.CartCoreTestConfig;
import com.eastspring.tom.cart.core.CartException;
import org.joda.time.DateTimeUtils;
import org.junit.Assert;
import org.junit.Before;
import org.junit.BeforeClass;
import org.junit.Rule;
import org.junit.Test;
import org.junit.rules.ExpectedException;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.MockitoAnnotations;

import java.util.Arrays;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import static org.mockito.Mockito.anyString;
import static org.mockito.Mockito.doNothing;
import static org.mockito.Mockito.times;
import static org.mockito.Mockito.verify;
import static org.mockito.Mockito.when;

public class DatabaseSvcTest {
    public static final String VAR_PREFIX = "com.eastspring.tom.prefix.";
    public static final String SQL_QUERY = "SELECT a, b, c FROM x WHERE x.a = '${my.predefined.string}'";
    public static final String SQL_QUERY_EXPANDED = "SELECT a, b, c FROM x WHERE x.a = 'pqr'";
    public static final String DB_CONFIG_NAME = "myconfig";
    public static final Map<String, String> RESULT_MAP = new HashMap<String, String>() {{
        put("var1", "value1");
        put("var591", "value591");
        put("johnny", "doe");
    }};
    public static final Map<String, String> SINGLE_VALUE_RESULT_MAP = new HashMap<String, String>() {{
        put("var1", "value1");
    }};
    public static final Map<String, String> EMPTY_MAP = new HashMap<>();

    @InjectMocks
    private DatabaseSvc databaseSvc;

    @Rule
    public ExpectedException thrown = ExpectedException.none();

    @Mock
    private JdbcSvc jdbcSvc;

    @Mock
    private StateSvc stateSvc;

    @Before
    public void initMocks() {
        MockitoAnnotations.initMocks(this);
    }

    @BeforeClass
    public static void setUpClass() {
        CartCoreTestConfig.configureLogging(DatabaseSvcTest.class);
    }

    @Test
    public void testExecuteSqlQueryAssignResultsToVarsWithPrefix_success_multiRows() {
        when(stateSvc.expandVar(SQL_QUERY)).thenReturn(SQL_QUERY_EXPANDED);
        when(jdbcSvc.executeSingleRowQueryOnNamedConnection(DB_CONFIG_NAME, SQL_QUERY_EXPANDED)).thenReturn(RESULT_MAP);

        databaseSvc.setDatabaseConnectionToConfig(DB_CONFIG_NAME);
        databaseSvc.executeSqlQueryAssignResultsToVarsWithPrefix(VAR_PREFIX, SQL_QUERY);

        verify(stateSvc).setStringVar("com.eastspring.tom.prefix.var1", "value1");
        verify(stateSvc).setStringVar("com.eastspring.tom.prefix.var591", "value591");
        verify(stateSvc).setStringVar("com.eastspring.tom.prefix.johnny", "doe");
    }

    @Test
    public void testExecuteSqlQueryAssignResultsToVarsWithPrefix_success_emptyRows() {
        when(stateSvc.expandVar(SQL_QUERY)).thenReturn(SQL_QUERY_EXPANDED);
        when(jdbcSvc.executeSingleRowQueryOnNamedConnection(DB_CONFIG_NAME, SQL_QUERY_EXPANDED)).thenReturn(EMPTY_MAP);

        databaseSvc.setDatabaseConnectionToConfig(DB_CONFIG_NAME);
        databaseSvc.executeSqlQueryAssignResultsToVarsWithPrefix(VAR_PREFIX, SQL_QUERY);
    }

    @Test
    public void testExecuteSingleValueQueryOnNamedConnection_success() {
        when(stateSvc.expandVar(SQL_QUERY)).thenReturn(SQL_QUERY_EXPANDED);
        when(jdbcSvc.executeSingleRowQueryOnNamedConnection(DB_CONFIG_NAME, SQL_QUERY_EXPANDED)).thenReturn(SINGLE_VALUE_RESULT_MAP);

        databaseSvc.setDatabaseConnectionToConfig(DB_CONFIG_NAME);
        String result = databaseSvc.executeSingleValueQueryOnNamedConnection(SQL_QUERY);

        Assert.assertEquals("value1", result);
    }

    @Test
    public void testExecuteSingleValueQueryOnNamedConnection_success_empty() {
        when(stateSvc.expandVar(SQL_QUERY)).thenReturn(SQL_QUERY_EXPANDED);
        when(jdbcSvc.executeSingleRowQueryOnNamedConnection(DB_CONFIG_NAME, SQL_QUERY_EXPANDED)).thenReturn(EMPTY_MAP);

        databaseSvc.setDatabaseConnectionToConfig(DB_CONFIG_NAME);
        String result = databaseSvc.executeSingleValueQueryOnNamedConnection(SQL_QUERY);

        Assert.assertNull(result);
    }

    private class TestMillisProvider implements DateTimeUtils.MillisProvider {
        private long millis;

        public void setMillis(long millis) {
            this.millis = millis;
        }

        @Override
        public long getMillis() {
            return millis;
        }
    }

    //    @Test
    public void testPollUntilMaxTimeVerifySqlResult() throws Exception {
        // TODO: fix this test
        TestMillisProvider testMillisProvider = new TestMillisProvider();
        testMillisProvider.setMillis(10000L);
        DateTimeUtils.setCurrentMillisProvider(testMillisProvider);
        databaseSvc.pollUntilMaxTimeVerifySqlResult(15, "DONE", "SELECT STATUS FROM STATUS_TABLE");
    }

    @Test
    public void testExecuteSqlQueryAssignResultsToVars() {
        when(stateSvc.expandVar(SQL_QUERY)).thenReturn(SQL_QUERY_EXPANDED);
        when(jdbcSvc.executeSingleRowQueryOnNamedConnection(DB_CONFIG_NAME, SQL_QUERY_EXPANDED)).thenReturn(RESULT_MAP);

        databaseSvc.setDatabaseConnectionToConfig(DB_CONFIG_NAME);
        databaseSvc.executeSqlQueryAssignResultsToVars(SQL_QUERY, Arrays.asList("var1", "var591"));

        verify(stateSvc).setStringVar("var1", "value1");
        verify(stateSvc).setStringVar("var591", "value591");
    }

    @Test(expected = CartException.class)
    public void testExecuteSqlQueryAssignResultsToVars_withEmptyMap() {
        when(stateSvc.expandVar(SQL_QUERY)).thenReturn(SQL_QUERY_EXPANDED);
        when(jdbcSvc.executeSingleRowQueryOnNamedConnection(DB_CONFIG_NAME, SQL_QUERY_EXPANDED)).thenReturn(EMPTY_MAP);
        databaseSvc.setDatabaseConnectionToConfig(DB_CONFIG_NAME);
        databaseSvc.executeSqlQueryAssignResultsToVars(SQL_QUERY, Arrays.asList("var1", "var591"));
    }

    @Test(expected = CartException.class)
    public void testGetColumnValueMapFromSqlResult_EmptyResults() {
        when(stateSvc.expandVar(SQL_QUERY)).thenReturn(SQL_QUERY_EXPANDED);
        when(jdbcSvc.executeSingleRowQueryOnNamedConnection(DB_CONFIG_NAME, SQL_QUERY_EXPANDED)).thenReturn(EMPTY_MAP);
        databaseSvc.setDatabaseConnectionToConfig(DB_CONFIG_NAME);
        databaseSvc.getColumnValueMapFromSqlResult(SQL_QUERY);
    }

    @Test
    public void testGetColumnValueMapFromSqlResult() {
        when(stateSvc.expandVar(SQL_QUERY)).thenReturn(SQL_QUERY_EXPANDED);
        when(jdbcSvc.executeSingleRowQueryOnNamedConnection(DB_CONFIG_NAME, SQL_QUERY_EXPANDED)).thenReturn(RESULT_MAP);
        databaseSvc.setDatabaseConnectionToConfig(DB_CONFIG_NAME);
        Map<String, String> result = databaseSvc.getColumnValueMapFromSqlResult(SQL_QUERY);
        Assert.assertEquals(3, result.size());
        Assert.assertEquals("value1", result.get("var1"));
        Assert.assertEquals("value591", result.get("var591"));
        Assert.assertEquals("doe", result.get("johnny"));
    }


    @Test
    public void testRefactorSQLQuery() {
        String sqlQuery = "SELECT A,B,C,D FROM TABLE WHERE E = 1";
        String expQuery = "SELECT * FROM TABLE WHERE E = 1";
        String actualQuery = databaseSvc.refactorSQLQuery(sqlQuery).getRefactoredQuery();
        Assert.assertEquals(expQuery, actualQuery);
    }

    @Test
    public void testRefactorSQLQuery_NegativeTC1() {
        String sqlQuery = "SELECT FROM_DATE, TO_DATE FROM TABLE WHERE E = 1";
        String expQuery = "SELECT * FROM TABLE WHERE E = 1";
        String actualQuery = databaseSvc.refactorSQLQuery(sqlQuery).getRefactoredQuery();
        Assert.assertEquals(expQuery, actualQuery);
    }

    @Test
    public void testRefactorSQLQuery_NegativeTC2() {
        String sqlQuery = "SELECT A,B,C,DATE_FROM FROM TABLE WHERE E = 1";
        String expQuery = "SELECT * FROM TABLE WHERE E = 1";
        String actualQuery = databaseSvc.refactorSQLQuery(sqlQuery).getRefactoredQuery();
        Assert.assertEquals(expQuery, actualQuery);
    }

    @Test
    public void testRefactorSQLQuery_NegativeTC3() {
        String sqlQuery = "SELECT * FROM TABLE WHERE E = 1";
        String expQuery = "SELECT * FROM TABLE WHERE E = 1";
        String actualQuery = databaseSvc.refactorSQLQuery(sqlQuery).getRefactoredQuery();
        Assert.assertEquals(expQuery, actualQuery);
    }

    @Test
    public void testRefactorSQLQuery_NegativeTC4() {
        String sqlQuery = "SELECT A,B,C FROM TABLE WHERE FROM_DATE = 1";
        String expQuery = "SELECT * FROM TABLE WHERE FROM_DATE = 1";
        String actualQuery = databaseSvc.refactorSQLQuery(sqlQuery).getRefactoredQuery();
        Assert.assertEquals(expQuery, actualQuery);
    }

    @Test
    public void testRefactorSQLQuery_NegativeTC5() {
        String sqlQuery = "WITH TABL_1 AS (\n" +
                "    SELECT ACCT_ID AS ACID_ACCT_ID\n" +
                "    FROM FT_T_ACID\n" +
                "    WHERE ACCT_ID_CTXT_TYP='BNPPRTID'\n" +
                "    AND ACCT_ALT_ID = '${VAR_ACCT_ID}'\n" +
                "SELECT CASE WHEN A=B THEN 'PASS' ELSE 'FAIL' END AS ACCT_ID_CHECK,A.ACID_ACCT_ID, B.EXTR_ACCT_ID FROM TABL_1 A CROSS JOIN TABL_2 B";

        String actualQuery = databaseSvc.refactorSQLQuery(sqlQuery).getRefactoredQuery();
        Assert.assertEquals(sqlQuery, actualQuery);
    }

    @Test
    public void testRefactorSQLQuery_NegativeTC6() {
        String sqlQuery = "SELECT COUNT(*) AS RDM_MKIS_COUNT\n" +
                "FROM FT_T_MKIS\n" +
                "WHERE INSTR_ID = (SELECT INSTR_ID FROM FT_T_ISID WHERE ISS_ID = 'TW0002330008' AND END_TMS IS NULL)\n" +
                "AND TRUNC(LAST_CHG_TMS) = TRUNC(SYSDATE)\n" +
                "AND LAST_CHG_USR_ID='EIS_RDM_DMP_EOD_SECURITY'\n" +
                "AND TRDNG_STAT_TYP='ACTIVE'";

        String expectedQuery = "SELECT *\n" +
                "FROM FT_T_MKIS\n" +
                "WHERE INSTR_ID = (SELECT INSTR_ID FROM FT_T_ISID WHERE ISS_ID = 'TW0002330008' AND END_TMS IS NULL)\n" +
                "AND TRUNC(LAST_CHG_TMS) = TRUNC(SYSDATE)\n" +
                "AND LAST_CHG_USR_ID='EIS_RDM_DMP_EOD_SECURITY'\n" +
                "AND TRDNG_STAT_TYP='ACTIVE'";
        String actualQuery = databaseSvc.refactorSQLQuery(sqlQuery).getRefactoredQuery();
        Assert.assertEquals(expectedQuery, actualQuery);
    }

    @Test
    public void testRefactorSQLQuery_NegativeTC7() {
        String sqlQuery = "SELECT CASE\n" +
                "WHEN '${INPUT_FILENAME}' LIKE '%MISC%'\n" +
                "THEN\n" +
                "(\n" +
                "    SELECT CASE WHEN EXEC_TRN_CAT_TYP ='MISC' THEN 'PASS' ELSE 'FAIL' END AS EXEC_TRN_CAT_TYP_CHECK\n" +
                "    FROM FT_T_EXTR\n" +
                "    WHERE EXEC_TRD_ID =\n" +
                "    (\n" +
                "        SELECT EXEC_TRD_ID FROM FT_T_ETID\n" +
                "        WHERE EXEC_TRN_ID_CTXT_TYP ='BNPTRNEVID' AND EXEC_TRN_ID = '${VAR_BNP_SOURCE_TRAN_EV_ID}'\n" +
                "    )\n" +
                ")";

        String expectedQuery = "SELECT CASE\n" +
                "WHEN '${INPUT_FILENAME}' LIKE '%MISC%'\n" +
                "THEN\n" +
                "(\n" +
                "    SELECT CASE WHEN EXEC_TRN_CAT_TYP ='MISC' THEN 'PASS' ELSE 'FAIL' END AS EXEC_TRN_CAT_TYP_CHECK\n" +
                "    FROM FT_T_EXTR\n" +
                "    WHERE EXEC_TRD_ID =\n" +
                "    (\n" +
                "        SELECT EXEC_TRD_ID FROM FT_T_ETID\n" +
                "        WHERE EXEC_TRN_ID_CTXT_TYP ='BNPTRNEVID' AND EXEC_TRN_ID = '${VAR_BNP_SOURCE_TRAN_EV_ID}'\n" +
                "    )\n" +
                ")";
        String actualQuery = databaseSvc.refactorSQLQuery(sqlQuery).getRefactoredQuery();
        Assert.assertEquals(expectedQuery, actualQuery);
    }


    @Test
    public void testRefactorSQLQuery_NegativeTC8() {
        String sqlQuery = "SELECT COUNT(*) AS DUPLICATE_COUNT FROM (\n" +
                "    SELECT posn_sok\n" +
                "    FROM gs_dw.ft_v_rpt1_rbc_seed_capital\n" +
                "    WHERE me_date BETWEEN TO_DATE('20180131','YYYYMMDD') AND TO_DATE('20181231','YYYYMMDD')\n" +
                "    GROUP BY posn_sok\n" +
                "    HAVING COUNT(*) > 1\n" +
                ")";

        String expectedQuery = "SELECT * FROM (\n" +
                "    SELECT posn_sok\n" +
                "    FROM gs_dw.ft_v_rpt1_rbc_seed_capital\n" +
                "    WHERE me_date BETWEEN TO_DATE('20180131','YYYYMMDD') AND TO_DATE('20181231','YYYYMMDD')\n" +
                "    GROUP BY posn_sok\n" +
                "    HAVING COUNT(*) > 1\n" +
                ")";

        String actualQuery = databaseSvc.refactorSQLQuery(sqlQuery).getRefactoredQuery();
        Assert.assertEquals(expectedQuery, actualQuery);
    }

    @Test
    public void testVerifySqlResultOfColumn_ZeroRetries() {
        databaseSvc.setDatabaseConnectionToConfig(DB_CONFIG_NAME);
        String sql = "select johnny from table";
        Map<String, String> map = new HashMap<String, String>() {{
            put("JOHNNY", "doe");
        }};

        when(stateSvc.expandVar(sql)).thenReturn(sql);
        when(jdbcSvc.executeSingleRowQueryOnNamedConnection(DB_CONFIG_NAME, sql)).thenReturn(map);
        databaseSvc.verifySqlResultOfColumn("johnny", "doe", sql, 1);
    }

    @Test
    public void testVerifySqlResultOfColumn_ThreeRetries_SuccessfulAtFirstAttempt() {
        databaseSvc.setDatabaseConnectionToConfig(DB_CONFIG_NAME);
        String sql = "select johnny from table";

        Map<String, String> map = new HashMap<String, String>() {{
            put("JOHNNY", "doe");
        }};

        when(stateSvc.expandVar(sql)).thenReturn(sql);
        when(jdbcSvc.executeSingleRowQueryOnNamedConnection(DB_CONFIG_NAME, sql)).thenReturn(map);

        databaseSvc.verifySqlResultOfColumn("johnny", "doe", sql, 3);
        verify(jdbcSvc, times(1)).executeSingleRowQueryOnNamedConnection(DB_CONFIG_NAME, sql);
    }

    @SuppressWarnings("unchecked")
    @Test
    public void testVerifySqlResultOfColumn_ThreeRetries_SuccessfulAtLaterAttempt() {
        databaseSvc.setDatabaseConnectionToConfig(DB_CONFIG_NAME);
        String sql = "select johnny from table";

        Map<String, String> map1 = new HashMap<String, String>() {{
            put("JOHNNY", "dummy");
        }};

        Map<String, String> map2 = new HashMap<String, String>() {{
            put("JOHNNY", "doe");
        }};

        when(stateSvc.expandVar(sql)).thenReturn(sql);
        when(jdbcSvc.executeSingleRowQueryOnNamedConnection(DB_CONFIG_NAME, sql)).thenReturn(map1, map1, map2);

        databaseSvc.verifySqlResultOfColumn("johnny", "doe", sql, 3);
        verify(jdbcSvc, times(3)).executeSingleRowQueryOnNamedConnection(DB_CONFIG_NAME, sql);
    }


    @SuppressWarnings("unchecked")
    @Test
    public void testVerifySqlResultOfColumn_ThreeRetries_FailAfterAttempts() {
        thrown.expect(CartException.class);
        thrown.expectMessage("Verification failed, were expecting column [johnny] value to be [doe], but it is [dummy]");
        databaseSvc.setDatabaseConnectionToConfig(DB_CONFIG_NAME);
        String sql = "select johnny from table";

        Map<String, String> map1 = new HashMap<String, String>() {{
            put("JOHNNY", "dummy");
        }};

        when(stateSvc.expandVar(sql)).thenReturn(sql);
        when(jdbcSvc.executeSingleRowQueryOnNamedConnection(DB_CONFIG_NAME, sql)).thenReturn(map1, map1, map1);

        databaseSvc.verifySqlResultOfColumn("johnny", "doe", sql, 3);
        verify(jdbcSvc, times(3)).executeSingleRowQueryOnNamedConnection(DB_CONFIG_NAME, sql);
    }

    @Test
    public void testGetCurrentConfigPrefix() {
        databaseSvc.setDatabaseConnectionToConfig("dmp.db.DW");
        Assert.assertEquals("dmp.db.DW", databaseSvc.getCurrentConfigPrefix());
    }

    @Test
    public void testExecuteSqlQueryAssignResultsToVars_MultipleRows() {
        final String query = "select column1 from table";
        final List<String> result = Arrays.asList("value1", "value2");

        when(stateSvc.expandVar(query)).thenReturn(query);
        when(jdbcSvc.getColumnValuesOnNamedConnection(DB_CONFIG_NAME, query, "column1")).thenReturn(result);
        doNothing().when(stateSvc).setStringVar("column11", "value1");
        doNothing().when(stateSvc).setStringVar("column12", "value2");

        databaseSvc.setDatabaseConnectionToConfig(DB_CONFIG_NAME);
        databaseSvc.executeSqlQueryAssignResultsToVars(query, "column1");

        verify(stateSvc, times(2)).setStringVar(anyString(), anyString());
    }

}
