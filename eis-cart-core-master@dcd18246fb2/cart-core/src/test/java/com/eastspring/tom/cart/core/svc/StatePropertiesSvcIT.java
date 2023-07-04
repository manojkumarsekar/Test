package com.eastspring.tom.cart.core.svc;

import com.eastspring.tom.cart.core.CartCoreTestConfig;
import com.eastspring.tom.cart.core.utl.WorkspaceUtil;
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

import static org.junit.Assert.*;

@RunWith(SpringJUnit4ClassRunner.class)
@ContextConfiguration(classes = {CartCoreSvcUtlTestConfig.class})
public class StatePropertiesSvcIT {

    private static final Logger LOGGER = LoggerFactory.getLogger(StatePropertiesSvcIT.class);

    @Autowired
    private StateSvc stateSvc;

    @Autowired
    private WorkspaceUtil workspaceUtil;

    @Autowired
    private WorkspaceDirSvc workspaceDirSvc;

    @Autowired
    private StatePropertiesSvc statePropertiesSvc;

    @Rule
    public ExpectedException thrown = ExpectedException.none();

    @BeforeClass
    public static void initLogging() {
        CartCoreTestConfig.configureLogging(StatePropertiesSvcIT.class);
    }

    @Test
    public void testGetValueStringMapFromPrefix() {
        workspaceUtil.setBaseDir(System.getProperty("user.dir"));
        statePropertiesSvc.loadProperties();
        Map<String, String> result = statePropertiesSvc.getGlobalMapValueFromPrefix("default.template.param", false);
        assertNotNull(result);
        assertEquals("test", result.get("USER"));
        assertEquals("pass@1234", result.get("PWD"));
    }

    @Test
    public void testGetValueStringMapFromPrefix_Zero() {
        workspaceUtil.setBaseDir(System.getProperty("user.dir"));
        statePropertiesSvc.loadProperties();
        Map<String, String> result = statePropertiesSvc.getGlobalMapValueFromPrefix("default.test.invalid", false);
        assertEquals(0, result.size());
    }

}
