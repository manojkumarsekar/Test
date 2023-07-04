package com.eastspring.tom.cart.core.svc;

import com.eastspring.tom.cart.core.CartException;
import com.eastspring.tom.cart.core.CartExceptionType;

public class VerificationSvc {
    public void verifyNumericallyRelativeMatch(Double double1, Double double2, Double tolerance) {
        if (Math.abs(double1 - double2) / Math.min(Math.abs(double1), Math.abs(double2)) > tolerance) {
            throw new CartException(CartExceptionType.VERIFICATION_FAILED, "numerical relative match failed");
        }
    }

}
