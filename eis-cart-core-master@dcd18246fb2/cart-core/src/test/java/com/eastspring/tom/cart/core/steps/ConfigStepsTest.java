package com.eastspring.tom.cart.core.steps;

import com.eastspring.tom.cart.core.CartCoreTestConfig;
import com.eastspring.tom.cart.core.CartException;
import com.eastspring.tom.cart.core.svc.StateSvc;
import com.eastspring.tom.cart.core.utl.DateTimeUtil;
import com.eastspring.tom.cart.core.utl.StringVerifyUtil;
import org.junit.Before;
import org.junit.BeforeClass;
import org.junit.Rule;
import org.junit.Test;
import org.junit.rules.ExpectedException;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.MockitoAnnotations;
import org.mockito.invocation.InvocationOnMock;
import org.mockito.stubbing.Answer;

import static org.mockito.ArgumentMatchers.anyString;
import static org.mockito.ArgumentMatchers.eq;
import static org.mockito.Mockito.doNothing;
import static org.mockito.Mockito.times;
import static org.mockito.Mockito.verify;
import static org.mockito.Mockito.when;

public class ConfigStepsTest {
    @InjectMocks
    private ConfigSteps steps;

    @Mock
    private StateSvc stateSvc;

    @Mock
    private DateTimeUtil dateTimeUtil;

    @Mock
    private StringVerifyUtil stringVerifyUtil;

    @Rule
    public ExpectedException thrown = ExpectedException.none();

    @BeforeClass
    public static void initLogging() {
        CartCoreTestConfig.configureLogging(ConfigStepsTest.class);
    }

    @Before
    public void initMocks() {
        MockitoAnnotations.initMocks(this);
    }

    @Test
    public void testAssignValueToVar_success() {
        when(stateSvc.expandVar("a")).thenReturn("c");
        steps.assignValueToVar("a", "b");
        verify(stateSvc, times(1)).setStringVar("b", "c");
    }

    @Test
    public void testGenerateUuidANdStoreInVariable() throws Exception {
        when(stateSvc.expandVar(anyString())).thenAnswer(new Answer<String>() {
            @Override
            public String answer(InvocationOnMock invocationOnMock) throws Throwable {
                Object[] args = invocationOnMock.getArguments();
                return (String) args[0];
            }
        });
        steps.generateUuidAndStoreInVariable("abc");
        verify(stateSvc).setStringVar(eq("abc"), anyString());
    }

    @Test
    public void testUseNamedEnvironment() throws Exception {
        steps.useNamedEnvironment("ABC");
        verify(stateSvc).useNamedEnvironment("ABC");
    }

    @Test
    public void testAssignFormattedValueToVar() {
        String format = "DD-MM-YYYY";
        when(dateTimeUtil.getTimestamp(format)).thenReturn("16-01-2018");
        steps.assignFormattedDateToVar(format, "var_date");
        verify(stateSvc, times(1)).setStringVar("var_date", "16-01-2018");
    }

    @Test
    public void testAssignFormattedValueToVar_NagativeCase() {
        thrown.expect(CartException.class);
        thrown.expectMessage("dateFormat should be valid and is mandatory");
        String format = "";
        when(dateTimeUtil.getTimestamp(format)).thenReturn("16-01-2018");
        steps.assignFormattedDateToVar(format, "var_date");
    }

    @Test
    public void testModifyDateAndConvertFormat() {
        final String dateVar = "${date_var}";
        final String expandVar = "01-04-2018";
        when(stateSvc.expandVar(dateVar)).thenReturn(expandVar);
        when(dateTimeUtil.updateDateAndChangeFormat(expandVar, "+1d", "dd-MM-yyyy", "dd-MM-yyyy")).thenReturn("02-04-2018");
        steps.modifyDateAndConvertFormat(dateVar, "+1d", "dd-MM-yyyy", "dd-MM-yyyy", "output_var");
        verify(stateSvc, times(1)).setStringVar("output_var", "02-04-2018");
    }

    @Test
    public void testModifyDateAndConvertFormat_withSrcTrgtException() {
        thrown.expectMessage("Cannot accept source [${date_var}] and target [date_var] variable with same name");
        thrown.expect(CartException.class);
        String dateVar = "${date_var}";
        when(stateSvc.expandVar(dateVar)).thenReturn("01-04-2018");
        steps.modifyDateAndConvertFormat(dateVar, "+1d", "dd-MM-yyyy", "dd-MM-yyyy", "date_var");
    }

    @Test
    public void testVerifyValuesEqual() {
        when(stateSvc.expandVar("${var1}")).thenReturn("val1");
        when(stateSvc.expandVar("${var2}")).thenReturn("val1");
        doNothing().when(stringVerifyUtil).match("val1", "val2");
        steps.verifyValuesEqual("${var1}", "${var2}");
    }

    @Test
    public void testRemoveVar() {
        when(stateSvc.expandVar("var")).thenReturn("var");
        steps.removeVar("var");
        verify(stateSvc, times(1)).removeStringVar("var");
    }
}
