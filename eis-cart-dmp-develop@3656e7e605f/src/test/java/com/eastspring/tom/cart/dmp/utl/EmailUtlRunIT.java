package com.eastspring.tom.cart.dmp.utl;

import com.eastspring.tom.cart.core.steps.ConfigSteps;
import com.eastspring.tom.cart.core.svc.StateSvc;
import com.eastspring.tom.cart.core.utl.WorkspaceUtil;
import com.eastspring.tom.cart.dmp.CartDmpTestConfig;
import com.eastspring.tom.cart.dmp.integration.CartDmpStepsSvcUtlConfig;
import java.util.HashMap;
import java.util.Map;
import javax.mail.Session;
import org.junit.*;
import org.junit.rules.ExpectedException;
import org.junit.runner.RunWith;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.test.context.ContextConfiguration;
import org.springframework.test.context.junit4.SpringJUnit4ClassRunner;

@RunWith(SpringJUnit4ClassRunner.class)
@ContextConfiguration(classes = {CartDmpStepsSvcUtlConfig.class})
public class EmailUtlRunIT {
    public static String RESOURCES_EMAIL_PATH = "src/test/resources/email";

    @Autowired
    private EmailUtl emailUtl;

    @Autowired
    private WorkspaceUtil workspaceUtil;

    @Autowired
    private ConfigSteps configSteps;

    @Autowired
    private StateSvc stateSvc;


    @Rule
    public ExpectedException thrown = ExpectedException.none();

    @BeforeClass
    public static void setUpclass() {
        CartDmpTestConfig.configureLogging(EmailUtlRunIT.class);
    }

    @Before
    public void before() {
        workspaceUtil.setBaseDir(System.getProperty("user.dir"));
    }

    @Test
    public void testsetSession() {
        Session session = emailUtl.setEmailSession();
        Assert.assertNotNull(session);
    }

    @Test
    public void testsendEmail() {
        stateSvc.setStringVar("outlook.email.username", "goldensource_svc");
        stateSvc.setStringVar("outlook.email.password", "XcPkJ23h");
        stateSvc.setStringVar("outlook.smtp.host", "mailsg.intranet.asia");
        stateSvc.setStringVar("outlook.smtp.port", "25");
        stateSvc.setStringVar("outlook.email.from", "no-reply@eastspring.com");
        stateSvc.setStringVar("outlook.email.to", "testautomation@eastspring.com");
        stateSvc.setStringVar("outlook.email.subject", "TestAutomation");
        emailUtl.sendEmail("target/test-classes/email/DEQTemplate.txt");
    }

    @Test
    public void testconstructEmailTemplateParamsFromMap() {
        Map<String, String> testMap = new HashMap<>();
        testMap.put("REASEARCH_CATEGORY", "Cat1");
        testMap.put("RESEARCH_PORTFOLIO", "TSTTT");
        testMap.put("RESEARCH_CUSIP", "12345");
        testMap.put("RESEARCH_DOMESTICTP_LOWER", "100");
        testMap.put("RESEARCH_DOMESTICTP_UPPER", "200");
        testMap.put("RESEARCH_PRICE", "100");
        emailUtl.constructEmailTemplateParamsFromMap(testMap);
    }
}
