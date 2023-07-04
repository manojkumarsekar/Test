package com.eastspring.tom.cart.dmp.steps;

import com.eastspring.tom.cart.core.CartException;
import com.eastspring.tom.cart.core.svc.*;
import com.eastspring.tom.cart.dmp.utl.DmpFileHandlingUtl;
import org.junit.Assert;
import org.junit.Before;
import org.junit.Rule;
import org.junit.Test;
import org.junit.rules.ExpectedException;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.Mockito;
import org.mockito.MockitoAnnotations;
import org.mockito.invocation.InvocationOnMock;
import org.mockito.stubbing.Answer;

import java.nio.file.Paths;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import static com.eastspring.tom.cart.dmp.svc.DmpWorkflowSvc.GSWF_DEFAULT_CONFIG_NAME;
import static org.mockito.Mockito.doNothing;
import static org.mockito.Mockito.doThrow;
import static org.mockito.Mockito.times;
import static org.mockito.Mockito.verify;
import static org.mockito.Mockito.when;

public class DmpGsWorkflowStepsTest {

    @InjectMocks
    private DmpGsWorkflowSteps steps;

    @Mock
    private FileDirSvc fileDirSvc;

    @Mock
    private StateSvc stateSvc;

    @Mock
    private FmTemplateSvc fmTemplateSvc;

    @Mock
    private XmlSvc xmlSvc;

    @Mock
    private DatabaseSvc databaseSvc;

    @Mock
    private DmpFileHandlingUtl dmpFileHandlingUtl;

    @Mock
    private WorkspaceDirSvc workspaceDirSvc;

    @Rule
    public ExpectedException thrown = ExpectedException.none();

    @Before
    public void initMocks() {
        MockitoAnnotations.initMocks(this);
    }

    //    @Test
    public void test() throws Exception {
        String file = "ProcessFilesDirectory_request.xmlt";
        String dir = "c:/tomcart-work/testdata/workflow/template";
        String templateFile = "testdata/workflow/template/ProcessFilesDirectory_request.xmlt";
        String responseFile = "testevidence/workflow/response1.xml";
        Map<String, String> valueMap = new HashMap<>();
        valueMap.put("BUSINESS_FEED", "EIS_BF_RDM");
        valueMap.put("INPUT_DATA_DIR", "/home/jbossadm/automatedtest/inbound");
        valueMap.put("FILE_PATTERN", "");
        valueMap.put("ARCHIVE_DIR", "/home/jbossadm/automatedtest/archive");
        valueMap.put("PARALLELISM", "2");

        FmTemplateSvc fts = new FmTemplateSvc();
        fts.setTemplateLocation(dir);

        when(fileDirSvc.createTestEvidenceSubDir("/gswf")).thenReturn("c:/tomcart-work/testevidence/gswf");
        when(fileDirSvc.decomposePath(templateFile)).thenReturn(new FileDirSvc.FileDir(dir, file));
        when(stateSvc.getValueMapFromPrefix(DmpGsWorkflowSteps.GSWF_TEMPLATE_PARAM_PREFIX, true)).thenReturn(valueMap);
//        final StringBuilder sb = new StringBuilder();
        Mockito.doAnswer(new Answer<Void>() {
            @Override
            public Void answer(InvocationOnMock invocationOnMock) throws Throwable {
                return null;
            }
        }).when(fmTemplateSvc).setTemplateLocation(dir);
        when(fmTemplateSvc.getTemplate(file)).thenReturn(fts.getTemplate(file));
        when(stateSvc.getStringVar(GSWF_DEFAULT_CONFIG_NAME)).thenReturn("dmp.ws.WORKFLOW");
        when(stateSvc.getStringVar("dmp.ws.WORKFLOW.protocol")).thenReturn("http");
        when(stateSvc.getStringVar("dmp.ws.WORKFLOW.host")).thenReturn("vsgeisldapp07.pru.intranet.asia");
        when(stateSvc.getStringVar("dmp.ws.WORKFLOW.context")).thenReturn("/standardvddb/webservice/Events");
        when(stateSvc.getStringVar("dmp.ws.WORKFLOW.port")).thenReturn("8680");
        when(stateSvc.getStringVar("dmp.ws.WORKFLOW.user")).thenReturn("user1");
        when(stateSvc.getStringVar("dmp.ws.WORKFLOW.pass")).thenReturn("user1@123");
        steps.sendWebServiceRequestUsingTemplateFile(templateFile, responseFile);
    }

    @Test
    public void testSetEndTmsToSYSDATEAsPerDBConfig_NoSqlException() {
        String issIds = "'Test1','Test2'";
        String dbConfig = "testDb";
        String sqlQuery = "UPDATE FT_T_ISID \n" +
                "  SET END_TMS=SYSDATE,START_TMS=LAST_CHG_TMS\n" +
                "  WHERE INSTR_ID IN (SELECT INSTR_ID FROM FT_T_ISID WHERE ISS_ID IN (" + issIds + ")) AND END_TMS IS NULL;\n" +
                "  COMMIT;";

        when(stateSvc.expandVar(issIds)).thenReturn(issIds);
        doNothing().when(databaseSvc).setDatabaseConnectionToConfig(dbConfig);
        doNothing().when(databaseSvc).executeMultipleQueries(sqlQuery);
        steps.setEndTmsToSYSDATEAsPerDBConfig(dbConfig, issIds);
        verify(databaseSvc, times(1)).executeMultipleQueries(sqlQuery);
    }

    @Test
    public void testSetEndTmsToSYSDATEAsPerDBConfig_WithSqlException() {
        String issIds = "'Test1','Test2'";
        String dbConfig = "testDb";
        String sqlQuery = "UPDATE FT_T_ISID \n" +
                "  SET END_TMS=SYSDATE,START_TMS=LAST_CHG_TMS\n" +
                "  WHERE INSTR_ID IN (SELECT INSTR_ID FROM FT_T_ISID WHERE ISS_ID IN (" + issIds + ")) AND END_TMS IS NULL;\n" +
                "  COMMIT;";

        when(stateSvc.expandVar(issIds)).thenReturn(issIds);
        doNothing().when(databaseSvc).setDatabaseConnectionToConfig(dbConfig);
        doThrow(CartException.class).when(databaseSvc).executeMultipleQueries(sqlQuery);
        doNothing().when(databaseSvc).executeMultipleQueries(sqlQuery.replace(",START_TMS=LAST_CHG_TMS", ""));
        steps.setEndTmsToSYSDATEAsPerDBConfig(dbConfig, issIds);
        verify(databaseSvc, times(1)).executeMultipleQueries(sqlQuery);
        verify(databaseSvc, times(1)).executeMultipleQueries(sqlQuery.replace(",START_TMS=LAST_CHG_TMS", ""));
    }

    @Test
    public void testIExpectColumnValuesOfCSVFileShouldBeAsPerCondition_lookingForMatch_withValue() {
        final String file = "mock.csv";
        List<String> values = new ArrayList<>();
        when(stateSvc.expandVar("column1")).thenReturn("column1");
        when(stateSvc.expandVar(file)).thenReturn(file);
        values.add("test1");
        values.add("test1");
        values.add("test1");
        when(dmpFileHandlingUtl.getFieldValuesFromFileWithHeader(file, 1, "", "column1", ',')).thenReturn(values);
        steps.iExpectColumnValuesOfCSVFileShouldBeAsPerCondition("column1", file, "test1", true);
    }

    @Test
    public void testIExpectColumnValuesOfCSVFileShouldBeAsPerCondition_lookingForMatch_withRegEx() {
        final String file = "mock.csv";
        List<String> values = new ArrayList<>();
        when(stateSvc.expandVar("column1")).thenReturn("column1");
        when(stateSvc.expandVar(file)).thenReturn(file);
        values.add("test1");
        values.add("test2");
        values.add("test3");
        when(dmpFileHandlingUtl.getFieldValuesFromFileWithHeader(file, 1, "", "column1", ',')).thenReturn(values);
        steps.iExpectColumnValuesOfCSVFileShouldBeAsPerCondition("column1", file, "test.*", true);
    }

    @Test
    public void testIExpectColumnValuesOfCSVFileShouldBeAsPerCondition_lookingForMatch_withRegEx_complex() {
        final String file = "mock.csv";
        List<String> values = new ArrayList<>();
        when(stateSvc.expandVar("column1")).thenReturn("column1");
        when(stateSvc.expandVar(file)).thenReturn(file);
        values.add("test1");
        values.add("test2");
        values.add("test3");
        when(dmpFileHandlingUtl.getFieldValuesFromFileWithHeader(file, 1, "", "column1", ',')).thenReturn(values);
        steps.iExpectColumnValuesOfCSVFileShouldBeAsPerCondition("column1", file, ".*(?<!4|5)$", true);
    }

    @Test
    public void testIExpectColumnValuesOfCSVFileShouldBeAsPerCondition_lookingForMatch_but_notFound_withValue() {
        thrown.expect(CartException.class);
        final String file = "mock.csv";
        List<String> values = new ArrayList<>();
        when(stateSvc.expandVar("column1")).thenReturn("column1");
        when(stateSvc.expandVar(file)).thenReturn(file);
        values.add("test1");
        values.add("test1");
        values.add("test1");
        when(dmpFileHandlingUtl.getFieldValuesFromFileWithHeader(file, 1, "", "column1", ',')).thenReturn(values);
        steps.iExpectColumnValuesOfCSVFileShouldBeAsPerCondition("column1", file, "test4", true);
    }

    @Test
    public void testIExpectColumnValuesOfCSVFileShouldBeAsPerCondition_lookingForMatch_but_notFound_withRegEx_complex() {
        thrown.expect(CartException.class);
        final String file = "mock.csv";
        List<String> values = new ArrayList<>();
        when(stateSvc.expandVar("column1")).thenReturn("column1");
        when(stateSvc.expandVar(file)).thenReturn(file);
        values.add("test1");
        values.add("test2");
        values.add("test3");
        when(dmpFileHandlingUtl.getFieldValuesFromFileWithHeader(file, 1, "", "column1", ',')).thenReturn(values);
        steps.iExpectColumnValuesOfCSVFileShouldBeAsPerCondition("column1", file, ".*(4|5)$", true);
    }

    @Test
    public void testIExpectColumnValuesOfCSVFileShouldBeAsPerCondition_lookingForNotMatch_withValue() {
        final String file = "mock.csv";
        List<String> values = new ArrayList<>();
        when(stateSvc.expandVar("column1")).thenReturn("column1");
        when(stateSvc.expandVar(file)).thenReturn(file);
        values.add("test1");
        values.add("test1");
        values.add("test1");
        when(dmpFileHandlingUtl.getFieldValuesFromFileWithHeader(file, 1, "", "column1", ',')).thenReturn(values);
        steps.iExpectColumnValuesOfCSVFileShouldBeAsPerCondition("column1", file, "test2", false);
    }
    
}
