package com.eastspring.tom.cart.dmp.utl;

import com.eastspring.tom.cart.constant.ValidationError;
import com.eastspring.tom.cart.core.CartException;
import com.eastspring.tom.cart.core.CartExceptionType;
import com.eastspring.tom.cart.core.svc.StateSvc;
import com.eastspring.tom.cart.core.svc.ThreadSvc;
import com.eastspring.tom.cart.core.svc.WebTaskSvc;
import com.eastspring.tom.cart.core.utl.FormatterUtil;
import com.eastspring.tom.cart.dmp.pages.HomePage;
import com.eastspring.tom.cart.dmp.steps.DmpGsPortalSteps;
import org.h2.util.StringUtils;
import org.openqa.selenium.*;
import org.openqa.selenium.support.ui.ExpectedConditions;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;

import javax.script.ScriptEngine;
import javax.script.ScriptEngineManager;
import javax.script.ScriptException;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.List;

import static com.eastspring.tom.cart.constant.CommonLocators.*;

/**
 * Created by GummarajuM on 23/1/2018.
 */
public class DmpGsPortalUtl {
    private static final Logger LOGGER = LoggerFactory.getLogger(DmpGsPortalUtl.class);

    private static final String ACTUAL_DOES_NOT_MATCH_WITH_EXPECTED = "Actual Does not match with expected, Actual:[{}] and Expected:[{}]";
    private static final String INNER_TEXT = "innerText";
    public static final String ENTER = "ENTER";

    public static final Integer MAX_RETRIES = 3;

    @Autowired
    private WebTaskSvc webTaskSvc;

    @Autowired
    private FormatterUtil formatterUtil;

    @Autowired
    private StateSvc stateSvc;

    @Autowired
    private ThreadSvc threadSvc;

    @Autowired
    private DmpGsPortalSteps dmpGsPortalSteps;

    @Autowired
    private HomePage homePage;


    public int getTableColumnNumber(final String xpathOfTable, final String columnName) {
        return getTableColumnNumber(xpathOfTable, columnName, 60);
    }

    public int getTableColumnNumber(final String xpathOfTable, final String columnName, final Integer timeoutSeconds) {
        try {
            final WebElement headerTable = webTaskSvc.getWebDriverWait(timeoutSeconds)
                    .ignoring(StaleElementReferenceException.class)
                    .until(ExpectedConditions.visibilityOfElementLocated(By.xpath(xpathOfTable)));

            final List<WebElement> listOfColumns = headerTable.findElements(By.tagName("td"));
            for (int i = 0; i <= listOfColumns.size() - 1; i++) {
                if (listOfColumns.get(i).getAttribute(INNER_TEXT).trim().equals(columnName)) {
                    LOGGER.debug("Column Name [{}] Number is [{}]", listOfColumns.get(i).getAttribute(INNER_TEXT), i);
                    return i;
                }
            }
        } catch (CartException | TimeoutException | StaleElementReferenceException e) {
            //swallow
        }
        LOGGER.debug("Column Name [{}] not found in Table with Xpath [{}]", columnName, xpathOfTable);
        return -1;
    }

    public int getRowNumWithText(String xpathOfTableBody, Integer columnNumber, String expectedText) {
        int rowCount = this.getTableRowCount(xpathOfTableBody);
        String xpathOfCellText = "";

        for (int i = 1; i <= rowCount; i++) {
            xpathOfCellText = xpathOfTableBody + "//tr[" + i + "]" + "//td[" + columnNumber + "]/div";
            WebElement webElement = webTaskSvc.findElementsByXPath(xpathOfCellText).get(0);
            String actualText = webElement.getAttribute(INNER_TEXT);
            if (this.areEquals(expectedText, actualText)) {
                return i;
            }
        }
        return -1;
    }

    public int getTableRowCount(final String xpathTable) {
        int rowCount = 0;
        try {
            List<WebElement> rowsCollection = null;
            int retry = 0;
            while (rowsCollection == null && retry < MAX_RETRIES) {
                WebElement tableElement = webTaskSvc.waitForElementToAppear(By.xpath(xpathTable), 10);
                try {
                    rowsCollection = tableElement.findElements(By.tagName("tr"));
                    rowCount = rowsCollection.size();
                    threadSvc.sleepSeconds(1);
                    webTaskSvc.getJavaScriptExecutor().executeScript("arguments[0].click();", tableElement);
                } catch (StaleElementReferenceException e) {
                    LOGGER.debug("Ignoring StaleElement Reference Exception...");
                    //swallow
                }
                retry++;
            }
        } catch (CartException e) {
            LOGGER.error("Rows with xpath [{}] not found", xpathTable);
            throw new CartException(CartExceptionType.PROCESSING_FAILED, "Rows with xpath [{}] not found", xpathTable);
        }
        return rowCount;
    }


    /**
     * Wait till table row count is equal to expected count and returns the actual row count after 3 attempts.
     *
     * @param xpathTable       the xpath table
     * @param expectedRowCount the expected row count
     * @return actual row count after 3 attempts
     */
    public Integer waitTillTableRowCount(final String xpathTable, final Integer expectedRowCount) {
        int actualRowCount = this.getTableRowCount(xpathTable);
        int retry = 0;
        while (actualRowCount != expectedRowCount && retry < MAX_RETRIES) {
            LOGGER.debug("Retrying to get Table row count [{}]", expectedRowCount);
            this.refreshPage();
            actualRowCount = this.getTableRowCount(xpathTable);
            retry++;
        }
        return actualRowCount;
    }

    public String getCellText(String xpathTable, int rowNum, int columnNum) {
        try {
            String cellXPath = xpathTable + "//tr[" + rowNum + "]//td[" + columnNum + "]";
            List<WebElement> webElementList = webTaskSvc.findElementsByXPath(cellXPath);
            if (webElementList.isEmpty()) {
                LOGGER.error("Web Element with xpath [{}] not found", cellXPath);
                throw new CartException(CartExceptionType.PROCESSING_FAILED, "Web Element with xpath [{}] not found", cellXPath);
            }
            return webElementList.get(0).getAttribute(INNER_TEXT);
        } catch (CartException e) {
            LOGGER.error("getCellText(): processing failed", e);
            throw new CartException(CartExceptionType.PROCESSING_FAILED, "getCellText(): processing failed");
        }
    }

    public void assertEquals(Object expected, Object actual) {
        if (!this.areEquals(expected, actual)) {
            LOGGER.error(ACTUAL_DOES_NOT_MATCH_WITH_EXPECTED, actual, expected);
            throw new CartException(CartExceptionType.VERIFICATION_FAILED, ACTUAL_DOES_NOT_MATCH_WITH_EXPECTED, actual, expected);
        } else {
            LOGGER.info("Actual [{}] match with Expected [{}]", actual, expected);
        }
    }

    public boolean areEquals(Object expected, Object actual) {
        if (expected == null && actual == null) {
            return true;
        } else if (isNumeric(String.valueOf(expected)) && isNumeric(String.valueOf(actual))) {
            Double expectedDbl = Double.parseDouble(String.valueOf(expected));
            Double actualDbl = Double.parseDouble(String.valueOf(actual));
            if (Math.abs(expectedDbl - actualDbl) == 0) {
                return true;
            }
        } else if (expected instanceof String && actual instanceof String && expected.equals(actual)) {
            return true;
        }
        return false;
    }

    private static boolean isNumeric(String string) {
        return string.matches("^[-+]?\\d+(\\.\\d+)?$");
    }

    //Made this function as generic to enter both Text Fields and Dropdown fields
    public boolean filterTable(final String columnName, final String value, final boolean isColumnDropdownField) {
        webTaskSvc.setImplicitWait(2);

        final int columnNum = webTaskSvc.findElementsByXPath(GS_HEADER_TABLE_XPATH).size() == 0
                ? -1
                : this.getTableColumnNumber(GS_HEADER_TABLE_XPATH, columnName, 1) + 1;

        webTaskSvc.setDefaultImplicitWait();

        if (columnNum > 0) {
            String columnXpath = isColumnDropdownField
                    ? formatterUtil.format(GS_LOOKUP_SEARCH_DROPDOWN_TEXTFIELD, columnNum)
                    : formatterUtil.format(GS_LOOKUP_SEARCH_TEXT_FIELD, columnNum);

            webTaskSvc.scrollElementIntoView(columnXpath);
            WebElement element = webTaskSvc.getWebElementRef(columnXpath);

            if (element != null && element.isDisplayed()) {
                try {
                    webTaskSvc.enterTextIntoWebElement(element, stateSvc.expandVar(value), ENTER);
                    if (isColumnDropdownField) {
                        element.sendKeys(Keys.ESCAPE);
                    } else {
                        element.sendKeys(Keys.ENTER);
                    }
                } catch (StaleElementReferenceException e) {
                    return false;
                }
                return true;
            }
        }
        return false;
    }

    public void waitTillFilterIsSuccess(final String columnName, final String expectedText) {
        webTaskSvc.setImplicitWait(3);
        boolean isRecordLoaded = webTaskSvc.findElementsByXPath(GS_RELOAD_BUTTON.replace("xpath:", "")).size() > 0;
        boolean isTableExists = webTaskSvc.findElementsByXPath(GS_DATA_TABLE_XPATH).size() > 0;

        if (!isRecordLoaded && isTableExists) {
            LOGGER.debug("Waiting till Table is filtered successfully...");
            final int columnNum = this.getTableColumnNumber(GS_HEADER_TABLE_XPATH, columnName, 5) + 1;

            if (columnNum > 0) {
                final String cellXPath = GS_DATA_TABLE_XPATH + "//tr[1]//td[" + columnNum + "]";
                try {
                    webTaskSvc.getWebDriverWait(60)
                            .ignoring(StaleElementReferenceException.class)
                            .ignoring(WebDriverException.class)
                            .ignoring(ElementNotVisibleException.class)
                            .ignoring(NoSuchElementException.class)
                            .until(ExpectedConditions.attributeToBe(webTaskSvc.getByReference("xpath", cellXPath), INNER_TEXT, expectedText));
                } catch (Exception e) {
                    LOGGER.error("Exception captured while waiting for filtered records", e);
                    //ignore
                }
            }
        }
        webTaskSvc.setDefaultImplicitWait();
    }


    public void saveModification(String comment) {
        By commentLocator = webTaskSvc.getByReference(GS_MODIFICATION_COMMENT_TEXTFIELD);
        webTaskSvc.getWebDriverWait(180)
                .ignoring(StaleElementReferenceException.class)
                .ignoring(NoSuchElementException.class)
                .until(ExpectedConditions.elementToBeClickable(commentLocator));
        this.inputText(GS_MODIFICATION_COMMENT_TEXTFIELD, comment, ENTER, true);
        webTaskSvc.click(GS_POPUP_CONTENT_SAVE_BUTTON);
        By by = webTaskSvc.getByReference(GS_POPUP_CONTENT_SAVE_BUTTON);
        webTaskSvc.getWebDriverWait(180)
                .until(ExpectedConditions.invisibilityOfElementLocated(by));
    }


    //New Function
    public boolean isSearchRecordAvailable(String recordName) {
        final String expandRecordName = stateSvc.expandVar(recordName);
        WebElement saveElement = null;
        try {
            webTaskSvc.setImplicitWait(2);
            saveElement = webTaskSvc.waitForElementToAppear(GS_SAVE_BUTTON, 10);
        } catch (CartException ignore) {
            /*swallow*/
        }
        webTaskSvc.setDefaultImplicitWait();
        if (saveElement != null) {
            LOGGER.info("Record with Name [{}] is Already available...", expandRecordName);
            return true;
        }
        LOGGER.info("Record with Name [{}] is NOT available...", expandRecordName);
        return false;
    }


    //New Function
    public void inputText(final String locator, final String textToEnter, final String followingKey, final boolean isMandatoryField) {
        final String expandText = stateSvc.expandVar(textToEnter);
        if (!StringUtils.isNullOrEmpty(expandText)) {

            final String effectiveText = expandText.equalsIgnoreCase("null") ? "" : expandText;

            WebElement element = webTaskSvc.getWebDriverWait(180)
                    .ignoring(StaleElementReferenceException.class)
                    .until(ExpectedConditions.elementToBeClickable(webTaskSvc.getByReference(locator)));

            webTaskSvc.enterTextIntoWebElement(element, effectiveText, followingKey);
            LOGGER.debug("Entered [{}] into element [{}]", effectiveText, locator);
        } else {
            if (isMandatoryField) {
                LOGGER.error("[{}] is a Mandatory field, must input the value", locator);
                throw new CartException(CartExceptionType.INCOMPLETE_PARAMS, "[{}] is a Mandatory field, must input the value", locator);
            }
        }
    }

    //New Function
    public void invokeSetUpScreen(final String entity, final String template, final String draft) {
        //setup
        webTaskSvc.click(GS_SETUP_BUTTON);
        //If setup screen is enabled enter Entity, Template, Draft
        if (webTaskSvc.getWebElementRef(GS_SETUP_CREATE_NEW_BUTTON) != null) {
            if (!StringUtils.isNullOrEmpty(entity)) {
                this.inputText(GS_SETUP_ENTITY_TEXT_FIELD, entity, ENTER, false);
            }
            if (!StringUtils.isNullOrEmpty(template)) {
                this.inputText(GS_SETUP_TEMPLATE_TEXT_FIELD, template, ENTER, false);
            }
            if (!StringUtils.isNullOrEmpty(draft)) {
                this.inputText(GS_SETUP_DRAFT_TEXT_FIELD, draft, ENTER, false);
            }
            webTaskSvc.click(GS_SETUP_CREATE_NEW_BUTTON);
        }
        webTaskSvc.waitForElementToAppear(GS_SAVE_BUTTON, 180);
    }

    //New Function
    public String getActiveScreenName() {
        //setting implicit wait time to minimum to read the Active Screen name
        webTaskSvc.setImplicitWait(2);
        WebElement element = webTaskSvc.getWebElementRef(GS_ACTIVE_TAB);
        if (element != null) {
            String idAttribute = element.getAttribute("id");
            List<String> list = Arrays.asList(idAttribute.split(":"));
            String screenName = list.get(list.size() - 1);
            LOGGER.debug("Active Screen Name is [{}]", screenName);
            return screenName;
        }
        LOGGER.debug("No Menu is Opened Yet!!!");
        //resetting implicit wait time to Default
        webTaskSvc.setDefaultImplicitWait();
        return "";
    }


    public void waitTillNotificationMessageAppears() {
        By by = webTaskSvc.getByReference(GS_NOTIFICATION_CAPTION);
        try {
            webTaskSvc.waitForElementToAppear(by, 180);
        } catch (Exception e) {
            //Above function waits for 120 sec and throws error message if element not visible
            //We don't want to throw error message and break the execution here
            //So intentionally swallowing the exception
        }
    }


    //New Function
    public void addNewDetails() {
        try {
            By byReference = webTaskSvc.getByReference(GS_ADD_DETAILS_BUTTON);
            WebElement element = webTaskSvc.getWebDriverWait(10).until(ExpectedConditions.elementToBeClickable(byReference));
            element.click();
        } catch (Exception e) {
            String activeScreenName = getActiveScreenName();
            LOGGER.error("Unable to Add Details Button in Screen [{}]", e, activeScreenName);
            throw new CartException(CartExceptionType.PROCESSING_FAILED, "Unable to Add Details Button in Screen [{}]", activeScreenName);
        }
    }

    //New Function
    public void invokeDetailsView() {
        try {
            webTaskSvc.click(GS_DETAILS_VIEW);
        } catch (Exception e) {
            String activeScreenName = getActiveScreenName();
            LOGGER.error("Unable to Invoke View Details screen in Screen [{}]", e, activeScreenName);
            throw new CartException(CartExceptionType.PROCESSING_FAILED, "Unable to Invoke View Details screen in Screen [{}]", activeScreenName);
        }
    }


    //POPUP CONTENT
    public void filterPopupContentTable(final String columnName, final String value, final boolean isColumnDropdownField) {
        final String expandText = stateSvc.expandVar(value);
        final String columnTextName = stateSvc.expandVar(columnName);
        final int columnNum = getTableColumnNumber(GS_POPUP_HEADER_TABLE_XPATH, columnTextName) + 1;
        final String columnXpath = formatterUtil.format(GS_POPUP_LOOKUP_SEARCH_FIELD, columnNum);

        /*Have not faced scenarios with dropdown field in popup content table
        Hence, adding arg to the function, but handling for isColumnDropdownField is pending*/
        final WebElement element = webTaskSvc.waitForElementToAppear(columnXpath, 10);
        webTaskSvc.enterTextIntoWebElement(element, expandText, ENTER);
        if (isColumnDropdownField) {
            element.sendKeys(Keys.ESCAPE);
        }
    }

    private WebElement getCellReference(final String cellLocator, final String cellText) {
        final String effectiveLocator = formatterUtil.format(cellLocator, cellText);
        final By by = webTaskSvc.getByReference(effectiveLocator);
        return webTaskSvc.waitForElementToAppear(by, 30);
    }

    public void selectRecord(final String locator, final String recordIdentifier) {
        threadSvc.sleepSeconds(1);
        WebElement element = this.getCellReference(locator, recordIdentifier);
        webTaskSvc.getActionsBinding().click(element).build().perform();
    }

    public void openRecord(final String locator, final String recordIdentifier) {
        final String expandIdentifier = stateSvc.expandVar(recordIdentifier);
        try {
            webTaskSvc.waitTillPageLoads();
            WebElement element = this.getCellReference(locator, expandIdentifier);
            webTaskSvc.fireMouseEventUsingJavaScript(element, "dblclick");
        } catch (StaleElementReferenceException e) {
            LOGGER.error("StaleElement Reference Exception in Open Record...");
            //swallow exception
        } catch (CartException e) {
            LOGGER.error("Error occurred while opening record with identifier [{}]", e, expandIdentifier);
            throw new CartException(CartExceptionType.PROCESSING_FAILED, "Error occurred while opening record with identifier [{}]", expandIdentifier);
        }
    }

    public void closePopupWindow() {
        try {
            webTaskSvc.click(GS_POPUP_CLOSE_WINDOW);
        } catch (Exception e) {
            String activeScreenName = getActiveScreenName();
            LOGGER.error("Unable to Close Popup Window View Details screen in Screen [{}]", e, activeScreenName);
            throw new CartException(CartExceptionType.PROCESSING_FAILED, "Unable to Invoke View Details screen in Screen [{}]", activeScreenName);
        }
    }

    public List<ValidationError> readAllValidationErrors() {
        List<ValidationError> listOfErrors = new ArrayList<>();
        String gsoField;
        String severity;
        String message;

        final WebElement table = webTaskSvc.waitForElementToAppear(GS_VALIDATION_ERROR_TABLE, 10);
        final List<WebElement> rowsCollection = table.findElements(By.tagName("tr"));

        for (int row = 0; row <= rowsCollection.size() - 1; row++) {
            List<WebElement> columnCollection = rowsCollection.get(row).findElements(By.tagName("td"));
            if (columnCollection.size() >= 3) {
                gsoField = columnCollection.get(0).getText();
                severity = columnCollection.get(1).getText();
                message = columnCollection.get(2).getText();
                listOfErrors.add(new ValidationError(gsoField, severity, message));
            }
        }
        return listOfErrors;
    }

    public String getErrorPopUpContent() {
        WebElement msgWebElement = webTaskSvc.getWebElementRef(GS_ERROR_POPUP_CONTENT);
        if (msgWebElement == null) {
            LOGGER.error("There is no error popup");
            throw new CartException(CartExceptionType.VALIDATION_FAILED, "There is no error popup");
        }
        final String actualErrMsg = msgWebElement.getText();
        return actualErrMsg;
    }

    public List<String> getDropDownFieldValues() {
        List<String> result = new ArrayList<>();
        By by = webTaskSvc.getByReference(GS_POPUP_COMBO_BOX_LIST_VALUES);
        WebElement tBody = webTaskSvc.waitForElementToAppear(by, 10);

        WebElement statusElement = webTaskSvc.getWebElementRef("xpath:" + GS_POPUP_CONTENT + "/div[@class='v-filterselect-status']");
        try {
            ScriptEngine scriptEngine = new ScriptEngineManager().getEngineByName("JavaScript");
            boolean status = false;

            while (!status) {
                List<WebElement> rows = tBody.findElements(By.tagName("tr"));
                for (WebElement row : rows) {
                    result.add(row.getText());
                }
                String filterStatus = statusElement.getAttribute("innerText");
                status = scriptEngine.eval(filterStatus.split("-")[1]).equals(1);

                webTaskSvc.setImplicitWait(2);
                WebElement nextPage = webTaskSvc.getWebElementRef("className:v-filterselect-nextpage");
                if (nextPage != null) {
                    nextPage.click();
                    threadSvc.sleepMillis(400);
                }
            }

        } catch (ScriptException e) {
            LOGGER.error("");
            throw new CartException(CartExceptionType.UNDEFINED, "");
        }
        webTaskSvc.setDefaultImplicitWait();
        threadSvc.sleepSeconds(1);
        return result;
    }

    public void selectGSTab(final String tabName) {
        try {
            final String xpathDerived = formatterUtil.format(GS_TAB, tabName);
            By by = webTaskSvc.getByReference(xpathDerived);
            WebElement tabElement = webTaskSvc.getWebDriverWait(60)
                    .ignoring(WebDriverException.class)
                    .until(ExpectedConditions.elementToBeClickable(by));
            try {
                tabElement.click();
            } catch (WebDriverException e) {
                //ignore
            }
            threadSvc.sleepMillis(500);
            webTaskSvc.waitTillPageLoads();
        } catch (Exception e) {
            LOGGER.error("Exception occurred while selecting tab [{}]", tabName, e);
            throw new CartException(CartExceptionType.PROCESSING_FAILED, "Exception occurred while selecting tab [{}]", tabName);
        }
    }

    public void refreshPage() {
        LOGGER.debug("Refreshing page...");
        try {
            webTaskSvc.getWebDriverNavigation().refresh();
            webTaskSvc.waitTillPageLoads();
            threadSvc.sleepMillis(1000);
        } catch (Exception e) {
            LOGGER.error("Caught exception while refreshing page", e);
            //ignore exception
        }
    }


    //Lookup handling
    //By default it enters the value into 1st column
    public void selectLookupInFirstColumn(final String valToSelect) {
        this.selectLookupValue(1, valToSelect);
    }

    //It search the column and enters the value
    public void selectLookupInGivenColumn(final String columnName, final String valToSelect) {
        int tableColumnNumber = this.getTableColumnNumber(GS_POPUP_HEADER_TABLE_XPATH, columnName);
        this.selectLookupValue(tableColumnNumber + 1, valToSelect);
    }

    private void selectLookupValue(final Integer columnNum, final String valToSelect) {
        String xpathSearch = formatterUtil.format(GS_LOOKUP_SEARCH_TEXT_FIELD, columnNum);
        WebElement elementSearchField = webTaskSvc.waitForElementToAppear(xpathSearch, 30);
        int retry = 0;
        webTaskSvc.setImplicitWait(1);
        while (elementSearchField != null && retry <= MAX_RETRIES) {
            try {
                webTaskSvc.enterTextIntoWebElement(elementSearchField, valToSelect, ENTER);
                elementSearchField.sendKeys(Keys.TAB);
                threadSvc.sleepSeconds(2);
                this.openRecord(GS_DATA_TABLE_ROW, valToSelect);
                threadSvc.sleepSeconds(1);
                elementSearchField = webTaskSvc.getWebDriverWait(10)
                        .ignoring(StaleElementReferenceException.class)
                        .until(ExpectedConditions.visibilityOf(webTaskSvc.getWebElementRef(xpathSearch)));
            } catch (Exception e) {
                retry++;
            }
        }
        webTaskSvc.setDefaultImplicitWait();
    }


    //uses default functionality of searching in 1st column
    public void inputTextInLookUpField(final String searchBtn, final String textToEnter, final boolean isMandatoryField) {
        final String expandText = stateSvc.expandVar(textToEnter);
        if (!StringUtils.isNullOrEmpty(expandText)) {
            webTaskSvc.click(searchBtn);
            threadSvc.sleepMillis(1000);
            this.selectLookupInFirstColumn(expandText);
            LOGGER.debug("Entered [{}] into Element [{}]", expandText, searchBtn);
        } else {
            if (isMandatoryField) {
                LOGGER.error("[{}] is a Mandatory field, must input the value", searchBtn);
                throw new CartException(CartExceptionType.INCOMPLETE_PARAMS, "[{}] is a Mandatory field, must input the value", searchBtn);
            }
        }
    }

    //search in a given column
    public void inputTextInLookUpField(final String searchBtn, final String columnName, final String textToEnter, final boolean isMandatoryField) {
        final String expandText = stateSvc.expandVar(textToEnter);
        if (!StringUtils.isNullOrEmpty(expandText)) {
            webTaskSvc.click(searchBtn);
            threadSvc.sleepMillis(1000);
            this.selectLookupInGivenColumn(columnName, expandText);
            LOGGER.debug("Entered [{}] into Element [{}]", expandText, searchBtn);
        } else {
            if (isMandatoryField) {
                LOGGER.error("[{}] is a Mandatory field, must input the value", searchBtn);
                throw new CartException(CartExceptionType.INCOMPLETE_PARAMS, "[{}] is a Mandatory field, must input the value", searchBtn);
            }
        }
    }

    public void clearLookupField(final String inputLocator) {
        LOGGER.debug("Clear Lookup field [{}]", inputLocator);
        final WebElement element = webTaskSvc.getWebElementRef(inputLocator);
        if (element != null) {
            element.clear();
            element.click();
            element.sendKeys(Keys.ARROW_DOWN);
            element.sendKeys(Keys.ARROW_DOWN);
            element.sendKeys(Keys.ENTER);
            element.sendKeys(Keys.ESCAPE);
        }
    }

    public void saveChangesWithValidData(final boolean isInModifyMode) {
        try {
            webTaskSvc.click(GS_SAVE_BUTTON);
            webTaskSvc.setImplicitWait(isInModifyMode ? 60 : 2);
            WebElement commentsWebElement = webTaskSvc.getWebElementRef(GS_MODIFICATION_COMMENT_TEXTFIELD);
            if (commentsWebElement != null) {
                this.saveModification("Updated by Automation user");
            }
        } catch (Exception e) {
            final String activeScreenName = getActiveScreenName();
            LOGGER.error("Unable to Save Changes in Screen [{}]", e, activeScreenName);
            throw new CartException(CartExceptionType.PROCESSING_FAILED, "Unable to Save Changes in Screen [{}]", activeScreenName);
        } finally {
            webTaskSvc.setDefaultImplicitWait();
        }
    }

    //All the reference with this function in the repo would be pointed to saveChangesWithValidData
    public void saveChanges() {
        try {
            webTaskSvc.click(GS_SAVE_BUTTON);
            WebElement commentsWebElement = webTaskSvc.getWebElementRef(GS_MODIFICATION_COMMENT_TEXTFIELD);
            if (commentsWebElement != null) {
                this.saveModification("Updated by Automation user");
            }
            webTaskSvc.setImplicitWait(1);
            if (webTaskSvc.getWebElementRef(GS_VALIDATION_ERROR_COUNT_MSG) == null) {
                webTaskSvc.setDefaultImplicitWait();
                this.waitTillNotificationMessageAppears();
            }
        } catch (Exception e) {
            String activeScreenName = getActiveScreenName();
            LOGGER.error("Unable to Save Changes in Screen [{}]", e, activeScreenName);
            throw new CartException(CartExceptionType.PROCESSING_FAILED, "Unable to Save Changes in Screen [{}]", activeScreenName);
        }
    }

    public void deleteRecord() {
        try {
            webTaskSvc.click(GS_OTHERS_MENU_BUTTON);
            threadSvc.sleepSeconds(1);
            webTaskSvc.click(GS_OTHERS_DELETE_BUTTON);
            By deleteElement = webTaskSvc.getByReference(GS_POPUP_DELETE_BUTTON);

            WebElement element = webTaskSvc.getWebDriverWait(120)
                    .ignoring(StaleElementReferenceException.class)
                    .ignoring(NoSuchElementException.class)
                    .until(ExpectedConditions.elementToBeClickable(deleteElement));
            threadSvc.sleepSeconds(2);
            element.click();
            threadSvc.sleepSeconds(2);

            this.waitTillSuccessNotificationMessageAppears();
        } catch (Exception e) {
            final String activeScreenName = getActiveScreenName();
            LOGGER.error("Unable to Delete record in Screen [{}]", activeScreenName, e);
            throw new CartException(CartExceptionType.PROCESSING_FAILED, "Unable to Delete record in Screen [{}]", activeScreenName);
        }
    }

    public void waitTillSuccessNotificationMessageAppears() {
        By by = webTaskSvc.getByReference(GS_NOTIFICATION_SUCCESS);
        try {
            LOGGER.debug("Waiting for Success Notification message...");
            webTaskSvc.waitForElementToAppear(by, 180);
        } catch (Exception e) {
            final String activeScreenName = getActiveScreenName();
            LOGGER.error("Unable to Save Changes in Screen [{}]", e, activeScreenName);
            throw new CartException(CartExceptionType.PROCESSING_FAILED, "Unable to Save Changes in Screen [{}]", activeScreenName);
        }
    }

    //TODO - new method written to handle "in development" objects
    public String getWebElementAttribute(final String locator, final String attribute, final boolean optional) {
        String val = "";
        try {
            val = webTaskSvc.getWebElementAttribute(locator, attribute);
        } catch (CartException e) {
            if (!optional) {
                LOGGER.error("Unable to find WebElement [{}]", locator);
                throw new CartException(CartExceptionType.EXPECTED_WEBELEMENT_DOESNT_EXIST, "Unable to find WebElement [{}]", locator);
            }
        }
        return val;
    }


}
