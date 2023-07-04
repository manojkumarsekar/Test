package com.eastspring.tom.cart.dmp.steps.websteps.security.master;

import com.eastspring.tom.cart.core.CartException;
import com.eastspring.tom.cart.core.CartExceptionType;
import com.eastspring.tom.cart.core.svc.StateSvc;
import com.eastspring.tom.cart.dmp.pages.security.master.InstrumentGroupPage;
import com.eastspring.tom.cart.dmp.steps.DmpGsPortalSteps;
import com.eastspring.tom.cart.dmp.utl.DmpGsPortalUtl;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;

import java.util.LinkedHashMap;
import java.util.Set;

public class InstrumentGroupSteps {

    private static final Logger LOGGER = LoggerFactory.getLogger(InstrumentGroupSteps.class);

    @Autowired
    private DmpGsPortalSteps portalSteps;

    @Autowired
    private DmpGsPortalUtl dmpGsPortalUtl;

    @Autowired
    private InstrumentGroupPage instrumentGroupPage;

    @Autowired
    private StateSvc stateSvc;

    public void iCreateInstrumentGroup(final LinkedHashMap<String, String> dataMap) {
        instrumentGroupPage.invokeInstrumentGroupScreen()
                .invokeSetup()
                .fillGroupBasicDetails(dataMap, false);

    }

    public void iCreateInstrumentGroupAndParticipant(final LinkedHashMap<String, String> dataMap) {
        instrumentGroupPage
                .invokeAddParticipantDetails()
                .fillGroupParticipantDetails(dataMap, false);
    }

    public void iUpdateInstrumentGroupAndParticipant(final String groupName, final LinkedHashMap<String, String> dataMap) {
        instrumentGroupPage.openInstrumentGroup(groupName)
                .fillGroupBasicDetails(dataMap, true)
                .fillGroupParticipantDetails(dataMap, true);
    }

    public void iAddParticipantDetailsToGivenGroup(final String groupName, final LinkedHashMap<String, String> dataMap) {
        instrumentGroupPage.openInstrumentGroup(groupName)
                .invokeAddParticipantDetails()
                .fillGroupParticipantDetails(dataMap, false);

    }

    public void iExpectInstrumentGroupAddedWithBelowDetails(final String groupName, final LinkedHashMap<String, String> dataMap) {
        LinkedHashMap<String, String> instrumentGroupDetails = instrumentGroupPage.openInstrumentGroup(groupName).getInstrumentGroupDetails();
        Set<String> fields = dataMap.keySet();
        for (String field : fields) {
            String expectedVal = stateSvc.expandVar(dataMap.get(field));
            String actualVal = instrumentGroupDetails.get(field);
            if (!expectedVal.equals(actualVal)) {
                LOGGER.error("Instrument Group Details verification failed, Field [{}] Expected Value [{}], but Actual Value [{}]", field, expectedVal, actualVal);
                throw new CartException(CartExceptionType.VERIFICATION_FAILED, "Instrument Group Details verification failed, Field [{}] Expected Value [{}], but Actual Value [{}]", field, expectedVal, actualVal);
            }
        }
    }

    public void iExpectInstrumentGroupParticipantWithBelowDetails(final LinkedHashMap<String, String> dataMap) {
        LinkedHashMap<String, String> instrumentGroupDetails = instrumentGroupPage.getInstrumentGroupParticipantDetails(dataMap);
        Set<String> fields = dataMap.keySet();
        for (String field : fields) {
            String expectedVal = stateSvc.expandVar(dataMap.get(field));
            String actualVal = instrumentGroupDetails.get(field);
            if (!expectedVal.equals(actualVal)) {
                LOGGER.error("Instrument Group Particpant Details verification failed, Field [{}] Expected Value [{}], but Actual Value [{}]", field, expectedVal, actualVal);
                throw new CartException(CartExceptionType.VERIFICATION_FAILED, "Instrument Group Particpant Details verification failed, Field [{}] Expected Value [{}], but Actual Value [{}]", field, expectedVal, actualVal);
            }
        }
    }

    public void iExpectInstrumentGroupCreated(final String groupName) {
        if (!instrumentGroupPage.verifyInstrumentGroupCreated(groupName)) {
            LOGGER.error("Verification failed, Instrument Group Name [{}] is not created", groupName);
            throw new CartException(CartExceptionType.VERIFICATION_FAILED, "Verification failed, Instrument Group Name [{}] is not created", groupName);
        }
    }


}
