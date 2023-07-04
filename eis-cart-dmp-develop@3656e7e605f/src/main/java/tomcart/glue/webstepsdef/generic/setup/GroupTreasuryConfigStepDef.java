package tomcart.glue.webstepsdef.generic.setup;

import com.eastspring.tom.cart.core.CartBootstrap;
import com.eastspring.tom.cart.core.utl.DataTableUtil;
import com.eastspring.tom.cart.dmp.steps.websteps.generic.setup.GroupTreasuryConfigSteps;
import cucumber.api.java8.En;
import io.cucumber.datatable.DataTable;

import java.util.Map;

public class GroupTreasuryConfigStepDef implements En {
    private GroupTreasuryConfigSteps steps = (GroupTreasuryConfigSteps) CartBootstrap.getBean(GroupTreasuryConfigSteps.class);
    private DataTableUtil dataTableUtil = (DataTableUtil) CartBootstrap.getBean(DataTableUtil.class);

    public GroupTreasuryConfigStepDef() {

        When("I add below Group treasury configuration details", (DataTable gtcDetails) -> {
            final Map<String, String> dataMap = dataTableUtil.getTwoColumnAsMap(gtcDetails);
            steps.iAddGroupTreasuryConfigDetails(dataMap);
        });

        When("I open group treasury Account {string}", (String counterPartyId) -> {
            steps.iOpenGroupTreasuryConfig(counterPartyId);
        });

        When("I update below group treasury configuration details", (DataTable acTable) -> {
            Map<String, String> dataMap = dataTableUtil.getTwoColumnAsMap(acTable);
            steps.iUpdatedGroupTreasuryConfigDetails(dataMap);
        });

    }
}
