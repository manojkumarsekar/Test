package com.eastspring.tom.cart.dmp.steps.websteps.generic.setup;

import com.eastspring.tom.cart.core.CartException;
import com.eastspring.tom.cart.core.CartExceptionType;
import com.eastspring.tom.cart.core.svc.StateSvc;
import com.eastspring.tom.cart.dmp.pages.generic.setup.RequestTypeConfigPage;
import com.eastspring.tom.cart.dmp.steps.DmpGsPortalSteps;
import com.eastspring.tom.cart.dmp.utl.DmpGsPortalUtl;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;

import java.util.LinkedHashMap;
import java.util.Set;

public class RequestTypeConfigSteps {

    private static final Logger LOGGER = LoggerFactory.getLogger(RequestTypeConfigSteps.class);

    @Autowired
    private RequestTypeConfigPage requestTypeConfigPage;

    @Autowired
    private DmpGsPortalSteps portalSteps;

    @Autowired
    private DmpGsPortalUtl dmpGsPortalUtl;

    @Autowired
    private StateSvc stateSvc;

    public void iCreateRequestTypeConfiguration(final LinkedHashMap<String, String> dataMap) {
        requestTypeConfigPage.invokeRequestTypeConfigScreen()
                .invokeSetup()
                .fillRequestTypeConfigDetails(dataMap, false);
    }

    public void iUpdateRequestTypeConfiguration(final LinkedHashMap<String, String> dataMap) {
        requestTypeConfigPage.fillRequestTypeConfigDetails(dataMap, true);
    }

    public void iExpectRequestTypeConfigurationCreated(final LinkedHashMap<String, String> dataMap) {
        String key = dataMap.entrySet().stream().findFirst().get().getKey();
        String value = dataMap.entrySet().stream().findFirst().get().getValue();

        if (!requestTypeConfigPage.verifyRequestTypeConfigIsCreated(dataMap)) {
            LOGGER.error("Verification failed, Request Type Configuration with [{}] as [{}] is not created", key, value);
            throw new CartException(CartExceptionType.VERIFICATION_FAILED, "Verification failed, Request Type Configuration with [{}] as [{}] is not created", key, value);
        }
    }

    public void iExpectRequestTypeConfigurationIsUpdated(final LinkedHashMap<String, String> dataMap) {
        requestTypeConfigPage.openRequestTypeConfig(dataMap);
        LinkedHashMap<String, String> configDetails = requestTypeConfigPage.getRequestTypeConfigDetails();
        portalSteps.closeActiveGsTab();

        Set<String> fields = dataMap.keySet();
        for (String field : fields) {
            String expectedVal = stateSvc.expandVar(dataMap.get(field));
            String actualVal = configDetails.get(field);
            if (!expectedVal.equals(actualVal)) {
                LOGGER.error("RequestTypeConfiguration Details verification failed, Field [{}] Expected Value [{}], but Actual Value [{}]", field, expectedVal, actualVal);
                throw new CartException(CartExceptionType.VERIFICATION_FAILED, "RequestTypeConfiguration Details verification failed, Field [{}] Expected Value [{}], but Actual Value [{}]", field, expectedVal, actualVal);
            }
        }
    }

    public void iSearchRequestTypeConfigurationCreated(final LinkedHashMap<String, String> dataMap) {
        requestTypeConfigPage.openRequestTypeConfig(dataMap);
    }


}
