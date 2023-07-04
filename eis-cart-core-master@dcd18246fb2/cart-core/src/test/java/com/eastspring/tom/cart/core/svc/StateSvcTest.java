package com.eastspring.tom.cart.core.svc;

import com.eastspring.tom.cart.core.CartCoreTestConfig;
import com.eastspring.tom.cart.core.utl.CredentialsUtil;
import com.eastspring.tom.cart.core.utl.WorkspaceUtil;
import org.junit.Assert;
import org.junit.Before;
import org.junit.BeforeClass;
import org.junit.Test;
import org.mockito.*;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import static org.mockito.Mockito.*;

public class StateSvcTest {

    private static final Logger LOGGER = LoggerFactory.getLogger(StateSvcTest.class);

    @Spy
    @InjectMocks
    private StateSvc stateSvc;

    @Mock
    private CredentialsUtil credentialsUtil;

    @Mock
    private StatePropertiesSvc statePropertiesSvc;

    @Mock
    private WorkspaceUtil workspaceUtil;

    @BeforeClass
    public static void initLogging() {
        CartCoreTestConfig.configureLogging(StateSvcTest.class);
    }

    @Before
    public void initMocks() {
        MockitoAnnotations.initMocks(this);
    }

    @Test
    public void testUseNamedEnvironment() {

    }

    @Test
    public void testGetStringVar() {
    }

    @Test
    public void testGetLongVar() {

    }

    @Test
    public void testExpandVarWithMultipleVars() {
        String expected ="Test_abc_def_xyz";
        String expression = "Test_${var1}_${var2}_${var3}";
        Mockito.when(workspaceUtil.getEnvDir()).thenReturn("c:/tomwork/cart-tests/config");
        doReturn("abc").when(stateSvc).getStringVar("var1");
        doReturn("def").when(stateSvc).getStringVar("var2");
        doReturn("xyz").when(stateSvc).getStringVar("var3");
        Assert.assertEquals(expected,stateSvc.expandVar(expression));
    }

    @Test
    public void testExpandVarWithSingleVarInString() {
        String expected ="Test_abc_def";
        String expression = "Test_${var1}_def";
        Mockito.when(workspaceUtil.getEnvDir()).thenReturn("c:/tomwork/cart-tests/config");
        doReturn("abc").when(stateSvc).getStringVar("var1");
        Assert.assertEquals(expected,stateSvc.expandVar(expression));
    }

    @Test
    public void testExpandVarWithSingleVarWithPassword() {
        String expected ="Test";
        String expression = "${var1.pass}";
        Mockito.when(workspaceUtil.getEnvDir()).thenReturn("c:/tomwork/cart-tests/config");
        doReturn("Test").when(stateSvc).getStringVar("var1.pass");
        Assert.assertEquals(expected,stateSvc.expandVar(expression));
    }

    @Test
    public void testExpandVarWithNoVarInExpression() {
        String expected ="Test";
        String expression = "Test";
        Mockito.when(workspaceUtil.getEnvDir()).thenReturn("c:/tomwork/cart-tests/config");
        Assert.assertEquals(expected,stateSvc.expandVar(expression));
    }

    @Test
    public void testExpandVarWithNull() {
        String expression = null;
        Mockito.when(workspaceUtil.getEnvDir()).thenReturn("c:/tomwork/cart-tests/config");
        String result = stateSvc.expandVar(expression);
        Assert.assertNull(result);
    }

    @Test
    public void testExpandVarWithNoVarInMap_full() {
        String expression = "${var1}";
        when(workspaceUtil.getEnvDir()).thenReturn("c:/tomwork/cart-tests/config");
        when(statePropertiesSvc.getGlobalPropsMap("var1")).thenReturn("");
        Assert.assertEquals("", stateSvc.expandVar(expression));
        verify(statePropertiesSvc, times(1)).populateGlobalPropsMap();
    }


    @Test
    public void testExpandVarWithNoVarInMap_partial() {
        String expression = "abc${var1}def";
        when(workspaceUtil.getEnvDir()).thenReturn("c:/tomwork/cart-tests/config");
        when(statePropertiesSvc.getGlobalPropsMap("var1")).thenReturn("");
        Assert.assertEquals("abcdef", stateSvc.expandVar(expression));
        verify(statePropertiesSvc, times(1)).populateGlobalPropsMap();
    }

    @Test
    public void testDumpVars() {

    }

    @Test
    public void testGetValueMapFromPrefix() {

    }

    @Test
    public void testGetValueStringMapFromPrefix() {

    }
}
