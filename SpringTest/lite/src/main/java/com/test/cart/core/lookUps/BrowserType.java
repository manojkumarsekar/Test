package com.eastspring.qa.cart.core.lookUps;

public enum BrowserType {
    CHROME("CHROME"),
    IE("IE"),
    FIREFOX("FIREFOX");

    public final String name;

    private BrowserType(String name) {
        this.name = name;
    }
}