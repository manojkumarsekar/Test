package com.eastspring.tom.cart.core.svc;

import com.eastspring.tom.cart.core.CartCoreTestConfig;
import com.eastspring.tom.cart.core.utl.FileDirUtil;
import com.eastspring.tom.cart.core.utl.WorkspaceUtil;
import org.junit.*;
import org.junit.runner.RunWith;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.test.context.ContextConfiguration;
import org.springframework.test.context.junit4.SpringJUnit4ClassRunner;

@RunWith(SpringJUnit4ClassRunner.class)
@ContextConfiguration(classes = {CartCoreSvcUtlTestConfig.class})
public class MTReportsSvcRunIT {

    @Autowired
    private MTReportsSvc mtReportsSvc;

    @Autowired
    private FileDirUtil fileDirUtil;

    @Autowired
    private WorkspaceUtil workspaceUtil;

    @BeforeClass
    public static void setUpClass() {
        CartCoreTestConfig.configureLogging(MTReportsSvcRunIT.class);
    }

    @Before
    public void before() {
        workspaceUtil.setBaseDir(System.getProperty("user.dir"));
    }

    @Test
    public void testGenerateReports() {
        final String path = fileDirUtil.getMavenTestResourcesPath("cucumber");
        mtReportsSvc.generateReports(path);
        Assert.assertTrue(fileDirUtil.verifyFileExists("target/test-classes/cucumber/report.json"));
        Assert.assertTrue(fileDirUtil.verifyFileExists("target/test-classes/cucumber/cucumber-html-reports/overview-features.html"));
        Assert.assertTrue(fileDirUtil.verifyFileExists("target/test-classes/cucumber/cucumber-html-reports/overview-failures.html"));
        Assert.assertTrue(fileDirUtil.verifyFileExists("target/test-classes/cucumber/cucumber-html-reports/overview-steps.html"));
    }


    //@Test
    public void testGenerateReports_failCase() {
        final String path = fileDirUtil.getMavenTestResourcesPath("conf");
        mtReportsSvc.generateReports(path);
    }

}
