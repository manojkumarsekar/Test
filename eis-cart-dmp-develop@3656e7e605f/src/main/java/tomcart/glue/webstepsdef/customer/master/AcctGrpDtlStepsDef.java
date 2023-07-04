package tomcart.glue.webstepsdef.customer.master;

import com.eastspring.tom.cart.core.CartBootstrap;
import com.eastspring.tom.cart.core.utl.DataTableUtil;
import com.eastspring.tom.cart.dmp.steps.websteps.customer.master.AcctGrpDetailSteps;
import cucumber.api.java8.En;
import io.cucumber.datatable.DataTable;

import java.util.LinkedHashMap;

public class AcctGrpDtlStepsDef implements En {

    private AcctGrpDetailSteps steps = (AcctGrpDetailSteps) CartBootstrap.getBean(AcctGrpDetailSteps.class);
    private DataTableUtil dataTableUtil = (DataTableUtil) CartBootstrap.getBean(DataTableUtil.class);

    public AcctGrpDtlStepsDef() {

        Then("I create a new Account Group with below details", (DataTable dataTable) -> {
            LinkedHashMap<String, String> dataMap = new LinkedHashMap<>(dataTableUtil.getTwoColumnAsMap(dataTable));
            steps.iCreateAccountGroup(dataMap);
        });

        Then("I create a new Account Group along with a new Participant Details", (DataTable dataTable) -> {
            LinkedHashMap<String, String> dataMap = new LinkedHashMap<>(dataTableUtil.getTwoColumnAsMap(dataTable));
            steps.iCreateAccountGroupAndParticipantDetails(dataMap);
        });

        Then("I add Participant Details to the Account Group", (DataTable dataTable) -> {
            LinkedHashMap<String, String> dataMap = new LinkedHashMap<>(dataTableUtil.getTwoColumnAsMap(dataTable));
            steps.iAddParticipantDetails(dataMap);
        });

        Then("I add Participant Details to the Account Group {string}", (String accountGrpId, DataTable dataTable) -> {
            LinkedHashMap<String, String> dataMap = new LinkedHashMap<>(dataTableUtil.getTwoColumnAsMap(dataTable));
            steps.iAddParticipantDetailsToGivenGroup(accountGrpId, dataMap);
        });

        When("I update Account Group {string} with below details", (String accountGrpId, DataTable dataTable) -> {
            LinkedHashMap<String, String> dataMap = new LinkedHashMap<>(dataTableUtil.getTwoColumnAsMap(dataTable));
            steps.iUpdateAccountGroup(accountGrpId, dataMap);
        });

        Then("I expect Account Group {string} is created", (String accountGrpId) -> steps.iExpectAccountGroupIsCreated(accountGrpId));

        Then("I expect Account Group {string} has below Participant Details", (String accountGrpId, DataTable dataTable) -> {
            LinkedHashMap<String, String> dataMap = new LinkedHashMap<>(dataTableUtil.getTwoColumnAsMap(dataTable));
            steps.iExpectParticipantDetailsAreAddedToGivenGroup(accountGrpId, dataMap);
        });

        Then("I expect Account Group {string} is updated as below", (String accountGrpId, DataTable dataTable) -> {
            LinkedHashMap<String, String> dataMap = new LinkedHashMap<>(dataTableUtil.getTwoColumnAsMap(dataTable));
            steps.iExpectAccountGroupIsUpdated(accountGrpId, dataMap);
        });


    }
}
