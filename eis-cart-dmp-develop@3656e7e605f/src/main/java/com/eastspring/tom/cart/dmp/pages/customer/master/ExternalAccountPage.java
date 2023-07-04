package com.eastspring.tom.cart.dmp.pages.customer.master;

import com.eastspring.tom.cart.core.CartException;
import com.eastspring.tom.cart.core.CartExceptionType;
import com.eastspring.tom.cart.core.svc.WebTaskSvc;
import com.eastspring.tom.cart.dmp.pages.HomePage;
import com.eastspring.tom.cart.dmp.utl.DmpGsPortalUtl;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;

import java.util.HashMap;
import java.util.Map;

import static com.eastspring.tom.cart.constant.CommonLocators.GS_SAVE_BUTTON;
import static com.eastspring.tom.cart.dmp.mdl.GSUIFields.*;

public class ExternalAccountPage {

    private static final Logger LOGGER = LoggerFactory.getLogger(ExternalAccountPage.class);
    public static final String ENTER = "ENTER";

    private boolean mandatoryFlag = true;

    private void setMandatoryFlag(final boolean isInUpdateMode) {
        if (isInUpdateMode) {
            mandatoryFlag = false;
        }
    }

    //region Bean Declaration
    @Autowired
    private WebTaskSvc webTaskSvc;

    @Autowired
    private DmpGsPortalUtl dmpGsPortalUtl;

    @Autowired
    private HomePage homePage;

    public static final String EXT_ACCT_INST_NAME_LOCATOR = "cssSelector:div[id$='FinancialInstitutionName'] input";
    public static final String EXT_ACCT_INST_NAME_SEARCH_LOCATOR = "xpath://*[contains(@id,'FinancialInstitutionName')]//input/../../div[@role='button'][1]";
    public static final String EXT_ACCT_EXTERNAL_ACCOUNT_NME_LOCATOR = "cssSelector:div[id$='ExternalAccount.EISExternalAccountName'] input";
    public static final String EXT_ACCT_EXTERNAL_ACCOUNT_NO_LOCATOR = "cssSelector:div[id$='ExternalAccount.EISExternalSysAccountId'] input";
    public static final String EXT_ACCT_ROLE_TYPE_LOCATOR = "cssSelector:div[id$='ExternalAccount.EISExternalAccountRoleType'] input";
    public static final String EXT_ACCT_EXTERNAL_ACCOUNT_DATE_LOCATOR = "cssSelector:div[id$='ExternalAccount.EISExternalAccountDate'] input";


    public ExternalAccountPage invokeExternalAccountScreen() {
        LOGGER.debug("Navigating to External Account screen ");
        homePage.clickMenuDropdown()
                .selectMenu("Customer Master")
                .selectMenu("External Account");
        homePage.verifyGSTabDisplayed("External Account");
        return this;
    }

    public ExternalAccountPage invokeSetup() {
        dmpGsPortalUtl.invokeSetUpScreen(null, null, null);
        return this;
    }

    public ExternalAccountPage openExternalAccount(final String extAcctId) {
        dmpGsPortalUtl.filterTable("External Account Identifier", extAcctId, false);

        try {
            webTaskSvc.waitForElementToAppear(GS_SAVE_BUTTON, 20);
            LOGGER.debug("External Account [{}] is Opened to Add Details...", extAcctId);
        } catch (CartException e) {
            LOGGER.error("External Account [{}] is Not available in the System!!", extAcctId);
            throw new CartException(CartExceptionType.PROCESSING_FAILED, "External Account [{}] is Not available in the System!!", extAcctId);
        }
        return this;
    }

    public ExternalAccountPage fillExternalAccountDetails(final Map<String, String> dataMap, boolean isInUpdateMode) {
        try {
            this.setMandatoryFlag(isInUpdateMode);
            dmpGsPortalUtl.inputTextInLookUpField(EXT_ACCT_INST_NAME_SEARCH_LOCATOR, EXT_ACCT_INST_NAME, dataMap.get(EXT_ACCT_INST_NAME), mandatoryFlag);
            dmpGsPortalUtl.inputText(EXT_ACCT_EXTERNAL_ACCOUNT_NME_LOCATOR, dataMap.get(EXT_ACCT_EXTERNAL_ACCOUNT_NME), ENTER, mandatoryFlag);
            dmpGsPortalUtl.inputText(EXT_ACCT_EXTERNAL_ACCOUNT_NO_LOCATOR, dataMap.get(EXT_ACCT_EXTERNAL_ACCOUNT_NO), ENTER, mandatoryFlag);
            dmpGsPortalUtl.inputText(EXT_ACCT_ROLE_TYPE_LOCATOR, dataMap.get(EXT_ACCT_ROLE_TYPE), ENTER, false);
            dmpGsPortalUtl.inputText(EXT_ACCT_EXTERNAL_ACCOUNT_DATE_LOCATOR, dataMap.get(EXT_ACCT_EXTERNAL_ACCOUNT_DATE), ENTER, false);
            return this;
        } catch (Exception e) {
            LOGGER.error("Exception Occurred while filling External Account Details", e);
            throw new CartException(CartExceptionType.IO_ERROR, "Exception Occurred while filling External Account Details");
        }
    }


    public Map<String, String> getExternalAccountDetails() {
        Map<String, String> dataMap = new HashMap<>();
        try {
            dataMap.put(EXT_ACCT_INST_NAME, webTaskSvc.getWebElementAttribute(EXT_ACCT_INST_NAME_LOCATOR, "value"));
            dataMap.put(EXT_ACCT_EXTERNAL_ACCOUNT_NME, webTaskSvc.getWebElementAttribute(EXT_ACCT_EXTERNAL_ACCOUNT_NME_LOCATOR, "value"));
            dataMap.put(EXT_ACCT_EXTERNAL_ACCOUNT_NO, webTaskSvc.getWebElementAttribute(EXT_ACCT_EXTERNAL_ACCOUNT_NO_LOCATOR, "value"));
            dataMap.put(EXT_ACCT_ROLE_TYPE, webTaskSvc.getWebElementAttribute(EXT_ACCT_ROLE_TYPE_LOCATOR, "value"));
            dataMap.put(EXT_ACCT_EXTERNAL_ACCOUNT_DATE, webTaskSvc.getWebElementAttribute(EXT_ACCT_EXTERNAL_ACCOUNT_DATE_LOCATOR, "value"));
        } catch (Exception e) {
            LOGGER.error("Exception Occurred while reading Account Group Details", e);
            throw new CartException(CartExceptionType.IO_ERROR, "Exception Occurred while reading Account Group Details");
        }
        return dataMap;
    }
}
