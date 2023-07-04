package com.eastspring.tom.cart.core.steps;

import com.eastspring.tom.cart.cfg.CartCoreConfig;
import com.eastspring.tom.cart.core.CartCoreTestConfig;
import com.eastspring.tom.cart.core.CartException;
import com.eastspring.tom.cart.core.svc.StateSvc;
import com.eastspring.tom.cart.core.utl.FileDirUtil;
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

import java.util.Arrays;
import java.util.Collections;

//https://regex101.com/
@RunWith( SpringJUnit4ClassRunner.class )
@ContextConfiguration( classes = {CartCoreConfig.class} )
public class ConfigStepsRunIT {

    private static final String TARGET_STRING = "abc\n" +
            "Fund size (mil) 300,428.3 \n" +
            "def\n" +
            "Fund size (nil) 200,428.3 ";

    @Autowired
    private ConfigSteps configSteps;

    @Autowired
    private StateSvc stateSvc;

    @Autowired
    private WorkspaceUtil workspaceUtil;

    @Autowired
    private FileDirUtil fileDirUtil;

    @Rule
    public ExpectedException thrown = ExpectedException.none();

    @BeforeClass
    public static void initLogging() {
        CartCoreTestConfig.configureLogging(ConfigStepsRunIT.class);
    }

    @Test
    public void testEvaluateRegExInTarget_caseSensitiveCheck() {
        thrown.expect(CartException.class);
        thrown.expectMessage("Evaluation|verification failed for [fund size \\(mil\\) 300,428.3] values at expected occurrence [1]");
        configSteps.evaluateRegExInTarget(TARGET_STRING, Collections.singletonList("fund size \\(mil\\) 300,428.3"), 1);
    }

    @Test
    public void testEvaluateRegExInTarget_noRegExInvolved_andValueAvailable() {
        configSteps.evaluateRegExInTarget(TARGET_STRING, Collections.singletonList("Fund size \\(mil\\) 300,428.3"), 1);
    }

    @Test
    public void testEvaluateRegExInTarget_noRegExInvolved_andValueNotAvailable() {
        thrown.expect(CartException.class);
        thrown.expectMessage("Evaluation|verification failed for [Fund size \\(nil\\) 300,428.3] values at expected occurrence [1]");
        configSteps.evaluateRegExInTarget(TARGET_STRING, Collections.singletonList("Fund size \\(nil\\) 300,428.3"), 1);
    }

    @Test
    public void testEvaluateRegExInTarget_noRegExInvolved_multipleList() {
        thrown.expect(CartException.class);
        thrown.expectMessage("Evaluation|verification failed for [Fund size \\(nil\\) 300,428.3] values at expected occurrence [1]");
        configSteps.evaluateRegExInTarget(TARGET_STRING, Arrays.asList("Fund size \\(nil\\) 300,428.3", "Fund size \\(mil\\) 300,428.3"), 1);
    }

    @Test
    public void testEvaluateRegExInTarget_occurrence1() {
        configSteps.evaluateRegExInTarget(TARGET_STRING, Collections.singletonList("^Fund size \\(REGEX{var1}\\) REGEX{var2}$"), 1);
        Assert.assertEquals("mil", stateSvc.getStringVar("var1"));
        Assert.assertEquals("300,428.3", stateSvc.getStringVar("var2"));
    }

    @Test
    public void testEvaluateRegExInTarget_occurrence2() {
        configSteps.evaluateRegExInTarget(TARGET_STRING, Collections.singletonList("^Fund size \\(REGEX{var1}\\) REGEX{var2}$"), 2);
        Assert.assertEquals("nil", stateSvc.getStringVar("var1"));
        Assert.assertEquals("200,428.3", stateSvc.getStringVar("var2"));
    }

    @Test
    public void testEvaluateRegExInTarget_occurrence3_notFound() {
        thrown.expect(CartException.class);
        thrown.expectMessage("Evaluation|verification failed for [^Fund size \\(REGEX{var1}\\) REGEX{var2}$] values at expected occurrence [3]");
        configSteps.evaluateRegExInTarget(TARGET_STRING, Collections.singletonList("^Fund size \\(REGEX{var1}\\) REGEX{var2}$"), 3);
    }

    @Test
    public void testEvaluateRegExInTarget_valueNotAvailable() {
        thrown.expect(CartException.class);
        thrown.expectMessage("Evaluation|verification failed for [^size \\(REGEX{var1}\\) REGEX{var2}$] values at expected occurrence [1]");
        configSteps.evaluateRegExInTarget(TARGET_STRING, Collections.singletonList("^size \\(REGEX{var1}\\) REGEX{var2}$"), 1);
    }

    @Test
    public void testEvaluateRegExInTarget_multilineEvaluation() {
        String str = fileDirUtil.readFileToString("target/test-classes/filedirutil/bbg_prices.out");
        configSteps.evaluateRegExInTarget(str, Collections.singletonList("(?s)START-OF-DATA\\r?\\nREGEX{var1}END-OF-DATA"), 1);
        Assert.assertTrue(stateSvc.getStringVar("var1").startsWith("LU0318949566"));
    }

    @Test
    public void testAssignValueToVar_readFromFile() {
        workspaceUtil.setBaseDir(System.getProperty("user.dir"));
        configSteps.assignValueToVar("file:target/test-classes/filedirutil/readFileToString.txt", "var1");
        Assert.assertTrue(stateSvc.getStringVar("var1").contains("a quick brown fox"));
    }

    @Test
    public void testReadJsonPathValueFromFile() {
        workspaceUtil.setBaseDir(System.getProperty("user.dir"));
        configSteps.readJsonPathValueFromFile("portfoliosByPortfolioId.4590.portfolioName", "target/test-classes/test.json", "portfolio");
        Assert.assertEquals("UAT_EASTSPRING Training 03", stateSvc.getStringVar("portfolio"));
    }

    @Test
    public void testReadJsonPathValueFromString() {
        workspaceUtil.setBaseDir(System.getProperty("user.dir"));
        String jsonContent = fileDirUtil.readFileToString("target/test-classes/test.json");
        configSteps.readJsonPathValueFromString("portfoliosByPortfolioId.4590.portfolioName", jsonContent, "portfolio");
        Assert.assertEquals("UAT_EASTSPRING Training 03", stateSvc.getStringVar("portfolio"));
    }



}

