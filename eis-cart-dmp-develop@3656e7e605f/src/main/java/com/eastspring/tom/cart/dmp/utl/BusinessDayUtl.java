package com.eastspring.tom.cart.dmp.utl;

import com.eastspring.tom.cart.core.CartException;
import com.eastspring.tom.cart.core.CartExceptionType;
import com.eastspring.tom.cart.core.utl.DateTimeUtil;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;

import java.text.ParseException;
import java.text.SimpleDateFormat;
import java.time.LocalDate;
import java.util.Calendar;

import static com.eastspring.tom.cart.constant.TradeConstants.ISO_DATE_FORMAT;
import static com.eastspring.tom.cart.dmp.utl.mdl.PublicHolidays.PUBLIC_HOLIDAYS;
import static com.eastspring.tom.cart.dmp.utl.mdl.PublicHolidays.RECORDED_PUBLIC_HOLIDAY_YEAR;

public class BusinessDayUtl {

    private static final Logger LOGGER = LoggerFactory.getLogger(BusinessDayUtl.class);

    @Autowired
    private DateTimeUtil dateTimeUtil;

    /**
     * Adds an Integer to a Given date and returns Next Valid Business Day.
     * This function considers Public Holidays (As per Singapore MOM PH list)
     * defined in {@link com.eastspring.tom.cart.dmp.utl.mdl.PublicHolidays}
     * and Weekends.
     *
     * @param dateString in ISO Date format
     * @param increment  an Integer to add no. of days to the Given date
     * @return Valid Business Day
     */
    public String getNextBizDay(final String dateString, final Integer increment) {
        dateTimeUtil.validateIsoDate(dateString);
        if (increment == 0) {
            return dateString;
        }

        int counter = 1;
        String nextDate = this.incrementISODate(dateString, 1);
        while (counter <= increment) {
            if (!(this.isDateWeekend(nextDate) || this.isDatePublicHoliday(nextDate))) {
                counter++;
            }
            if (counter <= increment) {
                nextDate = this.incrementISODate(nextDate, 1);
            }
        }
        return nextDate;
    }

    /**
     * Is date weekend boolean.
     *
     * @param dateString the date string
     * @return the boolean
     */
    public boolean isDateWeekend(final String dateString) {
        try {
            Calendar calendar = Calendar.getInstance();
            calendar.setTime(new SimpleDateFormat(ISO_DATE_FORMAT).parse(dateString));
            int dayOfWeek = calendar.get(Calendar.DAY_OF_WEEK);
            boolean result = Calendar.SATURDAY == dayOfWeek || Calendar.SUNDAY == dayOfWeek;
            LOGGER.debug("Is Date [{}] Weekend ? ==> [{}]", dateString, result);
            return result;
        } catch (ParseException e) {
            LOGGER.error("Parsing Exception with Date [{}]", dateString);
            throw new CartException(CartExceptionType.UNSUPPORTED_ENCODING, "Parsing Exception with Date [{}]", dateString);
        }
    }

    /**
     * Is date public holiday boolean.
     *
     * @param dateString the date string
     * @return the boolean
     */
    public boolean isDatePublicHoliday(final String dateString) {
        int year = LocalDate.parse(dateString).getYear();

        if (year > RECORDED_PUBLIC_HOLIDAY_YEAR) {
            LOGGER.error("Public Holidays for the year [{}] are not defined", year);
            throw new CartException(CartExceptionType.UNDEFINED, "Public Holidays for the year [{}] are not defined", year);
        }
        boolean result = PUBLIC_HOLIDAYS.contains(dateString);
        LOGGER.debug("Is Date [{}] Public Holiday ? ==> [{}]", dateString, result);
        return result;
    }

    /**
     * Wrapper method to add a number to a date of ISO Format
     *
     * @param dateString
     * @param increment
     * @return the Date as String
     */
    private String incrementISODate(final String dateString, final Integer increment) {
        String nextDate = dateTimeUtil.updateDateAndChangeFormat(dateString, "+" + increment + "d", ISO_DATE_FORMAT, ISO_DATE_FORMAT);
        LOGGER.debug("Date [{}] incremented by 1 to [{}]", dateString, nextDate);
        return nextDate;
    }

}
