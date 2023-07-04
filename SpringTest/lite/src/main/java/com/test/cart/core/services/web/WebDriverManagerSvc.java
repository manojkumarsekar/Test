package com.eastspring.qa.cart.core.services.web;

import com.eastspring.qa.cart.core.exceptions.CartException;
import com.eastspring.qa.cart.core.exceptions.CartExceptionType;
import com.eastspring.qa.cart.core.report.CartLogger;
import org.openqa.selenium.*;

import java.util.concurrent.ConcurrentHashMap;


public class WebDriverManagerSvc {
    private static final String SESSION_IS_NOT_ESTABLISHED_COULDN_T_GET_WEBDRIVER_OBJECT = "Session is not established, couldn't get webdriver object";

    private final ConcurrentHashMap<String, Boolean> sessionMap = new ConcurrentHashMap<String, Boolean>();
    private final ConcurrentHashMap<String, WebDriver> driverMap = new ConcurrentHashMap<String, WebDriver>();

    private final WebDriverSvc webDriverSvc = new WebDriverSvc();

    public WebDriver getDriver() {
        if (isSessionEstablished()) {
            return driverMap.get(Thread.currentThread().getName());
        }
        CartLogger.error(SESSION_IS_NOT_ESTABLISHED_COULDN_T_GET_WEBDRIVER_OBJECT);
        throw new CartException(CartExceptionType.UNDEFINED, SESSION_IS_NOT_ESTABLISHED_COULDN_T_GET_WEBDRIVER_OBJECT);
    }

    public WebDriver getNullOrWebDriver() {
        WebDriver webDriver = null;
        try {
            if (isSessionEstablished()) webDriver = getDriver();
        } catch (CartException ignored) {
        }
        return webDriver;
    }

    protected synchronized void initializeWebDriver() {
        WebDriver dr = webDriverSvc.driver();
        driverMap.put(Thread.currentThread().getName(), dr);
        setSessionEstablished(true);
    }

    Boolean isSessionEstablished() {
        return sessionMap.containsKey(Thread.currentThread().getName()) && sessionMap.get(Thread.currentThread().getName());
    }

    void setSessionEstablished(Boolean sessionEstablished) {
        sessionMap.put(Thread.currentThread().getName(), sessionEstablished);
    }

    protected void closeDriver() {
        webDriverSvc.close(getNullOrWebDriver());
        setSessionEstablished(false);
    }

    protected void quitDriver() {
        String threadName = Thread.currentThread().getName();
        if (driverMap.containsKey(threadName)) {
            WebDriver driver = driverMap.get(threadName);
            driver.quit();
            driverMap.remove(threadName);
        }
        setSessionEstablished(false);
    }

    public void quitAllDrivers() {
        driverMap.forEach((thread, driver) -> driver.quit());
        sessionMap.keySet().forEach(key -> sessionMap.put(key, false));
    }
}
