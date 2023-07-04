package tomcart.glue;

import com.eastspring.tom.cart.core.CartBootstrap;
import com.eastspring.tom.cart.core.utl.DataTableUtil;
import com.eastspring.tom.cart.dmp.steps.DmpGsPortalSteps;
import cucumber.api.java8.En;
import io.cucumber.datatable.DataTable;

import java.util.List;
import java.util.Map;

import static com.eastspring.tom.cart.dmp.steps.DmpGsPortalSteps.*;

/**
 * <p>This class contains the definition for the steps related to the GS Web Portal.</p>
 *
 * @author Daniel Baktiar
 * @since 2017-10
 */
public class DmpGsPortalStepsDef implements En {

    private DmpGsPortalSteps portalSteps = (DmpGsPortalSteps) CartBootstrap.getBean(DmpGsPortalSteps.class);
    private DataTableUtil dataTableUtil = (DataTableUtil) CartBootstrap.getBean(DataTableUtil.class);

    public DmpGsPortalStepsDef() {

        Then("I select from GS menu {string}", (String gsMenu) -> portalSteps.selectGsMenu(gsMenu));

        Then("I close GS tab {string}", (String gsTabName) -> portalSteps.closeGsTab(gsTabName));

        Then("I close active GS tab", () -> portalSteps.closeActiveGsTab());

        Then("I expect there (are|is) {int} validation error(s|) on screen", (Integer errorsCount) -> portalSteps.verifyValidationErrorCount(errorsCount));

        Then("I expect below validation error messages on screen", (DataTable columnValTable) -> {
            Map<String, String> columnValMap = dataTableUtil.getTwoColumnAsMap(columnValTable);
            portalSteps.verifyValidationErrorMessage(columnValMap);
        });

        //Can be used for generic
        Then("I read column {string} number from table with xpath {string} and assign to {string}", (String columnName, String xPathOfTable, String varName) -> portalSteps.readColumnNumberToVar(xPathOfTable, columnName, varName));

        //Generic Step Defs for GS Data Table
        Then("I expect GS table should have {int} rows", (Integer expectedRows) -> portalSteps.expectGsTableRowCountShouldMatch(expectedRows));

        //Generic Step Defs for GS Header wrapper and GS Filter Row
        Then("I search GS table input column {string} with {string} followed by {string} key", (String columnName, String text, String followingKey) -> portalSteps.searchGsTableInputColumn(columnName, text, followingKey));

        //Generic Step Defs for GS Data Table & Header row
        Then("I expect column {string} value for row {int} should be {string}", (String columnName, Integer rowNum, String expectedValue) -> portalSteps.expectGsTableCellTextShouldMatchForGivenRow(columnName, expectedValue, rowNum));

        Given("I login into Golden Source UI with named configuration {string}", (String namedConfig) -> portalSteps.loginGsUIWithNamedConfig(namedConfig));

        Then("I expect GS table should have records with column {string} value {string}", (String columnName, String expectedValue) -> portalSteps.expectRecordsInGsTableWithColumnValue(columnName, expectedValue));

        Then("I expect {string} screen is opened", (String tabName) -> portalSteps.verifyTabDisplayed(tabName));

        Given("I login to golden source UI with {string} role", (String role) ->
                portalSteps.loginToGSWithUserRole(role)
        );


        Given("I relogin to golden source UI with {string} role", (String role) -> portalSteps.reLoginToGSWithUserRole(role));

        Then("I logout from Golden Source UI", () -> portalSteps.iLogoutFromGsUi());

        When("I (again search|search) Audit Log Report with below details", (DataTable dataTable) -> {
            Map<String, String> dataMap = dataTableUtil.getTwoColumnAsMap(dataTable);
            portalSteps.iSearchAuditLogReport(dataMap);
        });


        When("I add Domain Values for Internal Domain for Data Feed {string} with following details", (String fieldName, DataTable dataTable) -> {
            Map<String, String> dataMap = dataTableUtil.getTwoColumnAsMap(dataTable);
            portalSteps.iAddDomainValuesForIDFDF(fieldName, dataMap);
        });

        Then("I expect Internal Domain for Data Feed Record is moved to My WorkList for approval", () -> {
            portalSteps.iExpectDomainValuesForIDFDFAreInMyWorkList();
        });

        Then("I approve Internal Domain for Data Feed record", () ->
                portalSteps.iApproveDomainValueRecordForIDFDF()
        );

        When("I expect the Internal Domian For Data Feed is updated as below", (DataTable dataTable) -> {
            Map<String, String> dataMap = dataTableUtil.getTwoColumnAsMap(dataTable);
            portalSteps.iExpectDomainValuesForIDFDFUpdated(dataMap);
        });

        When("I add Domain Values for Internal Domain for Data Feed Class {string} with following details", (String fieldDataClassId, DataTable dataTable) -> {
            Map<String, String> dataMap = dataTableUtil.getTwoColumnAsMap(dataTable);
            portalSteps.iAddDomainValuesForIDFDFC(fieldDataClassId, dataMap);
        });

        Then("I expect Internal Domain for Data Feed Class Record is moved to My WorkList for approval", () -> portalSteps.iExpectDomainValuesForIDFDFCAreInMyWorkList());

        Then("I approve Internal Domain for Data Feed Class record", () ->
                portalSteps.iApproveDomainValueRecordForIDFDFC()
        );

        When("I expect the Internal Domian For Data Feed Class is updated as below", (DataTable dataTable) -> {
            Map<String, String> dataMap = dataTableUtil.getTwoColumnAsMap(dataTable);
            portalSteps.iExpectDomainValuesForIDFDFCUpdated(dataMap);
        });

        Then("I reject Internal Domain for Data Feed Class record", () ->
                portalSteps.iRejectDomainValueRecordForIDFDFC()
        );

        Then("I close Internal Domain for Data Feed Class record", () ->
                portalSteps.iCloseDomainValueRecordForIDFDFC()
        );

        Given("I reassign Internal Domain for Data Feed Class record with {string}", (String userid) -> {
            portalSteps.iReassignDomainValueRecordForIDFDFC(userid);
        });


        /*
        These are generic step definitions to approve a record from My WorkList based on Entity Name or Entity Id
        Actions: approve/reject/close/reassign
         */
        Then("I {word} a record from My WorkList with entity name {string}", (String action, String entityName) -> portalSteps.iActOnRecordFromMyWorkList(action, entityName, NAME));

        Then("I {word} a record from My WorkList with entity id {string}", (String action, String entityName) -> portalSteps.iActOnRecordFromMyWorkList(action, entityName, ID));

        Then("I expect a record in My WorkList with entity name {string}", (String entityName) -> portalSteps.iExpectRecordInMyWorkList(entityName, NAME, OPEN));

        Then("I expect a record in My WorkList with entity id {string}", (String entityId) -> portalSteps.iExpectRecordInMyWorkList(entityId, ID, OPEN));

        Then("I expect a record in My WorkList with entity name {string} and status {string}", (String entityName, String status) -> portalSteps.iExpectRecordInMyWorkList(entityName, NAME, status));

        Then("I expect a record in My WorkList with entity id {string} and status {string}", (String entityId, String status) -> portalSteps.iExpectRecordInMyWorkList(entityId, ID, status));

        //Dropdown Arrow button element property needs to be entered
        Then("I expect dropdown field with property {string} should have below values", (String elementProps, DataTable valuesTable) -> {
            List<String> listOfValues = dataTableUtil.getFirstColsAsList(valuesTable);
            portalSteps.verifyDropdownValues(elementProps, listOfValues, true);
        });

        //Dropdown Arrow button element property needs to be entered
        Then("I expect dropdown field with property {string} should contain below values", (String elementProps, DataTable valuesTable) -> {
            List<String> listOfValues = dataTableUtil.getFirstColsAsList(valuesTable);
            portalSteps.verifyDropdownValues(elementProps, listOfValues, false);
        });

        //Input box element property needs to be entered
        Then("I expect dropdown field with property {string} should contain below values with counts", (String elementProps, DataTable valuesCountTable) -> {
            Map<String, String> valueCountMap = dataTableUtil.getTwoColumnAsMap(valuesCountTable);
            portalSteps.verifyDropdownValuesCount(elementProps, valueCountMap);
        });

        Then("I save the valid data", () ->
                portalSteps.iSaveChangesWithValidData(false)
        );

        Then("I save the modified data", () ->
                portalSteps.iSaveChangesWithValidData(true)
        );

        Then("I save changes", () -> portalSteps.iSaveChanges());

        Then("I click on authorize record from My WorkList with entity name {string}", (String entityName) -> portalSteps.iClickAuthorizeFromWorkList(entityName));

        Then("I expect error message {string} on popup", (String errorMsg) -> {
            portalSteps.verifyErrorMessageOnPopUpContent(errorMsg);
        });

        Then("I delete from details screen", () -> {
            portalSteps.iDeleteRecord();
        });

        Then("I open {string} from global search", (String entity) -> {
            portalSteps.iOpenFromGlobalSearch(entity);
        });


    }
}