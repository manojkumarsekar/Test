package com.eastspring.tom.cart.dmp.pages.customer.master;

import com.eastspring.tom.cart.core.CartException;
import com.eastspring.tom.cart.core.CartExceptionType;
import com.eastspring.tom.cart.core.steps.WebSteps;
import com.eastspring.tom.cart.core.svc.StateSvc;
import com.eastspring.tom.cart.core.svc.ThreadSvc;
import com.eastspring.tom.cart.core.svc.WebTaskSvc;
import com.eastspring.tom.cart.core.utl.DateTimeUtil;
import com.eastspring.tom.cart.core.utl.FormatterUtil;
import com.eastspring.tom.cart.core.utl.ScenarioUtil;
import com.eastspring.tom.cart.dmp.pages.HomePage;
import com.eastspring.tom.cart.dmp.steps.DmpGsPortalSteps;
import com.eastspring.tom.cart.dmp.utl.DmpGsPortalUtl;
import com.google.common.base.Strings;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;

import java.util.HashMap;
import java.util.Map;

import static com.eastspring.tom.cart.constant.CommonLocators.VARIABLE;
import static com.eastspring.tom.cart.dmp.mdl.GSUIFields.*;
import static com.eastspring.tom.cart.dmp.pages.customer.master.CustomerMasterOR.*;

public class AccountMasterPage {

    private static final Logger LOGGER = LoggerFactory.getLogger(AccountMasterPage.class);

    public static final String ENTER = "ENTER";
    public static final String PROCESSING_FAILED = "Processing failed!!";
    public static final String VALUE = "value";

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

    @Autowired
    private ScenarioUtil scenarioUtil;

    //constants
    public static final String SEARCH_TYPE = "Account";
    public static final String IDENTIFIERS_TAB = "Identifiers";
    public static final String LEGACYINDER_TAB = "Legacy Identifiers";
    public static final String LBUIDENTIFIER_TAB = "LBU Identifiers";
    public static final String XREFERENCE_TAB = "XReference";

    private String timeStamp;
    private String portfolioName;
    private String crtsCode;
    private String tStarCode;
    private String koreaCode;
    private String irpCode;

    public String getTimeStamp() {
        return timeStamp;
    }

    public void setTimeStamp(String timeStamp) {
        this.timeStamp = timeStamp;
    }

    public String getPortfolioName() {
        return portfolioName;
    }

    public void setPortfolioName(String portfolioName) {
        if (portfolioName.contains(VARIABLE)) {
            this.portfolioName = stateSvc.expandVar(portfolioName);
        } else {
            this.portfolioName = portfolioName.concat(getTimeStamp());
        }
    }

    public String getCrtsCode() {
        return crtsCode;
    }

    public void setCrtsCode(String crtsCode) {
        if (crtsCode.contains(VARIABLE)) {
            this.crtsCode = stateSvc.expandVar(crtsCode);
        } else {
            this.crtsCode = crtsCode.concat(getTimeStamp());
        }
    }

    public String getTstarCode() {
        return tStarCode;
    }

    public void setTstarCode(String tstarCode) {
        if (tstarCode.contains(VARIABLE)) {
            this.tStarCode = stateSvc.expandVar(tstarCode);
        } else {
            this.tStarCode = tstarCode.concat(getTimeStamp());
        }
    }

    public String getKoreaCode() {
        return koreaCode;
    }

    public void setKoreaCode(String koreaCode) {
        if (koreaCode.contains(VARIABLE)) {
            this.koreaCode = stateSvc.expandVar(koreaCode);
        } else {
            this.koreaCode = koreaCode.concat(getTimeStamp());
        }
    }

    public String getIrpCode() {
        return irpCode;
    }

    public void setIrpCode(String irpCode) {
        if (irpCode.contains(VARIABLE)) {
            this.irpCode = stateSvc.expandVar(irpCode);
        } else {
            this.irpCode = irpCode.concat(getTimeStamp());
        }
    }

    public AccountMasterPage initializePortfolioData(Map<String, String> map) {
        this.setTimeStamp(dateTimeUtil.getTimestamp("DHMs"));

        this.setPortfolioName(map.get(AM_PORTFOLIO_NAME));
        this.setCrtsCode(map.get(AM_CRTS_CODE));
        this.setTstarCode(map.get(AM_TSTAR_CODE));
        this.setKoreaCode(map.get(AM_KOREA_CODE));
        this.setIrpCode(map.get(AM_IRP_CODE));

        map.replace(AM_PORTFOLIO_NAME, getPortfolioName());
        map.replace(AM_CRTS_CODE, getCrtsCode());
        map.replace(AM_TSTAR_CODE, getTstarCode());
        map.replace(AM_KOREA_CODE, getKoreaCode());
        map.replace(AM_IRP_CODE, getIrpCode());
        return this;
    }

    public AccountMasterPage searchAccountMaster(String searchValue) {
        homePage.globalSearchAndWaitTillSuccess(searchValue, SEARCH_TYPE, 120);
        webTaskSvc.waitTillPageLoads();
        threadSvc.sleepMillis(500);
        return this;
    }

    public boolean isAccountMasterPresent(String portfolioName) {
        searchAccountMaster(portfolioName);
        threadSvc.sleepSeconds(1);
        return dmpGsPortalUtl.isSearchRecordAvailable(portfolioName);
    }


    public AccountMasterPage invokeAccountMaster(String portfolioName) {
        if (this.isAccountMasterPresent(portfolioName)) {
            LOGGER.error("Account Master is present with name [{}]", portfolioName);
            throw new CartException(CartExceptionType.INCOMPLETE_PARAMS, "Account Master is present with name [{}]", portfolioName);
        }
        dmpGsPortalUtl.invokeSetUpScreen(null, null, null);
        return this;
    }

    public void invokeAccountMaster() {
        LOGGER.debug("Navigating to Customer Master Screen");
        homePage.clickMenuDropdown()
                .selectMenu("Customer Master")
                .selectMenu("Account Master");
        homePage.verifyGSTabDisplayed("Account Master", 600);
        dmpGsPortalUtl.invokeSetUpScreen(null, null, null);
    }


    public void saveAccountMaster() {
        dmpGsPortalUtl.saveChanges();
    }

    public AccountMasterPage fillPortfolioDetails(Map<String, String> map) {
        webTaskSvc.waitForElementToAppear(ACCOUNTMASTER_PORTFOLIONAME_LOCATOR, 120);
        try {
            dmpGsPortalUtl.inputText(ACCOUNTMASTER_PORTFOLIONAME_LOCATOR, map.get(AM_PORTFOLIO_NAME), ENTER, false);
            dmpGsPortalUtl.inputText(ACCOUNTMASTER_PORTFOLIOLEGALNAME_LOCATOR, map.get(AM_PORTFOLIO_LEGAL_NAME), ENTER, false);
            dmpGsPortalUtl.inputText(ACCOUNTMASTER_INCEPTIONDATE_LOCATOR, map.get(AM_INCEPTION_DATE), ENTER, false);
            dmpGsPortalUtl.inputText(ACCOUNTMASTER_ACTIVEFLAG_LOCATOR, map.get(AM_ACTIVE_FLAG), ENTER, false);
            dmpGsPortalUtl.inputText(ACCOUNTMASTER_PORTFOLIODOMICILE_LOCATOR, map.get(AM_PORTFOLIO_DOMICILE), ENTER, false);
            dmpGsPortalUtl.inputText(ACCOUNTMASTER_INVESTMENT_TEAM_LOCATOR, map.get(AM_INVST_TEAM), ENTER, false);
            dmpGsPortalUtl.inputText(ACCOUNTMASTER_BASECCY_LOCATOR, map.get(AM_BASE_CCY), ENTER, false);
            dmpGsPortalUtl.inputText(ACCOUNTMASTER_PORTFOLIOLEI_LOCATOR, map.get(AM_PORTFOLIO_LEI), ENTER, false);
            dmpGsPortalUtl.inputText(ACCOUNTMASTER_PROCESSED_UNPROCESSED_LOCATOR, map.get(AM_PROCESSED), ENTER, false);
            dmpGsPortalUtl.inputTextInLookUpField(ACCOUNTMASTER_MASTERPORTFOLIONAME_SEARCHBUTTON, map.get(AM_MASTER_PORTFOLIO_NAME), false);
            dmpGsPortalUtl.inputText(ACCOUNTMASTER_BNP_PORTFOLIO_PERMNCE_FLAG_LOCATOR, map.getOrDefault(BENCHMARK_PERFORMANCE_FLAG, "N"), ENTER, false);

            return this;
        } catch (Exception e) {
            LOGGER.error(PROCESSING_FAILED, e);
            throw new CartException(CartExceptionType.PROCESSING_FAILED, PROCESSING_FAILED);
        }
    }

    public AccountMasterPage fillPortfolioManagerDetails(Map<String, String> map) {
        webTaskSvc.waitForElementToAppear(ACCOUNTMASTER_PORTMANAGER1_SEARCHBUTTON, 120);
        try {
            dmpGsPortalUtl.inputTextInLookUpField(ACCOUNTMASTER_PORTMANAGER1_SEARCHBUTTON, map.get(AM_PM1), false);
            dmpGsPortalUtl.inputTextInLookUpField(ACCOUNTMASTER_PORTMANAGER2_SEARCHBUTTON, map.get(AM_PM2), false);
            dmpGsPortalUtl.inputText(ACCOUNTMASTER_BACKUP_PM_LOCATOR, map.get(AM_BACKUP_PM), ENTER, false);
            return this;
        } catch (Exception e) {
            LOGGER.error(PROCESSING_FAILED, e);
            throw new CartException(CartExceptionType.PROCESSING_FAILED, PROCESSING_FAILED);
        }
    }

    public AccountMasterPage fillFundDetails(Map<String, String> map) {
        webTaskSvc.waitForElementToAppear(ACCOUNTMASTER_FUNDCATEGORY_LOCATOR, 120);
        threadSvc.sleepSeconds(1);
        try {
            dmpGsPortalUtl.inputText(ACCOUNTMASTER_FUNDCATEGORY_LOCATOR, map.get(AM_FUND_CATEGORY), ENTER, false);
            dmpGsPortalUtl.inputText(ACCOUNTMASTER_FUNDPLATFORM_LOCATOR, map.get(AM_FUND_PLATFORM), ENTER, false);
            dmpGsPortalUtl.inputText(ACCOUNTMASTER_FUNDTYPE_LOCATOR, map.get(AM_FUND_TYPE), ENTER, false);
            dmpGsPortalUtl.inputText(ACCOUNTMASTER_INVESTMENT_STRATEGY_LOCATOR, map.get(AM_INVST_STRATEGY), ENTER, false);
            dmpGsPortalUtl.inputText(ACCOUNTMASTER_MNG_MOTHERFUND_LOCATOR, map.get(AM_MOTHER_FUND), ENTER, false);
            dmpGsPortalUtl.inputText(ACCOUNTMASTER_FUND_REGION_LOCATOR, map.get(AM_FUND_REGION), ENTER, false);
            return this;
        } catch (Exception e) {
            LOGGER.error(PROCESSING_FAILED, e);
            throw new CartException(CartExceptionType.PROCESSING_FAILED, PROCESSING_FAILED);
        }
    }

    public AccountMasterPage fillIdentifiersTabDetails(Map<String, String> map) {
        try {
            dmpGsPortalUtl.selectGSTab(IDENTIFIERS_TAB);
            threadSvc.sleepSeconds(1);
            dmpGsPortalUtl.inputTextInLookUpField(ACCOUNTMASTER_SUBPORT_SECURITYID_SEARCHBUTTON, map.get(AM_SUBPORT_SECID), false);
            dmpGsPortalUtl.inputTextInLookUpField(ACCOUNTMASTER_UNIT_TRUST_SECURITYID_SEARCHBUTTON, map.get(AM_UNITTRUST_SECID), false);
            return this;
        } catch (Exception e) {
            LOGGER.error(PROCESSING_FAILED, e);
            throw new CartException(CartExceptionType.PROCESSING_FAILED, PROCESSING_FAILED);
        }
    }

    public AccountMasterPage fillLegalIdentifiersTabDetails(Map<String, String> map) {
        try {

            dmpGsPortalUtl.selectGSTab(LEGACYINDER_TAB);
            threadSvc.sleepSeconds(1);
            dmpGsPortalUtl.inputTextInLookUpField(ACCOUNTMASTER_CLONE_PORTFOLIONAME_SEARCHBUTTON, map.get(AM_CLONE_PORT_TICKER), false);
            dmpGsPortalUtl.inputText(ACCOUNTMASTER_RDMPORTCODE_LOCATOR, map.get(AM_RDM_CODE), ENTER, false);
            dmpGsPortalUtl.inputText(ACCOUNTMASTER_CRTSPORTCODE_LOCATOR, map.get(AM_CRTS_CODE), ENTER, false);
            dmpGsPortalUtl.inputText(ACCOUNTMASTER_HIPORTCODE_LOCATOR, map.get(AM_HIPORT_CODE), ENTER, false);
            dmpGsPortalUtl.inputText(ACCOUNTMASTER_SYLVANPORTCODE_LOCATOR, map.get(AM_SYLVAN_CODE), ENTER, false);
            dmpGsPortalUtl.inputText(ACCOUNTMASTER_EISPORTCODE_LOCATOR, map.get(AM_EASTSPRING_CODE), ENTER, false);
            dmpGsPortalUtl.inputText(ACCOUNTMASTER_ALT_CRTSID_LOCATOR, map.get(AM_ALTERNATE_CRTS_ID), ENTER, false);
            return this;
        } catch (Exception e) {
            LOGGER.error(PROCESSING_FAILED, e);
            throw new CartException(CartExceptionType.PROCESSING_FAILED, PROCESSING_FAILED);
        }
    }

    public AccountMasterPage fillLBUIdentifiersTabDetails(Map<String, String> map) {
        try {
            dmpGsPortalUtl.selectGSTab(LBUIDENTIFIER_TAB);
            threadSvc.sleepSeconds(1);
            dmpGsPortalUtl.inputText(ACCOUNTMASTER_TSTARPORTCODE_LOCATOR, map.get(AM_TSTAR_CODE), ENTER, false);
            dmpGsPortalUtl.inputText(ACCOUNTMASTER_DBANKPORTCODE_LOCATOR, map.get(AM_MFUND_CODE), ENTER, false);
            dmpGsPortalUtl.inputText(ACCOUNTMASTER_MFUNDPORTCODE_LOCATOR, map.get(AM_DBANK_CODE), ENTER, false);
            dmpGsPortalUtl.inputText(ACCOUNTMASTER_DMSPORTCODE_LOCATOR, map.get(AM_DMS_CODE), ENTER, false);
            dmpGsPortalUtl.inputText(ACCOUNTMASTER_KOREAMD_PORTCODE_LOCATOR, map.get(AM_KOREA_CODE), ENTER, false);
            dmpGsPortalUtl.inputText(ACCOUNTMASTER_THAILAND_PORTFOLIO_CODE_LOCATOR, map.get(AM_THAILAND_CODE), ENTER, false);
            dmpGsPortalUtl.inputText(ACCOUNTMASTER_HIPORT_SUFFIX_CODE_LOCATOR, map.get(AM_HIPORT_SUFFIX_CODE), ENTER, false);
            return this;
        } catch (Exception e) {
            LOGGER.error(PROCESSING_FAILED, e);
            throw new CartException(CartExceptionType.PROCESSING_FAILED, PROCESSING_FAILED);
        }
    }

    public AccountMasterPage fillXReferenceIdentifiersTabDetails(Map<String, String> map) {
        try {
            dmpGsPortalUtl.selectGSTab(XREFERENCE_TAB);
            threadSvc.sleepSeconds(1);
            dmpGsPortalUtl.inputText(ACCOUNTMASTER_BRS_PORTID_LOCATOR, map.get(AM_BRS_ID), ENTER, false);
            dmpGsPortalUtl.inputText(ACCOUNTMASTER_BRS_LEGALENTITY_TICKER_LOCATOR, map.get(AM_BRS_LEGAL_ENTITY), ENTER, false);
            dmpGsPortalUtl.inputText(ACCOUNTMASTER_BRS_BUSINESSLINE_TICKER_LOCATOR, map.get(AM_BRS_BUSINESS_LINE), ENTER, false);
            dmpGsPortalUtl.inputText(ACCOUNTMASTER_BNP_PORTID_LOCATOR, map.get(AM_BNP_ID), ENTER, false);
            dmpGsPortalUtl.inputText(ACCOUNTMASTER_IRPCODE_LOCATOR, map.get(AM_IRP_CODE), ENTER, false);
            dmpGsPortalUtl.inputText(ACCOUNTMASTER_PORTFOLIO_ISIN_LOCATOR, map.get(AM_PORTFOLIO_ISIN), ENTER, false);
            dmpGsPortalUtl.inputText(ACCOUNTMASTER_IDENTIFIER_FUNDIPEDIA_FUND_ID, map.get(SC_FUNDIPEDIA_FUND_ID), ENTER, false);
            dmpGsPortalUtl.inputText(ACCOUNTMASTER_IDENTIFIER_FUNDIPEDIA_PORTFOLIO_ID, map.get(SC_FUNDIPEDIA_PORTFOLIO_ID), ENTER, false);
            return this;
        } catch (Exception e) {
            LOGGER.error(PROCESSING_FAILED, e);
            throw new CartException(CartExceptionType.PROCESSING_FAILED, PROCESSING_FAILED);
        }
    }

    public AccountMasterPage fillRegulatoryDetails(Map<String, String> map) {
        try {
            dmpGsPortalUtl.inputText(ACCOUNTMASTER_MAS_CATEGORY_LOCATOR, map.get(AM_MAS_CATEGORY), ENTER, false);
            return this;
        } catch (Exception e) {
            LOGGER.error(PROCESSING_FAILED, e);
            throw new CartException(CartExceptionType.PROCESSING_FAILED, PROCESSING_FAILED);
        }
    }

    public AccountMasterPage fillSSDRDetails(Map<String, String> map) {
        webTaskSvc.waitForElementToAppear(ACCOUNTMASTER_FUND_MGTCOMP_SEARCHBUTTON, 120);
        try {
            dmpGsPortalUtl.inputTextInLookUpField(ACCOUNTMASTER_PRU_GROUP_LE_NAME_SEARCH_BUTTON, map.get(AM_PRU_GROUP_LE_NAME), false);
            dmpGsPortalUtl.inputTextInLookUpField(ACCOUNTMASTER_NON_GROUP_LE_NAME_SEARCH_BUTTON, map.get(AM_NON_GROUP_LE_NAME), false);
            dmpGsPortalUtl.inputTextInLookUpField(ACCOUNTMASTER_SID_NAME_SEARCH_BUTTON, map.get(AM_SID_NAME), false);
            dmpGsPortalUtl.inputText(ACCOUNTMASTER_QFII_CN_FLAG_LOCATOR, map.get(AM_QFII_CN_FLAG), ENTER, false);
            dmpGsPortalUtl.inputText(ACCOUNTMASTER_STC_VN_FLAG_LOCATOR, map.get(AM_STC_VN_FLAG), ENTER, false);
            dmpGsPortalUtl.inputText(ACCOUNTMASTER_INVESTMENT_DISCRETION_LE_INVESTMENT_LOCATOR, map.get(AM_INVESTMENT_DISCRETION_LE_INVESTMENT_DISCRETION), ENTER, false);
            dmpGsPortalUtl.inputText(ACCOUNTMASTER_FINI_TAIWAN_LOCATOR, map.get(AM_FINI_TAIWAN_FLAG), ENTER, false);
            dmpGsPortalUtl.inputText(ACCOUNTMASTER_PPMA_FLAG_LOCATOR, map.get(AM_PPMA_FLAG), ENTER, false);
            dmpGsPortalUtl.inputText(ACCOUNTMASTER_SSH_FLAG_LOCATOR, map.get(AM_SSH_FLAG), ENTER, false);
            dmpGsPortalUtl.inputText(ACCOUNTMASTER_FUND_VEHICLE_TYPE_LOCATOR, map.get(AM_FUND_VEHICLE_TYPE), ENTER, false);
            dmpGsPortalUtl.inputText(ACCOUNTMASTER_INVESTMENT_DISCRETION_LE_VR_LOCATOR, map.get(AM_INVESTMENT_DISCRETION_LE_VR_DISCRETION), ENTER, false);
            return this;
        } catch (Exception e) {
            LOGGER.error(PROCESSING_FAILED, e);
            throw new CartException(CartExceptionType.PROCESSING_FAILED, PROCESSING_FAILED);
        }
    }

    public AccountMasterPage fillPartiesDetails(Map<String, String> map) {
        webTaskSvc.waitForElementToAppear(ACCOUNTMASTER_FUND_MGTCOMP_SEARCHBUTTON, 120);
        try {
            dmpGsPortalUtl.inputTextInLookUpField(ACCOUNTMASTER_FUND_MGTCOMP_SEARCHBUTTON, map.get(AM_FUND_MNGMT_COMP), false);
            dmpGsPortalUtl.inputTextInLookUpField(ACCOUNTMASTER_INVSTMGR_SEARCH_BUTTON, map.get(AM_INVEST_MNGR), false);
            dmpGsPortalUtl.inputTextInLookUpField(ACCOUNTMASTER_INVSTMGR_LEV3_LE_SEARCH_BUTTON, map.get(AM_INVEST_MNGR_LEV3), false);
            dmpGsPortalUtl.inputTextInLookUpField(ACCOUNTMASTER_INVSTMGR_LEV4_LE_SEARCH_BUTTON, map.get(AM_INVEST_MNGR_LEV4), false);
            dmpGsPortalUtl.inputTextInLookUpField(ACCOUNTMASTER_SUB_INVESTMENT_MANAGER_SEARCH_BUTTON, map.get(AM_SUB_INVST_MNGR), false);
            dmpGsPortalUtl.inputText(ACCOUNTMASTER_INVST_MANAGER_LOCATION_LOCATOR, map.get(AM_INVST_MNGR_LOCATION), ENTER, false);
            dmpGsPortalUtl.inputTextInLookUpField(ACCOUNTMASTER_ADVISOR_SEARCH_BUTTON, map.get(AM_ADVISOR), false);
            dmpGsPortalUtl.inputTextInLookUpField(ACCOUNTMASTER_TRUSTEE_LOCATOR, map.get(AM_TRUSTEE), false);
            dmpGsPortalUtl.inputText(ACCOUNTMASTER_CUSTODIAN_LOCATOR, map.get(AM_CUSTODIAN), ENTER, false);
            dmpGsPortalUtl.inputText(ACCOUNTMASTER_CUSTODIAN_ACCTNO_LOCATOR, map.get(AM_CUSTODIAL_ACCOUNT_NO), ENTER, false);
            dmpGsPortalUtl.inputText(ACCOUNTMASTER_ACCOUNTING_AGENT_LOCATOR, map.get(AM_ACCOUNTING_AGENT), ENTER, false);
            dmpGsPortalUtl.inputText(ACCOUNTMASTER_VALNAGENT_LOCATOR, map.get(AM_VALUATION_AGENT), ENTER, false);
            dmpGsPortalUtl.inputText(ACCOUNTMASTER_REGISTRAR_LOCATOR, map.get(AM_REGISTRAR), ENTER, false);
            dmpGsPortalUtl.inputText(ACCOUNTMASTER_SUBREGISTRAR_LOCATOR, map.get(AM_SUB_REGISTRER), ENTER, false);
            dmpGsPortalUtl.inputText(ACCOUNTMASTER_TRANSFER_AGENT_LOCATOR, map.get(AM_TRANSFER_AGENT), ENTER, false);
            dmpGsPortalUtl.inputText(ACCOUNTMASTER_SUBTRANSFER_AGENT_LOCATOR, map.get(AM_SUB_TRANSFER_AGENT), ENTER, false);
            dmpGsPortalUtl.inputText(ACCOUNTMASTER_GLOBAL_DISTRIBUTOR_LOCATOR, map.get(AM_GLOBAL_DISTRIBUTER), ENTER, false);
            dmpGsPortalUtl.inputText(ACCOUNTMASTER_FUND_ADMINISTRATOR_LOCATOR, map.get(AM_FUND_ADMIN), ENTER, false);
            dmpGsPortalUtl.inputText(ACCOUNTMASTER_CLIENT_NAME_LOCATOR, map.get(AM_CLIENT_NAME), ENTER, false);
            return this;
        } catch (Exception e) {
            LOGGER.error(PROCESSING_FAILED, e);
            throw new CartException(CartExceptionType.PROCESSING_FAILED, PROCESSING_FAILED);
        }
    }

    public AccountMasterPage fillDOPCashFlowTolerance(Map<String, String> map) {
        webTaskSvc.waitForElementToAppear(ACCOUNTMASTER_DOP_VS_ACTUAL_PORTFOLIO_SEARCH_BUTTON, 120);
        try {
            dmpGsPortalUtl.inputTextInLookUpField(ACCOUNTMASTER_DOP_VS_ACTUAL_PORTFOLIO_SEARCH_BUTTON, map.get(AM_DOP_VS_ACTUAL_PORTFOLIO), false);
            dmpGsPortalUtl.inputText(ACCOUNTMASTER_TARGET_PERCENT_LOCATOR, map.get(AM_TARGET_PERCENT), ENTER, false);
            dmpGsPortalUtl.inputText(ACCOUNTMASTER_LOWER_TOLERANCE_PERCENT_LOCATOR, map.get(AM_LOWER_TOLERANCE_PERCENT), ENTER, false);
            dmpGsPortalUtl.inputText(ACCOUNTMASTER_UPPER_TOLERANCE_PERCENT_LOCATOR, map.get(AM_UPPER_TOLERANCE_PERCENT), ENTER, false);

            return this;
        } catch (Exception e) {
            LOGGER.error(PROCESSING_FAILED, e);
            throw new CartException(CartExceptionType.PROCESSING_FAILED, PROCESSING_FAILED);
        }
    }

    public Map<String, String> getAccountMasterDetails() {
        Map<String, String> dataMap = new HashMap<>();
        Map<String, String> portfolioDetails = this.getAccountMasterPortfolioDetails();
        Map<String, String> fundDetails = this.getAccountMasterFundDetails();
        Map<String, String> lBUIdentifiersTabDetails = this.getAccountMasterLBUIdentifiersTabDetails();
        Map<String, String> xReferenceTabDetails = this.getAccountMasterXReferenceIdentifiersTabDetails();
        Map<String, String> partiesDetails = this.getPartiesDetails();
        Map<String, String> ssrDetails = this.getSsrDetails();
        Map<String, String> bmDetails = this.getBMDetails();
        Map<String, String> driftedBmDetails = this.getDOPBMDetails();
        Map<String, String> dopCashFlowTolerance = this.getDOPCashFlowTolerance();

        dataMap.putAll(portfolioDetails);
        dataMap.putAll(fundDetails);
        dataMap.putAll(lBUIdentifiersTabDetails);
        dataMap.putAll(xReferenceTabDetails);
        dataMap.putAll(partiesDetails);
        dataMap.putAll(ssrDetails);
        dataMap.putAll(bmDetails);
        dataMap.putAll(driftedBmDetails);
        dataMap.putAll(dopCashFlowTolerance);

        return dataMap;
    }


    private Map<String, String> getAccountMasterPortfolioDetails() {
        Map<String, String> dataMap = new HashMap<>();
        dataMap.put(AM_PORTFOLIO_NAME, webTaskSvc.getWebElementAttribute(ACCOUNTMASTER_PORTFOLIONAME_LOCATOR, VALUE));
        dataMap.put(AM_PORTFOLIO_LEGAL_NAME, webTaskSvc.getWebElementAttribute(ACCOUNTMASTER_PORTFOLIOLEGALNAME_LOCATOR, VALUE));
        dataMap.put(AM_INCEPTION_DATE, webTaskSvc.getWebElementAttribute(ACCOUNTMASTER_INCEPTIONDATE_LOCATOR, VALUE));
        dataMap.put(AM_ACTIVE_FLAG, webTaskSvc.getWebElementAttribute(ACCOUNTMASTER_ACTIVEFLAG_LOCATOR, VALUE));
        dataMap.put(AM_PORTFOLIO_DOMICILE, webTaskSvc.getWebElementAttribute(ACCOUNTMASTER_PORTFOLIODOMICILE_LOCATOR, VALUE));
        dataMap.put(AM_INVST_TEAM, webTaskSvc.getWebElementAttribute(ACCOUNTMASTER_INVESTMENT_TEAM_LOCATOR, VALUE));
        dataMap.put(AM_BASE_CCY, webTaskSvc.getWebElementAttribute(ACCOUNTMASTER_BASECCY_LOCATOR, VALUE));
        dataMap.put(AM_PORTFOLIO_LEI, webTaskSvc.getWebElementAttribute(ACCOUNTMASTER_PORTFOLIOLEI_LOCATOR, VALUE));
        dataMap.put(AM_PROCESSED, webTaskSvc.getWebElementAttribute(ACCOUNTMASTER_PROCESSED_UNPROCESSED_LOCATOR, VALUE));
        return dataMap;
    }

    private Map<String, String> getAccountMasterFundDetails() {
        Map<String, String> dataMap = new HashMap<>();

        dataMap.put(AM_FUND_CATEGORY, webTaskSvc.getWebElementAttribute(ACCOUNTMASTER_FUNDCATEGORY_LOCATOR, VALUE));
        dataMap.put(AM_FUND_PLATFORM, webTaskSvc.getWebElementAttribute(ACCOUNTMASTER_FUNDPLATFORM_LOCATOR, VALUE));
        dataMap.put(AM_FUND_TYPE, webTaskSvc.getWebElementAttribute(ACCOUNTMASTER_FUNDTYPE_LOCATOR, VALUE));
        dataMap.put(AM_INVST_STRATEGY, webTaskSvc.getWebElementAttribute(ACCOUNTMASTER_INVESTMENT_STRATEGY_LOCATOR, VALUE));
        dataMap.put(AM_MOTHER_FUND, webTaskSvc.getWebElementAttribute(ACCOUNTMASTER_MNG_MOTHERFUND_LOCATOR, VALUE));
        dataMap.put(AM_FUND_REGION, webTaskSvc.getWebElementAttribute(ACCOUNTMASTER_FUND_REGION_LOCATOR, VALUE));
        return dataMap;
    }

    private Map<String, String> getAccountMasterLBUIdentifiersTabDetails() {
        Map<String, String> dataMap = new HashMap<>();

        dmpGsPortalUtl.selectGSTab(LBUIDENTIFIER_TAB);
        dataMap.put(AM_TSTAR_CODE, dmpGsPortalUtl.getWebElementAttribute(ACCOUNTMASTER_TSTARPORTCODE_LOCATOR, VALUE, false));
        dataMap.put(AM_MFUND_CODE, dmpGsPortalUtl.getWebElementAttribute(ACCOUNTMASTER_DBANKPORTCODE_LOCATOR, VALUE, false));
        dataMap.put(AM_DBANK_CODE, dmpGsPortalUtl.getWebElementAttribute(ACCOUNTMASTER_MFUNDPORTCODE_LOCATOR, VALUE, false));
        dataMap.put(AM_DMS_CODE, dmpGsPortalUtl.getWebElementAttribute(ACCOUNTMASTER_DMSPORTCODE_LOCATOR, VALUE, false));
        dataMap.put(AM_KOREA_CODE, dmpGsPortalUtl.getWebElementAttribute(ACCOUNTMASTER_KOREAMD_PORTCODE_LOCATOR, VALUE, false));
        dataMap.put(AM_THAILAND_CODE, dmpGsPortalUtl.getWebElementAttribute(ACCOUNTMASTER_THAILAND_PORTFOLIO_CODE_LOCATOR, VALUE, false));
        //TODO once the change went to production, we can update optional flag as false
        dataMap.put(AM_HIPORT_SUFFIX_CODE, dmpGsPortalUtl.getWebElementAttribute(ACCOUNTMASTER_HIPORT_SUFFIX_CODE_LOCATOR, VALUE, true));
        return dataMap;
    }

    private Map<String, String> getAccountMasterXReferenceIdentifiersTabDetails() {

        Map<String, String> dataMap = new HashMap<>();

        dmpGsPortalUtl.selectGSTab(XREFERENCE_TAB);

        dataMap.put(AM_BRS_ID, webTaskSvc.getWebElementAttribute(ACCOUNTMASTER_BRS_PORTID_LOCATOR, VALUE));
        dataMap.put(AM_BRS_LEGAL_ENTITY, webTaskSvc.getWebElementAttribute(ACCOUNTMASTER_BRS_LEGALENTITY_TICKER_LOCATOR, VALUE));
        dataMap.put(AM_BRS_BUSINESS_LINE, webTaskSvc.getWebElementAttribute(ACCOUNTMASTER_BRS_BUSINESSLINE_TICKER_LOCATOR, VALUE));
        dataMap.put(AM_BNP_ID, webTaskSvc.getWebElementAttribute(ACCOUNTMASTER_BNP_PORTID_LOCATOR, VALUE));
        dataMap.put(AM_IRP_CODE, webTaskSvc.getWebElementAttribute(ACCOUNTMASTER_IRPCODE_LOCATOR, VALUE));
        dataMap.put(SC_FUNDIPEDIA_FUND_ID, webTaskSvc.getWebElementAttribute(ACCOUNTMASTER_IDENTIFIER_FUNDIPEDIA_FUND_ID, VALUE));
        dataMap.put(SC_FUNDIPEDIA_PORTFOLIO_ID, webTaskSvc.getWebElementAttribute(ACCOUNTMASTER_IDENTIFIER_FUNDIPEDIA_PORTFOLIO_ID, VALUE));
        return dataMap;
    }

    private Map<String, String> getPartiesDetails() {

        Map<String, String> dataMap = new HashMap<>();

        dataMap.put(AM_INVEST_MNGR_LEV3, webTaskSvc.getWebElementAttribute(ACCOUNTMASTER_INVSTMGR_LEV3_LE_LOCATOR, VALUE));
        dataMap.put(AM_INVEST_MNGR_LEV4, webTaskSvc.getWebElementAttribute(ACCOUNTMASTER_INVSTMGR_LEV4_LE_LOCATOR, VALUE));


        return dataMap;
    }

    private Map<String, String> getSsrDetails() {

        Map<String, String> dataMap = new HashMap<>();

        dataMap.put(AM_PRU_GROUP_LE_NAME, webTaskSvc.getWebElementAttribute(ACCOUNTMASTER_PRU_GROUP_LE_NAME_LOCATOR, VALUE));
        dataMap.put(AM_SID_NAME, webTaskSvc.getWebElementAttribute(ACCOUNTMASTER_SID_NAME_LOCATOR, VALUE));
        dataMap.put(AM_NON_GROUP_LE_NAME, webTaskSvc.getWebElementAttribute(ACCOUNTMASTER_NON_GROUP_LE_NAME_LOCATOR, VALUE));
        dataMap.put(AM_QFII_CN_FLAG, webTaskSvc.getWebElementAttribute(ACCOUNTMASTER_QFII_CN_FLAG_LOCATOR, VALUE));
        dataMap.put(AM_STC_VN_FLAG, webTaskSvc.getWebElementAttribute(ACCOUNTMASTER_STC_VN_FLAG_LOCATOR, VALUE));
        dataMap.put(AM_INVESTMENT_DISCRETION_LE_INVESTMENT_DISCRETION, webTaskSvc.getWebElementAttribute(ACCOUNTMASTER_INVESTMENT_DISCRETION_LE_INVESTMENT_LOCATOR, VALUE));
        dataMap.put(AM_FINI_TAIWAN_FLAG, webTaskSvc.getWebElementAttribute(ACCOUNTMASTER_FINI_TAIWAN_LOCATOR, VALUE));
        dataMap.put(AM_PPMA_FLAG, webTaskSvc.getWebElementAttribute(ACCOUNTMASTER_PPMA_FLAG_LOCATOR, VALUE));
        dataMap.put(AM_SSH_FLAG, webTaskSvc.getWebElementAttribute(ACCOUNTMASTER_SSH_FLAG_LOCATOR, VALUE));
        dataMap.put(AM_FUND_VEHICLE_TYPE, webTaskSvc.getWebElementAttribute(ACCOUNTMASTER_FUND_VEHICLE_TYPE_LOCATOR, VALUE));
        dataMap.put(AM_INVESTMENT_DISCRETION_LE_VR_DISCRETION, webTaskSvc.getWebElementAttribute(ACCOUNTMASTER_INVESTMENT_DISCRETION_LE_VR_LOCATOR, VALUE));

        return dataMap;
    }

    public AccountMasterPage fillBenchMarkDetails(Map<String, String> map) {
        webTaskSvc.waitForElementToAppear(ACCOUNTMASTER_ESI_PRIM_BNCHMRK_LOCATOR, 120);
        try {
            dmpGsPortalUtl.inputTextInLookUpField(ACCOUNTMASTER_ESI_PRIM_BNCHMRK_SEARCH_BUTTON, map.get(AM_BENCHMARK_PRIMARY_BM), false);
            dmpGsPortalUtl.inputTextInLookUpField(ACCOUNTMASTER_ESI_SEC_BNCHMRK_SEARCH_BUTTON, map.get(AM_BENCHMARK_SECONDARY_BM), false);
            dmpGsPortalUtl.inputTextInLookUpField(ACCOUNTMASTER_BNP_L1_PRMY_BNCHMRK_SEARCH_BUTTON, map.get(AM_BENCHMARK_L1_PRIMARY_BM), false);
            dmpGsPortalUtl.inputTextInLookUpField(ACCOUNTMASTER_BNP_L1_SEC_BNCHMRK_SEARCH_BUTTON, map.get(AM_BENCHMARK_L1_SECONDARY_BM), false);
            dmpGsPortalUtl.inputTextInLookUpField(ACCOUNTMASTER_BNP_L3_PRMY_BNCHMRK_SEARCH_BUTTON, map.get(AM_BENCHMARK_L3_PRIMARY_BM), false);
            return this;
        } catch (Exception e) {
            LOGGER.error(PROCESSING_FAILED, e);
            throw new CartException(CartExceptionType.PROCESSING_FAILED, PROCESSING_FAILED);
        }
    }

    private Map<String, String> getBMDetails() {

        Map<String, String> dataMap = new HashMap<>();

        dataMap.put(AM_BENCHMARK_PRIMARY_BM, webTaskSvc.getWebElementAttribute(ACCOUNTMASTER_ESI_PRIM_BNCHMRK_LOCATOR, VALUE));
        dataMap.put(AM_BENCHMARK_SECONDARY_BM, webTaskSvc.getWebElementAttribute(ACCOUNTMASTER_ESI_SEC_BNCHMRK_LOCATOR, VALUE));
        dataMap.put(AM_BENCHMARK_L1_PRIMARY_BM, webTaskSvc.getWebElementAttribute(ACCOUNTMASTER_BNP_L1_PRMY_BNCHMRK_LOCATOR, VALUE));
        dataMap.put(AM_BENCHMARK_L1_SECONDARY_BM, webTaskSvc.getWebElementAttribute(ACCOUNTMASTER_BNP_L1_SEC_BNCHMRK_LOCATOR, VALUE));
        dataMap.put(AM_BENCHMARK_L3_PRIMARY_BM, webTaskSvc.getWebElementAttribute(ACCOUNTMASTER_BNP_L3_PRMY_BNCHMRK_LOCATOR, VALUE));

        return dataMap;
    }

    public AccountMasterPage fillDriftedBenchmarkDetails(Map<String, String> map) {
        try {
            webTaskSvc.scrollElementIntoView(ACCOUNTMASTER_DOP_BM_ADD_LOCATOR);
            if (!Strings.isNullOrEmpty(map.get(AM_DOP_EIS_BM))) {
                if (webTaskSvc.xpathResultsEmpty(ACCOUNTMASTER_DOP_EIS_BM_SEARCH_LOCATOR.substring(6))) {
                    webTaskSvc.click(ACCOUNTMASTER_DOP_BM_ADD_LOCATOR);
                }
                webTaskSvc.waitForElementToAppear(ACCOUNTMASTER_DOP_EIS_BM_SEARCH_LOCATOR, 10);
                dmpGsPortalUtl.inputTextInLookUpField(ACCOUNTMASTER_DOP_EIS_BM_SEARCH_LOCATOR, map.get(AM_DOP_EIS_BM), false);
                stateSvc.setStringVar("ALADDIN_BENCHMARK_CODE", webTaskSvc.getWebElementAttribute(ACCOUNTMASTER_DOP_ALADDIN_BM_LOCATOR, VALUE));
                scenarioUtil.write("ALADDIN_BENCHMARK_CODE => " + webTaskSvc.getWebElementAttribute(ACCOUNTMASTER_DOP_ALADDIN_BM_LOCATOR, VALUE));
            }
            return this;
        } catch (Exception e) {
            LOGGER.error(PROCESSING_FAILED, e);
            throw new CartException(CartExceptionType.PROCESSING_FAILED, PROCESSING_FAILED);
        }
    }

    private Map<String, String> getDOPBMDetails() {

        Map<String, String> dataMap = new HashMap<>();
        webTaskSvc.scrollElementIntoView(ACCOUNTMASTER_DOP_BM_ADD_LOCATOR);
        if (!webTaskSvc.xpathResultsEmpty(ACCOUNTMASTER_DOP_EIS_BM_SEARCH_LOCATOR.substring(6))) {
            dataMap.put(AM_DOP_EIS_BM, webTaskSvc.getWebElementAttribute(ACCOUNTMASTER_DOP_EIS_BM_LOCATOR, VALUE));
            dataMap.put(AM_DOP_ALADDIN_BM, webTaskSvc.getWebElementAttribute(ACCOUNTMASTER_DOP_ALADDIN_BM_LOCATOR, VALUE));
        }
        return dataMap;
    }

    private Map<String, String> getDOPCashFlowTolerance() {

        Map<String, String> dataMap = new HashMap<>();
        webTaskSvc.scrollElementIntoView(ACCOUNTMASTER_DOP_VS_ACTUAL_PORTFOLIO_LOCATOR);

        dataMap.put(AM_DOP_VS_ACTUAL_PORTFOLIO, webTaskSvc.getWebElementAttribute(ACCOUNTMASTER_DOP_VS_ACTUAL_PORTFOLIO_LOCATOR, VALUE));
        dataMap.put(AM_TARGET_PERCENT, webTaskSvc.getWebElementAttribute(ACCOUNTMASTER_TARGET_PERCENT_LOCATOR, VALUE));
        dataMap.put(AM_LOWER_TOLERANCE_PERCENT, webTaskSvc.getWebElementAttribute(ACCOUNTMASTER_LOWER_TOLERANCE_PERCENT_LOCATOR, VALUE));
        dataMap.put(AM_UPPER_TOLERANCE_PERCENT, webTaskSvc.getWebElementAttribute(ACCOUNTMASTER_UPPER_TOLERANCE_PERCENT_LOCATOR, VALUE));

        return dataMap;
    }
}


