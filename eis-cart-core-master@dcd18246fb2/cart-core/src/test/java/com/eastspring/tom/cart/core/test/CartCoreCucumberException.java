package com.eastspring.tom.cart.core.test;

import cucumber.runtime.CucumberException;

public class CartCoreCucumberException extends CucumberException {
    public CartCoreCucumberException(String message) {
        super(message);
    }

    public CartCoreCucumberException(Throwable throwable) {
        super(throwable);
    }

    public CartCoreCucumberException(String message, Throwable throwable) {
        super(message, throwable);
    }
}
