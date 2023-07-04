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
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;

import java.util.LinkedHashMap;

import static com.eastspring.tom.cart.dmp.mdl.GSUIFields.CCREF_CLASSIFICATION_NAME;
import static com.eastspring.tom.cart.dmp.mdl.GSUIFields.CCREF_GROUP_DESCRIPTION;
import static com.eastspring.tom.cart.dmp.mdl.GSUIFields.CCREF_GROUP_NAME;
import static com.eastspring.tom.cart.dmp.mdl.GSUIFields.CCREF_GROUP_PURPOSE;
import static com.eastspring.tom.cart.dmp.mdl.GSUIFields.CCREF_GROUP_TYPE;
import static com.eastspring.tom.cart.dmp.mdl.GSUIFields.CCREF_PARTICIPANT_DESCRIPTION;
import static com.eastspring.tom.cart.dmp.mdl.GSUIFields.CCREF_PARTICIPANT_PURPOSE;
import static com.eastspring.tom.cart.dmp.mdl.GSUIFields.CCREF_PORTFOLIO_GROUP_NAME;

public class CentralCrossRefGrpPage {

    private static final Logger LOGGER = LoggerFactory.getLogger(CentralCrossRefGrpPage.class);

    private static final String CENTRAL_CROSS_RFF_GROUP_COMMON = "xpath://div[starts-with(@id,'EISCentralCrossReferenceGroup')]";

    private static final String CENTRAL_CROSS_REF_GROUP_PURPOSE = CENTRAL_CROSS_RFF_GROUP_COMMON + "[contains(@id,'EISCRGRGroupPurpose')]//input";
    private static final String CENTRAL_CROSS_REF_GROUP_TYPE = CENTRAL_CROSS_RFF_GROUP_COMMON + "[contains(@id,'EISCRGRGroupType')]//input";
    private static final String CENTRAL_CROSS_REF_GROUP_NAME = CENTRAL_CROSS_RFF_GROUP_COMMON + "[contains(@id,'EISCRGRGroupName')]//input";
    private static final String CENTRAL_CROSS_REF_GROUP_DESCRIPTION = CENTRAL_CROSS_RFF_GROUP_COMMON + "[contains(@id,'EISCRGRGroupDescription')]//input";
    private static final String CENTRAL_CROSS_REF_PARTICIPANT_PURPOSE = CENTRAL_CROSS_RFF_GROUP_COMMON + "[contains(@id,'EISCRGPGroupParticipantPurpose')]//input";
    private static final String CENTRAL_CROSS_REF_PARTICIPANT_DESCRIPTION = CENTRAL_CROSS_RFF_GROUP_COMMON + "[contains(@id,'EISCRGPGroupParticipantDescription')]//input";
    private static final String CENTRAL_CROSS_REF_PORTFOLIO_GRP_NAME = CENTRAL_CROSS_RFF_GROUP_COMMON + "[contains(@id,'EISCRGPAccountGroupName')]//input";
    private static final String CENTRAL_CROSS_REF_CLASSIFICATION_NAME = CENTRAL_CROSS_RFF_GROUP_COMMON + "[contains(@id,'EISCRGPClassificationName')]//input";
    public static final String VALUE = "value";


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

    public CentralCrossRefGrpPage invokeCentralCrossRefGrpScreen() {
        LOGGER.debug("Navigating to Central Cross Reference Group");
        homePage.clickMenuDropdown()
                .selectMenu("Generic Setup")
                .selectMenu("Central Cross Reference Group");
        homePage.verifyGSTabDisplayed("Central Cross Reference Group", 600);
        return this;
    }

    public CentralCrossRefGrpPage invokeSetup() {
        dmpGsPortalUtl.invokeSetUpScreen(null, null, null);
        return this;
    }

    public CentralCrossRefGrpPage fillGroupDetails(final LinkedHashMap<String, String> dataMap, boolean isInUpdateMode) {
        try {
            this.setMandatoryFlag(isInUpdateMode);
            dmpGsPortalUtl.inputText(CENTRAL_CROSS_REF_GROUP_PURPOSE, dataMap.get(CCREF_GROUP_PURPOSE), "ENTER", false);
            dmpGsPortalUtl.inputText(CENTRAL_CROSS_REF_GROUP_TYPE, dataMap.get(CCREF_GROUP_TYPE), "ENTER", false);
            dmpGsPortalUtl.inputText(CENTRAL_CROSS_REF_GROUP_NAME, dataMap.get(CCREF_GROUP_NAME), "ENTER", mandatoryFlag);
            dmpGsPortalUtl.inputText(CENTRAL_CROSS_REF_GROUP_DESCRIPTION, dataMap.get(CCREF_GROUP_DESCRIPTION), "ENTER", mandatoryFlag);
            return this;
        } catch (Exception e) {
            LOGGER.error("Exception Occurred while filling Group Details", e);
            throw new CartException(CartExceptionType.IO_ERROR, "Exception Occurred while filling Group Details");
        }
    }

    public CentralCrossRefGrpPage invokeAddParticipantDetails() {
        dmpGsPortalUtl.addNewDetails();
        threadSvc.sleepSeconds(1);
        return this;
    }

    public CentralCrossRefGrpPage fillGroupParticipantDetails(final LinkedHashMap<String, String> dataMap, boolean isInUpdateMode) {
        try {
            this.setMandatoryFlag(isInUpdateMode);
            dmpGsPortalUtl.inputText(CENTRAL_CROSS_REF_PARTICIPANT_PURPOSE, dataMap.get(CCREF_PARTICIPANT_PURPOSE), "ENTER", mandatoryFlag);
            dmpGsPortalUtl.inputText(CENTRAL_CROSS_REF_PARTICIPANT_DESCRIPTION, dataMap.get(CCREF_PARTICIPANT_DESCRIPTION), "ENTER", false);
            dmpGsPortalUtl.inputText(CENTRAL_CROSS_REF_PORTFOLIO_GRP_NAME, dataMap.get(CCREF_PORTFOLIO_GROUP_NAME), "ENTER", false);
            dmpGsPortalUtl.inputText(CENTRAL_CROSS_REF_CLASSIFICATION_NAME, dataMap.get(CCREF_CLASSIFICATION_NAME), "ENTER", false);
            return this;
        } catch (Exception e) {
            LOGGER.error("Exception Occurred while filling Group Participant Details", e);
            throw new CartException(CartExceptionType.IO_ERROR, "Exception Occurred while filling Group Participant Details");
        }
    }

    public CentralCrossRefGrpPage openCrossReferenceGroup(final String groupName) {
        this.invokeCentralCrossRefGrpScreen();
        dmpGsPortalUtl.filterTable("Group Name", groupName, false);
        return this;
    }

    public boolean verifyCrossReferenceGroupIsCreated(final String groupName) {
        this.openCrossReferenceGroup(groupName);
        boolean searchRecordAvailable = dmpGsPortalUtl.isSearchRecordAvailable(groupName);
        dmpGsPortalSteps.closeActiveGsTab();
        return searchRecordAvailable;
    }

    public LinkedHashMap<String, String> getCentralCrossRefGrpDetails() {
        LinkedHashMap<String, String> dataMap = new LinkedHashMap<>();
        try {
            dataMap.put(CCREF_GROUP_PURPOSE, webTaskSvc.getWebElementAttribute(CENTRAL_CROSS_REF_GROUP_PURPOSE, VALUE));
            dataMap.put(CCREF_GROUP_TYPE, webTaskSvc.getWebElementAttribute(CENTRAL_CROSS_REF_GROUP_TYPE, VALUE));
            dataMap.put(CCREF_GROUP_NAME, webTaskSvc.getWebElementAttribute(CENTRAL_CROSS_REF_GROUP_NAME, VALUE));
            dataMap.put(CCREF_GROUP_DESCRIPTION, webTaskSvc.getWebElementAttribute(CENTRAL_CROSS_REF_GROUP_DESCRIPTION, VALUE));
        } catch (Exception e) {
            LOGGER.error("Exception Occurred while reading Central Cross Ref Group Details", e);
            throw new CartException(CartExceptionType.IO_ERROR, "Exception Occurred while reading Central Cross Ref Group Details");
        }
        return dataMap;
    }

    public LinkedHashMap<String, String> getCentralCrossRefGrpParticipantDetails() {
        LinkedHashMap<String, String> dataMap = new LinkedHashMap<>();
        try {
            dataMap.put(CCREF_PARTICIPANT_PURPOSE, webTaskSvc.getWebElementAttribute(CENTRAL_CROSS_REF_PARTICIPANT_PURPOSE, VALUE));
            dataMap.put(CCREF_PARTICIPANT_DESCRIPTION, webTaskSvc.getWebElementAttribute(CENTRAL_CROSS_REF_PARTICIPANT_DESCRIPTION, VALUE));
            dataMap.put(CCREF_PORTFOLIO_GROUP_NAME, webTaskSvc.getWebElementAttribute(CENTRAL_CROSS_REF_PORTFOLIO_GRP_NAME, VALUE));
            dataMap.put(CCREF_CLASSIFICATION_NAME, webTaskSvc.getWebElementAttribute(CENTRAL_CROSS_REF_CLASSIFICATION_NAME, VALUE));
        } catch (Exception e) {
            LOGGER.error("Exception Occurred while reading Central Cross Ref Group Participant Details", e);
            throw new CartException(CartExceptionType.IO_ERROR, "Exception Occurred while reading Central Cross Ref Group Participant Details");
        }
        return dataMap;
    }

}
