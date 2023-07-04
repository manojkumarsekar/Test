package com.eastspring.tom.cart.dmp.utl;

import com.eastspring.tom.cart.core.CartException;
import org.junit.Assert;
import org.junit.Before;
import org.junit.Rule;
import org.junit.Test;
import org.junit.rules.ExpectedException;
import org.mockito.InjectMocks;
import org.mockito.MockitoAnnotations;

public class BusinessDayUtlTest {

    @InjectMocks
    private BusinessDayUtl businessDayUtl;

    @Rule
    public ExpectedException thrown = ExpectedException.none();


    @Before
    public void setUp() throws Exception {
        MockitoAnnotations.initMocks(this);
    }

    @Test
    public void testIsDateWeekend_Saturday() throws Exception {
        String date = "2018-07-07";
        Assert.assertTrue(businessDayUtl.isDateWeekend(date));
    }

    @Test
    public void testIsDateWeekend_Sunday() throws Exception {
        String date = "2018-07-01";
        Assert.assertTrue(businessDayUtl.isDateWeekend(date));
    }

    @Test
    public void testIsDateWeekend_Weekday() throws Exception {
        String date = "2018-07-05";
        Assert.assertFalse(businessDayUtl.isDateWeekend(date));
    }

    @Test
    public void testIsDateWeekend_InvalidFormat() throws Exception {
        thrown.expect(CartException.class);
        thrown.expectMessage("Parsing Exception with Date [20180505]");
        String date = "20180505";
        Assert.assertFalse(businessDayUtl.isDateWeekend(date));
    }

    @Test
    public void testIsDatePublicHoliday_ValidPH() throws Exception {
        String date = "2018-12-25";
        Assert.assertTrue(businessDayUtl.isDatePublicHoliday(date));
    }

    @Test
    public void testIsDatePublicHoliday_InvalidPH() throws Exception {
        String date = "2018-12-24";
        Assert.assertFalse(businessDayUtl.isDatePublicHoliday(date));
    }

    @Test
    public void testIsDatePublicHoliday_DateOutOfRecordedRange() throws Exception {
        thrown.expect(CartException.class);
        thrown.expectMessage("Public Holidays for the year [2022] are not defined");
        String date = "2022-12-25";
        Assert.assertFalse(businessDayUtl.isDatePublicHoliday(date));
    }

}