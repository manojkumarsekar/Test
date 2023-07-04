package com.eastspring.tom.cart.core.utl;

import com.eastspring.tom.cart.core.CartCoreTestConfig;
import com.eastspring.tom.cart.core.CartException;
import org.junit.BeforeClass;
import org.junit.Test;
import org.junit.runner.RunWith;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.test.context.ContextConfiguration;
import org.springframework.test.context.junit4.SpringJUnit4ClassRunner;

import static org.junit.Assert.*;

@RunWith(SpringJUnit4ClassRunner.class)
@ContextConfiguration(classes = {CartCoreUtlConfig.class})
public class NumericVerificationUtilRunIT {
    @Autowired
    private NumericVerificationUtil numericVerificationUtil;

    @BeforeClass
    public static void setUpClass() {
        CartCoreTestConfig.configureLogging(NumericVerificationUtilRunIT.class);
    }

    @Test
    public void testMatchWithAbsError_float_sameNumber() {
        Throwable exceptionThrown = null;
        try {
            numericVerificationUtil.matchWithAbsError(0.0f, 0.0f, 0.0000001f);
        } catch (Throwable t) {
            exceptionThrown = t;
        }

        assertNull(exceptionThrown);
    }

    @Test
    public void testMatchWithAbsError_float_failOutOfTolerance() {
        Throwable exceptionThrown = null;
        try {
            numericVerificationUtil.matchWithAbsError(0.0f, 0.1f, 0.0000001f);
        } catch (Throwable t) {
            exceptionThrown = t;
        }

        assertNotNull(exceptionThrown);
        assertEquals(CartException.class, exceptionThrown.getClass());
        assertEquals("numeric values absolute error match failed for[0.0] and [0.1]", exceptionThrown.getMessage());
    }


    @Test
    public void testMatchWithAbsError_float_bigNumFailOutOfTolerance() {
        Throwable exceptionThrown = null;
        try {
            numericVerificationUtil.matchWithAbsError(1000000.0f, 1000000.1f, 0.0000001f);
        } catch (Throwable t) {
            exceptionThrown = t;
        }

        assertNotNull(exceptionThrown);
        assertEquals(CartException.class, exceptionThrown.getClass());
        assertEquals("numeric values absolute error match failed for[1000000.0] and [1000000.1]", exceptionThrown.getMessage());
    }

    @Test
    public void testMatchWithAbsError_float_successWithinTolerance() {
        Throwable exceptionThrown = null;
        try {
            numericVerificationUtil.matchWithAbsError(0.00016f, 0.00015f, 0.0001f);
        } catch (Throwable t) {
            exceptionThrown = t;
        }

        assertNull(exceptionThrown);
    }

    @Test
    public void testMatchWithAbsError_bigNumFailOutOfTolerance() {
        Throwable exceptionThrown = null;
        try {
            numericVerificationUtil.matchWithAbsError(1000000.0, 1000000.1, 0.0000001);
        } catch (Throwable t) {
            exceptionThrown = t;
        }

        assertNotNull(exceptionThrown);
        assertEquals(CartException.class, exceptionThrown.getClass());
        assertEquals("numeric values absolute error match failed for[1000000.0] and [1000000.1]", exceptionThrown.getMessage());
    }

    @Test
    public void testMatchWithAbsError_successWithinTolerance() {
        Throwable exceptionThrown = null;
        try {
            numericVerificationUtil.matchWithAbsError(0.00016, 0.00015, 0.0001);
        } catch (Throwable t) {
            exceptionThrown = t;
        }

        assertNull(exceptionThrown);
    }

    @Test
    public void testMatchWithRelError_sameNumber() {
        Throwable exceptionThrown = null;
        try {
            numericVerificationUtil.matchWithRelError(0.0, 0.0, 0.0000001);
        } catch (Throwable t) {
            exceptionThrown = t;
        }

        assertNull(exceptionThrown);
    }


    @Test
    public void testMatchWithRelError_failOutOfTolerance() {
        Throwable exceptionThrown = null;
        try {
            numericVerificationUtil.matchWithRelError(0.0, 0.1, 0.0000001);
        } catch (Throwable t) {
            exceptionThrown = t;
        }

        assertNotNull(exceptionThrown);
        assertEquals(CartException.class, exceptionThrown.getClass());
        assertEquals("numeric values relative error match failed for: [0.0] and [0.1]", exceptionThrown.getMessage());
    }


    @Test
    public void testMatchWithRelError_success_bigNum() {
        Throwable exceptionThrown = null;
        try {
            numericVerificationUtil.matchWithRelError(1000000.0, 1000000.1, 0.0000001);
        } catch (Throwable t) {
            exceptionThrown = t;
        }

        assertNull(exceptionThrown);
    }


    @Test
    public void testMatchWithRelError_failed_bigNum() {
        Throwable exceptionThrown = null;
        try {
            numericVerificationUtil.matchWithRelError(1000000.0f, 1000000.1f, 0.00000001f);
        } catch (Throwable t) {
            exceptionThrown = t;
        }

        assertNotNull(exceptionThrown);
        assertEquals(CartException.class, exceptionThrown.getClass());
        assertEquals("numeric values relative error match failed for: [1000000.0] and [1000000.1]", exceptionThrown.getMessage());
    }

    @Test
    public void testMatchWithRelError_successWithinTolerance() {
        Throwable exceptionThrown = null;
        try {
            numericVerificationUtil.matchWithRelError(0.00010006f, 0.00010005f, 0.0001f);
        } catch (Throwable t) {
            exceptionThrown = t;
        }

        assertNull(exceptionThrown);
    }

    @Test
    public void testMatchWithAbsError_double_sameNumber() {
        Throwable exceptionThrown = null;
        try {
            numericVerificationUtil.matchWithAbsError(0.0D, 0.0D, 0.0000001D);
        } catch (Throwable t) {
            exceptionThrown = t;
        }

        assertNull(exceptionThrown);
    }


    @Test
    public void testMatchWithAbsError_double_failOutOfTolerance() {
        Throwable exceptionThrown = null;
        try {
            numericVerificationUtil.matchWithAbsError(0.0D, 0.1D, 0.0000001D);
        } catch (Throwable t) {
            exceptionThrown = t;
        }

        assertNotNull(exceptionThrown);
        assertEquals(CartException.class, exceptionThrown.getClass());
        assertEquals("numeric values absolute error match failed for[0.0] and [0.1]", exceptionThrown.getMessage());
    }


    @Test
    public void testMatchWithAbsError_double_bigNumFailOutOfTolerance() {
        Throwable exceptionThrown = null;
        try {
            numericVerificationUtil.matchWithAbsError(1000000.0D, 1000000.1D, 0.0000001D);
        } catch (Throwable t) {
            exceptionThrown = t;
        }

        assertNotNull(exceptionThrown);
        assertEquals(CartException.class, exceptionThrown.getClass());
        assertEquals("numeric values absolute error match failed for[1000000.0] and [1000000.1]", exceptionThrown.getMessage());
    }

    @Test
    public void testMatchWithAbsError_double_successWithinTolerance() {
        Throwable exceptionThrown = null;
        try {
            numericVerificationUtil.matchWithAbsError(0.00016D, 0.00015D, 0.0001D);
        } catch (Throwable t) {
            exceptionThrown = t;
        }

        assertNull(exceptionThrown);
    }




    @Test
    public void testMatchWithRelError_double_sameNumber() {
        Throwable exceptionThrown = null;
        try {
            numericVerificationUtil.matchWithRelError(0.0D, 0.0D, 0.0000001D);
        } catch (Throwable t) {
            exceptionThrown = t;
        }

        assertNull(exceptionThrown);
    }


    @Test
    public void testMatchWithRelError_double_failOutOfTolerance() {
        Throwable exceptionThrown = null;
        try {
            numericVerificationUtil.matchWithRelError(0.0D, 0.1D, 0.0000001D);
        } catch (Throwable t) {
            exceptionThrown = t;
        }

        assertNotNull(exceptionThrown);
        assertEquals(CartException.class, exceptionThrown.getClass());
        assertEquals("numeric values relative error match failed for: [0.0] and [0.1]", exceptionThrown.getMessage());
    }


    @Test
    public void testMatchWithRelError_double_success_bigNum() {
        Throwable exceptionThrown = null;
        try {
            numericVerificationUtil.matchWithRelError(1000000.0D, 1000000.1D, 0.0000001D);
        } catch (Throwable t) {
            exceptionThrown = t;
        }

        assertNull(exceptionThrown);
    }


    @Test
    public void testMatchWithRelError_double_failed_bigNum() {
        Throwable exceptionThrown = null;
        try {
            numericVerificationUtil.matchWithRelError(1000000.0D, 1000000.1D, 0.00000001D);
        } catch (Throwable t) {
            exceptionThrown = t;
        }

        assertNotNull(exceptionThrown);
        assertEquals(CartException.class, exceptionThrown.getClass());
        assertEquals("numeric values relative error match failed for: [1000000.0] and [1000000.1]", exceptionThrown.getMessage());
    }

    @Test
    public void testMatchWithRelError_double_failed_outsideTolerance() {
        Throwable exceptionThrown = null;
        try {
            numericVerificationUtil.matchWithRelError(0.000106D, 0.000105D, 0.001D);
        } catch (Throwable t) {
            exceptionThrown = t;
        }

        assertNotNull(exceptionThrown);
        assertEquals(CartException.class, exceptionThrown.getClass());
        assertEquals("numeric values relative error match failed for: [1.06E-4] and [1.05E-4]", exceptionThrown.getMessage());
    }
}
