package tomcart.glue.webstepsdef.benchmark.master;

import com.eastspring.tom.cart.core.CartBootstrap;
import com.eastspring.tom.cart.core.utl.DataTableUtil;
import com.eastspring.tom.cart.dmp.steps.websteps.benchmark.master.BenchmarkSteps;
import cucumber.api.java8.En;
import io.cucumber.datatable.DataTable;

import java.util.Map;

public class BenchmarkStepsDef implements En {

    private BenchmarkSteps portalSteps = (BenchmarkSteps) CartBootstrap.getBean(BenchmarkSteps.class);
    private DataTableUtil dataTableUtil = (DataTableUtil) CartBootstrap.getBean(DataTableUtil.class);

    public BenchmarkStepsDef() {

        When("I create a benchmark with following details", (DataTable benchMarkDetails) -> {
            Map<String, String> dataMap = dataTableUtil.getTwoColumnAsMap(benchMarkDetails);
            portalSteps.iCreateBenchMark(dataMap);
        });

        When("I update benchmark {string} with following details", (String benchmark, DataTable updateBenchmark) -> {
            Map<String, String> dataMap = dataTableUtil.getTwoColumnAsMap(updateBenchmark);
            portalSteps.iUpdateBenchmark(benchmark, dataMap);
        });

        When("I expect the Benchmark {string} is updated as below", (String benchmark, DataTable updateBenchmark) -> {
            Map<String, String> dataMap = dataTableUtil.getTwoColumnAsMap(updateBenchmark);
            portalSteps.iExpectBenchmarkDetailsUpdated(benchmark, dataMap);
        });

        Then("I expect Benchmark {string} is created", (String benchmark) ->
                portalSteps.iExpectBenchmarkCreated(benchmark)
        );
    }
}
