package com.eastspring.tom.cart.core.mdl;

import com.eastspring.tom.cart.core.CartException;
import com.eastspring.tom.cart.core.CartExceptionType;
import org.junit.Assert;
import org.junit.Test;

import static org.junit.Assert.assertEquals;
import static org.junit.Assert.assertNotNull;
import static org.junit.Assert.assertTrue;

public class WebGenericOpTest {

    @Test
    public void testInstantiate() throws Exception {
        WebGenericOp ops1 = new WebGenericOp(null, null, null);
        assertNotNull(ops1);
        Assert.assertNull(ops1.getOpCode());
        Assert.assertNull(ops1.getParam1());
        Assert.assertNull(ops1.getParam2());

        WebGenericOp ops2 = new WebGenericOp("id", "3", null);
        assertNotNull(ops2);
        assertEquals("id", ops2.getOpCode());
        assertEquals("3", ops2.getParam1());
        Assert.assertNull(ops2.getParam2());
    }

    @Test
    public void testParseString_success_xpath() throws Exception {
        WebGenericOp result = WebGenericOp.parseString("xpath://div[text() = 'Select identity']");
        assertNotNull(result);
        assertEquals("xpath", result.getOpCode());
        assertEquals("//div[text() = 'Select identity']", result.getParam1());
        Assert.assertNull(result.getParam2());
    }

    @Test
    public void testParseString_success_id() throws Exception {
        WebGenericOp result = WebGenericOp.parseString("id:a58929fj");
        assertNotNull(result);
        assertEquals("id", result.getOpCode());
        assertEquals("a58929fj", result.getParam1());
        Assert.assertNull(result.getParam2());
    }

    @Test
    public void testParseString_success_xpath_xy_pct() throws Exception {
        WebGenericOp result = WebGenericOp.parseString("xpath-xy-pct:(10,20)://div[text()='abc']");
        assertNotNull(result);
        assertEquals("xpath-xy-pct", result.getOpCode());
        assertEquals("(10,20)", result.getParam1());
        assertEquals("//div[text()='abc']", result.getParam2());
    }

    @Test
    public void testParseString_nullOpcode() throws Exception {
        Exception thrown = null;
        try {
            WebGenericOp.parseString(null);
        } catch (Exception e) {
            thrown = e;
        }
        assertNotNull(thrown);
        assertTrue(thrown instanceof CartException);
        CartException exception = (CartException) thrown;
        assertEquals(CartExceptionType.INCOMPLETE_PARAMS, exception.getExceptionType());
        assertEquals("invalid op specification null", exception.getMessage());
    }

    @Test
    public void testParseString_missingOpcode() throws Exception {
        Exception thrown = null;
        try {
            WebGenericOp.parseString("abc");
        } catch (Exception e) {
            thrown = e;
        }
        assertNotNull(thrown);
        assertTrue(thrown instanceof CartException);
        CartException exception = (CartException) thrown;
        assertEquals(CartExceptionType.UNSATISFIED_IMPLICIT_ASSUMPTION, exception.getExceptionType());
        assertEquals("missing opCode (xpath:,id:,xpath-pct:) in [abc]", exception.getMessage());
    }

    @Test
    public void testParseString_readXpath() {
        String s = "xpath://div[@class='v-window-header'][text()='Setup']/ancestor::div[@class='popupContent']//span[text()='Entity']/ancestor::tr//td[@class='v-formlayout-contentcell']//input";
        WebGenericOp.parseString(s);
    }
}
