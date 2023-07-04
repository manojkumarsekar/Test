package com.eastspring.tom.cart.dmp.mdl;

import com.fasterxml.jackson.annotation.JsonIgnoreProperties;
import com.fasterxml.jackson.dataformat.xml.annotation.JacksonXmlProperty;

@JsonIgnoreProperties(ignoreUnknown = true)
public class BrsTrade {

    @JacksonXmlProperty(localName = "DESK_TYPE")
    private String deskType;

    @JacksonXmlProperty(localName = "PORTFOLIOS_PORTFOLIO_NAME")
    private String portfolio;

    @JacksonXmlProperty(localName = "SM_SEC_GROUP")
    private String secGroup;

    @JacksonXmlProperty(localName = "SM_SEC_TYPE")
    private String secType;

    @JacksonXmlProperty(localName = "TOUCH_COUNT")
    private String touchCount;

    @JacksonXmlProperty(localName = "TRAN_TYPE")
    private String tranType;

    @JacksonXmlProperty(localName = "TRAN_TYPE1")
    private String tranType1;

    @JacksonXmlProperty(localName = "TRD_COUNTERPARTY")
    private String trdCounterParty;

    @JacksonXmlProperty(localName = "TRD_LOCATION")
    private String trdLocation;

    @JacksonXmlProperty(localName = "TRD_MODIFY_DATE")
    private String trdModifyDate;

    @JacksonXmlProperty(localName = "TRD_ORIG_ENTRY_DATE")
    private String trdOrigEntryDate;

    @JacksonXmlProperty(localName = "TRD_ORIG_FACE")
    private String trdOrgFace;

    @JacksonXmlProperty(localName = "TRD_PRICE")
    private String trdPrice;

    @JacksonXmlProperty(localName = "TRD_PRINCIPAL")
    private String trdPrincipal;

    @JacksonXmlProperty(localName = "TRD_TRADE_DATE")
    private String trdTradeDate;

    @JacksonXmlProperty(localName = "TRD_SETTLE_DATE")
    private String trdSettleDate;

    @JacksonXmlProperty(localName = "TRD_VERSION")
    private String trdVersion;

    @JacksonXmlProperty(localName = "UNITS")
    private String units;

    @JacksonXmlProperty(localName = "TRD_STATUS")
    private String trdStatus;

    @JacksonXmlProperty(localName = "INVNUM")
    private String invNum;

    @JacksonXmlProperty(localName = "ISIN")
    private String isin;

    @JacksonXmlProperty(localName = "SEDOL")
    private String sedol;

    @JacksonXmlProperty(localName = "CUSIP")
    private String cusip;

    @JacksonXmlProperty(localName = "FUND")
    private String fund;

    @JacksonXmlProperty(localName = "TRD_EX_BROKER_CODE")
    private String trdExBrokerCode;

    public String getTrdExBrokerCode() {
        return trdExBrokerCode;
    }

    public String getFund() {
        return fund;
    }

    public String getSedol() {
        return sedol;
    }

    public String getCusip() {
        return cusip;
    }

    public String getIsin() {
        return isin;
    }

    public String getInvNum() {
        return invNum;
    }

    public String getTrdStatus() {
        return trdStatus;
    }

    public String getTrdTradeDate() {
        return trdTradeDate;
    }

    public String getDeskType() {
        return deskType;
    }

    public String getPortfolio() {
        return portfolio;
    }

    public String getSecGroup() {
        return secGroup;
    }

    public String getSecType() {
        return secType;
    }

    public String getTouchCount() {
        return touchCount;
    }

    public String getTranType() {
        return tranType;
    }

    public String getTranType1() {
        return tranType1;
    }

    public String getTrdCounterParty() {
        return trdCounterParty;
    }

    public String getTrdLocation() {
        return trdLocation;
    }

    public String getTrdModifyDate() {
        return trdModifyDate;
    }

    public String getTrdOrigEntryDate() {
        return trdOrigEntryDate;
    }

    public String getTrdOrgFace() {
        return trdOrgFace;
    }

    public String getTrdPrice() {
        return trdPrice;
    }

    public String getTrdPrincipal() {
        return trdPrincipal;
    }

    public String getTrdSettleDate() {
        return trdSettleDate;
    }

    public String getTrdVersion() {
        return trdVersion;
    }

    public String getUnits() {
        return units;
    }
}
