package tomcart.glue;

import com.eastspring.tom.cart.core.CartBootstrap;
import com.eastspring.tom.cart.core.utl.DataTableUtil;
import com.eastspring.tom.cart.dmp.steps.ControlMServiceSteps;
import cucumber.api.java8.En;
import io.cucumber.datatable.DataTable;

import java.util.HashMap;
import java.util.Map;

public class ControlMStepDef implements En {

    private ControlMServiceSteps ctrlmSteps = (ControlMServiceSteps) CartBootstrap.getBean(ControlMServiceSteps.class);
    private DataTableUtil dataTableUtil = (DataTableUtil) CartBootstrap.getBean(DataTableUtil.class);

    public ControlMStepDef() {
        Given("I establish connection with controlM server with below API credentials", (DataTable sessionParam) -> {
            Map<String, String> paramDetails = dataTableUtil.getTwoColumnAsMap(sessionParam);
            ctrlmSteps.createSession(paramDetails.get("username"), paramDetails.get("password"));
        });

        Given("I establish connection with controlM server with default API credentials", () -> {
            ctrlmSteps.createSession();
        });

        When("I order the controlM job {string} using API with default parameters", (String jobRelativePath) -> {
            ctrlmSteps.orderControlMJob(jobRelativePath, new HashMap<>());
        });

        When("I order the controlM job {string} using API with below parameters", (String jobRelativePath, DataTable orderParam) -> {
            Map<String, String> paramDetails = dataTableUtil.getTwoColumnAsMap(orderParam);
            ctrlmSteps.orderControlMJob(jobRelativePath, paramDetails);
        });

        When("I order the controlM folder {string} using API with default parameters", (String folderRelativePath) -> {
            ctrlmSteps.orderControlMFolder(folderRelativePath, new HashMap<>());
        });

        When("I order the controlM folder {string} using API with below parameters", (String folderRelativePath, DataTable orderParam) -> {
            Map<String, String> paramDetails = dataTableUtil.getTwoColumnAsMap(orderParam);
            ctrlmSteps.orderControlMFolder(folderRelativePath, paramDetails);
        });

        When("I free the ordered controlM entity", () -> {
            ctrlmSteps.freeOrderedEntity();
        });

        Then("I wait for {int} seconds till the job status is passed", (Integer seconds) -> {
            ctrlmSteps.waitTillJobStatusEndedOK(seconds);
        });

        Then("I wait for {int} seconds till the job status is failed", (Integer seconds) -> {
            ctrlmSteps.waitTillJobStatusEndedNOTOK(seconds);
        });
    }

}
