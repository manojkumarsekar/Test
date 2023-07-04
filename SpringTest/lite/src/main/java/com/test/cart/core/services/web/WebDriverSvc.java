package com.eastspring.qa.cart.core.services.web;

import com.eastspring.qa.cart.core.configmanagers.RunConfigManager;
import com.eastspring.qa.cart.core.exceptions.CartException;
import com.eastspring.qa.cart.core.exceptions.CartExceptionType;
import com.eastspring.qa.cart.core.report.CartLogger;
import com.eastspring.qa.cart.core.utils.core.WorkspaceUtil;
import com.eastspring.qa.cart.core.lookUps.BrowserType;
import com.gargoylesoftware.htmlunit.BrowserVersion;
import com.google.common.base.Strings;
import org.openqa.selenium.Capabilities;
import org.openqa.selenium.Platform;
import org.openqa.selenium.Proxy;
import org.openqa.selenium.WebDriver;
import org.openqa.selenium.chrome.ChromeDriver;
import org.openqa.selenium.chrome.ChromeOptions;
import org.openqa.selenium.htmlunit.HtmlUnitDriver;
import org.openqa.selenium.ie.InternetExplorerDriver;
import org.openqa.selenium.ie.InternetExplorerOptions;
import org.openqa.selenium.remote.CapabilityType;
import org.openqa.selenium.remote.DesiredCapabilities;

import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.time.Duration;
import java.util.HashMap;


class WebDriverSvc {
    private static final int DEFAULT_IMPLICIT_WAIT_SECONDS = RunConfigManager.Web.IMPLICIT_WAIT_SECONDS;
    protected WebDriver driver;
    private boolean isWebDriverPathConfigured = false;

    WebDriver driver() {
        return computeWebDriverWithOptions();
    }

    private WebDriver computeWebDriverWithOptions() {
        BrowserType browser = RunConfigManager.Web.BROWSER;
        CartLogger.debug("Initialising [{}] driver", browser);
        if (!isWebDriverPathConfigured) configureWebDriverPath(browser);
        switch (browser) {
            case CHROME:
                driver = new ChromeDriver(getChromeOptions());
                break;
            case IE:
                driver = new InternetExplorerDriver(getIeOptions());
                break;
            default:
                throw new CartException(CartExceptionType.UNDEFINED, "browser [{}] is not configured", browser);
        }
        driver.manage().window().maximize();
        driver.manage().timeouts().implicitlyWait(Duration.ofSeconds(RunConfigManager.Web.IMPLICIT_WAIT_SECONDS));
        driver.manage().timeouts().pageLoadTimeout(Duration.ofSeconds(RunConfigManager.Web.PAGE_TIMEOUT_SECONDS));
        return driver;
    }

    private Capabilities getHtmlUnitCapabilities() {
        final DesiredCapabilities capabilities = new DesiredCapabilities();
        capabilities.setCapability(HtmlUnitDriver.JAVASCRIPT_ENABLED, false);
        capabilities.setBrowserName("htmlunit");
        capabilities.setVersion(BrowserVersion.INTERNET_EXPLORER.toString());
        capabilities.setAcceptInsecureCerts(true);
        capabilities.setPlatform(Platform.ANY);
        return capabilities;
    }

    private InternetExplorerOptions getIeOptions() {
        InternetExplorerOptions options = new InternetExplorerOptions();
        options.ignoreZoomSettings()
                .requireWindowFocus()
                .takeFullPageScreenshot()
                .enablePersistentHovering()
                .withInitialBrowserUrl("about:blank");

        final String userDefinedVal = String.valueOf(RunConfigManager.Web.IE_CLEAN_SESSION);
        boolean ensureCleanSession = !Strings.isNullOrEmpty(userDefinedVal) && Boolean.parseBoolean(userDefinedVal);

        options.setCapability(InternetExplorerDriver.IE_ENSURE_CLEAN_SESSION, ensureCleanSession);
        options.setCapability(CapabilityType.ACCEPT_SSL_CERTS, true);

        return options;
    }

    ChromeOptions getChromeOptions() {
        ChromeOptions options = new ChromeOptions();
        if (RunConfigManager.Web.HEADLESS_BROWSER) {
            CartLogger.debug("Running in headless mode");
            options.addArguments("--headless");
            options.addArguments("--verbose");
            options.addArguments("--no-sandbox");
            options.addArguments("--window-size=1920,1080");
        }
        options.addArguments("--allow-running-insecure-content");
        options.addArguments("--allow-insecure-localhost");
        options.addArguments("--ignore-certificate-errors");
        options.addArguments("--start-maximized");

        HashMap<String, Object> chromePreferences = new HashMap<String, Object>();
        chromePreferences.put("download.default_directory", WorkspaceUtil.getExecutionReportsDir());
        options.setExperimentalOption("prefs", chromePreferences);
        options = setChromeBrowserProxies(options);
        options.setCapability(CapabilityType.ACCEPT_INSECURE_CERTS, true);
//        options.setCapability(CapabilityType.ACCEPT_SSL_CERTS, true);
        String chromeBinaryPath = RunConfigManager.Web.CHROME_BINARY_PATH;
        if (!Strings.isNullOrEmpty(chromeBinaryPath)) {
            options.setBinary(chromeBinaryPath);
        }
        return options;
    }

    private ChromeOptions setChromeBrowserProxies(ChromeOptions options) {
        if (!Strings.isNullOrEmpty(RunConfigManager.Web.PROXY)) {
            CartLogger.debug("Consuming SELENIUM_PROXY env var");
            Proxy proxy = new Proxy();
            proxy.setHttpProxy(RunConfigManager.Web.PROXY);
            options.setCapability("proxy", proxy);
        }
        return options;
    }

    //ToDo:
    // move this to webdriver manager and enhance the driver selection by browser-version

    /**
     * Configures WebDriver through System properties.
     */
    private void configureWebDriverPath(BrowserType browser) {
        String WEB_DRIVER_PARAM;
        String WEB_DRIVER_NAME;
        switch (browser) {
            case IE:
                WEB_DRIVER_PARAM = "webdriver.ie.driver";
                WEB_DRIVER_NAME = "IEDriverServer.exe";
                break;
            case CHROME:
                WEB_DRIVER_PARAM = "webdriver.chrome.driver";
                WEB_DRIVER_NAME = "chromedriver.exe";
                break;
            default:
                throw new CartException(CartExceptionType.UNDEFINED, "browser [{}] is not configured", browser);
        }
        Path webDriverPath = Paths.get(WorkspaceUtil.getWebDriverDir(), WEB_DRIVER_NAME);
        Path customWebDriverPath = Paths.get(RunConfigManager.Web.WEB_DRIVER_PATH);
        if (!Strings.isNullOrEmpty(customWebDriverPath.toString()) && Files.exists(customWebDriverPath)) {
            webDriverPath = customWebDriverPath;
        } else if (!Files.exists(webDriverPath)) {
            throw new CartException(CartExceptionType.IO_ERROR, webDriverPath + " file is not found");
        }
        isWebDriverPathConfigured = true;
        CartLogger.debug("WebDriver is located in " + webDriverPath);
        System.setProperty(WEB_DRIVER_PARAM, webDriverPath.toString());
    }

    synchronized void quit(WebDriver driver) {
        if (driver != null) {
            driver.quit();
        }
    }

    synchronized void close(WebDriver driver) {
        if (driver != null) {
            driver.close();
        }
    }
}