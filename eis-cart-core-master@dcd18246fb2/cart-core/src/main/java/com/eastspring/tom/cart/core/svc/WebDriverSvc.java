package com.eastspring.tom.cart.core.svc;

import com.eastspring.tom.cart.core.CartException;
import com.eastspring.tom.cart.core.CartExceptionType;
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
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;

import java.util.concurrent.TimeUnit;

public class WebDriverSvc {

    private static final Logger LOGGER = LoggerFactory.getLogger(WebDriverSvc.class);

    public static final int DEFAULT_IMPLICIT_WAIT_SECONDS = 10;
    public static final String IE_BROWSER_ENSURE_CLEAN_SESSION = "ie.browser.ensure.clean.session";
    public static final String CUCUMBER_REPORTS_BROWSER = "cucumber.reports.browser";

    @Autowired
    private StateSvc stateSvc;

    protected WebDriver driver;

    WebDriver driver() {
        return computeWebDriverWithOptions();
    }


    @SuppressWarnings( "unused" )
    private WebDriver computeWebDriverWithOptions() {

        String browser = System.getProperty("cart.browser");
        if (Strings.isNullOrEmpty(browser)) {
            browser = "chrome";
        }
        stateSvc.setStringVar(CUCUMBER_REPORTS_BROWSER, browser.toLowerCase());

        LOGGER.info("Initialising [{}] driver", browser);
        switch (browser.toLowerCase()) {
            case "chrome":
                driver = new ChromeDriver(getChromeOptions());
                break;
            case "ie":
                driver = new InternetExplorerDriver(getIeOptions());
                break;
            default:
                LOGGER.error("browser [{}] is not configured", browser);
                throw new CartException(CartExceptionType.UNDEFINED, "browser [{}] is not configured", browser);
        }
        driver.manage().window().maximize();
        driver.manage().timeouts().implicitlyWait(DEFAULT_IMPLICIT_WAIT_SECONDS, TimeUnit.SECONDS);
        return driver;
    }

    private Capabilities getHtmlUnitCapabilities() {
        final DesiredCapabilities capabilities = DesiredCapabilities.htmlUnit();
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

        final String userDefinedVal = stateSvc.getStringVar(IE_BROWSER_ENSURE_CLEAN_SESSION);
        boolean ensureCleanSession = !Strings.isNullOrEmpty(userDefinedVal) && Boolean.parseBoolean(userDefinedVal);

        options.setCapability(InternetExplorerDriver.IE_ENSURE_CLEAN_SESSION, ensureCleanSession);
        options.setCapability(CapabilityType.ACCEPT_SSL_CERTS, true);

        return options;
    }

    ChromeOptions getChromeOptions() {
        ChromeOptions options = new ChromeOptions();
        if ("true".equals(System.getProperty("webdriver.chrome.headless"))) {
            LOGGER.debug("Running in headless mode");
            options.addArguments("--headless");
            options.addArguments("--verbose");
            options.addArguments("--no-sandbox");
            options.addArguments("--window-size=1920,1080");
        }
        options.addArguments("--allow-running-insecure-content");
        options.addArguments("--allow-insecure-localhost");
        options.addArguments("--ignore-certificate-errors");
        options.addArguments("--start-maximized");

        options = setChromeBrowserProxies(options);
        options.setCapability(CapabilityType.ACCEPT_INSECURE_CERTS, true);
        options.setCapability(CapabilityType.ACCEPT_SSL_CERTS, true);
        String chromeBinaryPath = System.getProperty("tomcart.web.chrome.path");
        if (!Strings.isNullOrEmpty(chromeBinaryPath)) {
            options.setBinary(chromeBinaryPath);
        }
        return options;
    }

    private ChromeOptions setChromeBrowserProxies(ChromeOptions options) {
        if (!Strings.isNullOrEmpty(System.getenv("SELENIUM_PROXY"))) {
            LOGGER.debug("Consuming SELENIUM_PROXY env var");
            Proxy proxy = new Proxy();
            proxy.setHttpProxy(System.getenv("SELENIUM_PROXY"));
            options.setCapability("proxy", proxy);
        }
        return options;
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
