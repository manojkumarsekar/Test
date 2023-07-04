package com.eastspring.tom.cart.core.steps;

import com.eastspring.tom.cart.core.CartCoreTestConfig;
import org.junit.BeforeClass;
import org.junit.Test;
import org.junit.runner.RunWith;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.test.context.ContextConfiguration;
import org.springframework.test.context.junit4.SpringJUnit4ClassRunner;

@RunWith(SpringJUnit4ClassRunner.class)
@ContextConfiguration(classes = {CartCoreStepsSvcUtlTestConfig.class})
public class ControlMStepsIT {
    private static final Logger LOGGER = LoggerFactory.getLogger(ControlMStepsIT.class);

    @Autowired
    private ControlMSteps steps;

    @BeforeClass
    public static void setUpClass() {
        CartCoreTestConfig.configureLogging(ControlMStepsIT.class);
    }

    @Test
    public void test() {
        steps.executeControlMJob("DANIELTEST", "EIS-APP-TOM-DEV-MISCELLANEOUS/DANIELTEST");
    }

}
