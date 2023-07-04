package tomcart.glue;

import com.eastspring.tom.cart.core.CartBootstrap;
import com.eastspring.tom.cart.core.steps.ConfigSteps;
import com.eastspring.tom.cart.core.svc.DataTableSvc;
import cucumber.api.java.en.Given;
import cucumber.api.java.en.Then;
import cucumber.api.java.en.When;
import io.cucumber.datatable.DataTable;

import java.util.List;

/**
 * @author Daniel Baktiar
 * @since 2017-09
 */
public class ConfigStepsDef {

    private ConfigSteps configSteps = (ConfigSteps) CartBootstrap.getBean(ConfigSteps.class);
    private DataTableSvc dataTableSvc = (DataTableSvc) CartBootstrap.getBean(DataTableSvc.class);

    @Given("I use the named environment {string}")
    public void iUseNamedEnvironment(final String envName) {
        configSteps.useNamedEnvironment(envName);
    }

    @Given("I generate a UUID and store in variable {string}")
    public void iGenerateUUIDAndAssignToVar(final String varName) {
        configSteps.generateUuidAndStoreInVariable(varName);
    }

    @Given("I assign {string} to variable {string}")
    public void assignValueToVariable(final String value, final String variable) {
        configSteps.assignValueToVar(value, variable);
    }

    @Given("I remove variable {string} from memory")
    public void removeVarFromMemory(String varName) {
        configSteps.removeVar(varName);
    }

    @Given("I assign below value to variable {string}")
    public void assignMultiLineValueToVariable(final String variable, final String multiLineValue) {
        configSteps.assignValueToVar(multiLineValue, variable);
    }

    @Given("I generate value with date format {string} and assign to variable {string}")
    public void iGenerateDateAndAssignToVar(final String dateFormat, final String variable) {
        configSteps.assignFormattedDateToVar(dateFormat, variable);
    }

    @When("I modify date {string} with {string} from source format {string} to destination format {string} and assign to {string}")
    public void iModifyDateAndAssignToVar(final String dateVar, final String modifiers, final String srcFormat, final String destFormat, final String outputVar) {
        configSteps.modifyDateAndConvertFormat(dateVar, modifiers, srcFormat, destFormat, outputVar);
    }

    @Then("I expect the value of var {string} equals to {string}")
    public void assertEquals(final String value1, final String value2) {
        configSteps.verifyValuesEqual(value2, value1);
    }

    @Then("I expect the value of var {string} not equals to {string}")
    public void assertNotEquals(final String value1, final String value2) {
        configSteps.verifyValuesNotEqual(value2, value1);
    }

    @Then("I evaluate below math expression and store into variable {string}")
    public void computeMathExpression(final String resultVariable, final String multilineExpression) {
        configSteps.computeMathExpAndAssignToVar(multilineExpression, resultVariable);
    }

    @Then("I evaluate|verify below regex values in the target string {string} with occurrence index {int}")
    public void iEvaluateVerifyRegex(String target, Integer occurrence, DataTable dataTable) {
        List<String> values = dataTableSvc.getFirstColsAsList(dataTable);
        configSteps.evaluateRegExInTarget(target, values, occurrence);
    }

    //https://goessner.net/articles/JsonPath/
    @Then("read jsonpath {string} result from file {string} into variable {string}")
    public void readJsonPathValueFromFile(final String jsonPath, final String filepath, final String outputVar){
        configSteps.readJsonPathValueFromFile(jsonPath, filepath, outputVar);
    }

    //https://goessner.net/articles/JsonPath/
    @Then("read jsonpath {string} result from json string {string} into variable {string}")
    public void readJsonPathValueFromString(final String jsonPath, final String jsonContent, final String outputVar){
        configSteps.readJsonPathValueFromString(jsonPath, jsonContent, outputVar);
    }
}
