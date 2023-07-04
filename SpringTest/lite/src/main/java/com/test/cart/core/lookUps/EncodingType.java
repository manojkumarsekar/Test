package com.eastspring.qa.cart.core.lookUps;

public enum EncodingType {
    UTF_8("UTF-8"),
    UTF_16("UTF-16");

    public final String name;

    private EncodingType(String name) {
        this.name = name;
    }
}