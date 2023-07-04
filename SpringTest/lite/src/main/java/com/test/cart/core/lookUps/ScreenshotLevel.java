package com.eastspring.qa.cart.core.lookUps;

public enum ScreenshotLevel {
    ALWAYS("ALWAYS"),
    NEVER("NEVER"),
    ON_FAILURE("ON_FAILURE");

    public final String name;

    private ScreenshotLevel(String name) {
        this.name = name;
    }
}