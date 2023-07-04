package com.eastspring.qa.cart.core.utils.datetime;

import com.eastspring.qa.cart.core.report.CartLogger;
import com.eastspring.qa.cart.core.exceptions.CartException;
import com.eastspring.qa.cart.core.exceptions.CartExceptionType;
import com.google.common.base.Strings;
import org.joda.time.DateTimeUtils;
import org.joda.time.LocalDateTime;
import org.joda.time.format.DateTimeFormat;
import org.joda.time.format.DateTimeFormatter;



public class DateTimeUtil {

    private static final DateTimeFormatter ISO_DATE = DateTimeFormat.forPattern("yyyy-MM-dd");

    public long currentTimeMillis() {
        return DateTimeUtils.currentTimeMillis();
    }

    public String getTimestamp() {
        DateTimeFormatter formatter = DateTimeFormat.forPattern("YMdHmsS");
        return formatter.print(new LocalDateTime());
    }

    public String getTimestamp(String format) {
        try {
            synchronized (this) {
                Thread.sleep(100);
            }
            return DateTimeFormat.forPattern(format).print(new LocalDateTime());
        } catch (IllegalArgumentException | InterruptedException e) {
            throw new CartException(e, CartExceptionType.INVALID_PARAM, "getTimestamp(): Invalid pattern specification");
        }
    }


    public String convertDateFormat(String date, String srcFormat, String dstFormat) {
        if (Strings.isNullOrEmpty(date)) {
            throw new CartException(CartExceptionType.INVALID_PARAM, "Date to be converted must not be blank or null");
        }
        try {
            final DateTimeFormatter srcParser = DateTimeFormat.forPattern(srcFormat);
            final DateTimeFormatter dstFormatter = DateTimeFormat.forPattern(dstFormat);
            return dstFormatter.print(srcParser.parseDateTime(date));
        } catch (IllegalArgumentException e) {
            throw new CartException(e, CartExceptionType.INVALID_PARAM, "convertDateFormat(): IO Error");
        }
    }

    public String updateDateAndChangeFormat(String date, String modifier, String srcFormat, String dstFormat) {
        String localDateFormat = "yyyy-MM-dd";
        DateTimeFormatter localDateParser = DateTimeFormat.forPattern(localDateFormat);
        String localDate = convertDateFormat(date, srcFormat, localDateFormat);
        CartLogger.debug("updateDateAndChangeFormat: date {} converted into local format [{}]", date, localDate);
        int numberToUpdate;

        modifier = modifier.toLowerCase();

        if (!modifier.matches("[\\+|-]\\d{1,3}[d|m|y]")) {
            CartLogger.error("updateDateAndChangeFormat(): modifiers should be in [\\+|-]\\d{1,3}[d|m|y] format");
            throw new CartException(CartExceptionType.UNSUPPORTED_ENCODING, "updateDateAndChangeFormat(): modifiers should be in [\\+|-]\\d{1,3}[d|m|y] format");
        }

        final String indicator = modifier.substring(0, 1);
        final String param = String.valueOf(modifier.charAt(modifier.length() - 1));

        if (param.equals("d")) {
            numberToUpdate = Integer.parseInt(modifier.substring(1, modifier.indexOf('d')));
            localDate = indicator.equals("+") ? localDateParser.parseLocalDate(localDate).plusDays(numberToUpdate).toString() :
                    localDateParser.parseLocalDate(localDate).minusDays(numberToUpdate).toString();
        } else if (param.equals("m")) {
            numberToUpdate = Integer.parseInt(modifier.substring(1, modifier.indexOf('m')));
            localDate = indicator.equals("+") ? localDateParser.parseLocalDate(localDate).plusMonths(numberToUpdate).toString() :
                    localDateParser.parseLocalDate(localDate).minusMonths(numberToUpdate).toString();
        } else if (param.equals("y")) {
            numberToUpdate = Integer.parseInt(modifier.substring(1, modifier.indexOf('y')));
            localDate = indicator.equals("+") ? localDateParser.parseLocalDate(localDate).plusYears(numberToUpdate).toString() :
                    localDateParser.parseLocalDate(localDate).minusYears(numberToUpdate).toString();
        }
        return convertDateFormat(localDate, localDateFormat, dstFormat);
    }


    /**
     * <p>This method validate an ISO date in the format yyyy-MM-dd. It throws exception if the date format is not as expected.</p>
     *
     * @param dateString date string to be validated
     */
    public void validateIsoDate(String dateString) {
        try {
            ISO_DATE.parseDateTime(dateString);
        } catch (IllegalArgumentException e) {
            throw new CartException(CartExceptionType.ASSERTION_ERROR, "Report End Date [{}] is not in the expected format of [yyyy-MM-dd]", dateString);
        }
    }
}