package com.eastspring.tom.cart.core.svc;

import com.eastspring.tom.cart.core.CartCoreTestConfig;
import com.eastspring.tom.cart.core.CartException;
import com.eastspring.tom.cart.core.mdl.RegexVars;
import com.eastspring.tom.cart.core.utl.WorkspaceUtil;
import org.junit.Assert;
import org.junit.BeforeClass;
import org.junit.Rule;
import org.junit.Test;
import org.junit.rules.ExpectedException;
import org.junit.runner.RunWith;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.test.context.ContextConfiguration;
import org.springframework.test.context.junit4.SpringJUnit4ClassRunner;

import java.util.Map;

import static org.junit.Assert.assertEquals;
import static org.junit.Assert.assertNotNull;
import static org.junit.Assert.assertTrue;

@RunWith(SpringJUnit4ClassRunner.class)
@ContextConfiguration(classes = {CartCoreSvcUtlTestConfig.class})
public class StateSvcIT {

    private static final Logger LOGGER = LoggerFactory.getLogger(StateSvcIT.class);

    @Autowired
    private StateSvc stateSvc;

    @Autowired
    private WorkspaceUtil workspaceUtil;

    public static final String BRS_WEB_PASS_ENCRYPTED = "brs.web.pass.encrypted";
    public static final String BRS_WEB_PASS = "brs.web.pass";

    @Rule
    public ExpectedException thrown = ExpectedException.none();


    @BeforeClass
    public static void initLogging() {
        CartCoreTestConfig.configureLogging(StateSvcIT.class);
    }

    /**
     * When a <b>brs.web.pass.encrypted</b> exists int the state string var, but not <b>brs.web.pass</b> we expect
     * that the state service will automatically decrypt <b>brs.web.pass.encrypted</b> into <b>brs.web.pass</b> and
     * stored the result in the state string var.
     *
     * @throws Exception exception
     */
//    @Test
    // TODO: fix this
    public void testEncryptDecryptOfProperties() throws Exception {
        stateSvc.loadProperties();
        String encrypted = stateSvc.getStringVar(BRS_WEB_PASS_ENCRYPTED);
        LOGGER.info("encrypted: [{}]", encrypted);
        String decrypted = stateSvc.getStringVar(BRS_WEB_PASS);
        LOGGER.info("decrypted: [{}]", decrypted);
        stateSvc.useNamedEnvironment("TOM_DEV1");
    }

    @Test
    public void testDumpVars() {
        stateSvc.dumpVars();
    }

    //    @Test
    // TODO: fix this
    public void testLoadProperties() throws Exception {
        stateSvc.loadProperties();
        stateSvc.useNamedEnvironment("TOM_DEV1");
    }

    @Test
    public void testLoadProperties_failed() throws Exception {
        String envDir = workspaceUtil.getEnvDir();
        thrown.expect(CartException.class);
        thrown.expectMessage("failed when loading named environment [TOM_DEVX3] config from environment properties file [" + envDir + "/env_TOM_DEVX3.properties]");
        stateSvc.loadProperties();
        stateSvc.useNamedEnvironment("TOM_DEVX3");
    }

    //    @Test
    // TODO: fix this
    public void testGetValueMapFromPrefix() {
        stateSvc.loadProperties();
        stateSvc.useNamedEnvironment("TOM_DEV1");
        Map<String, String> valueMap = stateSvc.getValueMapFromPrefix("dmp.ssh.inbound", false);
        assertNotNull(valueMap);
        assertEquals(5, valueMap.size());
        assertEquals("vsgeisldapp07.pru.intranet.asia", valueMap.get("host"));
        assertEquals("22", valueMap.get("port"));
        assertEquals("jbossadm", valueMap.get("user"));
        assertEquals("+HA+jJ6rEP4HH/E2bpdJRyUUKhxgvkK10XmtghhKiug=", valueMap.get("pass.encrypted"));
        assertTrue(valueMap.containsKey("pass"));
    }

    @Test
    public void testGetValueStringMapFromPrefix() {
        stateSvc.loadProperties();
        stateSvc.setStringVar("abcd.def", "123");
        stateSvc.setStringVar("abcd.ghi", "456");
        stateSvc.setStringVar("abcd.jkl", "789");
        Map<String, String> result = stateSvc.getValueStringMapFromPrefix("abcd", false);
        assertNotNull(result);
        assertEquals(3, result.size());
        assertEquals("123", result.get("def"));
        assertEquals("456", result.get("ghi"));
        assertEquals("789", result.get("jkl"));
    }

    @Test
    public void testDebugLogVar() {
        stateSvc.loadProperties();
        stateSvc.setStringVar("abc", "def");
        stateSvc.setStringVar("ghi.pass", "we-are-not-supposed-to-see-this");
        stateSvc.debugLogVar("mno");
        stateSvc.debugLogVar("abc");
        stateSvc.debugLogVar("ghi.pass");
    }

    @Test
    public void testRemoveStringVar_ifExists() {
        stateSvc.loadProperties();
        final String varName = "abcd.def";
        final String varValue = "123";

        stateSvc.setStringVar(varName, varValue);
        Assert.assertEquals(varValue, stateSvc.getStringVar(varName));

        stateSvc.removeStringVar(varName);
        Assert.assertEquals("", stateSvc.getStringVar(varName));
    }

    @Test
    public void testRemoveStringVar_ifNotExists() {
        stateSvc.loadProperties();
        final String varName = "abcd.def";
        stateSvc.removeStringVar(varName);
        Assert.assertEquals("", stateSvc.getStringVar(varName));
    }

    @Test
    public void testExpandToRegExGroups_withTwoVars() {
        final String expression = "Fund size \\(REGEX{var1}\\) REGEX{var2}";
        final String expected = "Fund size \\((.*)\\) (.*)";

        RegexVars regexVars = stateSvc.expandToRegExGroups(expression);

        Assert.assertEquals(expected, regexVars.getExpression());
        Assert.assertEquals("var1", regexVars.getVars().get(0));
        Assert.assertEquals("var2", regexVars.getVars().get(1));
    }

    @Test
    public void testExpandToRegExGroups_withNoVars() {
        final String expression = "Fund size (mil) 300,428.3";
        final String expected = "Fund size (mil) 300,428.3";

        RegexVars regexVars = stateSvc.expandToRegExGroups(expression);

        Assert.assertEquals(expected, regexVars.getExpression());
        Assert.assertEquals(0, regexVars.getVars().size());
    }

    @Test
    public void testExpandToRegExGroups_withInvalidPattern() {
        final String expression = "Fund size \\(${var1}\\) ${var2}";
        final String expected = "Fund size \\(${var1}\\) ${var2}";

        RegexVars regexVars = stateSvc.expandToRegExGroups(expression);

        Assert.assertEquals(expected, regexVars.getExpression());
        Assert.assertEquals(0, regexVars.getVars().size());
    }

    @Test
    public void testExpandToRegExGroups_withVarInTheBeginning() {
        final String expression = "REGEX{var1} Fund size \\(REGEX{var2}\\)";
        final String expected = "(.*) Fund size \\((.*)\\)";

        RegexVars regexVars = stateSvc.expandToRegExGroups(expression);

        Assert.assertEquals(expected, regexVars.getExpression());
        Assert.assertEquals(2, regexVars.getVars().size());
    }

    @Test
    public void testExpandToRegExGroups_withNull() {
        final String expression = null;
        RegexVars regexVars = stateSvc.expandToRegExGroups(expression);
        Assert.assertNull(regexVars);
    }


}
