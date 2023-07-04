package com.eastspring.tom.cart.dmp.pages.security.master;

import com.eastspring.tom.cart.core.CartException;
import com.eastspring.tom.cart.core.CartExceptionType;
import com.eastspring.tom.cart.core.svc.StateSvc;
import com.eastspring.tom.cart.core.svc.ThreadSvc;
import com.eastspring.tom.cart.core.svc.WebTaskSvc;
import com.eastspring.tom.cart.core.utl.DateTimeUtil;
import com.eastspring.tom.cart.dmp.mdl.GSUIFields;
import com.eastspring.tom.cart.dmp.pages.HomePage;
import com.eastspring.tom.cart.dmp.steps.DmpGsPortalSteps;
import com.eastspring.tom.cart.dmp.utl.DmpGsPortalUtl;
import org.h2.util.StringUtils;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;

import java.util.LinkedHashMap;
import java.util.Set;

import static com.eastspring.tom.cart.dmp.mdl.GSUIFields.*;

public class MrktGrpDetailPage {

    public static final String MARKET_GRP_EFFECTIVE_UNTIL = "xpath://div[@id='MarketGroup.MarketGroupDetails.MarketGrpEffectiveUntil']//input";
    public static final String MARKET_GRP_GROUP_NAME = "xpath://div[@id='MarketGroup.MarketGroupDetails.MarketGroupName']//input";
    public static final String MARKET_GRP_ASSET_SUBDIVISION_NAME = "xpath://div[@id='MarketGroup.MarketGroupDetails.MarketGrpAssetSubdivisionName']//input";
    public static final String MARKET_GRP_GROUP_DESCRIPTION = "xpath://div[@id='MarketGroup.MarketGroupDetails.MarketGroupDescription']//input";
    public static final String MARKET_GRP_PURPOSE_TYPE = "xpath://div[@id='MarketGroup.MarketGroupDetails.MarketGroupPurposeType']//input";
    public static final String MARKET_GRP_CREATED_ON = "xpath://div[@id='MarketGroup.MarketGroupDetails.MarketGrpCreatedOn']//input";
    public static final String MARKET_GRP_ENTERPRISE_NAME = "xpath://div[@id='MarketGroup.MarketGroupDetails.MarketGrpEnterpriseName']//input";
    public static final String MARKET_GRP_EXCHANGE_NAME = "xpath://div[@id='MarketGroup.MarketGroupParticipant.MarketAsParticipants.FinancialMarket.MarketDetails.MarketName']//input/../../div[@role='button'][1]";
    public static final String MARKET_GRP_GROUP_NAME2 = "xpath://div[@id='MarketGroup.MarketGroupParticipant.MarketGroupAsParticipants.MarketGroup.MarketGroupDetails.MarketGroupName']//input/../../div[@role='button'][1]";
    public static final String MARKET_GRP_EXCHANGE_NAME_LOCATOR = "xpath://div[@id='MarketGroup.MarketGroupParticipant.MarketAsParticipants.FinancialMarket.MarketDetails.MarketName']//input";
    public static final String MARKET_GRP_GROUP_NAME2_LOCATOR = "xpath://div[@id='MarketGroup.MarketGroupParticipant.MarketGroupAsParticipants.MarketGroup.MarketGroupDetails.MarketGroupName']//input";
    public static final String MARKET_GRP_PARTICIPANT_DESC = "xpath://div[@id='MarketGroup.MarketGroupParticipant.MarketGrpParticipantDesc']//input";
    public static final String MARKET_GRP_MIC_CODE = "xpath://div[@id='MarketGroup.MarketGroupParticipant.MarketAsParticipants.FinancialMarket.MarketDetails.MICCode']//input";
    public static final String MARKET_PARTICIPANT_PURPOSE_TYPE = "xpath://div[@id='MarketGroup.MarketGroupParticipant.MarketGrpParticipantPurposeType']//input";


    private static final Logger LOGGER = LoggerFactory.getLogger(MrktGrpDetailPage.class);
    public static final String ENTER = "ENTER";

    private boolean mandatoryFlag = true;

    private void setMandatoryFlag(final boolean isInUpdateMode) {
        if (isInUpdateMode) {
            mandatoryFlag = false;
        }
    }


    //region Bean Declaration
    @Autowired
    private StateSvc stateSvc;

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

    public MrktGrpDetailPage invokeMarketGroupDetailScreen() {
        LOGGER.debug("Navigating to Market Group Detail");
        homePage.clickMenuDropdown()
                .selectMenu("Security Master")
                .selectMenu("Market Group");
        homePage.verifyGSTabDisplayed("Market Group");
        return this;
    }

    public MrktGrpDetailPage invokeSetup() {
        dmpGsPortalUtl.invokeSetUpScreen(null, null, null);
        return this;
    }

    public MrktGrpDetailPage fillMarketGroupDetails(final LinkedHashMap<String, String> dataMap, boolean isInUpdateMode) {
        try {
            this.setMandatoryFlag(isInUpdateMode);
            dmpGsPortalUtl.inputText(MARKET_GRP_PURPOSE_TYPE, dataMap.get(MKT_GROUP_PURPOSE_TYPE), ENTER, true);
            dmpGsPortalUtl.inputText(MARKET_GRP_GROUP_NAME, dataMap.get(MKT_GROUP_NAME), ENTER, mandatoryFlag);
            dmpGsPortalUtl.inputText(MARKET_GRP_CREATED_ON, dataMap.get(MKT_GROUP_CREATED_ON), ENTER, false);
            dmpGsPortalUtl.inputText(MARKET_GRP_GROUP_DESCRIPTION, dataMap.get(MKT_GROUP_DESC), ENTER, false);
            dmpGsPortalUtl.inputText(MARKET_GRP_EFFECTIVE_UNTIL, dataMap.get(MKT_GRP_EFFECTIVE_UNTIL), ENTER, false);
            dmpGsPortalUtl.inputText(MARKET_GRP_ENTERPRISE_NAME, dataMap.get(MKT_GRP_ENTERPRISE_NAME), ENTER, false);
            dmpGsPortalUtl.inputText(MARKET_GRP_ASSET_SUBDIVISION_NAME, dataMap.get(MKT_GROUP_ASSET_SUBDIVISION_NAME), ENTER, false);
            return this;
        } catch (Exception e) {
            LOGGER.error("Exception Occurred while filling Market Group Details", e);
            throw new CartException(CartExceptionType.IO_ERROR, "Exception Occurred while filling Market Group Details");
        }
    }

    public MrktGrpDetailPage invokeAddParticipantDetails() {
        dmpGsPortalUtl.addNewDetails();
        threadSvc.sleepSeconds(1);
        return this;
    }

    public MrktGrpDetailPage fillGroupParticipantDetails(final LinkedHashMap<String, String> dataMap, boolean isInUpdateMode) {
        try {
            this.setMandatoryFlag(isInUpdateMode);
            if (!StringUtils.isNullOrEmpty(dataMap.get(MKT_GROUP_EXCHANGE_NAME))) {
                dmpGsPortalUtl.inputTextInLookUpField(MARKET_GRP_EXCHANGE_NAME, dataMap.get(MKT_GROUP_EXCHANGE_NAME), false);
            }
            dmpGsPortalUtl.inputText(MARKET_PARTICIPANT_PURPOSE_TYPE, dataMap.get(MKT_GROUP_PARTICIPANT_PURPOSE), ENTER, true);
            dmpGsPortalUtl.inputTextInLookUpField(MARKET_GRP_GROUP_NAME2, dataMap.get(MKT_GRP_GROUP_NAME2), false);
            dmpGsPortalUtl.inputText(MARKET_GRP_PARTICIPANT_DESC, dataMap.get(MKT_GROUP_PARTICIPANT_DESC), ENTER, false);

            return this;
        } catch (Exception e) {
            LOGGER.error("Exception Occurred while filling Market Group Participant Details", e);
            throw new CartException(CartExceptionType.IO_ERROR, "Exception Occurred while filling Market Group Participant Details");
        }
    }


    public MrktGrpDetailPage openMarketGroup(final String accountGrpId) {
        this.invokeMarketGroupDetailScreen();
        dmpGsPortalUtl.filterTable(GSUIFields.MKT_GROUP_NAME, accountGrpId, false);
        return this;
    }

    public boolean verifyMarketGroupIsCreated(final String accountGrpId) {
        this.openMarketGroup(accountGrpId);
        boolean searchRecordAvailable = dmpGsPortalUtl.isSearchRecordAvailable(accountGrpId);
        dmpGsPortalSteps.closeActiveGsTab();
        return searchRecordAvailable;
    }

    public MrktGrpDetailPage invokeDetailsView() {
        dmpGsPortalUtl.invokeDetailsView();
        return this;
    }

    public void searchParticipantDetails(final LinkedHashMap<String, String> map) {
        final Set<String> colNames = map.keySet();
        String value;
        for (String column : colNames) {
            value = map.get(column);
            if (column.contains(MKT_GROUP_EXCHANGE_NAME) || column.contains(MKT_GROUP_PARTICIPANT_PURPOSE)) {
                dmpGsPortalUtl.filterPopupContentTable(column, value, true);
            } else {
                dmpGsPortalUtl.filterPopupContentTable(column, value, false);
            }
        }
    }


    public LinkedHashMap<String, String> getMarketGroupDetails() {
        LinkedHashMap<String, String> dataMap = new LinkedHashMap<>();
        try {
            dataMap.put(MKT_GRP_EFFECTIVE_UNTIL, webTaskSvc.getWebElementAttribute(MARKET_GRP_EFFECTIVE_UNTIL, "value"));
            dataMap.put(MKT_GROUP_NAME, webTaskSvc.getWebElementAttribute(MARKET_GRP_GROUP_NAME, "value"));
            dataMap.put(MKT_GROUP_ASSET_SUBDIVISION_NAME, webTaskSvc.getWebElementAttribute(MARKET_GRP_ASSET_SUBDIVISION_NAME, "value"));
            dataMap.put(MKT_GROUP_DESC, webTaskSvc.getWebElementAttribute(MARKET_GRP_GROUP_DESCRIPTION, "value"));
            dataMap.put(MKT_GROUP_PURPOSE_TYPE, webTaskSvc.getWebElementAttribute(MARKET_GRP_PURPOSE_TYPE, "value"));
            dataMap.put(MKT_GROUP_CREATED_ON, webTaskSvc.getWebElementAttribute(MARKET_GRP_CREATED_ON, "value"));
            dataMap.put(MKT_GRP_ENTERPRISE_NAME, webTaskSvc.getWebElementAttribute(MARKET_GRP_ENTERPRISE_NAME, "value"));
            dataMap.put(MKT_GROUP_EXCHANGE_NAME, webTaskSvc.getWebElementAttribute(MARKET_GRP_EXCHANGE_NAME_LOCATOR, "value"));
            dataMap.put(MKT_GRP_GROUP_NAME2, webTaskSvc.getWebElementAttribute(MARKET_GRP_GROUP_NAME2_LOCATOR, "value"));
            dataMap.put(MKT_GROUP_PARTICIPANT_DESC, webTaskSvc.getWebElementAttribute(MARKET_GRP_PARTICIPANT_DESC, "value"));
            dataMap.put(MKT_GROUP_MIC_CODE, webTaskSvc.getWebElementAttribute(MARKET_GRP_MIC_CODE, "value"));
            dataMap.put(MKT_GROUP_PARTICIPANT_PURPOSE, webTaskSvc.getWebElementAttribute(MARKET_PARTICIPANT_PURPOSE_TYPE, "value"));
        } catch (Exception e) {
            LOGGER.error("Exception Occurred while reading Market Group Details", e);
            throw new CartException(CartExceptionType.IO_ERROR, "Exception Occurred while reading Market Group Details");
        }
        return dataMap;
    }
}
