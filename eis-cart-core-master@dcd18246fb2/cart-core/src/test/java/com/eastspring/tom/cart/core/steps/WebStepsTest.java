package com.eastspring.tom.cart.core.steps;

import com.eastspring.tom.cart.core.CartCoreTestConfig;
import com.eastspring.tom.cart.core.CartException;
import com.eastspring.tom.cart.core.CartExceptionType;
import com.eastspring.tom.cart.core.mdl.WebIdentifiersMetadata;
import com.eastspring.tom.cart.core.svc.StateSvc;
import com.eastspring.tom.cart.core.svc.ThreadSvc;
import com.eastspring.tom.cart.core.svc.WebTaskSvc;
import com.eastspring.tom.cart.core.utl.FileDirUtil;
import com.eastspring.tom.cart.core.utl.WorkspaceUtil;
import cucumber.api.Scenario;
import org.junit.Assert;
import org.junit.Before;
import org.junit.Rule;
import org.junit.Test;
import org.junit.rules.ExpectedException;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.MockitoAnnotations;
import org.openqa.selenium.By;
import org.openqa.selenium.WebElement;

import java.util.ArrayList;
import java.util.List;

import static org.junit.Assert.assertEquals;
import static org.junit.Assert.assertFalse;
import static org.junit.Assert.assertNotNull;
import static org.junit.Assert.assertTrue;
import static org.mockito.Mockito.times;
import static org.mockito.Mockito.verify;
import static org.mockito.Mockito.when;

public class WebStepsTest {

    @InjectMocks
    private WebSteps webSteps;

    @Mock
    private Scenario scenario;

    @Mock
    private FileDirUtil fileDirUtil;

    @Mock
    private StateSvc stateSvc;

    @Mock
    private ThreadSvc threadSvc;

    @Mock
    private WebTaskSvc webTaskSvc;

    @Mock
    private WebElement we1;

    @Mock
    private WebElement we2;

    @Mock
    private WorkspaceUtil workspaceUtil;

    @Rule
    public ExpectedException thrown = ExpectedException.none();

    @Before
    public void initMocks() {
        MockitoAnnotations.initMocks(this);
        CartCoreTestConfig.configureLogging(WebStepsTest.class);
    }

    @Test
    public void testCloseBrowserInstance() {
        webSteps.closeBrowserInstance();
        verify(webTaskSvc, times(1)).closeBrowserInstance();
    }

    @Test
    public void testXpathResultsEmpty() {
        String xpathQuery = "//abc/d";
        when(webTaskSvc.xpathResultsEmpty(xpathQuery)).thenReturn(true);
        boolean result1 = webSteps.xpathResultsEmpty(xpathQuery);
        assertTrue(result1);

        when(webTaskSvc.xpathResultsEmpty(xpathQuery)).thenReturn(false);
        boolean result2 = webSteps.xpathResultsEmpty(xpathQuery);
        assertFalse(result2);
    }

    @Test
    public void testSetImplicitWaitSeconds() {
        webSteps.setImplicitWaitSeconds(5);
        verify(webTaskSvc, times(1)).setImplicitWait(5);
    }

    @Test
    public void testPauseForSeconds() {
        webSteps.pauseForSeconds(7);
        verify(threadSvc, times(1)).sleepSeconds(7);
    }

    @Test
    public void testTakeScreenshot() {
        webSteps.takeScreenshot();
        verify(webTaskSvc, times(1)).takeScreenshot();
    }

    @Test
    public void testOpenWebUrl() {
        String url = "http://some.website.com/context";
        when(stateSvc.expandVar(url)).thenReturn(url);
        webSteps.openWebUrl(url);
        verify(webTaskSvc, times(1)).openWebUrl(url);
    }

    @Test
    public void testEnterTextIntoById_plain() {
        String text = "abc";
        String webElementId = "user_address_btn";
        when(stateSvc.expandVar(text)).thenReturn(text);
        when(stateSvc.expandVar(webElementId)).thenReturn(webElementId);
        webSteps.enterTextIntoById(text, webElementId);
        verify(stateSvc, times(1)).expandVar(text);
        verify(stateSvc, times(1)).expandVar(webElementId);
        verify(webTaskSvc, times(1)).enterTextIntoById(text, webElementId);
    }

    @Test
    public void testClickById() {
        webSteps.clickById("submitBtn");
        verify(webTaskSvc, times(1)).clickId("submitBtn");
    }

    @Test
    public void testSubmitById() {
        webSteps.submitById("abc");
        verify(webTaskSvc, times(1)).submitId("abc");
    }

    @Test
    public void testClickByCss() {
        webSteps.clickByCss("abc");
        verify(webTaskSvc, times(1)).clickCss("abc");
    }

    @Test
    public void testClickByXPath() {
        webSteps.clickByXpath("xpath");
        verify(webTaskSvc, times(1)).clickXPath("xpath");
    }

    @Test
    public void testWebElementByIdShown() {
        webSteps.webElementByIdShown("id");
        verify(webTaskSvc, times(1)).webElementByIdShown("id");
    }

    @Test
    public void testWebElementByXPathShown() {
        webSteps.webElementByXPathShown("xpath");
        verify(webTaskSvc, times(1)).webElementByXPathShown("xpath");
    }

    @Test
    public void testSetWebConfigToPropPrefix() {
        webSteps.setWebConfigToPropPrefix("WEB1", "automation.web1");
        verify(webTaskSvc, times(1)).setWebConfigToPropPrefix("WEB1", "automation.web1");
    }

    @Test
    public void testClickXPathUsingJavascript() {
        webSteps.clickXPathUsingJavascript("//div[@id='abc']");
        verify(webTaskSvc, times(1)).clickXPathUsingJavascript("//div[@id='abc']");
    }

    @Test
    public void testOpenSessionByWebConfigName() {
        webSteps.openSessionByWebConfigName("WEBCONFIG_NAME");
        verify(webTaskSvc, times(1)).openSessionByWebConfigName("WEBCONFIG_NAME");
    }

    @Test
    public void testClickByPropKey() {
        webSteps.clickByPropKey("propkey");
        verify(webTaskSvc, times(1)).clickWebByPropKey("propkey");
    }

    @Test
    public void testCloseAllOpenBrowsers() {
        webSteps.closeAllOpenBrowsers();
        verify(webTaskSvc, times(1)).quitWebDriver();
    }

    @Test
    public void testClickWhoseText() {
        webSteps.clickWhoseText("abc");
        verify(webTaskSvc, times(1)).clickWhoseText("abc");
    }

    @Test
    public void testFindElementsByXPath() {
        List<WebElement> elements = new ArrayList<>();
        elements.add(we1);
        elements.add(we2);
        when(webTaskSvc.findElementsByXPath("myxpath")).thenReturn(elements);
        webSteps.findElementsByXPath("myxpath");
        assertNotNull(elements);
        assertEquals(we1, elements.get(0));
        assertEquals(we2, elements.get(1));
    }

    @Test
    public void testClickWebXPathWhenOnWindowThatHasXPath_nonEmptyElements() {
        String toClickXPath = "//div[@id='submitBtn']";
        String selectorXPath = "//div[@id='abc']";
        List<WebElement> elements = new ArrayList<>();
        elements.add(we1);
        elements.add(we2);
        when(stateSvc.expandVar(toClickXPath)).thenReturn(toClickXPath);
        when(stateSvc.expandVar(selectorXPath)).thenReturn(selectorXPath);
        when(webTaskSvc.findElementsByXPath(selectorXPath)).thenReturn(elements);
        List<String> windowHandles = new ArrayList<>();
        windowHandles.add("abc");
        when(webTaskSvc.getWindowHandles()).thenReturn(windowHandles);
        webSteps.clickXPathWhenOnWindowThatHasXPath(toClickXPath, selectorXPath);
        verify(webTaskSvc, times(1)).switchToWindowHandle("abc");
        verify(webTaskSvc, times(1)).clickXPath(toClickXPath);
    }

    @Test
    public void testClickXPathWhenOnWindowThatHasXPath_emptyElements() {
        String toClickXPath = "//div[@id='submitBtn']";
        String selectorXPath = "//div[@id='abc']";
        List<WebElement> elements = new ArrayList<>();
        when(stateSvc.expandVar(toClickXPath)).thenReturn(toClickXPath);
        when(stateSvc.expandVar(selectorXPath)).thenReturn(selectorXPath);
        when(webTaskSvc.findElementsByXPath(selectorXPath)).thenReturn(elements);
        List<String> windowHandles = new ArrayList<>();
        windowHandles.add("abc");
        when(webTaskSvc.getWindowHandles()).thenReturn(windowHandles);
        webSteps.clickXPathWhenOnWindowThatHasXPath(toClickXPath, selectorXPath);
        verify(webTaskSvc, times(1)).switchToWindowHandle("abc");
    }

    @Test
    public void testClickXPathWhenOnWindowThatHasXPath_varExpansion() {
        String toClickXPath = "//div[@id='${submit.btn}']";
        String selectorXPath = "//div[@id='${predefined.id}']";
        String expandedToClickXPath = "//div[@id='submitBtn']";
        String expandedSelectorXPath = "//div[@id='abc']";
        List<WebElement> elements = new ArrayList<>();
        elements.add(we1);
        elements.add(we2);
        when(stateSvc.expandVar(toClickXPath)).thenReturn(expandedToClickXPath);
        when(stateSvc.expandVar(selectorXPath)).thenReturn(expandedSelectorXPath);
        when(webTaskSvc.findElementsByXPath(expandedSelectorXPath)).thenReturn(elements);
        List<String> windowHandles = new ArrayList<>();
        windowHandles.add("abc");
        when(webTaskSvc.getWindowHandles()).thenReturn(windowHandles);
        webSteps.clickXPathWhenOnWindowThatHasXPath(toClickXPath, selectorXPath);
        verify(webTaskSvc, times(1)).switchToWindowHandle("abc");
        verify(webTaskSvc, times(1)).clickXPath(expandedToClickXPath);
    }

    @Test
    public void testSwitchToNextBrowserTab() {
        webSteps.switchToNextBrowserTab();
        verify(webTaskSvc, times(1)).switchToNextBrowserTab();
    }

    @Test
    public void testSelectVisibleValueOn_byXPath() {
        List<WebElement> elements = new ArrayList<>();
        elements.add(we1);
        when(stateSvc.getStringVar("myvar.abc")).thenReturn("xpath://div[@id='submitBtn']");
        when(webTaskSvc.findElementsByXPath("//div[@id='submitBtn']")).thenReturn(elements);
        webSteps.selectVisibleText("Eastspring Global Emerging Market Dynamic Fund", "myvar.abc");
        //verify(webTaskSvc, times(1)).selectVisibleText("Eastspring Global Emerging Market Dynamic Fund", we1);
    }

    @Test
    public void testSelectVisibleValueOn_others() {
        when(stateSvc.getStringVar("myvar.abc")).thenReturn("others://div[@id='submitBtn']");
        webSteps.selectVisibleText("Eastspring Global Emerging Market Dynamic Fund", "myvar.abc");
        //verify(webTaskSvc, times(1)).selectVisibleText("Eastspring Global Emerging Market Dynamic Fund", null);
    }

    @Test
    public void testSelectVisibleValueOn_byId() {
        List<WebElement> elements = new ArrayList<>();
        elements.add(we1);
        when(stateSvc.getStringVar("myvar.abc")).thenReturn("id:myid123");
        when(webTaskSvc.findElementsById("myid123")).thenReturn(elements);
        webSteps.selectVisibleText("Eastspring Global Emerging Market Dynamic Fund", "myvar.abc");
        //verify(webTaskSvc, times(1)).selectVisibleText("Eastspring Global Emerging Market Dynamic Fund", we1);
    }

    @Test
    public void testAssignCurrentBrowserWindowHandleNameToVar() {
        when(webTaskSvc.getCurrentBrowserWindowHandleName()).thenReturn("handleName");
        webSteps.assignCurrentBrowserWindowHandleNameToVar("justAVarName");
        verify(stateSvc, times(1)).setStringVar("justAVarName", "handleName");
    }

    @Test
    public void testClickOp_null() {
        Throwable thrown = null;

        try {
            webSteps.clickOp(null);
        } catch (Throwable t) {
            thrown = t;
        }
        assertNotNull(thrown);
        assertTrue(thrown instanceof CartException);

        CartException ce = (CartException) thrown;
        assertEquals(CartExceptionType.UNSATISFIED_IMPLICIT_ASSUMPTION, ce.getExceptionType());
        assertEquals("web element should not be null or empty", ce.getMessage());
    }

    @Test
    public void testClickOp_emptyString() {
        Throwable thrown = null;

        try {
            webSteps.clickOp("");
        } catch (Throwable t) {
            thrown = t;
        }
        assertNotNull(thrown);
        assertTrue(thrown instanceof CartException);

        CartException ce = (CartException) thrown;
        assertEquals(CartExceptionType.UNSATISFIED_IMPLICIT_ASSUMPTION, ce.getExceptionType());
        assertEquals("web element should not be null or empty", ce.getMessage());
    }


    @Test
    public void testClickOp_OPCODE_XPATH_XY_PCT_others() {
        List<WebElement> elements = new ArrayList<>();
        elements.add(we1);

        when(webTaskSvc.findElementsByXPath("//div[@class='a']/div[@id='b']")).thenReturn(elements);
        when(stateSvc.getStringVar("myvar.abc")).thenReturn("others:20,60://div[@class='a']/div[@id='b']");
        when(stateSvc.expandVar("others:20,60://div[@class='a']/div[@id='b']")).thenReturn("others:20,60://div[@class='a']/div[@id='b']");
        webSteps.clickOp("myvar.abc");
    }


    @Test
    public void testClickXPathWithCoordPct_zeroElementSize() {
        Throwable thrown = null;

        List<WebElement> elements = new ArrayList<>();
        when(webTaskSvc.findElementsByXPath("//div[@id='asdfiu5']/span")).thenReturn(elements);
        try {
            webSteps.clickXPathWithCoordPct("//div[@id='asdfiu5']/span", 20, 60);
        } catch (Exception e) {
            thrown = e;
        }

        assertNotNull(thrown);
        assertTrue(thrown instanceof CartException);

        CartException ce = (CartException) thrown;
        assertEquals(CartExceptionType.UNSATISFIED_IMPLICIT_ASSUMPTION, ce.getExceptionType());
        assertEquals("element not found", ce.getMessage());
    }

    @Test
    public void testClickXPathWithCoordPct() {
        List<WebElement> elements = new ArrayList<>();
        elements.add(we1);
        elements.add(we2);
        when(webTaskSvc.findElementsByXPath("//div[@id='asdfiu5']/span")).thenReturn(elements);
        webSteps.clickXPathWithCoordPct("//div[@id='asdfiu5']/span", 20, 60);
        verify(webTaskSvc, times(1)).clickByCoordPct(we1, 20, 60);
    }

    @Test
    public void testMoveDownloadedFileToTestEvidenceDir() {
        when(workspaceUtil.getUserDownloadDir()).thenReturn("c:/Users/fakeuser/Downloads");
        when(workspaceUtil.getTestEvidenceDir()).thenReturn("c:/tomwork/cart-tests/testout/evidence");
        when(fileDirUtil.addPrefixIfNotAbsolute("topic1", "c:/tomwork/cart-tests/testout/evidence/")).thenReturn("c:/tomwork/cart-tests/testout/evidence/topic1");
        webSteps.moveDownloadedFileToTestEvidenceDir("filename1.ext", "topic1");
        verify(fileDirUtil, times(1)).moveFileToDirectory("c:/Users/fakeuser/Downloads/filename1.ext", "c:/tomwork/cart-tests/testout/evidence/topic1", true);
    }

    @Test
    public void testMoveDownloadedFileToTestEvidenceDir_absoluteDirNoDrive() {
        when(workspaceUtil.getUserDownloadDir()).thenReturn("c:/Users/fakeuser/Downloads");
        when(workspaceUtil.getTestEvidenceDir()).thenReturn("c:/tomwork/cart-tests/testout/evidence");
        when(fileDirUtil.addPrefixIfNotAbsolute("/topic1", "c:/tomwork/cart-tests/testout/evidence/")).thenReturn("/topic1");
        webSteps.moveDownloadedFileToTestEvidenceDir("filename1.ext", "/topic1");
        verify(fileDirUtil, times(1)).moveFileToDirectory("c:/Users/fakeuser/Downloads/filename1.ext", "/topic1", true);
    }

    @Test
    public void testMoveDownloadedFileToTestEvidenceDir_absoluteDirWithDrive() {
        when(workspaceUtil.getUserDownloadDir()).thenReturn("c:/Users/fakeuser/Downloads");
        when(workspaceUtil.getTestEvidenceDir()).thenReturn("c:/tomwork/cart-tests/testout/evidence");
        when(fileDirUtil.addPrefixIfNotAbsolute("z:/topic1", "c:/tomwork/cart-tests/testout/evidence/")).thenReturn("z:/topic1");
        webSteps.moveDownloadedFileToTestEvidenceDir("filename1.ext", "z:/topic1");
        verify(fileDirUtil, times(1)).moveFileToDirectory("c:/Users/fakeuser/Downloads/filename1.ext", "z:/topic1", true);
    }

    @Test
    public void testRightClickOp_null() {
        Exception thrown = null;
        try {
            webSteps.rightClickOp(null, true);
        } catch (Exception e) {
            thrown = e;
        }
        assertNotNull(thrown);
        assertTrue(thrown instanceof CartException);
        assertEquals("web element should not be null or empty", thrown.getMessage());
    }

    @Test
    public void testRightClickOp_emptyString() {
        Exception thrown = null;
        try {
            webSteps.rightClickOp("", true);
        } catch (Exception e) {
            thrown = e;
        }
        assertNotNull(thrown);
        assertTrue(thrown instanceof CartException);
        assertEquals("web element should not be null or empty", thrown.getMessage());
    }

    @Test
    public void testRightClickOp_opCode_xpath() {
        when(stateSvc.getStringVar("paramOpVar")).thenReturn("xpath:param1");
        webSteps.rightClickOp("paramOpVar", true);
        verify(webTaskSvc, times(1)).rightClickXPath("param1");
    }

    @Test
    public void testRightClickOp_opCode_thers() {
        when(stateSvc.getStringVar("paramOpVar")).thenReturn("others:param1:param2");
        webSteps.rightClickOp("paramOpVar", true);
    }

    @Test
    public void testRightClickOp_opCode_id() {
        when(stateSvc.getStringVar("paramOpVar")).thenReturn("id:param1");
        webSteps.rightClickOp("paramOpVar", true);
        verify(webTaskSvc, times(1)).rightClickId("param1");
    }

    @Test
    public void testRightClickOp_opCode_idNotOnVar() {
        webSteps.rightClickOp("id:param1", false);
        verify(webTaskSvc, times(1)).rightClickId("param1");
    }

    @Test
    public void testRightClickOp_opCode_xpath_xy_pct_nullParam2() {
        when(stateSvc.getStringVar("paramOpVar")).thenReturn("xpath-xy-pct:param1");
        Exception thrownException = null;
        try {
            webSteps.rightClickOp("paramOpVar", true);
        } catch (Exception e) {
            thrownException = e;
        }
        Assert.assertNotNull(thrownException);
        Assert.assertTrue(thrownException instanceof CartException);
        Assert.assertEquals(WebSteps.XPATH_XY_PCT_FORMAT_GUIDE, thrownException.getMessage());
    }

    @Test
    public void testRightClickOp_opCode_xpath_xy_pct_success() {
        List<WebElement> elements = new ArrayList<>();
        elements.add(we1);
        when(stateSvc.getStringVar("paramOpVar")).thenReturn("xpath-xy-pct:102,34://div[@name='abc']");
        when(webTaskSvc.findElementsByXPath("//div[@name='abc']")).thenReturn(elements);
        webSteps.rightClickOp("paramOpVar", true);
        verify(webTaskSvc, times(1)).rightClickByCoordPct(we1, 102, 34);
    }

    @Test
    public void testEnterTextIntoGeneric_id() {
        String text = "abc";
        String webElementId = "id:abcd";
        when(stateSvc.expandVar(text)).thenReturn(text);
        when(stateSvc.expandVar(webElementId)).thenReturn(webElementId);
        when(webTaskSvc.waitForElementToAppear("id:abcd", 10)).thenReturn(we1);
        WebIdentifiersMetadata metadata = new WebIdentifiersMetadata();
        metadata.setOpCode("id");
        metadata.setParam1("abcd");
        when(webTaskSvc.getWebElementIdentifiers(webElementId)).thenReturn(metadata);
        webSteps.enterTextIntoGeneric(text, webElementId, true, null, 10);
        verify(webTaskSvc, times(1)).enterTextIntoWebElement(we1, text, null);
    }

    @Test
    public void testEnterTextIntoGeneric_idNotOnVar() {
        String text = "abc";
        String webElementId = "id:abcd";
        when(stateSvc.expandVar(text)).thenReturn(text);
        when(stateSvc.expandVar(webElementId)).thenReturn(webElementId);
        when(webTaskSvc.waitForElementToAppear("id:abcd", 10)).thenReturn(we1);
        WebIdentifiersMetadata metadata = new WebIdentifiersMetadata();
        metadata.setOpCode("id");
        metadata.setParam1("abcd");
        when(webTaskSvc.getWebElementIdentifiers(webElementId)).thenReturn(metadata);
        webSteps.enterTextIntoGeneric(text, webElementId, false, null, 10);
        verify(webTaskSvc, times(1)).enterTextIntoWebElement(we1, text, null);
    }

    @Test
    public void testEnterTextIntoGeneric_xpath() {
        String text = "abc";
        String webElementId = "xpath://div[text()='abcd']";
        when(stateSvc.expandVar(text)).thenReturn(text);
        when(stateSvc.getStringVar(webElementId)).thenReturn(webElementId);
        when(stateSvc.expandVar(webElementId)).thenReturn(webElementId);
        when(webTaskSvc.waitForElementToAppear(webElementId, 10)).thenReturn(we1);
        WebIdentifiersMetadata metadata = new WebIdentifiersMetadata();
        metadata.setOpCode("xpath");
        metadata.setParam1("//div[text()='abcd']");
        when(webTaskSvc.getWebElementIdentifiers(webElementId)).thenReturn(metadata);
        webSteps.enterTextIntoGeneric(text, webElementId, true, null, 10);
        verify(webTaskSvc, times(1)).enterTextIntoWebElement(we1, text, null);
    }

    //TODO - Fix test - functionality not in use
    //@Test
    public void testEnterTextIntoGeneric_xpathXYPct() {
        String text = "abc";
        String webElementId = "xpath-xy-pct:70,30://div[text()='abcd']";
        when(stateSvc.expandVar(text)).thenReturn(text);
        when(stateSvc.getStringVar(webElementId)).thenReturn(webElementId);
        when(stateSvc.expandVar(webElementId)).thenReturn(webElementId);
        when(webTaskSvc.waitForElementToAppear(webElementId, 10)).thenReturn(we1);
        WebIdentifiersMetadata metadata = new WebIdentifiersMetadata();
        metadata.setOpCode("xpath-xy-pct");
        metadata.setParam1("70,30");
        metadata.setParam2("//div[text()='abcd']");
        metadata.setXcordinate(70);
        metadata.setYcordinate(30);
        when(webTaskSvc.getWebElementIdentifiers(webElementId)).thenReturn(metadata);
        List<WebElement> elements = new ArrayList<>();
        elements.add(we2);
        when(webTaskSvc.findElementsByXPath("//div[text()='abcd']")).thenReturn(elements);
        webSteps.enterTextIntoGeneric(text, webElementId, true, null, 10);
        verify(webTaskSvc, times(1)).enterTextIntoWebElement(we1, text, null);
        verify(webTaskSvc, times(1)).clickByCoordPct(we2, 70, 30);
    }

    //TODO - Fix test - functionality not in use
    //@Test
    public void testEnterTextIntoGeneric_others() {
        String text = "abc";
        String webElementId = "others:70,30://div[text()='abcd']";
        when(stateSvc.expandVar(text)).thenReturn(text);
        when(stateSvc.getStringVar(webElementId)).thenReturn(webElementId);
        when(stateSvc.expandVar(webElementId)).thenReturn(webElementId);
        when(webTaskSvc.waitForElementToAppear(By.xpath("//div[text()='abcd']"), 10)).thenReturn(we1);
        WebIdentifiersMetadata metadata = new WebIdentifiersMetadata();
        metadata.setOpCode("others");
        metadata.setParam1("70,30");
        metadata.setParam2("//div[text()='abcd']");
        metadata.setXcordinate(70);
        metadata.setYcordinate(30);
        when(webTaskSvc.getWebElementIdentifiers(webElementId)).thenReturn(metadata);
        List<WebElement> elements = new ArrayList<>();
        elements.add(we2);
        when(webTaskSvc.findElementsByXPath("//div[text()='abcd']")).thenReturn(elements);
        webSteps.enterTextIntoGeneric(text, webElementId, true, null, 10);
        verify(webTaskSvc, times(1)).enterTextIntoWebElement(null, text, null);
    }

    @Test
    public void testEnterTextIntoGeneric_negative_nullOpcode() {
        thrown.expect(CartException.class);
        thrown.expectMessage("invalid web element specification [xpath://div[text()='abcd']] ==> [xpath://div[text()='abcd']]");
        String text = "abc";
        String webElementId = "xpath://div[text()='abcd']";
        when(stateSvc.expandVar(text)).thenReturn(text);
        when(stateSvc.getStringVar(webElementId)).thenReturn(webElementId);
        when(stateSvc.expandVar(webElementId)).thenReturn(webElementId);
        WebIdentifiersMetadata metadata = new WebIdentifiersMetadata();
        metadata.setOpCode(null);
        metadata.setParam1("//div[text()='abcd']");
        when(webTaskSvc.getWebElementIdentifiers(webElementId)).thenReturn(metadata);
        webSteps.enterTextIntoGeneric(text, webElementId, true, null, 10);
    }

    @Test
    public void testWaitMaxTimeForTheElementToAppear_withIdOnVar() {
        String webElementId = "id:abcd";
        By by = By.id("abcd");
        when(stateSvc.getStringVar(webElementId)).thenReturn(webElementId);
        when(stateSvc.expandVar(webElementId)).thenReturn(webElementId);
        WebIdentifiersMetadata metadata = new WebIdentifiersMetadata();
        metadata.setOpCode("id");
        metadata.setParam1("abcd");
        when(webTaskSvc.getWebElementIdentifiers(webElementId)).thenReturn(metadata);
        when(webTaskSvc.getByReference("id", "abcd")).thenReturn(by);
        when(webTaskSvc.waitForElementToAppear(by, 20)).thenReturn(we1);
        webSteps.waitMaxTimeForTheElementToAppear(20, webElementId, true);
        verify(webTaskSvc, times(1)).waitForElementToAppear(by, 20);
    }

    @Test
    public void testWaitMaxTimeForTheElementToAppear_withIdNotOnVar() {
        String webElementId = "id:abcd";
        By by = By.id("abcd");
        when(stateSvc.expandVar(webElementId)).thenReturn(webElementId);
        when(webTaskSvc.waitForElementToAppear(By.id("abcd"), 20)).thenReturn(we1);
        WebIdentifiersMetadata metadata = new WebIdentifiersMetadata();
        metadata.setOpCode("id");
        metadata.setParam1("abcd");
        when(webTaskSvc.getWebElementIdentifiers(webElementId)).thenReturn(metadata);
        when(webTaskSvc.getByReference("id", "abcd")).thenReturn(by);
        webSteps.waitMaxTimeForTheElementToAppear(20, webElementId, false);
        verify(webTaskSvc, times(1)).waitForElementToAppear(By.id("abcd"), 20);
    }

    @Test
    public void testWaitMaxTimeForTheElementToAppear_withXpath() {
        String webElementId = "xpath://div[text()='abcd']";
        By by = By.xpath("//div[text()='abcd']");
        when(stateSvc.getStringVar(webElementId)).thenReturn(webElementId);
        when(stateSvc.expandVar(webElementId)).thenReturn(webElementId);
        when(webTaskSvc.waitForElementToAppear(By.xpath("//div[text()='abcd']"), 20)).thenReturn(we1);
        WebIdentifiersMetadata metadata = new WebIdentifiersMetadata();
        metadata.setOpCode("xpath");
        metadata.setParam1("//div[text()='abcd']");
        when(webTaskSvc.getByReference("xpath", "//div[text()='abcd']")).thenReturn(by);
        when(webTaskSvc.getWebElementIdentifiers(webElementId)).thenReturn(metadata);
        webSteps.waitMaxTimeForTheElementToAppear(20, webElementId, true);
        verify(webTaskSvc, times(1)).waitForElementToAppear(by, 20);
    }

    @Test
    public void testWaitMaxTimeForTheElementToAppear_negative_invalidOpCode() {
        thrown.expect(CartException.class);
        thrown.expectMessage("Invalid OP Code");
        String webElementId = "xyz:abcd";
        WebIdentifiersMetadata metadata = new WebIdentifiersMetadata();
        metadata.setOpCode("xyz");
        metadata.setParam1("abcd");
        when(webTaskSvc.getByReference("xyz", "abcd")).thenThrow(new CartException(CartExceptionType.INCOMPLETE_PARAMS, "Invalid OP Code"));
        when(webTaskSvc.getWebElementIdentifiers(webElementId)).thenReturn(metadata);
        when(stateSvc.getStringVar(webElementId)).thenReturn(webElementId);
        when(stateSvc.expandVar(webElementId)).thenReturn(webElementId);
        webSteps.waitMaxTimeForTheElementToAppear(20, webElementId, true);
    }

    @Test
    public void testWaitMaxTimeForTheElementToAppear_negative_nullOpCode() {
        thrown.expect(CartException.class);
        thrown.expectMessage("OpCode Cannot be Null or Empty");
        String webElementId = "xyz:abcd";
        WebIdentifiersMetadata metadata = new WebIdentifiersMetadata();
        metadata.setOpCode(null);
        metadata.setParam1("abcd");
        when(webTaskSvc.getWebElementIdentifiers(webElementId)).thenReturn(metadata);
        when(webTaskSvc.getByReference(null, "abcd")).thenThrow(new CartException(CartExceptionType.INCOMPLETE_PARAMS, "OpCode Cannot be Null or Empty"));
        when(stateSvc.getStringVar(webElementId)).thenReturn(webElementId);
        when(stateSvc.expandVar(webElementId)).thenReturn(webElementId);
        webSteps.waitMaxTimeForTheElementToAppear(20, webElementId, true);
    }

    @Test
    public void testWaitMaxTimeForTheElementToAppear_negative_nullElement() {
        thrown.expect(CartException.class);
        thrown.expectMessage("Unable to get web element [xpath://div[@id='abc']] within [20] seconds");
        String webElementId = "xpath://div[@id='abc']";
        WebIdentifiersMetadata metadata = new WebIdentifiersMetadata();
        metadata.setOpCode("xpath");
        metadata.setParam1("//div[@id='abc']");
        when(webTaskSvc.getWebElementIdentifiers(webElementId)).thenReturn(metadata);
        when(stateSvc.getStringVar(webElementId)).thenReturn(webElementId);
        when(stateSvc.expandVar(webElementId)).thenReturn(webElementId);
        when(webTaskSvc.waitForElementToAppear(By.xpath("//div[@id='abc']"), 20)).thenReturn(null);
        webSteps.waitMaxTimeForTheElementToAppear(20, webElementId, true);
    }

    @Test(expected = CartException.class)
    public void testRightClickXPathWithCoordPct() {
        List<WebElement> emptyList = new ArrayList<>();
        when(webTaskSvc.findElementsByXPath("//div[@id='myid14']")).thenReturn(emptyList);
        webSteps.rightClickXPathWithCoordPct("//div[@id='myid14']", 530, 70);
    }
}
