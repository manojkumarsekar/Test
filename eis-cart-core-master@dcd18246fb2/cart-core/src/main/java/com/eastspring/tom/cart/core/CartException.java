package com.eastspring.tom.cart.core;

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
        this.exceptionType = exceptionType;
    }

    public CartException(Throwable throwable, CartExceptionType exceptionType, String message, Object... args) {
        super(MessageFormatter.arrayFormat(message, args).getMessage(), throwable);
        this.exceptionType = exceptionType;
    }

    public CartException(CartExceptionType exceptionType, Throwable throwable) {
        super(throwable);
        this.exceptionType = exceptionType;
    }

    public CartExceptionType getExceptionType() {
        return exceptionType;
    }
}
