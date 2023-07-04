package com.eastspring.tom.cart.constant;

public enum VndRequestType {

    EIS_SECMASTER("EIS_Secmaster"),
    EIS_ENTITYMASTERDETAIL("EIS_Entitymasterdetail"),
    EIS_FUNDAMENTALSTE("EIS_FundamentalsTE"),
    EIS_CLASSIFICATIONS("EIS_Classifications"),
    EITH_FUND_SECPRICE("EITH_Fund_SecPrice"),
    EITH_BM_PRICE("EITH_BM_Price");

    private String requestType;

    VndRequestType(String requestType) {
        this.requestType = requestType;
    }

    public String getRequestType() {
        return requestType;
    }
}
