package com.eastspring.tom.cart.constant;

public class ValidationError {

    private String gsoField;
    private String severity;
    private String validationMsg;

    public String getGsoField() {
        return gsoField;
    }

    public String getSeverity() {
        return severity;
    }

    public String getValidationMsg() {
        return validationMsg;
    }

    public ValidationError(String gsoField, String severity, String validationMsg) {
        this.gsoField = gsoField;
        this.severity = severity;
        this.validationMsg = validationMsg;
    }

    @Override
    public String toString() {
        return "GSO / Field : " + gsoField + ", Severity : " + severity + ", Validation Message : " + validationMsg;
    }
}
