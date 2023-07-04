package com.eastspring.tom.cart.core.utl;

import com.eastspring.tom.cart.core.CartCoreTestConfig;
import org.apache.http.client.methods.HttpPost;
import org.junit.Assert;
import org.junit.BeforeClass;
import org.junit.Test;
import org.junit.runner.RunWith;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.test.context.ContextConfiguration;
import org.springframework.test.context.junit4.SpringJUnit4ClassRunner;

@RunWith(SpringJUnit4ClassRunner.class)
@ContextConfiguration(classes = {CartCoreUtlConfig.class})
public class WsClientUtilRunIT {
    public static final String WS_ENDPOINT1 = "http://my.endpoint.com:8592/context1/context2";
    public static final String WS_BODY1 = "<mymessage><code>a</code><message>hello</message></mymessage>";

    @Autowired
    private WsClientUtil service;

    @BeforeClass
    public static void setUpClass() {
        CartCoreTestConfig.configureLogging(WsClientUtilRunIT.class);
    }

    @Test
    public void testCreateHttpPost_success() throws Exception {
        HttpPost httpPost = service.createHttpPost(WS_ENDPOINT1, WS_BODY1);
        Assert.assertNotNull(httpPost);
        Assert.assertEquals("POST", httpPost.getMethod());
        Assert.assertEquals(WS_ENDPOINT1, httpPost.getURI().toString());
    }
}
