package tomcart.glue.webstepsdef.security.master;

import com.eastspring.tom.cart.core.CartBootstrap;
import com.eastspring.tom.cart.core.utl.DataTableUtil;
import com.eastspring.tom.cart.dmp.steps.websteps.security.master.InstitutionSteps;
import cucumber.api.java8.En;
import io.cucumber.datatable.DataTable;

import java.util.LinkedHashMap;
import java.util.Map;

public class InstitutionStepsDef implements En {

    private InstitutionSteps steps = (InstitutionSteps) CartBootstrap.getBean(InstitutionSteps.class);
    private DataTableUtil dataTableUtil = (DataTableUtil) CartBootstrap.getBean(DataTableUtil.class);

    public InstitutionStepsDef() {

        When("I add new Institution with following details", (DataTable dataTable) -> {
            LinkedHashMap<String, String> dataMap = new LinkedHashMap<>(dataTableUtil.getTwoColumnAsMap(dataTable));
            steps.iAddInstitutionDetails(dataMap);
        });

        When("I (add|update) Institution Identifiers with following details", (DataTable dataTable) -> {
            LinkedHashMap<String, String> dataMap = new LinkedHashMap<>(dataTableUtil.getTwoColumnAsMap(dataTable));
            steps.iAddInstitutionIdentifiers(dataMap);
        });

        Then("I expect Institution {string} is created", (String institutionName) -> {
            steps.iExpectInstitutionRecordCreated(institutionName);
        });

        Then("I open Institution {string} record", (String institutionName) -> {
            steps.iOpenInstitutionRecord(institutionName);
        });

        When("I update Institution with following details", (DataTable dataTable) -> {
            LinkedHashMap<String, String> dataMap = new LinkedHashMap<>(dataTableUtil.getTwoColumnAsMap(dataTable));
            steps.iUpdateInstitutionDetails(dataMap);
        });

        Then("I expect Institution details are updated as below", (DataTable dataTable) -> {
            Map<String, String> dataMap = dataTableUtil.getTwoColumnAsMap(dataTable);
            steps.iExpectInstitutionDetailsAreUpdated(dataMap);
        });

        Then("I expect Institution identifiers are updated as below", (DataTable dataTable) -> {
            Map<String, String> dataMap = dataTableUtil.getTwoColumnAsMap(dataTable);
            steps.iExpectFinInstitutionIdentifiersAreUpdated(dataMap);
        });

        //New step definitions added for EISDEV-5276
        When("I add LBU Identifiers with following details", (DataTable dataTable) -> {
            LinkedHashMap<String, String> dataMap = new LinkedHashMap<>(dataTableUtil.getTwoColumnAsMap(dataTable));
            steps.iAddLbuIdentifiers(dataMap);
        });

        //New step definitions added for EISDEV-5276
        Then("I expect LBU Identifiers are created as below", (DataTable dataTable) -> {
            Map<String, String> dataMap = dataTableUtil.getTwoColumnAsMap(dataTable);
            steps.iExpectFinInstitutionLbuIdentifiersAreCreated(dataMap);
        });

        //New step definitions added for EISDEV-5276
        When("I add SSDR OrgChart Attributes with following details", (DataTable dataTable) -> {
            LinkedHashMap<String, String> dataMap = new LinkedHashMap<>(dataTableUtil.getTwoColumnAsMap(dataTable));
            steps.iAddSsdrOrgChartAttributes(dataMap);
        });

        //New step definitions added for EISDEV-5276
        Then("I expect SSDR OrgChart Attributes are created as below", (DataTable dataTable) -> {
            Map<String, String> dataMap = dataTableUtil.getTwoColumnAsMap(dataTable);
            steps.iExpectSsdrOrgChartAttributesAreCreated(dataMap);
        });

        //New step definitions added for EISDEV-5276
        When("I add Address Details with following details", (DataTable dataTable) -> {
            LinkedHashMap<String, String> dataMap = new LinkedHashMap<>(dataTableUtil.getTwoColumnAsMap(dataTable));
            steps.iAddAddressDetails(dataMap);
        });

        //New step definitions added for EISDEV-5276
        Then("I expect Address Details are created as below", (DataTable dataTable) -> {
            Map<String, String> dataMap = dataTableUtil.getTwoColumnAsMap(dataTable);
            steps.iExpectAddressDetailsAreCreated(dataMap);
        });
    }
}
