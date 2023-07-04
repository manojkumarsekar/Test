package com.eastspring.tom.cart.core.svc;

import com.eastspring.tom.cart.core.CartException;
import com.eastspring.tom.cart.core.CartExceptionType;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import java.util.HashMap;
import java.util.Map;
import java.util.function.Function;

public class StringFunctionSvc {
    private static final Logger LOGGER = LoggerFactory.getLogger(StringFunctionSvc.class);
    public static final String IDENTITY = "IDENTITY";

    private Map<String, Function<String, String>> functionMap = new HashMap<>();

    public StringFunctionSvc() {
        functionMap.put(IDENTITY, x -> x);
    }

    public Function<String, String> get(String name) {
        Function<String, String> result = functionMap.get(name);
        if(result == null) {
            LOGGER.error("unknown function name [{}]", name);
            throw new CartException(CartExceptionType.UNSATISFIED_IMPLICIT_ASSUMPTION, "unknown function name [{}]", name);
        }
        return functionMap.get(name);
    }
}
