package com.eastspring.tom.cart.core.utl;

import com.eastspring.tom.cart.core.CartCoreTestConfig;
import com.eastspring.tom.cart.core.CartException;
import org.junit.Assert;
import org.junit.BeforeClass;
import org.junit.Test;

public class TcpUtilTest {
    @BeforeClass
    public static void setUpClass() {
        CartCoreTestConfig.configureLogging(TcpUtilTest.class);
    }

    @Test
    public void testOpenSocket_unreachable() throws Exception {
        Exception thrown = null;
        TcpUtil tcpUtil = new TcpUtil();
        try {
            tcpUtil.openSocket("127.0.0.3", 3285);
        } catch (Exception e) {
            thrown = e;
        }
        Assert.assertNotNull(thrown);
        Assert.assertTrue(thrown instanceof CartException);
        Assert.assertEquals("TCP endpoint (host:port) [127.0.0.3:3285] is not reachable", thrown.getMessage());
    }
}
