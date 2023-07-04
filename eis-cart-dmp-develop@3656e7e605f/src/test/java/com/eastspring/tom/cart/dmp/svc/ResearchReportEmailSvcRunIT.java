package com.eastspring.tom.cart.dmp.svc;

import com.eastspring.tom.cart.core.utl.WorkspaceUtil;
import com.eastspring.tom.cart.dmp.CartDmpTestConfig;
import com.eastspring.tom.cart.dmp.integration.CartDmpStepsSvcUtlConfig;
import java.util.HashMap;
import java.util.Map;
import org.junit.*;
import org.junit.rules.ExpectedException;
import org.junit.runner.RunWith;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.test.context.ContextConfiguration;
import org.springframework.test.context.junit4.SpringJUnit4ClassRunner;

@RunWith(SpringJUnit4ClassRunner.class)
@ContextConfiguration(classes = {CartDmpStepsSvcUtlConfig.class})
public class ResearchReportEmailSvcRunIT {
    @Autowired
    private ResearchReportEmailSvc researchReportEmailSvc;

    @Autowired
    private WorkspaceUtil workspaceUtil;

    @Rule
    public ExpectedException thrown = ExpectedException.none();

    @BeforeClass
    public static void setUpclass() {
        CartDmpTestConfig.configureLogging(ResearchReportEmailSvcRunIT.class);
    }

    @Before
    public void before() {
        workspaceUtil.setBaseDir(System.getProperty("user.dir"));
    }

    @Test
    public void testgenerateEmailBody() {

        String EMAIL_FILES_TEMPLATE_PATH = "src/test/resources/email/DEQTemplate.txt";
        String EMAIL_FILES_BODY_PATH = "target/test-classes/email";
        Map<String, String> testMap = new HashMap<>();
        testMap.put("CATEGORY", "TW DEQ Buy Sell");
        testMap.put("REPORT_DATE", "2018-10-07");
        testMap.put("LINK", "12345");
        testMap.put("CUSIP", "12345");
        testMap.put("TW_DEQ_Buy_Sell", "Buy");
        testMap.put("Target_Price_Lower", "2345");
        testMap.put("Target_Price_Upper", "5678");
        testMap.put("PRICE", "100");
        String emailbodyFilename = researchReportEmailSvc.generateEmailBody(EMAIL_FILES_TEMPLATE_PATH, EMAIL_FILES_BODY_PATH, testMap);
        Assert.assertEquals(emailbodyFilename.equals(null), false);
    }

}
