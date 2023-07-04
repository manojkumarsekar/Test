package com.eastspring.tom.cart.core.utl;

import com.eastspring.tom.cart.core.CartCoreTestConfig;
import com.eastspring.tom.cart.core.CartException;
import org.junit.Assert;
import org.junit.BeforeClass;
import org.junit.Test;
import org.junit.runner.RunWith;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.test.context.ContextConfiguration;
import org.springframework.test.context.junit4.SpringJUnit4ClassRunner;

@RunWith(SpringJUnit4ClassRunner.class)
@ContextConfiguration(classes = {CartCoreUtlConfig.class})
public class DateTimeUtilRunIT {
    private static final Logger LOGGER = LoggerFactory.getLogger(DateTimeUtilRunIT.class);

    @Autowired
    private DateTimeUtil dateTimeUtil;

    @BeforeClass
    public static void setUpClass() {
        CartCoreTestConfig.configureLogging(DateTimeUtilRunIT.class);
    }

    @Test
    public void test() {
        String timestamp = dateTimeUtil.getTimestamp();
        LOGGER.debug("timestamp: [{}]", timestamp);
        long currenTimeMillis = dateTimeUtil.currentTimeMillis();
        LOGGER.debug("currentTimeMilis: [{}]", currenTimeMillis);
    }

    @Test
    public void testGetTimeStamp() {
        String result = dateTimeUtil.getTimestamp("dd-MMM-yyyy");
        LOGGER.debug(result);
    }

    @Test
    public void testGetTimeStamp_24Hr() {
        String result = dateTimeUtil.getTimestamp("dd-MM-yyyy HH:mm:ss");
        LOGGER.debug(result);
    }

    @Test(expected = CartException.class)
    public void testGetTimeStamp_invalidPattern() {
        String result = dateTimeUtil.getTimestamp("dd-b-yyyy");
        LOGGER.debug(result);
    }

    @Test
    public void testModifyDate_with1DayMore() {
        String date = "2017-JAN-19";
        String modifiedDate = dateTimeUtil.updateDateAndChangeFormat(date, "+1d", "yyyy-MMM-dd", "dd/MM/yyyy");
        Assert.assertEquals("20/01/2017", modifiedDate);
    }

    @Test
    public void testModifyDate_with1DayLess() {
        String date = "2017-JAN-19";
        String modifiedDate = dateTimeUtil.updateDateAndChangeFormat(date, "-1d", "yyyy-MMM-dd", "yyyy-MM-dd");
        Assert.assertEquals("2017-01-18", modifiedDate);
    }

    @Test
    public void testModifyDate_with1DayMore_BoundaryCondition() {
        String date = "2017-FEB-28";
        String modifiedDate = dateTimeUtil.updateDateAndChangeFormat(date, "+1d", "yyyy-MMM-dd", "yyyy-MM-dd");
        Assert.assertEquals("2017-03-01", modifiedDate);
    }

    @Test
    public void testModifyDate_with1DayLess_BoundaryCondition() {
        String date = "2017-JAN-01";
        String modifiedDate = dateTimeUtil.updateDateAndChangeFormat(date, "-1m", "yyyy-MMM-dd", "yyyy-MM-dd");
        Assert.assertEquals("2016-12-01", modifiedDate);
    }

    @Test
    public void testModifyDate_with1MonthMore_BoundaryCondition() {
        String date = "2017-FEB-28";
        String modifiedDate = dateTimeUtil.updateDateAndChangeFormat(date, "+1m", "yyyy-MMM-dd", "yyyy-MM-dd");
        Assert.assertEquals("2017-03-28", modifiedDate);
    }

    @Test
    public void testModifyDate_with1DayMore_with2YearsAdd() {
        String date = "2017-FEB-28";
        String modifiedDate = dateTimeUtil.updateDateAndChangeFormat(date, "+2y", "yyyy-MMM-dd", "yyyy-MM-dd");
        Assert.assertEquals("2019-02-28", modifiedDate);
    }

    @Test
    public void testModifyDate_with1DayMore_with2YearsSubtract() {
        String date = "2017-FEB-28";
        String modifiedDate = dateTimeUtil.updateDateAndChangeFormat(date, "-1y", "yyyy-MMM-dd", "yyyy-MM-dd");
        Assert.assertEquals("2016-02-28", modifiedDate);
    }

    @Test(expected = CartException.class)
    public void testModifyDate_invalidModifier() {
        String date = "2017-FEB-28";
        dateTimeUtil.updateDateAndChangeFormat(date, "+2x", "yyyy-MMM-dd", "yyyy-MM-dd");
    }

    @Test(expected = CartException.class)
    public void testConvertDateFormat_WithNullDate() {
        dateTimeUtil.convertDateFormat(null, "yyyy-MMM-dd", "yyyy-MM-dd");
    }

    @Test(expected = CartException.class)
    public void testConvertDateFormat_WithEmptyDate() {
        dateTimeUtil.convertDateFormat("", "yyyy-MMM-dd", "yyyy-MM-dd");
    }

    @Test
    public void testConvertDateFormat() {
        String date = "2017-FEB-28";
        String modifiedDate = dateTimeUtil.convertDateFormat(date, "yyyy-MMM-dd", "yyyy-MM-dd");
        Assert.assertEquals("2017-02-28", modifiedDate);
    }

    @Test(expected = CartException.class)
    public void testConvertDateFormat_WithInvalidPattern() {
        dateTimeUtil.convertDateFormat("2017-FEB-28", null, "yyyy-MM-dd");
    }

    @Test
    public void testValidateIsoDate_positive_validDate() throws Exception {
        dateTimeUtil.validateIsoDate("2018-02-28");
    }

    @Test(expected = CartException.class)
    public void testValidateIsoDate_negative_invalidDate() throws Exception {
        dateTimeUtil.validateIsoDate("02-Feb-2018");
    }
}
