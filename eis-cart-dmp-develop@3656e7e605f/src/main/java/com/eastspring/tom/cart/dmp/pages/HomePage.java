package com.eastspring.tom.cart.dmp.pages;

import com.eastspring.tom.cart.core.CartException;
import com.eastspring.tom.cart.core.CartExceptionType;
import com.eastspring.tom.cart.core.svc.StateSvc;
import com.eastspring.tom.cart.core.svc.ThreadSvc;
import com.eastspring.tom.cart.core.svc.WebTaskSvc;
import com.eastspring.tom.cart.core.utl.FormatterUtil;
import com.eastspring.tom.cart.dmp.utl.DmpGsPortalUtl;
import org.openqa.selenium.*;
import org.openqa.selenium.support.ui.ExpectedConditions;
import org.openqa.selenium.support.ui.WebDriverWait;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;

import java.awt.*;
import java.awt.event.KeyEvent;
import java.time.Duration;

import static com.eastspring.tom.cart.constant.CommonLocators.*;
import static com.eastspring.tom.cart.dmp.utl.DmpGsPortalUtl.MAX_RETRIES;


public class HomePage {

    private static final Logger LOGGER = LoggerFactory.getLogger(HomePage.class);

    public static final String GS_UI_MENU_DROPDOWN = "//div[contains(@class, 'gsPopupViewMenu')]";
    public static final String GS_UI_MENU = "//span[text()='%s']/../..";

    public static final String GS_TAB_CLOSE_BUTTON = "//span[@class='v-button-caption'][text()='%s']/ancestor::*[contains(@class,'gsUsrTabBg')]/descendant::div[@role='button']";

    public static final String GS_UI_TAB = "//div[contains(@class,'gsMenuContainer')]//span[@class='v-button-caption'][text()='%s']";
    public static final String GS_UI_SETUP_BUTTON = "//div[contains(@class,'gsSearchToolbar')]//span[text()='Setup']/../..";
    public static final String GS_UI_GLOBAL_SPLITTER = "//div[contains(@class,'v-button-link gsSplitter')]";
    public static final String ENTER = "ENTER";


    @Autowired
    private FormatterUtil formatter;

    @Autowired
    private WebTaskSvc webTaskSvc;

    @Autowired
    private ThreadSvc threadSvc;

    @Autowired
    private StateSvc stateSvc;

    @Autowired
    private DmpGsPortalUtl dmpGsPortalUtl;

    String parentBrowserHandle;

    public HomePage selectMenu(String menu) {
        try {
            LOGGER.debug("Select [{}]", menu);
            parentBrowserHandle = webTaskSvc.getCurrentBrowserWindowHandleName();
            By menuXpath = webTaskSvc.getByReference("xpath", formatter.format(GS_UI_MENU, menu));
            threadSvc.sleepSeconds(1);
            WebElement webElement = webTaskSvc.getWebDriverWait(240)
                    .ignoring(NoSuchElementException.class)
                    .ignoring(StaleElementReferenceException.class)
                    .until(ExpectedConditions.elementToBeClickable(menuXpath));
            webTaskSvc.waitTillPageLoads();
            webElement.click();
            threadSvc.sleepSeconds(1);
        } catch (Exception e) {
            LOGGER.error("Exception occurred while Selecting menu [{}]", menu, e);
            throw new CartException(CartExceptionType.PROCESSING_FAILED, "Exception occurred while Selecting menu [{}]", menu);
        }
        return this;
    }


    public HomePage selectMenuJS(String menu) {
        try {
            LOGGER.debug("Select [{}]", menu);
            By menuXpath = webTaskSvc.getByReference("xpath", formatter.format(GS_UI_MENU, menu));
            threadSvc.sleepSeconds(1);
            WebElement webElement = webTaskSvc.getWebElementRef(menuXpath);
            webTaskSvc.clickByJavaScript(webElement);
            threadSvc.sleepSeconds(1);
        } catch (Exception e) {
            LOGGER.error("Exception occurred while Selecting menu [{}]", menu, e);
            throw new CartException(CartExceptionType.PROCESSING_FAILED, "Exception occurred while Selecting menu [{}]", menu);
        }
        return this;
    }


    public HomePage clickMenuDropdown() {
        try {
            final WebElement element = webTaskSvc.getWebDriverWait(60)
                    .ignoring(NoSuchElementException.class)
                    .ignoring(StaleElementReferenceException.class)
                    .pollingEvery(Duration.ofSeconds(5))
                    .until(ExpectedConditions.elementToBeClickable(By.xpath(GS_UI_MENU_DROPDOWN)));

            if (element.isEnabled()) {
                webTaskSvc.clickXPath(GS_UI_MENU_DROPDOWN);
            }
        } catch (Exception e) {
            LOGGER.error("Exception occurred while clicking dropdown menu", e);
            throw new CartException(CartExceptionType.PROCESSING_FAILED, "Exception occurred while clicking dropdown menu");
        }
        return this;
    }

    public void closeGSTab(final String tabName) {
        final String expandedTabName = stateSvc.expandVar(tabName);
        LOGGER.debug("Closing [{}] tab", tabName);

        String xpathDerived;

        if ("GlobalSearch".equalsIgnoreCase(expandedTabName)) {
            xpathDerived = formatter.format(GS_TAB_CLOSE_BUTTON, "Global Search").concat("[2]");
        } else {
            xpathDerived = formatter.format(GS_TAB_CLOSE_BUTTON, expandedTabName).concat("[3]");
        }

        if (!"GSO Designer".equals(tabName)) {
            webTaskSvc.clickXPath(xpathDerived);
        }

        webTaskSvc.setImplicitWait(2);
        WebElement okButton = webTaskSvc.getWebElementRef(GS_CONFIRM_DIALOG_OK);
        if (okButton != null) {
            okButton.click();
        }
        webTaskSvc.setDefaultImplicitWait();
    }

    //default 120 seconds
    public void verifyGSTabDisplayed(String tabName) {
        this.verifyGSTabDisplayed(tabName, 120);
    }

    public void verifyGSTabDisplayed(String tabName, Integer maxTimeoutInSeconds) {
        final String tabXpath = formatter.format(GS_UI_TAB, tabName);
        if ("GSO Designer".equals(tabName)) {
            verifyGSODesigner();
            webTaskSvc.switchToWindowHandle(parentBrowserHandle);
        } else {
            try {
                webTaskSvc.waitForElementToAppear("xpath:" + tabXpath, maxTimeoutInSeconds);
            } catch (Exception e) {
                LOGGER.error(tabName + " Tab is not displayed", e);
                throw new CartException(CartExceptionType.VERIFICATION_FAILED, tabName + " tab is not displayed");
            }
        }
    }

    public void clickSetUpButton() {
        webTaskSvc.clickXPath(GS_UI_SETUP_BUTTON);
    }

    public void verifyGSODesigner() {
        webTaskSvc.switchToNextBrowserTab();
        Robot robot;
        String browserURL;
        try {
            robot = new Robot();
            robot.keyPress(KeyEvent.VK_ESCAPE);
            browserURL = webTaskSvc.getBrowserUrl();
            if (!browserURL.contains("GSODesigner")) {
                LOGGER.error("GSO Designer tab is not displayed");
                throw new CartException(CartExceptionType.VERIFICATION_FAILED, "GSO Designer tab is not displayed");
            }
        } catch (Exception e) {
            LOGGER.error("Unable to handle popup login window", e);
            throw new CartException(CartExceptionType.PROCESSING_FAILED, "Unable to handle popup login window");
        }
    }

    private void globalSearch(final String searchValue, final String searchType) {
        try {
            dmpGsPortalUtl.inputText(GS_GLOBAL_SEARCHTYPE_TEXTFIELD, searchType, ENTER, true);
            dmpGsPortalUtl.inputText(GS_GLOBAL_SEARCH_TEXTFIELD, stateSvc.expandVar(searchValue), null, true);
            WebElement searchBtn = webTaskSvc.getWebElementRef(GS_GLOBAL_SEARCH_BUTTON);
            searchBtn.click();
            threadSvc.sleepMillis(1000);
        } catch (Exception e) {
            LOGGER.error("Exception occurred in Global Search in searching for [{}]", searchValue, e);
            throw new CartException(CartExceptionType.PROCESSING_FAILED, "Exception occurred in Global Search in searching for [{}]", searchValue);
        }
    }

    public void globalSearchAndWaitTillSuccess(final String searchValue, final String searchType, final Integer timeOutInSeconds) {
        this.globalSearch(searchValue, searchType);
        By by = webTaskSvc.getByReference(GS_SAVE_BUTTON);
        try {
            webTaskSvc.getWebDriverWait(timeOutInSeconds * 2).until(ExpectedConditions.visibilityOfElementLocated(by));
            threadSvc.sleepMillis(500);
        } catch (TimeoutException e) {
            int actualRowCount = dmpGsPortalUtl.getTableRowCount(GS_DATA_TABLE_XPATH);
            LOGGER.info("Exception occurred,selecting first portfolio by default,number of records found : " + actualRowCount);
            if (actualRowCount > 0) {
                WebElement firstRow = webTaskSvc.getWebElementRef(XPATH + GS_DATA_TABLE_XPATH + "/tr[1]");
                webTaskSvc.fireMouseEventUsingJavaScript(firstRow, "dblclick");
                webTaskSvc.getWebDriverWait(timeOutInSeconds * 2).until(ExpectedConditions.visibilityOfElementLocated(by));
            }
        }

    }

    public boolean isUserLoggedIn() {
        try {
            return webTaskSvc.getWebElementRef(GS_HOME_USER_MENU) != null;
        } catch (NoSuchSessionException e) {
            LOGGER.debug("WebSession is not active, launch URL again...");
            return false;
        }
    }

    public void logout() {
        webTaskSvc.waitTillPageLoads();
        By by = webTaskSvc.getByReference(GS_HOME_USER_MENU);
        WebDriverWait webDriverWait = webTaskSvc.getWebDriverWait(60);

        int retry = 0;
        boolean loggedOut = false;
        while (retry < MAX_RETRIES && !loggedOut) {
            try {
                webDriverWait.until(ExpectedConditions.visibilityOfElementLocated(by));
                webDriverWait
                        .ignoring(WebDriverException.class)
                        .until(ExpectedConditions.elementToBeClickable(by))
                        .click();
                threadSvc.sleepSeconds(1);
                webTaskSvc.click(GS_HOME_LOGOUT_BUTTON);
                loggedOut = true;
            } catch (Exception e) {
                retry++;
                LOGGER.debug("Exception occurred while logout, retrying...[{}]", retry, e);
                dmpGsPortalUtl.refreshPage();
            }
        }
    }
}
