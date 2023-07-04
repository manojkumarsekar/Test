package com.eastspring.tom.cart.core.steps;

import com.eastspring.tom.cart.core.CartException;
import com.eastspring.tom.cart.core.CartExceptionType;
import com.eastspring.tom.cart.core.mdl.RestRequestType;
import com.eastspring.tom.cart.core.svc.RestApiSvc;
import com.eastspring.tom.cart.core.svc.StateSvc;
import com.eastspring.tom.cart.core.svc.WorkspaceDirSvc;
import com.eastspring.tom.cart.core.utl.FileDirUtil;
import com.eastspring.tom.cart.core.utl.ScenarioUtil;
import io.restassured.response.Response;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;

import java.util.Map;
import java.util.Set;

import static com.eastspring.tom.cart.core.svc.DataTableSvc.FILE_PREFIX;

public class RestApiSteps {

    private static final Logger LOGGER = LoggerFactory.getLogger(RestApiSteps.class);

    @Autowired
    private RestApiSvc restApiSvc;

    @Autowired
    private StateSvc stateSvc;

    @Autowired
    private WorkspaceDirSvc workspaceDirSvc;

    @Autowired
    private ScenarioUtil scenarioUtil;

    @Autowired
    private FileDirUtil fileDirUtil;

    public void writeResponseToReport() {
        scenarioUtil.write(restApiSvc.getResponseAsString());
    }

    public void setBaseUri(final String baseUri) {
        String expandBaseUri = stateSvc.expandVar(baseUri);
        restApiSvc.setApiBaseUri(expandBaseUri);
    }

    public void setApiEndPoint(final String endPoint) {
        String expandEndPoint = stateSvc.expandVar(endPoint);
        restApiSvc.setApiEndPoint(expandEndPoint);
    }

    public void setAuthenticationParams(final String username, final String password) {
        String expandUsername = stateSvc.expandVar(username);
        String expandPassword = stateSvc.expandVar(password);
        restApiSvc.setBasicAuthentication(expandUsername, expandPassword);
    }

    public void setAuthenticationWithToken(final String token) {
        String expandToken = stateSvc.expandVar(token);
        restApiSvc.setBasicAuthentication(expandToken);
    }

    public void setApiBodyParam(final String bodyParam) {
        String expandBodyParam = stateSvc.expandVar(bodyParam);
        if (bodyParam.startsWith(FILE_PREFIX)) {
            expandBodyParam = stateSvc.expandVar(fileDirUtil.readFileToString(workspaceDirSvc.normalize(expandBodyParam.replaceFirst(FILE_PREFIX, "").trim())));
        }
        restApiSvc.setBodyParam(expandBodyParam);

    }

    public void setHeaderParams(final Map<String, String> headerParams) {
        headerParams.remove("parameter", "value");
        headerParams.forEach((key, value) -> headerParams.replace(key, stateSvc.expandVar(value)));
        restApiSvc.setHeaderParams(headerParams);
    }

    public void setApiEndPointParams(final Map<String, String> endPointParams) {
        endPointParams.remove("parameter", "value");
        endPointParams.forEach((key, value) -> endPointParams.replace(key, stateSvc.expandVar(value)));
        restApiSvc.setEndPointParamsVar(endPointParams);
    }

    public void sendGetRequest() {
        restApiSvc.sendRequest(RestRequestType.GET);
    }

    public void sendPostRequest() {
        restApiSvc.sendRequest(RestRequestType.POST);
    }

    public void sendDeleteRequest() {
        restApiSvc.sendRequest(RestRequestType.DELETE);
    }

    public void sendPutRequest() {
        restApiSvc.sendRequest(RestRequestType.PUT);
    }

    public void sendPatchRequest() {
        restApiSvc.sendRequest(RestRequestType.PATCH);
    }

    public void expectStatusCodeAs(final Integer statusCode) {
        final Integer actualStatusCode = restApiSvc.getStatusCode();
        if (!statusCode.equals(actualStatusCode)) {
            LOGGER.error("Status Code verification failed, actual [{}], expected [{}]", actualStatusCode, statusCode);
            throw new CartException(CartExceptionType.VERIFICATION_FAILED, "Status Code verification failed, actual [{}], expected [{}]", actualStatusCode, statusCode);
        }
    }

    public void expectResponseShouldContain(final String responseInString) {
        String response = restApiSvc.getResponseAsString();
        if (!response.contains(responseInString)) {
            LOGGER.error("Actual response does not contain String [{}]", responseInString);
            throw new CartException(CartExceptionType.VERIFICATION_FAILED, "Actual response does not contain String [{}]", responseInString);
        }
    }

    public void expectResponseShouldIncludeFollowingKeyValues(final Map<String, String> jsonKeyValues) {
        Set<String> jsonKeySet = jsonKeyValues.keySet();
        for (String jsonKey : jsonKeySet) {
            String actualValue = restApiSvc.getObjectFromResponse(jsonKey).toString();
            String expectedValue = stateSvc.expandVar(jsonKeyValues.get(jsonKey));
            if (!expectedValue.equals(actualValue)) {
                LOGGER.error("Verification failed, Expected Json Key [{}] value is [{}], actual is [{}]", jsonKey, expectedValue, actualValue);
                throw new CartException(CartExceptionType.VERIFICATION_FAILED, "Verification failed, Expected Json Key [{}] value is [{}], actual is [{}]", jsonKey, expectedValue, actualValue);
            }
        }
    }

    public void extractResponseValuesIntoVars(final Map<String, String> jsonKeyVars) {
        try {
            Set<String> jsonKeySet = jsonKeyVars.keySet();
            Response latestResponse = restApiSvc.getResponse();
            for (String jsonKey : jsonKeySet) {
                String expandJsonKey = stateSvc.expandVar(jsonKey);
                String value = restApiSvc.getObjectFromResponse(latestResponse, expandJsonKey).toString();
                stateSvc.setStringVar(jsonKeyVars.get(expandJsonKey), value);
            }
        } catch (Exception e) {
            LOGGER.error("Processing failed while extracting api Key values into variables", e);
            throw new CartException(CartExceptionType.PROCESSING_FAILED, "Processing failed while extracting api Key values into variables");
        }
    }

}