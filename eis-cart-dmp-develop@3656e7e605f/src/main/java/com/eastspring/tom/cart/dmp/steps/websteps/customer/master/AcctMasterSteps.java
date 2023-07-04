package com.eastspring.tom.cart.dmp.steps.websteps.customer.master;

import com.eastspring.tom.cart.core.CartException;
import com.eastspring.tom.cart.core.CartExceptionType;
import com.eastspring.tom.cart.core.svc.StateSvc;
import com.eastspring.tom.cart.dmp.pages.customer.master.AccountMasterPage;
import com.eastspring.tom.cart.dmp.steps.DmpGsPortalSteps;
import com.eastspring.tom.cart.dmp.utl.DmpGsPortalUtl;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;

import java.util.Map;
import java.util.Set;

import static com.eastspring.tom.cart.constant.CommonLocators.VARIABLE;
import static com.eastspring.tom.cart.dmp.mdl.GSUIFields.AM_PORTFOLIO_NAME;

public class AcctMasterSteps {

    private static final Logger LOGGER = LoggerFactory.getLogger(AcctMasterSteps.class);

    @Autowired
    private AccountMasterPage accountMasterPage;

    @Autowired
    private DmpGsPortalSteps portalSteps;

    @Autowired
    private StateSvc stateSvc;

    @Autowired
    private DmpGsPortalUtl dmpGsPortalUtl;

    public void iCreateAccountMaster(Map<String, String> map) {

        final String portfolioName = map.get(AM_PORTFOLIO_NAME);
        accountMasterPage.initializePortfolioData(map);

        if (portfolioName.contains(VARIABLE)) {
            accountMasterPage.invokeAccountMaster();
        } else {
            accountMasterPage.invokeAccountMaster(map.get(AM_PORTFOLIO_NAME));
        }

        accountMasterPage.fillPortfolioDetails(map)
                .fillPortfolioManagerDetails(map)
                .fillFundDetails(map)
                .fillIdentifiersTabDetails(map)
                .fillLegalIdentifiersTabDetails(map)
                .fillLBUIdentifiersTabDetails(map)
                .fillXReferenceIdentifiersTabDetails(map)
                .fillPartiesDetails(map)
                .fillRegulatoryDetails(map);

    }


    public void iCreateAccountMasterParties(Map<String, String> map) {

        accountMasterPage
                .fillPartiesDetails(map);
    }

    public void iCreateAccountMasterSsdr(Map<String, String> map) {

        accountMasterPage
                .fillSSDRDetails(map);
    }

    public void iCreateAccountMasterDOPCashFlowTolerance(Map<String, String> map) {

        accountMasterPage
                .fillDOPCashFlowTolerance(map);
    }

    public void iCreateAccountMasterBenchmarkdetails(Map<String, String> map) {

        accountMasterPage
                .fillBenchMarkDetails(map);
    }


    public void iCreateAccountMasterDOPDriftedBenchmarkdetails(Map<String, String> map) {

        accountMasterPage
                .fillDriftedBenchmarkDetails(map);
    }

    public void iUpdateAccountMaster(String accountMasterSection, final Map<String, String> map) {
        switch (accountMasterSection) {
            case "portfolioDetails":
                accountMasterPage.fillPortfolioDetails(map);
                break;
            case "portfolioManager":
                accountMasterPage.fillPortfolioManagerDetails(map);
                break;
            case "fundDetails":
                accountMasterPage.fillFundDetails(map);
                break;
            case "identifiersTab":
                accountMasterPage.fillIdentifiersTabDetails(map);
                break;
            case "legalIdentifiersTab":
                accountMasterPage.fillLegalIdentifiersTabDetails(map);
                break;
            case "lbuIdentifiersTab":
                accountMasterPage.fillLBUIdentifiersTabDetails(map);
                break;
            case "xReferenceIdentifiers":
                accountMasterPage.fillXReferenceIdentifiersTabDetails(map);
                break;
            case "partiesDetails":
                accountMasterPage.fillPartiesDetails(map);
                break;
            case "ssdrDetails":
                accountMasterPage.fillSSDRDetails(map);
                break;
            case "regulatoryDetails":
                accountMasterPage.fillRegulatoryDetails(map);
                break;
            case "benchMarkDetails":
                accountMasterPage.fillBenchMarkDetails(map);
                break;
            case "driftedBenchmarkDetails":
                accountMasterPage.fillDriftedBenchmarkDetails(map);
                break;
            case "dopCashFlowTolerance":
                accountMasterPage.fillDOPCashFlowTolerance(map);
                break;
            default:
                LOGGER.error("Unsupported action [{}] in Account Master Page", accountMasterSection);
                throw new CartException(CartExceptionType.UNSUPPORTED_ENCODING, "Unsupported action [{}] in Account Master Page", accountMasterSection);
        }
    }


    public void iExpectAccountMasterUpdatedForGivenPortfolio(final Map<String, String> map) {
        Map<String, String> portfolioDetails = accountMasterPage.getAccountMasterDetails();

        Set<String> fields = map.keySet();
        for (String field : fields) {
            String expectedVal = stateSvc.expandVar(map.get(field));
            String actualVal = portfolioDetails.get(field);
            if (!expectedVal.equals(actualVal)) {
                LOGGER.error("Account Master verification failed, Field [{}] Expected Value [{}], but Actual Value [{}]", field, expectedVal, actualVal);
                throw new CartException(CartExceptionType.VERIFICATION_FAILED, "Account Master verification failed, Field [{}] Expected Value [{}], but Actual Value [{}]", field, expectedVal, actualVal);
            }
        }
    }

    public void iExpectAccountMasterIsCreated(final String portfolioName) {
        if (!accountMasterPage.isAccountMasterPresent(portfolioName)) {
            LOGGER.error("Verification failed, Account Master [{}] is not created", portfolioName);
            throw new CartException(CartExceptionType.VERIFICATION_FAILED, "Verification failed, Account Master [{}] is not created", portfolioName);
        }
    }


    public void iAddPortfolioDetailsForAccountMaster(Map<String, String> map) {

        final String portfolioName = map.get(AM_PORTFOLIO_NAME);

        if (portfolioName.contains(VARIABLE)) {
            accountMasterPage.invokeAccountMaster();
        } else {
            accountMasterPage.invokeAccountMaster(map.get(AM_PORTFOLIO_NAME));
        }
        accountMasterPage
                .fillPortfolioDetails(map);
    }

    public void iAddPMDetailsForAccountMaster(Map<String, String> map) {
        accountMasterPage.fillPortfolioManagerDetails(map);
    }

    public void iAddFundDetailsForAccountMaster(Map<String, String> map) {
        accountMasterPage.fillFundDetails(map);
    }

    public void iAddIdentifiersForAccountMaster(Map<String, String> map) {
        accountMasterPage.fillIdentifiersTabDetails(map);
    }

    public void iAddLegalIdentifiersForAccountMaster(Map<String, String> map) {
        accountMasterPage.fillLegalIdentifiersTabDetails(map);
    }

    public void iAddLBUIdentifiersForAccountMaster(Map<String, String> map) {
        accountMasterPage.fillLBUIdentifiersTabDetails(map);
    }

    public void iAddXReferenceForAccountMaster(Map<String, String> map) {
        accountMasterPage.fillXReferenceIdentifiersTabDetails(map);
    }

    public void iAddPartiesForAccountMaster(Map<String, String> map) {
        accountMasterPage.fillPartiesDetails(map);
    }

    public void iAddRegulatoryForAccountMaster(Map<String, String> map) {
        accountMasterPage.fillRegulatoryDetails(map);
    }

    public void iSelctTabUnderAccountMaster(String tabName) {
        String expandedTabName = stateSvc.expandVar(tabName);
        dmpGsPortalUtl.selectGSTab(expandedTabName);
    }
}
