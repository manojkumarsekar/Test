package tomcart.glue.webstepsdef.security.master;

import com.eastspring.tom.cart.core.CartBootstrap;
import com.eastspring.tom.cart.core.utl.DataTableUtil;
import com.eastspring.tom.cart.dmp.steps.websteps.security.master.InstrumentGroupSteps;
import cucumber.api.java8.En;
import io.cucumber.datatable.DataTable;

import java.util.LinkedHashMap;

public class InstrumentGroupStepsDef implements En {

    private DataTableUtil dataTableUtil = (DataTableUtil) CartBootstrap.getBean(DataTableUtil.class);
    private InstrumentGroupSteps steps = (InstrumentGroupSteps) CartBootstrap.getBean(InstrumentGroupSteps.class);

    public InstrumentGroupStepsDef() {

        When("I create Instrument Group with following details", (DataTable dataTable) -> {
            LinkedHashMap<String, String> dataMap = new LinkedHashMap<>(dataTableUtil.getTwoColumnAsMap(dataTable));
            steps.iCreateInstrumentGroup(dataMap);
        });

        When("I add Instrument Group Participant with following details", (DataTable dataTable) -> {
            LinkedHashMap<String, String> dataMap = new LinkedHashMap<>(dataTableUtil.getTwoColumnAsMap(dataTable));
            steps.iCreateInstrumentGroupAndParticipant(dataMap);
        });


        When("I add Participant details to the Instrument Group {string}", (String groupName, DataTable dataTable) -> {
            LinkedHashMap<String, String> dataMap = new LinkedHashMap<>(dataTableUtil.getTwoColumnAsMap(dataTable));
            steps.iAddParticipantDetailsToGivenGroup(groupName, dataMap);
        });

        When("I update Instrument group {string} with following details", (String groupName, DataTable dataTable) -> {
            LinkedHashMap<String, String> dataMap = new LinkedHashMap<>(dataTableUtil.getTwoColumnAsMap(dataTable));
            steps.iUpdateInstrumentGroupAndParticipant(groupName, dataMap);
        });

        When("I expect the Instrument Group {string} is updated as below", (String groupName, DataTable dataTable) -> {
            LinkedHashMap<String, String> dataMap = new LinkedHashMap<>(dataTableUtil.getTwoColumnAsMap(dataTable));
            steps.iExpectInstrumentGroupAddedWithBelowDetails(groupName, dataMap);
        });

        When("I expect the Instrument Group Participant is updated as below", (DataTable dataTable) -> {
            LinkedHashMap<String, String> dataMap = new LinkedHashMap<>(dataTableUtil.getTwoColumnAsMap(dataTable));
            steps.iExpectInstrumentGroupParticipantWithBelowDetails(dataMap);
        });

        Then("I expect Instrument Group {string} is created", (String groupName) -> steps.iExpectInstrumentGroupCreated(groupName));

    }
}
