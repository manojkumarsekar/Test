package com.eastspring.tom.cart.dmp.utl.mdl;


import org.apache.commons.lang3.builder.ToStringBuilder;

/**
 *
 * @author Daniel Baktiar
 * @since 2017-09
 */
public class RowInfo {
    private String eventName;
    private String eventType;
    private String wsdlUrl;

    public String getEventName() {
        return eventName;
    }

    public void setEventName(String eventName) {
        this.eventName = eventName;
    }

    public String getEventType() {
        return eventType;
    }

    public void setEventType(String eventType) {
        this.eventType = eventType;
    }

    public String getWsdlUrl() {
        return wsdlUrl;
    }

    public void setWsdlUrl(String wsdlUrl) {
        this.wsdlUrl = wsdlUrl;
    }

    public String toString() {
        return ToStringBuilder.reflectionToString(this);
    }
}
