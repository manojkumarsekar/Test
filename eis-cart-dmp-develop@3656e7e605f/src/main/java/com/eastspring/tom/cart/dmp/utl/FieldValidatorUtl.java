package com.eastspring.tom.cart.dmp.utl;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.validation.Errors;

public class FieldValidatorUtl {

    private static final Logger LOGGER = LoggerFactory.getLogger(FieldValidatorUtl.class);

    public static <T> void validateEqual(
            final String field, final T expected, final T actual, final Errors e) {

        LOGGER.debug("Validating Equal condition for field [{}], expected [{}], actual [{}]", field, expected, actual);

        if (!expected.equals(actual)) {
            Object[] params = {expected, actual};
            e.rejectValue(field, "validation.field.mismatched", params, "Mismatched values.");
        }
    }

    public static <T> void validateNotNull(final String field, final T actual, final Errors e) {

        LOGGER.debug("Validating NotNull condition for field [{}], actual is [{}]", actual);

        if (actual == null) {
            Object[] params = {null};
            e.rejectValue(field, "validation.field.notnull", params, "Notnull check failed");
        }
    }

    public static <T> void validateRegEx(final String field, final T expectedRegEx, final T actual, final Errors e) {
        if (!String.valueOf(actual).matches(String.valueOf(expectedRegEx))) {
            Object[] params = {expectedRegEx, actual};
            e.rejectValue(field, "validation.field.regex.mismatched", params, "Mismatched values.");
        }
    }

    public static <T extends Comparable<T>> void validateGreaterOrEqualTo(final String field, final T value, final T comparator, final Errors e) {
        if (value != null && value.compareTo(comparator) < 0) {
            Object[] params = new Object[]{comparator};
            e.rejectValue(field, "validation.field.greaterOrEqual", params, String.format("Value should be greater than to equal to %s.", comparator));
        }
    }

    public static <T extends Comparable<T>> void validateGreaterThan(final String field, final T value, final T comparator, final Errors e) {
        if (value != null && value.compareTo(comparator) <= 0) {
            Object[] params = new Object[]{comparator};
            e.rejectValue(field, "validation.field.greater", params, String.format("Value should be greater than %s.", comparator));
        }
    }

    public static <T extends Comparable<T>> void validateLessThanOrEqualTo(final String field, final T value, final T comparator, final Errors e) {
        if (value != null && value.compareTo(comparator) > 0) {
            Object[] params = new Object[]{comparator};
            e.rejectValue(field, "validation.field.lessThanOrEqual", params, String.format("Value should be less than to equal to %s.", comparator));
        }
    }

    public static <T extends Comparable<T>> void validateLessThan(final String field, final T value, final T comparator, final Errors e) {
        if (value != null && value.compareTo(comparator) >= 0) {
            Object[] params = new Object[]{comparator};
            e.rejectValue(field, "validation.field.lessThan", params, String.format("Value should be less than %s.", comparator));
        }
    }
}
