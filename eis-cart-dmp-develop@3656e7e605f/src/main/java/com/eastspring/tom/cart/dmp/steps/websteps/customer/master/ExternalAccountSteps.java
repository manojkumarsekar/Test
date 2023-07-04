package com.eastspring.tom.cart.dmp.steps.websteps.customer.master;

import com.eastspring.tom.cart.core.CartException;
import com.eastspring.tom.cart.core.CartExceptionType;
import com.eastspring.tom.cart.core.svc.StateSvc;
import com.eastspring.tom.cart.dmp.pages.customer.master.AccountMasterPage;
import com.eastspring.tom.cart.dmp.pages.customer.master.ExternalAccountPage;
import com.eastspring.tom.cart.dmp.steps.DmpGsPortalSteps;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;

import java.util.Map;
import java.util.Set;

import static com.eastspring.tom.cart.constant.CommonLocators.VARIABLE;
import static com.eastspring.tom.cart.dmp.mdl.GSUIFields.AM_PORTFOLIO_NAME;

public class ExternalAccountSteps {

    private static final Logger LOGGER = LoggerFactory.getLogger(ExternalAccountSteps.class);

    @Autowired
    private ExternalAccountPage externalAccountPage;

    @Autowired
    private DmpGsPortalSteps portalSteps;

    @Autowired
    private StateSvc stateSvc;


    public void iAddExternalAccountDetails(Map<String, String> dataMap) {
        externalAccountPage.invokeExternalAccountScreen()
                .invokeSetup()
                .fillExternalAccountDetails(dataMap, false);
    }

    public void iOpenExternalAccount(String extAcctId) {
        externalAccountPage.invokeExternalAccountScreen()
                .openExternalAccount(extAcctId);
    }

    public void iUpdateExternalAccountDetails(final Map<String, String> map) {
        externalAccountPage.fillExternalAccountDetails(map, true);
    }

    public void iExpectExternalAccountDetailsUpdated(final Map<String, String> map) {
        Map<String, String> extAcctDetails = externalAccountPage.getExternalAccountDetails();
        for (Map.Entry<String, String> entry : map.entrySet()) {
            String expectedVal = stateSvc.expandVar(entry.getValue());
            String actualVal = extAcctDetails.get(entry.getKey());
            if (!expectedVal.equals(actualVal)) {
                LOGGER.error("External Account details verification failed, Field [{}] Expected Value [{}], but Actual Value [{}]", entry.getKey(), expectedVal, actualVal);
                throw new CartException(CartExceptionType.VERIFICATION_FAILED, "External Account details  verification failed, Field [{}] Expected Value [{}], but Actual Value [{}]", entry.getKey(), expectedVal, actualVal);
            }
        }
    }

}
