package tomcart.glue.webstepsdef.customer.master;

import com.eastspring.tom.cart.core.CartBootstrap;
import com.eastspring.tom.cart.core.utl.DataTableUtil;
import com.eastspring.tom.cart.dmp.steps.websteps.customer.master.ExternalAccountSteps;
import cucumber.api.java8.En;
import io.cucumber.datatable.DataTable;

import java.util.Map;

public class ExternalAccountStepsDef implements En {

    private ExternalAccountSteps steps = (ExternalAccountSteps) CartBootstrap.getBean(ExternalAccountSteps.class);
    private DataTableUtil dataTableUtil = (DataTableUtil) CartBootstrap.getBean(DataTableUtil.class);

    public ExternalAccountStepsDef() {

        When("I enter below details for new External Account", (DataTable acTable) -> {
            Map<String, String> dataMap = dataTableUtil.getTwoColumnAsMap(acTable);
            steps.iAddExternalAccountDetails(dataMap);
        });

        When("I open External Account {string}", (String extAcctId) -> {
            steps.iOpenExternalAccount(extAcctId);
        });

        When("I update below external account details", (DataTable acTable) -> {
            Map<String, String> dataMap = dataTableUtil.getTwoColumnAsMap(acTable);
            steps.iUpdateExternalAccountDetails(dataMap);
        });

        Then("I expect below external account details updated", (DataTable acctDetails) -> {
            Map<String, String> dataMap = dataTableUtil.getTwoColumnAsMap(acctDetails);
            steps.iExpectExternalAccountDetailsUpdated(dataMap);
        });

    }
}
