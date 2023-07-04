package com.eastspring.tom.cart.core.utl;

import com.eastspring.tom.cart.core.CartCoreTestConfig;
import org.flywaydb.core.Flyway;
import org.junit.Before;
import org.junit.BeforeClass;
import org.junit.Test;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.MockitoAnnotations;

import static org.mockito.Mockito.times;
import static org.mockito.Mockito.verify;

public class FlywayUtilTest {

    @InjectMocks
    private FlywayUtil flywayUtil;

    @Mock
    private Flyway flyway;

    @Before
    public void initMocks() {
        MockitoAnnotations.initMocks(this);
    }


    @BeforeClass
    public static void setUpClass() {
        CartCoreTestConfig.configureLogging(FlywayUtilTest.class);
    }

    @Test
    public void testSetDataSource() throws Exception {
        flywayUtil.setDataSource("jdbcUrl", "jdbcUsername", "jdbcPassword");
        verify(flyway, times(1)).setDataSource("jdbcUrl", "jdbcUsername", "jdbcPassword");
    }

    @Test
    public void testBaseline() throws Exception {
        flywayUtil.baseline();
        verify(flyway, times(1)).baseline();
    }

    @Test
    public void testMigrate() throws Exception {
        flywayUtil.migrate();
        verify(flyway, times(1)).migrate();
    }
}
