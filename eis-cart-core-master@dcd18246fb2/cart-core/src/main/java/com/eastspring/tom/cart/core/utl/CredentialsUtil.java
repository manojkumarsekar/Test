package com.eastspring.tom.cart.core.utl;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.sonatype.plexus.components.cipher.DefaultPlexusCipher;
import org.sonatype.plexus.components.cipher.PlexusCipherException;

public class CredentialsUtil {
    private static final Logger LOGGER = LoggerFactory.getLogger(CredentialsUtil.class);

    public String encrypt(String text, String password) {
        try {
            DefaultPlexusCipher cipher = new DefaultPlexusCipher();
            return cipher.encrypt(text, password);
        } catch (PlexusCipherException e) {
            LOGGER.error("encryption failed", e);
        }
        return null;
    }

    public String decrypt(String text, String password) {
        if(text == null || password == null) {
            return null;
        }
        try {
            DefaultPlexusCipher cipher = new DefaultPlexusCipher();
            return cipher.decrypt(text, password);
        } catch (PlexusCipherException e) {
            LOGGER.error("decryption failed", e);
        }
        return null;
    }
}
