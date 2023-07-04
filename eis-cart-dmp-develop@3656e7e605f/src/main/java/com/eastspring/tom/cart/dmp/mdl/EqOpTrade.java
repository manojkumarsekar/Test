package com.eastspring.tom.cart.dmp.mdl;

import com.fasterxml.jackson.annotation.JsonIgnoreProperties;
import com.fasterxml.jackson.dataformat.xml.annotation.JacksonXmlProperty;

@JsonIgnoreProperties(ignoreUnknown = true)
public class EqOpTrade extends BrsTrade {

    @JacksonXmlProperty(localName = "TRD_CONVEXITY")
    private String trdConvexity;

    @JacksonXmlProperty(localName = "MATURITY")
    private String maturity;

    @JacksonXmlProperty(localName = "TRD_DROP_RATE")
    private String trdDropRate;

    @JacksonXmlProperty(localName = "TRD_DURATION")
    private String trdDuration;

    public String getTrdDropRate() {
        return trdDropRate;
    }

    public String getTrdDuration() {
        return trdDuration;
    }

    public String getMaturity() {
        return maturity;
    }

    public String getTrdConvexity() {
        return trdConvexity;
    }
}
