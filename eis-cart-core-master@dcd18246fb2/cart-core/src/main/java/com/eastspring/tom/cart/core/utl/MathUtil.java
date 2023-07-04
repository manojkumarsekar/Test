package com.eastspring.tom.cart.core.utl;


import com.eastspring.tom.cart.core.CartException;
import com.eastspring.tom.cart.core.CartExceptionType;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import javax.script.ScriptEngine;
import javax.script.ScriptEngineManager;

/**
 * @author Akshat R
 * @since 2019-04
 */

public class MathUtil {

    private static final Logger LOGGER = LoggerFactory.getLogger(MathUtil.class);
    public static final String EXPRESSION_ENTERED_IS_INVALID = "Expression [{}] entered is invalid";

    public String computeExpression(final String mathExpression) {
        ScriptEngine scriptEngine = new ScriptEngineManager().getEngineByName("JavaScript");
        try {
            LOGGER.debug("using user expression [{}] for computation", mathExpression);
            Object eval = scriptEngine.eval(mathExpression);
            return eval.toString();

        } catch (Exception e) {
            LOGGER.error(EXPRESSION_ENTERED_IS_INVALID, mathExpression, e);
            throw new CartException(CartExceptionType.PROCESSING_FAILED, EXPRESSION_ENTERED_IS_INVALID, mathExpression);
        }
    }

}
