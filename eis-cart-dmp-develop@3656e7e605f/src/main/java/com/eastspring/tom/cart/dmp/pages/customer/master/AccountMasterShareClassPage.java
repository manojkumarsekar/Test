package com.eastspring.tom.cart.dmp.pages.customer.master;

import com.eastspring.tom.cart.core.CartException;
import com.eastspring.tom.cart.core.CartExceptionType;
import com.eastspring.tom.cart.core.utl.DateTimeUtil;
import com.eastspring.tom.cart.dmp.pages.HomePage;
import com.eastspring.tom.cart.dmp.utl.DmpGsPortalUtl;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;

import java.util.HashMap;
import java.util.Map;

import static com.eastspring.tom.cart.dmp.mdl.GSUIFields.*;
import static com.eastspring.tom.cart.dmp.pages.customer.master.CustomerMasterOR.*;

public class AccountMasterShareClassPage {

    private static final Logger LOGGER = LoggerFactory.getLogger(AccountMasterShareClassPage.class);

    public static final String PROCESSING_FAILED = "Processing failed!!";
    public static final String VALUE = "value";
    public static final String ENTER = "ENTER";


    @Autowired
    private DmpGsPortalUtl dmpGsPortalUtl;

    @Autowired
    private AccountMasterPage accountMasterPage;

    @Autowired
    private DateTimeUtil dateTimeUtil;

    @Autowired
    private HomePage homePage;

    private String timeStamp;

    public void setTimeStamp(String timeStamp) {
        this.timeStamp = timeStamp;
    }

    public AccountMasterShareClassPage initializeShareClassData(Map<String, String> map) {
        this.setTimeStamp(dateTimeUtil.getTimestamp("DHMs"));
        return this;
    }

    public AccountMasterShareClassPage invokeAccountMasterShareclass(String portfolioName) {
        if (accountMasterPage.isAccountMasterPresent(portfolioName)) {
            LOGGER.error("Account Master is present with name [{}]", portfolioName);
            throw new CartException(CartExceptionType.INCOMPLETE_PARAMS, "Account Master is present with name [{}]", portfolioName);
        }
        dmpGsPortalUtl.invokeSetUpScreen("EISShareClassAccount", null, null);
        return this;
    }

    public void invokeAccountMasterShareclass() {
        LOGGER.debug("Navigating to Customer Master Screen");
        homePage.clickMenuDropdown()
                .selectMenu("Customer Master")
                .selectMenu("Account Master");
        homePage.verifyGSTabDisplayed("Account Master", 600);
        dmpGsPortalUtl.invokeSetUpScreen("EISShareClassAccount", null, null);
    }

    public AccountMasterShareClassPage fillShareclassDetails(Map<String, String> map) {
        try {
            dmpGsPortalUtl.inputText(SC_IDENTIFIER_PORTFOLIO_NAME, map.get(AM_PORTFOLIO_NAME),ENTER, true);
            dmpGsPortalUtl.inputText(SC_IDENTIFIER_BASE_CCY, map.get(AM_BASE_CCY),ENTER, true);
            dmpGsPortalUtl.inputText(SC_IDENTIFIER_INCEPTION_DATE, map.get(AM_INCEPTION_DATE),ENTER, true);
            dmpGsPortalUtl.inputText(SC_IDENTIFIER_SHARECLASS_TYPE, map.get(SC_SHARECLASS_TYPE),ENTER, true);
            dmpGsPortalUtl.inputText(SC_IDENTIFIER_ACTIVE_FLAG, map.get(AM_ACTIVE_FLAG),ENTER, false);
            dmpGsPortalUtl.inputText(SC_IDENTIFIER_BNP_PERF_FLAG, map.get(SC_BNP_PERF_FLAG),ENTER, true);
            return this;
        } catch (Exception e) {
            LOGGER.error(PROCESSING_FAILED, e);
            throw new CartException(CartExceptionType.PROCESSING_FAILED, PROCESSING_FAILED);
        }
    }

    public AccountMasterShareClassPage fillShareclassIdentifiersDetails(Map<String, String> map) {
        try {
            dmpGsPortalUtl.inputText(SC_IDENTIFIER_ALT_CRTS_ID, map.get(AM_ALTERNATE_CRTS_ID),ENTER, false);
            dmpGsPortalUtl.inputText(SC_IDENTIFIER_RDM_CODE, map.get(AM_RDM_CODE),ENTER, true);
            dmpGsPortalUtl.inputText(SC_IDENTIFIER_ISIN, map.get(SC_ISIN),ENTER, false);
            return this;
        } catch (Exception e) {
            LOGGER.error(PROCESSING_FAILED, e);
            throw new CartException(CartExceptionType.PROCESSING_FAILED, PROCESSING_FAILED);
        }
    }

    public AccountMasterShareClassPage fillShareclassXReferenceDetails(Map<String, String> map) {
        try {
            dmpGsPortalUtl.inputText(SC_IDENTIFIER_IRP_CODE, map.get(AM_IRP_CODE),ENTER, false);
            dmpGsPortalUtl.inputText(SC_IDENTIFIER_FUNDIPEDIA_FUND_ID, map.get(SC_FUNDIPEDIA_FUND_ID),ENTER, false);
            dmpGsPortalUtl.inputText(SC_IDENTIFIER_FUNDIPEDIA_SHARECLASS_ID, map.get(SC_FUNDIPEDIA_SC_ID),ENTER, false);
            dmpGsPortalUtl.inputText(SC_IDENTIFIER_PORTFOLIO_ISIN, map.get(AM_PORTFOLIO_ISIN),ENTER, false);
            dmpGsPortalUtl.inputText(SC_IDENTIFIER_FUNDIPEDIA_PORTFOLIO_ID, map.get(SC_FUNDIPEDIA_PORTFOLIO_ID),ENTER, false);
            return this;
        } catch (Exception e) {
            LOGGER.error(PROCESSING_FAILED, e);
            throw new CartException(CartExceptionType.PROCESSING_FAILED, PROCESSING_FAILED);
        }
    }

    public AccountMasterShareClassPage fillShareclassBenchmarkDetails(Map<String, String> map) {
        try {
            dmpGsPortalUtl.inputTextInLookUpField(SC_IDENTIFIER_PRIMARY_BM_SRCH_BTN, map.get(SC_PRIMARY_BM), true);
            return this;
        } catch (Exception e) {
            LOGGER.error(PROCESSING_FAILED, e);
            throw new CartException(CartExceptionType.PROCESSING_FAILED, PROCESSING_FAILED);
        }
    }

    public Map<String, String> getShareClassDetails() {
        Map<String, String> dataMap = new HashMap<>();
        Map<String, String> shareclassDetails = this.getShareclassFundDetails();
        Map<String, String> shareclassIdentifiers = this.getShareclassIdentifiersDetails();
        Map<String, String> shareclassXReference = this.getShareclassXReferenceDetails();
        Map<String, String> shareclassBMDetailss = this.getShareclassBenchmarkDetails();


        dataMap.putAll(shareclassDetails);
        dataMap.putAll(shareclassIdentifiers);
        dataMap.putAll(shareclassXReference);
        dataMap.putAll(shareclassBMDetailss);

        return dataMap;
    }

    public Map<String, String> getShareclassFundDetails() {
        Map<String, String> dataMap = new HashMap<>();

        dataMap.put(AM_PORTFOLIO_NAME,dmpGsPortalUtl.getWebElementAttribute(SC_IDENTIFIER_PORTFOLIO_NAME, VALUE, false));
        dataMap.put(AM_BASE_CCY,dmpGsPortalUtl.getWebElementAttribute(SC_IDENTIFIER_BASE_CCY, VALUE, false));
        dataMap.put(AM_INCEPTION_DATE,dmpGsPortalUtl.getWebElementAttribute(SC_IDENTIFIER_INCEPTION_DATE, VALUE, false));
        dataMap.put(SC_SHARECLASS_TYPE,dmpGsPortalUtl.getWebElementAttribute(SC_IDENTIFIER_SHARECLASS_TYPE, VALUE, false));
        dataMap.put(AM_ACTIVE_FLAG,dmpGsPortalUtl.getWebElementAttribute(SC_IDENTIFIER_ACTIVE_FLAG, VALUE, false));
        dataMap.put(SC_BNP_PERF_FLAG,dmpGsPortalUtl.getWebElementAttribute(SC_IDENTIFIER_BNP_PERF_FLAG, VALUE, false));
        return dataMap;
    }

    public Map<String, String> getShareclassIdentifiersDetails() {
        Map<String, String> dataMap = new HashMap<>();

        dataMap.put(AM_ALTERNATE_CRTS_ID, dmpGsPortalUtl.getWebElementAttribute(SC_IDENTIFIER_ALT_CRTS_ID, VALUE, false));
        dataMap.put(AM_RDM_CODE, dmpGsPortalUtl.getWebElementAttribute(SC_IDENTIFIER_RDM_CODE, VALUE, false));
        dataMap.put(SC_ISIN, dmpGsPortalUtl.getWebElementAttribute(SC_IDENTIFIER_ISIN , VALUE, false));
        return dataMap;
    }

    public Map<String, String> getShareclassXReferenceDetails() {
        Map<String, String> dataMap = new HashMap<>();

        dataMap.put(AM_IRP_CODE,dmpGsPortalUtl.getWebElementAttribute(SC_IDENTIFIER_IRP_CODE, VALUE, false));
        dataMap.put(SC_FUNDIPEDIA_FUND_ID,dmpGsPortalUtl.getWebElementAttribute(SC_IDENTIFIER_FUNDIPEDIA_FUND_ID, VALUE, false));
        dataMap.put(SC_FUNDIPEDIA_SC_ID,dmpGsPortalUtl.getWebElementAttribute(SC_IDENTIFIER_FUNDIPEDIA_SHARECLASS_ID, VALUE, false));
        dataMap.put(AM_PORTFOLIO_ISIN,dmpGsPortalUtl.getWebElementAttribute(SC_IDENTIFIER_PORTFOLIO_ISIN, VALUE, false));
        dataMap.put(SC_FUNDIPEDIA_PORTFOLIO_ID,dmpGsPortalUtl.getWebElementAttribute(SC_IDENTIFIER_FUNDIPEDIA_PORTFOLIO_ID, VALUE, false));
        return dataMap;
    }


    public Map<String, String> getShareclassBenchmarkDetails() {
        Map<String, String> dataMap = new HashMap<>();

        dataMap.put(SC_PRIMARY_BM,dmpGsPortalUtl.getWebElementAttribute(SC_IDENTIFIER_PRIMARY_BM, VALUE, false));
        return dataMap;
    }


}


