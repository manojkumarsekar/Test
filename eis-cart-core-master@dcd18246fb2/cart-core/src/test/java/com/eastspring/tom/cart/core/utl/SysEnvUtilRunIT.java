package com.eastspring.tom.cart.core.utl;

import com.eastspring.tom.cart.core.CartCoreTestConfig;
import org.junit.BeforeClass;
import org.junit.Test;
import org.junit.runner.RunWith;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.test.context.ContextConfiguration;
import org.springframework.test.context.junit4.SpringJUnit4ClassRunner;

import static org.junit.Assert.assertNotNull;
import static org.junit.Assert.assertNull;

@RunWith(SpringJUnit4ClassRunner.class)
@ContextConfiguration(classes = {CartCoreUtlConfig.class})
public class SysEnvUtilRunIT {
    @Autowired
    private SysEnvUtil sysEnvUtil;

    @BeforeClass
    public static void setUpClass() {
        CartCoreTestConfig.configureLogging(SysEnvUtilRunIT.class);
    }

    @Test
    public void test() {
        assertNull(sysEnvUtil.getEnv("NONEXISTENT_ENV_VARIABLE_2350892358"));
        assertNotNull(sysEnvUtil.getEnv("PATH"));
    }
}
