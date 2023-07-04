package com.eastspring.qa.cart.core.utils.secret;

import com.eastspring.qa.cart.core.exceptions.CartException;
import com.eastspring.qa.cart.core.exceptions.CartExceptionType;
import com.eastspring.qa.cart.core.report.CartLogger;
import com.eastspring.qa.cart.core.configmanagers.CoreConfigManager;
import org.sonatype.plexus.components.cipher.DefaultPlexusCipher;
import org.sonatype.plexus.components.cipher.PlexusCipherException;


public class SecretUtil {

    static String getMasterPassword() {
        if (CoreConfigManager.MASTER_PASSWORD.equals("")) {
            throw new CartException(CartExceptionType.INVALID_CONFIG,
                    "MASTER_PASSWORD in core-config is empty and required by SecretUtil");
        }
        return CoreConfigManager.MASTER_PASSWORD;
    }

    public static String encrypt(String text) {
        return encrypt(text, getMasterPassword());
    }

    public static String encrypt(String text, String password) {
        try {
            DefaultPlexusCipher cipher = new DefaultPlexusCipher();
            return cipher.encrypt(text, password);
        } catch (PlexusCipherException e) {
            throw new CartException(e, CartExceptionType.ENCRYPTION_FAILED, "Failed to encrypt text");
        }
    }

    public static String decrypt(String text) {
        return decrypt(text, getMasterPassword());
    }

    public static String decrypt(String text, String password) {
        if (text == null || password == null) {
            return null;
        }
        try {
            DefaultPlexusCipher cipher = new DefaultPlexusCipher();
            return cipher.decrypt(text, password);
        } catch (PlexusCipherException e) {
            throw new CartException(e, CartExceptionType.ENCRYPTION_FAILED, "Failed to decrypt secret");
        }
    }
}