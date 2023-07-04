package com.eastspring.tom.cart.dmp.pages.issue;

import com.eastspring.tom.cart.core.CartException;
import com.eastspring.tom.cart.core.CartExceptionType;
import com.eastspring.tom.cart.core.steps.WebSteps;
import com.eastspring.tom.cart.core.svc.StateSvc;
import com.eastspring.tom.cart.core.svc.ThreadSvc;
import com.eastspring.tom.cart.core.svc.WebTaskSvc;
import com.eastspring.tom.cart.core.utl.DateTimeUtil;
import com.eastspring.tom.cart.core.utl.FormatterUtil;
import com.eastspring.tom.cart.dmp.pages.HomePage;
import com.eastspring.tom.cart.dmp.steps.DmpGsPortalSteps;
import com.eastspring.tom.cart.dmp.utl.DmpGsPortalUtl;
import org.openqa.selenium.JavascriptExecutor;
import org.openqa.selenium.WebElement;
import org.openqa.selenium.support.ui.ExpectedConditions;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;

import java.util.HashMap;
import java.util.Map;

import static com.eastspring.tom.cart.constant.CommonLocators.GS_ADD_DETAILS_BUTTON;
import static com.eastspring.tom.cart.constant.CommonLocators.GS_TAB;
import static com.eastspring.tom.cart.dmp.mdl.GSUIFields.*;
import static com.eastspring.tom.cart.dmp.pages.issue.IssueOR.ISSUE_EXCHANGE_NAME_LOCATOR;

public class IssuePage {

    private static final Logger LOGGER = LoggerFactory.getLogger(IssuePage.class);

    @Autowired
    private WebSteps webSteps;

    @Autowired
    private WebTaskSvc webTaskSvc;

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

    //constants
    public static final String SEARCH_TYPE = "Issue";
    public static final String INST_LEVEL_IDENTIFIERS_TAB = "Instrument Level Identifiers";
    public static final String DESCRIPTION_TAB = "Description";
    public static final String INST_CLASSIFICATION_TAB = "Instrument Classifications";
    public static final String INSTITUTION_ROLE_TAB = "Institution Roles";
    public static final String MARKET_LISTING_TAB = "Market Listing";
    public static final String CAPITALIZATION_TAB = "Capitalization";
    public static final String EXTENDED_IDENTIFIER_TAB = "Extended Identifiers";
    public static final String RELATED_INST_TAB = "Related Instrument";
    public static final String ISSUE_COMMENTS_TAB = "Issue Comments";
    public static final String INSTRUMENT_RATING_TAB = "Instrument Ratings";
    public static final String CLASSIFICATION_TAB = "Classification";
    public static final String FA_ISSUE_ATTR_TAB = "Fundapps Issue Attributes";
    public static final String FA_MIC_LIST_TAB = "Fundapps MIC List";


    private boolean mandatoryFlag = true;

    private void setMandatoryFlag(final boolean isAppendModeOn) {
        if (isAppendModeOn) {
            mandatoryFlag = false;
        }
    }

    public IssuePage searchIssue(String searchValue) {
        try {
            homePage.globalSearchAndWaitTillSuccess(searchValue, SEARCH_TYPE, 20);
        } catch (Exception e) {
        }
        return this;
    }

    public IssuePage navigateToIssueScreen() {
        LOGGER.debug("Navigating to Issue Screen");
        homePage.clickMenuDropdown()
                .selectMenu("Security Master")
                .selectMenu("Issue");
        homePage.verifyGSTabDisplayed("Issue");
        return this;
    }

    public IssuePage invokeSetup() {
        dmpGsPortalUtl.invokeSetUpScreen(null, null, null);
        return this;
    }

    public boolean isIssuePresent(String searchValue) {
        searchIssue(searchValue);
        threadSvc.sleepSeconds(2);
        return dmpGsPortalUtl.isSearchRecordAvailable(searchValue);
    }

    public IssuePage invokeIssue(String issueName) {
        isIssuePresent(issueName);
        dmpGsPortalUtl.invokeSetUpScreen(null, null, null);
        return this;
    }


    public IssuePage clickMarketLevelIdentifier(String linkName) {
        webTaskSvc.scrollElementIntoView(IssueOR.ISSUE_MARKET_lISTING_LOCATOR);
        dmpGsPortalUtl.selectGSTab(MARKET_LISTING_TAB);
        webTaskSvc.click( formatter.format(IssueOR.ISSUE_MARKET_LEVEL_IDENTIFIER,linkName));
        return this;
    }

    public IssuePage invokeAddNewDetails(String tabName) {
        dmpGsPortalUtl.selectGSTab(tabName);
        dmpGsPortalUtl.addNewDetails();
        threadSvc.sleepSeconds(1);
        return this;
    }

    private void navigateToMarketListing(){
        webTaskSvc.scrollElementIntoView(IssueOR.ISSUE_MARKET_lISTING_LOCATOR);
        dmpGsPortalUtl.selectGSTab(MARKET_LISTING_TAB);
        webTaskSvc.click(IssueOR.ISSUE_MARKET_lISTING_LINK_LOCATOR);
        threadSvc.sleepSeconds(1);
        webTaskSvc.getWebDriverWait(10).until(ExpectedConditions.
                visibilityOfElementLocated(webTaskSvc.getByReference(ISSUE_EXCHANGE_NAME_LOCATOR)));
    }

//    private void scrollToTab(String tabName){
//        WebElement tab = webTaskSvc.getWebElementRef(formatter.format(GS_TAB, tabName));
//        webTaskSvc.getJavaScriptExecutor().executeScript("arguments[0].scrollLeft = arguments[0].offsetWidth",tab);
//    }

    public IssuePage fillInstrumentDetails(Map<String, String> map, boolean isInUpdateMode) {
        try {
            this.setMandatoryFlag(isInUpdateMode);
            dmpGsPortalUtl.inputText(IssueOR.ISSUE_INST_NAME_LOCATOR, map.get(ISSUE_INST_NAME), "ENTER", mandatoryFlag);
            dmpGsPortalUtl.inputText(IssueOR.ISSUE_INST_DESC_LOCATOR, map.get(ISSUE_INST_DESC), "ENTER", false);
            dmpGsPortalUtl.inputText(IssueOR.ISSUE_PREF_IDEN_TYPE_LOCATOR, map.get(ISSUE_PREF_IDEN_TYPE), "ENTER", false);
            dmpGsPortalUtl.inputText(IssueOR.ISSUE_PREF_IDEN_VALUE_LOCATOR, map.get(ISSUE_PREF_IDEN_VALUE), "ENTER", false);
            dmpGsPortalUtl.inputText(IssueOR.ISSUE_INST_TYPE_LOCATOR, map.get(ISSUE_INST_TYPE), "ENTER", mandatoryFlag);
            dmpGsPortalUtl.inputText(IssueOR.ISSUE_DENOM_CCY_LOCATOR, map.get(ISSUE_DENOM_CCY), "ENTER", false);
            dmpGsPortalUtl.inputText(IssueOR.ISSUE_PRICE_METHOD_LOCATOR, map.get(ISSUE_PRICE_METHOD), "ENTER", false);
            dmpGsPortalUtl.inputText(IssueOR.ISSUE_DATE_LOCATOR, map.get(ISSUE_DATE), "ENTER", false);
            dmpGsPortalUtl.inputText(IssueOR.ISSUE_MATURITY_DATE_LOCATOR, map.get(ISSUE_MATURITY_DATE), "ENTER", false);
            dmpGsPortalUtl.inputText(IssueOR.ISSUE_INST_SYSTEM_STATUS_LOCATOR, map.get(ISSUE_INST_SYSTEM_STATUS), "ENTER", mandatoryFlag);
            dmpGsPortalUtl.inputText(IssueOR.ISSUE_STATUS_REASON_LOCATOR, map.get(ISSUE_STATUS_REASON), "ENTER", false);
            dmpGsPortalUtl.inputText(IssueOR.ISSUE_WHEN_USED_LOCATOR, map.get(ISSUE_WHEN_USED), "ENTER", false);
            dmpGsPortalUtl.inputText(IssueOR.ISSUE_CREATED_ON_LOCATOR, map.get(ISSUE_CREATED_ON), "ENTER", false);
            dmpGsPortalUtl.inputText(IssueOR.ISSUE_ACTIVE_UNTIL_LOCATOR, map.get(ISSUE_ACTIVE_UNTIL), "ENTER", false);
            dmpGsPortalUtl.inputText(IssueOR.ISSUE_FINAL_MATURITY_DATE_LOCATOR, map.get(ISSUE_FINAL_MATURITY_DATE), "ENTER", false);
            dmpGsPortalUtl.inputText(IssueOR.ISSUE_SOURCE_CCY_LOCATOR, map.get(ISSUE_SOURCE_CCY), "ENTER", false);
            dmpGsPortalUtl.inputText(IssueOR.ISSUE_TARGET_CCY_LOCATOR, map.get(ISSUE_TARGET_CCY), "ENTER", false);
            dmpGsPortalUtl.inputText(IssueOR.ISSUE_NOTIONAL_INDICATOR_LOCATOR, map.get(ISSUE_NOTIONAL_INDICATOR), "ENTER", false);
            dmpGsPortalUtl.inputText(IssueOR.ISSUE_ILLIQUIDITY_INDICATOR_LOCATOR, map.get(ISSUE_ILLIQUIDITY_INDICATOR), "ENTER", false);
            dmpGsPortalUtl.inputText(IssueOR.ISSUE_PROXY_IN_BRS_LOCATOR, map.get(ISSUE_PROXY_IN_BRS), "ENTER", false);
            return this;
        } catch (Exception e) {
            LOGGER.error("Processing failed while adding Instrument Details", e);
            throw new CartException(CartExceptionType.PROCESSING_FAILED, "Processing failed while adding Instrument Details");
        }
    }


    public IssuePage fillInstLevelIdentifier(Map<String, String> map) {
        try {
            dmpGsPortalUtl.selectGSTab(INST_LEVEL_IDENTIFIERS_TAB);
            dmpGsPortalUtl.inputText(IssueOR.ISSUE_CUSIP_LOCATOR, map.get(ISSUE_CUSIP), "ENTER", false);
            dmpGsPortalUtl.inputText(IssueOR.ISSUE_ISIN_LOCATOR, map.get(ISSUE_ISIN), "ENTER", false);
            return this;
        } catch (Exception e) {
            LOGGER.error("Processing failed while adding Instrument Level Identifiers Details", e);
            throw new CartException(CartExceptionType.PROCESSING_FAILED, "Processing failed while adding Instrument Level Identifiers Details");
        }
    }

    public IssuePage fillDescription(Map<String, String> map, boolean isInUpdateMode) {
        try {
            this.setMandatoryFlag(isInUpdateMode);
            dmpGsPortalUtl.inputText(IssueOR.ISSUE_DESC_INSTRUMENT_NAME, map.get(ISSUE_INST_NAME), "", mandatoryFlag);
            dmpGsPortalUtl.inputText(IssueOR.ISSUE_DESC_INSTRUMENT_DESC, map.get(ISSUE_DESC_INST_DESC), "ENTER", false);
            dmpGsPortalUtl.inputText(IssueOR.ISSUE_SOURCE_OF_DESC_LOCATOR, map.get(ISSUE_SOURCE_OF_DESC), "ENTER", mandatoryFlag);
            dmpGsPortalUtl.inputText(IssueOR.ISSUE_INST_DESC_USAGE_LOCATOR, map.get(ISSUE_INST_DESC_USAGE), "ENTER", mandatoryFlag);
            dmpGsPortalUtl.inputText(IssueOR.ISSUE_INST_DESC_LANG_LOCATOR, map.get(ISSUE_INST_DESC_LANG), "ENTER", mandatoryFlag);
            return this;
        } catch (Exception e) {
            LOGGER.error("Processing failed while adding Description", e);
            throw new CartException(CartExceptionType.PROCESSING_FAILED, "Processing failed while adding Description");
        }
    }

    public IssuePage fillInstClassification(Map<String, String> map) {
        try {
            dmpGsPortalUtl.selectGSTab(INST_CLASSIFICATION_TAB);
            dmpGsPortalUtl.inputText(IssueOR.ISSUE_CLASSI_SET_LOCATOR, map.get(ISSUE_CLASSI_SET), "ENTER", false);
            dmpGsPortalUtl.inputText(IssueOR.ISSUE_CLASSI_VALUE_LOCATOR, map.get(ISSUE_CLASSI_VALUE), "ENTER", false);
            dmpGsPortalUtl.inputText(IssueOR.ISSUE_CLASSI_PUC_LOCATOR, map.get(ISSUE_CLASSI_PUC), "ENTER", false);
            return this;
        } catch (Exception e) {
            LOGGER.error("Processing failed while adding Instrument classification Details", e);
            throw new CartException(CartExceptionType.PROCESSING_FAILED, "Processing failed while adding Instrument classification Details");
        }
    }

    public IssuePage fillInstitutionRole(Map<String, String> map) {
        try {
            dmpGsPortalUtl.selectGSTab(INSTITUTION_ROLE_TAB);
            dmpGsPortalUtl.inputText(IssueOR.ISSUE_RELATION_PURPOSE_LOCATOR, map.get(ISSUE_RELATION_PURPOSE), "ENTER", false);
            return this;
        } catch (Exception e) {
            LOGGER.error("Processing failed while adding Institution Role Details", e);
            throw new CartException(CartExceptionType.PROCESSING_FAILED, "Processing failed while adding Institution Role Details");
        }
    }

    public IssuePage fillMarketListing(Map<String, String> map) {
        try {
            dmpGsPortalUtl.selectGSTab(MARKET_LISTING_TAB);
            webTaskSvc.waitForElementToAppear(ISSUE_EXCHANGE_NAME_LOCATOR, 120);
            dmpGsPortalUtl.inputTextInLookUpField(ISSUE_EXCHANGE_NAME_LOCATOR, map.get(ISSUE_EXCHANGE_NAME), false);
            dmpGsPortalUtl.inputText(IssueOR.ISSUE_PRIMARY_MKT_INDICATOR_LOCATOR, map.get(ISSUE_PRIMARY_MKT_INDICATOR), "ENTER", false);
            dmpGsPortalUtl.inputText(IssueOR.ISSUE_MARKET_STATUS_LOCATOR, map.get(ISSUE_MARKET_STATUS), "ENTER", false);
            dmpGsPortalUtl.inputText(IssueOR.ISSUE_TRADING_CCY_LOCATOR, map.get(ISSUE_TRADING_CCY), "ENTER", false);
            dmpGsPortalUtl.inputText(IssueOR.ISSUE_MKT_LISTING_CREATED_ON_LOCATOR, map.get(ISSUE_MKT_LISTING_CREATEDON), "ENTER", false);
            dmpGsPortalUtl.inputText(IssueOR.ISSUE_RDM_CODE_LOCATOR, map.get(ISSUE_MKT_LISTING_RDMCODE), "ENTER", false);
            dmpGsPortalUtl.inputText(IssueOR.ISSUE_BB_GLOBAL_LOCATOR, map.get(ISSUE_MKT_LISTING_BBGLOBAL), "ENTER", false);
            dmpGsPortalUtl.inputText(IssueOR.ISSUE_TICKER_LOCATOR, map.get(ISSUE_MKT_LISTING_TICKER), "ENTER", false);
            dmpGsPortalUtl.inputText(IssueOR.ISSUE_REUTERS_TICKER_LOCATOR, map.get(ISSUE_MKT_LISTING_REUTERS_TICKER), "ENTER", false);
            dmpGsPortalUtl.inputText(IssueOR.ISSUE_RIC_LOCATOR, map.get(ISSUE_MKT_LISTING_RIC), "ENTER", false);
            return this;
        } catch (Exception e) {
            LOGGER.error("Processing failed while adding Market Listing Details", e);
            throw new CartException(CartExceptionType.PROCESSING_FAILED, "Processing failed while adding  Market Listing Details");
        }
    }

    public IssuePage fillMarketLevelIdentifiersUnderListing(Map<String, String> map) {
        try {
            dmpGsPortalUtl.inputText(IssueOR.ISSUE_RDM_CODE_LOCATOR, map.get(ISSUE_MKT_LISTING_RDMCODE), "ENTER", false);
            dmpGsPortalUtl.inputText(IssueOR.ISSUE_BB_GLOBAL_LOCATOR, map.get(ISSUE_MKT_LISTING_BBGLOBAL), "ENTER", false);
            dmpGsPortalUtl.inputText(IssueOR.ISSUE_TICKER_LOCATOR, map.get(ISSUE_MKT_LISTING_TICKER), "ENTER", false);
            dmpGsPortalUtl.inputText(IssueOR.ISSUE_REUTERS_TICKER_LOCATOR, map.get(ISSUE_MKT_LISTING_REUTERS_TICKER), "ENTER", false);
            dmpGsPortalUtl.inputText(IssueOR.ISSUE_RIC_LOCATOR, map.get(ISSUE_MKT_LISTING_RIC), "ENTER", false);
            dmpGsPortalUtl.inputText(IssueOR.ISSUE_RCR_MNG_CODE_LOCATOR, map.get(ISSUE_MKT_LISTING_RCR_MNGCODE), "ENTER", false);
            dmpGsPortalUtl.inputText(IssueOR.ISSUE_RCR_ESJP_CODE_LOCATOR, map.get(ISSUE_MKT_LISTING_RCR_EJSPCODE), "ENTER", false);
            dmpGsPortalUtl.inputText(IssueOR.ISSUE_RCR_ESGA_CODE_LOCATOR, map.get(ISSUE_MKT_LISTING_RCR_ESGACODE), "ENTER", false);
            dmpGsPortalUtl.inputText(IssueOR.ISSUE_RCR_BOCI_CODE_LOCATOR, map.get(ISSUE_MKT_LISTING_RCR_BOCICODE), "ENTER", false);
            dmpGsPortalUtl.inputText(IssueOR.ISSUE_RCR_EIMKOR_CODE_LOCATOR, map.get(ISSUE_MKT_LISTING_RCR_EIMKIRCODE), "ENTER", false);
            dmpGsPortalUtl.inputText(IssueOR.ISSUE_RCR_PPMJNAM_CODE_LOCATOR, map.get(ISSUE_MKT_LISTING_RCR_PPMJNAMCODE), "ENTER", false);
            dmpGsPortalUtl.inputText(IssueOR.ISSUE_RCR_TMBAM_CODE_LOCATOR, map.get(ISSUE_MKT_LISTING_RCR_TMBAMCODE), "ENTER", false);
            dmpGsPortalUtl.inputText(IssueOR.ISSUE_RCR_WFOE_CODE_LOCATOR, map.get(ISSUE_MKT_LISTING_RCR_WFOECODE), "ENTER", false);
            dmpGsPortalUtl.inputText(IssueOR.ISSUE_RCR_THANA_CODE_LOCATOR, map.get(ISSUE_MKT_LISTING_RCR_THANACODE), "ENTER", false);
            dmpGsPortalUtl.inputText(IssueOR.ISSUE_BRS_BCUSIP_LOCATOR, map.get(ISSUE_MKT_LISTING_BRS_BCUSIP), "ENTER", false);
            dmpGsPortalUtl.inputText(IssueOR.ISSUE_BNP_BBGLOBAL_LOCATOR, map.get(ISSUE_MKT_LISTING_BNP_BBGLOBAL), "ENTER", false);
            dmpGsPortalUtl.inputText(IssueOR.ISSUE_MNG_BCUSIP_LOCATOR, map.get(ISSUE_MKT_LISTING_MNG_BCUSIP), "ENTER", false);
            dmpGsPortalUtl.inputText(IssueOR.ISSUE_RCR_WFOECCB_CODE_LOCATOR, map.get(ISSUE_MKT_LISTING_RCR_WFOECCBCODE), "ENTER", false);
            dmpGsPortalUtl.inputText(IssueOR.ISSUE_RCR_ROBOCOLL_CODE_LOCATOR, map.get(ISSUE_MKT_LISTING_RCR_ROBOCOLLCODE), "ENTER", false);
            dmpGsPortalUtl.inputText(IssueOR.ISSUE_BNP_HIPEXT21D_LOCATOR, map.get(ISSUE_MKT_LISTING_BNP_HIPEXT21D), "ENTER", false);
            dmpGsPortalUtl.inputText(IssueOR.ISSUE_BNP_LISTINGID_LOCATOR, map.get(ISSUE_MKT_LISTING_BNP_LISTINGID), "ENTER", false);
            dmpGsPortalUtl.inputText(IssueOR.ISSUE_BB_ID_MIC_PRIM_EXCH_LOCATOR, map.get(ISSUE_MKT_LISTING_BB_ID_MIC_PRIM_EXCH), "ENTER", false);
            dmpGsPortalUtl.inputText(IssueOR.ISSUE_RCR_PAMTC_CODE_LOCATOR, map.get(ISSUE_MKT_LISTING_RCR_PAMTC_CODE), "ENTER", false);
            dmpGsPortalUtl.inputText(IssueOR.ISSUE_RCR_WELLINGTON_CODE_LOCATOR, map.get(ISSUE_MKT_LISTING_RCR_WELLINGTONCODE), "ENTER", false);

            return this;
        } catch (Exception e) {
            LOGGER.error("Processing failed while adding Market Level Identifiers under Market Listing Details", e);
            throw new CartException(CartExceptionType.PROCESSING_FAILED, "Processing failed while adding Market Level Identifiers under Market Listing Details");
        }
    }

    public IssuePage fillCapitalization(Map<String, String> map) {
        try {
            dmpGsPortalUtl.selectGSTab(CAPITALIZATION_TAB);
            dmpGsPortalUtl.inputText(IssueOR.ISSUE_CAPITAL_TYPE_LOCATOR, map.get(ISSUE_CAPITAL_TYPE), "ENTER", false);
            dmpGsPortalUtl.inputText(IssueOR.ISSUE_MKT_CAPITALIZATION_LOCATOR, map.get(ISSUE_MKT_CAPITALIZATION), "ENTER", false);
            dmpGsPortalUtl.inputText(IssueOR.ISSUE_ACTUAL_SHARE_OUTSTAN_LOCATOR, map.get(ISSUE_ACTUAL_SHARE_OUTSTAN), "ENTER", false);
            return this;
        } catch (Exception e) {
            LOGGER.error("Processing failed while adding Calitalization Details", e);
            throw new CartException(CartExceptionType.PROCESSING_FAILED, "Processing failed while adding Calitalization Details");
        }
    }

    public IssuePage fillExtendedIdentifiers(Map<String, String> map) {
        try {
            dmpGsPortalUtl.selectGSTab(EXTENDED_IDENTIFIER_TAB);
            dmpGsPortalUtl.inputText(IssueOR.ISSUE_IDENTIFIER_VALUE_LOCATOR, map.get(ISSUE_IDENTIFIER_VALUE), "ENTER", false);
            dmpGsPortalUtl.inputText(IssueOR.ISSUE_IDENTIFIER_TYPE_LOCATOR, map.get(ISSUE_IDENTIFIER_TYPE), "ENTER", false);
            dmpGsPortalUtl.inputText(IssueOR.ISSUE_IDENTIFIER_EFFECTIVE_DATE_LOCATOR, map.get(ISSUE_IDENTIFIER_EFFECTIVE_DATE), "ENTER", false);
            dmpGsPortalUtl.inputText(IssueOR.ISSUE_GLOBAL_UNIQUE_INDI_LOCATOR, map.get(ISSUE_GLOBAL_UNIQUE_INDI), "ENTER", false);
            return this;
        } catch (Exception e) {
            LOGGER.error("Processing failed while adding Extended Identifiers Details", e);
            throw new CartException(CartExceptionType.PROCESSING_FAILED, "Processing failed while adding Extended Identifiers Details");
        }
    }

    public IssuePage fillRelatedInstrument(Map<String, String> map) {
        try {
            dmpGsPortalUtl.selectGSTab(RELATED_INST_TAB);
            dmpGsPortalUtl.inputText(IssueOR.ISSUE_RELATIONSHIP_TYPE_LOCATOR, map.get(ISSUE_RELATIONSHIP_TYPE), "ENTER", false);
            return this;
        } catch (Exception e) {
            LOGGER.error("Processing failed while adding Related Instrument Details", e);
            throw new CartException(CartExceptionType.PROCESSING_FAILED, "Processing failed while adding Related Instrument Details");
        }
    }

    public IssuePage fillIssueComments(Map<String, String> map) {
        try {
            dmpGsPortalUtl.selectGSTab(ISSUE_COMMENTS_TAB);
            dmpGsPortalUtl.inputText(IssueOR.ISSUE_COMMENT_REASON_TYPE_LOCATOR, map.get(ISSUE_COMMENT_REASON_TYPE), "ENTER", false);
            dmpGsPortalUtl.inputText(IssueOR.ISSUE_COMMENT_TEXT_LOCATOR, map.get(ISSUE_COMMENT_TEXT), "ENTER", false);
            dmpGsPortalUtl.inputText(IssueOR.ISSUE_LINE_NUMBER_LOCATOR, map.get(ISSUE_LINE_NUMBER), "ENTER", false);
            dmpGsPortalUtl.inputText(IssueOR.ISSUE_COMMENT_DATE_LOCATOR, map.get(ISSUE_COMMENT_DATE), "ENTER", false);
            return this;
        } catch (Exception e) {
            LOGGER.error("Processing failed while adding Issue Comments", e);
            throw new CartException(CartExceptionType.PROCESSING_FAILED, "Processing failed while adding Issue Comments");
        }
    }

    public IssuePage fillInstrumentRatings(Map<String, String> map) {
        try {
            dmpGsPortalUtl.selectGSTab(INSTRUMENT_RATING_TAB);
            dmpGsPortalUtl.inputText(IssueOR.ISSUE_RATING_NAME_LOCATOR, map.get(ISSUE_RATING_NAME), "ENTER", false);
            dmpGsPortalUtl.inputText(IssueOR.ISSUE_RATING_VALUE_LOCATOR, map.get(ISSUE_RATING_VALUE), "ENTER", false);
            return this;
        } catch (Exception e) {
            LOGGER.error("Processing failed while adding Instrument Ratings", e);
            throw new CartException(CartExceptionType.PROCESSING_FAILED, "Processing failed while adding Instrument Ratings");
        }
    }

    public Map<String, String> getIssueDetails() {
        Map<String, String> issueMap = new HashMap<>();
        issueMap.put(ISSUE_DENOM_CCY, webTaskSvc.getWebElementAttribute(IssueOR.ISSUE_DENOM_CCY_LOCATOR, "value"));
        issueMap.put(ISSUE_SOURCE_CCY, webTaskSvc.getWebElementAttribute(IssueOR.ISSUE_SOURCE_CCY_LOCATOR, "value"));
        issueMap.put(ISSUE_TARGET_CCY, webTaskSvc.getWebElementAttribute(IssueOR.ISSUE_TARGET_CCY_LOCATOR, "value"));
        issueMap.put(ISSUE_PROXY_IN_BRS, webTaskSvc.getWebElementAttribute(IssueOR.ISSUE_PROXY_IN_BRS_LOCATOR, "value"));
        return issueMap;
    }


    public Map<String, String> getIssueMarketLevelIdentifiersDetails() {
        Map<String, String> issueMap = new HashMap<>();
        dmpGsPortalUtl.selectGSTab(MARKET_LISTING_TAB);
        clickMarketLevelIdentifier("Market Level Identifiers");
        issueMap.put(ISSUE_MKT_LISTING_RDMCODE, webTaskSvc.getWebElementAttribute(IssueOR.ISSUE_RDM_CODE_LOCATOR, "value"));
        issueMap.put(ISSUE_MKT_LISTING_BBGLOBAL, webTaskSvc.getWebElementAttribute(IssueOR.ISSUE_BB_GLOBAL_LOCATOR, "value"));
        issueMap.put(ISSUE_MKT_LISTING_TICKER, webTaskSvc.getWebElementAttribute(IssueOR.ISSUE_TICKER_LOCATOR, "value"));
        issueMap.put(ISSUE_MKT_LISTING_REUTERS_TICKER, webTaskSvc.getWebElementAttribute(IssueOR.ISSUE_REUTERS_TICKER_LOCATOR, "value"));
        issueMap.put(ISSUE_MKT_LISTING_RIC, webTaskSvc.getWebElementAttribute(IssueOR.ISSUE_RIC_LOCATOR, "value"));
        issueMap.put(ISSUE_MKT_LISTING_RCR_EJSPCODE, webTaskSvc.getWebElementAttribute(IssueOR.ISSUE_RCR_ESJP_CODE_LOCATOR, "value"));
        issueMap.put(ISSUE_MKT_LISTING_RCR_BOCICODE, webTaskSvc.getWebElementAttribute(IssueOR.ISSUE_RCR_BOCI_CODE_LOCATOR, "value"));
        issueMap.put(ISSUE_MKT_LISTING_RCR_ESGACODE, webTaskSvc.getWebElementAttribute(IssueOR.ISSUE_RCR_ESGA_CODE_LOCATOR, "value"));
        issueMap.put(ISSUE_MKT_LISTING_RCR_EIMKIRCODE, webTaskSvc.getWebElementAttribute(IssueOR.ISSUE_RCR_EIMKOR_CODE_LOCATOR, "value"));
        issueMap.put(ISSUE_MKT_LISTING_RCR_MNGCODE, webTaskSvc.getWebElementAttribute(IssueOR.ISSUE_RCR_MNG_CODE_LOCATOR, "value"));
        issueMap.put(ISSUE_MKT_LISTING_RCR_PPMJNAMCODE, webTaskSvc.getWebElementAttribute(IssueOR.ISSUE_RCR_PPMJNAM_CODE_LOCATOR, "value"));
        issueMap.put(ISSUE_MKT_LISTING_RCR_TMBAMCODE, webTaskSvc.getWebElementAttribute(IssueOR.ISSUE_RCR_TMBAM_CODE_LOCATOR, "value"));
        issueMap.put(ISSUE_MKT_LISTING_RCR_WFOECODE, webTaskSvc.getWebElementAttribute(IssueOR.ISSUE_RCR_WFOE_CODE_LOCATOR, "value"));
        issueMap.put(ISSUE_MKT_LISTING_RCR_THANACODE, webTaskSvc.getWebElementAttribute(IssueOR.ISSUE_RCR_THANA_CODE_LOCATOR, "value"));
        issueMap.put(ISSUE_MKT_LISTING_BRS_BCUSIP, webTaskSvc.getWebElementAttribute(IssueOR.ISSUE_BRS_BCUSIP_LOCATOR, "value"));
        issueMap.put(ISSUE_MKT_LISTING_BNP_BBGLOBAL, webTaskSvc.getWebElementAttribute(IssueOR.ISSUE_BNP_BBGLOBAL_LOCATOR, "value"));
        issueMap.put(ISSUE_MKT_LISTING_MNG_BCUSIP, webTaskSvc.getWebElementAttribute(IssueOR.ISSUE_MNG_BCUSIP_LOCATOR, "value"));
        issueMap.put(ISSUE_MKT_LISTING_RCR_WFOECCBCODE, webTaskSvc.getWebElementAttribute(IssueOR.ISSUE_RCR_WFOECCB_CODE_LOCATOR, "value"));
        issueMap.put(ISSUE_MKT_LISTING_RCR_ROBOCOLLCODE, webTaskSvc.getWebElementAttribute(IssueOR.ISSUE_RCR_ROBOCOLL_CODE_LOCATOR, "value"));
        issueMap.put(ISSUE_MKT_LISTING_BNP_HIPEXT21D, webTaskSvc.getWebElementAttribute(IssueOR.ISSUE_BNP_HIPEXT21D_LOCATOR, "value"));
        issueMap.put(ISSUE_MKT_LISTING_BNP_LISTINGID, webTaskSvc.getWebElementAttribute(IssueOR.ISSUE_BNP_LISTINGID_LOCATOR, "value"));
        issueMap.put(ISSUE_MKT_LISTING_BB_ID_MIC_PRIM_EXCH, webTaskSvc.getWebElementAttribute(IssueOR.ISSUE_BB_ID_MIC_PRIM_EXCH_LOCATOR, "value"));
        issueMap.put(ISSUE_MKT_LISTING_RCR_PAMTC_CODE, webTaskSvc.getWebElementAttribute(IssueOR.ISSUE_RCR_PAMTC_CODE_LOCATOR, "value"));
        issueMap.put(ISSUE_MKT_LISTING_RCR_WELLINGTONCODE, webTaskSvc.getWebElementAttribute(IssueOR.ISSUE_RCR_WELLINGTON_CODE_LOCATOR, "value"));


        return issueMap;
    }

    public Map<String, String> getIssueDescriptionDetails() {
        Map<String, String> issueMap = new HashMap<>();
        dmpGsPortalUtl.selectGSTab(DESCRIPTION_TAB);
        issueMap.put(ISSUE_INST_NAME, webTaskSvc.getWebElementAttribute(IssueOR.ISSUE_DESC_INSTRUMENT_NAME, "value"));
        issueMap.put(ISSUE_DESC_INST_DESC, webTaskSvc.getWebElementAttribute(IssueOR.ISSUE_DESC_INSTRUMENT_DESC, "value"));
        issueMap.put(ISSUE_SOURCE_OF_DESC, webTaskSvc.getWebElementAttribute(IssueOR.ISSUE_SOURCE_OF_DESC_LOCATOR, "value"));
        issueMap.put(ISSUE_INST_DESC_USAGE, webTaskSvc.getWebElementAttribute(IssueOR.ISSUE_INST_DESC_USAGE_LOCATOR, "value"));
        issueMap.put(ISSUE_INST_DESC_LANG, webTaskSvc.getWebElementAttribute(IssueOR.ISSUE_INST_DESC_LANG_LOCATOR, "value"));
        return issueMap;
    }

    public IssuePage fillClassification(Map<String, String> map) {
        try {
            dmpGsPortalUtl.selectGSTab(CLASSIFICATION_TAB);
            dmpGsPortalUtl.inputText(IssueOR.ISSUE_CLASSI_RT_CLSS_SCH_LOCATOR, map.get(ISSUE_CLASSI_RTCS), "ENTER", false);
            return this;
        } catch (Exception e) {
            LOGGER.error("Processing failed while adding Classification Details", e);
            throw new CartException(CartExceptionType.PROCESSING_FAILED, "Processing failed while adding Classification Details");
        }
    }

    public Map<String, String> getClassificationDetails() {
        Map<String, String> issueMap = new HashMap<>();
        dmpGsPortalUtl.selectGSTab(CLASSIFICATION_TAB);
        issueMap.put(ISSUE_CLASSI_RTCS, webTaskSvc.getWebElementAttribute(IssueOR.ISSUE_CLASSI_RT_CLSS_SCH_LOCATOR, "value"));
        return issueMap;
    }

    public IssuePage fillMarketFeaturesUnderListing(Map<String, String> map) {
        try {
            this.navigateToMarketListing();
            this.clickMarketLevelIdentifier("Market Features");
            dmpGsPortalUtl.inputText(IssueOR.ISSUE_SSDR_ROUND_LOT_LOCATOR, map.get(ISSUE_MKT_FEATURES_SSDR_LOT), "ENTER", false);
            return this;
        } catch (Exception e) {
            LOGGER.error("Processing failed while adding Market Level Identifiers under Market Listing Details", e);
            throw new CartException(CartExceptionType.PROCESSING_FAILED, "Processing failed while adding Market Level Identifiers under Market Listing Details");
        }
    }

    public Map<String, String> getMarketFeaturesUnderListing() {
        Map<String, String> issueMap = new HashMap<>();
        this.clickMarketLevelIdentifier("Market Features");
        issueMap.put(ISSUE_MKT_FEATURES_SSDR_LOT, webTaskSvc.getWebElementAttribute(IssueOR.ISSUE_SSDR_ROUND_LOT_LOCATOR, "value"));
        return issueMap;
    }

    public IssuePage fillFundappsIssueAttributes(Map<String, String> map) {
        try {
            webTaskSvc.clickHiddenElementByJavaScript(formatter.format(GS_TAB, FA_ISSUE_ATTR_TAB),10);
            dmpGsPortalUtl.inputText(IssueOR.ISSUE_FA_DELTA_LOCATOR, map.get(ISSUE_FA_ATTR_DELTA), "ENTER", false);
            dmpGsPortalUtl.inputText(IssueOR.ISSUE_FA_CONV_DATA_IND_LOCATOR, map.get(ISSUE_FA_ATTR_CONV_DATA_IND), "ENTER", false);
            dmpGsPortalUtl.inputText(IssueOR.ISSUE_FA_CLOSE_PRICE_LOCATOR, map.get(ISSUE_FA_ATTR_CLOSE_PRICE), "ENTER", false);
            dmpGsPortalUtl.inputText(IssueOR.ISSUE_FA_TOT_ISSUE_NOM_CAP_LOCATOR, map.get(ISSUE_FA_ATTR_TOT_ISS_NOM), "ENTER", false);
            dmpGsPortalUtl.inputText(IssueOR.ISSUE_FA_TOT_SHARES_TRSRY_LOCATOR, map.get(ISSUE_FA_ATTR_TOT_SHR_TRSY), "ENTER", false);
            dmpGsPortalUtl.inputText(IssueOR.ISSUE_FA_RDM_SECTYPE_LOCATOR, map.get(ISSUE_FA_ATTR_RDM_SECTYPE), "ENTER", false);
            dmpGsPortalUtl.inputText(IssueOR.ISSUE_FA_FUND_SHARES_OS_LOCATOR, map.get(ISSUE_FA_ATTR_FUND_SHR_OS), "ENTER", false);
            dmpGsPortalUtl.inputText(IssueOR.ISSUE_FA_TOT_NET_ASSETS_LOCATOR, map.get(ISSUE_FA_ATTR_TOT_NET_ASSET), "ENTER", false);
            dmpGsPortalUtl.inputText(IssueOR.ISSUE_FA_RT_SHARES_OS_LOCATOR, map.get(ISSUE_FA_ATTR_RT_SHR_OS), "ENTER", false);
            dmpGsPortalUtl.inputText(IssueOR.ISSUE_FA_LIST_SHR_ISS_SHR_AMT_LOCATOR, map.get(ISSUE_FA_ATTR_LIST_SHR_ISS_SHR_AMT), "ENTER", false);
            dmpGsPortalUtl.inputText(IssueOR.ISSUE_FA_TOT_SHR_OS_LOCATOR, map.get(ISSUE_FA_ATTR_TOT_SHR_OS), "ENTER", false);
            dmpGsPortalUtl.inputText(IssueOR.ISSUE_FA_CONV_RATIO_LOCATOR, map.get(ISSUE_FA_ATTR_CONV_RATIO), "ENTER", false);
            dmpGsPortalUtl.inputText(IssueOR.ISSUE_FA_ASSET_RATIO_AGAINST_LOCATOR, map.get(ISSUE_FA_ATTR_ASSET_RATIO_AGAINST), "ENTER", false);
            dmpGsPortalUtl.inputText(IssueOR.ISSUE_FA_ASSET_RATIO_FOR_LOCATOR, map.get(ISSUE_FA_ATTR_ASSET_RATIO_FOR), "ENTER", false);
            dmpGsPortalUtl.inputText(IssueOR.ISSUE_FA_MKT_CAPZN_LOCATOR, map.get(ISSUE_FA_ATTR_MKT_CAPTZN), "ENTER", false);
            dmpGsPortalUtl.inputText(IssueOR.ISSUE_FA_EXCH_CNTRY_CDE_LOCATOR, map.get(ISSUE_FA_ATTR_EXCH_CNTRY_CDE), "ENTER", false);
            dmpGsPortalUtl.inputText(IssueOR.ISSUE_FA_TOT_SHR_ISS_LOCATOR, map.get(ISSUE_FA_ATTR_TOT_SHR_ISS), "ENTER", false);
            dmpGsPortalUtl.inputText(IssueOR.ISSUE_FA_TOT_VOTE_RIGHT_LOCATOR, map.get(ISSUE_FA_ATTR_TOT_VOTE_RIGHTS), "ENTER", false);
            dmpGsPortalUtl.inputText(IssueOR.ISSUE_FA_TOT_VOTE_RIGHT_UL_LOCATOR, map.get(ISSUE_FA_ATTR_TOT_VOTE_RIGHTS_UL), "ENTER", false);
            dmpGsPortalUtl.inputText(IssueOR.ISSUE_FA_TOT_VOTE_RIGHT_L_LOCATOR, map.get(ISSUE_FA_ATTR_TOT_VOTE_RIGHTS_L), "ENTER", false);
            dmpGsPortalUtl.inputText(IssueOR.ISSUE_FA_TOT_VOTE_SHR_LOCATOR, map.get(ISSUE_FA_ATTR_TOT_VOTE_SHR), "ENTER", false);
            dmpGsPortalUtl.inputText(IssueOR.ISSUE_FA_TOT_VOTE_SHR_ISS_LOCATOR, map.get(ISSUE_FA_ATTR_TOT_VOTE_SHR_ISS), "ENTER", false);
            dmpGsPortalUtl.inputText(IssueOR.ISSUE_FA_TOT_VOTE_SHR_UL_LOCATOR, map.get(ISSUE_FA_ATTR_TOT_VOTE_SHR_UL), "ENTER", false);
            dmpGsPortalUtl.inputText(IssueOR.ISSUE_FA_TOT_VOTE_SHR_L_LOCATOR, map.get(ISSUE_FA_ATTR_TOT_VOTE_SHR_L), "ENTER", false);
            dmpGsPortalUtl.inputText(IssueOR.ISSUE_FA_TOT_VOTE_SHR_OS_LOCATOR, map.get(ISSUE_FA_ATTR_TOT_VOTE_SHR_OS), "ENTER", false);
            dmpGsPortalUtl.inputText(IssueOR.ISSUE_FA_CLOSE_PR_CURR_LOCATOR, map.get(ISSUE_FA_ATTR_CLOSE_PR_CURR), "ENTER", false);
            dmpGsPortalUtl.inputText(IssueOR.ISSUE_FA_CLOSE_PR_DATE_LOCATOR, map.get(ISSUE_FA_ATTR_CLOSE_PR_DATE), "ENTER", false);
            return this;
        } catch (Exception e) {
            LOGGER.error("Processing failed while adding Fundapps Issue Attributes", e);
            throw new CartException(CartExceptionType.PROCESSING_FAILED, "Processing failed while adding Fundapps Issue Attributes");
        }
    }

    public Map<String, String> getFundappsIssueAttributes() {
        Map<String, String> issueMap = new HashMap<>();
        webTaskSvc.clickHiddenElementByJavaScript(formatter.format(GS_TAB, FA_ISSUE_ATTR_TAB),10);
        issueMap.put(ISSUE_FA_ATTR_DELTA, webTaskSvc.getWebElementAttribute(IssueOR.ISSUE_FA_DELTA_LOCATOR, "value"));
        issueMap.put(ISSUE_FA_ATTR_CONV_DATA_IND, webTaskSvc.getWebElementAttribute(IssueOR.ISSUE_FA_CONV_DATA_IND_LOCATOR, "value"));
        issueMap.put(ISSUE_FA_ATTR_CLOSE_PRICE, webTaskSvc.getWebElementAttribute(IssueOR.ISSUE_FA_CLOSE_PRICE_LOCATOR, "value"));
        issueMap.put(ISSUE_FA_ATTR_TOT_ISS_NOM, webTaskSvc.getWebElementAttribute(IssueOR.ISSUE_FA_TOT_ISSUE_NOM_CAP_LOCATOR, "value"));
        issueMap.put(ISSUE_FA_ATTR_TOT_SHR_TRSY, webTaskSvc.getWebElementAttribute(IssueOR.ISSUE_FA_TOT_SHARES_TRSRY_LOCATOR, "value"));
        issueMap.put(ISSUE_FA_ATTR_RDM_SECTYPE, webTaskSvc.getWebElementAttribute(IssueOR.ISSUE_FA_RDM_SECTYPE_LOCATOR, "value"));
        issueMap.put(ISSUE_FA_ATTR_FUND_SHR_OS, webTaskSvc.getWebElementAttribute(IssueOR.ISSUE_FA_FUND_SHARES_OS_LOCATOR, "value"));
        issueMap.put(ISSUE_FA_ATTR_TOT_NET_ASSET, webTaskSvc.getWebElementAttribute(IssueOR.ISSUE_FA_TOT_NET_ASSETS_LOCATOR, "value"));
        issueMap.put(ISSUE_FA_ATTR_RT_SHR_OS, webTaskSvc.getWebElementAttribute(IssueOR.ISSUE_FA_RT_SHARES_OS_LOCATOR, "value"));
        issueMap.put(ISSUE_FA_ATTR_LIST_SHR_ISS_SHR_AMT, webTaskSvc.getWebElementAttribute(IssueOR.ISSUE_FA_LIST_SHR_ISS_SHR_AMT_LOCATOR, "value"));
        issueMap.put(ISSUE_FA_ATTR_TOT_SHR_OS, webTaskSvc.getWebElementAttribute(IssueOR.ISSUE_FA_TOT_SHR_OS_LOCATOR, "value"));
        issueMap.put(ISSUE_FA_ATTR_CONV_RATIO, webTaskSvc.getWebElementAttribute(IssueOR.ISSUE_FA_CONV_RATIO_LOCATOR, "value"));
        issueMap.put(ISSUE_FA_ATTR_ASSET_RATIO_AGAINST, webTaskSvc.getWebElementAttribute(IssueOR.ISSUE_FA_ASSET_RATIO_AGAINST_LOCATOR, "value"));
        issueMap.put(ISSUE_FA_ATTR_ASSET_RATIO_FOR, webTaskSvc.getWebElementAttribute(IssueOR.ISSUE_FA_ASSET_RATIO_FOR_LOCATOR, "value"));
        issueMap.put(ISSUE_FA_ATTR_MKT_CAPTZN, webTaskSvc.getWebElementAttribute(IssueOR.ISSUE_FA_MKT_CAPZN_LOCATOR, "value"));
        issueMap.put(ISSUE_FA_ATTR_EXCH_CNTRY_CDE, webTaskSvc.getWebElementAttribute(IssueOR.ISSUE_FA_EXCH_CNTRY_CDE_LOCATOR, "value"));
        issueMap.put(ISSUE_FA_ATTR_TOT_SHR_ISS, webTaskSvc.getWebElementAttribute(IssueOR.ISSUE_FA_TOT_SHR_ISS_LOCATOR, "value"));
        issueMap.put(ISSUE_FA_ATTR_TOT_VOTE_RIGHTS, webTaskSvc.getWebElementAttribute(IssueOR.ISSUE_FA_TOT_VOTE_RIGHT_LOCATOR, "value"));
        issueMap.put(ISSUE_FA_ATTR_TOT_VOTE_RIGHTS_UL, webTaskSvc.getWebElementAttribute(IssueOR.ISSUE_FA_TOT_VOTE_RIGHT_UL_LOCATOR, "value"));
        issueMap.put(ISSUE_FA_ATTR_TOT_VOTE_RIGHTS_L, webTaskSvc.getWebElementAttribute(IssueOR.ISSUE_FA_TOT_VOTE_RIGHT_L_LOCATOR, "value"));
        issueMap.put(ISSUE_FA_ATTR_TOT_VOTE_SHR, webTaskSvc.getWebElementAttribute(IssueOR.ISSUE_FA_TOT_VOTE_SHR_LOCATOR, "value"));
        issueMap.put(ISSUE_FA_ATTR_TOT_VOTE_SHR_ISS, webTaskSvc.getWebElementAttribute(IssueOR.ISSUE_FA_TOT_VOTE_SHR_ISS_LOCATOR, "value"));
        issueMap.put(ISSUE_FA_ATTR_TOT_VOTE_SHR_UL, webTaskSvc.getWebElementAttribute(IssueOR.ISSUE_FA_TOT_VOTE_SHR_UL_LOCATOR, "value"));
        issueMap.put(ISSUE_FA_ATTR_TOT_VOTE_SHR_L, webTaskSvc.getWebElementAttribute(IssueOR.ISSUE_FA_TOT_VOTE_SHR_L_LOCATOR, "value"));
        issueMap.put(ISSUE_FA_ATTR_TOT_VOTE_SHR_OS, webTaskSvc.getWebElementAttribute(IssueOR.ISSUE_FA_TOT_VOTE_SHR_OS_LOCATOR, "value"));
        issueMap.put(ISSUE_FA_ATTR_CLOSE_PR_CURR, webTaskSvc.getWebElementAttribute(IssueOR.ISSUE_FA_CLOSE_PR_CURR_LOCATOR, "value"));
        issueMap.put(ISSUE_FA_ATTR_CLOSE_PR_DATE, webTaskSvc.getWebElementAttribute(IssueOR.ISSUE_FA_CLOSE_PR_DATE_LOCATOR, "value"));
        return issueMap;
    }

    public IssuePage fillFundappsMICList(Map<String, String> map) {
        try {
            webTaskSvc.clickHiddenElementByJavaScript(formatter.format(GS_TAB, FA_MIC_LIST_TAB),10);
            WebElement addDetailsBtn = webTaskSvc.getWebElementRef(GS_ADD_DETAILS_BUTTON);
            if(!addDetailsBtn.equals(null)){
                this.invokeAddNewDetails(FA_MIC_LIST_TAB);
            }
            dmpGsPortalUtl.inputTextInLookUpField(IssueOR.ISSUE_FA_MIC_CODE_SRCH_BTN_LOCATOR,ISSUE_FA_MIC_CODE,map.get(ISSUE_FA_MIC_CODE),false);
            dmpGsPortalUtl.inputText(IssueOR.ISSUE_FA_PRTCPN_AMT_LOCATOR, map.get(ISSUE_FA_PARTICIPATION_AMT), "ENTER", false);
            return this;
        } catch (Exception e) {
            LOGGER.error("Processing failed while adding Fundapps MIC List", e);
            throw new CartException(CartExceptionType.PROCESSING_FAILED, "Processing failed while adding Fundapps MIC List");
        }
    }

    public Map<String, String> getFundappsMICList() {
        Map<String, String> issueMap = new HashMap<>();
        webTaskSvc.clickHiddenElementByJavaScript(formatter.format(GS_TAB, FA_MIC_LIST_TAB),10);
        issueMap.put(ISSUE_FA_MIC_CODE, webTaskSvc.getWebElementAttribute(IssueOR.ISSUE_FA_MIC_CODE_LOCATOR, "value"));
        issueMap.put(ISSUE_FA_PARTICIPATION_AMT, webTaskSvc.getWebElementAttribute(IssueOR.ISSUE_FA_PRTCPN_AMT_LOCATOR, "value"));
        return issueMap;
    }
}
