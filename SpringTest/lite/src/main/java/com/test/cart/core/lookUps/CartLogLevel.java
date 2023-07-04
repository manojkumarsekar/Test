package com.eastspring.qa.cart.core.lookUps;

public enum CartLogLevel {
    DEBUG("DEBUG", 1),
    INFO("INFO", 2),
    WARN("WARN", 3),
    ERROR("ERROR", 4);

    public final String name;
    public final int level;

    private CartLogLevel(String name, int level) {
        this.name = name;
        this.level = level;
    }
}