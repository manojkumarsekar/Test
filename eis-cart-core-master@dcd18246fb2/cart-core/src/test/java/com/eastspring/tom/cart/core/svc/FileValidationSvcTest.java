package com.eastspring.tom.cart.core.svc;

import com.eastspring.tom.cart.core.CartCoreTestConfig;
import com.eastspring.tom.cart.core.CartException;
import com.eastspring.tom.cart.core.utl.FileDirUtil;
import org.junit.Assert;
import org.junit.Before;
import org.junit.BeforeClass;
import org.junit.Test;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.MockitoAnnotations;

import static org.mockito.Mockito.when;

public class FileValidationSvcTest {
    @BeforeClass
    public static void setUpClass() {
        CartCoreTestConfig.configureLogging(FileValidationSvcTest.class);
    }

    @InjectMocks
    private FileValidationSvc fileValidationSvc;

    @Mock
    private FileDirUtil fileDirUtil;

    @Before
    public void initMocks() {
        MockitoAnnotations.initMocks(this);
    }

    @Test
    public void testValidateContentEquals_success() throws Exception {
        when(fileDirUtil.contentEquals("a", "b")).thenReturn(true);
        fileValidationSvc.validateContentEquals("a", "b");
    }

    @Test
    public void testValidateContentEquals_failed() throws Exception {
        when(fileDirUtil.contentEquals("a", "b")).thenReturn(false);
        Exception thrownException = null;
        try {
            fileValidationSvc.validateContentEquals("a", "b");
        } catch(Exception e) {
            thrownException = e;
        }
        Assert.assertNotNull(thrownException);
        Assert.assertTrue(thrownException instanceof CartException);
        Assert.assertEquals("the content of file [a] does not exactly match the content of file [b]", thrownException.getMessage());
    }
}

