package com.eastspring.tom.cart.dmp.utl;

import com.eastspring.tom.cart.core.CartException;
import com.eastspring.tom.cart.dmp.CartDmpTestConfig;
import com.eastspring.tom.cart.dmp.integration.CartDmpStepsSvcUtlConfig;
import org.junit.Assert;
import org.junit.BeforeClass;
import org.junit.Rule;
import org.junit.Test;
import org.junit.rules.ExpectedException;
import org.junit.runner.RunWith;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.test.context.ContextConfiguration;
import org.springframework.test.context.junit4.SpringRunner;

@RunWith(SpringRunner.class)
@ContextConfiguration(classes = {CartDmpStepsSvcUtlConfig.class})
public class BusinessDayUtlRunIT {

    @Autowired
    private BusinessDayUtl businessDayUtl;

    @BeforeClass
    public static void setUpClass() {
        CartDmpTestConfig.configureLogging(BusinessDayUtlRunIT.class);
    }

    @Rule
    public ExpectedException thrown = ExpectedException.none();

    @Test
    public void testGetNextBizDay_AddOneToFriday() {
        String date = "2018-07-06";
        Assert.assertEquals("2018-07-09", businessDayUtl.getNextBizDay(date, 1));
    }

    @Test
    public void testGetNextBizDay_AddTwoToFriday() {
        String date = "2018-07-06";
        Assert.assertEquals("2018-07-10", businessDayUtl.getNextBizDay(date, 2));
    }

    @Test
    public void testGetNextBizDay_AddTwoToMonday() {
        String date = "2018-07-09";
        Assert.assertEquals("2018-07-11", businessDayUtl.getNextBizDay(date, 2));
    }

    @Test
    public void testGetNextBizDay_AddZeroToMonday() {
        String date = "2018-07-09";
        Assert.assertEquals("2018-07-09", businessDayUtl.getNextBizDay(date, 0));
    }

    @Test
    public void testGetNextBizDay_WithPublicHolidays() {
        String date = "2018-12-24";
        Assert.assertEquals("2018-12-26", businessDayUtl.getNextBizDay(date, 1));
    }

    @Test
    public void testGetNextBizDay_WithPublicHolidaysAndWeekends() {
        String date = "2018-12-20";
        Assert.assertEquals("2018-12-26", businessDayUtl.getNextBizDay(date, 3));
    }

    @Test
    public void testGetNextBizDay_NotInISOFormat() {
        thrown.expect(CartException.class);
        thrown.expectMessage("Report End Date [20181220] is not in the expected format of [yyyy-MM-dd]");
        String date = "20181220";
        businessDayUtl.getNextBizDay(date, 1);
    }

    @Test
    public void testGetNextBizDay_InvalidDate() {
        thrown.expect(CartException.class);
        thrown.expectMessage("Report End Date [2018-13-20] is not in the expected format of [yyyy-MM-dd]");
        String date = "2018-13-20";
        businessDayUtl.getNextBizDay(date, 1);
    }
}
