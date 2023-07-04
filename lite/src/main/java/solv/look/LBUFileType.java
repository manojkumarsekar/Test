package com.eastspring.qa.solvency.lookup;

public enum LBUFileType {
    PORTFOLIO("portfolio"),
    POSITION("position"),
    FXRATECOMPARISON_REPORT("FX Rate Comparison Reports");
    public final String type;

    private LBUFileType(String type) {
        this.type = type;
    }
}