package com.eastspring.tom.cart.core.svc;

import com.eastspring.tom.cart.core.CartCoreTestConfig;
import com.eastspring.tom.cart.core.steps.CartCoreStepsSvcUtlTestConfig;
import org.junit.BeforeClass;
import org.junit.Test;
import org.junit.runner.RunWith;
import org.openqa.selenium.chrome.ChromeOptions;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.test.context.ContextConfiguration;
import org.springframework.test.context.junit4.SpringJUnit4ClassRunner;

import static org.junit.Assert.assertNotNull;

@RunWith(SpringJUnit4ClassRunner.class)
@ContextConfiguration(classes = {CartCoreStepsSvcUtlTestConfig.class})
public class WebDriverSvcRunIT {

    @Autowired
    private WebDriverSvc webDriverSvc;

    @BeforeClass
    public static void setUpClass() {
        CartCoreTestConfig.configureLogging(WebDriverSvcRunIT.class);
    }

    @Test
    public void testGetChromeOption_nonHeadless() {
        ChromeOptions chromeOptions = webDriverSvc.getChromeOptions();
        assertNotNull(chromeOptions);
    }

    @Test
    public void testGetChromeOption_headless() {
        ChromeOptions chromeOptions = webDriverSvc.getChromeOptions();
        assertNotNull(chromeOptions);
    }
}
