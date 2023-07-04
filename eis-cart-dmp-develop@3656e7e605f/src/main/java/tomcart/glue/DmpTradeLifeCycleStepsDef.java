package tomcart.glue;

import com.eastspring.tom.cart.constant.FileType;
import com.eastspring.tom.cart.constant.MapConstants;
import com.eastspring.tom.cart.constant.Source;
import com.eastspring.tom.cart.core.CartBootstrap;
import com.eastspring.tom.cart.core.utl.DataTableUtil;
import com.eastspring.tom.cart.dmp.steps.DmpTradeLifeCycleSteps;
import cucumber.api.java8.En;
import io.cucumber.datatable.DataTable;

import java.util.HashMap;
import java.util.Map;

public class DmpTradeLifeCycleStepsDef implements En {

    private DmpTradeLifeCycleSteps steps = (DmpTradeLifeCycleSteps) CartBootstrap.getBean(DmpTradeLifeCycleSteps.class);
    private DataTableUtil dataTableUtil = (DataTableUtil) CartBootstrap.getBean(DataTableUtil.class);
    private static Map<String, String> defaultsMap = new HashMap<>();

    public DmpTradeLifeCycleStepsDef() {

        When("I place {string} trade with below trade economics", (final String assetType, final DataTable tradeEconomics) -> {
            Map<String, String> twoColumnAsMap = dataTableUtil.getTwoColumnAsMap(tradeEconomics);
            Map<String, String> tradeParamsMap = steps.updateTradeParamsMapWithActualDates(twoColumnAsMap);
            tradeParamsMap.put(MapConstants.ASSET_TYPE, assetType);
            steps.placeTrade(tradeParamsMap);
        });

        Then("I expect the transaction xml is generated with expected trade economics", () -> {
            steps.validateTransactionXml();
        });

        Given("I place {string} order for:", (String category, DataTable defaultsTable) -> {
            Map<String, String> temp = (defaultsTable.transpose().asMap(String.class, String.class));
            defaultsMap.put(MapConstants.ASSET_TYPE, category);
            defaultsMap.putAll(temp);
        });

        Given("I generate trade nuggets for below trade params:", (DataTable tradeTable) -> {
            Map<String, String> twoColumnAsMap = dataTableUtil.getTwoColumnAsMap(tradeTable);
            Map<String, String> tradeParamsMap = steps.updateTradeParamsMapWithActualDates(twoColumnAsMap);

            //Merging both Maps set by user
            tradeParamsMap.putAll(defaultsMap);

            steps.generateTradeNuggets(tradeParamsMap);
        });

        When("I initiate trade life cycle workflow", () -> {
            // Kick start BRS BrsTrade Nuggets File Transfer Job
            steps.initiateTLCFileTransferJob(Source.BRS);
            // Read trade ack file from transaction.xml based on BrsTrade Nugget File
            steps.generateTradeAckXml();
            // Kick start BNP BrsTrade Ack File Transfer Job
            steps.initiateTLCFileTransferJob(Source.BNP);
        });

        Then("I expect trade nuggets are successfully archived", () -> steps.iExpectFileIsSuccessfullyArchived(FileType.TRADE_NUGGETS));

        Then("I expect trade nuggets entry is made in DMP", () -> steps.iExpectDMPRecordIsCreatedForFileProcessing(FileType.TRADE_NUGGETS));

        Then("I expect trade ack status file is successfully archived", () -> steps.iExpectFileIsSuccessfullyArchived(FileType.TMS_ACK));

        Then("I expect trade ack status entry is made in DMP", () -> steps.iExpectDMPRecordIsCreatedForFileProcessing(FileType.TMS_ACK));

        Given("Date is ISO Format YYYY-MM-DD", () -> {
            //Handled in NextBizDay function
        });

        Given("An Increment is in the format T\\+x where x is a number of Business Days", () -> {
            //Handled in NextBizDay function
        });

        Given("A date (.*)", (String currDate) -> {
            steps.setCurrentDateVar(currDate);
        });

        When("I add {int} business days to given date", (Integer increment) -> {
            steps.setIncrementVar(increment);
        });

        Then("I expect next date as (.*)", (String nextBizDay) -> {
            steps.validateNextBizDay(nextBizDay);
        });
    }
}
