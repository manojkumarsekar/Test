package com.eastspring.tom.cart.core.svc;

import com.eastspring.tom.cart.core.CartCoreTestConfig;
import com.eastspring.tom.cart.core.CartException;
import com.eastspring.tom.cart.core.mdl.QtestRptStep;
import com.eastspring.tom.cart.core.utl.CukesTagUtil;
import org.junit.*;
import org.junit.rules.ExpectedException;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.MockitoAnnotations;

import static com.eastspring.tom.cart.core.svc.BambooQtestRptSvc.QTEST_JIRASPACES_CONFIGKEY;
import static org.junit.Assert.assertEquals;
import static org.mockito.Mockito.when;

public class BambooQtestRptSvcTest {

    @InjectMocks
    private BambooQtestRptSvc bambooQtestRptSvc;

    @Mock
    private CukesTagUtil cukesTagUtil;

    @Mock
    private StateSvc stateSvc;

    @Rule
    public ExpectedException thrown = ExpectedException.none();

    @Before
    public void initMocks() {
        MockitoAnnotations.initMocks(this);
    }

    @BeforeClass
    public static void setUpClass() {
        CartCoreTestConfig.configureLogging(BambooQtestRptSvcTest.class);
    }

    @Test
    public void testNameStatusToString() throws Exception {
        QtestRptStep nameStatus = new QtestRptStep("name", true,"errorMessage");
        String result = nameStatus.toString();
        Assert.assertTrue(result.endsWith("[name=name,status=true,errorMessage=errorMessage]"));
    }

    @Test
    public void testGenerateSurefireReport_nullJsonReportFile() {
        Exception thrownException =  null;
        try {
            bambooQtestRptSvc.generateSurefireReport(null, "a");
        }catch (Exception e) {
            thrownException = e;
        }
        Assert.assertNotNull(thrownException);
        Assert.assertTrue(thrownException instanceof CartException);
        assertEquals(BambooQtestRptSvc.THE_JSON_REPORT_FILE_PARAMETER_MUST_NOT_BE_NULL_OR_EMPTY, thrownException.getMessage());
    }

    @Test
    public void testGenerateSurefireReport_nullOutputFile() {
        Exception thrownException =  null;
        try {
            bambooQtestRptSvc.generateSurefireReport("{}", null);
        }catch (Exception e) {
            thrownException = e;
        }
        Assert.assertNotNull(thrownException);
        Assert.assertTrue(thrownException instanceof CartException);
        assertEquals(BambooQtestRptSvc.THE_OUTPUT_FILE_PARAMETER_MUST_NOT_BE_NULL_OR_EMPTY, thrownException.getMessage());
    }

    @Test
    public void testGenerateSurefireReport_jiraSpaceNull() {
        Exception thrownException =  null;
        when(stateSvc.getStringVar(QTEST_JIRASPACES_CONFIGKEY)).thenReturn(null);
        try {
            bambooQtestRptSvc.generateSurefireReport("{}", "something.json");
        }catch (Exception e) {
            thrownException = e;
        }
        Assert.assertNotNull(thrownException);
        Assert.assertTrue(thrownException instanceof CartException);
        assertEquals(BambooQtestRptSvc.THE_QTEST_JIRASPACES_NEEDED, thrownException.getMessage());
    }

    @Test
    public void testGenerateSurefireReport_jiraSpaceEmpty() {
        Exception thrownException =  null;
        when(stateSvc.getStringVar(QTEST_JIRASPACES_CONFIGKEY)).thenReturn("");
        try {
            bambooQtestRptSvc.generateSurefireReport("{}", "something.json");
        }catch (Exception e) {
            thrownException = e;
        }
        Assert.assertNotNull(thrownException);
        Assert.assertTrue(thrownException instanceof CartException);
        assertEquals(BambooQtestRptSvc.THE_QTEST_JIRASPACES_NEEDED, thrownException.getMessage());
    }
}
