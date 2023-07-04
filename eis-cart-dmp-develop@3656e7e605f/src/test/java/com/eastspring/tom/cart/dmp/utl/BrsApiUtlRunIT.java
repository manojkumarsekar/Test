package com.eastspring.tom.cart.dmp.utl;

import com.eastspring.tom.cart.core.utl.WorkspaceUtil;
import com.eastspring.tom.cart.dmp.CartDmpTestConfig;
import com.eastspring.tom.cart.dmp.integration.CartDmpStepsSvcUtlConfig;
import org.apache.http.client.methods.HttpGet;
import org.apache.http.client.methods.HttpPost;
import org.apache.http.impl.client.CloseableHttpClient;
import org.junit.*;
import org.junit.rules.ExpectedException;
import org.junit.runner.RunWith;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.test.context.ContextConfiguration;
import org.springframework.test.context.junit4.SpringJUnit4ClassRunner;

@RunWith(SpringJUnit4ClassRunner.class)
@ContextConfiguration(classes = {CartDmpStepsSvcUtlConfig.class})
public class BrsApiUtlRunIT {

    @Autowired
    private BrsApiUtl brsApiUtl;

    @Autowired
    private WorkspaceUtil workspaceUtil;


    @Rule
    public ExpectedException thrown = ExpectedException.none();

    @BeforeClass
    public static void setUpclass() {
        CartDmpTestConfig.configureLogging(BrsApiUtlRunIT.class);
    }

    @Before
    public void before() {
        workspaceUtil.setBaseDir(System.getProperty("user.dir"));
    }

    @Test
    public void testcreateHttpClient() {
        CloseableHttpClient httpClient = brsApiUtl.createHttpClient();
        Assert.assertNotNull(httpClient);
    }

    @Test
    public void testcreateHttpPost() {
        String orderApiUrl = "https://ppmg.blackrock.com/api/trading/orders/v2/orders/";
        HttpPost httpPost = brsApiUtl.createHttpPost(orderApiUrl);
        Assert.assertNotNull(httpPost);
    }

    @Test
    public void testcreateHttpGet() {
        String orderApiUrl = "https://ppmg.blackrock.com/api/trading/orders/v2/orders/";
        HttpGet httpGet = brsApiUtl.createHttpGet(orderApiUrl);
        Assert.assertNotNull(httpGet);
    }


}
