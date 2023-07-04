package com.eastspring.qa.cart.core.configmanagers;


import com.eastspring.qa.cart.core.exceptions.CartException;
import com.eastspring.qa.cart.core.exceptions.CartExceptionType;
import com.eastspring.qa.cart.core.lookUps.*;
import com.eastspring.qa.cart.core.report.CartLogger;
import com.eastspring.qa.cart.core.utils.core.WorkspaceUtil;
import org.apache.commons.lang3.EnumUtils;
import com.eastspring.qa.cart.core.utils.file.PropertiesUtil;

import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.util.Properties;


public class RunConfigManager {

    private static final Properties runConfigurations;
    private static final String CONFIG_FILE_NAME = "run-config.properties";
    public final static String PROJECT_NAME, BUILD_NUMBER, RELEASE_VERSION;
    public final static String ENV_NAME;
    public final static ExecutionMode EXECUTION_MODE;
    public final static int THREAD_COUNT, INTERMITTENT_WAIT_SECONDS;
    public final static boolean TERMINATE_APP_BEFORE_SCENARIO, TERMINATE_APP_ON_SCENARIO_FAILURE;


    static {
        Path configFilePath = Paths.get(WorkspaceUtil.getResourceDir(), "config", CONFIG_FILE_NAME);
        runConfigurations = PropertiesUtil.loadResource("/config/" + CONFIG_FILE_NAME);
        if (Files.exists(configFilePath)) {
            runConfigurations.putAll(PropertiesUtil.loadFile(configFilePath.toString()));
        }

        PROJECT_NAME = getConfigValue("run.project.name");
        BUILD_NUMBER = getConfigValue("run.build.number", true);
        RELEASE_VERSION = getConfigValue("run.release.version", true);
        ENV_NAME = getConfigValue("run.env.name");
        THREAD_COUNT = Integer.parseInt(getConfigValue("run.thread.count", true).equals("") ?
                "1" : getConfigValue("run.thread.count"));
        INTERMITTENT_WAIT_SECONDS = Integer.parseInt(getConfigValue("run.intermittent.wait.seconds", true).equals("") ?
                "5" : getConfigValue("run.intermittent.wait.seconds"));
        TERMINATE_APP_BEFORE_SCENARIO = Boolean.parseBoolean(getConfigValue("run.terminate.app.before.scenario", true));
        TERMINATE_APP_ON_SCENARIO_FAILURE = Boolean.parseBoolean(getConfigValue("run.terminate.app.on.failure", true));
        EXECUTION_MODE = ExecutionMode.valueOf(
                lookUpEnumValue("run.execution.mode", true, ExecutionMode.class, ExecutionMode.DEFAULT.toString())
        );
    }

    public static class Jira {
        public final static boolean UPLOAD_RESULTS_TO_JIRA;
        public final static String JIRA_KEY, JIRA_URL, JIRA_USER_NAME, JIRA_PASSWORD;

        static {
            JIRA_KEY = getConfigValue("jira.project.key");
            UPLOAD_RESULTS_TO_JIRA = Boolean.parseBoolean(getConfigValue("jira.uploadResults", true));
            JIRA_URL = UPLOAD_RESULTS_TO_JIRA ? getConfigValue("jira.url") : "";
            JIRA_USER_NAME = UPLOAD_RESULTS_TO_JIRA ? getConfigValue("jira.user.id") : "";
            JIRA_PASSWORD = UPLOAD_RESULTS_TO_JIRA ? getConfigValue("jira.user.encrypted.password") : "";
        }
    }

    public static class Web {
        public final static BrowserType BROWSER;
        public final static boolean HEADLESS_BROWSER, IE_CLEAN_SESSION;
        public final static String WEB_DRIVER_PATH, CHROME_BINARY_PATH;
        public final static int PAGE_TIMEOUT_SECONDS, IMPLICIT_WAIT_SECONDS;
        public final static String PROXY;

        static {
            BROWSER = BrowserType.valueOf(
                    lookUpEnumValue("web.browser", true, BrowserType.class, BrowserType.CHROME.toString())
            );
            HEADLESS_BROWSER = Boolean.parseBoolean(getConfigValue("web.headless", true));
            PROXY = getConfigValue("web.proxy", true);
            WEB_DRIVER_PATH = getConfigValue("web.driver.path", true);
            CHROME_BINARY_PATH = getConfigValue("web.chrome.binary.path", true);
            PAGE_TIMEOUT_SECONDS = Integer.parseInt(getConfigValue("web.page.timeout.seconds", true).equals("") ?
                    "30" : getConfigValue("web.page.timeout.seconds"));
            IMPLICIT_WAIT_SECONDS = Integer.parseInt(getConfigValue("web.implicit.wait.seconds", true).equals("") ?
                    "10" : getConfigValue("web.implicit.wait.seconds"));
            IE_CLEAN_SESSION = Boolean.parseBoolean(getConfigValue("web.ie.ensure.clean.session", true));
        }
    }

    public static class Report {
        public final static CartLogLevel CART_LOG_LEVEL;
        public final static ScreenshotLevel SCREENSHOT_LEVEL;
        public final static ScreenshotFormat SCREENSHOT_FORMAT;

        static {
            CART_LOG_LEVEL = CartLogLevel.valueOf(
                    lookUpEnumValue("report.log.level", true, CartLogLevel.class, CartLogLevel.INFO.toString())
            );
            SCREENSHOT_LEVEL = ScreenshotLevel.valueOf(
                    lookUpEnumValue("report.screenshot.level", true, ScreenshotLevel.class, ScreenshotLevel.ON_FAILURE.toString())
            );
            SCREENSHOT_FORMAT = ScreenshotFormat.valueOf(
                    lookUpEnumValue("report.screenshot.format", true, ScreenshotFormat.class, ScreenshotFormat.PNG.toString())
            );
        }
    }

    public static class TestScope {
        public final static String FEATURES, GLUE;
        public static String filterTags;

        static {
            FEATURES = getConfigValue("run.cucumber.features", true);
            GLUE = getConfigValue("run.cucumber.glue", true);
            filterTags = getConfigValue("run.cucumber.tags", true);
        }
    }

    //return all the properties for additional manipulation by test runners
    public Properties getConfigurations() {
        return runConfigurations;
    }

    private static String getConfigValue(String key) {
        return getConfigValue(key, false);
    }

    private static String getConfigValue(String key, boolean isOptional) {
        String configVal = (System.getProperty(key) == null || System.getProperty(key).equals("")) ?
                System.getenv(key) : System.getProperty(key);
        configVal = configVal == null ? runConfigurations.getProperty(key) : configVal;
        if (configVal == null || configVal.isEmpty()) {
            if (!isOptional) {
                throw new CartException(CartExceptionType.INVALID_CONFIG, "Run configuration parameter '[{}]' " +
                        "cannot be empty. It must be provided via [{}]/env variable/pom", key, CONFIG_FILE_NAME);
            }
            configVal = "";
        }
        return configVal.trim();
    }

    private static String lookUpEnumValue(String key, boolean isOptional, Class enumClassName, String defaultValue) {
        String keyVal = getConfigValue(key, isOptional).toUpperCase();
        if (EnumUtils.isValidEnum(enumClassName, keyVal)) {
            return keyVal;
        }
        CartLogger.debug("'" + keyVal + "' is not a valid '" + key + "'; '" + defaultValue + "' will be used");
        return defaultValue;
    }
}