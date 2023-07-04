package com.eastspring.qa.cart.core.lookUps;

//ToDo: enable rerun mode
public enum ExecutionMode {
    DEFAULT("DEFAULT");
//    RERUN("RERUN"),
//    DRY_RUN("DRY_RUN");

    public final String name;

    private ExecutionMode(String name) {
        this.name = name;
    }
}