package com.eastspring.tom.cart.dmp.mdl;

import com.fasterxml.jackson.annotation.JsonIgnoreProperties;
import com.fasterxml.jackson.dataformat.xml.annotation.JacksonXmlProperty;

@JsonIgnoreProperties(ignoreUnknown = true)
public class FxTrade extends BrsTrade {

    @JacksonXmlProperty(localName = "DESC_INSTMT")
    private String descInstrument;

    @JacksonXmlProperty(localName = "FX_PAY_AMT")
    private String fxPayAmt;

    @JacksonXmlProperty(localName = "FX_PAY_CURR")
    private String fxPayCurr;

    @JacksonXmlProperty(localName = "FX_PRICE")
    private String fxPrice;

    @JacksonXmlProperty(localName = "FX_PRICE_SPOT")
    private String fxPriceSpot;

    @JacksonXmlProperty(localName = "FX_RCV_AMT")
    private String fxRcvAmt;

    @JacksonXmlProperty(localName = "FX_RCV_CURR")
    private String fxRcvCurr;

    @JacksonXmlProperty(localName = "SM_CURRENCY")
    private String smCurrency;

    public String getDescInstrument() {
        return descInstrument;
    }

    public String getFxPayAmt() {
        return fxPayAmt;
    }

    public String getFxPayCurr() {
        return fxPayCurr;
    }

    public String getFxPrice() {
        return fxPrice;
    }

    public String getFxPriceSpot() {
        return fxPriceSpot;
    }

    public String getFxRcvAmt() {
        return fxRcvAmt;
    }

    public String getFxRcvCurr() {
        return fxRcvCurr;
    }

    public String getSmCurrency() {
        return smCurrency;
    }
}
