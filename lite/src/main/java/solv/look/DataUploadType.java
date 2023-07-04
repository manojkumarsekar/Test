package com.eastspring.qa.solvency.lookup;

public enum DataUploadType {

    PORTFOLIO_DATAUPLOAD("Portfolio Data Upload"),
    POSITION_DATAUPLOAD("Position Data Upload");
    public final String uiText;

    private DataUploadType(String uiText) {
        this.uiText = uiText;
    }
}