package tomcart.glue.webstepsdef.customer.master;

import com.eastspring.tom.cart.core.CartBootstrap;
import com.eastspring.tom.cart.core.utl.DataTableUtil;
import com.eastspring.tom.cart.dmp.steps.websteps.customer.master.AcctMasterShareclassSteps;
import cucumber.api.java8.En;
import io.cucumber.datatable.DataTable;
import java.util.Map;

public class ShareclassStepsDef implements En {

    private AcctMasterShareclassSteps steps = (AcctMasterShareclassSteps) CartBootstrap.getBean(AcctMasterShareclassSteps.class);
    private DataTableUtil dataTableUtil = (DataTableUtil) CartBootstrap.getBean(DataTableUtil.class);

    public ShareclassStepsDef() {

        When("I create shareclass with following details", (DataTable shareclassDetails) -> {
            final Map<String, String> dataMap = dataTableUtil.getTwoColumnAsMap(shareclassDetails);
            steps.iCreateShareclass(dataMap);
        });


        When("I update shareclass Identifiers in shareclass with following details", (DataTable shareclassIdentifiers) -> {
            final Map<String, String> dataMap = dataTableUtil.getTwoColumnAsMap(shareclassIdentifiers);
            steps.iUpdateShareclass("shareclassIdentifiers",dataMap);
        });

        When("I update shareclass Details in shareclass with following details", (DataTable shareclassDetails) -> {
            final Map<String, String> dataMap = dataTableUtil.getTwoColumnAsMap(shareclassDetails);
            steps.iUpdateShareclass("shareclassDetails",dataMap);
        });

        When("I update shareclass XReference Details in shareclass with following details", (DataTable shareclassXReference) -> {
            final Map<String, String> dataMap = dataTableUtil.getTwoColumnAsMap(shareclassXReference);
            steps.iUpdateShareclass("shareclassXreference",dataMap);
        });

        When("I update shareclass Benchmark Details in shareclass with following details", (DataTable shareclassBMDetails) -> {
            final Map<String, String> dataMap = dataTableUtil.getTwoColumnAsMap(shareclassBMDetails);
            steps.iUpdateShareclass("shareclassBenchmarks",dataMap);
        });

        Then("I expect the shareclass is updated as below", (DataTable shareclassDetails) -> {
            Map<String, String> dataMap = dataTableUtil.getTwoColumnAsMap(shareclassDetails);
            steps.iExpectShareclassUpdatedForGivenShareclass(dataMap);
        });

    }
}
