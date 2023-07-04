package tomcart.glue.webstepsdef.generic.setup;

import com.eastspring.tom.cart.core.CartBootstrap;
import com.eastspring.tom.cart.core.utl.DataTableUtil;
import com.eastspring.tom.cart.dmp.steps.DmpGsPortalSteps;
import com.eastspring.tom.cart.dmp.steps.websteps.generic.setup.CentralCrossRefGrpSteps;
import com.eastspring.tom.cart.dmp.steps.websteps.generic.setup.IndustryClassificationSteps;
import cucumber.api.java8.En;
import io.cucumber.datatable.DataTable;

import java.util.LinkedHashMap;
import java.util.Map;

public class IndustryClassificationStepsDef implements En {

    private IndustryClassificationSteps steps = (IndustryClassificationSteps) CartBootstrap.getBean(IndustryClassificationSteps.class);
    private DmpGsPortalSteps portalSteps = (DmpGsPortalSteps) CartBootstrap.getBean(DmpGsPortalSteps.class);
    private DataTableUtil dataTableUtil = (DataTableUtil) CartBootstrap.getBean(DataTableUtil.class);

    public IndustryClassificationStepsDef() {

        When("I add Industry Classification Details for Classification set {string} with following details", (String setMnemonic, DataTable dataTable) -> {
            Map<String, String> dataMap = dataTableUtil.getTwoColumnAsMap(dataTable);
            steps.iAddIndustryClassificationDetails(setMnemonic, dataMap);
        });

        When("I expect Industry Classification Details for set {string} are updated as below", (String mnemonic,DataTable dataTable) -> {
            Map<String, String> dataMap = dataTableUtil.getTwoColumnAsMap(dataTable);
            steps.iExpectIndustryClassificationDetailsUpdated(mnemonic,dataMap);
        });

        When("I delete Industry Classification Details for Classification set {string} having following details", (String setMnemonic, DataTable dataTable) -> {
            Map<String, String> dataMap = dataTableUtil.getTwoColumnAsMap(dataTable);
            steps.iDeleteIndustryClassificationDetails(setMnemonic, dataMap);
        });

    }

}
