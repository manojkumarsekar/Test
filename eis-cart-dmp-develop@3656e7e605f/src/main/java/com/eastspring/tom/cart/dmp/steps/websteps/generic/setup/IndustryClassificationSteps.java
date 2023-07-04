package com.eastspring.tom.cart.dmp.steps.websteps.generic.setup;

import com.eastspring.tom.cart.core.CartException;
import com.eastspring.tom.cart.core.CartExceptionType;
import com.eastspring.tom.cart.core.svc.StateSvc;
import com.eastspring.tom.cart.dmp.pages.HomePage;
import com.eastspring.tom.cart.dmp.pages.generic.setup.CentralCrossRefGrpPage;
import com.eastspring.tom.cart.dmp.pages.industryclassif.IndustryClassificationSetPage;
import com.eastspring.tom.cart.dmp.pages.myworklist.MyWorkListPage;
import com.eastspring.tom.cart.dmp.steps.DmpGsPortalSteps;
import com.eastspring.tom.cart.dmp.utl.DmpGsPortalUtl;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;

import java.util.LinkedHashMap;
import java.util.Map;
import java.util.Set;

public class IndustryClassificationSteps {

    private static final Logger LOGGER = LoggerFactory.getLogger(IndustryClassificationSteps.class);

    @Autowired
    private CentralCrossRefGrpPage centralCrossRefGrpPage;

    @Autowired
    private DmpGsPortalSteps portalSteps;

    @Autowired
    private HomePage homePage;

    @Autowired
    private DmpGsPortalUtl dmpGsPortalUtl;

    @Autowired
    private StateSvc stateSvc;

    @Autowired
    private IndustryClassificationSetPage industryClassificationSetPage;

    @Autowired
    private MyWorkListPage myWorkListPage;

    public void iAddIndustryClassificationDetails(final String mnemonic, final Map<String, String> classifDetails) {
        industryClassificationSetPage.navigateToIndusClassifSet()
                .invokeClassificationSet(mnemonic)
                .invokeAddNewDetails()
                .fillIndustryClassificationDetails(mnemonic,classifDetails);
    }

    public void iDeleteIndustryClassificationDetails(final String setMnemonic, final Map<String, String> classifDetails) {
        industryClassificationSetPage.navigateToIndusClassifSet()
                .invokeClassificationSet(setMnemonic)
                .invokeDetailsView()
                .searchIndustryClassificationDetails(classifDetails)
                .deleteActiveRecordFromDetailView();
    }

     public void iExpectIndustryClassificationDetailsUpdated(final String mnemonic,final Map<String, String> map) {
        Map<String, String> industryClassificationDetails = industryClassificationSetPage.navigateToIndusClassifSet()
                .invokeClassificationSet(mnemonic)
                .getActiveIndustryClassificationDetails();

        Set<String> fields = map.keySet();
        for (String field : fields) {
            String expectedVal = stateSvc.expandVar(map.get(field));
            String actualVal = industryClassificationDetails.get(field);
            if (!expectedVal.equals(actualVal)) {
                LOGGER.error("IC Details Verification failed, Field [{}] Expected Value [{}], but Actual Value [{}]", field, expectedVal, actualVal);
                throw new CartException(CartExceptionType.VERIFICATION_FAILED, "IC Details Verification failed, Field [{}] Expected Value [{}], but Actual Value [{}]", field, expectedVal, actualVal);
            }
        }
    }

}
