package tomcart.glue.webstepsdef.generic.setup;

import com.eastspring.tom.cart.core.CartBootstrap;
import com.eastspring.tom.cart.core.utl.DataTableUtil;
import com.eastspring.tom.cart.dmp.steps.websteps.generic.setup.CentralCrossRefGrpSteps;
import cucumber.api.java8.En;
import io.cucumber.datatable.DataTable;

import java.util.LinkedHashMap;

public class CentralCrossRefGrpStepsDef implements En {

    private DataTableUtil dataTableUtil = (DataTableUtil) CartBootstrap.getBean(DataTableUtil.class);
    private CentralCrossRefGrpSteps steps = (CentralCrossRefGrpSteps) CartBootstrap.getBean(CentralCrossRefGrpSteps.class);

    public CentralCrossRefGrpStepsDef() {

        Then("I create a new Central Cross Reference Group with below details", (DataTable dataTable) -> {
            LinkedHashMap<String, String> dataMap = new LinkedHashMap<>(dataTableUtil.getTwoColumnAsMap(dataTable));
            steps.iCreateCentralCrossRefGroup(dataMap);
        });

        Then("I create a new Central Cross Reference Group along with a new Participant Details", (DataTable dataTable) -> {
            LinkedHashMap<String, String> dataMap = new LinkedHashMap<>(dataTableUtil.getTwoColumnAsMap(dataTable));
            steps.iCreateCentralCrossRefGroupAndParticipantDetails(dataMap);
        });

        Then("I add Participant Details to the Central Cross Reference Group", (DataTable dataTable) -> {
            LinkedHashMap<String, String> dataMap = new LinkedHashMap<>(dataTableUtil.getTwoColumnAsMap(dataTable));
            steps.iAddParticipantDetails(dataMap);
        });

        Then("I add Participant Details to the Central Cross Reference Group {string}", (String grpName, DataTable dataTable) -> {
            LinkedHashMap<String, String> dataMap = new LinkedHashMap<>(dataTableUtil.getTwoColumnAsMap(dataTable));
            steps.iAddParticipantDetailsToGivenGroup(grpName, dataMap);
        });

        When("I update Central Cross Reference Group {string} with below details", (String grpName, DataTable dataTable) -> {
            LinkedHashMap<String, String> dataMap = new LinkedHashMap<>(dataTableUtil.getTwoColumnAsMap(dataTable));
            steps.iUpdateCrossRefGroupDetails(grpName, dataMap);
        });

        Then("I expect Central Cross Reference Group {string} is created", (String grpName) -> steps.iExpectCentralCrossRefGroupCreated(grpName));


        Then("I expect Central Cross Reference Group {string} is updated as below", (String grpName, DataTable dataTable) -> {
            LinkedHashMap<String, String> dataMap = new LinkedHashMap<>(dataTableUtil.getTwoColumnAsMap(dataTable));
            steps.iExpectCrossRefGroupIsUpdated(grpName, dataMap);
        });

        Then("I expect Central Cross Reference Group {string} Participant details are updated as below", (String grpName, DataTable dataTable) -> {
            LinkedHashMap<String, String> dataMap = new LinkedHashMap<>(dataTableUtil.getTwoColumnAsMap(dataTable));
            steps.iExpectCrossRefGroupParticipantIsUpdated(grpName, dataMap);
        });

    }


}
