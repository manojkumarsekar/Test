package com.eastspring.tom.cart.dmp.steps.websteps.security.master;

import com.eastspring.tom.cart.core.CartException;
import com.eastspring.tom.cart.core.CartExceptionType;
import com.eastspring.tom.cart.core.svc.StateSvc;
import com.eastspring.tom.cart.dmp.pages.security.master.InstitutionPage;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;

import java.util.LinkedHashMap;
import java.util.Map;
import java.util.Set;

public class InstitutionSteps {

    private static final Logger LOGGER = LoggerFactory.getLogger(InstitutionSteps.class);

    @Autowired
    private InstitutionPage institutionPage;

    @Autowired
    private StateSvc stateSvc;

    public void iAddInstitutionDetails(LinkedHashMap<String, String> dataMap) {
        institutionPage.invokeInstitutionScreen()
                .invokeSetup()
                .fillInstitutionDetails(dataMap, false);
    }

    public void iUpdateInstitutionDetails(final LinkedHashMap<String, String> dataMap) {
        institutionPage.fillInstitutionDetails(dataMap, true);
    }

    public void iOpenInstitutionRecord(final String institutionName) {
        institutionPage.searchInstitution(institutionName);
    }

    public void iAddInstitutionIdentifiers(LinkedHashMap<String, String> dataMap) {
        institutionPage.switchToTab("Identifiers")
                .fillFinInstitutionIdentifiers(dataMap);
    }

    public void iExpectInstitutionRecordCreated(final String name) {
        String expectedVal = stateSvc.expandVar(name);
        if (!institutionPage.verifyInstitutionIsCreated(expectedVal)) {
            LOGGER.error("Verification failed, Institution [{}] is not created", expectedVal);
            throw new CartException(CartExceptionType.VERIFICATION_FAILED, "Verification failed, Institution [{}] is not created", expectedVal);
        }
    }

    public void iExpectInstitutionDetailsAreUpdated(final Map<String, String> dataMap) {
        Map<String, String> institutionDetails = institutionPage.getInstitutionDetails();

        Set<String> fields = dataMap.keySet();
        for (String field : fields) {
            String expectedVal = stateSvc.expandVar(dataMap.get(field));
            String actualVal = institutionDetails.get(field);
            if (!expectedVal.equals(actualVal)) {
                LOGGER.error("Institution Details Verification failed, Field [{}] Expected Value [{}], but Actual Value [{}]", field, expectedVal, actualVal);
                throw new CartException(CartExceptionType.VERIFICATION_FAILED, "Institution Details Verification failed, Field [{}] Expected Value [{}], but Actual Value [{}]", field, expectedVal, actualVal);
            }
        }
    }

    public void iExpectFinInstitutionIdentifiersAreUpdated(final Map<String, String> dataMap) {
        institutionPage.switchToTab("Identifiers");
        Map<String, String> finInstitutionIdentifiers = institutionPage.getFinInstitutionIdentifiers();

        Set<String> fields = dataMap.keySet();
        for (String field : fields) {
            String expectedVal = stateSvc.expandVar(dataMap.get(field));
            String actualVal = finInstitutionIdentifiers.get(field);
            if (!expectedVal.equals(actualVal)) {
                LOGGER.error("Institution Identifiers Verification failed, Field [{}] Expected Value [{}], but Actual Value [{}]", field, expectedVal, actualVal);
                throw new CartException(CartExceptionType.VERIFICATION_FAILED, "Institution Identifiers Verification failed, Field [{}] Expected Value [{}], but Actual Value [{}]", field, expectedVal, actualVal);
            }
        }
    }

    //New method added for EISDEV-5276
    public void iAddLbuIdentifiers(LinkedHashMap<String, String> dataMap) {
        institutionPage.switchToTab("LBU Identifiers")
                .fillFinInstitutionLbuIdentifiers(dataMap);
    }

    //New method added for EISDEV-5276
    public void iExpectFinInstitutionLbuIdentifiersAreCreated(final Map<String, String> dataMap) {
        institutionPage.switchToTab("LBU Identifiers");
        Map<String, String> lbuIdentifiers = institutionPage.getFinInstitutionLbuIdentifiers();

        for (Map.Entry<String, String> entry : dataMap.entrySet()) {
            String expectedVal = stateSvc.expandVar(entry.getValue());
            String actualVal = lbuIdentifiers .get(entry.getKey());
            if (!expectedVal.equals(actualVal)) {
                LOGGER.error("LBU Identifiers Verification failed, Field [{}] Expected Value [{}], but Actual Value [{}]", entry.getKey(), expectedVal, actualVal);
                throw new CartException(CartExceptionType.VERIFICATION_FAILED, "Verification failed, Field [{}] Expected Value [{}], but Actual Value [{}]", entry.getKey(), expectedVal, actualVal);
            }
        }
    }

    //New method added for EISDEV-5276
    public void iAddSsdrOrgChartAttributes(LinkedHashMap<String, String> dataMap) {
        institutionPage.switchToTab("SSDR OrgChart Specific Attributes")
                .fillFinInstitutionSsdrOrgChart(dataMap);
    }

    public void iExpectSsdrOrgChartAttributesAreCreated(final Map<String, String> dataMap) {
        institutionPage.switchToTab("SSDR OrgChart Specific Attributes");
        Map<String, String> ssdrOrgChartAttributes = institutionPage.getFinInstitutionSsdrOrgChart();

        for (Map.Entry<String, String> entry : dataMap.entrySet()) {
            String expectedVal = stateSvc.expandVar(entry.getValue());
            String actualVal = ssdrOrgChartAttributes.get(entry.getKey());
            if (!expectedVal.equals(actualVal)) {
                LOGGER.error("SSDR OrgChart Specific Attributes Verification failed, Field [{}] Expected Value [{}], but Actual Value [{}]", entry.getKey(), expectedVal, actualVal);
                throw new CartException(CartExceptionType.VERIFICATION_FAILED, "SSDR OrgChart Specific Attributes Verification failed, Field [{}] Expected Value [{}], but Actual Value [{}]", entry.getKey(), expectedVal, actualVal);
            }
        }
    }

    //New method added for EISDEV-5276
    public void iAddAddressDetails(LinkedHashMap<String, String> dataMap) {
        institutionPage.switchToTab("Address Details").invokeAddDetails()
                .fillFinInstitutionAddressDetails(dataMap);
    }

    //New method added for EISDEV-5276
    public void iExpectAddressDetailsAreCreated(final Map<String, String> dataMap) {
        institutionPage.switchToTab("Address Details");
        Map<String, String> addressDetails = institutionPage.getFinInstitutionAddressDetails();

        for (Map.Entry<String , String> entry: dataMap.entrySet()) {
            String expectedVal = stateSvc.expandVar(entry.getValue());
            String actualVal = addressDetails.get(entry.getKey());
            if (!expectedVal.equals(actualVal)) {
                LOGGER.error("Address Details Verification failed, Field [{}] Expected Value [{}], but Actual Value [{}]", entry.getKey(), expectedVal, actualVal);
                throw new CartException(CartExceptionType.VERIFICATION_FAILED, "Address Details Verification failed, Field [{}] Expected Value [{}], but Actual Value [{}]", entry.getKey(), expectedVal, actualVal);
            }
        }
    }

}
