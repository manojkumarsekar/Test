package com.eastspring.tom.cart.core.utl;

import com.eastspring.tom.cart.core.CartCoreTestConfig;
import org.junit.Assert;
import org.junit.BeforeClass;
import org.junit.Test;
import org.junit.runner.RunWith;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.test.context.ContextConfiguration;
import org.springframework.test.context.junit4.SpringJUnit4ClassRunner;

@RunWith(SpringJUnit4ClassRunner.class)
@ContextConfiguration(classes = {CartCoreUtlConfig.class})
public class FormatterUtilRunIT {
    @Autowired
    private FormatterUtil formatterUtil;

    @BeforeClass
    public static void setUpClass() {
        CartCoreTestConfig.configureLogging(FormatterUtilRunIT.class);
    }

    @Test
    public void testFormat() {
        String result = formatterUtil.format("hello, %s!", "Big Al");
        Assert.assertEquals("hello, Big Al!", result);
    }
}
