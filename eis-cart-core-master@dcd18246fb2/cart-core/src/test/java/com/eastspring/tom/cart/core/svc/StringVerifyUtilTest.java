package com.eastspring.tom.cart.core.svc;

import com.eastspring.tom.cart.core.CartCoreTestConfig;
import com.eastspring.tom.cart.core.CartException;
import com.eastspring.tom.cart.core.utl.StringVerifyUtil;
import org.hamcrest.CoreMatchers;
import org.junit.Before;
import org.junit.BeforeClass;
import org.junit.Rule;
import org.junit.Test;
import org.junit.rules.ExpectedException;

public class StringVerifyUtilTest {
    StringVerifyUtil service;

    @Rule
    public ExpectedException thrown = ExpectedException.none();

    @Before
    public void setUp() {
        service = new StringVerifyUtil();
    }

    @Test
    public void testMatch_success() throws Exception {
        service.match("", "");
    }

    @BeforeClass
    public static void initLogging() {
        CartCoreTestConfig.configureLogging(StringVerifyUtilTest.class);
    }

    @Test
    public void testMatch_notMatch() throws Exception {
        thrown.expect(CartException.class);
        thrown.expectMessage(CoreMatchers.startsWith("string match expected, but expected [a] does not match actual [b]"));
        service.match("a", "b");
    }

    @Test
    public void testMatch_expectedIsNull() {
        thrown.expect(CartException.class);
        thrown.expectMessage("string match expected, but expected is null");
        service.match(null, "");
    }

    @Test
    public void testMatch_actualIsNull() {
        thrown.expect(CartException.class);
        thrown.expectMessage("string match expected, but actual value given is null");
        service.match("", null);
    }
}
