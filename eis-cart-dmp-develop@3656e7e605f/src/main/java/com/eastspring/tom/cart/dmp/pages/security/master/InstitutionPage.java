package com.eastspring.tom.cart.dmp.pages.security.master;

import com.eastspring.tom.cart.core.CartException;
import com.eastspring.tom.cart.core.CartExceptionType;
import com.eastspring.tom.cart.core.svc.StateSvc;
import com.eastspring.tom.cart.core.svc.ThreadSvc;
import com.eastspring.tom.cart.core.svc.WebTaskSvc;
import com.eastspring.tom.cart.dmp.pages.HomePage;
import com.eastspring.tom.cart.dmp.steps.DmpGsPortalSteps;
import com.eastspring.tom.cart.dmp.utl.DmpGsPortalUtl;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;

import java.util.HashMap;
import java.util.LinkedHashMap;
import java.util.Map;

import static com.eastspring.tom.cart.dmp.mdl.GSUIFields.*;

public class InstitutionPage {

    private static final Logger LOGGER = LoggerFactory.getLogger(InstitutionPage.class);

    public static final String ENTER = "ENTER";
    public static final String VALUE = "value";
    public static final String INSTITUTION_NAME_INPUT = "cssSelector:div[id='FinancialInstitution.FinancialInstitutionDetails.FinancialInstitutionName'] input";
    public static final String INSTITUTION_DESC_INPUT = "cssSelector:div[id$='InstitutionDescription'] textarea";
    public static final String PREFERRED_IDENTIFIER_NAME_INPUT = "cssSelector:div[id$='PreferredIdentifierName'] input";
    public static final String PREFERRED_IDENTIFIER_VALUE_INPUT = "cssSelector:div[id$='PreferredIdentifierValue'] input";
    public static final String COUNTRY_INCORPORATION_INPUT = "cssSelector:div[id$='CountryOfIncorporation'] input";
    public static final String COUNTRY_DOMICILE_INPUT = "cssSelector:div[id$='CountryOfDomicile'] input";
    public static final String INSTITUTION_STATUS_INPUT = "cssSelector:div[id$='InstitutionStatus'] input";
    public static final String INSTITUTION_STATUS_DATE_INPUT = "cssSelector:div[id$='EISInstitutionStatusDateTime'] input";
    public static final String DESC_INSTITUTION_NAME_INPUT = "cssSelector:div[id$='InstitutionName'] input";
    public static final String DESC_INSTITUTION_DESC_INPUT = "cssSelector:div[id$='InstitutionLongDescription'] input";
    public static final String DESC_INSTITUTION_LANGUAGE_INPUT = "cssSelector:div[id$='InstitutionLanguage'] input";
    public static final String DESC_INSTITUTION_DESC_USAGE_INPUT = "cssSelector:div[id$='InstitutionDescriptionUsage'] input";
    public static final String IDENTIFIERS_INHOUSE_ID_INPUT = "cssSelector:div[id$='InhouseIdentifier'] input";
    public static final String IDENTIFIERS_HIP_BROKER_ID_INPUT = "cssSelector:div[id$='EISHIPBrokerID'] input";
    public static final String IDENTIFIERS_BRS_ISSUER_ID_INPUT = "cssSelector:div[id$='EISBRSIssuerID'] input";
    public static final String CLASSIFICATION_ISSUER_REVIEW_INPUT = "cssSelector:div[id$='EISIssuerReviewed'] input";
    public static final String LBU_IDENTIFIERS_COMPANY_NO_INPUT = "cssSelector:div[id$='EISCompanyNumber'] input";
    public static final String LBU_IDENTIFIERS_LEGAL_ENTITY_ID_INPUT = "cssSelector:div[id='FinancialInstitution.EISFinancialInstLBUIdentifiers.EISRCRLBULeID'] input";
    public static final String SSDR_ORGCHART_REGULATOR_INPUT = "cssSelector:div[id$='EISOrgChartREGLTOR'] input";
    public static final String SSDR_ORGCHART_PERCENT_OWNED_INPUT = "cssSelector:div[id$='EISFFRLParentPercentOwned'] input";
    public static final String ADDRESS_DETAILS_ADDRESS_LINE1_INPUT = "cssSelector:div[id$='FinsAddressLine1'] input";
    public static final String ADDRESS_DETAILS_ADDRESS_LINE2_INPUT = "cssSelector:div[id$='FinsAddressLine2'] input";
    public static final String ADDRESS_DETAILS_COUNTRY_NAME_INPUT = "cssSelector:div[id$='FinsCountryName'] input";
    public static final String ADDRESS_DETAILS_ADDRESS_TYPE_INPUT = "cssSelector:div[id$='FinsAddressType'] input";
    public static final String INSTITUTION_PARENT_COMPANY_SEARCH_BUTON = "cssSelector:div[id*='ParentCompanyOf'] div[tabindex='0'][role='button']";
    public static final String ADDRESS_DETAILS_MAILING_ADDRESS_BUTTON = "xpath://div[@class='v-slot v-slot-icon-link v-slot-link v-slot-gsMargin']/div[@role='button']";
    public static final String IDENTIFIERS_BRS_COUNTERPARTY_CODE_INPUT = "cssSelector:div[id$='EISBRSCounterpartyCode'] input";
    public static final String IDENTIFIERS_UNI_BUS_NUMBER_INPUT = "cssSelector:div[id$='EISFinancialInstitutionUNIBUSNUM'] input";
    public static final String IDENTIFIERS_BB_COMPANY_ID_INPUT = "cssSelector:div[id$='BBCompanyID'] input";
    public static final String IDENTIFIERS_LEGAL_ENTITY_ID_INPUT = "cssSelector:div[id$='FinancialLegalEntityIdentifier'] input";
    public static final String IDENTIFIERS_REUTERS_PARTY_ID_INPUT = "cssSelector:div[id$='ReutersPartyId'] input";
    public static final String IDENTIFIERS_BB_COMP_EXCHANGE_INPUT = "cssSelector:div[id$='EISBBCompositeExchange'] input";
    public static final String IDENTIFIERS_BRS_TRADE_COUNTERPARTY_CODE_INPUT = "cssSelector:div[id$='EISBRSTradeCounterpartyCode'] input";
    public static final String IDENTIFIERS_GENERIC_FINS_ID_INPUT = "cssSelector:div[id$='EISGenericFINSID'] input";
    public static final String IDENTIFIERS_ISSUER_TICKER_INPUT = "cssSelector:div[id$='EISIssuerTicker'] input";
    public static final String IDENTIFIERS_FINS_MNEMONIC_INPUT = "cssSelector:div[id$='EISFinsMnemonic'] input";
    public static final String IDENTIFIERS_REUTERS_ORG_ID_INPUT = "cssSelector:div[id$='ReutersOrganisationId'] input";
    public static final String IDENTIFIERS_REUTERS_ENTITY_LEI_INPUT = "cssSelector:div[id$='EISTRDSSEntityLEI'] input";
    public static final String SSDR_FORM_13F_CIK_INPUT = "cssSelector:div[id$='EISSSDRForm13FCIK'] input";
    public static final String SSDR_FORM_13F_FILE_NO_INPUT = "cssSelector:div[id$='EISSSDRForm13FFileNumber'] input";


    public static final String SEARCH_TYPE = "Financial Institution";


    @Autowired
    private HomePage homePage;

    @Autowired
    private WebTaskSvc webTaskSvc;

    @Autowired
    private DmpGsPortalUtl dmpGsPortalUtl;

    @Autowired
    private ThreadSvc threadSvc;

    @Autowired
    private StateSvc stateSvc;

    @Autowired
    private DmpGsPortalSteps dmpGsPortalSteps;


    private boolean mandatoryFlag = true;

    private void setMandatoryFlag(final boolean isAppendModeOn) {
        if (isAppendModeOn) {
            mandatoryFlag = false;
        }
    }

    public InstitutionPage invokeInstitutionScreen() {
        LOGGER.debug("Navigating to Institution Screen");
        homePage.clickMenuDropdown()
                .selectMenu("Security Master")
                .selectMenu("Institution");
        homePage.verifyGSTabDisplayed("Institution");
        return this;
    }

    public InstitutionPage invokeSetup() {
        dmpGsPortalUtl.invokeSetUpScreen(null, null, null);
        return this;
    }

    public InstitutionPage fillInstitutionDetails(final LinkedHashMap<String, String> map, boolean isInUpdateMode) {
        try {
            this.setMandatoryFlag(isInUpdateMode);
            dmpGsPortalUtl.inputText(INSTITUTION_NAME_INPUT, map.get(INST_INSTITUTION_NAME), ENTER, mandatoryFlag);
            dmpGsPortalUtl.inputText(INSTITUTION_DESC_INPUT, map.get(INST_INSTITUTION_DESC), null, false);
            dmpGsPortalUtl.inputText(PREFERRED_IDENTIFIER_NAME_INPUT, map.get(INST_PREFERRED_IDENTIFIER_NAME), ENTER, false);
            dmpGsPortalUtl.inputText(PREFERRED_IDENTIFIER_VALUE_INPUT, map.get(INST_PREFERRED_IDENTIFIER_VALUE), ENTER, false);
            dmpGsPortalUtl.inputText(COUNTRY_INCORPORATION_INPUT, map.get(INST_COUNTRY_OF_INCORPORATION), ENTER, false);
            dmpGsPortalUtl.inputText(COUNTRY_DOMICILE_INPUT, map.get(INST_COUNTRY_OF_DOMICILE), ENTER, false);
            dmpGsPortalUtl.inputText(INSTITUTION_STATUS_INPUT, map.get(INST_INSTITUTION_STATUS), ENTER, false);
            dmpGsPortalUtl.inputText(INSTITUTION_STATUS_DATE_INPUT, map.get(INST_INSTITUTION_STATUS_DATE_TIME), ENTER, false);
            dmpGsPortalUtl.inputTextInLookUpField(INSTITUTION_PARENT_COMPANY_SEARCH_BUTON, map.get(INST_PARENT_COMPANY), false); //Added new for EISDEV-5276
        } catch (Exception e) {
            LOGGER.error("Processing failed while filling Institution details!!", e);
            throw new CartException(CartExceptionType.PROCESSING_FAILED, "Processing failed while filling Institution details!!");
        }
        return this;
    }

    public InstitutionPage switchToTab(final String tabName) {
        webTaskSvc.click("xpath://div[@class='v-captiontext'][text()='" + tabName + "']/ancestor::td");
        threadSvc.sleepMillis(500);
        return this;
    }

    public InstitutionPage invokeAddDetails() {
        dmpGsPortalUtl.addNewDetails();
        threadSvc.sleepSeconds(1);
        return this;
    }

    public InstitutionPage fillFinInstitutionDescription(final LinkedHashMap<String, String> map) {
        try {
            dmpGsPortalUtl.inputText(DESC_INSTITUTION_NAME_INPUT, map.get(INST_INSTITUTION_NAME), ENTER, true);
            dmpGsPortalUtl.inputText(DESC_INSTITUTION_DESC_INPUT, map.get(INST_INSTITUTION_DESC), ENTER, false);
            dmpGsPortalUtl.inputText(DESC_INSTITUTION_LANGUAGE_INPUT, map.get(INST_DESC_INSTITUTION_LANGUAGE), ENTER, false);
            dmpGsPortalUtl.inputText(DESC_INSTITUTION_DESC_USAGE_INPUT, map.get(INST_DESC_INSTITUTION_DESC_USAGE), ENTER, false);
        } catch (Exception e) {
            LOGGER.error("Processing failed while filling Description details!!", e);
            throw new CartException(CartExceptionType.PROCESSING_FAILED, "Processing failed while filling Description details!!");
        }
        return this;
    }

    public InstitutionPage fillFinInstitutionIdentifiers(final LinkedHashMap<String, String> map) {
        try {
            dmpGsPortalUtl.inputText(IDENTIFIERS_INHOUSE_ID_INPUT, map.get(INST_INHOUSE_IDENTIFIER), ENTER, false);
            dmpGsPortalUtl.inputText(IDENTIFIERS_HIP_BROKER_ID_INPUT, map.get(INST_HIP_BROKER_ID), ENTER, false);
            dmpGsPortalUtl.inputText(IDENTIFIERS_BRS_ISSUER_ID_INPUT, map.get(INST_BRS_ISSUER_ID), ENTER, false);
            dmpGsPortalUtl.inputText(IDENTIFIERS_BRS_COUNTERPARTY_CODE_INPUT, map.get(INST_BRS_COUNTERPARTY_CODE), ENTER, false);
            dmpGsPortalUtl.inputText(IDENTIFIERS_UNI_BUS_NUMBER_INPUT, map.get(INST_UNIFIED_BUS_NUM), ENTER, false);
            dmpGsPortalUtl.inputText(IDENTIFIERS_BB_COMPANY_ID_INPUT, map.get(INST_BB_COMPANY_ID), ENTER, false);
            dmpGsPortalUtl.inputText(IDENTIFIERS_LEGAL_ENTITY_ID_INPUT, map.get(INST_LEGAL_ENTITY_ID), ENTER, false);
            dmpGsPortalUtl.inputText(IDENTIFIERS_REUTERS_PARTY_ID_INPUT, map.get(INST_REUTERS_PARTY_ID), ENTER, false);
            dmpGsPortalUtl.inputText(IDENTIFIERS_BB_COMP_EXCHANGE_INPUT, map.get(INST_BB_COMP_EXCHANGE), ENTER, false);
            dmpGsPortalUtl.inputText(IDENTIFIERS_BRS_TRADE_COUNTERPARTY_CODE_INPUT, map.get(INST_BRS_TRD_COUNTERPARTY_CODE), ENTER, false);
            dmpGsPortalUtl.inputText(IDENTIFIERS_GENERIC_FINS_ID_INPUT, map.get(INST_GENERIC_FINS_ID), ENTER, false);
            dmpGsPortalUtl.inputText(IDENTIFIERS_ISSUER_TICKER_INPUT, map.get(INST_ISSUER_TICKER), ENTER, false);
            dmpGsPortalUtl.inputText(IDENTIFIERS_FINS_MNEMONIC_INPUT, map.get(INST_FINS_MNEMONIC), ENTER, false);
            dmpGsPortalUtl.inputText(IDENTIFIERS_REUTERS_ORG_ID_INPUT, map.get(INST_REUTERS_ORG_ID), ENTER, false);
            dmpGsPortalUtl.inputText(IDENTIFIERS_REUTERS_ENTITY_LEI_INPUT, map.get(INST_REUTERS_ENTITY_LEI), ENTER, false);
        } catch (Exception e) {
            LOGGER.error("Processing failed while filling Identifier details!!", e);
            throw new CartException(CartExceptionType.PROCESSING_FAILED, "Processing failed while filling Identifier details!!");
        }
        return this;
    }

    public InstitutionPage fillFinInstitutionClassification(final LinkedHashMap<String, String> map) {
        try {
            dmpGsPortalUtl.inputText(CLASSIFICATION_ISSUER_REVIEW_INPUT, map.get(INST_CLASSIFICATION_IS_ISSUER_REVIEWED), ENTER, false);
        } catch (Exception e) {
            LOGGER.error("Processing failed while filling Classification details!!", e);
            throw new CartException(CartExceptionType.PROCESSING_FAILED, "Processing failed while filling Classification details!!");
        }
        return this;
    }

    public InstitutionPage searchInstitution(String searchValue) {
        homePage.globalSearchAndWaitTillSuccess(searchValue, SEARCH_TYPE, 120);
        threadSvc.sleepSeconds(1);
        return this;
    }

    public boolean verifyInstitutionIsCreated(final String name) {
        this.searchInstitution(name);
        boolean searchRecordAvailable = dmpGsPortalUtl.isSearchRecordAvailable(name);
        dmpGsPortalSteps.closeActiveGsTab();
        return searchRecordAvailable;
    }

    public Map<String, String> getInstitutionDetails() {
        Map<String, String> dataMap = new HashMap<>();
        dataMap.put(INST_INSTITUTION_NAME, webTaskSvc.getWebElementAttribute(INSTITUTION_NAME_INPUT, VALUE));
        dataMap.put(INST_INSTITUTION_DESC, webTaskSvc.getWebElementAttribute(INSTITUTION_DESC_INPUT, VALUE));
        dataMap.put(INST_PREFERRED_IDENTIFIER_NAME, webTaskSvc.getWebElementAttribute(PREFERRED_IDENTIFIER_NAME_INPUT, VALUE));
        dataMap.put(INST_PREFERRED_IDENTIFIER_VALUE, webTaskSvc.getWebElementAttribute(PREFERRED_IDENTIFIER_VALUE_INPUT, VALUE));
        dataMap.put(INST_COUNTRY_OF_INCORPORATION, webTaskSvc.getWebElementAttribute(COUNTRY_INCORPORATION_INPUT, VALUE));
        dataMap.put(INST_COUNTRY_OF_DOMICILE, webTaskSvc.getWebElementAttribute(COUNTRY_DOMICILE_INPUT, VALUE));
        dataMap.put(INST_INSTITUTION_STATUS, webTaskSvc.getWebElementAttribute(INSTITUTION_STATUS_INPUT, VALUE));
        dataMap.put(INST_INSTITUTION_STATUS_DATE_TIME, webTaskSvc.getWebElementAttribute(INSTITUTION_STATUS_DATE_INPUT, VALUE));
        return dataMap;
    }

    public Map<String, String> getFinInstitutionIdentifiers() {
        Map<String, String> dataMap = new HashMap<>();
        dataMap.put(INST_INHOUSE_IDENTIFIER, webTaskSvc.getWebElementAttribute(IDENTIFIERS_INHOUSE_ID_INPUT, VALUE));
        dataMap.put(INST_BRS_ISSUER_ID, webTaskSvc.getWebElementAttribute(IDENTIFIERS_BRS_ISSUER_ID_INPUT, VALUE));
        dataMap.put(INST_HIP_BROKER_ID, webTaskSvc.getWebElementAttribute(IDENTIFIERS_HIP_BROKER_ID_INPUT, VALUE));
        dataMap.put(INST_BRS_COUNTERPARTY_CODE, webTaskSvc.getWebElementAttribute(IDENTIFIERS_BRS_COUNTERPARTY_CODE_INPUT, VALUE));
        dataMap.put(INST_UNIFIED_BUS_NUM, webTaskSvc.getWebElementAttribute(IDENTIFIERS_UNI_BUS_NUMBER_INPUT, VALUE));
        dataMap.put(INST_BB_COMPANY_ID, webTaskSvc.getWebElementAttribute(IDENTIFIERS_BB_COMPANY_ID_INPUT, VALUE));
        dataMap.put(INST_LEGAL_ENTITY_ID, webTaskSvc.getWebElementAttribute(IDENTIFIERS_LEGAL_ENTITY_ID_INPUT, VALUE));
        dataMap.put(INST_REUTERS_PARTY_ID, webTaskSvc.getWebElementAttribute(IDENTIFIERS_REUTERS_PARTY_ID_INPUT, VALUE));
        dataMap.put(INST_BB_COMP_EXCHANGE, webTaskSvc.getWebElementAttribute(IDENTIFIERS_BB_COMP_EXCHANGE_INPUT, VALUE));
        dataMap.put(INST_BRS_TRD_COUNTERPARTY_CODE, webTaskSvc.getWebElementAttribute(IDENTIFIERS_BRS_TRADE_COUNTERPARTY_CODE_INPUT, VALUE));
        dataMap.put(INST_GENERIC_FINS_ID, webTaskSvc.getWebElementAttribute(IDENTIFIERS_GENERIC_FINS_ID_INPUT, VALUE));
        dataMap.put(INST_ISSUER_TICKER, webTaskSvc.getWebElementAttribute(IDENTIFIERS_ISSUER_TICKER_INPUT, VALUE));
        dataMap.put(INST_FINS_MNEMONIC, webTaskSvc.getWebElementAttribute(IDENTIFIERS_FINS_MNEMONIC_INPUT, VALUE));
        dataMap.put(INST_REUTERS_ORG_ID, webTaskSvc.getWebElementAttribute(IDENTIFIERS_REUTERS_ORG_ID_INPUT, VALUE));
        dataMap.put(INST_REUTERS_ENTITY_LEI, webTaskSvc.getWebElementAttribute(IDENTIFIERS_REUTERS_ENTITY_LEI_INPUT, VALUE));
        return dataMap;
    }

    //New method added for EISDEV-5276
    public InstitutionPage fillFinInstitutionLbuIdentifiers(final LinkedHashMap<String, String> map) {
        try {
            dmpGsPortalUtl.inputText(LBU_IDENTIFIERS_COMPANY_NO_INPUT, map.get(INST_LBU_ID_COMPANY_NUMBER), ENTER, false);
            dmpGsPortalUtl.inputText(LBU_IDENTIFIERS_LEGAL_ENTITY_ID_INPUT, map.get(INST_LBU_ID_LEGAL_ENTITY_ID), ENTER, false);
        } catch (Exception e) {
            LOGGER.error("Processing failed while filling LBU Identifier details!!", e);
            throw new CartException(CartExceptionType.PROCESSING_FAILED, "Processing failed while filling LBU Identifier details!!");
        }
        return this;
    }

    //New method added for EISDEV-5276
    public Map<String, String> getFinInstitutionLbuIdentifiers() {
        Map<String, String> dataMap = new HashMap<>();
        dataMap.put(INST_LBU_ID_COMPANY_NUMBER, webTaskSvc.getWebElementAttribute(LBU_IDENTIFIERS_COMPANY_NO_INPUT, VALUE));
        dataMap.put(INST_LBU_ID_LEGAL_ENTITY_ID, webTaskSvc.getWebElementAttribute(LBU_IDENTIFIERS_LEGAL_ENTITY_ID_INPUT, VALUE));
        return dataMap;
    }

    //New method added for EISDEV-5276
    public InstitutionPage fillFinInstitutionSsdrOrgChart(final LinkedHashMap<String, String> map) {
        try {
            dmpGsPortalUtl.inputText(SSDR_ORGCHART_REGULATOR_INPUT, map.get(INST_SSDR_ORG_CHART_REGULATOR), ENTER, false);
            dmpGsPortalUtl.inputText(SSDR_ORGCHART_PERCENT_OWNED_INPUT, map.get(INST_SSDR_ORG_CHART_PERCENT_OWNED), ENTER, false);
            dmpGsPortalUtl.inputText(SSDR_FORM_13F_CIK_INPUT, map.get(INST_SSDR_FORM_13F_CIK), ENTER, false);
            dmpGsPortalUtl.inputText(SSDR_FORM_13F_FILE_NO_INPUT, map.get(INST_SSDR_FORM_13F_FILE_NO), ENTER, false);
        } catch (Exception e) {
            LOGGER.error("Processing failed while filling SSDR OrgChart Specific Attribute details!!", e);
            throw new CartException(CartExceptionType.PROCESSING_FAILED, "Processing failed while filling SSDR OrgChart Specific Attribute details!!");
        }
        return this;
    }

    //New method added for EISDEV-5276
    public Map<String, String> getFinInstitutionSsdrOrgChart() {
        Map<String, String> dataMap = new HashMap<>();
        dataMap.put(INST_SSDR_ORG_CHART_REGULATOR, webTaskSvc.getWebElementAttribute(SSDR_ORGCHART_REGULATOR_INPUT, VALUE));
        dataMap.put(INST_SSDR_ORG_CHART_PERCENT_OWNED, webTaskSvc.getWebElementAttribute(SSDR_ORGCHART_PERCENT_OWNED_INPUT, VALUE));
        dataMap.put(INST_SSDR_FORM_13F_CIK, webTaskSvc.getWebElementAttribute(SSDR_FORM_13F_CIK_INPUT, VALUE));
        dataMap.put(INST_SSDR_FORM_13F_FILE_NO, webTaskSvc.getWebElementAttribute(SSDR_FORM_13F_FILE_NO_INPUT, VALUE));
        return dataMap;
    }

    //New method added for EISDEV-5276
    public InstitutionPage fillFinInstitutionAddressDetails(final LinkedHashMap<String, String> map) {
        try {
            dmpGsPortalUtl.inputText(ADDRESS_DETAILS_ADDRESS_TYPE_INPUT, map.get(INST_ADDR_DETAILS_ADDRESS_TYPE), ENTER, mandatoryFlag);
            webTaskSvc.click(ADDRESS_DETAILS_MAILING_ADDRESS_BUTTON);
            threadSvc.sleepMillis(500);
            dmpGsPortalUtl.inputText(ADDRESS_DETAILS_ADDRESS_LINE1_INPUT, map.get(INST_ADDR_DETAILS_ADDRESS_LINE1), ENTER, false);
            dmpGsPortalUtl.inputText(ADDRESS_DETAILS_ADDRESS_LINE2_INPUT, map.get(INST_ADDR_DETAILS_ADDRESS_LINE2), ENTER, false);
            dmpGsPortalUtl.inputText(ADDRESS_DETAILS_COUNTRY_NAME_INPUT, map.get(INST_ADDR_DETAILS_ADDRESS_COUNTRY_NAME), ENTER, false);
        } catch (Exception e) {
            LOGGER.error("Processing failed while filling Address details!!", e);
            throw new CartException(CartExceptionType.PROCESSING_FAILED, "Processing failed while filling Address details!!");
        }
        return this;
    }

    public Map<String, String> getFinInstitutionAddressDetails() {
        Map<String, String> dataMap = new HashMap<>();
        dataMap.put(INST_ADDR_DETAILS_ADDRESS_TYPE, webTaskSvc.getWebElementAttribute(ADDRESS_DETAILS_ADDRESS_TYPE_INPUT, VALUE));
        webTaskSvc.click(ADDRESS_DETAILS_MAILING_ADDRESS_BUTTON);
        threadSvc.sleepMillis(500);
        dataMap.put(INST_ADDR_DETAILS_ADDRESS_LINE1, webTaskSvc.getWebElementAttribute(ADDRESS_DETAILS_ADDRESS_LINE1_INPUT, VALUE));
        dataMap.put(INST_ADDR_DETAILS_ADDRESS_LINE2, webTaskSvc.getWebElementAttribute(ADDRESS_DETAILS_ADDRESS_LINE2_INPUT, VALUE));
        dataMap.put(INST_ADDR_DETAILS_ADDRESS_COUNTRY_NAME, webTaskSvc.getWebElementAttribute(ADDRESS_DETAILS_COUNTRY_NAME_INPUT, VALUE));
        return dataMap;
    }

}
