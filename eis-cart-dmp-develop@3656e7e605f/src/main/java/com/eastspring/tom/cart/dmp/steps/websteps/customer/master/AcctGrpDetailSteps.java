package com.eastspring.tom.cart.dmp.steps.websteps.customer.master;

import com.eastspring.tom.cart.core.CartException;
import com.eastspring.tom.cart.core.CartExceptionType;
import com.eastspring.tom.cart.core.svc.StateSvc;
import com.eastspring.tom.cart.dmp.pages.customer.master.AcctGrpDetailPage;
import com.eastspring.tom.cart.dmp.steps.DmpGsPortalSteps;
import com.eastspring.tom.cart.dmp.utl.DmpGsPortalUtl;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;

import java.util.LinkedHashMap;
import java.util.Set;

import static com.eastspring.tom.cart.constant.CommonLocators.GS_POPUP_DATA_TABLE_XPATH;

public class AcctGrpDetailSteps {

    private static final Logger LOGGER = LoggerFactory.getLogger(AcctGrpDetailSteps.class);

    @Autowired
    private AcctGrpDetailPage acctGrpDetailPage;

    @Autowired
    private DmpGsPortalSteps portalSteps;

    @Autowired
    private DmpGsPortalUtl dmpGsPortalUtl;

    @Autowired
    private StateSvc stateSvc;


    public void iCreateAccountGroup(final LinkedHashMap<String, String> dataMap) {
        acctGrpDetailPage.invokeAccountGroupDetailScreen()
                .invokeSetup()
                .initializeAccountGroup(dataMap)
                .fillAccountGroupDetails(dataMap, false);
    }

    public void iCreateAccountGroupAndParticipantDetails(final LinkedHashMap<String, String> dataMap) {
        acctGrpDetailPage.invokeAccountGroupDetailScreen()
                .invokeSetup()
                .initializeAccountGroup(dataMap)
                .fillAccountGroupDetails(dataMap, false)
                .invokeAddParticipantDetails()
                .fillGroupParticipantDetails(dataMap);
    }

    public void iAddParticipantDetails(final LinkedHashMap<String, String> dataMap) {
        acctGrpDetailPage.invokeAddParticipantDetails()
                .fillGroupParticipantDetails(dataMap);
    }

    public void iAddParticipantDetailsToGivenGroup(final String accountGrpId, final LinkedHashMap<String, String> dataMap) {
        acctGrpDetailPage.openAccountGroup(accountGrpId)
                .invokeAddParticipantDetails()
                .fillGroupParticipantDetails(dataMap);
    }

    public void iUpdateAccountGroup(final String accountGrpId, final LinkedHashMap<String, String> dataMap) {
        acctGrpDetailPage.openAccountGroup(accountGrpId)
                .fillAccountGroupDetails(dataMap, true);
    }

    public void iExpectAccountGroupIsCreated(final String accountGrpId) {
        if (!acctGrpDetailPage.verifyAccountGroupIsCreated(accountGrpId)) {
            LOGGER.error("Verification failed, Account Group ID [{}] is not created", accountGrpId);
            throw new CartException(CartExceptionType.VERIFICATION_FAILED, "Verification failed, Account Group ID [{}] is not created", accountGrpId);
        }
    }

    public void iExpectParticipantDetailsAreAddedToGivenGroup(final String accountGrpId, final LinkedHashMap<String, String> dataMap) {
        acctGrpDetailPage.openAccountGroup(accountGrpId)
                .invokeDetailsView()
                .searchParticipantDetails(dataMap);

        int actualRowCount = dmpGsPortalUtl.getTableRowCount(GS_POPUP_DATA_TABLE_XPATH);
        dmpGsPortalUtl.assertEquals(1, actualRowCount);
    }

    public void iExpectAccountGroupIsUpdated(final String accountGrpId, final LinkedHashMap<String, String> dataMap) {
        acctGrpDetailPage.openAccountGroup(accountGrpId);
        LinkedHashMap<String, String> accountGroupDetails = acctGrpDetailPage.getAccountGroupDetails();
        portalSteps.closeActiveGsTab();

        Set<String> fields = dataMap.keySet();
        for (String field : fields) {
            String expectedVal = stateSvc.expandVar(dataMap.get(field));
            String actualVal = accountGroupDetails.get(field);
            if (!expectedVal.equals(actualVal)) {
                LOGGER.error("Account Group Details verification failed, Field [{}] Expected Value [{}], but Actual Value [{}]", field, expectedVal, actualVal);
                throw new CartException(CartExceptionType.VERIFICATION_FAILED, "Account Group Details verification failed, Field [{}] Expected Value [{}], but Actual Value [{}]", field, expectedVal, actualVal);
            }
        }
    }

}
