package com.eastspring.tom.cart.dmp.pages.generic.setup;

import com.eastspring.tom.cart.core.CartException;
import com.eastspring.tom.cart.core.CartExceptionType;
import com.eastspring.tom.cart.core.svc.StateSvc;
import com.eastspring.tom.cart.core.svc.ThreadSvc;
import com.eastspring.tom.cart.core.svc.WebTaskSvc;
import com.eastspring.tom.cart.core.utl.DateTimeUtil;
import com.eastspring.tom.cart.core.utl.FormatterUtil;
import com.eastspring.tom.cart.dmp.pages.HomePage;
import com.eastspring.tom.cart.dmp.steps.DmpGsPortalSteps;
import com.eastspring.tom.cart.dmp.utl.DmpGsPortalUtl;
import org.h2.util.StringUtils;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;

import java.util.LinkedHashMap;
import java.util.Set;

import static com.eastspring.tom.cart.dmp.mdl.GSUIFields.AGD_GROUP_NAME;
import static com.eastspring.tom.cart.dmp.mdl.GSUIFields.RT_CONFIG_ACCOUNT_GROUP_NAME;
import static com.eastspring.tom.cart.dmp.mdl.GSUIFields.RT_CONFIG_CROSS_REFERENCE_GROUP;
import static com.eastspring.tom.cart.dmp.mdl.GSUIFields.RT_CONFIG_DESCRIPTION;
import static com.eastspring.tom.cart.dmp.mdl.GSUIFields.RT_CONFIG_ISSUE_GROUP_NAME;
import static com.eastspring.tom.cart.dmp.mdl.GSUIFields.RT_CONFIG_VENDOR_REQUEST_TYPE;

public class RequestTypeConfigPage {

    private static final Logger LOGGER = LoggerFactory.getLogger(RequestTypeConfigPage.class);

    private static final String RT_CONFIG_ACCOUNT_GROUP_NAME_VAR = "xpath://div[starts-with(@id,'EISRequestTypeConfiguration')][contains(@id,'EISAccountGroupName')]";
    private static final String RT_CONFIG_ISSUE_GROUP_NAME_VAR = "xpath://div[starts-with(@id,'EISRequestTypeConfiguration')][contains(@id,'InstrumentGroupName')]";
    private static final String RT_CONFIG_CROSS_REF_GROUP_VAR = "xpath://div[starts-with(@id,'EISRequestTypeConfiguration')][contains(@id,'EISCRGRGroupName')]";

    private static final String RT_CONFIG_ACCOUNT_GROUP_NAME_LOOKUP = RT_CONFIG_ACCOUNT_GROUP_NAME_VAR + "//div[contains(@class,'gsLookupField')]/div[@role='button']";
    private static final String RT_CONFIG_ISSUE_GROUP_NAME_LOOKUP = RT_CONFIG_ISSUE_GROUP_NAME_VAR + "//div[contains(@class,'gsLookupField')]/div[@role='button']";
    private static final String RT_CONFIG_CROSS_REF_GROUP_LOOKUP = RT_CONFIG_CROSS_REF_GROUP_VAR + "//div[contains(@class,'gsLookupField')]/div[@role='button']";

    private static final String RT_CONFIG_ACCOUNT_GROUP_NAME_INPUT = RT_CONFIG_ACCOUNT_GROUP_NAME_VAR + "//input";
    private static final String RT_CONFIG_ISSUE_GROUP_NAME_INPUT = RT_CONFIG_ISSUE_GROUP_NAME_VAR + "//input";
    private static final String RT_CONFIG_CROSS_REF_GROUP_INPUT = RT_CONFIG_CROSS_REF_GROUP_VAR + "//input";

    private static final String RT_CONFIG_VENDOR_REQUEST_TYPE_INPUT = "xpath://div[starts-with(@id,'EISRequestTypeConfiguration')][contains(@id,'EISVRT1VendorRequestType')]//input";
    private static final String RT_CONFIG_DESCRIPTION_INPUT = "xpath://div[starts-with(@id,'EISRequestTypeConfiguration')][contains(@id,'EISVRT1CommentText')]//textarea";
    public static final String VALUE = "value";
    public static final String ENTER = "ENTER";
    public static final String NULL = "null";

    //region Bean Declaration
    @Autowired
    private StateSvc stateSvc;

    @Autowired
    private FormatterUtil formatter;

    @Autowired
    private DmpGsPortalUtl dmpGsPortalUtl;

    @Autowired
    private ThreadSvc threadSvc;

    @Autowired
    private HomePage homePage;

    @Autowired
    private DmpGsPortalSteps dmpGsPortalSteps;

    @Autowired
    private DateTimeUtil dateTimeUtil;

    @Autowired
    private WebTaskSvc webTaskSvc;
    //endregion

    private boolean mandatoryFlag = true;

    private void setMandatoryFlag(final boolean isAppendModeOn) {
        if (isAppendModeOn) {
            mandatoryFlag = false;
        }
    }

    public RequestTypeConfigPage invokeRequestTypeConfigScreen() {
        LOGGER.debug("Navigating to Request Type Configuration");
        homePage.clickMenuDropdown()
                .selectMenu("Generic Setup")
                .selectMenu("Request Type Configuration");
        homePage.verifyGSTabDisplayed("Request Type Configuration");
        return this;
    }

    public RequestTypeConfigPage invokeSetup() {
        dmpGsPortalUtl.invokeSetUpScreen(null, null, null);
        return this;
    }

    public RequestTypeConfigPage fillRequestTypeConfigDetails(final LinkedHashMap<String, String> dataMap, boolean isInUpdateMode) {
        try {

            this.setMandatoryFlag(isInUpdateMode);

            if (!StringUtils.isNullOrEmpty(dataMap.get(RT_CONFIG_ACCOUNT_GROUP_NAME))) {
                if (isInUpdateMode && NULL.equals(dataMap.get(RT_CONFIG_ACCOUNT_GROUP_NAME))) {
                    dmpGsPortalUtl.clearLookupField(RT_CONFIG_ACCOUNT_GROUP_NAME_INPUT);
                } else {
                    dmpGsPortalUtl.inputTextInLookUpField(RT_CONFIG_ACCOUNT_GROUP_NAME_LOOKUP, AGD_GROUP_NAME, dataMap.get(RT_CONFIG_ACCOUNT_GROUP_NAME), mandatoryFlag);
                }
            }

            if (!StringUtils.isNullOrEmpty(dataMap.get(RT_CONFIG_ISSUE_GROUP_NAME))) {
                if (isInUpdateMode && NULL.equals(dataMap.get(RT_CONFIG_ISSUE_GROUP_NAME))) {
                    dmpGsPortalUtl.clearLookupField(RT_CONFIG_ISSUE_GROUP_NAME_INPUT);
                } else {
                    dmpGsPortalUtl.inputTextInLookUpField(RT_CONFIG_ISSUE_GROUP_NAME_LOOKUP, dataMap.get(RT_CONFIG_ISSUE_GROUP_NAME), mandatoryFlag);
                }
            }

            if (!StringUtils.isNullOrEmpty(dataMap.get(RT_CONFIG_CROSS_REFERENCE_GROUP))) {
                if (isInUpdateMode && NULL.equals(dataMap.get(RT_CONFIG_CROSS_REFERENCE_GROUP))) {
                    dmpGsPortalUtl.clearLookupField(RT_CONFIG_CROSS_REF_GROUP_INPUT);
                } else {
                    dmpGsPortalUtl.inputTextInLookUpField(RT_CONFIG_CROSS_REF_GROUP_LOOKUP, dataMap.get(RT_CONFIG_CROSS_REFERENCE_GROUP), mandatoryFlag);
                }
            }
            dmpGsPortalUtl.inputText(RT_CONFIG_VENDOR_REQUEST_TYPE_INPUT, dataMap.get(RT_CONFIG_VENDOR_REQUEST_TYPE), ENTER, mandatoryFlag);
            dmpGsPortalUtl.inputText(RT_CONFIG_DESCRIPTION_INPUT, dataMap.get(RT_CONFIG_DESCRIPTION), null, false);

        } catch (Exception e) {
            LOGGER.error("Exception Occurred while filling Request Type Config Details", e);
            throw new CartException(CartExceptionType.IO_ERROR, "Exception Occurred while filling Request Type Config Details");
        }
        return this;
    }

    public LinkedHashMap<String, String> getRequestTypeConfigDetails() {
        LinkedHashMap<String, String> dataMap = new LinkedHashMap<>();
        try {
            dataMap.put(RT_CONFIG_ACCOUNT_GROUP_NAME, webTaskSvc.getWebElementAttribute(RT_CONFIG_ACCOUNT_GROUP_NAME_INPUT, VALUE));
            dataMap.put(RT_CONFIG_ISSUE_GROUP_NAME, webTaskSvc.getWebElementAttribute(RT_CONFIG_ISSUE_GROUP_NAME_INPUT, VALUE));
            dataMap.put(RT_CONFIG_CROSS_REFERENCE_GROUP, webTaskSvc.getWebElementAttribute(RT_CONFIG_CROSS_REF_GROUP_INPUT, VALUE));
            dataMap.put(RT_CONFIG_VENDOR_REQUEST_TYPE, webTaskSvc.getWebElementAttribute(RT_CONFIG_VENDOR_REQUEST_TYPE_INPUT, VALUE));
            dataMap.put(RT_CONFIG_DESCRIPTION, webTaskSvc.getWebElementAttribute(RT_CONFIG_DESCRIPTION_INPUT, VALUE));
        } catch (Exception e) {
            LOGGER.error("Exception Occurred while reading Request Type Config Details", e);
            throw new CartException(CartExceptionType.IO_ERROR, "Exception Occurred while reading Request Type Config Details");
        }
        return dataMap;
    }


    public RequestTypeConfigPage openRequestTypeConfig(final LinkedHashMap<String, String> dataMap) {

        if (dataMap.isEmpty()) {
            LOGGER.error("Cannot open Request Type Config details with empty values");
            throw new CartException(CartExceptionType.PROCESSING_FAILED, "Cannot open Request Type Config details with empty values");
        }
        this.invokeRequestTypeConfigScreen();

        Set<String> keySet = dataMap.keySet();
        for (String key : keySet) {
            if (RT_CONFIG_VENDOR_REQUEST_TYPE.equals(key)) {
                dmpGsPortalUtl.filterTable(key, dataMap.get(key), true);
            } else if (RT_CONFIG_DESCRIPTION.equals(key)) {
                dmpGsPortalUtl.filterTable(key, dataMap.get(key), false);
            } else {
                dmpGsPortalUtl.filterTable("**" + key, dataMap.get(key), false);
            }
            threadSvc.sleepSeconds(1);
        }
        return this;
    }

    public boolean verifyRequestTypeConfigIsCreated(final LinkedHashMap<String, String> dataMap) {
        this.openRequestTypeConfig(dataMap);

        final String value = dataMap.entrySet().stream().findFirst().get().getValue();
        boolean searchRecordAvailable = dmpGsPortalUtl.isSearchRecordAvailable(value);

        dmpGsPortalSteps.closeActiveGsTab();
        return searchRecordAvailable;
    }


}
