package com.eastspring.tom.cart.core.flt;

import com.eastspring.tom.cart.core.CartException;
import org.junit.Rule;
import org.junit.Test;
import org.junit.rules.ExpectedException;

import static org.junit.Assert.assertEquals;
import static org.junit.Assert.assertNull;

public class ColumnFilterPredicatesTest {
    @Rule
    public ExpectedException thrown = ExpectedException.none();


    @Test
    public void testStripPercentage() {
        assertEquals("abc", ColumnFilterPredicates.stripPercentage(0, "abc%"));
        assertEquals("%abc", ColumnFilterPredicates.stripPercentage(0, "%abc"));
        assertEquals("%abc", ColumnFilterPredicates.stripPercentage(0, "%abc%"));
        assertEquals("abc", ColumnFilterPredicates.stripPercentage(0, "abc"));
        assertEquals("", ColumnFilterPredicates.stripPercentage(3, ""));
        assertEquals(null, ColumnFilterPredicates.stripPercentage(3, null));
    }

    @Test
    public void testConvertMdyHmsaToIsoDate() {
        assertEquals("2017-12-31", ColumnFilterPredicates.convertMdyHmsaToIsoDate(0, "12/31/2017 12:37:51 AM"));
        assertEquals("2016-11-30", ColumnFilterPredicates.convertMdyHmsaToIsoDate(0, "11/30/2016 12:59:59 AM"));
        assertEquals("2016-11-30", ColumnFilterPredicates.convertMdyHmsaToIsoDate(0, "11/30/2016 12:59:59 PM"));
        assertEquals("2016-01-30", ColumnFilterPredicates.convertMdyHmsaToIsoDate(0, "1/30/2016 12:59:59 PM"));

        assertEquals("2017-12-31", ColumnFilterPredicates.convertMdyHmsaToIsoDate(1, "12/31/2017 12:37:51 AM"));
        assertEquals("2016-11-30", ColumnFilterPredicates.convertMdyHmsaToIsoDate(1, "11/30/2016 12:59:59 AM"));
        assertEquals("2016-11-30", ColumnFilterPredicates.convertMdyHmsaToIsoDate(1, "11/30/2016 12:59:59 PM"));
        assertEquals("2016-01-30", ColumnFilterPredicates.convertMdyHmsaToIsoDate(1, "1/30/2016 12:59:59 PM"));

        assertEquals("12/31/2017 12:37:51 AM", ColumnFilterPredicates.convertMdyHmsaToIsoDate(2, "12/31/2017 12:37:51 AM"));
        assertEquals("11/30/2016 12:59:59 AM", ColumnFilterPredicates.convertMdyHmsaToIsoDate(3, "11/30/2016 12:59:59 AM"));
        assertEquals("1/30/2016 12:59:59 PM", ColumnFilterPredicates.convertMdyHmsaToIsoDate(4, "1/30/2016 12:59:59 PM"));
        assertEquals("1/30/2016 12:59:59 PM", ColumnFilterPredicates.convertMdyHmsaToIsoDate(5, "1/30/2016 12:59:59 PM"));
        assertEquals("1/30/2016 12:59:59 PM", ColumnFilterPredicates.convertMdyHmsaToIsoDate(6, "1/30/2016 12:59:59 PM"));
        assertEquals("1/30/2016 12:59:59 PM", ColumnFilterPredicates.convertMdyHmsaToIsoDate(7, "1/30/2016 12:59:59 PM"));
        assertEquals("11/30/2016 12:59:59 PM", ColumnFilterPredicates.convertMdyHmsaToIsoDate(8, "11/30/2016 12:59:59 PM"));
        assertEquals("11/30/2016 12:59:59 PM", ColumnFilterPredicates.convertMdyHmsaToIsoDate(20, "11/30/2016 12:59:59 PM"));

        assertEquals(null, ColumnFilterPredicates.convertMdyHmsaToIsoDate(2, null));
        assertEquals(null, ColumnFilterPredicates.convertMdyHmsaToIsoDate(3, null));
        assertEquals(null, ColumnFilterPredicates.convertMdyHmsaToIsoDate(4, null));
        assertEquals(null, ColumnFilterPredicates.convertMdyHmsaToIsoDate(5, null));
        assertEquals(null, ColumnFilterPredicates.convertMdyHmsaToIsoDate(6, null));
        assertEquals(null, ColumnFilterPredicates.convertMdyHmsaToIsoDate(7, null));
        assertEquals(null, ColumnFilterPredicates.convertMdyHmsaToIsoDate(8, null));
        assertEquals(null, ColumnFilterPredicates.convertMdyHmsaToIsoDate(20, null));

        assertEquals("0.000010", ColumnFilterPredicates.convertMdyHmsaToIsoDate(9, "1e-5"));
        assertEquals("0.006010", ColumnFilterPredicates.convertMdyHmsaToIsoDate(9, "6.01e-3"));
        assertEquals("0.005312", ColumnFilterPredicates.convertMdyHmsaToIsoDate(9, "5.31195892e-3"));
        assertEquals("0.005312", ColumnFilterPredicates.convertMdyHmsaToIsoDate(9, "0.00531249999"));
        assertEquals("0.005312", ColumnFilterPredicates.convertMdyHmsaToIsoDate(9, "0.00531150000"));
    }

    @Test
    public void testConvertMdyHmsaToIsoDate_nullValue() {
        assertNull(ColumnFilterPredicates.convertMdyHmsaToIsoDate(1, null));
    }

    @Test
    public void testConvertMdyHmsaToIsoDate_moreThan2lessThan9() {
        assertEquals("", ColumnFilterPredicates.convertMdyHmsaToIsoDate(4, ""));
    }

    @Test
    public void testConvertMdyHmsaToIsoDate_numberFormatException() {
        thrown.expect(CartException.class);
        thrown.expectMessage("NumberFormatException: [12.3.2ef2859], columnNum: 10");

        ColumnFilterPredicates.convertMdyHmsaToIsoDate(10, "12.3.2ef2859");
    }
}
