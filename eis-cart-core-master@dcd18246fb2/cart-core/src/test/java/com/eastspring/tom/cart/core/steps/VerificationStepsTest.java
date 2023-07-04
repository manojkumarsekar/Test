package com.eastspring.tom.cart.core.steps;

import com.eastspring.tom.cart.core.CartCoreTestConfig;
import com.eastspring.tom.cart.core.svc.VerificationSvc;
import org.junit.Before;
import org.junit.BeforeClass;
import org.junit.Test;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.MockitoAnnotations;

import static org.mockito.Mockito.times;
import static org.mockito.Mockito.verify;

public class VerificationStepsTest {
    @InjectMocks
    private VerificationSteps steps;

    @Mock
    private VerificationSvc verificationSvc;

    @BeforeClass
    public static void initLogging() {
        CartCoreTestConfig.configureLogging(VerificationSteps.class);
    }

    @Before
    public void initMocks() {
        MockitoAnnotations.initMocks(this);
    }

    @Test
    public void testVerifyNumericallyRelativeMatch() throws Exception {
        String numericText1 = "23452.259";
        String numericText2 = "23552.263";
        String toleranceText = "0.0001";
        Double numericDouble1 = Double.parseDouble(numericText1);
        Double numericDouble2 = Double.parseDouble(numericText2);
        Double toleranceDouble = Double.parseDouble(toleranceText);
        steps.verifyNumericallyRelativeMatch(numericText1, numericText2, toleranceText);
        verify(verificationSvc, times(1)).verifyNumericallyRelativeMatch(numericDouble1, numericDouble2, toleranceDouble);
    }
}
