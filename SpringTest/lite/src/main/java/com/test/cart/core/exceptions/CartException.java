package com.eastspring.qa.cart.core.exceptions;

import com.eastspring.qa.cart.core.report.CartLogger;
import org.slf4j.helpers.MessageFormatter;

/**
 *
 * @author Daniel Baktiar
 * @since 2017-09
 */
public class CartException extends RuntimeException {

    private final CartExceptionType exceptionType;

    public CartException(CartExceptionType exceptionType, String message, Object... args) {
        super(MessageFormatter.arrayFormat(message, args).getMessage());
        CartLogger.error("[CartException]" + message, args);
        this.exceptionType = exceptionType;
    }

    public CartException(Throwable throwable, CartExceptionType exceptionType, String message, Object... args) {
        super(MessageFormatter.arrayFormat(message, args).getMessage(), throwable);
        CartLogger.error(message, throwable, args);
        this.exceptionType = exceptionType;
    }

    public CartException(CartExceptionType exceptionType, Throwable throwable) {
        super(throwable);
        CartLogger.error(this.getMessage());
        this.exceptionType = exceptionType;
    }

    public CartExceptionType getExceptionType() {
        return exceptionType;
    }
}