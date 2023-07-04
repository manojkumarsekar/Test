package com.eastspring.tom.cart.core.utl;

import com.eastspring.tom.cart.core.CartException;
import com.eastspring.tom.cart.core.CartExceptionType;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

/**
 * @author Daniel Baktiar
 * @since 2017-09
 */
public class StringVerifyUtil {

    private static final Logger LOGGER = LoggerFactory.getLogger(StringVerifyUtil.class);

    public void match(String expected, String actual) {
        if (expected == null) {
            throw new CartException(CartExceptionType.VERIFICATION_FAILED, "string match expected, but expected is null");
        }
        if (actual == null) {
            throw new CartException(CartExceptionType.VERIFICATION_FAILED, "string match expected, but actual value given is null");
        }
        if (!expected.equals(actual)) {
            throw new CartException(CartExceptionType.VERIFICATION_FAILED, "string match expected, but expected [{}] does not match actual [{}]", expected, actual);
        }
    }

    public void notMatch(String expected, String actual) {
        if (expected.equals(actual)) {
            LOGGER.error("string match not expected, but expected [{}] matches with actual [{}]", expected, actual);
            throw new CartException(CartExceptionType.VERIFICATION_FAILED, "string match not expected, but expected [{}] matches with actual [{}]", expected, actual);
        }
    }

    public Map<String, String> compareKeyValuesFromMaps(final Map<String, String> actualKeyValues, final Map<String, String> expectedKeyValues) {
        Map<String, String> exceptions = new HashMap<>();
        for (Map.Entry<String, String> expected : expectedKeyValues.entrySet()) {
            String actualValue = actualKeyValues.get(expected.getKey());
            String expectedValue = expected.getValue();
            if (!expectedValue.equals(actualValue)) {
                exceptions.put(expected.getKey(), "Actual value is [" + actualValue + "] Expected Value is [" + expectedValue + "]");
            }
        }
        return exceptions;
    }


    public List<String> compareValuesFromLists(final List<String> actualValues, final List<String> expectedValue) {
        List<String> exceptions = new ArrayList<>();
        for (String expected : expectedValue) {
            if (!actualValues.contains(expected)) {
                exceptions.add("Expected Value [" + expected + "] is not available");
            }
        }
        return exceptions;
    }

    /**
     * Trim ascii 160 character string.
     * Ascii 160 character is equivalent to Alt. which is neither null or empty.
     * Special handling required to truncate this character.
     *
     * @param originalString the original string
     * @return the string
     */
    public String trimAscii160Character(final String originalString) {
        return originalString.replace('\u00A0', ' ').trim();
    }
}
