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
public class CredentialsUtilRunIT {

    public static final String ORIGINAL_TEXT = "the little brown fox jumps over the lazy dog";
    public static final String ENCRYPTION_PASSWORD = "N354JrBZspgh9IaJNoi3iROpHyJO9";
    public static final String ENCRYPTED_TEXT = "b7djHzKM6/gHYEwmm0aKnm6NvU+dfWArXrqrM0xbM6jpP5st5wPm/21/WpnAHRq75UE2AhRt3aCcekESBPBmOw==";

    @Autowired
    private CredentialsUtil credentialsUtil;

    @BeforeClass
    public static void setUpClass() {
        CartCoreTestConfig.configureLogging(CredentialsUtilRunIT.class);
    }

    @Test
    public void testEncryptDecrypt() {
        String encryptedText = credentialsUtil.encrypt(ORIGINAL_TEXT, ENCRYPTION_PASSWORD);
        String result = credentialsUtil.decrypt(encryptedText, ENCRYPTION_PASSWORD);
        Assert.assertEquals(ORIGINAL_TEXT, result);
    }

    @Test
    public void testEncrypt_nullText() {
        String result = credentialsUtil.decrypt(null, ENCRYPTION_PASSWORD);
        Assert.assertNull(result);
    }

    @Test
    public void testEncrypt_nullPassword() {
        String result = credentialsUtil.decrypt(ORIGINAL_TEXT, ENCRYPTION_PASSWORD);
        Assert.assertNull(result);
    }

    @Test
    public void testDecrypt_nullText() {
        String result = credentialsUtil.decrypt(null, ENCRYPTION_PASSWORD);
        Assert.assertNull(result);
    }

    @Test
    public void testDecrypt_nullPasswprd() {
        String result = credentialsUtil.decrypt(ENCRYPTED_TEXT, null);

    }

}
