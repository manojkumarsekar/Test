package com.eastspring.tom.cart.core.steps;

import com.eastspring.tom.cart.core.CartCoreTestConfig;
import com.eastspring.tom.cart.core.mdl.RemoteOutput;
import com.eastspring.tom.cart.core.svc.ControlMSvc;
import org.junit.Before;
import org.junit.BeforeClass;
import org.junit.Test;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.MockitoAnnotations;

import static org.mockito.Mockito.verify;
import static org.mockito.Mockito.when;

public class ControlMStepsTest {
    private static final String EXPECTED_CMD_LINE = "/opt/controlm/ctm/exe/ctmorder -FOLDER ESI-APP-TOM-DEV-MISCELLANEOUS/DANIELTEST -NAME DANIELTEST -ODATE 20171001 -FORCE y -INTO_FOLDER_ORDERID ALONE";

    @InjectMocks
    private ControlMSteps steps;

    @Mock
    private ControlMSvc controlMSvc;

    @BeforeClass
    public static void setUpClass() {
        CartCoreTestConfig.configureLogging(ControlMSteps.class);
    }

    @Before
    public void initMocks() {
        MockitoAnnotations.initMocks(this);
    }

    @Test
    public void testExecuteControlMJob() {
        when(controlMSvc.getTodayOdate()).thenReturn("20171001");
        RemoteOutput output = new RemoteOutput("success", "");
        when(controlMSvc.runCliControlM(EXPECTED_CMD_LINE)).thenReturn(output);
        steps.executeControlMJob("DANIELTEST", "ESI-APP-TOM-DEV-MISCELLANEOUS/DANIELTEST");
        verify(controlMSvc).runCliControlM(EXPECTED_CMD_LINE);
    }
}
