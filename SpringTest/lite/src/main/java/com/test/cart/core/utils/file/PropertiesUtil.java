package com.eastspring.qa.cart.core.utils.file;


import com.eastspring.qa.cart.core.exceptions.CartException;
import com.eastspring.qa.cart.core.exceptions.CartExceptionType;
import org.springframework.util.Assert;

import java.io.FileInputStream;
import java.io.FileNotFoundException;
import java.io.IOException;
import java.io.InputStream;
import java.util.Properties;


public class PropertiesUtil {

    public static Properties loadFile(String filepath) {
        try {
            FileInputStream fileInputStream = new FileInputStream(filepath);
            Properties properties = new Properties();
            properties.load(fileInputStream);
            fileInputStream.close();
            return properties;
        } catch (FileNotFoundException fileNotFoundException) {
            throw new CartException(fileNotFoundException, CartExceptionType.IO_ERROR, "Properties file '[{}]' is not found", filepath);
        } catch (IOException exception) {
            throw new CartException(exception, CartExceptionType.PROCESSING_FAILED,
                    "Encountered exception while loading properties file '[{}]'.", filepath);
        }

    }

    public static Properties loadResource(String resourceFilePath) {
        try {
            InputStream propStream = PropertiesUtil.class.getResourceAsStream(resourceFilePath);
            Assert.notNull(propStream, resourceFilePath + " file is not found in resources");
            Properties properties = new Properties();
            properties.load(propStream);
            return properties;
        } catch (FileNotFoundException fileNotFoundException) {
            throw new CartException(fileNotFoundException, CartExceptionType.IO_ERROR, "Properties file '[{}]' is not found", resourceFilePath);
        } catch (IOException exception) {
            throw new CartException(exception, CartExceptionType.PROCESSING_FAILED,
                    "Encountered exception while loading properties file '[{}]'.", resourceFilePath);
        }

    }
}