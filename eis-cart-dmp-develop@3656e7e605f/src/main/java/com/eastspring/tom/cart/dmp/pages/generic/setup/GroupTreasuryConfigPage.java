package com.eastspring.tom.cart.dmp.pages.generic.setup;

import com.eastspring.tom.cart.core.CartException;
import com.eastspring.tom.cart.core.CartExceptionType;
import com.eastspring.tom.cart.core.svc.WebTaskSvc;
import com.eastspring.tom.cart.dmp.pages.HomePage;
import com.eastspring.tom.cart.dmp.utl.DmpGsPortalUtl;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;

import java.util.Map;

import static com.eastspring.tom.cart.constant.CommonLocators.GS_SAVE_BUTTON;
import static com.eastspring.tom.cart.dmp.mdl.GSUIFields.*;

public class GroupTreasuryConfigPage {

    private static final Logger LOGGER = LoggerFactory.getLogger(GroupTreasuryConfigPage.class);

    //This is support locator, hence xpath: has not appended
    private static final String CLASSIF_DETAILS_TABLE = "//div[text()='Industry Classification Details']//ancestor::div[contains(@class,'gsDetailSectionPanel')]//table[@class='v-table-table']";

    private static final String XPATH = "xpath:";


    //Locators
    public static final String GROUP_TREASURY_PORTFOLIO_NAME_LOCATOR = "xpath://*[contains(@id,'EISPortfolioDetails.EISPortfolioLongName')]//input/../../div[@role='button'][1]";
    public static final String GROUP_TREASURY_PORTFOLIO_CODE_LOCATOR = "cssSelector:div[id$='GroupTreasuryConfiguration.EICELC1CRTSID'] input";
    public static final String GROUP_TREASURY_DATA_SRC_ID_LOCATOR = "cssSelector:div[id$='GroupTreasuryConfiguration.EISELC1DataSourceID'] input";
    public static final String GROUP_TREASURY_SEC_TYPE_LOCATOR = "cssSelector:div[id$='GroupTreasuryConfiguration.EISELC1SecurityType'] input";
    public static final String GROUP_TREASURY_OTH_COUNTER_PARTY_LOCATOR = "xpath://*[contains(@id,'OCtoFINS.FinancialInstitution.FinancialInstitutionDetails.FinancialInstitutionName')]//input/../../div[@role='button'][1]";
    public static final String GROUP_TREASURY_REPORTING_COUNTERPARTY_LOCATOR = "xpath://*[contains(@id,'ELC1toFINS.FinancialInstitution.FinancialInstitutionDetails.FinancialInstitutionName')]//input/../../div[@role='button'][1]";
    public static final String GROUP_TREASURY_EASTSPRING_ID_LOCATOR = "xpath://*[contains(@id,'ESIDtoFINS.FinancialInstitution.FinancialInstitutionDetails.FinancialInstitutionName')]//input/../../div[@role='button'][1]";
    public static final String GROUP_TREASURY_CONTRACT_TYPE_LOCATOR = "cssSelector:div[id$='EISELC1ContractTyp'] input";
    public static final String GROUP_TREASURY_INST_CLASSIFIC_TYPE_LOCATOR = "cssSelector:div[id$='EISELC1InstrClassificationTyp'] input";
    public static final String GROUP_TREASURY_INST_CLASSIFIC_LOCATOR = "cssSelector:div[id$='EISELC1InstrumentClassification'] input";
    public static final String GROUP_TREASURY_COTOC_LOCATOR = "cssSelector:div[id$='EISELC1Cotoc'] input";

    @Autowired
    private HomePage homePage;

    @Autowired
    private DmpGsPortalUtl dmpGsPortalUtl;

    @Autowired
    private WebTaskSvc webTaskSvc;

    private boolean mandatoryFlag = true;

    private void setMandatoryFlag(final boolean isInUpdateMode) {
        if (isInUpdateMode) {
            mandatoryFlag = false;
        }
    }

    public GroupTreasuryConfigPage navigateToGroupTreasury() {
        LOGGER.debug("Navigating to Group Treasury Configuration Screen");
        homePage.clickMenuDropdown()
                .selectMenu("Generic Setup")
                .selectMenu("Group Treasury Configuration");
        homePage.verifyGSTabDisplayed("Group Treasury Configuration");
        return this;
    }

    public GroupTreasuryConfigPage invokeSetup() {
        dmpGsPortalUtl.invokeSetUpScreen(null, null, null);
        return this;
    }

    public GroupTreasuryConfigPage openGroupTreasuryAccount(final String counterPartyId) {
        dmpGsPortalUtl.filterTable("Other Counterparty", counterPartyId, false);

        try {
            webTaskSvc.waitForElementToAppear(GS_SAVE_BUTTON, 20);
            LOGGER.debug("External Account [{}] is Opened to Add Details...", counterPartyId);
        } catch (CartException e) {
            LOGGER.error("External Account [{}] is Not available in the System!!", counterPartyId);
            throw new CartException(CartExceptionType.PROCESSING_FAILED, "External Account [{}] is Not available in the System!!", counterPartyId);
        }
        return this;
    }


    public GroupTreasuryConfigPage fillGroupTreasuryConfigDetails(final Map<String, String> map, final boolean isInUpdateMode) {
        try {
            this.setMandatoryFlag(isInUpdateMode);
            dmpGsPortalUtl.inputTextInLookUpField(GROUP_TREASURY_PORTFOLIO_NAME_LOCATOR, map.get(GTC_PORTFOLIO_NAME), mandatoryFlag);
            dmpGsPortalUtl.inputText(GROUP_TREASURY_DATA_SRC_ID_LOCATOR, map.get(GTC_DATA_SOURCE_ID), "ENTER", mandatoryFlag);
            dmpGsPortalUtl.inputText(GROUP_TREASURY_SEC_TYPE_LOCATOR, map.get(GTC_SECURITY_TYPE), "ENTER", mandatoryFlag);
            dmpGsPortalUtl.inputTextInLookUpField(GROUP_TREASURY_OTH_COUNTER_PARTY_LOCATOR, map.get(GTC_OTHER_COUNTERPARTY), false);
            dmpGsPortalUtl.inputTextInLookUpField(GROUP_TREASURY_REPORTING_COUNTERPARTY_LOCATOR, map.get(GTC_REPORTING_COUNTERPARTY), false);
            dmpGsPortalUtl.inputTextInLookUpField(GROUP_TREASURY_EASTSPRING_ID_LOCATOR, map.get(GTC_EASTSPRING_ID), false);
            dmpGsPortalUtl.inputText(GROUP_TREASURY_CONTRACT_TYPE_LOCATOR, map.get(GTC_CONTRACT_TYPE), "ENTER", mandatoryFlag);
            dmpGsPortalUtl.inputText(GROUP_TREASURY_INST_CLASSIFIC_TYPE_LOCATOR, map.get(GTC_INSTRUMENT_CLASSIFIC_TYPE), "ENTER", false);
            dmpGsPortalUtl.inputText(GROUP_TREASURY_INST_CLASSIFIC_LOCATOR, map.get(GTC_INSTRUMENT_CLASSIFICATION), "ENTER", false);
            dmpGsPortalUtl.inputText(GROUP_TREASURY_COTOC_LOCATOR, map.get(GTC_COTOC), "ENTER", false);

            return this;
        } catch (Exception e) {
            LOGGER.error("Exception Occurred while filling Group Treasury config Details", e);
            throw new CartException(CartExceptionType.IO_ERROR, "Exception Occurred while filling Group Treasury config Details");
        }
    }


}
