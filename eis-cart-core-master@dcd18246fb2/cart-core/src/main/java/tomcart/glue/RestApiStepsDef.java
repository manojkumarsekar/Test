package tomcart.glue;

import com.eastspring.tom.cart.core.CartBootstrap;
import com.eastspring.tom.cart.core.steps.RestApiSteps;
import com.eastspring.tom.cart.core.svc.DataTableSvc;
import cucumber.api.java8.En;
import io.cucumber.datatable.DataTable;

public class RestApiStepsDef implements En {

    private RestApiSteps steps = (RestApiSteps) CartBootstrap.getBean(RestApiSteps.class);
    private DataTableSvc dataTableSvc = (DataTableSvc) CartBootstrap.getBean(DataTableSvc.class);

    public RestApiStepsDef() {

        Given("I have an Api with baseUrl {string}", (final String baseUri) -> steps.setBaseUri(baseUri));
        Given("I configure endpoint {string}", (final String endPoint) -> steps.setApiEndPoint(endPoint));
        Given("I configure endpoint {string} with below query parameters", (final String endPoint, final DataTable params) -> {
            steps.setApiEndPoint(endPoint);
            steps.setApiEndPointParams(dataTableSvc.getTwoColumnAsMap(params));
        });
        Given("I configure request with below header parameters", (final DataTable headerParamsTable) -> steps.setHeaderParams(dataTableSvc.getTwoColumnAsMap(headerParamsTable)));
        Given("I authenticate using username {string} and password {string}", (final String username, final String password) -> steps.setAuthenticationParams(username, password));
        Given("I authenticate using oAuth token {string}", (final String token) -> steps.setAuthenticationWithToken(token));
        Given("I configure request with below body parameter", (final String requestBody) -> steps.setApiBodyParam(requestBody));

        When("I submit GET request", () -> steps.sendGetRequest());
        When("I submit POST request", () -> steps.sendPostRequest());
        When("I submit DELETE request", () -> steps.sendDeleteRequest());
        When("I submit PUT request", () -> steps.sendPutRequest());
        When("I submit PATCH request", () -> steps.sendPatchRequest());

        When("I embed Api response in the report", () -> steps.writeResponseToReport());
        Then("I expect Api response status code as {int}", (final Integer statusCode) -> steps.expectStatusCodeAs(statusCode));
        Then("I expect Api response should contain:", (final String inString) -> steps.expectResponseShouldContain(inString));
        Then("I expect Api response should contain below json key values", (final DataTable keyValueTable) -> steps.expectResponseShouldIncludeFollowingKeyValues(dataTableSvc.getTwoColumnAsMap(keyValueTable)));
        Then("I extract json key values from latest Api response into variables", (final DataTable keyVarsTable) -> steps.extractResponseValuesIntoVars(dataTableSvc.getTwoColumnAsMap(keyVarsTable)));
    }
}