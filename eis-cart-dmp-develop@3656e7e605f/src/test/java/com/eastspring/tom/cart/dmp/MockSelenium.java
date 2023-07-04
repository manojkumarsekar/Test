package com.eastspring.tom.cart.dmp;

import org.mockito.Mock;
import org.openqa.selenium.By;
import org.openqa.selenium.WebDriver;
import org.openqa.selenium.WebElement;
import org.openqa.selenium.support.ui.FluentWait;
import org.openqa.selenium.support.ui.WebDriverWait;

public abstract class MockSelenium {

    @Mock
    public WebDriverWait webDriverWait;

    @Mock
    public WebElement webElement;

    @Mock
    public FluentWait<WebDriver> fluentWait;

    @Mock
    public By by;
}
