package com.eastspring.tom.cart.constant;

public final class AssetType {

    private AssetType() {
    }

    public enum AssetShortCode {

        Equity("EQ"),
        Bond("FI"),
        EquityOption("EQOP"),
        Futures("FUT"),
        FXFwd("FXFW"),
        FXSpot("FXSP");

        private String shortCode;

        public String getAssetCode() {
            return this.shortCode;
        }

        AssetShortCode(String shortCode) {
            this.shortCode = shortCode;
        }
    }

    public static final String EQUITY = "Equity";
    public static final String BOND = "Bond";
    public static final String EQ_OPTIONS = "EquityOption";
    public static final String FUTURES = "Futures";
    public static final String FX_FWRDS = "FXFwd";
    public static final String FX_SPOTS = "FXSpot";

}
