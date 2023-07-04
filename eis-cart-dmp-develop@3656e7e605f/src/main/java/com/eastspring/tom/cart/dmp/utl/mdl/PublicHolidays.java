package com.eastspring.tom.cart.dmp.utl.mdl;

import java.util.Arrays;
import java.util.Collections;
import java.util.List;

/**
 * It contains a List of Public Holidays in ISO format for 2018 and 2019 years.
 * http://www.mom.gov.sg/newsroom/press-releases/2017/0405-singapore-public-holidays-2018
 * http://www.mom.gov.sg/newsroom/press-releases/2018/0404-public-holidays-for-2019
 */
public final class PublicHolidays {

    private PublicHolidays() {
    }

    public static final long RECORDED_PUBLIC_HOLIDAY_YEAR = 2021;
    public static final List<String> PUBLIC_HOLIDAYS = Collections.unmodifiableList(Arrays.asList
            (
                    "2018-01-01",
                    "2018-02-16",
                    "2018-02-17",
                    "2018-03-30",
                    "2018-05-01",
                    "2018-05-29",
                    "2018-06-15",
                    "2018-08-09",
                    "2018-08-22",
                    "2018-11-06",
                    "2018-12-25",
                    "2019-01-01",
                    "2019-02-05",
                    "2019-02-06",
                    "2019-04-19",
                    "2019-05-01",
                    "2019-05-19",
                    "2019-06-05",
                    "2019-08-09",
                    "2019-08-11",
                    "2019-10-27",
                    "2019-12-25",
                    "2020-01-01",
                    "2020-01-25",
                    "2020-01-26",
                    "2020-04-10",
                    "2020-05-01",
                    "2020-05-07",
                    "2020-05-24",
                    "2020-07-31",
                    "2020-08-09",
                    "2020-11-14",
                    "2020-12-25",
                    "2021-01-01",
                    "2021-02-12",
                    "2021-02-13",
                    "2021-04-02",
                    "2021-05-01",
                    "2021-05-13",
                    "2021-05-26",
                    "2021-07-20",
                    "2021-08-09",
                    "2021-11-04",
                    "2021-12-25"


            ));
}
