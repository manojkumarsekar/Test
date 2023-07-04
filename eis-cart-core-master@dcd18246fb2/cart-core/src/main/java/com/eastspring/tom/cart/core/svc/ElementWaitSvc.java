package com.eastspring.tom.cart.core.svc;

import com.eastspring.tom.cart.core.CartException;
import com.eastspring.tom.cart.core.CartExceptionType;
import net.sourceforge.htmlunit.corejs.javascript.JavaScriptException;
import org.openqa.selenium.*;
import org.openqa.selenium.support.ui.ExpectedCondition;
import org.openqa.selenium.support.ui.ExpectedConditions;
import org.openqa.selenium.support.ui.FluentWait;
import org.openqa.selenium.support.ui.WebDriverWait;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import javax.annotation.Nullable;
import java.time.Duration;
import java.util.List;

public class ElementWaitSvc {

    private static final Logger LOGGER = LoggerFactory.getLogger(ElementWaitSvc.class);

    private static WebDriverWait getWebDriverWait(final WebDriver driver, final int timeOutInSec) {
        return new WebDriverWait(driver, timeOutInSec);
    }

    private static FluentWait<WebDriver> wait(WebDriver driver, int timeOutInSec) {
        return getWebDriverWait(driver, timeOutInSec)
                .ignoring(NoSuchElementException.class)
                .ignoring(StaleElementReferenceException.class)
                .ignoring(WebDriverException.class);

    }

    public static WebElement waitTillClickable(final WebDriver driver, By by, int timeOutInSec) {
        try {
            return wait(driver, timeOutInSec)
                    .until(ExpectedConditions.elementToBeClickable(by));
        } catch (Exception e) {
            LOGGER.error("Element is not clickable in {} sec", timeOutInSec);
            throw new CartException(CartExceptionType.ELEMENT_NOT_CLICKABLE, "Element is not clickable in {} sec", timeOutInSec);
        }
    }

    public static WebElement waitTillClickable(final WebDriver driver, WebElement element, int timeOutInSec) {
        try {
            return wait(driver, timeOutInSec)
                    .until(ExpectedConditions.elementToBeClickable(element));
        } catch (Exception e) {
            LOGGER.error("Element is not clickable in {} sec", timeOutInSec);
            throw new CartException(CartExceptionType.ELEMENT_NOT_CLICKABLE, "Element is not clickable in {} sec", timeOutInSec);
        }
    }

    public static WebElement waitTillVisible(final WebDriver driver, WebElement element, int timeOutInSec) {
        try {
            return wait(driver, timeOutInSec)
                    .until(ExpectedConditions.visibilityOf(element));
        } catch (Exception e) {
            LOGGER.error("Element is not visible in {} sec", timeOutInSec);
            throw new CartException(CartExceptionType.ELEMENT_NOT_VISIBLE, "Element is not clickable in {} sec", timeOutInSec);
        }
    }

    public static WebElement waitTillVisible(final WebDriver driver, By by, int timeOutInSec) {
        try {
            return wait(driver, timeOutInSec)
                    .until(ExpectedConditions.visibilityOfElementLocated(by));
        } catch (Exception e) {
            LOGGER.error("Element is not visible in {} sec", timeOutInSec);
            throw new CartException(CartExceptionType.ELEMENT_NOT_VISIBLE, "Element is not clickable in {} sec", timeOutInSec);
        }
    }

    public static WebElement findElement(final WebDriver driver, By by, int timeOutInSec) {
        try {
            LOGGER.debug("findElement [{}] in seconds", timeOutInSec);
            return wait(driver, timeOutInSec)
                    .pollingEvery(Duration.ofSeconds(2))
                    .until(driver1 -> (driver).findElement(by));
        } catch (Exception ex) {
            LOGGER.error("Element [{}] expected to appear within {} seconds, but failed to do so", by.toString(), timeOutInSec, ex);
            throw new CartException(CartExceptionType.PROCESSING_FAILED, "Element [{}] expected to appear within {} seconds, but failed to do so", by.toString(), timeOutInSec);
        }
    }

    public static List<WebElement> findElements(final WebDriver driver, By by, int timeOutInSec) {
        try {
            LOGGER.debug("findElements [{}] in seconds", timeOutInSec);
            return wait(driver, timeOutInSec)
                    .pollingEvery(Duration.ofSeconds(2))
                    .until(driver1 -> (driver).findElements(by));
        } catch (Exception ex) {
            LOGGER.error("Element [{}] expected to appear within {} seconds, but failed to do so", by.toString(), timeOutInSec, ex);
            throw new CartException(CartExceptionType.PROCESSING_FAILED, "Element [{}] expected to appear within {} seconds, but failed to do so", by.toString(), timeOutInSec);
        }
    }


    public static void waitTillJsLoads(final WebDriver driver, int timeOutInSec) {

    }


    public static ExpectedCondition<Boolean> evaluateJsCondition(String javaScript, Boolean value) {
        return new ExpectedCondition<Boolean>() {
            @Nullable
            @Override
            public Boolean apply(@Nullable WebDriver driver) {
                try {
                    Boolean jsValue = (Boolean) ((JavascriptExecutor) driver)
                            .executeScript("return " + javaScript);
                    LOGGER.debug("javascript [{}] value [{}]", javaScript, jsValue);
                    return jsValue == value;
                } catch (JavaScriptException e) {
                    LOGGER.error("Exception evaluating - return " + javaScript, e);
                    throw new CartException(CartExceptionType.INVALID_INVOCATION_PARAMS, "Exception evaluating - return " + javaScript, e);
                }
            }
        };
    }


}
