package com.eastspring.tom.cart.core.svc;

import com.eastspring.tom.cart.core.CartException;
import com.eastspring.tom.cart.core.CartExceptionType;
import com.eastspring.tom.cart.core.mdl.RestRequestType;
import com.google.common.base.Strings;
import io.restassured.response.Response;
import io.restassured.specification.RequestSpecification;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import java.io.File;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.Map;

import static io.restassured.RestAssured.given;
import static io.restassured.specification.ProxySpecification.host;

public class RestApiSvc {

    private static final Logger LOGGER = LoggerFactory.getLogger(RestApiSvc.class);

    private ThreadLocal<Response> response = new ThreadLocal<>();
    private ThreadLocal<RequestSpecification> requestSpec = new ThreadLocal<>();
    private ThreadLocal<String> endPoint = new ThreadLocal<>();
    private ThreadLocal<Map<String, String>> endPointParams = ThreadLocal.withInitial(HashMap::new);
    private ThreadLocal<String> baseUri = new ThreadLocal<>();

    //Wrapper method on API interaction
    public synchronized Response sendRequest(final RestRequestType requestType) {
        try {
            if (Strings.isNullOrEmpty(endPoint.get())) {
                LOGGER.error("Endpoint is not set, cannot process the request");
                throw new CartException(CartExceptionType.UNDEFINED, "Endpoint is not set, cannot process the request");
            }

            String url = baseUri.get() + endPoint.get();
            switch (requestType) {
                case GET:
                    response.set(this.sendGetRequest(url));
                    break;
                case POST:
                    response.set(this.sendPostRequest(url));
                    break;
                case DELETE:
                    response.set(this.sendDeleteRequest(url));
                    break;
                case PUT:
                    response.set(this.sendPutRequest(url));
                    break;
                case PATCH:
                    response.set(this.sendPatchRequest(url));
                    break;
                default:
                    LOGGER.error("Request type [{}] is not implemented", requestType);
                    throw new CartException(CartExceptionType.UNDEFINED, "Request type [{}] is not implemented", requestType);
            }
            response.get().then().log().ifError();
            return response.get();
        } finally

        {
            this.clearRequestSpecObject();
        }

    }

    public void clearRequestSpecObject() {
        LOGGER.debug("clearing RequestSpec and Endpoint config");
        requestSpec = new ThreadLocal<>();
    }

    public RequestSpecification getRequestSpec() {
        return requestSpec.get();
    }

    public Response getResponse() {
        if (response == null) {
            LOGGER.error("Response is null");
            throw new CartException(CartExceptionType.UNDEFINED, "Response is null");
        }
        return response.get();
    }

    public void setApiBaseUri(final String uri) {
        LOGGER.debug("Setting Api base uri [{}]", uri);
        baseUri.set(uri);
    }

    public void setApiEndPoint(final String endPoint) {
        LOGGER.debug("Setting Api endpoint [{}]", endPoint);
        this.endPoint.set(endPoint);
    }

    public void setEndPointParamsVar(final Map<String, String> params) {
        LOGGER.debug("Setting Api endpoint params [{}]", params.toString());
        this.endPointParams.set(params);
    }

    //Setting Basic Authentication
    public RequestSpecification setBasicAuthentication(final String username, final String password) {
        LOGGER.debug("Basic authentication using {} and {}", username, "********");
        if (getRequestSpec() == null) {
            requestSpec.set(given().auth().basic(username, password));
        } else {
            requestSpec.set(getRequestSpec().given().auth().basic(username, password));
        }
        return requestSpec.get();
    }

    public RequestSpecification setBasicAuthentication(final String token) {
        LOGGER.debug("Basic authentication using token {}", token);
        if (getRequestSpec() == null) {
            requestSpec.set(given().auth().oauth2(token));
        } else {
            requestSpec.set(getRequestSpec().given().auth().oauth2(token));
        }
        return requestSpec.get();
    }

    RequestSpecification setProxy(final String host, final Integer port, final String username, final String password) {
        if (getRequestSpec() == null) {
            requestSpec.set(given());
        } else {
            requestSpec.set(getRequestSpec().given());
        }
        requestSpec.set(requestSpec.get().proxy(host(host).and().withPort(port).withAuth(username, password)));
        return requestSpec.get();
    }

    public RequestSpecification setRequestLogging() {
        if (getRequestSpec() == null) {
            requestSpec.set(given());
        } else {
            requestSpec.set(getRequestSpec().given());
        }
        return requestSpec.get().log().all();
    }

    //Setting Header params
    public RequestSpecification setHeaderParams(final Map<String, String> headerParams) {
        LOGGER.debug("Setting Api header params [{}]", headerParams.toString());
        if (getRequestSpec() == null) {
            requestSpec.set(given().headers(headerParams));
        } else {
            requestSpec.set(getRequestSpec().given().headers(headerParams));
        }
        return requestSpec.get();
    }

    //Setting Header params
    public RequestSpecification setHeaderParams(final String key, final String value) {
        if (getRequestSpec() == null) {
            requestSpec.set(given().headers(key, value));
        } else {
            requestSpec.set(getRequestSpec().given().headers(key, value));
        }
        return requestSpec.get();
    }

    //Setting Body Params
    public RequestSpecification setBodyParam(final String bodyContent) {
        LOGGER.debug("Setting Api body param [{}]", bodyContent);
        if (getRequestSpec() == null) {
            requestSpec.set(given().body(bodyContent));
        } else {
            requestSpec.set(getRequestSpec().given().body(bodyContent));
        }
        return requestSpec.get();
    }

    //Setting Body Params
    public RequestSpecification setBodyParam(final File file) {
        LOGGER.debug("Setting Api body param [{}]", file.getAbsolutePath());
        if (getRequestSpec() == null) {
            requestSpec.set(given().body(file));
        } else {
            requestSpec.set(getRequestSpec().given().body(file));
        }
        return requestSpec.get();
    }

    public RequestSpecification setMultiPartData(final String filePath) {
        LOGGER.debug("Setting Multipart data [{}]", filePath);
        if (getRequestSpec() == null) {
            requestSpec.set(given().multiPart(new File(filePath)));
        } else {
            requestSpec.set(getRequestSpec().given().multiPart(new File(filePath)));
        }
        return requestSpec.get();
    }

    public RequestSpecification setMultiPartData(final String key, String filepath, String fileType) {
        if (getRequestSpec() == null) {
            requestSpec.set(given().multiPart(key, new File(filepath), fileType));
        } else {
            requestSpec.set(getRequestSpec().given().multiPart(key, new File(filepath), fileType));
        }
        return requestSpec.get();
    }

    public RequestSpecification setMultiPartData(final String key, final String value) {
        if (getRequestSpec() == null) {
            requestSpec.set(given().multiPart(key, value));
        } else {
            requestSpec.set(getRequestSpec().given().multiPart(key, value));
        }
        return requestSpec.get();
    }


    //API interaction methods
    private Response sendPostRequest(final String url) {
        if (getRequestSpec() == null) {
            return given()
                    .when()
                    .post(url);
        }
        return getRequestSpec()
                .when()
                .post(url);
    }

    private Response sendGetRequest(final String url) {
        if (getRequestSpec() == null) {
            return given()
                    .params(endPointParams.get())
                    .when()
                    .get(url);
        }
        return getRequestSpec()
                .given()
                .params(endPointParams.get())
                .when()
                .get(url);
    }

    private Response sendDeleteRequest(final String url) {
        if (getRequestSpec() == null) {
            return given()
                    .when()
                    .delete(url);
        }
        return getRequestSpec()
                .when()
                .delete(url);
    }

    private Response sendPutRequest(final String url) {
        if (getRequestSpec() == null) {
            return given()
                    .when()
                    .put(url);
        }
        return getRequestSpec()
                .when()
                .put(url);
    }

    private Response sendPatchRequest(final String url) {
        if (getRequestSpec() == null) {
            return given()
                    .when()
                    .patch(url);
        }
        return getRequestSpec()
                .when()
                .patch(url);
    }

    //Validation methods
    public Integer getStatusCode() {
        return getResponse().getStatusCode();
    }

    public String getResponseAsString() {
        return getResponse().asString();
    }

    public String getValueFromResponse(final String jsonKey) {
        return ((ArrayList) getObjectFromResponse(jsonKey)).get(0).toString();
    }

    public Object getObjectFromResponse(final String jsonKey) {
        return this.getObjectFromResponse(getResponse(), jsonKey);
    }

    public Object getObjectFromResponse(final Response response, final String jsonKey) {
        if (response == null) {
            return null;
        }
        Object value = response.jsonPath().get(jsonKey);
        LOGGER.debug("Response value for jsonKey [{}] is [{}]", jsonKey, value);
        return value;
    }

    public <T> T getResponseIntoObject(final Response response, final String jsonKey, final Class<T> clazz) {
        if (response == null) {
            return null;
        }
        return response.jsonPath().getObject(jsonKey, clazz);
    }

}