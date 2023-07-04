package com.eastspring.tom.cart.core.mdl;

import com.eastspring.tom.cart.core.CartException;
import com.eastspring.tom.cart.core.CartExceptionType;
import org.apache.commons.lang3.builder.ToStringBuilder;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

public class WebGenericOp {
    private static final Logger LOGGER = LoggerFactory.getLogger(WebGenericOp.class);

    public static final String OPCODE_XPATH = "xpath";
    public static final String OPCODE_ID = "id";
    public static final String OPCODE_XPATH_XY_PCT = "xpath-xy-pct";
    public static final String OPCODE_NAME = "name";
    public static final String OPCODE_CLASSNAME = "className";
    public static final String OPCODE_TAGNAME = "tagName";
    public static final String OPCODE_LINKTEXT = "linkText";
    public static final String OPCODE_CSSSELECTOR = "cssSelector";

    private String opCode;
    private String param1;
    private String param2;

    public static WebGenericOp parseString(String opSpecification) {
        LOGGER.debug("Object Specification = {}", opSpecification);
        if (opSpecification == null) {
            LOGGER.error("invalid op specification null");
            throw new CartException(CartExceptionType.INCOMPLETE_PARAMS, "invalid op specification null");
        }

        String[] splitString = opSpecification.split(":", opSpecification.startsWith(OPCODE_XPATH_XY_PCT) ? 3 : 2);
        if (splitString.length == 1) {
            LOGGER.error("missing opCode (xpath:,id:,xpath-pct:) in [{}]", opSpecification);
            throw new CartException(CartExceptionType.UNSATISFIED_IMPLICIT_ASSUMPTION, "missing opCode (xpath:,id:,xpath-pct:) in [{}]", opSpecification);
        }

        String opCode = splitString[0];
        String param1 = null;
        String param2 = null;

        if (splitString.length == 2) {
            param1 = splitString[1];
        } else if (splitString.length == 3) {
            param1 = splitString[1];
            param2 = splitString[2];
        }
        return new WebGenericOp(opCode, param1, param2);
    }

    public WebGenericOp(String opCode, String param1, String param2) {
        this.opCode = opCode;
        this.param1 = param1;
        this.param2 = param2;
    }

    public String getOpCode() {
        return opCode;
    }

    public String getParam1() {
        return param1;
    }

    public String getParam2() {
        return param2;
    }

    public String toString() {
        return ToStringBuilder.reflectionToString(this);
    }
}
