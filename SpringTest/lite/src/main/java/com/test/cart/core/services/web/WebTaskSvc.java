package com.eastspring.qa.cart.core.services.web;

import com.eastspring.qa.cart.core.CartBootstrap;
import com.eastspring.qa.cart.core.configmanagers.RunConfigManager;
import com.eastspring.qa.cart.core.exceptions.CartException;
import com.eastspring.qa.cart.core.exceptions.CartExceptionType;
import com.eastspring.qa.cart.core.report.CartLogger;
import com.eastspring.qa.cart.core.utils.secret.SecretUtil;
import com.eastspring.qa.cart.core.utils.sync.ThreadUtil;
import org.apache.commons.io.FileUtils;
import com.eastspring.qa.cart.core.configmanagers.AppConfigManager;
import com.google.common.base.Function;
import org.openqa.selenium.*;
import org.openqa.selenium.NoSuchElementException;
import org.openqa.selenium.interactions.Actions;
import org.openqa.selenium.support.ui.*;

import javax.annotation.Nullable;
import java.io.File;
import java.io.IOException;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.time.Duration;
import java.util.*;
import java.util.concurrent.TimeUnit;


abstract class WebTaskSvc {
    public static final int DEFAULT_IMPLICIT_WAIT_SECONDS = RunConfigManager.Web.IMPLICIT_WAIT_SECONDS;
    public static final int DEFAULT_PAGE_WAIT_SECONDS = RunConfigManager.Web.PAGE_TIMEOUT_SECONDS;

    private WebDriverManagerSvc webDriverManagerSvc;

    private AppConfigManager appConfigManager;

    public enum SELECT_ACTION {
        VALUE,
        VISIBLE_TEXT,
        INDEX
    }

    protected WebDriverManagerSvc getWebDriverManager() {
        if (this.webDriverManagerSvc == null) {
            this.webDriverManagerSvc = (WebDriverManagerSvc) CartBootstrap.getBean(WebDriverManagerSvc.class);
        }
        return this.webDriverManagerSvc;
    }

    protected AppConfigManager getAppConfigManager() {
        if (this.appConfigManager == null) {
            this.appConfigManager = (AppConfigManager) CartBootstrap.getBean(AppConfigManager.class);
        }
        return this.appConfigManager;
    }

    protected WebDriver getDriver() {
        return getWebDriverManager().getDriver();
    }

    protected Actions getActionsBinding() {
        return new Actions(getDriver());
    }

    protected JavascriptExecutor getJavaScriptExecutor() {
        return (JavascriptExecutor) getDriver();
    }

    public File captureScreenShotAsFile(String fileName, Path targetDir) {
        File src = ((TakesScreenshot) getDriver()).getScreenshotAs(OutputType.FILE);
        File dst = new File(Paths.get(targetDir.toString(), fileName).toString());
        try {
            FileUtils.copyFile(src, dst);
        } catch (IOException e) {
            throw new CartException(e, CartExceptionType.PROCESSING_FAILED, "failed to copy file from [{}] to [{}]", src, dst);
        }
        return dst;
    }

    protected byte[] captureScreenShotAsBytes() {
        return ((TakesScreenshot) getDriver()).getScreenshotAs(OutputType.BYTES);
    }

    protected void setPageLoadTimeout() {
        getDriver().manage().timeouts().pageLoadTimeout(DEFAULT_PAGE_WAIT_SECONDS, TimeUnit.SECONDS);

    }

    protected void setImplicitWait(int seconds) {
        getDriver().manage()
                .timeouts()
                .implicitlyWait(seconds, TimeUnit.SECONDS);
    }

    protected void setDefaultImplicitWait() {
        getDriver().manage()
                .timeouts()
                .implicitlyWait(DEFAULT_IMPLICIT_WAIT_SECONDS, TimeUnit.SECONDS);
    }

    // ########################################## window actions ############################################

    protected String getActiveWindowHandle() {
        return getDriver().getWindowHandle();
    }

    protected List<String> getWindowHandles() {
        return new ArrayList<>(getDriver().getWindowHandles());
    }

    protected WebDriver switchToWindowHandle(String handle) {
        return getDriver().switchTo().window(handle);
    }

    protected void switchToWindowByURL(String expectedURL) {
        switchToWindowByURL(expectedURL, false);
    }

    protected void switchToWindowByURL(String expectedURL, boolean waitUntilAvailable) {
        int iterateLimit = waitUntilAvailable ? (DEFAULT_PAGE_WAIT_SECONDS / 5) : 1;
        for (int iterator = 0; iterator < iterateLimit; iterator++) {
            Set<String> dWindowHandles = getDriver().getWindowHandles();
            for (String windowHandle : dWindowHandles) {
                getDriver().switchTo().window(windowHandle);
                if (getDriver().getCurrentUrl().toLowerCase().contains(expectedURL.toLowerCase())) {
                    return;
                }
            }
            ThreadUtil.sleepSeconds(5);
        }
        throw new NoSuchWindowException("No window handle found with url containing '" + expectedURL + "'");
    }

    public Alert switchToAlert() {
        return getDriver().switchTo().alert();
    }

    public Alert waitForAlertAndSwitch(final int timeoutInSec) {
        return fluentWait(getDriver(), timeoutInSec)
                .pollingEvery(Duration.ofSeconds(1))
                .until(ExpectedConditions.alertIsPresent());
    }
    // ########################################## element actions ############################################

    protected WebElement findElement(By by) {
        return getDriver().findElement(by);
    }

    protected List<WebElement> findElements(By by) {
        return findElements(by, by.toString());
    }

    protected List<WebElement> findElements(By by, String elementName) {
        List<WebElement> elements = getDriver().findElements(by);
        if (elements.isEmpty()) {
            throw new CartException(CartExceptionType.ELEMENT_NOT_FOUND,
                    "cannot find the element [{}]", elementName);
        }
        return elements;
    }

    protected boolean isElementExist(By by, boolean waitUntilVisible) {
        if (waitUntilVisible) {
            try {
                fluentWaitUntilVisible(by);
            } catch (TimeoutException | UnhandledAlertException ignored) {
            }
        }
        return isElementExist(by);
    }

    protected boolean isElementExist(By by) {
        try {
            return !findElements(by).isEmpty();
        } catch (WebDriverException ignored) {
            return false;
        }
    }

    protected boolean isElementVisible(By by) {
        try {
            return findElement(by).isDisplayed();
        } catch (WebDriverException ignored) {
            return false;
        }
    }

    protected boolean isElementEnabled(By by) {
        try {
            return findElement(by).isEnabled();
        } catch (WebDriverException ignored) {
            return false;
        }
    }

    protected void clickElement(By by) {
        this.findElement(by).click();
    }

    protected void submit(final By by) {
        submit(findElement(by));
    }

    protected void submit(final WebElement element) {
        element.submit();
    }

    protected void forceClickElement(WebElement element) {
        getJavaScriptExecutor().executeScript("arguments[0].click();", element);
    }

    protected void rightClickElement(By by) {
        try {
            getActionsBinding()
                    .contextClick(findElement(by))
                    .perform();
        } catch (Exception e) {
            throw new CartException(CartExceptionType.PROCESSING_FAILED,
                    "Unable to perform right click on element.Error message: [{}]",
                    e.getMessage()
            );
        }
    }

    protected void sendKeys(By by, Keys input) {
        findElement(by).sendKeys(input);
    }

    protected void sendKeys(By by, String input) {
        sendKeys(findElement(by), input);
    }

    protected void sendKeys(WebElement element, String input) {
        element.sendKeys(input);
    }

    protected void setPassword(By by, String encodedPassword) {
        setSecret(by, encodedPassword);
    }

    protected void setSecret(By by, String encodedSecret) {
        String decodedSecret = SecretUtil.decrypt(encodedSecret);
        findElement(by).sendKeys(decodedSecret);
    }

    protected void scrollElementIntoView(By by) {
        scrollElementIntoView(getDriver().findElement(by));
    }

    protected void scrollElementIntoView(WebElement webElement) {
        getJavaScriptExecutor().executeScript("arguments[0].scrollIntoView();", webElement);
    }

    protected void scrollElementIntoView(String elementName, WebElement webElement) {
        getJavaScriptExecutor().executeScript("arguments[0].scrollIntoView();", webElement);
    }

    protected String getElementAttribute(final By by, final String attribute) {
        return getElementAttribute(findElement(by), attribute);
    }

    protected String getElementAttribute(final WebElement element, final String attribute) {
        try {
            final String value = element.getAttribute(attribute).trim();
            CartLogger.debug("Element's Attribute [{}] => [{}]", attribute, value);
            return value;
        } catch (Exception e) {
            throw new CartException(e, CartExceptionType.PROCESSING_FAILED, "Exception while reading attribute {}", attribute);
        }
    }

    protected void selectItemBy(final By by, final SELECT_ACTION action, final Object input) {
        WebElement selectElement = findElement(by);
        Select selectDropDown = new Select(selectElement);
        switch (action) {
            case VALUE:
                selectDropDown.selectByValue(String.valueOf(input));
                break;
            case VISIBLE_TEXT:
                selectDropDown.selectByVisibleText(String.valueOf(input));
                break;
            case INDEX:
                selectDropDown.selectByIndex((int) input);
                break;
        }
    }

    // ########################################## wait actions ############################################

    protected WebDriverWait webDriverWait() {
        return webDriverWait(getDriver(), DEFAULT_PAGE_WAIT_SECONDS);
    }

    protected WebDriverWait webDriverWait(final WebDriver driver, final int timeOutInSec) {
        return new WebDriverWait(driver, Duration.ofSeconds(timeOutInSec));
    }

    protected FluentWait<WebDriver> fluentWait() {
        return fluentWait(getDriver(), DEFAULT_PAGE_WAIT_SECONDS);
    }

    protected static FluentWait<WebDriver> fluentWait(WebDriver driver, int timeOutInSec) {
        return new FluentWait<WebDriver>(driver)
                .withTimeout(Duration.ofSeconds(timeOutInSec))
                .pollingEvery(Duration.ofSeconds(1))
                .ignoring(NoSuchElementException.class)
                .ignoring(NoSuchWindowException.class)
                .ignoring(StaleElementReferenceException.class)
                .ignoring(WebDriverException.class);
    }

    protected boolean waitForJStoLoad() {
        final Boolean jqueryLoaded = webDriverWait().until(evaluateJsCondition("jQuery.active==0", true));
        final Boolean pageLoaded = webDriverWait().until(evaluateJsCondition("document.readyState=='complete'", true));
        return jqueryLoaded && pageLoaded;
    }

    protected void waitTillPageLoads() {
        try {
            fluentWait().until(new Function<WebDriver, Boolean>() {
                                   public Boolean apply(WebDriver driver) {
                                       return (getJavaScriptExecutor()
                                               .executeScript("return document.readyState"))
                                               .equals("complete");
                                   }
                               }
            );
        } catch (ScriptTimeoutException e) {
            throw new CartException(CartExceptionType.PROCESSING_FAILED,
                    "Unable to perform right click on element.Error message: [{}]",
                    e.getMessage());

        }
    }

    protected void fluentWaitUntilVisible(By by) {
        try {
            fluentWait().until(new Function<WebDriver, WebElement>() {
                public WebElement apply(WebDriver webDriver) {
                    return (getDriver()).findElement(by);
                }
            });
        } catch (Exception ex) {
            throw new CartException(ex, CartExceptionType.PROCESSING_FAILED, "Element [{}] expected to appear within {} seconds, but failed to do so", by.toString(), DEFAULT_PAGE_WAIT_SECONDS);
        }
    }

    protected void fluentWaitUntilInvisible(By by) {
        try {
            fluentWait().until(ExpectedConditions.invisibilityOfElementLocated(by));
        } catch (Exception ex) {
            throw new CartException(ex, CartExceptionType.PROCESSING_FAILED, "Element [{}] expected to disappear within {} seconds, but failed to do so", by.toString(), DEFAULT_PAGE_WAIT_SECONDS);
        }
    }

    protected void waitTillClickable(By by) {
        try {
            fluentWait().until(ExpectedConditions.elementToBeClickable(by));
        } catch (Exception e) {
            throw new CartException(e, CartExceptionType.ELEMENT_NOT_CLICKABLE, "Element is not clickable in {} sec", DEFAULT_PAGE_WAIT_SECONDS);
        }
    }

    // ########################################## other actions ############################################

    protected void fireMouseEventUsingJavaScript(final WebElement element, final String eventName) {
        String jsCode = formatString("var evObj = new MouseEvent('%s', " +
                "{bubbles: true, cancelable: true, view: window});", eventName);
        jsCode += " arguments[0].dispatchEvent(evObj);";
        getJavaScriptExecutor().executeScript(jsCode, element);
    }

    private String formatString(String formatString, Object... args) {
        StringBuilder sb = new StringBuilder();
        try (Formatter formatter = new Formatter(sb, Locale.US)) {
            formatter.format(formatString, args);
            return sb.toString();
        }
    }

    private ExpectedCondition<Boolean> evaluateJsCondition(String javaScript, Boolean value) {
        return new ExpectedCondition<Boolean>() {
            @Nullable
            @Override
            public Boolean apply(@Nullable WebDriver driver) {
                try {
                    Boolean jsValue = (Boolean) getJavaScriptExecutor().executeScript("return " + javaScript);
                    CartLogger.debug("javascript [{}] value [{}]", javaScript, jsValue);
                    return jsValue == value;
                } catch (JavascriptException e) {
                    throw new CartException(e, CartExceptionType.INVALID_INVOCATION_PARAMS, "Exception evaluating - return " + javaScript);
                }
            }
        };
    }
}
