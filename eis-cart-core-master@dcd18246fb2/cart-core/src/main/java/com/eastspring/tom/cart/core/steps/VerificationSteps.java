package com.eastspring.tom.cart.core.steps;

import com.eastspring.tom.cart.core.svc.VerificationSvc;
import org.springframework.beans.factory.annotation.Autowired;

public class VerificationSteps {
    @Autowired
    private VerificationSvc verificationSvc;

    public void verifyNumericallyRelativeMatch(String numericText1, String numericText2, String toleranceText) {
        String num1 = numericText1.replaceAll(",", "");
        String num2 = numericText2.replaceAll(",", "");
        Double double1 = Double.parseDouble(num1);
        Double double2 = Double.parseDouble(num2);
        Double tolerance = Double.parseDouble(toleranceText);
        verificationSvc.verifyNumericallyRelativeMatch(double1, double2, tolerance);
    }
}
