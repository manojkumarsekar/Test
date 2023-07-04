package com.eastspring.qa.cart.core.configmanagers;

import com.eastspring.qa.cart.core.exceptions.CartException;
import com.eastspring.qa.cart.core.exceptions.CartExceptionType;
import com.eastspring.qa.cart.core.utils.core.WorkspaceUtil;
import com.eastspring.qa.cart.core.utils.file.PropertiesUtil;

import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.util.Properties;


public class CoreConfigManager {

    private static final Properties coreConfigurations;
    private static final String CONFIG_FILE_NAME = "core-config.properties";

    public final static String MASTER_PASSWORD, LOG4J_CONFIG_PATH;

    static {
        Path configFilePath = Paths.get(WorkspaceUtil.getResourceDir(), "config", CONFIG_FILE_NAME);
        coreConfigurations = PropertiesUtil.loadResource("/config/" + CONFIG_FILE_NAME);
        if (Files.exists(configFilePath)) {
            coreConfigurations.putAll(PropertiesUtil.loadFile(configFilePath.toString()));
        }
        LOG4J_CONFIG_PATH = getConfigValue("log4j.config.path", true).toUpperCase();
        MASTER_PASSWORD = getConfigValue("secret.master.password", true);
    }

    //return all the properties for additional manipulation by test runners
    public Properties getConfigurations() {
        return coreConfigurations;
    }

    private static String getConfigValue(String key) {
        return getConfigValue(key, false);
    }

    private static String getConfigValue(String key, boolean isOptional) {
        String configVal = (System.getProperty(key) == null || System.getProperty(key).equals("")) ?
                System.getenv(key) : System.getProperty(key);
        configVal = configVal == null ? coreConfigurations.getProperty(key) : configVal;
        if (configVal == null || configVal.isEmpty()) {
            if (!isOptional) {
                throw new CartException(CartExceptionType.INVALID_CONFIG, "Core configuration parameter '[{}]' " +
                        "cannot be empty. It must be provided via [{}]/env variable/pom", key, CONFIG_FILE_NAME);
            }
            configVal = "";
        }
        return configVal.trim();
    }
}