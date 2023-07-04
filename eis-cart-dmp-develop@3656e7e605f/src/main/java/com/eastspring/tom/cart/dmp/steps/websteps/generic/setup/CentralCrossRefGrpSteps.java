package com.eastspring.tom.cart.dmp.steps.websteps.generic.setup;

import com.eastspring.tom.cart.core.CartException;
import com.eastspring.tom.cart.core.CartExceptionType;
import com.eastspring.tom.cart.core.svc.StateSvc;
import com.eastspring.tom.cart.dmp.pages.generic.setup.CentralCrossRefGrpPage;
import com.eastspring.tom.cart.dmp.steps.DmpGsPortalSteps;
import com.eastspring.tom.cart.dmp.utl.DmpGsPortalUtl;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;

import java.util.LinkedHashMap;
import java.util.Set;

public class CentralCrossRefGrpSteps {

    private static final Logger LOGGER = LoggerFactory.getLogger(CentralCrossRefGrpSteps.class);

    @Autowired
    private CentralCrossRefGrpPage centralCrossRefGrpPage;

    @Autowired
    private DmpGsPortalSteps portalSteps;

    @Autowired
    private DmpGsPortalUtl dmpGsPortalUtl;

    @Autowired
    private StateSvc stateSvc;

    public void iCreateCentralCrossRefGroup(final LinkedHashMap<String, String> dataMap) {
        centralCrossRefGrpPage.invokeCentralCrossRefGrpScreen()
                .invokeSetup()
                .fillGroupDetails(dataMap, false);
    }

    public void iCreateCentralCrossRefGroupAndParticipantDetails(final LinkedHashMap<String, String> dataMap) {
        centralCrossRefGrpPage.invokeCentralCrossRefGrpScreen()
                .invokeSetup()
                .fillGroupDetails(dataMap, false)
                .invokeAddParticipantDetails()
                .fillGroupParticipantDetails(dataMap, false);
    }


    public void iAddParticipantDetails(final LinkedHashMap<String, String> dataMap) {
        centralCrossRefGrpPage.invokeAddParticipantDetails()
                .fillGroupParticipantDetails(dataMap, false);
    }

    public void iAddParticipantDetailsToGivenGroup(final String groupName, final LinkedHashMap<String, String> dataMap) {
        centralCrossRefGrpPage.openCrossReferenceGroup(groupName)
                .invokeAddParticipantDetails()
                .fillGroupParticipantDetails(dataMap, false);

    }

    public void iUpdateCrossRefGroupDetails(final String groupName, final LinkedHashMap<String, String> dataMap) {
        centralCrossRefGrpPage.openCrossReferenceGroup(groupName)
                .fillGroupDetails(dataMap, true)
                .fillGroupParticipantDetails(dataMap, true);
    }

    public void iExpectCentralCrossRefGroupCreated(final String groupName) {
        final String expandGroupName = stateSvc.expandVar(groupName);
        if (!centralCrossRefGrpPage.verifyCrossReferenceGroupIsCreated(expandGroupName)) {
            LOGGER.error("Verification failed, Cross Reference Group Name [{}] is not created", expandGroupName);
            throw new CartException(CartExceptionType.VERIFICATION_FAILED, "Verification failed, Cross Reference Group Name [{}] is not created", expandGroupName);
        }
    }

    public void iExpectCrossRefGroupIsUpdated(final String groupName, final LinkedHashMap<String, String> dataMap) {
        LinkedHashMap<String, String> centralCrossRefGrpDetails = centralCrossRefGrpPage.openCrossReferenceGroup(groupName)
                .getCentralCrossRefGrpDetails();

        Set<String> fields = dataMap.keySet();
        for (String field : fields) {
            String expectedVal = stateSvc.expandVar(dataMap.get(field));
            String actualVal = centralCrossRefGrpDetails.get(field);
            if (!expectedVal.equals(actualVal)) {
                LOGGER.error("Central Cross Ref Group Details verification failed, Field [{}] Expected Value [{}], but Actual Value [{}]", field, expectedVal, actualVal);
                throw new CartException(CartExceptionType.VERIFICATION_FAILED, "Central Cross Ref Group Details verification failed, Field [{}] Expected Value [{}], but Actual Value [{}]", field, expectedVal, actualVal);
            }
        }
    }

    public void iExpectCrossRefGroupParticipantIsUpdated(final String groupName, final LinkedHashMap<String, String> dataMap) {
        LinkedHashMap<String, String> centralCrossRefGrpDetails = centralCrossRefGrpPage.openCrossReferenceGroup(groupName)
                .getCentralCrossRefGrpParticipantDetails();

        Set<String> fields = dataMap.keySet();
        for (String field : fields) {
            String expectedVal = stateSvc.expandVar(dataMap.get(field));
            String actualVal = centralCrossRefGrpDetails.get(field);
            if (!expectedVal.equals(actualVal)) {
                LOGGER.error("Central Cross Ref Group Details verification failed, Field [{}] Expected Value [{}], but Actual Value [{}]", field, expectedVal, actualVal);
                throw new CartException(CartExceptionType.VERIFICATION_FAILED, "Central Cross Ref Group Details verification failed, Field [{}] Expected Value [{}], but Actual Value [{}]", field, expectedVal, actualVal);
            }
        }
    }


}
