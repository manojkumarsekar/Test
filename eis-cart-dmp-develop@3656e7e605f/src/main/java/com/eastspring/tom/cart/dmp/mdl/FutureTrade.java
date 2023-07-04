package com.eastspring.tom.cart.dmp.mdl;

import com.fasterxml.jackson.annotation.JsonIgnoreProperties;
import com.fasterxml.jackson.dataformat.xml.annotation.JacksonXmlProperty;

@JsonIgnoreProperties(ignoreUnknown = true)
public class FutureTrade extends BrsTrade {

    @JacksonXmlProperty(localName = "MATURITY")
    private String maturity;

    public String getMaturity() {
        return maturity;
    }

}
