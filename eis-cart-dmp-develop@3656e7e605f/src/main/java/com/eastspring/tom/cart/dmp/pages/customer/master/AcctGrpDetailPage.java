package com.eastspring.tom.cart.dmp.pages.customer.master;

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

import static com.eastspring.tom.cart.constant.CommonLocators.VARIABLE;
import static com.eastspring.tom.cart.dmp.mdl.GSUIFields.AGD_GROUP_DESCRIPTION;
import static com.eastspring.tom.cart.dmp.mdl.GSUIFields.AGD_GROUP_ID;
import static com.eastspring.tom.cart.dmp.mdl.GSUIFields.AGD_GROUP_NAME;
import static com.eastspring.tom.cart.dmp.mdl.GSUIFields.AGD_GROUP_PURPOSE;
import static com.eastspring.tom.cart.dmp.mdl.GSUIFields.AGD_PARTICIPANT_CRTS_PORTFOLIO_CODE;
import static com.eastspring.tom.cart.dmp.mdl.GSUIFields.AGD_PARTICIPANT_GROUP_NAME;
import static com.eastspring.tom.cart.dmp.mdl.GSUIFields.AGD_PARTICIPANT_PORTFOLIO_NAME;
import static com.eastspring.tom.cart.dmp.mdl.GSUIFields.AGD_PARTICIPANT_PURPOSE;
import static com.eastspring.tom.cart.dmp.mdl.GSUIFields.AGD_PARTICIPANT_PURPOSE_DESCRIPTION;

public class AcctGrpDetailPage {

    private static final Logger LOGGER = LoggerFactory.getLogger(AcctGrpDetailPage.class);
    public static final String ENTER = "ENTER";

    private boolean mandatoryFlag = true;

    private void setMandatoryFlag(final boolean isInUpdateMode) {
        if (isInUpdateMode) {
            mandatoryFlag = false;
        }
    }

    private String groupId;
    private String groupName;
    private String randomVar;

    public void setRandomVar() {
        randomVar = dateTimeUtil.getTimestamp("DHMs");
    }

    public void setGroupId(String groupId) {
        if (groupId.contains(VARIABLE)) {
            this.groupId = stateSvc.expandVar(groupId);
        } else {
            this.groupId = groupId.concat(randomVar);
        }
    }

    public void setGroupName(String groupName) {
        if (groupName.contains(VARIABLE)) {
            this.groupName = stateSvc.expandVar(groupName);
        } else {
            this.groupName = groupName.concat(randomVar);
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

    public AcctGrpDetailPage initializeAccountGroup(final LinkedHashMap<String, String> dataMap) {
        this.setRandomVar();
        this.setGroupId(dataMap.get(AGD_GROUP_ID));
        this.setGroupName(dataMap.get(AGD_GROUP_NAME));
        dataMap.replace(AGD_GROUP_ID, groupId);
        dataMap.replace(AGD_GROUP_NAME, groupName);
        return this;
    }

    public AcctGrpDetailPage invokeAccountGroupDetailScreen() {
        LOGGER.debug("Navigating to Account Group Detail");
        homePage.clickMenuDropdown()
                .selectMenu("Customer Master")
                .selectMenu("Account Group Detail");
        homePage.verifyGSTabDisplayed("Account Group Detail");
        return this;
    }

    public AcctGrpDetailPage invokeSetup() {
        dmpGsPortalUtl.invokeSetUpScreen(null, null, null);
        return this;
    }

    public AcctGrpDetailPage fillAccountGroupDetails(final LinkedHashMap<String, String> dataMap, boolean isInUpdateMode) {
        try {
            this.setMandatoryFlag(isInUpdateMode);

            dmpGsPortalUtl.inputText(CustomerMasterOR.ACCOUNT_GRP_DETAIL_GROUP_ID, dataMap.get(AGD_GROUP_ID), ENTER, mandatoryFlag);
            dmpGsPortalUtl.inputText(CustomerMasterOR.ACCOUNT_GRP_DETAIL_GROUP_NAME, dataMap.get(AGD_GROUP_NAME), ENTER, mandatoryFlag);
            dmpGsPortalUtl.inputText(CustomerMasterOR.ACCOUNT_GRP_DETAIL_GROUP_PURPOSE, dataMap.get(AGD_GROUP_PURPOSE), ENTER, mandatoryFlag);
            dmpGsPortalUtl.inputText(CustomerMasterOR.ACCOUNT_GRP_DETAIL_GROUP_DESCRIPTION, dataMap.get(AGD_GROUP_DESCRIPTION), ENTER, false);
            return this;
        } catch (Exception e) {
            LOGGER.error("Exception Occurred while filling Account Group Details", e);
            throw new CartException(CartExceptionType.IO_ERROR, "Exception Occurred while filling Accout Group Details");
        }
    }

    public AcctGrpDetailPage invokeAddParticipantDetails() {
        dmpGsPortalUtl.addNewDetails();
        threadSvc.sleepSeconds(1);
        return this;
    }


    public AcctGrpDetailPage fillGroupParticipantDetails(final LinkedHashMap<String, String> dataMap) {
        try {
            if (!StringUtils.isNullOrEmpty(dataMap.get(AGD_PARTICIPANT_PORTFOLIO_NAME))) {
                dmpGsPortalUtl.inputTextInLookUpField(CustomerMasterOR.ACCOUNT_GRP_PARTICIPANT_DETAIL_PORTFOLIO_NAME_LOOKUP, dataMap.get(AGD_PARTICIPANT_PORTFOLIO_NAME), false);
            }

            if (!StringUtils.isNullOrEmpty(dataMap.get(AGD_PARTICIPANT_GROUP_NAME))) {
                dmpGsPortalUtl.inputTextInLookUpField(CustomerMasterOR.ACCOUNT_GRP_PARTICIPANT_DETAIL_GROUP_NAME_LOOKUP, dataMap.get(AGD_PARTICIPANT_GROUP_NAME), false);
            }

            dmpGsPortalUtl.inputText(CustomerMasterOR.ACCOUNT_GRP_PARTICIPANT_DETAIL_PARTICIPANT_PURPOSE, dataMap.get(AGD_PARTICIPANT_PURPOSE), ENTER, true);
            dmpGsPortalUtl.inputText(CustomerMasterOR.ACCOUNT_GRP_PARTICIPANT_DETAIL_PARTICIPANT_DESCRIPTION, dataMap.get(AGD_PARTICIPANT_PURPOSE_DESCRIPTION), ENTER, false);
            return this;
        } catch (Exception e) {
            LOGGER.error("Exception Occurred while filling Account Group Participant Details", e);
            throw new CartException(CartExceptionType.IO_ERROR, "Exception Occurred while filling Account Group Participant Details");
        }
    }


    public AcctGrpDetailPage openAccountGroup(final String accountGrpId) {
        this.invokeAccountGroupDetailScreen();
        dmpGsPortalUtl.filterTable(GSUIFields.AGD_GROUP_ID, accountGrpId, false);
        return this;
    }

    public boolean verifyAccountGroupIsCreated(final String accountGrpId) {
        this.openAccountGroup(accountGrpId);
        boolean searchRecordAvailable = dmpGsPortalUtl.isSearchRecordAvailable(accountGrpId);
        dmpGsPortalSteps.closeActiveGsTab();
        return searchRecordAvailable;
    }

    public AcctGrpDetailPage invokeDetailsView() {
        dmpGsPortalUtl.invokeDetailsView();
        return this;
    }

    public void searchParticipantDetails(final LinkedHashMap<String, String> map) {
        final Set<String> colNames = map.keySet();
        String value;
        for (String column : colNames) {
            value = map.get(column);
            if (column.contains(AGD_PARTICIPANT_PORTFOLIO_NAME) || column.contains(AGD_PARTICIPANT_PURPOSE)) {
                dmpGsPortalUtl.filterPopupContentTable(column, value, true);
            } else {
                dmpGsPortalUtl.filterPopupContentTable(column, value, false);
            }
        }
    }

    public LinkedHashMap<String, String> getAccountGroupDetails() {
        LinkedHashMap<String, String> dataMap = new LinkedHashMap<>();
        try {
            dataMap.put(AGD_GROUP_ID, webTaskSvc.getWebElementAttribute(CustomerMasterOR.ACCOUNT_GRP_DETAIL_GROUP_ID, "value"));
            dataMap.put(AGD_GROUP_NAME, webTaskSvc.getWebElementAttribute(CustomerMasterOR.ACCOUNT_GRP_DETAIL_GROUP_NAME, "value"));
            dataMap.put(AGD_GROUP_PURPOSE, webTaskSvc.getWebElementAttribute(CustomerMasterOR.ACCOUNT_GRP_DETAIL_GROUP_PURPOSE, "value"));
            dataMap.put(AGD_GROUP_DESCRIPTION, webTaskSvc.getWebElementAttribute(CustomerMasterOR.ACCOUNT_GRP_DETAIL_GROUP_DESCRIPTION, "value"));

            dataMap.put(AGD_PARTICIPANT_PORTFOLIO_NAME, webTaskSvc.getWebElementAttribute(CustomerMasterOR.ACCOUNT_GRP_PARTICIPANT_DETAIL_PORTFOLIO_NAME, "value"));
            dataMap.put(AGD_PARTICIPANT_GROUP_NAME, webTaskSvc.getWebElementAttribute(CustomerMasterOR.ACCOUNT_GRP_PARTICIPANT_DETAIL_GROUP_NAME, "value"));

            dataMap.put(AGD_PARTICIPANT_PURPOSE, webTaskSvc.getWebElementAttribute(CustomerMasterOR.ACCOUNT_GRP_PARTICIPANT_DETAIL_PARTICIPANT_PURPOSE, "value"));
            dataMap.put(AGD_PARTICIPANT_PURPOSE_DESCRIPTION, webTaskSvc.getWebElementAttribute(CustomerMasterOR.ACCOUNT_GRP_PARTICIPANT_DETAIL_PARTICIPANT_DESCRIPTION, "value"));
            dataMap.put(AGD_PARTICIPANT_CRTS_PORTFOLIO_CODE, webTaskSvc.getWebElementAttribute(CustomerMasterOR.ACCOUNT_GRP_PARTICIPANT_CRTS_PORTFOLIO_CODE, "value"));
        } catch (Exception e) {
            LOGGER.error("Exception Occurred while reading Account Group Details", e);
            throw new CartException(CartExceptionType.IO_ERROR, "Exception Occurred while reading Account Group Details");
        }
        return dataMap;
    }
}
