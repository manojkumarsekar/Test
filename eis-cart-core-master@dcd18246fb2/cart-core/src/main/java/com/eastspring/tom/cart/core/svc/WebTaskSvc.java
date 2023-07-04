package com.eastspring.tom.cart.core.svc;

import com.eastspring.tom.cart.core.CartException;
import com.eastspring.tom.cart.core.CartExceptionType;
import com.eastspring.tom.cart.core.constants.SELECT_ACTION;
import com.eastspring.tom.cart.core.mdl.WebGenericOp;
import com.eastspring.tom.cart.core.mdl.WebIdentifiersMetadata;
import com.eastspring.tom.cart.core.utl.*;
import com.google.common.base.Function;
import com.google.common.base.Strings;
import org.openqa.selenium.*;
import org.openqa.selenium.interactions.Actions;
import org.openqa.selenium.support.ui.*;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;

import java.io.File;
import java.time.Duration;
import java.util.ArrayList;
import java.util.Hashtable;
import java.util.List;
import java.util.Map;
import java.util.concurrent.TimeUnit;
import java.util.stream.Collectors;
import java.util.stream.Stream;

import static com.eastspring.tom.cart.core.mdl.WebGenericOp.*;
import static com.eastspring.tom.cart.core.svc.ElementWaitSvc.evaluateJsCondition;
import static com.eastspring.tom.cart.core.svc.WebDriverSvc.DEFAULT_IMPLICIT_WAIT_SECONDS;

public class WebTaskSvc {

    private static final Logger LOGGER = LoggerFactory.getLogger(WebTaskSvc.class);

    public static final String XPATH_XY_PCT_FORMAT_GUIDE = "xpath-xy-pct should be in the format [xpath-xy-pct:<pct-x>,<pct-y>:<xpath-query>] e.g. [xpath-xy-pct:75,50://div[@id='id113']/div]";
    public static final String WEB_CONFIG_PREFIX = "web.config.";

    private ThreadLocal<Boolean> sessionEstablished = ThreadLocal.withInitial(() -> false);
    private Hashtable<String, Integer> namePrefices = new Hashtable<>();

    @Autowired
    private FileDirUtil fileDirUtil;

    @Autowired
    private CssUtil cssUtil;

    @Autowired
    private FormatterUtil formatter;

    @Autowired
    private NumericVerificationUtil numericVerificationUtil;

    @Autowired
    private StateSvc stateSvc;

    @Autowired
    private StringVerifyUtil stringVerifyUtil;

    @Autowired
    private ThreadSvc threadSvc;

    @Autowired
    private WebDriverSvc webDriverSvc;

    @Autowired
    private WorkspaceUtil workspaceUtil;

    @Autowired
    private ScenarioUtil scenarioUtil;

    @Autowired
    private DateTimeUtil dateTimeUtil;

    @Autowired
    private Map<String, Object> globalObjects;

    private InheritableThreadLocal<WebDriver> driver = new InheritableThreadLocal<>();

    public WebDriver getDriver() {
        if (getSessionEstablished()) {
            return driver.get();
        }
        LOGGER.error("Session is not established, please launch application");
        throw new CartException(CartExceptionType.UNDEFINED, "Session is not established, please launch application");
    }

    private WebDriver getNullOrWebDriver() {
        try {
            return getDriver();
        } catch (CartException e) {
            LOGGER.warn("looks like session is already closed or not initialized...");
            return null;
        }
    }

    private synchronized void initializeWebDriver() {
        this.driver.set(webDriverSvc.driver());
        setSessionEstablished(true);
    }

    Boolean getSessionEstablished() {
        return sessionEstablished.get();
    }

    private void setSessionEstablished(Boolean sessionEstablished) {
        this.sessionEstablished.set(sessionEstablished);
    }

    public void openWebUrl(String url) {
        if (!getSessionEstablished()) {
            this.initializeWebDriver();
            threadSvc.inbetweenStepsWait();
            setSessionEstablished(true);
            getDriver().get(url);
            getDriver().manage().window().maximize();
        }
    }

    public void openWebUrlOnSameSession(String url) {
        if (!getSessionEstablished()) {
            LOGGER.error("Session is not established yet");
            throw new CartException(CartExceptionType.INVALID_INVOCATION_PARAMS, "Session is not established yet");
        }
        getDriver().get(url);
    }

    public void quitWebDriver() {
        webDriverSvc.quit(getNullOrWebDriver());
        setSessionEstablished(false);
    }

    /**
     * Instead of Quitting all browser, we can user driver.get().close to just close the browser instance.
     */
    public void closeBrowserInstance() {
        webDriverSvc.close(getNullOrWebDriver());
        setSessionEstablished(false);
    }

    private Integer generateScreenshotNumber(final String namePrefix) {
        Integer snapshotNum;
        snapshotNum = namePrefices.getOrDefault(namePrefix, -1);
        namePrefices.put(namePrefix, snapshotNum + 1);
        return namePrefices.get(namePrefix);
    }

    public void takeScreenshotOnElement(WebElement element, String prefix) {
        final WebDriver driver = getDriver();
        if (driver instanceof TakesScreenshot) {
            File src = element.getScreenshotAs(OutputType.FILE);
            File dst = new File(workspaceUtil.getTestEvidenceDir() + "/web-screenshot/" + prefix + this.generateScreenshotNumber(prefix) + ".png");
            fileDirUtil.copyFile(src, dst);
            byte[] bytes = fileDirUtil.readFileToByteArray(dst.getAbsolutePath());
            scenarioUtil.embed(bytes, "image/png");
        }
    }

    public void takeScreenshotWithNamePrefix(String namePrefix) {
        final WebDriver driver = getDriver();
        if (driver instanceof TakesScreenshot) {
            File src = ((TakesScreenshot) driver).getScreenshotAs(OutputType.FILE);
            File dst = new File(workspaceUtil.getTestEvidenceDir() + "/web-screenshot/" + namePrefix + this.generateScreenshotNumber(namePrefix) + ".png");
            fileDirUtil.copyFile(src, dst);
            byte[] bytes = fileDirUtil.readFileToByteArray(dst.getAbsolutePath());
            scenarioUtil.embed(bytes, "image/png");
        } else {
            scenarioUtil.write(driver.getPageSource());
        }
    }

    public synchronized void takeScreenshot() {
        takeScreenshotWithNamePrefix("screenshot");
    }

    public void clickId(String id) {
        threadSvc.inbetweenStepsWait();
        WebElement element = getDriver().findElement(By.id(id));
        element.click();
    }

    public void rightClickId(String id) {
        threadSvc.inbetweenStepsWait();
        WebElement element = getDriver().findElement(By.id(id));
        Actions builder = new Actions(getDriver());
        builder.contextClick(element).perform();
    }

    public void clickCss(String id) {
        threadSvc.inbetweenStepsWait();
        WebElement element = getDriver().findElement(By.className(id));
        element.click();
    }

    public void clickXPath(String xpathQuery) {
        clickXPath(xpathQuery, 10);
    }

    public void clickXPath(String xpathQuery, int fluentWaitSeconds) {
        threadSvc.inbetweenStepsWait();
        if (fluentWaitSeconds == 0) {
            // no implicit wait
            List<WebElement> elements = getDriver().findElements(By.xpath(xpathQuery));
            if (elements.isEmpty()) {
                throw new CartException(CartExceptionType.EXPECTED_WEBELEMENT_DOESNT_EXIST, "cannot find the element by xpath [{}]", xpathQuery);
            }
            elements.get(0).click();
        } else {
            WebElement element = waitForElementToAppear(By.xpath(xpathQuery), 30);
            element.click();
        }
    }

    public void rightClickXPath(String xpathQuery) {
        threadSvc.inbetweenStepsWait();
        List<WebElement> elements = getDriver().findElements(By.xpath(xpathQuery));
        if (elements.isEmpty()) {
            throw new CartException(CartExceptionType.EXPECTED_WEBELEMENT_DOESNT_EXIST, "cannot find the element by xpath [{}]", xpathQuery);
        }

        try {
            getActionsBinding()
                    .contextClick(elements.get(0))
                    .perform();
        } catch (Exception e) {
            LOGGER.error("Unable to perform right click on element [{}]", xpathQuery, e);
            throw new CartException(CartExceptionType.PROCESSING_FAILED, "Unable to perform right click on element [{}]", xpathQuery);
        }
    }


    public void webElementByIdShown(String webElementId) {
        threadSvc.inbetweenStepsWait();
        if (getDriver().findElements(By.id(webElementId)).isEmpty()) {
            throw new CartException(CartExceptionType.VERIFICATION_FAILED, "could not find web element specified by id [{}]", webElementId);
        }
    }

    public void webElementByXPathShown(String xpath) {
        threadSvc.inbetweenStepsWait();
        if (getDriver().findElements(By.xpath(xpath)).isEmpty()) {
            throw new CartException(CartExceptionType.VERIFICATION_FAILED, "could not find web element specified by id [{}]", xpath);
        }
    }


    public void setWebConfigToPropPrefix(String webConfigName, String propPrefix) {
        threadSvc.inbetweenStepsWait();
        globalObjects.put(WEB_CONFIG_PREFIX + webConfigName, propPrefix);
    }

    public void openSessionByWebConfigName(String webConfigName) {
        String propPrefix = (String) globalObjects.get(WEB_CONFIG_PREFIX + webConfigName);
        String protocol = stateSvc.getStringVar(propPrefix + ".url.protocol");
        String hostname = stateSvc.getStringVar(propPrefix + ".url.hostname");
        String context = stateSvc.getStringVar(propPrefix + ".url.context");
        String port = stateSvc.getStringVar(propPrefix + ".url.port");
        String user = stateSvc.getStringVar(propPrefix + ".user");
        String pwd = stateSvc.getStringVar(propPrefix + ".pass");

        String fullWebUrl = protocol + "://" + user + ":" + pwd + "@" + hostname + (port == null || "".equals(port) ? "" : ":" + port) + context;
        threadSvc.inbetweenStepsWait();
        getDriver().get(fullWebUrl);
        getDriver().manage().window().maximize();
        setSessionEstablished(true);
    }


    public void clickWebByPropKey(String propKey) {
        // inbetween waits will be invoked within the clickByXPath
        LOGGER.debug("clicking web element with propKey: [{}]", propKey);
        clickXPath(stateSvc.getStringVar(propKey));
    }

    public void clickWhoseText(String text) {
        LOGGER.debug("clickWhoseText(\"{}\")", text);
        String xpathQuery = "//a[text()='" + text + "']";
        clickXPath(xpathQuery);
    }

    public void setImplicitWait(int seconds) {
        getDriver().manage()
                .timeouts()
                .implicitlyWait(seconds, TimeUnit.SECONDS);
    }

    public void setDefaultImplicitWait() {
        getDriver().manage()
                .timeouts()
                .implicitlyWait(DEFAULT_IMPLICIT_WAIT_SECONDS, TimeUnit.SECONDS);
    }


    public boolean xpathResultsEmpty(String xpath) {
        return getDriver().findElements(By.xpath(xpath)).isEmpty();
    }

    public List<WebElement> findElementsByXPath(String xpath) {
        return getDriver().findElements(By.xpath(xpath));
    }

    public List<WebElement> findElementsById(String id) {
        return getDriver().findElements(By.id(id));
    }

    public List<WebElement> findElements(By by) {
        return getDriver().findElements(by);
    }

    public void switchToNextBrowserTab() {
        ArrayList<String> tabs = new ArrayList<>(getDriver().getWindowHandles());
        if (tabs.size() > 1) {
            getDriver().switchTo().window(tabs.get(1));
        } else if (!tabs.isEmpty()) {
            getDriver().switchTo().window(tabs.get(0));
        }
    }

    public void clickByCoordPct(WebElement webElement, int pctX, int pctY) {
        Point dim = cssUtil.getWebElementDimension(webElement);
        int ofsX = dim.getX() * pctX / 100;
        int ofsY = dim.getY() * pctY / 100;
        Actions actionsBuilder = new Actions(getDriver());
        actionsBuilder.moveToElement(webElement, ofsX, ofsY).click().build().perform();
    }

    public void rightClickByCoordPct(WebElement webElement, int pctX, int pctY) {
        Point dim = cssUtil.getWebElementDimension(webElement);
        int ofsX = dim.getX() * pctX / 100;
        int ofsY = dim.getY() * pctY / 100;
        Actions actionsBuilder = new Actions(getDriver());
        actionsBuilder.moveToElement(webElement, ofsX, ofsY).contextClick().build().perform();
    }

    public String getCurrentBrowserWindowHandleName() {
        return getDriver().getWindowHandle();
    }

    public List<String> getWindowHandles() {
        return new ArrayList<>(getDriver().getWindowHandles());
    }

    public WebDriver switchToWindowHandle(String handle) {
        return getDriver().switchTo().window(handle);
    }

    public void enterTextIntoById(String text, String id) {
        threadSvc.inbetweenStepsWait();
        WebElement element = getDriver().findElement(By.id(id));
        element.sendKeys(text);
    }

    public void enterTextIntoWebElement(String opOnWebElement, String text, String followingKey, int timeOutInSec) {
        final WebElement element = waitForElementToAppear(opOnWebElement, timeOutInSec);
        enterTextIntoWebElement(element, text, followingKey);
    }

    public void enterTextIntoWebElement(WebElement element, String text, String followingKey) {
        element.clear();
        element.sendKeys(text);
        threadSvc.sleepSeconds(1);
        if (followingKey != null) {
            if ("ENTER".equals(followingKey)) {
                element.sendKeys(Keys.ENTER);
            } else if ("ESCAPE".equals(followingKey)) {
                element.sendKeys(Keys.ESCAPE);
            } else if ("TAB".equals(followingKey)) {
                element.sendKeys(Keys.TAB);
            }
        }
    }


    /**
     * Wait for element to appear web element.
     * This function takes By reference and Max Timeout in Seconds as Arguments and returns WebElement Reference
     *
     * @param by             the by
     * @param timeoutSeconds the timeout seconds
     * @return the web element {@link WebElement}
     */
    @SuppressWarnings( "unchecked" )
    public WebElement waitForElementToAppear(final By by, final Integer timeoutSeconds) {
        try {
            LOGGER.debug("waitForElementToAppear [{}] in seconds", timeoutSeconds);
            int derivedTimeoutSeconds = timeoutSeconds == 0 ? 10 : timeoutSeconds;
            Wait wait = new FluentWait(getDriver())
                    .withTimeout(Duration.ofSeconds(derivedTimeoutSeconds))
                    .pollingEvery(Duration.ofSeconds(1))
                    .ignoring(NoSuchElementException.class)
                    .ignoring(StaleElementReferenceException.class);
            return (WebElement) wait.until(driver -> ((WebDriver) driver).findElement(by));
        } catch (Exception ex) {
            LOGGER.error("Element [{}] expected to appear within {} seconds, but failed to do so", by.toString(), timeoutSeconds, ex);
            throw new CartException(CartExceptionType.PROCESSING_FAILED, "Element [{}] expected to appear within {} seconds, but failed to do so", by.toString(), timeoutSeconds);
        }
    }


    /**
     * Wait for element to appear web element.
     * This function takes WebElement Locator (including Opcode) and Max Timeout in Seconds as Arguments and returns WebElement Reference
     *
     * @param opOnWebElement the op on web element
     * @param timeoutSeconds the timeout seconds
     * @return the web element {@link WebElement}
     */
    @SuppressWarnings( "unchecked" )
    public WebElement waitForElementToAppear(final String opOnWebElement, final Integer timeoutSeconds) {
        final By byReference = getByReference(opOnWebElement);
        return waitForElementToAppear(byReference, timeoutSeconds);
    }

    /**
     * Wait for element disappear.
     *
     * @param opOnWebElement   the opOnWebElement
     * @param timeOutInSeconds the time out in seconds
     */
    public void waitForElementDisappear(final String opOnWebElement, final Integer timeOutInSeconds) {
        try {
            LOGGER.debug("Waiting max {} seconds for the opOnWebElement [{}] to disappear", timeOutInSeconds, opOnWebElement);
            this.getWebDriverWait(timeOutInSeconds).ignoring(StaleElementReferenceException.class)
                    .ignoring(WebDriverException.class)
                    .until(ExpectedConditions.invisibilityOfElementLocated(this.getByReference(opOnWebElement)));
        } catch (TimeoutException e) {
            LOGGER.error("Element [{}] expected to disappear within {} seconds, but failed to do so", opOnWebElement, timeOutInSeconds);
            throw new CartException(CartExceptionType.PROCESSING_FAILED, "Element [{}] expected to disappear within {} seconds, but failed to do so", opOnWebElement, timeOutInSeconds);
        } catch (NoSuchElementException e) {
            //ignore exception
        }
    }

    public void multiSelectComboItems(List<String> xpaths) {
        int derivedTimeoutSeconds = 10;
        Wait wait = new FluentWait(getDriver())
                .withTimeout(Duration.ofSeconds(derivedTimeoutSeconds))
                .pollingEvery(Duration.ofSeconds(1))
                .ignoring(NoSuchElementException.class);

        if (xpaths != null && !xpaths.isEmpty()) {
            List<WebElement> webElements = xpaths.stream().map((String s) -> (WebElement) wait.until(driver -> ((WebDriver) driver).findElement(By.xpath(s)))).collect(Collectors.toList());
            int weCount = webElements.size();
            Actions actions = new Actions(getDriver());
            for (int i = 0; i < weCount; i++) {
                actions = actions.click(webElements.get(i));
                if (i == 0) {
                    actions = actions.keyDown(Keys.LEFT_CONTROL);
                }
            }
            actions.keyUp(Keys.LEFT_CONTROL).build().perform();
        }
    }

    public WebIdentifiersMetadata getWebElementIdentifiers(String opOnWebElement) {
        WebGenericOp op = WebGenericOp.parseString(opOnWebElement);
        WebIdentifiersMetadata identifiers = new WebIdentifiersMetadata();

        String opCode = op.getOpCode();

        if (OPCODE_XPATH.equals(opCode)) {
            identifiers.setOpCode(OPCODE_XPATH);
            identifiers.setParam1(op.getParam1());
        } else if (OPCODE_ID.equals(opCode)) {
            identifiers.setOpCode(OPCODE_ID);
            identifiers.setParam1(op.getParam1());
        } else if (OPCODE_XPATH_XY_PCT.equals(opCode)) {
            String param2 = op.getParam2();
            if (param2 == null) {
                throw new CartException(CartExceptionType.INCOMPLETE_PARAMS, XPATH_XY_PCT_FORMAT_GUIDE);
            }
            String[] pctSplit = op.getParam1().split(",");
            int pctX = Integer.parseInt(pctSplit[0]);
            int pctY = Integer.parseInt(pctSplit[1]);
            identifiers.setOpCode(OPCODE_XPATH_XY_PCT);
            identifiers.setParam2(param2);
            identifiers.setXcordinate(pctX);
            identifiers.setYcordinate(pctY);
        } else if (OPCODE_CLASSNAME.equals(opCode)) {
            identifiers.setOpCode(OPCODE_CLASSNAME);
            identifiers.setParam1(op.getParam1());
        } else if (OPCODE_NAME.equals(opCode)) {
            identifiers.setOpCode(OPCODE_NAME);
            identifiers.setParam1(op.getParam1());
        } else if (OPCODE_CSSSELECTOR.equals(opCode)) {
            identifiers.setOpCode(OPCODE_CSSSELECTOR);
            identifiers.setParam1(op.getParam1());
        } else if (OPCODE_LINKTEXT.equals(opCode)) {
            identifiers.setOpCode(OPCODE_LINKTEXT);
            identifiers.setParam1(op.getParam1());
        }
        return identifiers;
    }

    public String getBrowserTitle() {
        final String title = getDriver().getTitle();
        LOGGER.debug("Current Browser Title Captured as [{}]", title);
        return title;
    }

    public String getBrowserUrl() {
        final String url = getDriver().getCurrentUrl();
        LOGGER.debug("Current Browser url Captured as [{}]", url);
        return url;
    }


    public By getByReference(final String opOnWebElement) {
        final WebIdentifiersMetadata identifiers = this.getWebElementIdentifiers(opOnWebElement);
        final String opCode = identifiers.getOpCode();
        final String param1 = identifiers.getParam1();
        return getByReference(opCode, param1);
    }

    public Actions getActionsBinding() {
        return new Actions(getDriver());
    }


    public Alert switchToAlert() {
        return getDriver().switchTo().alert();
    }

    public WebDriverWait getWebDriverWait(final Integer timeOutInSeconds) {
        return new WebDriverWait(getDriver(), timeOutInSeconds);
    }


    public By getByReference(final String opCode, final String locator) {
        if (Strings.isNullOrEmpty(opCode)) {
            LOGGER.error("OpCode Cannot be Null or Empty", opCode);
            throw new CartException(CartExceptionType.INCOMPLETE_PARAMS, "OpCode Cannot be Null or Empty [{}]", opCode);
        }
        switch (opCode) {
            case OPCODE_XPATH:
                return By.xpath(locator);
            case OPCODE_ID:
                return By.id(locator);
            case OPCODE_NAME:
                return By.name(locator);
            case OPCODE_CLASSNAME:
                return By.className(locator);
            case OPCODE_TAGNAME:
                return By.tagName(locator);
            case OPCODE_LINKTEXT:
                return By.linkText(locator);
            case OPCODE_CSSSELECTOR:
                return By.cssSelector(locator);
            default:
                LOGGER.error("Invalid OP Code [{}]", opCode);
                throw new CartException(CartExceptionType.INCOMPLETE_PARAMS, "Invalid OP Code [{}]", opCode);
        }
    }


    /**
     * This function returns WebElement reference, if not found returns Null.
     * We have functions to return WebElement or throw exception if element not found,
     * but in some cases, we need to verify element is available or not without thrwowing
     * exception.
     *
     * @param opOnWebElement elementIdentifier ex: xpath://div[text()='blah']
     * @return {@link WebElement}
     */
    public WebElement getWebElementRef(final String opOnWebElement) {
        By by = getByReference(opOnWebElement);
        return getWebElementRef(by);
    }

    public WebElement getWebElementRef(final By by) {
        try {
            return getDriver().findElement(by);
        } catch (Exception e) {
            LOGGER.debug("Element Not Found, Returning Null...");
            return null;
        }
    }

    public void click(final String opOnWebElement) {
        WebElement element = getWebElementRef(opOnWebElement);
        if (element != null) {
            element.click();
        } else {
            LOGGER.error("Element [{}] Not found!!", opOnWebElement);
            throw new CartException(CartExceptionType.INCOMPLETE_PARAMS, "Element [{}] Not found!!", opOnWebElement);
        }
    }

    public WebDriver.Navigation getWebDriverNavigation() {
        return getDriver().navigate();
    }

    public WebDriver.Options getWebDriverManage() {
        return getDriver().manage();
    }

    public String getWebElementAttribute(final String locator, final String attribute) {
        WebElement webElement = getWebElementRef(locator);
        if (webElement != null) {
            final String value = webElement.getAttribute(attribute).trim();
            LOGGER.debug("Locator [{}], Attribute [{}] => [{}]", locator, attribute, value);
            return value;
        } else {
            LOGGER.error("Unable to find WebElement [{}]", locator);
            throw new CartException(CartExceptionType.IO_ERROR, "Unable to find WebElement [{}]", locator);
        }
    }

    public String getWebElementAttribute(final WebElement element, final String attribute) {
        try {
            final String value = element.getAttribute(attribute).trim();
            LOGGER.debug("Element's Attribute [{}] => [{}]", attribute, value);
            return value;
        } catch (Exception e) {
            LOGGER.error("Exception while reading attribute {}", attribute, e);
            throw new CartException(CartExceptionType.PROCESSING_FAILED, "Exception while reading attribute {}", attribute, e);
        }
    }

    //The method waits until the value in the specified attribute is updated to an expected value
    public void waitForAttributeValueEqualsExpectedValue(String locator, String attribute, String value, int timeout) {
        WebElement webElement = this.getWebElementRef(locator);
        if (webElement == null) {
            this.waitForElementToAppear(locator, 30);
        }
        this.waitForAttributeValueEqualsExpectedValue(webElement, attribute, value, timeout);
    }

    public void waitForAttributeValueEqualsExpectedValue(WebElement webElement, String attribute, String value, int timeout) {
        if (!webElement.isDisplayed()) {
            try {
                this.getWebDriverWait(30).until(ExpectedConditions.visibilityOf(webElement));
            } catch (Exception e) {
                LOGGER.error("Element {} expected to appear within {} seconds, but failed to do so", webElement, 30, e);
                throw new CartException(CartExceptionType.PROCESSING_FAILED, "Element {} expected to appear within {} seconds, but failed to do so", webElement, 30);
            }
        }
        try {
            this.getWebDriverWait(timeout).until(ExpectedConditions.attributeToBe(webElement, attribute, value));
        } catch (Exception e) {
            LOGGER.error("Attribute {} expected to have value {} within {} seconds, but failed to do so", attribute, value, timeout, e);
            throw new CartException(CartExceptionType.PROCESSING_FAILED, "Attribute {} expected to have value {} within {} seconds, but failed to do so", attribute, value, timeout);
        }

    }


    /**
     * Gets web driver switch to object.
     *
     * @return the switchTo object
     */
    public WebDriver.TargetLocator getWebDriverSwitchTo() {
        return getDriver().switchTo();
    }

    /**
     * Switch to frame by index.
     *
     * @param index the index
     */
    public void switchToFrameByIndex(int index) {
        LOGGER.debug("Switching to index [{}] frame", index);
        getWebDriverSwitchTo().frame(index);
    }

    /**
     * Switch to default frame.
     */
    public void switchToDefaultFrame() {
        LOGGER.debug("Switching to default frame");
        getWebDriverSwitchTo().defaultContent();
    }


    public void waitForFrameAndSwitch(final String opOnWebElement, final int timeoutInSec) {
        final By by = getByReference(opOnWebElement);
        waitForFrameAndSwitch(by, timeoutInSec);
    }

    public void waitForFrameAndSwitch(final By by, final int timeoutInSec) {
        getWebDriverWait(timeoutInSec)
                .ignoring(NoSuchElementException.class)
                .pollingEvery(Duration.ofSeconds(2))
                .withMessage("Unable to identify frame with locator " + by.toString())
                .until(ExpectedConditions.frameToBeAvailableAndSwitchToIt(by));
        threadSvc.sleepMillis(500);
    }

    public Alert waitForAlertAndSwitch(final int timeoutInSec) {
        return getWebDriverWait(timeoutInSec)
                .pollingEvery(Duration.ofSeconds(1))
                .until(ExpectedConditions.alertIsPresent());
    }

    /**
     * Generic method to submit on WebElement with wait time.
     *
     * @param opOnWebElement       the locator of the web element in the form id:<locator> or xpath:<xpath locator>
     * @param waitTimeOutInSeconds the wait time out in seconds
     */
    public void submit(final String opOnWebElement, final int waitTimeOutInSeconds) {
        final WebElement element = waitForElementToAppear(opOnWebElement, waitTimeOutInSeconds);
        submit(element);
    }

    public void submit(final WebElement element) {
        if (element != null) {
            element.submit();
        } else {
            LOGGER.error("Unable to do Submit on []", element);
            throw new CartException(CartExceptionType.PROCESSING_FAILED, "Unable to do Submit on []", element);
        }
    }

    //TODO - usage of this method can be replaced with submit(opOnWebElement,waitTimeOutInSeconds) method
    public void submitId(final String locator) {
        this.submit("id:" + locator, 0);
    }

    //TODO - usage of this method can be replaced with submit(opOnWebElement,waitTimeOutInSeconds) method
    public void submitXpath(final String locator) {
        this.submit("xpath:" + locator, 0);
    }


    public JavascriptExecutor getJavaScriptExecutor() {
        return (JavascriptExecutor) getDriver();
    }


    /**
     * Click by java script.
     *
     * @param element the element
     */
    public void clickByJavaScript(final WebElement element) {
        LOGGER.debug("Invoking click with Javascript");
        getJavaScriptExecutor().executeScript("arguments[0].click();", element);
    }


    public void clickHiddenElementByJavaScript(final String opOnWebElement, int timeOutInSec) {
        final By by = getByReference(opOnWebElement);
        WebElement element = ElementWaitSvc.findElement(getDriver(), by, timeOutInSec);
        clickByJavaScript(element);
    }


    /**
     * Click by java script.
     *
     * @param opOnWebElement       the op on web element
     * @param waitTimeOutInSeconds the wait time out in seconds
     */
    public void clickByJavaScript(final String opOnWebElement, final int waitTimeOutInSeconds) {
        By by = getByReference(opOnWebElement);
        WebElement element = ElementWaitSvc.waitTillClickable(getDriver(), by, waitTimeOutInSeconds);
        clickByJavaScript(element);
    }

    //TODO - usage of this method can be replaced with clickByJavaScript(opOnWebElement,waitTimeOutInSeconds) method
    public void clickXPathUsingJavascript(String locator) {
        clickByJavaScript("xpath:" + locator, 0);
    }

    /**
     * Wait till page loads.
     */
    public void waitTillPageLoads() {
        LOGGER.debug("waiting till page loads...");
        WebDriverWait webDriverWait = this.getWebDriverWait(60);
        final boolean complete = webDriverWait.until((Function<? super WebDriver, JavascriptExecutor>)
                webDriver -> (JavascriptExecutor) getDriver())
                .executeScript("return document.readyState")
                .equals("complete");
    }

    public boolean waitForJStoLoad() {
        final WebDriverWait wait = getWebDriverWait(30);
        final Boolean jqueryLoaded = wait.until(evaluateJsCondition("jQuery.active==0", true));
        final Boolean pageLoaded = wait.until(evaluateJsCondition("document.readyState=='complete'", true));
        return jqueryLoaded && pageLoaded;
    }


    /**
     * Scroll element into view.
     *
     * @param opOnWebElement the op on web element
     */
    public void scrollElementIntoView(final String opOnWebElement) {
        final WebElement element = this.getWebElementRef(opOnWebElement);
        getJavaScriptExecutor().executeScript("arguments[0].scrollIntoView(true);", element);
    }


    /**
     * Scroll element into view.
     *
     * @param element the element
     */
    public void scrollElementIntoView(final WebElement element) {
        getJavaScriptExecutor().executeScript("arguments[0].scrollIntoView(true);", element);
    }

    /**
     * Fire mouse event using java script.
     *
     * @param element   the element
     * @param eventName the event name
     */
    public void fireMouseEventUsingJavaScript(final WebElement element, final String eventName) {
        String jsCode = formatter.format("var evObj = new MouseEvent('%s', " +
                "{bubbles: true, cancelable: true, view: window});", eventName);
        jsCode += " arguments[0].dispatchEvent(evObj);";
        getJavaScriptExecutor().executeScript(jsCode, element);
    }

    /**
     * Fire mouse event using java script.
     *
     * @param opOnWebElement the op on web element
     * @param timeOutInSec   the time out in sec
     * @param eventName      the event name
     */
    public void fireMouseEventUsingJavaScript(final String opOnWebElement, final Integer timeOutInSec, final String eventName) {
        WebElement element = ElementWaitSvc.waitTillVisible(getDriver(), getByReference(opOnWebElement), timeOutInSec);
        String jsCode = formatter.format("var evObj = new MouseEvent('%s', " +
                "{bubbles: true, cancelable: true, view: window});", eventName);
        jsCode += " arguments[0].dispatchEvent(evObj);";
        getJavaScriptExecutor().executeScript(jsCode, element);
    }

    public void selectElementBy(final String opOnWebElement, final int waitTimeoutInSec, final SELECT_ACTION action, final Object input) {
        WebElement selectElement = ElementWaitSvc.findElement(getDriver(), getByReference(opOnWebElement), waitTimeoutInSec);
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


    /**
     * Gets list with attribute values.
     * Can be reused to iterate through stream of WebElements and read attribute values of all elements.
     *
     * @param stream    the stream
     * @param attribute the attribute
     * @return the list with attribute values
     */
    public List<String> getListWithAttributeValues(Stream<WebElement> stream, final String attribute) {
        return stream.map(s -> getWebElementAttribute(s, attribute).trim())
                .collect(Collectors.toList());
    }


}

