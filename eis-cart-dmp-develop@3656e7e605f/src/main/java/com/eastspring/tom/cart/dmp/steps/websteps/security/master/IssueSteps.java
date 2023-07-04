package com.eastspring.tom.cart.dmp.steps.websteps.security.master;

import com.eastspring.tom.cart.core.CartException;
import com.eastspring.tom.cart.core.CartExceptionType;
import com.eastspring.tom.cart.core.svc.StateSvc;
import com.eastspring.tom.cart.dmp.pages.issue.IssuePage;
import com.eastspring.tom.cart.dmp.pages.myworklist.MyWorkListPage;
import com.eastspring.tom.cart.dmp.steps.DmpGsPortalSteps;
import com.eastspring.tom.cart.dmp.utl.DmpGsPortalUtl;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;

import java.util.Map;
import java.util.Set;

import static com.eastspring.tom.cart.dmp.pages.issue.IssuePage.*;
import static com.eastspring.tom.cart.dmp.pages.issue.IssuePage.INSTRUMENT_RATING_TAB;
import static com.eastspring.tom.cart.dmp.pages.issue.IssuePage.ISSUE_COMMENTS_TAB;

public class IssueSteps {

    private static final Logger LOGGER = LoggerFactory.getLogger(IssueSteps.class);

    @Autowired
    private IssuePage issuePage;

    @Autowired
    private StateSvc stateSvc;

    @Autowired
    private MyWorkListPage myWorkListPage;

    @Autowired
    private DmpGsPortalSteps dmpGsPortalSteps;

    @Autowired
    private DmpGsPortalUtl dmpGsPortalUtl;


    public void iExpectIssueRecordCreated(String issueName) {
        if (!issuePage.isIssuePresent(issueName)) {
            LOGGER.error("Issue creation failed [{}]", issueName);
            throw new CartException(CartExceptionType.VERIFICATION_FAILED, "Issue creation failed [{}]", issueName);
        }
    }

    public void iUpdateIssueInstrumentDetails(final Map<String, String> Map) {
        issuePage.fillInstrumentDetails(Map, true)
                .fillInstLevelIdentifier(Map);
    }

    public void iOpenExistingIssue(final String instrumentName) {
        issuePage.searchIssue(instrumentName);
    }

    public void iExpectIssueInstrumentDetailsUpdated(final String instrumentName, final Map<String, String> map) {
        Map<String, String> issueDetails = issuePage.searchIssue(instrumentName)
                .getIssueDetails();

        Set<String> fields = map.keySet();
        for (String field : fields) {
            String expectedVal = map.get(field);
            String actualVal = issueDetails.get(field);
            if (!expectedVal.equals(actualVal)) {
                LOGGER.error("Issue verification failed, Field [{}] Expected Value [{}], but Actual Value [{}]", field, expectedVal, actualVal);
                throw new CartException(CartExceptionType.VERIFICATION_FAILED, "Issue verification failed, Field [{}] Expected Value [{}], but Actual Value [{}]", field, expectedVal, actualVal);
            }
        }
    }


    public void iExpectIssueMarketLevelIdentifiersDetailsUpdated(final String instrumentName, final Map<String, String> map) {
        Map<String, String> issueDetails = issuePage.searchIssue(instrumentName).getIssueMarketLevelIdentifiersDetails();
        for (Map.Entry<String, String> entry : map.entrySet()) {
            String expectedVal = stateSvc.expandVar(entry.getValue());
            String actualVal = issueDetails.get(entry.getKey());
            if (!expectedVal.equals(actualVal)) {
                LOGGER.error("Issue Market level identifiers verification failed, Field [{}] Expected Value [{}], but Actual Value [{}]", entry.getKey(), expectedVal, actualVal);
                throw new CartException(CartExceptionType.VERIFICATION_FAILED, "Issue Market level identifiers verification failed, Field [{}] Expected Value [{}], but Actual Value [{}]", entry.getKey(), expectedVal, actualVal);
            }
        }
    }

    public void iAddInstrumentDetailsForIssue(Map<String, String> map) {
        issuePage.navigateToIssueScreen()
                .invokeSetup()
                .fillInstrumentDetails(map, false);
    }

    public void iAddInstLevelIdentiForIssue(Map<String, String> map) {
        issuePage.fillInstLevelIdentifier(map);
    }

    public void iAddMarketLevelIdentifiersForIssue(Map<String, String> map) {
        issuePage.clickMarketLevelIdentifier("Market Level Identifiers")
                .fillMarketLevelIdentifiersUnderListing(map);
    }

    public void iAddDescriptionDetailsForIssue(Map<String, String> map) {
        dmpGsPortalUtl.selectGSTab(DESCRIPTION_TAB);
        issuePage.fillDescription(map, false);
    }

    public void iUpdateDescriptionDetailsForIssue(Map<String, String> map) {
        dmpGsPortalUtl.selectGSTab(DESCRIPTION_TAB);
        issuePage.fillDescription(map, true);
    }

    public void iAddInstClassificationForIssue(Map<String, String> map) {
        issuePage.invokeAddNewDetails(INST_CLASSIFICATION_TAB);
        issuePage.fillInstClassification(map);
    }

    public void iAddInstitutionRoleForIssue(Map<String, String> map) {
        issuePage.invokeAddNewDetails(INSTITUTION_ROLE_TAB);
        issuePage.fillInstitutionRole(map);
    }

    public void iAddMarketListingForIssue(Map<String, String> map) {
        issuePage.invokeAddNewDetails(MARKET_LISTING_TAB);
        issuePage.fillMarketListing(map);
    }

    public void iAddCapitalizationForIssue(Map<String, String> Map) {
        issuePage.invokeAddNewDetails(CAPITALIZATION_TAB);
        issuePage.fillCapitalization(Map);
    }

    public void iAddExtendedIdentifierForIssue(Map<String, String> map) {
        issuePage.invokeAddNewDetails(EXTENDED_IDENTIFIER_TAB);
        issuePage.fillExtendedIdentifiers(map);
    }

    public void iAddRelatedInstForIssue(Map<String, String> map) {
        issuePage.invokeAddNewDetails(RELATED_INST_TAB);
        issuePage.fillRelatedInstrument(map);
    }

    public void iAddIssueCommentsForIssue(Map<String, String> map) {
        issuePage.invokeAddNewDetails(ISSUE_COMMENTS_TAB);
        issuePage.fillIssueComments(map);
    }

    public void iAddInstRatingForIssue(Map<String, String> map) {
        issuePage.invokeAddNewDetails(INSTRUMENT_RATING_TAB);
        issuePage.fillInstrumentRatings(map);
    }

    public void iExpectIssueDescriptionDetailsUpdated(Map<String, String> map) {
        dmpGsPortalUtl.selectGSTab(DESCRIPTION_TAB);
        Map<String, String> issueDetails = issuePage.getIssueDescriptionDetails();
        for (Map.Entry<String, String> entry : map.entrySet()) {
            String expectedVal = stateSvc.expandVar(entry.getValue());
            String actualVal = issueDetails.get(entry.getKey());
            if (!expectedVal.equals(actualVal)) {
                LOGGER.error("Issue Description details verification failed, Field [{}] Expected Value [{}], but Actual Value [{}]", entry.getKey(), expectedVal, actualVal);
                throw new CartException(CartExceptionType.VERIFICATION_FAILED, "Issue Description details verification failed, Field [{}] Expected Value [{}], but Actual Value [{}]", entry.getKey(), expectedVal, actualVal);
            }
        }
    }

    public void iExpectClassificationDetailsUpdated(Map<String, String> map) {
        dmpGsPortalUtl.selectGSTab(CLASSIFICATION_TAB);
        Map<String, String> issueDetails = issuePage.getClassificationDetails();
        for (Map.Entry<String, String> entry : map.entrySet()) {
            String expectedVal = stateSvc.expandVar(entry.getValue());
            String actualVal = issueDetails.get(entry.getKey());
            if (!expectedVal.equals(actualVal)) {
                LOGGER.error("Issue Classification details verification failed, Field [{}] Expected Value [{}], but Actual Value [{}]", entry.getKey(), expectedVal, actualVal);
                throw new CartException(CartExceptionType.VERIFICATION_FAILED, "Issue Classification details verification failed, Field [{}] Expected Value [{}], but Actual Value [{}]", entry.getKey(), expectedVal, actualVal);
            }
        }
    }

    public void iAddClassificationForIssue(Map<String, String> map) {
        dmpGsPortalUtl.selectGSTab(CLASSIFICATION_TAB);
        issuePage.fillClassification(map);
    }

    public void iAddMarketFeaturesForIssue(Map<String, String> map) {
        issuePage.fillMarketFeaturesUnderListing(map);
    }

    public void iExpectMarketFeaturesForIssueUpdated(Map<String, String> map) {
        Map<String, String> issueDetails = issuePage.getMarketFeaturesUnderListing();
        for (Map.Entry<String, String> entry : map.entrySet()) {
            String expectedVal = stateSvc.expandVar(entry.getValue());
            String actualVal = issueDetails.get(entry.getKey());
            if (!expectedVal.equals(actualVal)) {
                LOGGER.error("Market Features under Market Listing verification failed, Field [{}] Expected Value [{}], but Actual Value [{}]", entry.getKey(), expectedVal, actualVal);
                throw new CartException(CartExceptionType.VERIFICATION_FAILED, "Market Features under Market Listing verification failed, Field [{}] Expected Value [{}], but Actual Value [{}]", entry.getKey(), expectedVal, actualVal);
            }
        }
    }

    public void iAddFundappsIssueAttributes(Map<String, String> map) {
        issuePage.fillFundappsIssueAttributes(map);
    }

    public void iExpectFundappsIssueAttributesUpdated(Map<String, String> map) {
        Map<String, String> issueDetails = issuePage.getFundappsIssueAttributes();
        for (Map.Entry<String, String> entry : map.entrySet()) {
            String expectedVal = stateSvc.expandVar(entry.getValue());
            String actualVal = issueDetails.get(entry.getKey());
            if (!expectedVal.equals(actualVal)) {
                LOGGER.error("Fundapps Issue Attributes details verification failed, Field [{}] Expected Value [{}], but Actual Value [{}]", entry.getKey(), expectedVal, actualVal);
                throw new CartException(CartExceptionType.VERIFICATION_FAILED, "Fundapps Issue Attributes details verification failed, Field [{}] Expected Value [{}], but Actual Value [{}]", entry.getKey(), expectedVal, actualVal);
            }
        }
    }

    public void iAddFundappsMICList(Map<String, String> map) {
        issuePage.fillFundappsMICList(map);
    }

    public void iExpectFundappsMICListUpdated(Map<String, String> map) {
        Map<String, String> issueDetails = issuePage.getFundappsMICList();
        for (Map.Entry<String, String> entry : map.entrySet()) {
            String expectedVal = stateSvc.expandVar(entry.getValue());
            String actualVal = issueDetails.get(entry.getKey());
            if (!expectedVal.equals(actualVal)) {
                LOGGER.error("Fundapps MIC List details verification failed, Field [{}] Expected Value [{}], but Actual Value [{}]", entry.getKey(), expectedVal, actualVal);
                throw new CartException(CartExceptionType.VERIFICATION_FAILED, "Fundapps MIC LIst details verification failed, Field [{}] Expected Value [{}], but Actual Value [{}]", entry.getKey(), expectedVal, actualVal);
            }
        }
    }
}
