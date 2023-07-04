package com.eastspring.tom.cart.dmp.pages.internaldomaindatafeedclass;

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
import static com.eastspring.tom.cart.dmp.mdl.GSUIFields.IDFDFC_COLUMN_NAME;
import static com.eastspring.tom.cart.dmp.mdl.GSUIFields.IDFDFC_DATA_SOURCE_ID;
import static com.eastspring.tom.cart.dmp.mdl.GSUIFields.IDFDFC_DATA_STATUS;
import static com.eastspring.tom.cart.dmp.mdl.GSUIFields.IDFDFC_DOMAIN_SET_ID;
import static com.eastspring.tom.cart.dmp.mdl.GSUIFields.IDFDFC_DOMAIN_VALUE;
import static com.eastspring.tom.cart.dmp.mdl.GSUIFields.IDFDFC_DOMAIN_VALUE_DESC;
import static com.eastspring.tom.cart.dmp.mdl.GSUIFields.IDFDFC_DOMAIN_VALUE_NAME;
import static com.eastspring.tom.cart.dmp.mdl.GSUIFields.IDFDFC_DOMAIN_VALUE_PURS_TYPE;
import static com.eastspring.tom.cart.dmp.mdl.GSUIFields.IDFDFC_MOD_RESTRICTION_IND;
import static com.eastspring.tom.cart.dmp.mdl.GSUIFields.IDFDFC_QUALIFIED_ID;
import static com.eastspring.tom.cart.dmp.mdl.GSUIFields.IDFDFC_QUALIFIED_VALUE;
import static com.eastspring.tom.cart.dmp.mdl.GSUIFields.IDFDFC_TABLE_ID;
import static com.eastspring.tom.cart.dmp.mdl.GSUIFields.IDFDF_DOMAIN_VALUE_NAME;

public class InternalDomainDataFeedClassPage {

    private static final Logger LOGGER = LoggerFactory.getLogger(InternalDomainDataFeedClassPage.class);

    public static final String IDFDFC_DOMAINVALNAME_TEXTFIELD = "xpath://*[contains(@id,'IntDomainValueName')]//input";
    public static final String IDFDFC_DOMAINVAL_TEXTFIELD = "xpath://*[@id='InternalDomainValueByClass.DomainValues.FCDFIDMVIntDomainValue']//input";
    public static final String IDFDFC_MODIREST_TEXTFIELD = "xpath://*[@id='InternalDomainValueByClass.DomainValues.FCDFIDMVModificationRestrictionInd']//input";
    public static final String IDFDFC_DOMAINVALDESC_TEXTFIELD = "xpath://*[@id='InternalDomainValueByClass.DomainValues.FCDFIDMVIntDomainValueDescription']//input";
    public static final String IDFDFC_QUAFIELDID_TEXTFIELD = "xpath://*[@id='InternalDomainValueByClass.DomainValues.FCDFIDMVQualifiedFieldID']//input";
    public static final String IDFDFC_QUALIVAL_TEXTFIELD = "xpath://*[@id='InternalDomainValueByClass.DomainValues.FCDFIDMVQualificationValue']//input";
    public static final String IDFDFC_TABLEID_TEXTFIELD = "xpath://*[@id='InternalDomainValueByClass.DomainValues.FCDFIDMVTableID']//input";
    public static final String IDFDFC_COLNAME_TEXTFIELD = "xpath://*[@id='InternalDomainValueByClass.DomainValues.FCDFIDMVColumnName']//input";
    public static final String IDFDFC_DOMAINSETID_TEXTFIELD = "xpath://*[@id='InternalDomainValueByClass.DomainValues.FCDFIDMVDomainSetID']//input";
    public static final String IDFDFC_DOMAINVALPURTYPE_TEXTFIELD = "xpath://*[@id='InternalDomainValueByClass.DomainValues.FCDFIDMVDomainValuePurposeType']//input";
    public static final String IDFDFC_DATASOURCEID_TEXTFIELD = "xpath://*[@id='InternalDomainValueByClass.DomainValues.FCDFIDMVDataSourceID']//input";
    public static final String IDFDFC_DATASTATUS_TEXTFIELD = "xpath://*[@id='InternalDomainValueByClass.DomainValues.FCDFIDMVDataStatus']//input";

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

    private String fieldDataClassId;
    private String internalDomainValueName;

    public void setInternalDomainValueName(final String internaldomainValuename) {
        final String format = this.dateTimeUtil.getTimestamp("DHMs");
        this.internalDomainValueName = internaldomainValuename.concat(format);
    }

    public String getInternalDomainValueName() {
        return internalDomainValueName;
    }


    public void setFieldid(final String fielddataclassid) {
        this.fieldDataClassId = fielddataclassid;
    }

    public String getFieldid() {
        return fieldDataClassId;
    }

    public InternalDomainDataFeedClassPage navigateToInternalDomainDataFeedClass() {
        LOGGER.debug("Navigating to Internal Domain for Data Feed Screen");
        homePage.clickMenuDropdown()
                .selectMenu("Generic Setup")
                .selectMenu("Internal Domain For Data Field Class");
        homePage.verifyGSTabDisplayed("Internal Domain For Data Field Class");
        return this;
    }

    public InternalDomainDataFeedClassPage invokeInternalDomainForDataFeedClass(final String fieldDataClassid) {
        this.setFieldid(fieldDataClassid);

        final int columnNum = dmpGsPortalUtl.getTableColumnNumber(GS_HEADER_TABLE_XPATH, "Field Data Class ID");
        final By filterBy = webTaskSvc.getByReference(formatter.format(GS_SEARCH_TEXT_FIELD, columnNum + 1));
        final WebElement filterElement = webTaskSvc.waitForElementToAppear(filterBy, 0);

        webTaskSvc.enterTextIntoWebElement(filterElement, fieldDataClassid, "ENTER");
        try {
            webTaskSvc.waitForElementToAppear(GS_SAVE_BUTTON, 20);
            LOGGER.debug("Internal Domain for Data Feed Class [{}] is Opened to Add Details...", fieldDataClassid);
        } catch (CartException e) {
            LOGGER.error("Internal Domain for Data Feed Class [{}] is Not available in the System!!", fieldDataClassid);
            throw new CartException(CartExceptionType.PROCESSING_FAILED, "Internal Domain for Data Feed Class [{}] is Not available in the System!!", fieldDataClassid);
        }
        return this;
    }

    public InternalDomainDataFeedClassPage invokeAddNewDetails() {
        dmpGsPortalUtl.addNewDetails();
        threadSvc.sleepSeconds(1);
        return this;
    }

    public InternalDomainDataFeedClassPage fillDomainValues(final Map<String, String> map) {
        this.setInternalDomainValueName(map.get(IDFDF_DOMAIN_VALUE_NAME));
        try {
            dmpGsPortalUtl.inputText(IDFDFC_DOMAINVALNAME_TEXTFIELD, getInternalDomainValueName(), "ENTER", true);
            dmpGsPortalUtl.inputText(IDFDFC_DOMAINVAL_TEXTFIELD, map.get(IDFDFC_DOMAIN_VALUE), "ENTER", true);
            dmpGsPortalUtl.inputText(IDFDFC_MODIREST_TEXTFIELD, map.get(IDFDFC_MOD_RESTRICTION_IND), "ENTER", true);
            dmpGsPortalUtl.inputText(IDFDFC_DOMAINVALDESC_TEXTFIELD, map.get(IDFDFC_DOMAIN_VALUE_DESC), "ENTER", false);
            dmpGsPortalUtl.inputText(IDFDFC_QUAFIELDID_TEXTFIELD, map.get(IDFDFC_QUALIFIED_ID), "ENTER", true);
            dmpGsPortalUtl.inputText(IDFDFC_QUALIVAL_TEXTFIELD, map.get(IDFDFC_QUALIFIED_VALUE), "ENTER", false);
            dmpGsPortalUtl.inputText(IDFDFC_TABLEID_TEXTFIELD, map.get(IDFDFC_TABLE_ID), "ENTER", false);
            dmpGsPortalUtl.inputText(IDFDFC_COLNAME_TEXTFIELD, map.get(IDFDFC_COLUMN_NAME), "ENTER", false);
            dmpGsPortalUtl.inputText(IDFDFC_DOMAINSETID_TEXTFIELD, map.get(IDFDFC_DOMAIN_SET_ID), "ENTER", false);
            dmpGsPortalUtl.inputText(IDFDFC_DOMAINVALPURTYPE_TEXTFIELD, map.get(IDFDFC_DOMAIN_VALUE_PURS_TYPE), "ENTER", false);
            dmpGsPortalUtl.inputText(IDFDFC_DATASOURCEID_TEXTFIELD, map.get(IDFDFC_DATA_SOURCE_ID), "ENTER", false);
            dmpGsPortalUtl.inputText(IDFDFC_DATASTATUS_TEXTFIELD, map.get(IDFDFC_DATA_STATUS), "ENTER", false);
            return this;
        } catch (Exception e) {
            LOGGER.error("Processing failed!!", e);
            throw new CartException(CartExceptionType.PROCESSING_FAILED, "Processing failed!!");
        }
    }

    public Map<String, String> getActiveDomainValuedDetails() {
        Map<String, String> map = new HashMap<>();
        map.put(IDFDFC_DOMAIN_VALUE_NAME, webTaskSvc.getWebElementAttribute(IDFDFC_DOMAINVALNAME_TEXTFIELD, "value"));
        map.put(IDFDFC_DOMAIN_VALUE, webTaskSvc.getWebElementAttribute(IDFDFC_DOMAINVAL_TEXTFIELD, "value"));
        map.put(IDFDFC_MOD_RESTRICTION_IND, webTaskSvc.getWebElementAttribute(IDFDFC_MODIREST_TEXTFIELD, "value"));
        map.put(IDFDFC_DOMAIN_VALUE_DESC, webTaskSvc.getWebElementAttribute(IDFDFC_DOMAINVALDESC_TEXTFIELD, "value"));
        map.put(IDFDFC_QUALIFIED_ID, webTaskSvc.getWebElementAttribute(IDFDFC_QUAFIELDID_TEXTFIELD, "value"));
        map.put(IDFDFC_QUALIFIED_VALUE, webTaskSvc.getWebElementAttribute(IDFDFC_QUALIVAL_TEXTFIELD, "value"));
        map.put(IDFDFC_TABLE_ID, webTaskSvc.getWebElementAttribute(IDFDFC_TABLEID_TEXTFIELD, "value"));
        map.put(IDFDFC_COLUMN_NAME, webTaskSvc.getWebElementAttribute(IDFDFC_COLNAME_TEXTFIELD, "value"));
        map.put(IDFDFC_DOMAIN_SET_ID, webTaskSvc.getWebElementAttribute(IDFDFC_DOMAINSETID_TEXTFIELD, "value"));
        map.put(IDFDFC_DOMAIN_VALUE_PURS_TYPE, webTaskSvc.getWebElementAttribute(IDFDFC_DOMAINVALPURTYPE_TEXTFIELD, "value"));
        map.put(IDFDFC_DATA_SOURCE_ID, webTaskSvc.getWebElementAttribute(IDFDFC_DATASOURCEID_TEXTFIELD, "value"));
        map.put(IDFDFC_DATA_STATUS, webTaskSvc.getWebElementAttribute(IDFDFC_DATASTATUS_TEXTFIELD, "value"));
        return map;
    }

    public InternalDomainDataFeedClassPage invokeDetailsView() {
        dmpGsPortalUtl.invokeDetailsView();
        return this;
    }

    public void saveDetails() {
        dmpGsPortalUtl.saveChanges();
    }

}
