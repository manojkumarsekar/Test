package tomcart.glue.webstepsdef.customer.master;

import com.eastspring.tom.cart.core.CartBootstrap;
import com.eastspring.tom.cart.core.utl.DataTableUtil;
import com.eastspring.tom.cart.dmp.steps.websteps.customer.master.AcctMasterSteps;
import cucumber.api.java8.En;
import io.cucumber.datatable.DataTable;

import java.util.Map;

public class AcctMasterStepsDef implements En {

    private AcctMasterSteps steps = (AcctMasterSteps) CartBootstrap.getBean(AcctMasterSteps.class);
    private DataTableUtil dataTableUtil = (DataTableUtil) CartBootstrap.getBean(DataTableUtil.class);

    public AcctMasterStepsDef() {

        //region INDIVIDUAL BLOCK FILLS
        When("I add Portfolio Details for the Account Master as below", (DataTable acTable) -> {
            Map<String, String> dataMap = dataTableUtil.getTwoColumnAsMap(acTable);
            steps.iAddPortfolioDetailsForAccountMaster(dataMap);
        });

        When("I add Portfolio Managers details for the Account Master as below", (DataTable acTable) -> {
            Map<String, String> dataMap = dataTableUtil.getTwoColumnAsMap(acTable);
            steps.iAddPMDetailsForAccountMaster(dataMap);
        });

        When("I add Fund Details for the Account Master as below", (DataTable acTable) -> {
            Map<String, String> dataMap = dataTableUtil.getTwoColumnAsMap(acTable);
            steps.iAddFundDetailsForAccountMaster(dataMap);
        });

        When("I add Identifiers details for the Account Master as below", (DataTable acTable) -> {
            Map<String, String> dataMap = dataTableUtil.getTwoColumnAsMap(acTable);
            steps.iAddIdentifiersForAccountMaster(dataMap);
        });

        When("I add Legacy Identifiers details for the Account Master as below", (DataTable acTable) -> {
            Map<String, String> dataMap = dataTableUtil.getTwoColumnAsMap(acTable);
            steps.iAddLegalIdentifiersForAccountMaster(dataMap);
        });

        When("I add LBU Identifiers details for the Account Master as below", (DataTable acTable) -> {
            Map<String, String> dataMap = dataTableUtil.getTwoColumnAsMap(acTable);
            steps.iAddLBUIdentifiersForAccountMaster(dataMap);
        });

        When("I add XReference details for the Account Master as below", (DataTable acTable) -> {
            Map<String, String> dataMap = dataTableUtil.getTwoColumnAsMap(acTable);
            steps.iAddXReferenceForAccountMaster(dataMap);
        });

        When("I add Parties details for the Account Master as below", (DataTable acTable) -> {
            Map<String, String> dataMap = dataTableUtil.getTwoColumnAsMap(acTable);
            steps.iAddPartiesForAccountMaster(dataMap);
        });

        When("I add Regulatory for the Account Master as below", (DataTable acTable) -> {
            Map<String, String> dataMap = dataTableUtil.getTwoColumnAsMap(acTable);
            steps.iAddRegulatoryForAccountMaster(dataMap);
        });
        //endregion

        //Can handle all the blocks
        When("I create account master with following details", (DataTable acmDetails) -> {
            final Map<String, String> dataMap = dataTableUtil.getTwoColumnAsMap(acmDetails);
            steps.iCreateAccountMaster(dataMap);
        });


        Then("I select {string} tab under Account Master screen", (String tabName) -> {
            steps.iSelctTabUnderAccountMaster(tabName);
        });


        When("I add the parties details in account master with following details", (DataTable partydetails) -> {
            final Map<String, String> dataMap = dataTableUtil.getTwoColumnAsMap(partydetails);
            steps.iCreateAccountMasterParties(dataMap);
        });

        When("I add the ssdr details in account master with following details", (DataTable ssdrdetails) -> {
            final Map<String, String> dataMap = dataTableUtil.getTwoColumnAsMap(ssdrdetails);
            steps.iCreateAccountMasterSsdr(dataMap);
        });

        When("I update portfolio details in account master with following details", (DataTable ssdrdetails) -> {
            final Map<String, String> dataMap = dataTableUtil.getTwoColumnAsMap(ssdrdetails);
            steps.iUpdateAccountMaster("portfolioDetails",dataMap);
        });

        When("I add the DOPCashflowdetails in account master with following details", (DataTable dopCashFlow) -> {
            final Map<String, String> dataMap = dataTableUtil.getTwoColumnAsMap(dopCashFlow);
            steps.iCreateAccountMasterDOPCashFlowTolerance(dataMap);
        });

        Then("I update Fund Details in account Master as below", (DataTable acTable) -> {
            Map<String, String> dataMap = dataTableUtil.getTwoColumnAsMap(acTable);
            steps.iUpdateAccountMaster("fundDetails",dataMap);
        });

        Then("I update parties in account master details for portfolio with below details", (DataTable accountMastepartiesdetailss) -> {
            final Map<String, String> dataMap = dataTableUtil.getTwoColumnAsMap(accountMastepartiesdetailss);
            steps.iUpdateAccountMaster("partiesDetails",dataMap);
        });

        When("I update ssdr in account master with below details", (DataTable upssdr) -> {
            final Map<String, String> dataMap = dataTableUtil.getTwoColumnAsMap(upssdr);
            steps.iUpdateAccountMaster("ssdrDetails",dataMap);
        });

        When("I update LBU in account master with below details", (DataTable lbuDetails) -> {
            final Map<String, String> dataMap = dataTableUtil.getTwoColumnAsMap(lbuDetails);
            steps.iUpdateAccountMaster("lbuIdentifiersTab",dataMap);
        });

        And("I update DOPCashflowdetails in account master with below details", (DataTable dopCashFlow) -> {
            final Map<String, String> dataMap = dataTableUtil.getTwoColumnAsMap(dopCashFlow);
            steps.iUpdateAccountMaster("dopCashFlowTolerance",dataMap);
        });

        And("I update XReferenceIdentifiers in account master with below details", (DataTable xReference) -> {
            final Map<String, String> dataMap = dataTableUtil.getTwoColumnAsMap(xReference);
            steps.iUpdateAccountMaster("xReferenceIdentifiers",dataMap);
        });

        And("I update Benchmark in account master with below details", (DataTable benchMarkdetails) -> {
            final Map<String, String> dataMap = dataTableUtil.getTwoColumnAsMap(benchMarkdetails);
            steps.iUpdateAccountMaster("benchMarkDetails",dataMap);
        });

        When("I add the Benchmark details in account master with following details", (DataTable benchMarkdetails) -> {
            final Map<String, String> dataMap = dataTableUtil.getTwoColumnAsMap(benchMarkdetails);
            steps.iCreateAccountMasterBenchmarkdetails(dataMap);
        });

        Given("I open account master {string} for the given portfolio", (String portfolioName) -> {
            steps.iExpectAccountMasterIsCreated(portfolioName);
        });

        Then("I update DOPDriftedBenchmark in account master with below details", (DataTable dopBenchmark) -> {
            final Map<String, String> dataMap = dataTableUtil.getTwoColumnAsMap(dopBenchmark);
            steps.iUpdateAccountMaster("driftedBenchmarkDetails",dataMap);
        });

        When("I add the DOPDriftedBenchmark details in account master with following details", (DataTable dopBenchmark) -> {
            final Map<String, String> dataMap = dataTableUtil.getTwoColumnAsMap(dopBenchmark);
            steps.iCreateAccountMasterDOPDriftedBenchmarkdetails(dataMap);
        });

        Then("I expect Account Master {string} is created", (String portfolioName) -> {
            steps.iExpectAccountMasterIsCreated(portfolioName);
        });

        Then("I expect portfolio details in Account Master is updated as below", (DataTable accountMaster) -> {
            Map<String, String> dataMap = dataTableUtil.getTwoColumnAsMap(accountMaster);
            steps.iExpectAccountMasterUpdatedForGivenPortfolio(dataMap);
        });

        Then("I expect fund details in Account Master is updated as below", (DataTable accountMaster) -> {
            Map<String, String> dataMap = dataTableUtil.getTwoColumnAsMap(accountMaster);
            steps.iExpectAccountMasterUpdatedForGivenPortfolio(dataMap);
        });

        Then("I expect LBU details in Account Master is updated as below", (DataTable expssrd) -> {
            final Map<String, String> dataMap = dataTableUtil.getTwoColumnAsMap(expssrd);
            steps.iExpectAccountMasterUpdatedForGivenPortfolio(dataMap);
        });

        Then("I expect Xref details in Account Master is updated as below", (DataTable expssrd) -> {
            final Map<String, String> dataMap = dataTableUtil.getTwoColumnAsMap(expssrd);
            steps.iExpectAccountMasterUpdatedForGivenPortfolio(dataMap);
        });

        Then("I expect Benchmark details in Account Master is updated as below", (DataTable expssrd) -> {
            final Map<String, String> dataMap = dataTableUtil.getTwoColumnAsMap(expssrd);
            steps.iExpectAccountMasterUpdatedForGivenPortfolio(dataMap);
        });

        Then("I expect DOPBenchmark details in Account Master is updated as below", (DataTable expssrd) -> {
            final Map<String, String> dataMap = dataTableUtil.getTwoColumnAsMap(expssrd);
            steps.iExpectAccountMasterUpdatedForGivenPortfolio(dataMap);
        });

        Then("I expect DOPCashFlow details in Account Master is updated as below", (DataTable expssrd) -> {
            final Map<String, String> dataMap = dataTableUtil.getTwoColumnAsMap(expssrd);
            steps.iExpectAccountMasterUpdatedForGivenPortfolio(dataMap);
        });

        Then("I expect ssdr details in Account Master is updated as below", (DataTable expssrd) -> {
            final Map<String, String> dataMap = dataTableUtil.getTwoColumnAsMap(expssrd);
            steps.iExpectAccountMasterUpdatedForGivenPortfolio(dataMap);
        });

        Then("I expect parties details in Account Master is updated as below", (DataTable accountMaster) -> {
            final Map<String, String> dataMap = dataTableUtil.getTwoColumnAsMap(accountMaster);
            steps.iExpectAccountMasterUpdatedForGivenPortfolio(dataMap);
        });


    }
}
