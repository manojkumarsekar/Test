package com.eastspring.tom.cart.dmp.steps;

import com.eastspring.tom.cart.constant.ValidationError;
import com.eastspring.tom.cart.core.CartException;
import com.eastspring.tom.cart.core.CartExceptionType;
import com.eastspring.tom.cart.core.svc.StateSvc;
import com.eastspring.tom.cart.core.svc.ThreadSvc;
import com.eastspring.tom.cart.core.svc.WebTaskSvc;
import com.eastspring.tom.cart.core.utl.FormatterUtil;
import com.eastspring.tom.cart.dmp.pages.AuditLogReportPage;
import com.eastspring.tom.cart.dmp.pages.HomePage;
import com.eastspring.tom.cart.dmp.pages.LoginPage;
import com.eastspring.tom.cart.dmp.pages.industryclassif.IndustryClassificationSetPage;
import com.eastspring.tom.cart.dmp.pages.internaldomaindatafeed.InternalDomainDataFeedPage;
import com.eastspring.tom.cart.dmp.pages.internaldomaindatafeedclass.InternalDomainDataFeedClassPage;
import com.eastspring.tom.cart.dmp.pages.myworklist.MyWorkListPage;
import com.eastspring.tom.cart.dmp.utl.DmpGsPortalUtl;
import org.openqa.selenium.WebElement;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;

import java.util.*;
import java.util.stream.Collectors;

import static com.eastspring.tom.cart.constant.CommonLocators.*;
import static com.eastspring.tom.cart.dmp.mdl.GSUIFields.*;

public class DmpGsPortalSteps {

    private static final Logger LOGGER = LoggerFactory.getLogger(DmpGsPortalSteps.class);

    public static final String ID = "id";
    public static final String NAME = "name";
    public static final String OPEN = "Open";
    private static final String GS_UI_SPLITTER_XPATH = "//div[contains(@class,'v-button-link gsSplitter')]";
    private static final String GS_WORKLIST_MYWORKLIST_SUBMENU = "//span[@class='v-button-caption'][text()='%s']/ancestor::div[contains(@class,'v-button-gsSubMenu')]";

    @Autowired
    private FormatterUtil formatterUtil;

    @Autowired
    private ThreadSvc threadSvc;

    @Autowired
    private WebTaskSvc webTaskSvc;

    @Autowired
    private StateSvc stateSvc;

    @Autowired
    private DmpGsPortalUtl dmpGsPortalUtl;

    @Autowired
    private LoginPage loginPage;

    @Autowired
    private HomePage homePage;

    @Autowired
    private MyWorkListPage myWorkListPage;

    @Autowired
    private IndustryClassificationSetPage industryClassificationSetPage;

    @Autowired
    private InternalDomainDataFeedPage internalDomainDataFeedPage;

    @Autowired
    private InternalDomainDataFeedClassPage internalDomainDataFeedClassPage;

    @Autowired
    private AuditLogReportPage auditLogReportPage;

    private void launchGsUrl(final String url) {
        stateSvc.setStringVar("cucumber.reports.app.url", url);
        webTaskSvc.openWebUrl(url);
    }

    public void loginGsWithInlineUrl(final String url, final String username, final String pwd) {
        launchGsUrl(url);
        final String inlineUrl = url + "/protected/index/j_security_check?j_username=" + username + "&j_password=" + pwd + "&login=LOGIN";
        webTaskSvc.openWebUrlOnSameSession(inlineUrl);
    }

    public void verifyValidationErrorCount(final Integer errorsCount) {
        WebElement msgWebElement = webTaskSvc.getWebElementRef(GS_VALIDATION_ERROR_COUNT_MSG);
        if (msgWebElement == null) {
            LOGGER.error("There are are no validation errors on screen");
            throw new CartException(CartExceptionType.VALIDATION_FAILED, "There are are no validation errors on screen");
        }
        final String actualMsg = msgWebElement.getText();
        LOGGER.debug("Actual Validation Error Message is [{}]", actualMsg);

        final Integer actualErrorsCount = Integer.valueOf(actualMsg.replaceAll("[^0-9]+", ""));
        dmpGsPortalUtl.assertEquals(errorsCount, actualErrorsCount);
    }

    public void verifyValidationErrorMessage(final Map<String, String> columnValueMap) {
        webTaskSvc.setImplicitWait(1);
        if (webTaskSvc.getWebElementRef(GS_VALIDATION_ERROR_TABLE) == null) {
            webTaskSvc.click(GS_VALIDATION_ERROR_LINK);
        }
        webTaskSvc.setDefaultImplicitWait();

        final String gsoField = columnValueMap.get(VALIDATION_ERROR_GSO_FILED);
        final String severity = columnValueMap.get(VALIDATION_ERROR_SEVERITY);
        final String validationMsg = columnValueMap.get(VALIDATION_ERROR_MESSAGE);

        List<ValidationError> errors = dmpGsPortalUtl.readAllValidationErrors()
                .stream()
                .filter(validationError -> validationError.getGsoField().equals(gsoField))
                .filter(validationError -> validationError.getSeverity().equals(severity))
                .filter(validationError -> validationError.getValidationMsg().equals(validationMsg))
                .collect(Collectors.toList());

        if (!errors.isEmpty()) {
            LOGGER.debug("[{}]", errors.get(0).toString());
        } else {
            LOGGER.error("Cannot find validation error message with GSO Field [{}], Severity [{}] and Validation Message [{}]", gsoField, severity, validationMsg);
            throw new CartException(CartExceptionType.VERIFICATION_FAILED, "Cannot find validation error message with GSO Field [{}], Severity [{}] and Validation Message [{}]", gsoField, severity, validationMsg);
        }
    }


    public void verifyErrorMessageOnPopUpContent(final String errorMsg) {
        webTaskSvc.setImplicitWait(1);
        String actErrMsg = dmpGsPortalUtl.getErrorPopUpContent();
        webTaskSvc.setDefaultImplicitWait();
        if (actErrMsg.contains(errorMsg)) {
            LOGGER.debug("Error Message displayed [{}]", actErrMsg);
        } else {
            LOGGER.error("Cannot find error message [{}] form popup content, actual message [{}]", errorMsg, actErrMsg);
            throw new CartException(CartExceptionType.VERIFICATION_FAILED, "Cannot find error message [{}] form popup content, actual message [{}]", errorMsg, actErrMsg);
        }
    }

    public void iLogoutFromGsUi() {
        homePage.logout();
    }

    public void selectGsMenu(String gsMenu) {
        threadSvc.inbetweenStepsWait();
        String[] breakdownList = gsMenu.split("::");
        LOGGER.debug("breakdownList: {}", Arrays.toString(breakdownList));
        homePage.clickMenuDropdown();
        homePage.selectMenu(breakdownList[0]);
        if (breakdownList[0].equals(breakdownList[1])) {
            String xpath = formatterUtil.format(GS_WORKLIST_MYWORKLIST_SUBMENU, breakdownList[1]);
            webTaskSvc.clickXPath(xpath);
            threadSvc.sleepMillis(1000);
        } else {
            homePage.selectMenu(breakdownList[1]);
        }
    }

    public void closeGsTab(String tabName) {
        threadSvc.inbetweenStepsWait();
        homePage.closeGSTab(tabName);
        threadSvc.sleepMillis(1000);
    }

    public void closeActiveGsTab() {
        String activeScreenName = dmpGsPortalUtl.getActiveScreenName();
        homePage.closeGSTab(activeScreenName);
    }

    public void readColumnNumberToVar(String xpathOfTable, String columnName, String var) {
        threadSvc.inbetweenStepsWait();
        String expandedXpath = stateSvc.expandVar(xpathOfTable);
        String expandedColumnName = stateSvc.expandVar(columnName);
        int columnNum = dmpGsPortalUtl.getTableColumnNumber(expandedXpath, expandedColumnName);
        stateSvc.setStringVar(var, String.valueOf(columnNum));
        LOGGER.debug("Column [{}] found in table at index [{}]", expandedColumnName, columnNum);
    }

    public void reLoginToGSWithUserRole(final String userRole) {
        if (homePage.isUserLoggedIn()) {
            homePage.logout();
            webTaskSvc.waitTillPageLoads();
        }
        this.loginToGSWithUserRole(userRole);
    }

    //Generic Function
    public void expectGsTableRowCountShouldMatch(final Integer expected) {
        Integer actualRowCount = dmpGsPortalUtl.waitTillTableRowCount(GS_DATA_TABLE_XPATH, expected);
        dmpGsPortalUtl.assertEquals(expected, actualRowCount);
    }

    //Generic Function
    public void searchGsTableInputColumn(String columnName, String text, String followingKey) {
        String expandedColumnName = stateSvc.expandVar(columnName);
        String expandedText = stateSvc.expandVar(text);
        int columnNum = dmpGsPortalUtl.getTableColumnNumber(GS_HEADER_TABLE_XPATH, expandedColumnName) + 1;
        String inputFilterXpath = "//div[@class='filters-panel']/div[contains(@class,'filterwrapper')][" + columnNum + "]/input"; //can be read from properties
        WebElement element = webTaskSvc.findElementsByXPath(inputFilterXpath).get(0);
        webTaskSvc.enterTextIntoWebElement(element, expandedText, followingKey);
        LOGGER.debug("Search performed on Column [{}]", expandedColumnName);
        threadSvc.sleepSeconds(1);
        List<WebElement> webElementList = webTaskSvc.findElementsByXPath(GS_DATA_TABLE_XPATH);
        if (webElementList.isEmpty()) {
            LOGGER.debug("data table not visible");
            webTaskSvc.clickXPath(GS_UI_SPLITTER_XPATH);
        }
    }

    //Generic Function
    public void expectGsTableCellTextShouldMatchForGivenRow(final String columnName, final String expectedText, final Integer rowNum) {
        final String expandedColumnName = stateSvc.expandVar(columnName);
        final String expandedText = stateSvc.expandVar(expectedText).trim();
        final int columnNum = dmpGsPortalUtl.getTableColumnNumber(GS_HEADER_TABLE_XPATH, expandedColumnName) + 1;
        final String actualText = dmpGsPortalUtl.getCellText(GS_DATA_TABLE_XPATH, rowNum, columnNum).trim();
        dmpGsPortalUtl.assertEquals(expandedText, actualText);
    }


    public void expectRecordsInGsTableWithColumnValue(String columnName, String expectedValue) {
        String expandedColumnName = stateSvc.expandVar(columnName);
        String expandedText = stateSvc.expandVar(expectedValue).trim();
        int columnNum = dmpGsPortalUtl.getTableColumnNumber(GS_HEADER_TABLE_XPATH, expandedColumnName) + 1;
        int rowNum = dmpGsPortalUtl.getRowNumWithText(GS_DATA_TABLE_XPATH, columnNum, expandedText);
        if (rowNum == -1) {
            LOGGER.error("GS Table does not have records with Column [{}] value [{}]", expandedColumnName, expandedText);
            throw new CartException(CartExceptionType.VERIFICATION_FAILED, "GS Table does not have records with Column [{}] value [{}]", expandedColumnName, expandedText);
        } else {
            LOGGER.info("GS Table have records with Column [{}] value [{}] at RowNum [{}]", expandedColumnName, expandedText, rowNum);
        }
    }


    public void loginGsUIWithNamedConfig(String namedConfigPrefix) {
        LOGGER.debug("LoginPage into GS using named Config [{}]", namedConfigPrefix);

        String gsWebUrl = stateSvc.getStringVar(namedConfigPrefix + ".url");
        String gsWebUsername = stateSvc.getStringVar(namedConfigPrefix + ".username");
        String gsWebPassword = stateSvc.getStringVar(namedConfigPrefix + ".password");

        LOGGER.debug(" GS WEB UI URL [{}]", gsWebUrl);
        LOGGER.debug(" GS WEB UI UserName [{}]", gsWebUsername);
        LOGGER.debug(" GS WEB UI Password [{}]", gsWebPassword);

        launchGsUrl(gsWebUrl);
        loginPage.loginIntoGs(gsWebUsername, gsWebPassword);
    }

    public void verifyTabDisplayed(String tabName) {
        homePage.verifyGSTabDisplayed(tabName);
    }

    public void loginToGSWithUserRole(String role) {
        final String gsWebUrl = stateSvc.getStringVar("gs.web.UI.url");
        final String userRole = role.replace("_", "");
        final String gsWebUsername = stateSvc.getStringVar("gs.web.UI." + userRole + ".username");
        final String gsWebPassword = stateSvc.getStringVar("gs.web.UI." + userRole + ".password");
        LOGGER.info("Logging in [{}] with the user [{}]", gsWebUrl, gsWebUsername);
        launchGsUrl(gsWebUrl);
        loginPage.loginIntoGs(gsWebUsername, gsWebPassword);
//        loginGsWithInlineUrl(gsWebUrl, gsWebUsername, gsWebPassword);
    }


    //New Steps
    public void iSearchAuditLogReport(final Map<String, String> map) {
        auditLogReportPage.navigateToAuditLogReport()
                .searchAuditLog(map);
    }

    public void iAddDomainValuesForIDFDF(final String fieldId, final Map<String, String> domainDetails) {
        internalDomainDataFeedPage.navigateToInternalDomainDataFeed()
                .invokeInternalDomainForDataFeed(fieldId)
                .invokeAddNewDetails()
                .fillDomainValues(domainDetails)
                .saveDetails();

        homePage.closeGSTab(dmpGsPortalUtl.getActiveScreenName());
    }


    public void iExpectDomainValuesForIDFDFAreInMyWorkList() {
        final String fieldID = internalDomainDataFeedPage.getFieldid();
        myWorkListPage.navigateToMyWorkList()
                .filterMyWorkListWithEntityId(fieldID)
                .filterMyWorkListWithTaskStatus("Open");

        this.expectGsTableRowCountShouldMatch(1);
    }

    public void iApproveDomainValueRecordForIDFDF() {
        final String fieldID = internalDomainDataFeedPage.getFieldid();
        myWorkListPage.navigateToMyWorkList()
                .filterMyWorkListWithEntityId(fieldID)
                .filterMyWorkListWithTaskStatus("Open")
                .openRecordToAuthorize(fieldID)
                .authorizeRequest();
        dmpGsPortalUtl.waitTillNotificationMessageAppears();
        myWorkListPage.isNotificationDisplayed();
    }

    public void iExpectDomainValuesForIDFDFUpdated(final Map<String, String> map) {
        final String fieldID = internalDomainDataFeedPage.getFieldid();
        Map<String, String> domainValuesDetails = internalDomainDataFeedPage.navigateToInternalDomainDataFeed()
                .invokeInternalDomainForDataFeed(fieldID)
                .getActiveDomainValuedDetails();

        Set<String> fields = map.keySet();
        for (String field : fields) {
            String expectedVal = map.get(field);
            String actualVal = domainValuesDetails.get(field);
            if (!expectedVal.equals(actualVal)) {
                LOGGER.error("IC Details Verification failed, Field [{}] Expected Value [{}], but Actual Value [{}]", field, expectedVal, actualVal);
                throw new CartException(CartExceptionType.VERIFICATION_FAILED, "IC Details Verification failed, Field [{}] Expected Value [{}], but Actual Value [{}]", field, expectedVal, actualVal);
            }
        }
        homePage.closeGSTab(dmpGsPortalUtl.getActiveScreenName());
    }

    public void iAddDomainValuesForIDFDFC(final String fieldDataClassId, final Map<String, String> domainDetails) {
        internalDomainDataFeedClassPage.navigateToInternalDomainDataFeedClass()
                .invokeInternalDomainForDataFeedClass(fieldDataClassId)
                .invokeAddNewDetails()
                .fillDomainValues(domainDetails)
                .saveDetails();

        homePage.closeGSTab(dmpGsPortalUtl.getActiveScreenName());
    }


    public void iExpectDomainValuesForIDFDFCAreInMyWorkList() {
        final String fieldDataClassID = internalDomainDataFeedClassPage.getFieldid();
        myWorkListPage.navigateToMyWorkList()
                .filterMyWorkListWithEntityId(fieldDataClassID)
                .filterMyWorkListWithTaskStatus("Open");

        this.expectGsTableRowCountShouldMatch(1);
    }

    public void iApproveDomainValueRecordForIDFDFC() {
        final String fieldDataClassID = internalDomainDataFeedClassPage.getFieldid();
        myWorkListPage.navigateToMyWorkList()
                .filterMyWorkListWithEntityId(fieldDataClassID)
                .filterMyWorkListWithTaskStatus("Open")
                .openRecordToAuthorize(fieldDataClassID)
                .authorizeRequest();
        dmpGsPortalUtl.waitTillNotificationMessageAppears();
        myWorkListPage.isNotificationDisplayed();
    }

    public void iExpectDomainValuesForIDFDFCUpdated(final Map<String, String> map) {
        final String fieldDataClassID = internalDomainDataFeedClassPage.getFieldid();
        Map<String, String> domainValuesDetails = internalDomainDataFeedClassPage.navigateToInternalDomainDataFeedClass()
                .invokeInternalDomainForDataFeedClass(fieldDataClassID)
                .getActiveDomainValuedDetails();

        Set<String> fields = map.keySet();
        for (String field : fields) {
            String expectedVal = map.get(field);
            String actualVal = domainValuesDetails.get(field);
            if (!expectedVal.equals(actualVal)) {
                LOGGER.error("IC Details Verification failed, Field [{}] Expected Value [{}], but Actual Value [{}]", field, expectedVal, actualVal);
                throw new CartException(CartExceptionType.VERIFICATION_FAILED, "IC Details Verification failed, Field [{}] Expected Value [{}], but Actual Value [{}]", field, expectedVal, actualVal);
            }
        }
        homePage.closeGSTab(dmpGsPortalUtl.getActiveScreenName());
    }

    public void iRejectDomainValueRecordForIDFDFC() {
        final String fieldDataClassID = internalDomainDataFeedClassPage.getFieldid();
        myWorkListPage.navigateToMyWorkList()
                .filterMyWorkListWithEntityId(fieldDataClassID)
                .filterMyWorkListWithTaskStatus("Open")
                .openRecordToAuthorize(fieldDataClassID)
                .rejectRequest();
        myWorkListPage.isNotificationDisplayed();
    }

    public void iCloseDomainValueRecordForIDFDFC() {
        final String fieldDataClassID = internalDomainDataFeedClassPage.getFieldid();
        myWorkListPage.navigateToMyWorkList()
                .filterMyWorkListWithEntityId(fieldDataClassID)
                .filterMyWorkListWithTaskStatus("Open")
                .openRecordToAuthorize(fieldDataClassID)
                .closeRequest();
        myWorkListPage.isNotificationDisplayed();
    }

    public void iReassignDomainValueRecordForIDFDFC(String userid) {
        final String fieldDataClassID = internalDomainDataFeedClassPage.getFieldid();
        myWorkListPage.navigateToMyWorkList()
                .filterMyWorkListWithEntityId(fieldDataClassID)
                .filterMyWorkListWithTaskStatus("Open")
                .openRecordToAuthorize(fieldDataClassID)
                .reassignRequest(userid);
        myWorkListPage.isNotificationDisplayed();
    }


    //Common function to Handle My WorkList Operations
    public void iActOnRecordFromMyWorkList(final String action, final String entity, final String entityType) {

        myWorkListPage.navigateToMyWorkList()
                .filterMyWorkListWithTaskStatus(OPEN);

        webTaskSvc.waitTillPageLoads();

        if (ID.equalsIgnoreCase(entityType)) {
            myWorkListPage.filterMyWorkListWithEntityId(entity);
        } else if (NAME.equalsIgnoreCase(entityType)) {
            myWorkListPage.filterMyWorkListWithEntityName(entity);
        }

        myWorkListPage.openRecordToAuthorize(entity);

        switch (action.toLowerCase()) {
            case "approve":
                myWorkListPage.authorizeRequest();
                dmpGsPortalUtl.waitTillNotificationMessageAppears();
                break;

            case "reject":
                myWorkListPage.rejectRequest();
                break;

            case "close":
                myWorkListPage.closeRequest();
                break;

            case "reassign":
                //user to be parameterized later
                myWorkListPage.reassignRequest("Ruby Narag");
                break;

            default:
                LOGGER.error("Unsupported action [{}] in MyWorkList Page", action.toLowerCase());
                throw new CartException(CartExceptionType.UNSUPPORTED_ENCODING, "Unsupported action [{}] in MyWorkList Page", action.toLowerCase());
        }
    }


    //Generic Step
    public void iExpectRecordInMyWorkList(final String entity, final String entityType, final String status) {
        final int expectedRowCount = 1;

        myWorkListPage.navigateToMyWorkList().
                filterMyWorkListWithTaskStatus(status);

        if (ID.equalsIgnoreCase(entityType)) {
            myWorkListPage.filterMyWorkListWithEntityId(entity);
        } else if (NAME.equalsIgnoreCase(entityType)) {
            myWorkListPage.filterMyWorkListWithEntityName(entity);
        }
        threadSvc.sleepSeconds(1);
        this.expectGsTableRowCountShouldMatch(expectedRowCount);
    }


    //Generic step
    public void iSaveChanges() {
        String activeScreenName = dmpGsPortalUtl.getActiveScreenName();
        try {
            dmpGsPortalUtl.saveChanges();
            threadSvc.sleepSeconds(1);
        } catch (Exception e) {
            LOGGER.error("Processing failed while saving screen [{}] changes", activeScreenName);
            throw new CartException(CartExceptionType.PROCESSING_FAILED, "Processing failed while saving screen [{}] changes ", activeScreenName);
        }
    }

    //Generic step
    public void iSaveChangesWithValidData(final boolean modifyMode) {
        dmpGsPortalUtl.saveChangesWithValidData(modifyMode);
        threadSvc.sleepSeconds(1);
        dmpGsPortalUtl.waitTillSuccessNotificationMessageAppears();

    }

    public void verifyDropdownValues(final String elementProps, final List<String> expectedValues, final boolean isAllValuesPresent) {
        final String expandElementProps = stateSvc.expandVar(elementProps);
        final WebElement element = webTaskSvc.waitForElementToAppear(elementProps, 10);
        element.click();

        List<String> dropDownFieldValues = dmpGsPortalUtl.getDropDownFieldValues();
        LOGGER.debug("Dropdown values in Element with property [{}] are [{}]: ", expandElementProps, dropDownFieldValues);

        //This is to close the popupContent
        element.click();

        List<String> actualValues = dropDownFieldValues.stream()
                .filter(s -> !s.equals(" "))
                .collect(Collectors.toList());

        boolean countMatch = actualValues.size() == expectedValues.size();
        List<String> missingList = expectedValues.stream()
                .filter(s -> !actualValues.contains(s))
                .collect(Collectors.toList());

        if (isAllValuesPresent) {
            if (!countMatch || missingList.size() > 0) {
                LOGGER.error("Dropdown Values verification failed, list values Count check is [{}] and missing values are [{}]", countMatch, missingList);
                throw new CartException(CartExceptionType.VERIFICATION_FAILED, "Dropdown Values verification failed, list values Count check is [{}] and missing values are [{}]", countMatch, missingList);
            }
        } else {
            if (missingList.size() > 0) {
                LOGGER.error("Dropdown Values verification failed, missing values are [{}]", missingList);
                throw new CartException(CartExceptionType.VERIFICATION_FAILED, "Dropdown Values verification failed, missing values are [{}]", missingList);
            }
        }
    }

    public void verifyDropdownValuesCount(final String elementProps, final Map<String, String> expectedValueCntMap) {
        final String expandElementProps = stateSvc.expandVar(elementProps);
        Set<String> expectedValues = expectedValueCntMap.keySet();
        Map<String, Integer> failures = new HashMap<>();

        for (String val : expectedValues) {
            dmpGsPortalUtl.inputText(expandElementProps, val, null, true);

            List<String> actualValues = dmpGsPortalUtl.getDropDownFieldValues();
            LOGGER.debug("Dropdown values available starting with value [{}] are [{}] ", val, actualValues);

            Map<String, Integer> actualValueCntMap = new HashMap<>();
            for (String aVal : actualValues) {
                actualValueCntMap.put(aVal, actualValueCntMap.getOrDefault(val, 0) + 1);
            }

            Integer actualCnt = actualValueCntMap.get(val);
            Integer expectedCnt = Integer.valueOf(expectedValueCntMap.get(val));
            if (!expectedCnt.equals(actualCnt)) {
                failures.put(val, actualCnt);
            }
        }
        dmpGsPortalUtl.inputText(expandElementProps, "", "ENTER", false);
        if (failures.size() > 0) {
            LOGGER.error("Dropdown Values Count verification failed, Actual Counts are [{}]", failures);
            throw new CartException(CartExceptionType.VERIFICATION_FAILED, "Dropdown Values Count verification failed, Actual counts are [{}]", failures);
        }
    }

    public void iClickAuthorizeFromWorkList(String recordIdentifier) {
        myWorkListPage.openRecordToAuthorize(recordIdentifier)
                .authorizeRequest();
    }

    public void iDeleteRecord() {
        dmpGsPortalUtl.deleteRecord();
        threadSvc.sleepSeconds(1);
    }

    public void iOpenFromGlobalSearch(String entity) {
        String expandEntity = stateSvc.expandVar(entity);
        String[] entityDetails = expandEntity.split(":");
        homePage.globalSearchAndWaitTillSuccess(entityDetails[1], entityDetails[0], 60);
    }

}