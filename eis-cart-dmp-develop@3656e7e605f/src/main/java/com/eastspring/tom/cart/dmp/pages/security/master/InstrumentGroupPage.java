package com.eastspring.tom.cart.dmp.pages.security.master;

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

import static com.eastspring.tom.cart.dmp.mdl.GSUIFields.*;

public class InstrumentGroupPage {

    private static final Logger LOGGER = LoggerFactory.getLogger(InstrumentGroupPage.class);

    public static final String IG_GROUP_BASIC_DETAILS_TABLE = "xpath://div[text()='Group Basic Details']//ancestor::div[contains(@class,'gsDetailSectionPanel')]//table[@class='v-table-table']";
    public static final String IG_GP_PARTICIPANT_TABLE = "xpath://div[text()='Group Participants Details']//ancestor::div[contains(@class,'gsDetailSectionPanel')]//table[@class='v-table-table']";

    public static final String IG_BASIC_GROUP_ID = IG_GROUP_BASIC_DETAILS_TABLE + "//div[text()='Group ID']/ancestor::tr//input";
    public static final String IG_BASIC_GROUP_NAME = IG_GROUP_BASIC_DETAILS_TABLE + "//div[text()='Group Name']/ancestor::tr//input";
    public static final String IG_BASIC_GROUP_PURPOSE = IG_GROUP_BASIC_DETAILS_TABLE + "//div[text()='Group Purpose']/ancestor::tr//input";
    public static final String IG_BASIC_GROUP_DESCRIPTION = IG_GROUP_BASIC_DETAILS_TABLE + "//div[text()='Group Description']/ancestor::tr//input";
    public static final String IG_BASIC_SUBSCRIBER_DOWNSTREAM = IG_GROUP_BASIC_DETAILS_TABLE + "//div[text()='Subscriber/Down Stream']/ancestor::tr//input";
    public static final String IG_BASIC_ENTERPRISE = IG_GROUP_BASIC_DETAILS_TABLE + "//div[text()='Enterprise']/ancestor::tr//input";
    public static final String IG_BASIC_ASSET_SUBDIVISION_NAME = IG_GROUP_BASIC_DETAILS_TABLE + "//div[text()='Asset Subdivision Name']/ancestor::tr//input";
    public static final String IG_BASIC_GROUP_CREATED_ON = IG_GROUP_BASIC_DETAILS_TABLE + "//div[text()='Group Created On']/ancestor::tr//input";
    public static final String IG_BASIC_GROUP_EFFECTIVE_UNTIL = IG_GROUP_BASIC_DETAILS_TABLE + "//div[text()='Group Effective Until']/ancestor::tr//input";
    public static final String IG_PARTICIPANT_INSTRUMENT_NAME_INPUT = IG_GP_PARTICIPANT_TABLE + "//div[text()='Instrument Name']/ancestor::tr//input";
    public static final String IG_PARTICIPANT_INSTRUMENT_NAME_LOOKUP = IG_GP_PARTICIPANT_TABLE + "//div[text()='Instrument Name']/ancestor::tr//div[@role='button'][contains(@class,'v-button')]";
    public static final String IG_PARTICIPANT_GROUP_NAME_INPUT = IG_GP_PARTICIPANT_TABLE + "//div[text()='Group Name']/ancestor::tr//input";
    public static final String IG_PARTICIPANT_GROUP_NAME_LOOKUP = IG_GP_PARTICIPANT_TABLE + "//div[text()='Group Name']/ancestor::tr//div[@role='button'][contains(@class,'v-button')]";
    public static final String IG_PREFERRED_IDENTIFIER_VALUE_INPUT = IG_GP_PARTICIPANT_TABLE + "//div[text()='Preferred Identifier Value']/ancestor::tr//input";
    public static final String IG_PREFERRED_IDENTIFIER_VALUE_LOOKUP = IG_GP_PARTICIPANT_TABLE + "//div[text()='Preferred Identifier Value']/ancestor::tr//div[@role='button'][contains(@class,'v-button')]";
    public static final String IG_PARTICIPANT_PARTICIPANT_PURPOSE = IG_GP_PARTICIPANT_TABLE + "//div[text()='Participant Purpose']/ancestor::tr//input";
    public static final String IG_PARTICIPANT_PARTICIPANT_DESCRIPTION = IG_GP_PARTICIPANT_TABLE + "//div[text()='Participant Description']/ancestor::tr//input";
    public static final String IG_PARTICIPANT_PARTICIPANT_AMOUNT = IG_GP_PARTICIPANT_TABLE + "//div[text()='Participant Amount']/ancestor::tr//input";
    public static final String IG_PARTICIPANT_PARTICIPANT_PERCENT = IG_GP_PARTICIPANT_TABLE + "//div[text()='Participant Percent']/ancestor::tr//input";
    public static final String IG_PARTICIPANT_PARTICIPANT_CCY = IG_GP_PARTICIPANT_TABLE + "//div[text()='Participant Currency']/ancestor::tr//input";
    public static final String IG_PARTICIPANT_PARTICIPANT_TYPE = IG_GP_PARTICIPANT_TABLE + "//div[text()='Participation Type']/ancestor::tr//input";
    public static final String IG_PARTICIPANT_PARTICIPANT_CREATED_ON = IG_GP_PARTICIPANT_TABLE + "//div[text()='Participant Created On']/ancestor::tr//input";
    public static final String IG_PARTICIPANT_PARTICIPANT_EFFECTIVE_UNTIL = IG_GP_PARTICIPANT_TABLE + "//div[text()='Participant Effective Until']/ancestor::tr//input";
    public static final String IG_GROUP_PARTICIPANT_ADD = "xpath://*[contains(@class,'v-slot v-slot-small v-slot-link v-slot-gsGreenIcon v-slot-gsMargin v-slot-gsIconLarge v-align-right v-align-middle')]/div[@role='button']";
    public static final String IG_SELECT_SAME_ISSUE_NAME = "//div[@class='popupContent']//table[@class='v-table-table']/tbody";
    public static final String ENTER = "ENTER";
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

    public InstrumentGroupPage invokeInstrumentGroupScreen() {
        LOGGER.debug("Navigating to Instrument Group Screen");
        homePage.clickMenuDropdown()
                .selectMenu("Security Master")
                .selectMenu("Instrument Group");
        homePage.verifyGSTabDisplayed("Instrument Group");
        return this;
    }

    public InstrumentGroupPage invokeSetup() {
        dmpGsPortalUtl.invokeSetUpScreen(null, null, null);
        return this;
    }

    public InstrumentGroupPage fillGroupBasicDetails(final LinkedHashMap<String, String> dataMap, final boolean isInUpdateMode) {
        try {
            this.setMandatoryFlag(isInUpdateMode);
            dmpGsPortalUtl.inputText(IG_BASIC_GROUP_ID, dataMap.get(INSTGRP_GROUP_ID), ENTER, false);
            dmpGsPortalUtl.inputText(IG_BASIC_GROUP_NAME, dataMap.get(INSTGRP_GROUP_NAME), ENTER, mandatoryFlag);
            dmpGsPortalUtl.inputText(IG_BASIC_GROUP_PURPOSE, dataMap.get(INSTGRP_GROUP_PURC), ENTER, false);
            dmpGsPortalUtl.inputText(IG_BASIC_GROUP_DESCRIPTION, dataMap.get(INSTGRP_GROUP_DESC), ENTER, false);
            dmpGsPortalUtl.inputText(IG_BASIC_SUBSCRIBER_DOWNSTREAM, dataMap.get(INSTGRP_SUBSCRIBER_DOWNSTREAM), ENTER, false);
            dmpGsPortalUtl.inputText(IG_BASIC_ENTERPRISE, dataMap.get(INSTGRP_ENTERPRISE), ENTER, false);
            dmpGsPortalUtl.inputText(IG_BASIC_ASSET_SUBDIVISION_NAME, dataMap.get(INSTGRP_ASSET_SUBDIVISION_NAME), ENTER, false);
            dmpGsPortalUtl.inputText(IG_BASIC_GROUP_CREATED_ON, dataMap.get(INSTGRP_GROUP_CREATED_ON), ENTER, false);
            dmpGsPortalUtl.inputText(IG_BASIC_GROUP_EFFECTIVE_UNTIL, dataMap.get(INSTGRP_GROUP_EFFICTIVE_UNTIL), ENTER, false);
            return this;
        } catch (Exception e) {
            LOGGER.error("Exception Occurred while filling Group Basic Details", e);
            throw new CartException(CartExceptionType.IO_ERROR, "Exception Occurred while filling Group Basic Details");
        }
    }

    public InstrumentGroupPage invokeAddParticipantDetails() {
        dmpGsPortalUtl.addNewDetails();
        threadSvc.sleepSeconds(1);
        return this;
    }

    public InstrumentGroupPage fillGroupParticipantDetails(final LinkedHashMap<String, String> dataMap, final boolean isInUpdateMode) {
        try {
            this.setMandatoryFlag(isInUpdateMode);
            dmpGsPortalUtl.inputTextInLookUpField(IG_PARTICIPANT_INSTRUMENT_NAME_LOOKUP, dataMap.get(INSTGRP_INSTRUMENT_NAME), false);
            dmpGsPortalUtl.inputText(IG_PARTICIPANT_PARTICIPANT_PURPOSE, dataMap.get(INSTGRP_PARTICIPANT_PURC), ENTER, mandatoryFlag);
            dmpGsPortalUtl.inputTextInLookUpField(IG_PREFERRED_IDENTIFIER_VALUE_LOOKUP, "ISIN", dataMap.get(INSTGRP_PREFERRED_IDENTIFIER_VALUE), false);
            dmpGsPortalUtl.inputText(IG_PARTICIPANT_PARTICIPANT_DESCRIPTION, dataMap.get(INSTGRP_PARTICIPANT_DESC), ENTER, false);
            dmpGsPortalUtl.inputText(IG_PARTICIPANT_PARTICIPANT_AMOUNT, dataMap.get(INSTGRP_PARTICIPANT_AMOUNT), ENTER, false);
            dmpGsPortalUtl.inputText(IG_PARTICIPANT_PARTICIPANT_PERCENT, dataMap.get(INSTGRP_PARTICIPANT_PERCENT), ENTER, false);
            dmpGsPortalUtl.inputText(IG_PARTICIPANT_PARTICIPANT_CCY, dataMap.get(INSTGRP_PARTICIPANT_CCY), ENTER, false);
            dmpGsPortalUtl.inputText(IG_PARTICIPANT_PARTICIPANT_TYPE, dataMap.get(INSTGRP_PARTICIPANT_TYPE), ENTER, false);
            dmpGsPortalUtl.inputText(IG_PARTICIPANT_PARTICIPANT_CREATED_ON, dataMap.get(INSTGRP_PARTICIPANT_CREATEDON), ENTER, false);
            dmpGsPortalUtl.inputText(IG_PARTICIPANT_PARTICIPANT_EFFECTIVE_UNTIL, dataMap.get(INSTGRP_PARTICIPANT_EFFICTIVEUNTIL), ENTER, false);

            return this;

        } catch (Exception e) {
            LOGGER.error("Exception Occurred while filling Group Participant Details", e);
            throw new CartException(CartExceptionType.IO_ERROR, "Exception Occurred while filling Group Participant Details");
        }
    }


    public LinkedHashMap<String, String> getInstrumentGroupDetails() {
        LinkedHashMap<String, String> dataMap = new LinkedHashMap<>();
        try {
            dataMap.put(INSTGRP_GROUP_ID, webTaskSvc.getWebElementAttribute(IG_BASIC_GROUP_ID, VALUE));
            dataMap.put(INSTGRP_GROUP_NAME, webTaskSvc.getWebElementAttribute(IG_BASIC_GROUP_NAME, VALUE));
            dataMap.put(INSTGRP_GROUP_PURC, webTaskSvc.getWebElementAttribute(IG_BASIC_GROUP_PURPOSE, VALUE));
            dataMap.put(INSTGRP_GROUP_DESC, webTaskSvc.getWebElementAttribute(IG_BASIC_GROUP_DESCRIPTION, VALUE));
            dataMap.put(INSTGRP_SUBSCRIBER_DOWNSTREAM, webTaskSvc.getWebElementAttribute(IG_BASIC_SUBSCRIBER_DOWNSTREAM, VALUE));
            dataMap.put(INSTGRP_ENTERPRISE, webTaskSvc.getWebElementAttribute(IG_BASIC_ENTERPRISE, VALUE));
            dataMap.put(INSTGRP_ASSET_SUBDIVISION_NAME, webTaskSvc.getWebElementAttribute(IG_BASIC_ASSET_SUBDIVISION_NAME, VALUE));
            dataMap.put(INSTGRP_GROUP_CREATED_ON, webTaskSvc.getWebElementAttribute(IG_BASIC_GROUP_CREATED_ON, VALUE));
            dataMap.put(INSTGRP_GROUP_EFFICTIVE_UNTIL, webTaskSvc.getWebElementAttribute(IG_BASIC_GROUP_EFFECTIVE_UNTIL, VALUE));
            dataMap.put(INSTGRP_INSTRUMENT_NAME, webTaskSvc.getWebElementAttribute(IG_PARTICIPANT_INSTRUMENT_NAME_INPUT, VALUE));
            dataMap.put(INSTGRP_PARTICIPANT_PURC, webTaskSvc.getWebElementAttribute(IG_PARTICIPANT_PARTICIPANT_PURPOSE, VALUE));
            dataMap.put(INSTGRP_PARTICIPANT_DESC, webTaskSvc.getWebElementAttribute(IG_PARTICIPANT_PARTICIPANT_DESCRIPTION, VALUE));
            dataMap.put(INSTGRP_PARTICIPANT_AMOUNT, webTaskSvc.getWebElementAttribute(IG_PARTICIPANT_PARTICIPANT_AMOUNT, VALUE));
            dataMap.put(INSTGRP_PARTICIPANT_PERCENT, webTaskSvc.getWebElementAttribute(IG_PARTICIPANT_PARTICIPANT_PERCENT, VALUE));
            dataMap.put(INSTGRP_PARTICIPANT_CCY, webTaskSvc.getWebElementAttribute(IG_PARTICIPANT_PARTICIPANT_CCY, VALUE));
            dataMap.put(INSTGRP_PARTICIPANT_TYPE, webTaskSvc.getWebElementAttribute(IG_PARTICIPANT_PARTICIPANT_TYPE, VALUE));
            dataMap.put(INSTGRP_PARTICIPANT_CREATEDON, webTaskSvc.getWebElementAttribute(IG_PARTICIPANT_PARTICIPANT_CREATED_ON, VALUE));
            dataMap.put(INSTGRP_PARTICIPANT_EFFICTIVEUNTIL, webTaskSvc.getWebElementAttribute(IG_PARTICIPANT_PARTICIPANT_EFFECTIVE_UNTIL, VALUE));
            dmpGsPortalUtl.invokeDetailsView();
            return dataMap;

        } catch (Exception e) {
            LOGGER.error("Exception Occurred while reading Active Instrument Group Details", e);
            throw new CartException(CartExceptionType.IO_ERROR, "Exception Occurred while reading Active Instrument Group Details");
        }
    }

    public LinkedHashMap<String, String> getInstrumentGroupParticipantDetails(final LinkedHashMap<String, String> dataMap) {


        try {
            dmpGsPortalUtl.filterPopupContentTable("ISIN", dataMap.get(INSTGRP_PREFERRED_IDENTIFIER_VALUE), true);
            threadSvc.sleepSeconds(2);
            dataMap.put(INSTGRP_PREFERRED_IDENTIFIER_VALUE, webTaskSvc.getWebElementAttribute(IG_PREFERRED_IDENTIFIER_VALUE_INPUT, VALUE));
            dataMap.put(INSTGRP_PARTICIPANT_PURC, webTaskSvc.getWebElementAttribute(IG_PARTICIPANT_PARTICIPANT_PURPOSE, VALUE));
            dataMap.put(INSTGRP_PARTICIPANT_DESC, webTaskSvc.getWebElementAttribute(IG_PARTICIPANT_PARTICIPANT_DESCRIPTION, VALUE));
            dataMap.put(INSTGRP_PARTICIPANT_AMOUNT, webTaskSvc.getWebElementAttribute(IG_PARTICIPANT_PARTICIPANT_AMOUNT, VALUE));
            dataMap.put(INSTGRP_PARTICIPANT_PERCENT, webTaskSvc.getWebElementAttribute(IG_PARTICIPANT_PARTICIPANT_PERCENT, VALUE));
            dataMap.put(INSTGRP_PARTICIPANT_CCY, webTaskSvc.getWebElementAttribute(IG_PARTICIPANT_PARTICIPANT_CCY, VALUE));
            dataMap.put(INSTGRP_PARTICIPANT_TYPE, webTaskSvc.getWebElementAttribute(IG_PARTICIPANT_PARTICIPANT_TYPE, VALUE));
            dataMap.put(INSTGRP_PARTICIPANT_CREATEDON, webTaskSvc.getWebElementAttribute(IG_PARTICIPANT_PARTICIPANT_CREATED_ON, VALUE));
            dataMap.put(INSTGRP_PARTICIPANT_EFFICTIVEUNTIL, webTaskSvc.getWebElementAttribute(IG_PARTICIPANT_PARTICIPANT_EFFECTIVE_UNTIL, VALUE));

            return dataMap;

        } catch (Exception e) {
            LOGGER.error("Exception Occurred while reading Active Instrument Group Participant Instrument Group Details", e);
            throw new CartException(CartExceptionType.IO_ERROR, "Exception Occurred while reading Active Instrument Group Participant Instrument Group Details");
        }
    }

    public InstrumentGroupPage openInstrumentGroup(final String instrumentGrpName) {
        this.invokeInstrumentGroupScreen();
        dmpGsPortalUtl.filterTable("Group Name", instrumentGrpName, false);
        return this;
    }

    public boolean verifyInstrumentGroupCreated(final String instrumentGrpName) {
        this.openInstrumentGroup(instrumentGrpName);
        boolean searchRecordAvailable = dmpGsPortalUtl.isSearchRecordAvailable(instrumentGrpName);
        dmpGsPortalUtl.invokeDetailsView();
        dmpGsPortalSteps.closeActiveGsTab();
        return searchRecordAvailable;
    }


}
