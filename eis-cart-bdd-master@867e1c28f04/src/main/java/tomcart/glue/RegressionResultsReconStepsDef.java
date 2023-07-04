package tomcart.glue;

import com.eastspring.tom.cart.cfg.RegressionResultsReconSteps;
import com.eastspring.tom.cart.core.CartBootstrap;
import com.eastspring.tom.cart.core.svc.DataTableSvc;
import cucumber.api.java.en.Given;
import cucumber.api.java.en.Then;
import io.cucumber.datatable.DataTable;

import java.util.Map;

public class RegressionResultsReconStepsDef {

    private RegressionResultsReconSteps steps = (RegressionResultsReconSteps) CartBootstrap.getBean(RegressionResultsReconSteps.class);
    private DataTableSvc dataTableSvc = (DataTableSvc) CartBootstrap.getBean(DataTableSvc.class);

    @Given( "Check {string} file exists" )
    public void checkFileExists(final String filepath) {
        steps.checkFileExistsInLocalFolder(filepath);
    }

    @Then( "I expect there are no new failures in release regression compared to latest master regression" )
    public void compareRegressionResults(DataTable dataTable) {
        final Map<String, String> map = dataTableSvc.getTwoColumnAsMap(dataTable);
        final String masterFailures = map.get("master");
        final String releaseFailures = map.get("release");
        steps.compareRegressionResults(releaseFailures, masterFailures);
    }
}
