package com.eastspring.tom.cart.core.steps;

import com.eastspring.tom.cart.core.CartException;
import com.eastspring.tom.cart.core.CartExceptionType;
import com.eastspring.tom.cart.core.constants.SELECT_ACTION;
import com.eastspring.tom.cart.core.mdl.WebGenericOp;
import com.eastspring.tom.cart.core.mdl.WebIdentifiersMetadata;
import com.eastspring.tom.cart.core.svc.StateSvc;
import com.eastspring.tom.cart.core.svc.ThreadSvc;
import com.eastspring.tom.cart.core.svc.WebTaskSvc;
import com.eastspring.tom.cart.core.utl.FileDirUtil;
import com.eastspring.tom.cart.core.utl.FormatterUtil;
import com.eastspring.tom.cart.core.utl.WorkspaceUtil;
import com.google.common.base.Strings;
import org.h2.util.StringUtils;
import org.openqa.selenium.By;
import org.openqa.selenium.WebElement;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;

import java.util.List;
import java.util.Objects;

import static com.eastspring.tom.cart.core.mdl.WebGenericOp.*;

public class WebSteps {
    private static final Logger LOGGER = LoggerFactory.getLogger(WebSteps.class);

    static final String XPATH_XY_PCT_FORMAT_GUIDE = "xpath-xy-pct should be in the format [xpath-xy-pct:<pct-x>,<pct-y>:<xpath-query>] e.g. [xpath-xy-pct:75,50://div[@id='id113']/div]";
    static final String INVALID_WEB_ELEMENT_SPECIFICATION = "invalid web element specification [{}] ==> [{}]";
    static final String WEB_ELEMENT_SHOULD_NOT_BE_NULL_OR_EMPTY = "web element should not be null or empty";
    static final String ELEMENT_NOT_FOUND = "element not found";

    @Autowired
    private FileDirUtil fileDirUtil;

    @Autowired
    private FormatterUtil formatter;

    @Autowired
    private StateSvc stateSvc;

    @Autowired
    private ThreadSvc threadSvc;

    @Autowired
    private WebTaskSvc webTaskSvc;

    @Autowired
    private WorkspaceUtil workspaceUtil;


    public boolean xpathResultsEmpty(String xpath) {
        return webTaskSvc.xpathResultsEmpty(xpath);
    }

    public void setImplicitWaitSeconds(int seconds) {
        webTaskSvc.setImplicitWait(seconds);
    }


    public void pauseForSeconds(Integer seconds) {
        threadSvc.sleepSeconds(seconds);
    }

    public void pauseForSecondsWithVar(String seconds) {
        Integer expandSeconds = Integer.valueOf(stateSvc.expandVar(seconds));
        threadSvc.sleepSeconds(expandSeconds);
    }

    public void takeScreenshot() {
        webTaskSvc.takeScreenshot();
    }

    public void openWebUrl(String url) {
        webTaskSvc.openWebUrl(stateSvc.expandVar(url));
    }

    public void clickById(String id) {
        webTaskSvc.clickId(id);
    }

    public void submitById(String id) {
        webTaskSvc.submitId(id);
    }

    public void submit(final String opOnWebElement) {
        final String expandLocator = stateSvc.expandVar(opOnWebElement);
        webTaskSvc.submit(expandLocator, 0);
    }

    public void submitByXpath(String xpath) {
        webTaskSvc.submitXpath(xpath);
    }

    public void clickByCss(String cssClass) {
        webTaskSvc.clickCss(cssClass);
    }

    public void clickByXpath(String xpathQuery) {
        webTaskSvc.clickXPath(xpathQuery);
    }

    public void webElementByIdShown(String webElementId) {
        webTaskSvc.webElementByIdShown(webElementId);
    }

    public void webElementByXPathShown(String xpath) {
        webTaskSvc.webElementByXPathShown(xpath);
    }

    public void setWebConfigToPropPrefix(String webConfigName, String propPrefix) {
        webTaskSvc.setWebConfigToPropPrefix(webConfigName, propPrefix);
    }

    public void clickXPathUsingJavascript(String xpath) {
        webTaskSvc.clickXPathUsingJavascript(xpath);
    }

    public void openSessionByWebConfigName(String webConfigName) {
        webTaskSvc.openSessionByWebConfigName(webConfigName);
    }

    public void clickByPropKey(String propKey) {
        webTaskSvc.clickWebByPropKey(propKey);
    }

    public void closeAllOpenBrowsers() {
        webTaskSvc.quitWebDriver();
    }

    public void closeBrowserInstance() {
        webTaskSvc.closeBrowserInstance();
    }

    public void clickWhoseText(String text) {
        webTaskSvc.clickWhoseText(text);
    }

    public List<WebElement> findElementsByXPath(String xpath) {
        return webTaskSvc.findElementsByXPath(xpath);
    }

    public void moveDownloadedFileToTestEvidenceDir(String filename, String testEvidenceLocation) {
        String downloadFullpath = workspaceUtil.getUserDownloadDir() + '/' + filename;
        String testEvidenceDir = workspaceUtil.getTestEvidenceDir();
        String destFullpath = fileDirUtil.addPrefixIfNotAbsolute(testEvidenceLocation, testEvidenceDir + '/');
        LOGGER.debug("moved downloaded file: [{}] to [{}]", downloadFullpath, destFullpath);
        fileDirUtil.moveFileToDirectory(downloadFullpath, destFullpath, true);
    }

    public void clickXPathWhenOnWindowThatHasXPath(String toClickWebElementXPath, String windowSelectorXPath) {
        String expandedToClickWebElementXPath = stateSvc.expandVar(toClickWebElementXPath);
        String expandedWindowSelectorXPath = stateSvc.expandVar(windowSelectorXPath);
        LOGGER.debug("expandedToClickWebElementXPath: {}", expandedToClickWebElementXPath);
        LOGGER.debug("expandedWindowSelectorXPath: {}", expandedWindowSelectorXPath);
        for (String activeHandle : webTaskSvc.getWindowHandles()) {
            LOGGER.debug("switching to webdriver window handle [{}]", activeHandle);
            webTaskSvc.switchToWindowHandle(activeHandle);
            List<WebElement> elements = webTaskSvc.findElementsByXPath(expandedWindowSelectorXPath);
            if (LOGGER.isDebugEnabled()) {
                LOGGER.debug("  elements found: [{}]", Objects.toString(elements));
            }
            LOGGER.debug("  elements size: [{}]", elements.size());
            if (!elements.isEmpty()) {
                webTaskSvc.clickXPath(expandedToClickWebElementXPath);
                LOGGER.debug("  ==> click xpath [{}]", expandedToClickWebElementXPath);
            }
        }
    }

    public void switchToNextBrowserTab() {
        webTaskSvc.switchToNextBrowserTab();
    }

    /**
     * <p>This method selects a select item with visible text <b>text</b></p>
     *
     * @param text
     * @param elementSpecifierVar
     */
    public void selectVisibleText(String text, String elementSpecifierVar) {
        String elementSpecifier = stateSvc.getStringVar(elementSpecifierVar);
        webTaskSvc.selectElementBy(elementSpecifier, 10, SELECT_ACTION.VISIBLE_TEXT, text);
    }

    public void assignCurrentBrowserWindowHandleNameToVar(String varName) {
        String windowHandleName = webTaskSvc.getCurrentBrowserWindowHandleName();
        stateSvc.setStringVar(varName, windowHandleName);
    }

    public void clickOp(String paramOp) {


        if (Strings.isNullOrEmpty(paramOp)) {
            LOGGER.error(WEB_ELEMENT_SHOULD_NOT_BE_NULL_OR_EMPTY);
            throw new CartException(CartExceptionType.UNSATISFIED_IMPLICIT_ASSUMPTION, WEB_ELEMENT_SHOULD_NOT_BE_NULL_OR_EMPTY);
        }

        String opOnWebElement = stateSvc.expandVar(paramOp);
        webTaskSvc.click(opOnWebElement);
    }

    public void rightClickOp(String paramOp, boolean onVar) {
        if (Strings.isNullOrEmpty(paramOp)) {
            LOGGER.error(WEB_ELEMENT_SHOULD_NOT_BE_NULL_OR_EMPTY);
            throw new CartException(CartExceptionType.UNSATISFIED_IMPLICIT_ASSUMPTION, WEB_ELEMENT_SHOULD_NOT_BE_NULL_OR_EMPTY);
        }

        String opOnWebElement = paramOp;
        if (onVar) {
            opOnWebElement = stateSvc.getStringVar(paramOp);
        }
        WebGenericOp op = WebGenericOp.parseString(opOnWebElement);
        LOGGER.debug("rightClickOp.op: {}", op);
        String opCode = op.getOpCode();
        if (OPCODE_XPATH.equals(opCode)) {
            webTaskSvc.rightClickXPath(op.getParam1());
        } else if (OPCODE_ID.equals(opCode)) {
            webTaskSvc.rightClickId(op.getParam1());
        } else if (OPCODE_XPATH_XY_PCT.equals(opCode)) {
            String param2 = op.getParam2();
            if (StringUtils.isNullOrEmpty(param2)) {
                LOGGER.error(XPATH_XY_PCT_FORMAT_GUIDE);
                throw new CartException(CartExceptionType.INCOMPLETE_PARAMS, XPATH_XY_PCT_FORMAT_GUIDE);
            }
            String[] pctSplit = op.getParam1().split(",");
            int pctX = Integer.parseInt(pctSplit[0]);
            int pctY = Integer.parseInt(pctSplit[1]);
            rightClickXPathWithCoordPct(param2, pctX, pctY);
        }
    }

    public void clickXPathWithCoordPct(String xpath, int pctX, int pctY) {
        List<WebElement> elements = webTaskSvc.findElementsByXPath(xpath);
        if (!elements.isEmpty()) {
            WebElement element = elements.get(0);
            webTaskSvc.clickByCoordPct(element, pctX, pctY);
        } else {
            LOGGER.error(ELEMENT_NOT_FOUND);
            throw new CartException(CartExceptionType.UNSATISFIED_IMPLICIT_ASSUMPTION, ELEMENT_NOT_FOUND);
        }
    }

    public void rightClickXPathWithCoordPct(String xpath, int pctX, int pctY) {
        List<WebElement> elements = webTaskSvc.findElementsByXPath(xpath);
        if (!elements.isEmpty()) {
            WebElement element = elements.get(0);
            webTaskSvc.rightClickByCoordPct(element, pctX, pctY);
        } else {
            LOGGER.error(ELEMENT_NOT_FOUND);
            throw new CartException(CartExceptionType.UNSATISFIED_IMPLICIT_ASSUMPTION, ELEMENT_NOT_FOUND);
        }
    }

    public void enterTextIntoById(String text, String id) {
        webTaskSvc.enterTextIntoById(stateSvc.expandVar(text), stateSvc.expandVar(id));
    }

    /**
     * <p>This method enter text into web element specified by <b>webElement</b> parameter.</p>
     *
     * @param text       text to be entered into web element
     * @param webElement web element specifier
     * @param onVar      indicates whether the web element is a variable
     */
    public void enterTextIntoGeneric(String text, String webElement, boolean onVar, String followingKey, int waitTimeoutSeconds) {
        threadSvc.inbetweenStepsWait();
        String expandedText = stateSvc.expandVar(text);
        String expandedWebElementSpec = stateSvc.expandVar(webElement);
        LOGGER.debug("webTaskSvc.enterTextIntoGeneric({},{},{},{})", expandedText, expandedWebElementSpec, followingKey, waitTimeoutSeconds);
        WebIdentifiersMetadata identifiers = webTaskSvc.getWebElementIdentifiers(expandedWebElementSpec);

        String opCode = identifiers.getOpCode();
        if (opCode == null) {
            LOGGER.error(INVALID_WEB_ELEMENT_SPECIFICATION, webElement, expandedWebElementSpec);
            throw new CartException(CartExceptionType.INCOMPLETE_PARAMS, INVALID_WEB_ELEMENT_SPECIFICATION, webElement, expandedWebElementSpec);
        }
        WebElement element = webTaskSvc.waitForElementToAppear(expandedWebElementSpec, waitTimeoutSeconds);

        webTaskSvc.enterTextIntoWebElement(element, expandedText, followingKey);
    }

    /**
     * <p>This method read the attribute from web element specified by locator
     *
     * @param attribute name of the attribute to read from web element
     * @param locator   web element specifier
     */
    public void readAttributeFromLocator(String attribute, String locator, String variable) {
        String attributeVal = webTaskSvc.getWebElementAttribute(locator, attribute);
        stateSvc.setStringVar(variable, attributeVal);
    }

    /**
     * <p>This method verify the attribute from web element specified by locator
     *
     * @param attribute     name of the attribute to read from web element
     * @param locator       web element specifier
     * @param expectedValue expected value of attribute
     */
    public void verifyAttributeFromLocator(String attribute, String locator, String expectedValue) {
        String actualVal = webTaskSvc.getWebElementAttribute(locator, attribute);
        final String expandedExpVal = stateSvc.expandVar(expectedValue);
        if (!actualVal.equals(expandedExpVal)) {
            LOGGER.error("Attribute verification failed for locator {},expected [{}] but actual [{}] ", locator, expandedExpVal, actualVal);
            throw new CartException(CartExceptionType.VERIFICATION_FAILED, "Attribute verification failed for locator {},expected [{}] but actual [{}] ", locator, expandedExpVal, actualVal);
        }
    }

    public void waitMaxTimeForTheElementToAppear(Integer maxWaitTime, String webElement, boolean onVar) {
        final String webElementSpec = onVar ? stateSvc.getStringVar(webElement) : webElement;
        final String expandedWebElementSpec = stateSvc.expandVar(webElementSpec);
        final WebIdentifiersMetadata identifiers = webTaskSvc.getWebElementIdentifiers(expandedWebElementSpec);

        final String opCode = identifiers.getOpCode();
        final String param1 = identifiers.getParam1();

        LOGGER.debug("Opcode captured as [{}] and value [{}]", opCode, param1);

        final By by = webTaskSvc.getByReference(opCode, param1);
        final WebElement element = webTaskSvc.waitForElementToAppear(by, maxWaitTime);

        if (element == null) {
            LOGGER.error("Unable to get web element [{}] within [{}] seconds", expandedWebElementSpec, maxWaitTime);
            throw new CartException(CartExceptionType.PROCESSING_FAILED, "Unable to get web element [{}] within [{}] seconds", expandedWebElementSpec, maxWaitTime);
        }
    }

    public void scrollElementIntoView(final String webElementProps) {
        LOGGER.debug("WebElement Props [{}]", webElementProps);
        final String elementSpec = stateSvc.getStringVar(webElementProps);

        String effectiveSpec = !Objects.equals(elementSpec, "") ? stateSvc.expandVar(elementSpec) : elementSpec;
        LOGGER.debug("Effective Props [{}]", effectiveSpec);

        webTaskSvc.scrollElementIntoView(effectiveSpec);
    }
}
