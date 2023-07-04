package com.eastspring.tom.cart.core.svc;

import com.eastspring.tom.cart.core.CartCoreTestConfig;
import com.eastspring.tom.cart.core.mdl.ColumnMetadata;
import com.eastspring.tom.cart.core.utl.FileDirUtil;
import com.eastspring.tom.cart.core.utl.SqlStringUtil;
import com.eastspring.tom.cart.core.utl.WorkspaceUtil;
import org.junit.Assert;
import org.junit.BeforeClass;
import org.junit.Rule;
import org.junit.Test;
import org.junit.rules.ExpectedException;
import org.junit.runner.RunWith;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.test.context.ContextConfiguration;
import org.springframework.test.context.junit4.SpringJUnit4ClassRunner;

import java.util.ArrayList;
import java.util.List;
import java.util.stream.Collectors;

import static com.eastspring.tom.cart.core.svc.JdbcSvc.INTERNAL_DB_RECON;

@RunWith(SpringJUnit4ClassRunner.class)
@ContextConfiguration(classes = {CartCoreSvcUtlTestConfig.class})
public class JdbcSvcIT {

    @Autowired
    private FileDirUtil fileDirUtil;

    @Autowired
    private JdbcSvc jdbcSvc;

    @Autowired
    private SqlStringUtil sqlStringUtil;

    @Autowired
    private StateSvc stateSvc;

    @Autowired
    private WorkspaceUtil workspaceUtil;

    @Rule
    public ExpectedException thrown = ExpectedException.none();

    @BeforeClass
    public static void setUpClass() {
        CartCoreTestConfig.configureLogging(JdbcSvcIT.class);
    }

    @Test
    public void testExecuteStoredProcedureOnNamedConnection() {
        List<String> inParams = new ArrayList<>();
        inParams.add("TestAutomation.dbo.CPR_BOR_Raw_20171030131148540");
        inParams.add("TestAutomation.dbo.BNP_BOR_Raw_20171030131148540");
        inParams.add("0.0001");
        inParams.add("10");
        inParams.add("CPR");
        inParams.add("BNP");
        List<String> outParams = new ArrayList<>();
        jdbcSvc.createNamedConnection(INTERNAL_DB_RECON);
        jdbcSvc.executeStoredProcedureOnNamedConnection(INTERNAL_DB_RECON, "TestAutomation.dbo.Compare_BOR_CPR_BNP", inParams, outParams);
    }

    /*Below stored procedure to be compiled in database against which we are running test (dmp.db.GC)
    Otherwise this test will fail.
     */
     /*create or replace procedure calc(p_num_1 in number, p_num_2 in number, p_plus out number, p_minus out number, p_multiply out number)
     is
     begin
     p_plus := p_num_1 + p_num_2;
     p_minus := p_num_1 - p_num_2;
     p_multiply := p_num_1 * p_num_2;
     end;
     */
    @Test
    public void testExecuteStoredProcedureOnNamedConnection_with_OutParams() {
        jdbcSvc.createNamedConnection("dmp.db.GC");

        List<String> inParams = new ArrayList<>();
        inParams.add("2");
        inParams.add("4");

        List<String> outParams = new ArrayList<>();
        outParams.add("sum");
        outParams.add("sub");
        outParams.add("mul");

        jdbcSvc.executeStoredProcedureOnNamedConnection("dmp.db.GC", "calc", inParams, outParams);
        Assert.assertEquals(6, Integer.parseInt(stateSvc.getStringVar("sum")));
        Assert.assertEquals(-2, Integer.parseInt(stateSvc.getStringVar("sub")));
        Assert.assertEquals(8, Integer.parseInt(stateSvc.getStringVar("mul")));
    }


    // Using h2 as in-memory database to execute stored procedure functions
    @Test
    public void testExecuteStoredProcedureOnNamedConnection_with_inParams_only() {
        StringBuilder sb = new StringBuilder();
        sb.append("CREATE ALIAS hello_world AS $$\n");
        sb.append("void hello_world(String param1){\n");
        sb.append("System.out.println(\"Hello world user \" + param1);}\n");
        sb.append("$$");
        try {
            jdbcSvc.createNamedConnection("db.in.mem");
            jdbcSvc.executeOnNamedConnection("db.in.mem", sb.toString());

            List<String> inParams = new ArrayList<>();
            inParams.add("User");
            List<String> outParams = new ArrayList<>();
            jdbcSvc.executeStoredProcedureOnNamedConnection("db.in.mem", "hello_world", inParams, outParams);
        } catch (Exception e) {
            Assert.assertNull(e);
        }
    }

    @Test
    public void testGetColumnMetadataOnNamedConnection() {
        jdbcSvc.createNamedConnection(INTERNAL_DB_RECON);
        String tableName = "dbo.vwMismatch_39";
        List<ColumnMetadata> result = jdbcSvc.getColumnMetadataOnNamedConnection(INTERNAL_DB_RECON, tableName);
        String columnList = sqlStringUtil.zipJoin(result.stream().map(ColumnMetadata::getBracketedColumnName).collect(Collectors.toList()), ",", "", "");
        String selectQuery = String.format("SELECT %s FROM %s", columnList, tableName);
        System.out.println(columnList);
        System.out.println(selectQuery);
        String outFileFullpath = fileDirUtil.getMavenTestResourcesPath("recon/result.csv");
        jdbcSvc.exportSqlQueryNamedConnectionToCsv(INTERNAL_DB_RECON, selectQuery, outFileFullpath);
    }
}
