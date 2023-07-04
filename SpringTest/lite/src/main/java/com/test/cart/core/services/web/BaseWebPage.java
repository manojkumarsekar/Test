package com.eastspring.qa.cart.core.services.web;

import com.eastspring.qa.cart.core.exceptions.CartException;
import com.eastspring.qa.cart.core.exceptions.CartExceptionType;
import com.eastspring.qa.cart.core.report.CartLogger;


public abstract class BaseWebPage extends WebTaskSvc {

    public void openWebUrl(String url, boolean forceNewSession) {
        if (forceNewSession) quitBrowser();
        openWebUrl(url);
    }

    public void openWebUrl(String url) {
        if (!getWebDriverManager().isSessionEstablished()) {
            getWebDriverManager().initializeWebDriver();
            getWebDriverManager().getDriver().get(url);
            getWebDriverManager().getDriver().manage().window().maximize();
        }
    }

    public void gotoUrl(String url) {
        if (!getWebDriverManager().isSessionEstablished()) {
            throw new CartException(CartExceptionType.INVALID_INVOCATION_PARAMS, "There is no active webdriver session");
        }
        getWebDriverManager().getDriver().get(url);
    }

    public String getBrowserTitle() {
        final String title = getWebDriverManager().getDriver().getTitle();
        CartLogger.debug("Current Browser Title Captured as [{}]", title);
        return title;
    }

    public String getBrowserUrl() {
        final String url = getWebDriverManager().getDriver().getCurrentUrl();
        CartLogger.debug("Current Browser url Captured as [{}]", url);
        return url;
    }

    public void quitBrowser() {
        getWebDriverManager().quitDriver();
    }

    public void closeBrowser() {
        getWebDriverManager().closeDriver();
    }

    public void capturePageSource() {
        byte[] file = getWebDriverManager().getDriver().getPageSource().getBytes();
        CartLogger.insertScreenshotToReport(file);
    }

    public void capturePageScreenShot() {
        byte[] file = this.captureScreenShotAsBytes();
        CartLogger.insertScreenshotToReport(file);
    }
}

