package com.eastspring.tom.cart.core.utl;

import com.eastspring.tom.cart.core.CartException;
import com.eastspring.tom.cart.core.CartExceptionType;

/**
 *
 * @author Daniel Baktiar
 * @since 2017-09
 */
public class NumericVerificationUtil {
    public void matchWithAbsError(float first, float second, float epsilon) {
        if(Math.abs(first - second) > epsilon) {
            throw new CartException(CartExceptionType.NUMERIC_VERIFICATION_FAILED, "numeric values absolute error match failed for[{}] and [{}]", first, second);
        }
    }

    public void matchWithAbsError(double first, double second, double epsilon) {
        if(Math.abs(first - second) > epsilon) {
            throw new CartException(CartExceptionType.NUMERIC_VERIFICATION_FAILED, "numeric values absolute error match failed for[{}] and [{}]", first, second);
        }
    }

    public void matchWithRelError(float first, float second, float epsilon) {
        float relError = Math.abs((first - second) / second);
        if (relError > epsilon) {
            throw new CartException(CartExceptionType.NUMERIC_VERIFICATION_FAILED, "numeric values relative error match failed for: [{}] and [{}]", first, second);
        }
    }

    public void matchWithRelError(double first, double second, double epsilon) {
        double relError = Math.abs((first - second) / second);
        if (relError > epsilon) {
            throw new CartException(CartExceptionType.NUMERIC_VERIFICATION_FAILED, "numeric values relative error match failed for: [{}] and [{}]", first, second);
        }
    }
}
