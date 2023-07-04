package com.eastspring.tom.cart.dmp.mdl;

import com.fasterxml.jackson.annotation.JsonIgnoreProperties;
import com.fasterxml.jackson.dataformat.xml.annotation.JacksonXmlProperty;

@JsonIgnoreProperties(ignoreUnknown = true)
public class BondTrade extends BrsTrade {

    @JacksonXmlProperty(localName = "ACCRUAL_DT")
    private String accrualDate;

    @JacksonXmlProperty(localName = "CPN_TYPE")
    private String cpnType;

    @JacksonXmlProperty(localName = "EXEC_TIME_SOURCE")
    private String execTimeSrc;

    @JacksonXmlProperty(localName = "FIRST_PAY_DT")
    private String firstPayDt;

    @JacksonXmlProperty(localName = "MATURITY")
    private String maturity;

    @JacksonXmlProperty(localName = "SM_COUPON_FREQ")
    private String smCouponFreq;

    @JacksonXmlProperty(localName = "TRD_INTEREST")
    private String trdInterest;

    public String getAccrualDate() {
        return accrualDate;
    }

    public String getCpnType() {
        return cpnType;
    }

    public String getExecTimeSrc() {
        return execTimeSrc;
    }

    public String getFirstPayDt() {
        return firstPayDt;
    }

    public String getMaturity() {
        return maturity;
    }

    public String getSmCouponFreq() {
        return smCouponFreq;
    }

    public String getTrdInterest() {
        return trdInterest;
    }
}
