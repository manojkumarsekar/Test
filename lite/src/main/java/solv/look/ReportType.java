package com.eastspring.qa.solvency.lookup;

public enum ReportType {

    CIC_D1_D2O("CIC/D1/D2O"),
    GHO_INTEGRITY("GHO Integrity"),
    LBU_REPORTS("LBU Reports"),
    PORTFOLIO_DATAUPLOAD("Portfolio Data Upload"),
    POSITION_DATAUPLOAD("Position Data Upload"),
    GHO_Report("GHO Report"),
    GHO_REPORT_ICP("GHO Report ICP"),
    GHO_REPORT_INS("GHO Report INS"),
    GHO_REPORT_POR("GHO Report POR"),
    GHO_REPORT_TRP("GHO Report TRP"),
    REGIONAL_REPORT("Regional Report"),
    LBUCONSOL_REPORT("LBU and Consol data Comparison Reports"),
    FXRATECOMPARISON_REPORT("FX Rate Comparison Reports");

    public final String uiText;

    private ReportType(String uiText) {
        this.uiText = uiText;
    }
}