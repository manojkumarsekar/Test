package com.eastspring.tom.cart.core;

import com.eastspring.tom.cart.cfg.CartCoreConfig;
import com.eastspring.tom.cart.core.svc.JdbcSvc;
import org.junit.Before;
import org.junit.BeforeClass;
import org.junit.Test;
import org.junit.runner.RunWith;
import org.springframework.test.context.ContextConfiguration;
import org.springframework.test.context.junit4.SpringJUnit4ClassRunner;

@RunWith(SpringJUnit4ClassRunner.class)
@ContextConfiguration(classes = {CartCoreConfig.class})
public class CartBootstrapRunIT {


    @BeforeClass
    public static void configureLogging() {
        CartBootstrap.unitTestMode = true;
        CartCoreTestConfig.configureLogging(CartBootstrapRunIT.class);
    }

    @Before
    public void setUp() {
        System.setProperty("tomcart.basedir", System.getProperty("user.dir"));
    }

    @Test
    public void testLifecycle() {
        CartBootstrap.init();
        CartBootstrap.getBean(JdbcSvc.class);
        CartBootstrap.done();
    }

    @Test
    public void testSetConfig() {
        // init() will automatically invoked when getBean() is invoked...
        CartBootstrap.setConfigClass(CartCoreConfig.class);
        CartBootstrap.getBean(JdbcSvc.class);
        CartBootstrap.done();
    }
}
