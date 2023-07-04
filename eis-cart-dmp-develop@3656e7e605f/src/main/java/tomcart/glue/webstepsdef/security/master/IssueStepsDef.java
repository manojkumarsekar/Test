package tomcart.glue.webstepsdef.security.master;

import com.eastspring.tom.cart.core.CartBootstrap;
import com.eastspring.tom.cart.core.utl.DataTableUtil;
import com.eastspring.tom.cart.dmp.steps.websteps.security.master.IssueSteps;
import cucumber.api.java8.En;
import io.cucumber.datatable.DataTable;

import java.util.LinkedHashMap;
import java.util.Map;

public class IssueStepsDef implements En {

    private IssueSteps issueSteps = (IssueSteps) CartBootstrap.getBean(IssueSteps.class);
    private DataTableUtil dataTableUtil = (DataTableUtil) CartBootstrap.getBean(DataTableUtil.class);

    public IssueStepsDef() {


        When("I enter below Instrument Details for new Issue", (DataTable issueTable) -> {
            Map<String, String> dataMap = dataTableUtil.getTwoColumnAsMap(issueTable);
            issueSteps.iAddInstrumentDetailsForIssue(dataMap);
        });

        Then("I expect below instrument details updated for the Issue {string}", (String issueName, DataTable issteTable) -> {
            Map<String, String> dataMap = dataTableUtil.getTwoColumnAsMap(issteTable);
            issueSteps.iExpectIssueInstrumentDetailsUpdated(issueName, dataMap);
        });

        When("I (add|update) below Instrument Level Identifiers", (DataTable issueTable) -> {
            Map<String, String> dataMap = dataTableUtil.getTwoColumnAsMap(issueTable);
            issueSteps.iAddInstLevelIdentiForIssue(dataMap);
        });

        Then("I expect Issue {string} is created", (String issueName) ->
                issueSteps.iExpectIssueRecordCreated(issueName)
        );

        Then("I open existing Issue {string}", (String issueName) ->
                issueSteps.iOpenExistingIssue(issueName)
        );

        When("I update below instrument details", (DataTable issueDetails) -> {
            final Map<String, String> dataMap = dataTableUtil.getTwoColumnAsMap(issueDetails);
            issueSteps.iUpdateIssueInstrumentDetails(dataMap);
        });

        When("I (add|update) below Market level Identifiers under Market Listing", (DataTable issueTable) -> {
            Map<String, String> dataMap = dataTableUtil.getTwoColumnAsMap(issueTable);
            issueSteps.iAddMarketLevelIdentifiersForIssue(dataMap);
        });

        When("I (add|update) below Market Listing details", (DataTable issueTable) -> {
            Map<String, String> dataMap = dataTableUtil.getTwoColumnAsMap(issueTable);
            issueSteps.iAddMarketListingForIssue(dataMap);
        });

        When("I add below Instrument Classifications", (DataTable issueTable) -> {
            Map<String, String> dataMap = dataTableUtil.getTwoColumnAsMap(issueTable);
            issueSteps.iAddInstClassificationForIssue(dataMap);
        });

        When("I (add|update) below Institution Roles", (DataTable issueTable) -> {
            Map<String, String> dataMap = dataTableUtil.getTwoColumnAsMap(issueTable);
            issueSteps.iAddInstitutionRoleForIssue(dataMap);
        });

        When("I (add|update) below Capitalization details", (DataTable issueTable) -> {
            Map<String, String> dataMap = dataTableUtil.getTwoColumnAsMap(issueTable);
            issueSteps.iAddCapitalizationForIssue(dataMap);
        });

        When("I (add|update) below Extended Identifier", (DataTable issueTable) -> {
            Map<String, String> dataMap = dataTableUtil.getTwoColumnAsMap(issueTable);
            issueSteps.iAddExtendedIdentifierForIssue(dataMap);
        });

        When("I (add|update) below Related Instrument", (DataTable issueTable) -> {
            Map<String, String> dataMap = dataTableUtil.getTwoColumnAsMap(issueTable);
            issueSteps.iAddRelatedInstForIssue(dataMap);
        });

        When("I (add|update) below Issue Comments", (DataTable issueTable) -> {
            Map<String, String> dataMap = dataTableUtil.getTwoColumnAsMap(issueTable);
            issueSteps.iAddIssueCommentsForIssue(dataMap);
        });

        When("I (add|update) below Instrument Ratings", (DataTable issueTable) -> {
            Map<String, String> dataMap = dataTableUtil.getTwoColumnAsMap(issueTable);
            issueSteps.iAddInstRatingForIssue(dataMap);
        });

        Then("I expect below Market level Identifiers (added|updated) for the Issue {string}", (String issueName, DataTable issteTable) -> {
            Map<String, String> dataMap = dataTableUtil.getTwoColumnAsMap(issteTable);
            issueSteps.iExpectIssueMarketLevelIdentifiersDetailsUpdated(issueName, dataMap);
        });


        When("I add below issue description details", (DataTable issueDetails) -> {
            final Map<String, String> dataMap = dataTableUtil.getTwoColumnAsMap(issueDetails);
            issueSteps.iAddDescriptionDetailsForIssue(dataMap);
        });

        When("I update below issue description details", (DataTable issueDetails) -> {
            final Map<String, String> dataMap = dataTableUtil.getTwoColumnAsMap(issueDetails);
            issueSteps.iUpdateDescriptionDetailsForIssue(dataMap);
        });

        Then("I expect below issue description details (added|updated)", (DataTable descDetails) -> {
            Map<String, String> dataMap = dataTableUtil.getTwoColumnAsMap(descDetails);
            issueSteps.iExpectIssueDescriptionDetailsUpdated(dataMap);
        });

        Then("I expect below Classification details (added|updated)", (DataTable classfcnDetails) -> {
            Map<String, String> dataMap = dataTableUtil.getTwoColumnAsMap(classfcnDetails);
            issueSteps.iExpectClassificationDetailsUpdated(dataMap);
        });

        When("I (add|update) below Classification", (DataTable issueTable) -> {
            Map<String, String> dataMap = dataTableUtil.getTwoColumnAsMap(issueTable);
            issueSteps.iAddClassificationForIssue(dataMap);
        });

        When("I (add|update) below Market Features under Market Listing", (DataTable issueTable) -> {
            Map<String, String> dataMap = dataTableUtil.getTwoColumnAsMap(issueTable);
            issueSteps.iAddMarketFeaturesForIssue(dataMap);
        });
        Then("I expect below Market Features under Market Listing (added|updated)", (DataTable classfcnDetails) -> {
            Map<String, String> dataMap = dataTableUtil.getTwoColumnAsMap(classfcnDetails);
            issueSteps.iExpectMarketFeaturesForIssueUpdated(dataMap);
        });

        When("I (add|update) below Fundapps Issue Attributes", (DataTable issueTable) -> {
            Map<String, String> dataMap = dataTableUtil.getTwoColumnAsMap(issueTable);
            issueSteps.iAddFundappsIssueAttributes(dataMap);
        });

        Then("I expect below Fundapps Issue Attributes details (added|updated)", (DataTable issueDetails) -> {
            Map<String, String> dataMap = dataTableUtil.getTwoColumnAsMap(issueDetails);
            issueSteps.iExpectFundappsIssueAttributesUpdated(dataMap);
        });

        When("I (add|update) below Fundapps MIC List", (DataTable issueTable) -> {
            Map<String, String> dataMap = dataTableUtil.getTwoColumnAsMap(issueTable);
            issueSteps.iAddFundappsMICList(dataMap);
        });


        Then("I expect below Fundapps MIC List details (added|updated)", (DataTable issueDetails) -> {
            Map<String, String> dataMap = dataTableUtil.getTwoColumnAsMap(issueDetails);
            issueSteps.iExpectFundappsMICListUpdated(dataMap);
        });

    }
}
