package tomcart.glue.webstepsdef.generic.setup;

import com.eastspring.tom.cart.core.CartBootstrap;
import com.eastspring.tom.cart.core.utl.DataTableUtil;
import com.eastspring.tom.cart.dmp.steps.websteps.generic.setup.TaiwanBrokerSteps;
import cucumber.api.java8.En;
import io.cucumber.datatable.DataTable;

import java.util.LinkedHashMap;

public class TaiwanBrokerStepDef implements En {

    private DataTableUtil dataTableUtil = (DataTableUtil) CartBootstrap.getBean(DataTableUtil.class);
    private TaiwanBrokerSteps steps = (TaiwanBrokerSteps) CartBootstrap.getBean(TaiwanBrokerSteps.class);

    public TaiwanBrokerStepDef() {

        Then("I create a new Taiwan Broker with below details", (DataTable dataTable) -> {
            LinkedHashMap<String, String> dataMap = new LinkedHashMap<>(dataTableUtil.getTwoColumnAsMap(dataTable));
            steps.iCreateTaiwanBroker(dataMap);
        });

    }
}
