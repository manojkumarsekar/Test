package com.eastspring.tom.cart.core.svc;

import com.eastspring.tom.cart.core.CartCoreTestConfig;
import com.eastspring.tom.cart.core.CartException;
import org.junit.*;
import org.junit.rules.ExpectedException;
import org.mockito.InjectMocks;
import org.mockito.MockitoAnnotations;

public class StringFunctionSvcTest {
    @BeforeClass
    public static void setUpClass() {
        CartCoreTestConfig.configureLogging(StringFunctionSvcTest.class);
    }

    @InjectMocks
    private StringFunctionSvc stringFunctionSvc;

    @Rule
    public ExpectedException thrown = ExpectedException.none();

    @Before
    public void initMocks() {
        MockitoAnnotations.initMocks(this);
    }

    @Test
    public void testGet_positive() throws Exception {
        Assert.assertEquals("abc", stringFunctionSvc.get(StringFunctionSvc.IDENTITY).apply("abc"));
        Assert.assertEquals(null, stringFunctionSvc.get(StringFunctionSvc.IDENTITY).apply(null));
    }

    @Test
    public void testGet_negative() throws Exception {
        thrown.expect(CartException.class);
        thrown.expectMessage("unknown function name [CannotFindThisAsThisDoesNotExist]");
        stringFunctionSvc.get("CannotFindThisAsThisDoesNotExist");
    }
}
