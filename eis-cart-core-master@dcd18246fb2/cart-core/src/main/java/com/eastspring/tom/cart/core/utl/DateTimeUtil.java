package com.eastspring.tom.cart.core.utl;

import com.eastspring.tom.cart.core.CartException;
import com.eastspring.tom.cart.core.CartExceptionType;
import com.google.common.base.Strings;
import org.joda.time.DateTimeUtils;
import org.joda.time.LocalDateTime;
import org.joda.time.format.DateTimeFormat;
import org.joda.time.format.DateTimeFormatter;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

public class DateTimeUtil {
    private static final Logger LOGGER = LoggerFactory.getLogger(DateTimeUtil.class);

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
            LOGGER.error("getTimestamp(): Invalid pattern specification", e);
            throw new CartException(e, CartExceptionType.IO_ERROR, "getTimestamp(): Invalid pattern specification");
        }
    }


    public String convertDateFormat(String date, String srcFormat, String dstFormat) {
        if (Strings.isNullOrEmpty(date)) {
            LOGGER.error("Date to be converted must not be blank or null");
            throw new CartException(CartExceptionType.INCOMPLETE_PARAMS, "Date to be converted must not be blank or null");
        }
        try {
            final DateTimeFormatter srcParser = DateTimeFormat.forPattern(srcFormat);
            final DateTimeFormatter dstFormatter = DateTimeFormat.forPattern(dstFormat);
            return dstFormatter.print(srcParser.parseDateTime(date));
        } catch (IllegalArgumentException e) {
            LOGGER.error("convertDateFormat(): IO Error [{}]", e);
            throw new CartException(CartExceptionType.IO_ERROR, "convertDateFormat(): IO Error");
        }
    }

    public String updateDateAndChangeFormat(String date, String modifier, String srcFormat, String dstFormat) {
        String localDateFormat = "yyyy-MM-dd";
        DateTimeFormatter localDateParser = DateTimeFormat.forPattern(localDateFormat);
        String localDate = convertDateFormat(date, srcFormat, localDateFormat);
        LOGGER.debug("updateDateAndChangeFormat: date {} converted into local format [{}]", date, localDate);
        int numberToUpdate;

        modifier = modifier.toLowerCase();

        if (!modifier.matches("[\\+|-]\\d{1,3}[d|m|y]")) {
            LOGGER.error("updateDateAndChangeFormat(): modifiers should be in [\\+|-]\\d{1,3}[d|m|y] format");
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
            LOGGER.error("Report End Date [{}] is not in the expected format of [yyyy-MM-dd]", dateString, e);
            throw new CartException(CartExceptionType.VALIDATION_FAILED, "Report End Date [{}] is not in the expected format of [yyyy-MM-dd]", dateString);
        }
    }
}
