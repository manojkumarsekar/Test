package tomcart.glue.webstepsdef.security.master;

import com.eastspring.tom.cart.core.CartBootstrap;
import com.eastspring.tom.cart.core.utl.DataTableUtil;
import com.eastspring.tom.cart.dmp.steps.websteps.security.master.MktGrpDetailSteps;
import cucumber.api.java8.En;
import io.cucumber.datatable.DataTable;

import java.util.LinkedHashMap;

public class MarketGrpDtlStepsDef implements En {

    private MktGrpDetailSteps steps = (MktGrpDetailSteps) CartBootstrap.getBean(MktGrpDetailSteps.class);
    private DataTableUtil dataTableUtil = (DataTableUtil) CartBootstrap.getBean(DataTableUtil.class);

    public MarketGrpDtlStepsDef() {

        Then("I add Market Details for the MarketGroup as below", (DataTable dataTable) -> {
            LinkedHashMap<String, String> dataMap = new LinkedHashMap<>(dataTableUtil.getTwoColumnAsMap(dataTable));
            steps.iCreateMarketGroup(dataMap);
        });

        Then("I add Market Group Participant for the MarketGroup as below", (DataTable dataTable) -> {
            LinkedHashMap<String, String> dataMap = new LinkedHashMap<>(dataTableUtil.getTwoColumnAsMap(dataTable));
            steps.iAddParticipantDetails(dataMap);
        });

        When("I update Market Group {string} with below details", (String accountGrpId, DataTable dataTable) -> {
            LinkedHashMap<String, String> dataMap = new LinkedHashMap<>(dataTableUtil.getTwoColumnAsMap(dataTable));
            steps.iUpdateMarketGroup(accountGrpId, dataMap);
        });

        Then("I expect Market Group {string} is created", (String accountGrpId) -> steps.iExpectMarketGroupIsCreated(accountGrpId));


        Then("I expect Market Group {string} is updated as below", (String accountGrpId, DataTable dataTable) -> {
            LinkedHashMap<String, String> dataMap = new LinkedHashMap<>(dataTableUtil.getTwoColumnAsMap(dataTable));
            steps.iExpectMarketGroupIsUpdated(accountGrpId, dataMap);
        });


    }
}
