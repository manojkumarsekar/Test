package com.eastspring.tom.cart.dmp.pages.internaldomaindatafeed;

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
import org.openqa.selenium.By;
import org.openqa.selenium.WebElement;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;

import java.util.HashMap;
import java.util.Map;

import static com.eastspring.tom.cart.constant.CommonLocators.GS_HEADER_TABLE_XPATH;
import static com.eastspring.tom.cart.constant.CommonLocators.GS_SAVE_BUTTON;
import static com.eastspring.tom.cart.constant.CommonLocators.GS_SEARCH_TEXT_FIELD;
import static com.eastspring.tom.cart.dmp.mdl.GSUIFields.IDFDF_COLUMN_NAME;
import static com.eastspring.tom.cart.dmp.mdl.GSUIFields.IDFDF_DATA_STREAM_ID;
import static com.eastspring.tom.cart.dmp.mdl.GSUIFields.IDFDF_DOMAIN_SET_ID;
import static com.eastspring.tom.cart.dmp.mdl.GSUIFields.IDFDF_DOMAIN_VALUE;
import static com.eastspring.tom.cart.dmp.mdl.GSUIFields.IDFDF_DOMAIN_VALUE_DESC;
import static com.eastspring.tom.cart.dmp.mdl.GSUIFields.IDFDF_DOMAIN_VALUE_NAME;
import static com.eastspring.tom.cart.dmp.mdl.GSUIFields.IDFDF_DOMAIN_VALUE_PURS_TYPE;
import static com.eastspring.tom.cart.dmp.mdl.GSUIFields.IDFDF_FIELD_DATA_CLASS_ID;
import static com.eastspring.tom.cart.dmp.mdl.GSUIFields.IDFDF_MOD_RESTRICTION_IND;
import static com.eastspring.tom.cart.dmp.mdl.GSUIFields.IDFDF_QUALIFIED_ID;
import static com.eastspring.tom.cart.dmp.mdl.GSUIFields.IDFDF_QUALIFIED_VALUE;
import static com.eastspring.tom.cart.dmp.mdl.GSUIFields.IDFDF_TABLE_ID;

public class InternalDomainDataFeedPage {

    private static final Logger LOGGER = LoggerFactory.getLogger(InternalDomainDataFeedPage.class);

    public static final String IDFDF_DOMAINVALNAME_TEXTFIELD = "xpath://*[contains(@id,'IntDomainValueName')]//input";
    public static final String IDFDF_DOMAINVAL_TEXTFIELD = "xpath://*[@id='InternalDomainValueforDataFieldIndentifier.DomainValues.FLDFIDMVIntDomainValue']//input";
    public static final String IDFDF_MODIREST_TEXTFIELD = "xpath://*[@id='InternalDomainValueforDataFieldIndentifier.DomainValues.FLDFIDMVModificationRestrictionInd']//input";
    public static final String IDFDF_DOMAINVALDESC_TEXTFIELD = "xpath://*[@id='InternalDomainValueforDataFieldIndentifier.DomainValues.FLDFIDMVIntDomainValueDescription']//input";
    public static final String IDFDF_QUAFIELDID_TEXTFIELD = "xpath://*[@id='InternalDomainValueforDataFieldIndentifier.DomainValues.FLDFIDMVQualifiedFieldID']//input";
    public static final String IDFDF_QUALIVAL_TEXTFIELD = "xpath://*[@id='InternalDomainValueforDataFieldIndentifier.DomainValues.FLDFIDMVQualificationValue']//input";
    public static final String IDFDF_TABLEID_TEXTFIELD = "xpath://*[@id='InternalDomainValueforDataFieldIndentifier.DomainValues.FLDFIDMVTableID']//input";
    public static final String IDFDF_COLNAME_TEXTFIELD = "xpath://*[@id='InternalDomainValueforDataFieldIndentifier.DomainValues.FLDFIDMVColumnName']//input";
    public static final String IDFDF_DOMAINSETID_TEXTFIELD = "xpath://*[@id='InternalDomainValueforDataFieldIndentifier.DomainValues.FLDFIDMVDomainSetID']//input";
    public static final String IDFDF_DOMAINVALPURTYPE_TEXTFIELD = "xpath://*[@id='InternalDomainValueforDataFieldIndentifier.DomainValues.FLDFIDMVDomainValuePurposeType']//input";
    public static final String IDFDF_DATASTREAMID_TEXTFIELD = "xpath://*[@id='InternalDomainValueforDataFieldIndentifier.DomainValues.FLDFIDMVDataStreamID']//input";
    public static final String IDFDF_FIELDDATACLASSID_TEXTFIELD = "xpath://*[@id='InternalDomainValueforDataFieldIndentifier.DomainValues.FLDFIDMVFieldDataClassID']//input";
    public static final String IDFDF_FIELDNAME_TEXTFIELD = "xpath://*[@id='InternalDomainValueforDataFieldIndentifier.InternalDomainValue.FLDFFieldName']//input";

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

    private String fieldid;
    private String internaldomainValuename;

    public void setInternalDomainValueName(final String internaldomainValuename) {
        final String format = this.dateTimeUtil.getTimestamp("DHMs");
        this.internaldomainValuename = internaldomainValuename.concat(format);
    }

    public String getInternalDomainValueName() {
        return internaldomainValuename;
    }


    public void setFieldid(final String fieldid) {
        this.fieldid = fieldid;
    }

    public String getFieldid() {
        return fieldid;
    }

    public InternalDomainDataFeedPage navigateToInternalDomainDataFeed() {
        LOGGER.debug("Navigating to Internal Domain for Data Feed Screen");
        homePage.clickMenuDropdown()
                .selectMenu("Generic Setup")
                .selectMenu("Internal Domain For Data Field");
        homePage.verifyGSTabDisplayed("Internal Domain For Data Field");
        return this;
    }

    public InternalDomainDataFeedPage invokeInternalDomainForDataFeed(final String fieldid) {
        this.setFieldid(fieldid);

        final int columnNum = dmpGsPortalUtl.getTableColumnNumber(GS_HEADER_TABLE_XPATH, "Field ID");
        final By filterBy = webTaskSvc.getByReference(formatter.format(GS_SEARCH_TEXT_FIELD, columnNum + 1));
        final WebElement filterElement = webTaskSvc.waitForElementToAppear(filterBy, 0);

        webTaskSvc.enterTextIntoWebElement(filterElement, fieldid, "ENTER");
        try {
            webTaskSvc.waitForElementToAppear(GS_SAVE_BUTTON, 20);
            LOGGER.debug("Internal Domain for Data Feed [{}] is Opened to Add Details...", fieldid);
        } catch (CartException e) {
            LOGGER.error("Internal Domain for Data Feed [{}] is Not available in the System!!", fieldid);
            throw new CartException(CartExceptionType.PROCESSING_FAILED, "Internal Domain for Data Feed [{}] is Not available in the System!!", fieldid);
        }
        return this;
    }

    public InternalDomainDataFeedPage invokeAddNewDetails() {
        dmpGsPortalUtl.addNewDetails();
        threadSvc.sleepSeconds(1);
        return this;
    }

    public InternalDomainDataFeedPage fillDomainValues(final Map<String, String> map) {
        this.setInternalDomainValueName(map.get(IDFDF_DOMAIN_VALUE_NAME));
        try {
            dmpGsPortalUtl.inputText(IDFDF_DOMAINVALNAME_TEXTFIELD, getInternalDomainValueName(), "ENTER", true);
            dmpGsPortalUtl.inputText(IDFDF_DOMAINVAL_TEXTFIELD, map.get(IDFDF_DOMAIN_VALUE), "ENTER", true);
            dmpGsPortalUtl.inputText(IDFDF_MODIREST_TEXTFIELD, map.get(IDFDF_MOD_RESTRICTION_IND), "ENTER", true);
            dmpGsPortalUtl.inputText(IDFDF_DOMAINVALDESC_TEXTFIELD, map.get(IDFDF_DOMAIN_VALUE_DESC), "ENTER", false);
            dmpGsPortalUtl.inputText(IDFDF_QUAFIELDID_TEXTFIELD, map.get(IDFDF_QUALIFIED_ID), "ENTER", true);
            dmpGsPortalUtl.inputText(IDFDF_QUALIVAL_TEXTFIELD, map.get(IDFDF_QUALIFIED_VALUE), "ENTER", false);
            dmpGsPortalUtl.inputText(IDFDF_TABLEID_TEXTFIELD, map.get(IDFDF_TABLE_ID), "ENTER", false);
            dmpGsPortalUtl.inputText(IDFDF_COLNAME_TEXTFIELD, map.get(IDFDF_COLUMN_NAME), "ENTER", false);
            dmpGsPortalUtl.inputText(IDFDF_DOMAINSETID_TEXTFIELD, map.get(IDFDF_DOMAIN_SET_ID), "ENTER", false);
            dmpGsPortalUtl.inputText(IDFDF_DOMAINVALPURTYPE_TEXTFIELD, map.get(IDFDF_DOMAIN_VALUE_PURS_TYPE), "ENTER", false);
            dmpGsPortalUtl.inputText(IDFDF_DATASTREAMID_TEXTFIELD, map.get(IDFDF_DATA_STREAM_ID), "ENTER", false);
            dmpGsPortalUtl.inputText(IDFDF_FIELDDATACLASSID_TEXTFIELD, map.get(IDFDF_FIELD_DATA_CLASS_ID), "ENTER", false);
            return this;
        } catch (Exception e) {
            LOGGER.error("Processing failed!!", e);
            throw new CartException(CartExceptionType.PROCESSING_FAILED, "Processing failed!!");
        }
    }

    public Map<String, String> getActiveDomainValuedDetails() {
        Map<String, String> map = new HashMap<>();
        map.put(IDFDF_DOMAIN_VALUE_NAME, webTaskSvc.getWebElementAttribute(IDFDF_DOMAINVALNAME_TEXTFIELD, "value"));
        map.put(IDFDF_DOMAIN_VALUE, webTaskSvc.getWebElementAttribute(IDFDF_DOMAINVAL_TEXTFIELD, "value"));
        map.put(IDFDF_MOD_RESTRICTION_IND, webTaskSvc.getWebElementAttribute(IDFDF_MODIREST_TEXTFIELD, "value"));
        map.put(IDFDF_DOMAIN_VALUE_DESC, webTaskSvc.getWebElementAttribute(IDFDF_DOMAINVALDESC_TEXTFIELD, "value"));
        map.put(IDFDF_QUALIFIED_ID, webTaskSvc.getWebElementAttribute(IDFDF_QUAFIELDID_TEXTFIELD, "value"));
        map.put(IDFDF_QUALIFIED_VALUE, webTaskSvc.getWebElementAttribute(IDFDF_QUALIVAL_TEXTFIELD, "value"));
        map.put(IDFDF_TABLE_ID, webTaskSvc.getWebElementAttribute(IDFDF_TABLEID_TEXTFIELD, "value"));
        map.put(IDFDF_COLUMN_NAME, webTaskSvc.getWebElementAttribute(IDFDF_COLNAME_TEXTFIELD, "value"));
        map.put(IDFDF_DOMAIN_SET_ID, webTaskSvc.getWebElementAttribute(IDFDF_DOMAINSETID_TEXTFIELD, "value"));
        map.put(IDFDF_DOMAIN_VALUE_PURS_TYPE, webTaskSvc.getWebElementAttribute(IDFDF_DOMAINVALPURTYPE_TEXTFIELD, "value"));
        map.put(IDFDF_DATA_STREAM_ID, webTaskSvc.getWebElementAttribute(IDFDF_DATASTREAMID_TEXTFIELD, "value"));
        map.put(IDFDF_FIELD_DATA_CLASS_ID, webTaskSvc.getWebElementAttribute(IDFDF_FIELDDATACLASSID_TEXTFIELD, "value"));
        return map;
    }

    public InternalDomainDataFeedPage invokeDetailsView() {
        dmpGsPortalUtl.invokeDetailsView();
        return this;
    }

    public void saveDetails() {
        dmpGsPortalUtl.saveChanges();
    }


}
