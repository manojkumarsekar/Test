package com.eastspring.qa.solvency.utils.common;

import com.eastspring.qa.cart.core.exceptions.CartException;
import com.eastspring.qa.cart.core.exceptions.CartExceptionType;
import stepdefinitions.Solvency.BaseSolvencySteps;

import java.util.Calendar;
import java.util.Date;

public class DateTimeUtil extends BaseSolvencySteps {

    public static Date getMonthEndDate(String targetMonth) {
        int monthInterval = 1;
        switch (targetMonth.toLowerCase()) {
            case "current-6":
                monthInterval = -6;
                break;
            case "current-5":
                monthInterval = -5;
                break;
            case "current":
                break;
            case "current-1":
            case "previous":
                monthInterval = -2;
                break;
            case "last":
                monthInterval = -1;
                break;
            default:
                throw new CartException(CartExceptionType.INVALID_PARAM,
                        "Input month-end target '[{}]' is invalid",
                        targetMonth);
        }
        Calendar aCalendar = Calendar.getInstance();
        aCalendar.add(Calendar.MONTH, monthInterval);
        aCalendar.set(Calendar.DATE, aCalendar.getActualMaximum(Calendar.DAY_OF_MONTH));
        return aCalendar.getTime();
    }

}