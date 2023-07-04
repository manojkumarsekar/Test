package com.eastspring.tom.cart.core.utl;

import com.eastspring.tom.cart.core.CartException;
import com.eastspring.tom.cart.core.CartExceptionType;
import org.apache.commons.io.IOUtils;
import org.mozilla.universalchardet.UniversalDetector;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import java.io.FileInputStream;
import java.io.FileNotFoundException;
import java.io.IOException;
import java.io.InputStream;

public class FileValidatorUtil {
    private static final Logger LOGGER = LoggerFactory.getLogger(FileValidatorUtil.class);

    public void validateEncoding(String fileFullpath, String expectedEncoding) {
        UniversalDetector ud = new UniversalDetector();
        try (InputStream fis = new FileInputStream(fileFullpath)) {
            byte[] bytes = IOUtils.toByteArray(fis);
            ud.handleData(bytes);
            ud.dataEnd();
            String detectedCharset = ud.getDetectedCharset();
            if (!expectedEncoding.equals(detectedCharset)) {
                LOGGER.error("validation failed for file [{}] to have encoding of [{}] however it is detected as [{}] instead", fileFullpath, expectedEncoding, detectedCharset);
                throw new CartException(CartExceptionType.VALIDATION_FAILED, "validation failed for file [{}] to have encoding of [{}] however it is detected as [{}] instead", fileFullpath, expectedEncoding, detectedCharset);
            }
            LOGGER.debug("detected charset: {}", detectedCharset);
        } catch (FileNotFoundException e) {
            LOGGER.error("File not found", e);
            throw new CartException(CartExceptionType.UNSATISFIED_IMPLICIT_ASSUMPTION, "File not found");
        } catch (IOException e) {
            LOGGER.error("IO error", e);
            throw new CartException(CartExceptionType.IO_ERROR, "IO error");
        }
    }
}
