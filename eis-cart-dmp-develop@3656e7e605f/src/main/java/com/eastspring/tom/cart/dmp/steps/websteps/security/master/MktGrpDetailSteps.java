package com.eastspring.tom.cart.dmp.steps.websteps.security.master;

import com.eastspring.tom.cart.core.CartException;
import com.eastspring.tom.cart.core.CartExceptionType;
import com.eastspring.tom.cart.core.svc.StateSvc;
import com.eastspring.tom.cart.dmp.pages.customer.master.AcctGrpDetailPage;
import com.eastspring.tom.cart.dmp.pages.security.master.MrktGrpDetailPage;
import com.eastspring.tom.cart.dmp.steps.DmpGsPortalSteps;
import com.eastspring.tom.cart.dmp.utl.DmpGsPortalUtl;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;

import java.util.LinkedHashMap;
import java.util.Set;

import static com.eastspring.tom.cart.constant.CommonLocators.GS_POPUP_DATA_TABLE_XPATH;

public class MktGrpDetailSteps {

    private static final Logger LOGGER = LoggerFactory.getLogger(MktGrpDetailSteps.class);

    @Autowired
    private MrktGrpDetailPage mktGrpDetailPage;

    @Autowired
    private DmpGsPortalSteps portalSteps;

    @Autowired
    private DmpGsPortalUtl dmpGsPortalUtl;

    @Autowired
    private StateSvc stateSvc;


    public void iCreateMarketGroup(final LinkedHashMap<String, String> dataMap) {
        mktGrpDetailPage.invokeMarketGroupDetailScreen()
                .invokeSetup()
                .fillMarketGroupDetails(dataMap, false);
    }


    public void iAddParticipantDetails(final LinkedHashMap<String, String> dataMap) {
        mktGrpDetailPage.invokeAddParticipantDetails()
                .fillGroupParticipantDetails(dataMap, false);
    }


    public void iUpdateMarketGroup(final String accountGrpId, final LinkedHashMap<String, String> dataMap) {
        mktGrpDetailPage.openMarketGroup(accountGrpId)
                .fillMarketGroupDetails(dataMap, true)
                .fillGroupParticipantDetails(dataMap, true);
    }

    public void iExpectMarketGroupIsCreated(final String accountGrpId) {
        if (!mktGrpDetailPage.verifyMarketGroupIsCreated(accountGrpId)) {
            LOGGER.error("Verification failed, Market Group [{}] is not created", accountGrpId);
            throw new CartException(CartExceptionType.VERIFICATION_FAILED, "Verification failed, Market Group [{}] is not created", accountGrpId);
        }
    }


    public void iExpectMarketGroupIsUpdated(final String accountGrpId, final LinkedHashMap<String, String> dataMap) {
        mktGrpDetailPage.openMarketGroup(accountGrpId);
        LinkedHashMap<String, String> accountGroupDetails = mktGrpDetailPage.getMarketGroupDetails();
        portalSteps.closeActiveGsTab();

        Set<String> fields = dataMap.keySet();
        for (String field : fields) {
            String expectedVal = stateSvc.expandVar(dataMap.get(field));
            String actualVal = accountGroupDetails.get(field);
            if (!expectedVal.equals(actualVal)) {
                LOGGER.error("Market Group Details verification failed, Field [{}] Expected Value [{}], but Actual Value [{}]", field, expectedVal, actualVal);
                throw new CartException(CartExceptionType.VERIFICATION_FAILED, "Market Group Details verification failed, Field [{}] Expected Value [{}], but Actual Value [{}]", field, expectedVal, actualVal);
            }
        }
    }

}
