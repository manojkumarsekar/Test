package com.eastspring.qa.cart.core.configmanagers;

import com.eastspring.qa.cart.core.exceptions.CartException;
import com.eastspring.qa.cart.core.exceptions.CartExceptionType;
import com.eastspring.qa.cart.core.utils.core.WorkspaceUtil;
import com.eastspring.qa.cart.core.utils.file.PropertiesUtil;

import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.util.Properties;


public class AppConfigManager {

    private static Properties appConfigurations;
    private String configFileName;

    public AppConfigManager(String env) {
        loadConfig(env);
    }

    public AppConfigManager() {
        loadConfig(RunConfigManager.ENV_NAME);
    }

    void loadConfig(String env) {
        configFileName = "app-config-" + env.toLowerCase().trim() + ".properties";
        Path configFilePath = Paths.get(WorkspaceUtil.getTestConfigDir(), configFileName);
        if (!Files.exists(configFilePath)) {
            throw new CartException(CartExceptionType.FILE_NOT_FOUND, configFilePath + " is not found");
        }
        appConfigurations = PropertiesUtil.loadFile(configFilePath.toString());
    }

    public String get(String key) {
        if (!appConfigurations.containsKey(key)) {
            throw new CartException(CartExceptionType.INVALID_CONFIG, "Parameter " + key + " is not found in " + configFileName);
        }
        return appConfigurations.getProperty(key).trim();
    }


}