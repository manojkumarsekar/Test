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
public class LinuxRuntimeUtilRunIT {
    @Autowired
    private LinuxRuntimeUtil linuxRuntimeUtil;

    @BeforeClass
    public static void setUpClass() {
        CartCoreTestConfig.configureLogging(LinuxRuntimeUtilRunIT.class);
    }

    @Test
    public void testGetRuntimeDir() {
        String result = linuxRuntimeUtil.getRuntimeDir();
        Assert.assertEquals("/opt/tomrt-linux", result);
    }

}
