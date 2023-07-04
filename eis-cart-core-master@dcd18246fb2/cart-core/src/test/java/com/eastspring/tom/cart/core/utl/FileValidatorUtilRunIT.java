package com.eastspring.tom.cart.core.utl;

import com.eastspring.tom.cart.core.CartCoreTestConfig;
import com.eastspring.tom.cart.core.CartException;
import com.eastspring.tom.cart.core.CartExceptionType;
import com.eastspring.tom.cart.core.svc.CartCoreSvcUtlTestConfig;
import com.eastspring.tom.cart.cst.EncodingConstants;
import org.junit.Assert;
import org.junit.BeforeClass;
import org.junit.Test;
import org.junit.runner.RunWith;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.test.context.ContextConfiguration;
import org.springframework.test.context.junit4.SpringJUnit4ClassRunner;

@RunWith(SpringJUnit4ClassRunner.class)
@ContextConfiguration(classes = {CartCoreSvcUtlTestConfig.class})
public class FileValidatorUtilRunIT {
    @Autowired
    private FileValidatorUtil fileValidatorUtil;

    @Autowired
    private FileDirUtil fileDirUtil;

    @BeforeClass
    public static void setUpClass() {
        CartCoreTestConfig.configureLogging(FileValidatorUtilRunIT.class);
    }

    @Test
    public void testValidateEncoding_success() {
        fileValidatorUtil.validateEncoding(fileDirUtil.getMavenTestResourcesPath("recon/tsv-utf16-sample.csv"), "UTF-16LE");
    }

    @Test
    public void testValidateEncoding_failedUtf8(){
        Throwable thrown = null;
        try {
            fileValidatorUtil.validateEncoding(fileDirUtil.getMavenTestResourcesPath("recon/tsv-utf16-sample.csv"), EncodingConstants.UTF_8);
        } catch(Exception e) {
            thrown = e;
        }

        Assert.assertNotNull(thrown);
        Assert.assertTrue(thrown instanceof CartException);
        Assert.assertEquals(CartExceptionType.VALIDATION_FAILED, ((CartException) thrown).getExceptionType());
    }

    @Test
    public void testValidateEncoding_fileNotFound() {
        Throwable thrown = null;
        try {
            fileValidatorUtil.validateEncoding(fileDirUtil.getMavenTestResourcesPath("recon/this-file-does-not-exist"), EncodingConstants.UTF_8);
        } catch(Exception e) {
            thrown = e;
        }

        Assert.assertNotNull(thrown);
        Assert.assertTrue(thrown instanceof CartException);
        CartException cartException = (CartException) thrown;
        Assert.assertEquals(CartExceptionType.UNSATISFIED_IMPLICIT_ASSUMPTION, cartException.getExceptionType());
        Assert.assertEquals("File not found", cartException.getMessage());
    }
}
