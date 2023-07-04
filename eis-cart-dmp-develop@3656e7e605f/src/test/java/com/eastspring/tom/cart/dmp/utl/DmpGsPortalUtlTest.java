package com.eastspring.tom.cart.dmp.utl;

import com.eastspring.tom.cart.core.CartException;
import com.eastspring.tom.cart.core.utl.FileDirUtil;
import org.junit.Before;
import org.junit.Test;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.MockitoAnnotations;

/**
 * Created by GummarajuM on 9/3/2018.
 */
public class DmpGsPortalUtlTest {

    @InjectMocks
    private DmpGsPortalUtl dmpGsPortalUtl;

    @Mock
    private FileDirUtil fileDirUtil;

    @Before
    public void initMocks() {
        MockitoAnnotations.initMocks(this);
    }

    @Test
    public void testAssertAreEquals_NumbersEqual() {
        dmpGsPortalUtl.assertEquals("2", "2");
    }

    @Test(expected = CartException.class)
    public void testAssertAreEquals_NumbersNotEqual() {
        dmpGsPortalUtl.assertEquals("2", "2.1");
    }

    @Test
    public void testAssertAreEquals_StringsEqual() {
        dmpGsPortalUtl.assertEquals("2a", "2a");
    }

    @Test(expected = CartException.class)
    public void testAssertAreEquals_StringsNotEqual() {
        dmpGsPortalUtl.assertEquals("2a", "2aa");
    }

    @Test
    public void testAssertAreEquals_StringsNull() {
        dmpGsPortalUtl.assertEquals(null, null);
    }


}
