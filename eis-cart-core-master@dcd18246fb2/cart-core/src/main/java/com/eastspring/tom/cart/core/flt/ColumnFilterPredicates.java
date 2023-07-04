package com.eastspring.tom.cart.core.flt;

import com.eastspring.tom.cart.core.CartException;
import com.eastspring.tom.cart.core.CartExceptionType;
import com.google.common.base.Strings;
import org.joda.time.format.DateTimeFormat;
import org.joda.time.format.DateTimeFormatter;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import java.math.BigDecimal;
import java.math.RoundingMode;

/**
 * <p>
 * Column filter (initially for, but not limited to CSV files.
 * </p>
 */
public class ColumnFilterPredicates {
    private static final Logger LOGGER = LoggerFactory.getLogger(ColumnFilterPredicates.class);

    private static final String M_D_Y_H_M_S_A_DATE_PATTERN = "M/d/y H:m:s a";
    private static final String ISO_DATE_PATTERN = "yyyy-MM-dd";
    private static final DateTimeFormatter M_D_Y_H_M_S_A_DATE_FORMATTER = DateTimeFormat.forPattern(M_D_Y_H_M_S_A_DATE_PATTERN);
    private static final DateTimeFormatter ISO_DATE_FORMATTER = DateTimeFormat.forPattern(ISO_DATE_PATTERN);
    private static final int DEFAULT_BNP_PRECISION = 6;
    public static final String NUMBER_FORMAT_EXCEPTION_COLUMN_NUM = "NumberFormatException: [{}], columnNum: {}";

    private ColumnFilterPredicates() {
    }

    /**
     * <p>
     * This static method strip the percentage of given columns (regardless of column numbers).
     * </p>
     *
     * @param columnNum column number, a mandatory parameter but will be ignored.
     * @param value     value to be formatted
     * @return String the formatted string value
     */
    public static String stripPercentage(int columnNum, String value) { // NOSONAR
        String result;
        if (!Strings.isNullOrEmpty(value) && value.endsWith("%")) {
            result = value.substring(0, value.length() - 1);
        } else {
            result = value;
        }
        return result;
    }


    /**
     * <p>This static method convers date in the format of "12/31/17 11:57:00 PM" into "2017-12-31".</p>
     *
     * @param columnNum column number (the order of the column)
     * @param value     value to be formatted
     * @return String result
     */
    public static String convertMdyHmsaToIsoDate(int columnNum, String value) {
        String result;
        if (columnNum < 2) {
            result = value != null ? ISO_DATE_FORMATTER.print(M_D_Y_H_M_S_A_DATE_FORMATTER.parseDateTime(value)) : null;
        } else if (9 <= columnNum && columnNum != 20) {
            try {
                if (!Strings.isNullOrEmpty(value)) {
                    String lowerCaseValue = value.toLowerCase();
                    if (lowerCaseValue.contains("e")) {
                        result = BigDecimal.valueOf(Double.parseDouble(lowerCaseValue)).setScale(DEFAULT_BNP_PRECISION, RoundingMode.HALF_UP).toPlainString();
                    } else {
                        result = new BigDecimal(value).setScale(DEFAULT_BNP_PRECISION, RoundingMode.HALF_UP).toPlainString();
                    }
                } else {
                    result = "";
                }
            } catch (NumberFormatException e) {
                LOGGER.error(NUMBER_FORMAT_EXCEPTION_COLUMN_NUM, value, columnNum, e);
                throw new CartException(CartExceptionType.PROCESSING_FAILED, NUMBER_FORMAT_EXCEPTION_COLUMN_NUM, value, columnNum);
            }
        } else {
            result = value;
        }
        return result;
    }
}
