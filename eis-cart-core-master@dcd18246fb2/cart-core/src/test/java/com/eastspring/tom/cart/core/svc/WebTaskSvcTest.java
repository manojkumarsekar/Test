package com.eastspring.tom.cart.core.svc;

import com.eastspring.tom.cart.core.CartCoreTestConfig;
import com.eastspring.tom.cart.core.CartException;
import com.eastspring.tom.cart.core.mdl.WebIdentifiersMetadata;
import org.junit.Before;
import org.junit.BeforeClass;
import org.junit.Rule;
import org.junit.Test;
import org.junit.rules.ExpectedException;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.MockitoAnnotations;
import org.mockito.Spy;
import org.openqa.selenium.Alert;
import org.openqa.selenium.By;
import org.openqa.selenium.Keys;
import org.openqa.selenium.StaleElementReferenceException;
import org.openqa.selenium.WebDriver;
import org.openqa.selenium.WebElement;
import org.openqa.selenium.support.ui.FluentWait;
import org.openqa.selenium.support.ui.WebDriverWait;

import java.util.*;
import java.util.concurrent.TimeUnit;

import static com.eastspring.tom.cart.core.svc.WebTaskSvc.WEB_CONFIG_PREFIX;
import static org.junit.Assert.assertEquals;
import static org.junit.Assert.assertNotNull;
import static org.junit.Assert.assertTrue;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.Mockito.times;
import static org.mockito.Mockito.verify;
import static org.powermock.api.mockito.PowerMockito.when;

public class WebTaskSvcTest {

    @Spy
    @InjectMocks
    private WebTaskSvc webTaskSvc;

    @Mock
    private WebDriverWait webDriverWaitMock;

    @Mock
    private FluentWait<WebDriver> fluentWaitMock;

    @Mock
    private StateSvc stateSvc;

    @Mock
    private WebDriverSvc webDriverSvc;

    @Mock
    private Map<String, Object> globalObjects;

    @Mock
    private WebDriver.TargetLocator targetLocator1;

    @Mock
    private ThreadSvc threadSvc;

    @Rule
    public ExpectedException thrown = ExpectedException.none();

    @Mock
    private WebDriver driver;

    @Mock
    private WebDriver.Options webDriverOptions;

    @Mock
    private WebDriver.Timeouts timeouts;

    @Mock
    private WebDriver.Window window;

    @Mock
    private WebElement we1;

    @Mock
    private Alert alert;


    @BeforeClass
    public static void initLogging() {
        CartCoreTestConfig.configureLogging(WebTaskSvcTest.class);
    }

    @Before
    public void initMocks() {
        MockitoAnnotations.initMocks(this);
    }

    private void mockSession(final boolean value){
        when(webTaskSvc.getSessionEstablished()).thenReturn(value);
        when(webTaskSvc.getDriver()).thenReturn(driver);
    }

    @Test
    public void testGetLocaDriverException() {
        thrown.expect(CartException.class);
        thrown.expectMessage("Session is not established");
        mockSession(false);
        webTaskSvc.getDriver();
    }

    @Test
    public void testGetBrowserTitle() {
        mockSession(true);
        when(driver.getTitle()).thenReturn("Mock Test");
        assertEquals("Mock Test", webTaskSvc.getBrowserTitle());
    }

    @Test
    public void testGetBrowserUrl() {
        mockSession(true);
        when(driver.getCurrentUrl()).thenReturn("http://www.mocktest.com");
        assertEquals("http://www.mocktest.com", webTaskSvc.getBrowserUrl());
    }

    @Test
    public void testGetByReference_WithOpCodeAndLocator() {
        mockSession(true);
        assertTrue(webTaskSvc.getByReference("id", "test") != null);
    }

    @Test
    public void testGetByReference_WithOpCodeAndLocator_OpCodeIsEmpty() {
        thrown.expect(CartException.class);
        thrown.expectMessage("OpCode Cannot be Null or Empty");
        mockSession(true);
        webTaskSvc.getByReference("", "test");
    }

    @Test
    public void testGetByReference_WithOpCodeAndLocator_InvalidOpCode() {
        thrown.expect(CartException.class);
        thrown.expectMessage("Invalid OP Code [XYZ]");
        mockSession(true);
        webTaskSvc.getByReference("XYZ", "test");
    }

    @Test
    public void testGetByReference_WithElementLocator() {
        String webElementId = "id:abcd";
        WebIdentifiersMetadata metadata = new WebIdentifiersMetadata();
        metadata.setOpCode("id");
        metadata.setParam1("abcd");
        mockSession(true);
        when(webTaskSvc.getWebElementIdentifiers(webElementId)).thenReturn(metadata);
        assertTrue(webTaskSvc.getByReference(webElementId) != null);
    }

    @Test
    public void testGetActionsBinding() {
        mockSession(true);
        assertTrue(webTaskSvc.getActionsBinding() != null);
    }

    @Test
    public void testSwitchToAlert() {
        mockSession(true);
        when(driver.switchTo()).thenReturn(targetLocator1);
        when(targetLocator1.alert()).thenReturn(alert);
        assertTrue(webTaskSvc.switchToAlert() != null);
    }

    @Test
    public void testGetWebDriverWait() {
        mockSession(true);
        WebDriverWait webDriverWait = webTaskSvc.getWebDriverWait(10);
        assertNotNull(webDriverWait);
    }

    @Test
    public void testOpenWebUrl() {
        mockSession(true);
        when(driver.manage()).thenReturn(webDriverOptions);
        when(webDriverOptions.window()).thenReturn(window);
        when(webTaskSvc.getSessionEstablished()).thenReturn(false);
        webTaskSvc.openWebUrl("https://abcurl:8024/asdbsf/");
        verify(threadSvc, times(1)).inbetweenStepsWait();
        verify(driver, times(1)).get("https://abcurl:8024/asdbsf/");
        verify(window, times(1)).maximize();
    }

    @Test
    public void testCloseAllOpenBrowsers() {
        mockSession(true);
        webTaskSvc.quitWebDriver();
        verify(webDriverSvc, times(1)).quit(driver);
    }

    @Test
    public void testCloseBrowserInstance() {
        mockSession(true);
        webTaskSvc.closeBrowserInstance();
        verify(webDriverSvc, times(1)).close(driver);
    }

    @Test
    public void testClickId() {
        mockSession(true);
        when(driver.findElement(By.id("id"))).thenReturn(we1);
        webTaskSvc.clickId("id");
        verify(threadSvc, times(1)).inbetweenStepsWait();
        verify(we1, times(1)).click();
    }

    @Test
    public void testRightClickId() {
        mockSession(true);
        when(driver.findElement(By.id("id"))).thenReturn(we1);
        webTaskSvc.rightClickId("id");
        verify(threadSvc, times(1)).inbetweenStepsWait();
    }

    @Test
    public void testSubmitId() {
        mockSession(true);
        when(driver.findElement(By.id("id"))).thenReturn(we1);
        webTaskSvc.submitId("id");
        verify(we1).submit();
    }

    @Test
    public void testClickCss() {
        mockSession(true);
        when(driver.findElement(By.className("classname"))).thenReturn(we1);
        webTaskSvc.clickCss("classname");
        verify(threadSvc, times(1)).inbetweenStepsWait();
        verify(we1, times(1)).click();
    }

    @Test
    public void testRightClickXPath_elementEmpty() {
        mockSession(true);
        when(driver.findElements(By.xpath("xpathquery"))).thenReturn(new ArrayList<>());
        thrown.expect(CartException.class);
        thrown.expectMessage("cannot find the element by xpath [xpathquery]");
        webTaskSvc.rightClickXPath("xpathquery");
        verify(threadSvc, times(1)).inbetweenStepsWait();
    }

    @Test
    public void testRightClickXPath_success() {
        List<WebElement> webElements = new ArrayList<>();
        webElements.add(we1);
        mockSession(true);
        when(driver.findElements(By.xpath("xpathquery"))).thenReturn(webElements);
        webTaskSvc.rightClickXPath("xpathquery");
        verify(threadSvc, times(1)).inbetweenStepsWait();
    }

    @Test
    public void testWebElementByIdShown_success() {
        List<WebElement> webElements = new ArrayList<>();
        webElements.add(we1);
        mockSession(true);
        when(driver.findElements(By.id("webElementId"))).thenReturn(webElements);
        webTaskSvc.webElementByIdShown("webElementId");
        verify(threadSvc, times(1)).inbetweenStepsWait();
    }

    @Test
    public void testWebElementByIdShown_failed() {
        List<WebElement> webElements = new ArrayList<>();
        when(driver.findElements(By.id("webElementId"))).thenReturn(webElements);
        thrown.expect(CartException.class);
        thrown.expectMessage("could not find web element specified by id [webElementId]");
        mockSession(true);
        webTaskSvc.webElementByIdShown("webElementId");
        verify(threadSvc, times(1)).inbetweenStepsWait();
    }

    @Test
    public void testWebElementByXPathShown_success() {
        List<WebElement> webElements = new ArrayList<>();
        webElements.add(we1);
        mockSession(true);
        when(driver.findElements(By.xpath("xpathQuery"))).thenReturn(webElements);
        webTaskSvc.webElementByXPathShown("xpathQuery");
        verify(threadSvc, times(1)).inbetweenStepsWait();
    }

    @Test
    public void testWebElementByXPathShown_failed() {
        List<WebElement> webElements = new ArrayList<>();
        when(driver.findElements(By.xpath("xpathQuery"))).thenReturn(webElements);
        thrown.expect(CartException.class);
        thrown.expectMessage("could not find web element specified by id [xpathQuery]");
        mockSession(true);
        webTaskSvc.webElementByXPathShown("xpathQuery");
        verify(threadSvc, times(1)).inbetweenStepsWait();
    }

    @Test
    public void testSetWebConfigToPropPrefix() {
        mockSession(true);
        webTaskSvc.setWebConfigToPropPrefix("webConfigName", "propPrefix");
        verify(threadSvc, times(1)).inbetweenStepsWait();
        verify(globalObjects, times(1)).put(WEB_CONFIG_PREFIX + "webConfigName", "propPrefix");
    }

    @Test
    public void testOpenSessionByWebConfigName() {
        mockSession(true);
        when(globalObjects.get(WEB_CONFIG_PREFIX + "webConfigName")).thenReturn("propPrefix");
        when(stateSvc.getStringVar("propPrefix.url.protocol")).thenReturn("https");
        when(stateSvc.getStringVar("propPrefix.url.hostname")).thenReturn("hostname");
        when(stateSvc.getStringVar("propPrefix.url.port")).thenReturn("8888");
        when(stateSvc.getStringVar("propPrefix.url.context")).thenReturn("/context");
        when(stateSvc.getStringVar("propPrefix.user")).thenReturn("user1");
        when(stateSvc.getStringVar("propPrefix.pass")).thenReturn("pass1");
        when(driver.manage()).thenReturn(webDriverOptions);
        when(webDriverOptions.window()).thenReturn(window);
        webTaskSvc.openSessionByWebConfigName("webConfigName");
        verify(threadSvc, times(1)).inbetweenStepsWait();
        verify(driver, times(1)).get("https://user1:pass1@hostname:8888/context");
        verify(window, times(1)).maximize();
    }

    @Test
    public void testOpenSessionByWebConfigName_emptyPort() {
        mockSession(true);
        when(globalObjects.get(WEB_CONFIG_PREFIX + "webConfigName")).thenReturn("propPrefix");
        when(stateSvc.getStringVar("propPrefix.url.protocol")).thenReturn("https");
        when(stateSvc.getStringVar("propPrefix.url.hostname")).thenReturn("hostname");
        when(stateSvc.getStringVar("propPrefix.url.port")).thenReturn("");
        when(stateSvc.getStringVar("propPrefix.url.context")).thenReturn("/context");
        when(stateSvc.getStringVar("propPrefix.user")).thenReturn("user1");
        when(stateSvc.getStringVar("propPrefix.pass")).thenReturn("pass1");
        when(driver.manage()).thenReturn(webDriverOptions);
        when(webDriverOptions.window()).thenReturn(window);
        webTaskSvc.openSessionByWebConfigName("webConfigName");
        verify(threadSvc, times(1)).inbetweenStepsWait();
        verify(driver, times(1)).get("https://user1:pass1@hostname/context");
        verify(window, times(1)).maximize();
    }

    @Test
    public void testOpenSessionByWebConfigName_nullPort() {
        mockSession(true);
        when(globalObjects.get(WEB_CONFIG_PREFIX + "webConfigName")).thenReturn("propPrefix");
        when(stateSvc.getStringVar("propPrefix.url.protocol")).thenReturn("https");
        when(stateSvc.getStringVar("propPrefix.url.hostname")).thenReturn("hostname");
        when(stateSvc.getStringVar("propPrefix.url.port")).thenReturn(null);
        when(stateSvc.getStringVar("propPrefix.url.context")).thenReturn("/context");
        when(stateSvc.getStringVar("propPrefix.user")).thenReturn("user1");
        when(stateSvc.getStringVar("propPrefix.pass")).thenReturn("pass1");
        when(driver.manage()).thenReturn(webDriverOptions);
        when(webDriverOptions.window()).thenReturn(window);
        webTaskSvc.openSessionByWebConfigName("webConfigName");
        verify(threadSvc, times(1)).inbetweenStepsWait();
        verify(driver, times(1)).get("https://user1:pass1@hostname/context");
        verify(window, times(1)).maximize();
    }

    @Test
    public void testSetImplicitWaitSeconds() {
        mockSession(true);
        when(driver.manage()).thenReturn(webDriverOptions);
        when(webDriverOptions.timeouts()).thenReturn(timeouts);
        webTaskSvc.setImplicitWait(31);
        verify(timeouts, times(1)).implicitlyWait(31, TimeUnit.SECONDS);
    }

    @Test
    public void testXPathResultsEmpty_empty() {
        mockSession(true);
        when(driver.findElements(By.xpath("xpathQuery"))).thenReturn(new ArrayList<>());
        assertTrue(webTaskSvc.xpathResultsEmpty("xpathQuery"));
    }

    @Test
    public void testXPathResultsEmpty_notEmpty() {
        List<WebElement> webElements = new ArrayList<>();
        webElements.add(we1);
        mockSession(true);
        when(driver.findElements(By.xpath("xpathQuery"))).thenReturn(webElements);
        boolean result = webTaskSvc.xpathResultsEmpty("xpathQuery");
    }

    @Test
    public void testSwitchToNextBrowserTab_multipleTabs() {
        mockSession(true);
        TreeSet<String> handles = new TreeSet<>(Arrays.asList("abc", "def"));
        when(driver.getWindowHandles()).thenReturn(handles);
        when(driver.switchTo()).thenReturn(targetLocator1);
        webTaskSvc.switchToNextBrowserTab();
        verify(targetLocator1, times(1)).window("def");
    }

    @Test
    public void testSwitchToNextBrowserTab_singleTab() {
        mockSession(true);
        TreeSet<String> handles = new TreeSet<>(Collections.singletonList("abc"));
        when(driver.getWindowHandles()).thenReturn(handles);
        when(driver.switchTo()).thenReturn(targetLocator1);
        webTaskSvc.switchToNextBrowserTab();
        verify(targetLocator1, times(1)).window("abc");
    }

    @Test
    public void testSwitchToNextBrowserTab_noTabs() {
        mockSession(true);
        TreeSet<String> handles = new TreeSet<>();
        when(driver.getWindowHandles()).thenReturn(handles);
        webTaskSvc.switchToNextBrowserTab();
    }

    @Test
    public void testGetCurrentBrowserWindowHandle() {
        mockSession(true);
        when(driver.getWindowHandle()).thenReturn("abc");
        assertEquals("abc", webTaskSvc.getCurrentBrowserWindowHandleName());
    }

    @Test
    public void testGetWindowHandles() {
        mockSession(true);
        when(driver.getWindowHandles()).thenReturn(new TreeSet<>(Arrays.asList("a", "b")));
        List<String> result = webTaskSvc.getWindowHandles();
        assertNotNull(result);
        assertEquals("a", result.get(0));
        assertEquals("b", result.get(1));
    }

    @Test
    public void testEnterTextIntoById() {
        mockSession(true);
        when(driver.findElement(By.id("id"))).thenReturn(we1);
        webTaskSvc.enterTextIntoById("text", "id");
        verify(threadSvc, times(1)).inbetweenStepsWait();
        verify(we1).sendKeys("text");
    }

    @Test
    public void testEnterTextIntoWebElement_withENTER() {
        mockSession(true);
        when(webTaskSvc.getWebDriverWait(60)).thenReturn(webDriverWaitMock);
        when(webDriverWaitMock.ignoring(StaleElementReferenceException.class)).thenReturn(fluentWaitMock);
        when(fluentWaitMock.until(any())).thenReturn(we1);

        webTaskSvc.enterTextIntoWebElement(we1, "text", "ENTER");
        verify(we1, times(1)).clear();
        verify(we1, times(1)).sendKeys("text");
        verify(threadSvc, times(1)).sleepSeconds(1);
        verify(we1, times(1)).sendKeys(Keys.ENTER);
    }

    @Test
    public void testEnterTextIntoWebElement_withOtherFollowingKey() {
        mockSession(true);
        when(webTaskSvc.getWebDriverWait(60)).thenReturn(webDriverWaitMock);
        when(webDriverWaitMock.ignoring(StaleElementReferenceException.class)).thenReturn(fluentWaitMock);
        when(fluentWaitMock.until(any())).thenReturn(we1);

        webTaskSvc.enterTextIntoWebElement(we1, "text", "ESCAPE");
        verify(we1, times(1)).clear();
        verify(we1, times(1)).sendKeys("text");
        verify(threadSvc, times(1)).sleepSeconds(1);
    }

    @Test
    public void testEnterTextIntoWebElement_noFollowingKey() {
        mockSession(true);
        when(webTaskSvc.getWebDriverWait(60)).thenReturn(webDriverWaitMock);
        when(webDriverWaitMock.ignoring(StaleElementReferenceException.class)).thenReturn(fluentWaitMock);
        when(fluentWaitMock.until(any())).thenReturn(we1);

        webTaskSvc.enterTextIntoWebElement(we1, "text", null);
        verify(we1, times(1)).clear();
        verify(we1, times(1)).sendKeys("text");
        verify(threadSvc, times(1)).sleepSeconds(1);
    }
}
