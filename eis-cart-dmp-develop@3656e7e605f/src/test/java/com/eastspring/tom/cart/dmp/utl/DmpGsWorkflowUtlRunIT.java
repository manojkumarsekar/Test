package com.eastspring.tom.cart.dmp.utl;

import com.eastspring.tom.cart.core.svc.DatabaseSvc;
import com.eastspring.tom.cart.core.svc.StateSvc;
import com.eastspring.tom.cart.core.utl.DateTimeUtil;
import com.eastspring.tom.cart.core.utl.FileDirUtil;
import com.eastspring.tom.cart.core.utl.WorkspaceUtil;
import com.eastspring.tom.cart.core.utl.XPathUtil;
import com.eastspring.tom.cart.dmp.CartDmpTestConfig;
import com.eastspring.tom.cart.dmp.integration.CartDmpStepsSvcUtlConfig;
import org.junit.*;
import org.junit.runner.RunWith;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.test.context.ContextConfiguration;
import org.springframework.test.context.junit4.SpringJUnit4ClassRunner;

import java.io.File;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import static com.eastspring.tom.cart.dmp.utl.DmpGsWorkflowUtl.EVEN_INSTRUMENTS;
import static com.eastspring.tom.cart.dmp.utl.DmpGsWorkflowUtl.GSWF_TEMPLATE_PARAM_PREFIX;

@RunWith( SpringJUnit4ClassRunner.class )
@ContextConfiguration( classes = {CartDmpStepsSvcUtlConfig.class} )
public class DmpGsWorkflowUtlRunIT {

    @Autowired
    private DmpGsWorkflowUtl dmpGsWorkflowUtl;

    @Autowired
    private StateSvc stateSvc;

    @Autowired
    private WorkspaceUtil workspaceUtil;

    @Autowired
    private FileDirUtil fileDirUtil;

    @Autowired
    private DateTimeUtil dateTimeUtil;

    @Autowired
    private DatabaseSvc databaseSvc;

    @Autowired
    private XPathUtil xPathUtil;

    @BeforeClass
    public static void setUpClass() {
        CartDmpTestConfig.configureLogging(DmpGsWorkflowUtl.class);
    }

    @Before
    public void setBaseDir() {
        workspaceUtil.setBaseDir(".");
    }

    @Test
    public void testClearAllTemplateParams() {
        dmpGsWorkflowUtl.setTemplateParam("MESSAGE_TYPE", "message");

        dmpGsWorkflowUtl.clearAllTemplateParams();

        Map<String, String> valueStringMapFromPrefix = stateSvc.getValueStringMapFromPrefix(GSWF_TEMPLATE_PARAM_PREFIX, true);
        Assert.assertTrue(valueStringMapFromPrefix.size() == 0);
    }

    @Test
    public void testChangePatternsInTemplateAndCreateNewFile_CSV_runtimeVariables() {
        final String path = "target/test-classes/files/expandFiles";

        Map<String, String> map = new HashMap<>();
        map.put("DATE", "DateTimeFormat:ddMMYYYY");
        map.put("VAL1", "value1");

        dmpGsWorkflowUtl.changePatternsInTemplateAndCreateNewFile(path + "/outfile_runtime_vars.csv", path + "/template.csv", map);

        String expandedLine = fileDirUtil.readFileToString(path + File.separator + "outfile_runtime_vars.csv");
        Assert.assertEquals(dateTimeUtil.getTimestamp("ddMMYYYY") + "value1", expandedLine);
    }

    @Test
    public void testChangePatternsInTemplateAndCreateNewFile_CSV_inMemoryVariables() {
        final String path = "target/test-classes/files/expandFiles";

        stateSvc.setStringVar("DATE", "ddMMYYYY");
        stateSvc.setStringVar("VAL1", "InMemoryTest");

        dmpGsWorkflowUtl.changePatternsInTemplateAndCreateNewFile(path + "/outfile_inmemory_vars.csv", path + "/template.csv", new HashMap<>());

        String expandedLine = fileDirUtil.readFileToString(path + File.separator + "outfile_inmemory_vars.csv");
        Assert.assertEquals("ddMMYYYYInMemoryTest", expandedLine);
    }

    //This test requires valid DB connection details, hence it should not be part of CI build and mvn test goal
    @Ignore
    @Test
    public void testModifyWorkflowXmlWithDynamicValues_GoldenPriceWf_InsertInstruments() {
        stateSvc.setStringVar("dmp.db.GC.type", "jdbc_a");
        stateSvc.setStringVar("dmp.db.GC.jdbc.url", "jdbc:oracle:thin:@asgesivldora001.pru.intranet.asia:1521/asgesivlggsa200_GC");
        stateSvc.setStringVar("dmp.db.GC.jdbc.class", "oracle.jdbc.driver.OracleDriver");
        stateSvc.setStringVar("dmp.db.GC.jdbc.user", "GS_GC_APP");
        stateSvc.setStringVar("dmp.db.GC.jdbc.pass", "eastspring");

        databaseSvc.setDatabaseConnectionToConfig("dmp.db.GC");

        final String wfTemplate = "target/test-classes/workflow/goldenpricewf.xmlt";
        Map<String, String> map = new HashMap<>();
        map.put("INSTRUMENTS", "SG6ZF3000008,XS0562852375,DE000BHY1547");
        dmpGsWorkflowUtl.modifyWorkflowXmlWithDynamicValues(wfTemplate, map);

        final List<String> instrumentTags = xPathUtil.extractByTagName(fileDirUtil.readFileToString(wfTemplate), EVEN_INSTRUMENTS);
        Assert.assertEquals(3, instrumentTags.size());
    }
}
