package com.eastspring.tom.cart.core.utl;

import com.eastspring.tom.cart.core.CartCoreTestConfig;
import com.eastspring.tom.cart.core.CartException;
import org.junit.BeforeClass;
import org.junit.Rule;
import org.junit.Test;
import org.junit.rules.ExpectedException;
import org.junit.runner.RunWith;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.test.context.ContextConfiguration;
import org.springframework.test.context.junit4.SpringJUnit4ClassRunner;

@RunWith( SpringJUnit4ClassRunner.class )
@ContextConfiguration( classes = {CartCoreUtlConfig.class} )
public class StringVerifyUtilRunIT {
    @Autowired
    private StringVerifyUtil stringVerifyUtil;

    @Rule
    public ExpectedException thrown = ExpectedException.none();

    @BeforeClass
    public static void setUpClass() {
        CartCoreTestConfig.configureLogging(StringVerifyUtilRunIT.class);
    }

    @Test
    public void testMatch_success() throws Exception {
        stringVerifyUtil.match("", "");
        stringVerifyUtil.match("abc", "abc");
        stringVerifyUtil.match("\n", "\n");
    }

    @Test
    public void testMatch_neg_expectedNull() throws Exception {
        thrown.expect(CartException.class);
        thrown.expectMessage("string match expected, but expected is null");
        stringVerifyUtil.match(null, "abc");
    }

    @Test
    public void testMatch_neg_actualNull() throws Exception {
        thrown.expect(CartException.class);
        thrown.expectMessage("string match expected, but actual value given is null");
        stringVerifyUtil.match("lazy dog", null);
    }

    @Test
    public void testMatch_neg_notEqual() throws Exception {
        thrown.expect(CartException.class);
        thrown.expectMessage("string match expected, but expected [lazy dog] does not match actual [lazzie dog]");
        stringVerifyUtil.match("lazy dog", "lazzie dog");
    }

    @Test
    public void testNotMatch_notMatched() {
        stringVerifyUtil.notMatch("lazy dog", "lazi dog");
    }

    @Test
    public void testNotMatch_matched_exception() {
        thrown.expect(CartException.class);
        thrown.expectMessage("string match not expected, but expected [lazy dog] matches with actual [lazy dog]");
        stringVerifyUtil.notMatch("lazy dog", "lazy dog");
    }
}