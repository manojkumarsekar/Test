package com.eastspring.tom.cart.dmp.pages;

import com.eastspring.tom.cart.core.svc.StateSvc;
import com.eastspring.tom.cart.core.svc.ThreadSvc;
import com.eastspring.tom.cart.core.svc.WebTaskSvc;
import com.eastspring.tom.cart.core.utl.FormatterUtil;
import com.eastspring.tom.cart.dmp.CartDmpTestConfig;
import com.eastspring.tom.cart.dmp.MockSelenium;
import org.junit.Before;
import org.junit.BeforeClass;
import org.junit.Test;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.MockitoAnnotations;
import org.openqa.selenium.By;
import org.openqa.selenium.support.ui.ExpectedConditions;

import static com.eastspring.tom.cart.dmp.pages.HomePage.GS_TAB_CLOSE_BUTTON;
import static com.eastspring.tom.cart.dmp.pages.HomePage.GS_UI_MENU;
import static com.eastspring.tom.cart.dmp.pages.HomePage.GS_UI_MENU_DROPDOWN;
import static com.eastspring.tom.cart.dmp.pages.HomePage.GS_UI_SETUP_BUTTON;
import static com.eastspring.tom.cart.dmp.pages.HomePage.GS_UI_TAB;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.Mockito.times;
import static org.mockito.Mockito.verify;
import static org.mockito.Mockito.when;

public class HomePageTest extends MockSelenium {

    @InjectMocks
    private HomePage homePage;

    @Mock
    private WebTaskSvc webTaskSvc;

    @Mock
    private StateSvc stateSvc;

    @Mock
    private FormatterUtil formatter;

    @Mock
    private ThreadSvc threadSvc;

    @BeforeClass
    public static void setUpLogging() {
        CartDmpTestConfig.configureLogging(HomePageTest.class);
    }

    @Before
    public void initMocks() {
        MockitoAnnotations.initMocks(this);
    }

    @Test
    public void testSelectMenu() {
        String menuName = "Mock_Menu";
        String formattedLocator = "//span[text()='Mock_Menu']/../..";
        when(formatter.format(GS_UI_MENU, menuName)).thenReturn(formattedLocator);
        when(webTaskSvc.getByReference("xpath", formattedLocator)).thenReturn(by);

        when(webTaskSvc.getWebDriverWait(240)).thenReturn(webDriverWait);
        when(webDriverWait.ignoring(any())).thenReturn(fluentWait);
        when(fluentWait.ignoring(any())).thenReturn(fluentWait);
        when(fluentWait.until(ExpectedConditions.elementToBeClickable((By) any()))).thenReturn(webElement);

        homePage.selectMenu(menuName);
        verify(webElement, times(1)).click();
    }

    @Test
    public void testClickMenuDropdown() {
        when(webTaskSvc.getWebDriverWait(60)).thenReturn(webDriverWait);
        when(webDriverWait.ignoring(any())).thenReturn(fluentWait);
        when(fluentWait.ignoring(any())).thenReturn(fluentWait);
        when(fluentWait.pollingEvery(any())).thenReturn(fluentWait);
        when(fluentWait.until(ExpectedConditions.elementToBeClickable((By) any()))).thenReturn(webElement);
        when(webElement.isEnabled()).thenReturn(true);
        homePage.clickMenuDropdown();
        verify(webTaskSvc, times(1)).clickXPath(GS_UI_MENU_DROPDOWN);
    }

    @Test
    public void testCloseTab() {
        String tabName = "Mock_Tab";
        String formattedLocator = String.format(GS_TAB_CLOSE_BUTTON, tabName);
        when(stateSvc.expandVar(tabName)).thenReturn(tabName);
        when(formatter.format(GS_TAB_CLOSE_BUTTON, tabName)).thenReturn(formattedLocator);
        homePage.closeGSTab(tabName);
        verify(webTaskSvc, times(1)).clickXPath(formattedLocator.concat("[3]"));
    }

    @Test
    public void testVerifyGSTabDisplayed() {
        String tabName = "Mock_Tab";
        String formattedLocator = "//span[@class='v-button-caption'][text()='Mock_Tab']";
        when(formatter.format(GS_UI_TAB, tabName)).thenReturn(formattedLocator);
        when(webTaskSvc.waitForElementToAppear(By.xpath(formattedLocator), 60)).thenReturn(webElement);
        when(webElement.isDisplayed()).thenReturn(true);
        homePage.verifyGSTabDisplayed(tabName);
    }

    @Test
    public void testClickSetUpButton() {
        homePage.clickSetUpButton();
        verify(webTaskSvc, times(1)).clickXPath(GS_UI_SETUP_BUTTON);
    }

}
