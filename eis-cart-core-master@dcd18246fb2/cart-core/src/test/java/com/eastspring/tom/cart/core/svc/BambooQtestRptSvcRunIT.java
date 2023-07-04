package com.eastspring.tom.cart.core.svc;

import com.eastspring.tom.cart.core.CartCoreTestConfig;
import com.eastspring.tom.cart.core.mdl.QtestFeatureRpt;
import com.eastspring.tom.cart.core.mdl.QtestRptScenario;
import com.eastspring.tom.cart.core.mdl.QtestRptStep;
import com.eastspring.tom.cart.core.steps.CartCoreStepsSvcUtlTestConfig;
import com.eastspring.tom.cart.core.utl.FileDirUtil;
import com.eastspring.tom.cart.core.utl.WorkspaceUtil;
import org.junit.Before;
import org.junit.BeforeClass;
import org.junit.Test;
import org.junit.runner.RunWith;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.test.context.ContextConfiguration;
import org.springframework.test.context.junit4.SpringJUnit4ClassRunner;

import java.util.ArrayList;
import java.util.Arrays;
import java.util.HashSet;
import java.util.List;
import java.util.Set;
import java.util.TreeSet;

import static com.eastspring.tom.cart.core.svc.BambooQtestRptSvc.QTEST_JIRASPACES_CONFIGKEY;
import static org.junit.Assert.assertEquals;
import static org.junit.Assert.assertNotNull;
import static org.junit.Assert.assertTrue;

@RunWith(SpringJUnit4ClassRunner.class)
@ContextConfiguration(classes = {CartCoreStepsSvcUtlTestConfig.class})
public class BambooQtestRptSvcRunIT {

    @Autowired
    private BambooQtestRptSvc bambooQtestRptSvc;

    @Autowired
    private FileDirUtil fileDirUtil;

    @Autowired
    private StateSvc stateSvc;

    @Autowired
    private WorkspaceUtil workspaceUtil;

    @BeforeClass
    public static void setUpClass() {
        CartCoreTestConfig.configureLogging(BambooQtestRptSvcRunIT.class);
    }

    @Before
    public void setUp() {
        workspaceUtil.setBaseDir(System.getProperty("user.dir"));
        stateSvc.setStringVar(StateSvc.CURRENT_ENV_NAME, "TOM_DEV1");
    }

    @Test
    public void testGenerateSurefireReport() {
        String jsonReportFile = fileDirUtil.getMavenTestResourcesPath("bambooqtest/report.json");
        String outputFile = fileDirUtil.getMavenTestResourcesPath("bambooqtest/out/TEST-result.xml");
        String refFile = fileDirUtil.getMavenTestResourcesPath("bambooqtest/ref/TEST-result.xml");
        bambooQtestRptSvc.generateSurefireReport(jsonReportFile, outputFile);
        fileDirUtil.contentEquals(refFile, outputFile);
    }

    @Test
    public void testGenerateSurefireReport_withErrorMessage() {
        String jsonReportFile = fileDirUtil.getMavenTestResourcesPath("bambooqtest/report_with_error_msg.json");
        String outputFile = fileDirUtil.getMavenTestResourcesPath("bambooqtest/out/TEST-result_with_error.xml");
        bambooQtestRptSvc.generateSurefireReport(jsonReportFile, outputFile);
    }

    @Test
    public void testGenerateSurefireReport_withErrorMessageAndTomTags_1space() {
        String jsonReportFile = fileDirUtil.getMavenTestResourcesPath("bambooqtest/report_with_error_msg_with_tom_tags.json");
        String outputFile = fileDirUtil.getMavenTestResourcesPath("bambooqtest/out/TEST-result_with_error.xml");
        bambooQtestRptSvc.generateSurefireReport(jsonReportFile, outputFile);
    }

    @Test
    public void testGenerateSurefireReport_withErrorMessageAndTomTags_2spaces() {
        String jsonReportFile = fileDirUtil.getMavenTestResourcesPath("bambooqtest/report_with_error_msg_with_tom_tags.json");
        String expectedFile = fileDirUtil.getMavenTestResourcesPath("bambooqtest/ref/TEST-result-expected-2space.xml");
        String outputFile = fileDirUtil.getMavenTestResourcesPath("bambooqtest/out/TEST-result_with_msg_with_tom_tags.xml");
        stateSvc.setStringVar(QTEST_JIRASPACES_CONFIGKEY, "TOM,EISST");
        bambooQtestRptSvc.generateSurefireReport(jsonReportFile, outputFile);
    }

    @Test
    public void testParseJsonIntoQtestFeatureRpt() {
        String jsonReportFile = fileDirUtil.getMavenTestResourcesPath("bambooqtest/report_with_error_msg.json");
        QtestFeatureRpt qtestFeatureRpt = bambooQtestRptSvc.parseJsonIntoQtestFeatureRpt(jsonReportFile);
        assertNotNull(qtestFeatureRpt);
        Set<String> featureTags = qtestFeatureRpt.getTags();
        assertTrue(featureTags.contains("@cash_in"));
        assertTrue(featureTags.contains("@interface"));
        assertEquals("Inbound Intraday Cash Transactions Interface Testing (R3.IN.CAS1 BNP to DMP)", qtestFeatureRpt.getFeatureName());
        assertEquals(3, qtestFeatureRpt.getScenarios().size());
        assertEquals("IF_0100_TC_1: Process BNP Intraday Cash Transactions to DMP (CAS1): Data Preparation", qtestFeatureRpt.getScenarios().get(0).getName());
        assertEquals("IF_0100_TC_2: Process BNP Intraday Cash Transactions to DMP (CAS1): Data Loading", qtestFeatureRpt.getScenarios().get(1).getName());
        assertEquals("IF_0100_TC_3: Process BNP Intraday Cash Transactions to DMP (CAS1): \"ESIINTRADAY_TRN_NEWCASH_NEW.out\" Verifications", qtestFeatureRpt.getScenarios().get(2).getName());
        Set<String> tags1 = qtestFeatureRpt.getScenarios().get(0).getTags();
        assertTrue(tags1.contains("@cash_data_prep"));
        assertTrue(tags1.contains("@cash_in"));
        assertTrue(tags1.contains("@interface"));
        Set<String> tags2 = qtestFeatureRpt.getScenarios().get(1).getTags();
        assertTrue(tags2.contains("@cash_data_load"));
        Set<String> tags3 = qtestFeatureRpt.getScenarios().get(2).getTags();
        assertTrue(tags3.contains("@cash_in"));
        assertTrue(tags3.contains("@cash_verification"));
        assertTrue(tags3.contains("@interface"));
    }


    @Test
    public void testGetXmlOutput1() {
        List<QtestRptStep> steps = Arrays.asList(new QtestRptStep("abc", true, null), new QtestRptStep("def", false, "error message 1"));
        List<QtestRptScenario> scenarios = new ArrayList<QtestRptScenario>() {{
            add(new QtestRptScenario("scenario name", steps, null));
        }};
        QtestFeatureRpt qtestFeatureRpt = new QtestFeatureRpt("feature name", scenarios, null);
        TreeSet<String> jiraSpaces = new TreeSet<String>() {{
            add("tom");
        }};
        String actualResult = bambooQtestRptSvc.getXmlOutput(qtestFeatureRpt, jiraSpaces);
        String expectedResult = "<?xml version=\"1.0\" encoding=\"UTF-8\" ?>\n" +
                "<testsuite tests=\"3\" failures=\"0\" name=\"TEST-TOMR3_INTF_RIMES-001_infile\" time=\"0\" errors=\"0\" skipped=\"0\">\n" +
                "  <testcase classname=\"[TOM_DEV1][] scenario name\" name=\"abc\" time=\"0\"/>\n" +
                "  <testcase classname=\"[TOM_DEV1][] scenario name\" name=\"def\" time=\"0\"><error message=\"Attribute error message\" type=\"Error Type\">error message 1</error></testcase>\n" +
                "</testsuite>\n";
        assertEquals(expectedResult, actualResult);
    }

    @Test
    public void testGetXmlOutput2() {
        List<QtestRptStep> steps = Arrays.asList(new QtestRptStep("abc", true, null), new QtestRptStep("def", false, "error message 1"));
        List<QtestRptScenario> scenarios = new ArrayList<QtestRptScenario>() {{
            add(new QtestRptScenario("scenario name", steps, new HashSet<String>() {{
                add("@tom_1");
                add("@tom_2");
            }}));
        }};
        QtestFeatureRpt qtestFeatureRpt = new QtestFeatureRpt("feature name", scenarios, null);
        TreeSet<String> jiraSpaces = new TreeSet<String>() {{
            add("tom");
        }};
        String actualResult = bambooQtestRptSvc.getXmlOutput(qtestFeatureRpt, jiraSpaces);
        String expectedResult = "<?xml version=\"1.0\" encoding=\"UTF-8\" ?>\n" +
                "<testsuite tests=\"3\" failures=\"0\" name=\"TEST-TOMR3_INTF_RIMES-001_infile\" time=\"0\" errors=\"0\" skipped=\"0\">\n" +
                "  <testcase classname=\"[TOM_DEV1][TOM-1, TOM-2] scenario name\" name=\"abc\" time=\"0\"/>\n" +
                "  <testcase classname=\"[TOM_DEV1][TOM-1, TOM-2] scenario name\" name=\"def\" time=\"0\"><error message=\"Attribute error message\" type=\"Error Type\">error message 1</error></testcase>\n" +
                "</testsuite>\n";
        assertEquals(expectedResult, actualResult);
    }

    @Test
    public void testGetXmlOutput3() {
        List<QtestRptStep> steps1 = Arrays.asList(new QtestRptStep("abc", true, null), new QtestRptStep("def", false, "error message 1"));
        List<QtestRptStep> steps2 = Arrays.asList(new QtestRptStep("ghi", true, null), new QtestRptStep("jkl", true, null));
        List<QtestRptScenario> scenarios = new ArrayList<QtestRptScenario>() {{
            add(new QtestRptScenario("scenario name 1", steps1, new HashSet<String>() {{
                add("@tom_1356");
                add("@tom_1468");
            }}));
            add(new QtestRptScenario("scenario name 2", steps2, null));
        }};
        QtestFeatureRpt qtestFeatureRpt = new QtestFeatureRpt("feature name", scenarios, new HashSet<String>() {{
            add("@tom_1348");
            add("@interface");
        }});
        TreeSet<String> jiraSpaces = new TreeSet<String>() {{
            add("tom");
        }};
        String actualResult = bambooQtestRptSvc.getXmlOutput(qtestFeatureRpt, jiraSpaces);
        String expectedResult = "<?xml version=\"1.0\" encoding=\"UTF-8\" ?>\n" +
                "<testsuite tests=\"3\" failures=\"0\" name=\"TEST-TOMR3_INTF_RIMES-001_infile\" time=\"0\" errors=\"0\" skipped=\"0\">\n" +
                "  <testcase classname=\"[TOM_DEV1][TOM-1348, TOM-1356, TOM-1468] scenario name 1\" name=\"abc\" time=\"0\"/>\n" +
                "  <testcase classname=\"[TOM_DEV1][TOM-1348, TOM-1356, TOM-1468] scenario name 1\" name=\"def\" time=\"0\"><error message=\"Attribute error message\" type=\"Error Type\">error message 1</error></testcase>\n" +
                "  <testcase classname=\"[TOM_DEV1][TOM-1348] scenario name 2\" name=\"ghi\" time=\"0\"/>\n" +
                "  <testcase classname=\"[TOM_DEV1][TOM-1348] scenario name 2\" name=\"jkl\" time=\"0\"/>\n" +
                "</testsuite>\n";
        assertEquals(expectedResult, actualResult);
        System.out.println(actualResult);
    }
}
