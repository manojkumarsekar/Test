package com.eastspring.tom.cart.dmp.pages.industryclassif;

import com.eastspring.tom.cart.core.CartException;
import com.eastspring.tom.cart.core.CartExceptionType;
import com.eastspring.tom.cart.core.steps.WebSteps;
import com.eastspring.tom.cart.core.svc.StateSvc;
import com.eastspring.tom.cart.core.svc.ThreadSvc;
import com.eastspring.tom.cart.core.svc.WebTaskSvc;
import com.eastspring.tom.cart.core.utl.DateTimeUtil;
import com.eastspring.tom.cart.core.utl.FormatterUtil;
import com.eastspring.tom.cart.dmp.pages.HomePage;
import com.eastspring.tom.cart.dmp.utl.DmpGsPortalUtl;
import com.google.common.base.Strings;
import org.openqa.selenium.By;
import org.openqa.selenium.WebElement;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;

import java.util.HashMap;
import java.util.Map;
import java.util.Set;

import static com.eastspring.tom.cart.constant.CommonLocators.GS_DELETE_DETAILS_RECORD;
import static com.eastspring.tom.cart.constant.CommonLocators.GS_HEADER_TABLE_XPATH;
import static com.eastspring.tom.cart.constant.CommonLocators.GS_POPUP_CONTENT;
import static com.eastspring.tom.cart.constant.CommonLocators.GS_POPUP_DATA_TABLE_ROW;
import static com.eastspring.tom.cart.constant.CommonLocators.GS_POPUP_DATE_SELECTOR;
import static com.eastspring.tom.cart.constant.CommonLocators.GS_POPUP_DELETE_RECORD;
import static com.eastspring.tom.cart.constant.CommonLocators.GS_POPUP_SET_BUTTON;
import static com.eastspring.tom.cart.constant.CommonLocators.GS_SAVE_BUTTON;
import static com.eastspring.tom.cart.constant.CommonLocators.GS_SEARCH_TEXT_FIELD;
import static com.eastspring.tom.cart.constant.CommonLocators.VARIABLE;
import static com.eastspring.tom.cart.dmp.mdl.GSUIFields.ICS_CLASSIFICATION_CREATED_ON;
import static com.eastspring.tom.cart.dmp.mdl.GSUIFields.ICS_CLASSIFICATION_ID;
import static com.eastspring.tom.cart.dmp.mdl.GSUIFields.ICS_CLASSIFICATION_VALUE;
import static com.eastspring.tom.cart.dmp.mdl.GSUIFields.ICS_CLASS_DESCRIPTION;
import static com.eastspring.tom.cart.dmp.mdl.GSUIFields.ICS_CLASS_NAME;
import static com.eastspring.tom.cart.dmp.mdl.GSUIFields.ICS_LEVEL_NUMBER;

public class IndustryClassificationSetPage {

    private static final Logger LOGGER = LoggerFactory.getLogger(IndustryClassificationSetPage.class);

    //This is support locator, hence xpath: has not appended
    private static final String CLASSIF_DETAILS_TABLE = "//div[text()='Industry Classification Details']//ancestor::div[contains(@class,'gsDetailSectionPanel')]//table[@class='v-table-table']";

    private static final String XPATH = "xpath:";
    public static final String CLASS_NAME_LOCATOR = XPATH + CLASSIF_DETAILS_TABLE + "//div[text()='Class Name']/../..//input";
    public static final String CLASS_DESCRIPTION_LOCATOR = XPATH + CLASSIF_DETAILS_TABLE + "//div[text()='Class Description']/../..//textarea";
    public static final String CLASSIFICATION_ID_LOCATOR = XPATH + CLASSIF_DETAILS_TABLE + "//div[text()='Classification ID']/../..//input";
    public static final String CLASSIFICATION_VALUE_LOCATOR = XPATH + CLASSIF_DETAILS_TABLE + "//div[text()='Classification Value']/../..//input";
    private static final String LEVEL_NUMBER_LOCATOR = XPATH + CLASSIF_DETAILS_TABLE + "//div[text()='Level Number']/../..//input";
    public static final String CLASSIFICATION_CREATED_ON_LOCATOR = XPATH + CLASSIF_DETAILS_TABLE + "//div[text()='Classification Created On']/../..//input";


    private static final String GS_POPUP_LEVEL_NUMBER_SELECTOR = XPATH + GS_POPUP_CONTENT + "//div[@class='filters-panel']//div[1]//div[@role='button']";
    private static final String GS_POPUP_CLASS_CREATED_ON_SELECTOR = XPATH + GS_POPUP_CONTENT + "//div[@class='filters-panel']//div[2]//div[@role='button']";

    private static final String GS_POPUP_LESSTHAN_INPUT = "xpath://div[contains(@class,'popupview')]//span[text()='Less Than']/../../input";
    private static final String VALUE = "value";
    private static final String DHMS = "DHMs";

    @Autowired
    private HomePage homePage;

    @Autowired
    private WebSteps webSteps;

    @Autowired
    private WebTaskSvc webTaskSvc;

    @Autowired
    private FormatterUtil formatter;

    @Autowired
    private DmpGsPortalUtl dmpGsPortalUtl;

    @Autowired
    private ThreadSvc threadSvc;

    @Autowired
    private StateSvc stateSvc;

    @Autowired
    private DateTimeUtil dateTimeUtil;

    private String classificationValue;

    private void setClassificationValue(final String classificationValue) {
        this.classificationValue = stateSvc.expandVar(classificationValue);
    }

    private String getClassificationValue() {
        return classificationValue;
    }

    public IndustryClassificationSetPage navigateToIndusClassifSet() {
        LOGGER.debug("Navigating to Industry Classification Set Screen");
        homePage.clickMenuDropdown()
                .selectMenu("Generic Setup")
                .selectMenu("Industry Classification Set");
        homePage.verifyGSTabDisplayed("Industry Classification Set");
        return this;
    }

    public IndustryClassificationSetPage invokeClassificationSet(final String clfSetMnemonic) {
       dmpGsPortalUtl.filterTable("Classification Set Mnemonic",clfSetMnemonic,false);

        try {
            webTaskSvc.waitForElementToAppear(GS_SAVE_BUTTON, 20);
            LOGGER.debug("Classification Set [{}] is Opened to Add Details...", clfSetMnemonic);
        } catch (CartException e) {
            LOGGER.error("Classification Set [{}] is Not available in the System!!", clfSetMnemonic);
            throw new CartException(CartExceptionType.PROCESSING_FAILED, "Classification Set [{}] is Not available in the System!!", clfSetMnemonic);
        }
        return this;
    }

    public IndustryClassificationSetPage invokeAddNewDetails() {
        dmpGsPortalUtl.addNewDetails();
        threadSvc.sleepSeconds(1);
        return this;
    }

    public IndustryClassificationSetPage fillIndustryClassificationDetails(final String mnemonic, final Map<String, String> map) {
        this.setClassificationValue(map.get(ICS_CLASSIFICATION_VALUE));
        try {
            dmpGsPortalUtl.inputText(CLASS_NAME_LOCATOR, map.get(ICS_CLASS_NAME), "", true);
            dmpGsPortalUtl.inputText(CLASSIFICATION_VALUE_LOCATOR, getClassificationValue(), "", true);
            dmpGsPortalUtl.inputText(CLASSIFICATION_CREATED_ON_LOCATOR, map.get(ICS_CLASSIFICATION_CREATED_ON), "ENTER", true);
            dmpGsPortalUtl.inputText(CLASSIFICATION_ID_LOCATOR, mnemonic, "", true);
            dmpGsPortalUtl.inputText(CLASS_DESCRIPTION_LOCATOR, map.get(ICS_CLASS_DESCRIPTION), "", false);
            dmpGsPortalUtl.inputText(LEVEL_NUMBER_LOCATOR, map.get(ICS_LEVEL_NUMBER), "", false);
            return this;
        } catch (Exception e) {
            LOGGER.error("Processing failed!!", e);
            throw new CartException(CartExceptionType.PROCESSING_FAILED, "Processing failed!!");
        }
    }

    public Map<String, String> getActiveIndustryClassificationDetails() {
        Map<String, String> map = new HashMap<>();
        map.put(ICS_CLASS_NAME, webTaskSvc.getWebElementAttribute(CLASS_NAME_LOCATOR, VALUE));
        map.put(ICS_CLASS_DESCRIPTION, webTaskSvc.getWebElementAttribute(CLASS_DESCRIPTION_LOCATOR, VALUE));
        map.put(ICS_CLASSIFICATION_VALUE, webTaskSvc.getWebElementAttribute(CLASSIFICATION_VALUE_LOCATOR, VALUE));
        map.put(ICS_CLASSIFICATION_ID, webTaskSvc.getWebElementAttribute(CLASSIFICATION_ID_LOCATOR, VALUE));
        map.put(ICS_CLASSIFICATION_CREATED_ON, webTaskSvc.getWebElementAttribute(CLASSIFICATION_CREATED_ON_LOCATOR, VALUE));
        map.put(ICS_LEVEL_NUMBER, webTaskSvc.getWebElementAttribute(LEVEL_NUMBER_LOCATOR, VALUE));
        return map;
    }

    public IndustryClassificationSetPage invokeDetailsView() {
        dmpGsPortalUtl.invokeDetailsView();
        return this;
    }

    public IndustryClassificationSetPage searchIndustryClassificationDetails(final Map<String, String> map) {
        final Set<String> colNames = map.keySet();
        String value;
        String recordIdentifier = null;

        for (String column : colNames) {
            try {
                value = map.get(column);
                switch (column) {
                    case ICS_LEVEL_NUMBER:
                        detailsViewLevelSelector(value);
                        break;
                    case ICS_CLASSIFICATION_CREATED_ON:
                        detailsViewDateSelector(value);
                        break;
                    default:
                        if (column.equals(ICS_CLASSIFICATION_VALUE)) {
                            if (!Strings.isNullOrEmpty(getClassificationValue())) {
                                value = getClassificationValue();
                            }
                            recordIdentifier = value;
                        }
                        dmpGsPortalUtl.filterPopupContentTable(column, value, false);
                        threadSvc.sleepSeconds(1);
                        break;
                }
            } catch (Exception e) {
                LOGGER.error("Cannot search with Column Name [{}]", column);
                throw new CartException(CartExceptionType.IO_ERROR, "Cannot search with Column Name [{}]", column);
            }
        }
        dmpGsPortalUtl.selectRecord(GS_POPUP_DATA_TABLE_ROW, recordIdentifier);
        threadSvc.sleepSeconds(1);
        return this;
    }

    public IndustryClassificationSetPage deleteActiveRecordFromDetailView() {
        webTaskSvc.click(GS_POPUP_DELETE_RECORD);
        dmpGsPortalUtl.closePopupWindow();
        threadSvc.sleepSeconds(1);
        return this;
    }

    public IndustryClassificationSetPage deleteActiveRecord() {
        webTaskSvc.click(GS_DELETE_DETAILS_RECORD);
        threadSvc.sleepSeconds(1);
        return this;
    }

    private void detailsViewLevelSelector(final String levelNumber) {
        try {
            webTaskSvc.click(GS_POPUP_LEVEL_NUMBER_SELECTOR);
            dmpGsPortalUtl.inputText(GS_POPUP_LESSTHAN_INPUT, levelNumber, "", true);
            webTaskSvc.click(GS_POPUP_SET_BUTTON);
        } catch (Exception e) {
            LOGGER.error("Error while selecting Level Number [{}]", levelNumber, e);
            throw new CartException(CartExceptionType.PROCESSING_FAILED, "Error while selecting Level Number [{}]", levelNumber);
        }
    }

    private void detailsViewDateSelector(final String dateStr) {
        try {
            final Integer date = Integer.parseInt(dateStr.substring(0, dateStr.indexOf('-')));
            webTaskSvc.click(GS_POPUP_CLASS_CREATED_ON_SELECTOR);
            webTaskSvc.click(formatter.format(GS_POPUP_DATE_SELECTOR, date));
            webTaskSvc.click(GS_POPUP_SET_BUTTON);
        } catch (Exception e) {
            LOGGER.error("Error while selecting Date [{}]", dateStr, e);
            throw new CartException(CartExceptionType.PROCESSING_FAILED, "Error while selecting Date [{}]", dateStr);
        }
    }


}
