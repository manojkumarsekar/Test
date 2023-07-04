package tomcart.glue.webstepsdef.generic.setup;

import com.eastspring.tom.cart.core.CartBootstrap;
import com.eastspring.tom.cart.core.utl.DataTableUtil;
import com.eastspring.tom.cart.dmp.steps.websteps.generic.setup.RequestTypeConfigSteps;
import cucumber.api.java8.En;
import io.cucumber.datatable.DataTable;

import java.util.LinkedHashMap;

public class RequestTypeConfigStepsDef implements En {

    private DataTableUtil dataTableUtil = (DataTableUtil) CartBootstrap.getBean(DataTableUtil.class);
    private RequestTypeConfigSteps steps = (RequestTypeConfigSteps) CartBootstrap.getBean(RequestTypeConfigSteps.class);

    public RequestTypeConfigStepsDef() {

        Then("I create a new Request Type Configuration with below details", (DataTable dataTable) -> {
            LinkedHashMap<String, String> dataMap = new LinkedHashMap<>(dataTableUtil.getTwoColumnAsMap(dataTable));
            steps.iCreateRequestTypeConfiguration(dataMap);
        });

        //first key-value pair in the map is used to search the config
        //First we need to call Search step before calling Update step
        When("I update Request Type Configuration with below details", (DataTable dataTable) -> {
            LinkedHashMap<String, String> dataMap = new LinkedHashMap<>(dataTableUtil.getTwoColumnAsMap(dataTable));
            steps.iUpdateRequestTypeConfiguration(dataMap);
        });

        Then("I expect Request Type Configuration is created with below value", (DataTable dataTable) -> {
            LinkedHashMap<String, String> dataMap = new LinkedHashMap<>(dataTableUtil.getTwoColumnAsMap(dataTable));
            steps.iExpectRequestTypeConfigurationCreated(dataMap);
        });

        Then("I search Request Type Configuration with below value", (DataTable dataTable) -> {
            LinkedHashMap<String, String> dataMap = new LinkedHashMap<>(dataTableUtil.getTwoColumnAsMap(dataTable));
            steps.iSearchRequestTypeConfigurationCreated(dataMap);
        });

        //first key-value pair in the map is used to search the config
        Then("I expect Request Type Configuration is updated as below", (DataTable dataTable) -> {
            LinkedHashMap<String, String> dataMap = new LinkedHashMap<>(dataTableUtil.getTwoColumnAsMap(dataTable));
            steps.iExpectRequestTypeConfigurationIsUpdated(dataMap);
        });


    }
}
