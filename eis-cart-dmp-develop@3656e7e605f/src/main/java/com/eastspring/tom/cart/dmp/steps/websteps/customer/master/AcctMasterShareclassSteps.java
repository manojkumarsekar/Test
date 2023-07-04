package com.eastspring.tom.cart.dmp.steps.websteps.customer.master;

import com.eastspring.tom.cart.core.CartException;
import com.eastspring.tom.cart.core.CartExceptionType;
import com.eastspring.tom.cart.core.svc.StateSvc;
import com.eastspring.tom.cart.dmp.pages.customer.master.AccountMasterShareClassPage;
import com.eastspring.tom.cart.dmp.steps.DmpGsPortalSteps;
import com.eastspring.tom.cart.dmp.utl.DmpGsPortalUtl;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;

import java.util.Map;
import java.util.Set;

import static com.eastspring.tom.cart.constant.CommonLocators.VARIABLE;
import static com.eastspring.tom.cart.dmp.mdl.GSUIFields.*;

public class AcctMasterShareclassSteps {

    private static final Logger LOGGER = LoggerFactory.getLogger(AcctMasterShareclassSteps.class);

    @Autowired
    private AccountMasterShareClassPage shareclassPage;

    @Autowired
    private DmpGsPortalSteps portalSteps;

    @Autowired
    private StateSvc stateSvc;

    @Autowired
    private DmpGsPortalUtl dmpGsPortalUtl;

    public void iCreateShareclass(Map<String, String> map) {

        final String portfolioName = map.get(AM_PORTFOLIO_NAME);
        shareclassPage.initializeShareClassData(map);

        if (portfolioName.contains(VARIABLE)) {
            shareclassPage.invokeAccountMasterShareclass();
        } else {
            shareclassPage.invokeAccountMasterShareclass(map.get(AM_PORTFOLIO_NAME));
        }
        shareclassPage.fillShareclassDetails(map)
                .fillShareclassIdentifiersDetails(map)
                .fillShareclassXReferenceDetails(map)
                .fillShareclassBenchmarkDetails(map);
    }

    public void iUpdateShareclass(String shareclassSection, final Map<String, String> map) {
        switch (shareclassSection) {
            case "shareclassDetails":
                shareclassPage.fillShareclassDetails(map);
                break;
            case "shareclassIdentifiers":
                shareclassPage.fillShareclassIdentifiersDetails(map);
                break;
            case "shareclassXreference":
                shareclassPage.fillShareclassXReferenceDetails(map);
                break;
            case "shareclassBenchmarks":
                shareclassPage.fillShareclassBenchmarkDetails(map);
                break;
            default:
                LOGGER.error("Unsupported action [{}] in Shareclass Page", shareclassSection);
                throw new CartException(CartExceptionType.UNSUPPORTED_ENCODING, "Unsupported action [{}] in Shareclass Page", shareclassSection);
        }
    }


    public void iExpectShareclassUpdatedForGivenShareclass(final Map<String, String> map) {
        Map<String, String> shareClassDetails = shareclassPage.getShareClassDetails();

        Set<String> fields = map.keySet();
        for (String field : fields) {
            String expectedVal = stateSvc.expandVar(map.get(field));
            String actualVal = shareClassDetails.get(field);
            if (!expectedVal.equals(actualVal)) {
                LOGGER.error("Shareclass verification failed, Field [{}] Expected Value [{}], but Actual Value [{}]", field, expectedVal, actualVal);
                throw new CartException(CartExceptionType.VERIFICATION_FAILED, "Shareclass verification failed, Field [{}] Expected Value [{}], but Actual Value [{}]", field, expectedVal, actualVal);
            }
        }
    }


}
