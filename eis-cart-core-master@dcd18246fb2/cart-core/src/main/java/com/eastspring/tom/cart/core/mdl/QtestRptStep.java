package com.eastspring.tom.cart.core.mdl;

import org.apache.commons.lang3.builder.ToStringBuilder;

public class QtestRptStep {
    private final String name;
    private final boolean status;
    private final String errorMessage;

    public QtestRptStep(final String name, final boolean status, final String errorMessage) {
        this.name = name;
        this.status = status;
        this.errorMessage = errorMessage;
    }

    public String getName() {
        return name;
    }

    public boolean getStatus() {
        return status;
    }

    public String getErrorMessage(){
        return errorMessage;
    }

    public String toString() {
        return ToStringBuilder.reflectionToString(this);
    }
}
