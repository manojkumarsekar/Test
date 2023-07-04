package com.eastspring.tom.cart.dmp.utl;

import com.eastspring.tom.cart.core.CartException;
import com.eastspring.tom.cart.core.CartExceptionType;
import com.eastspring.tom.cart.core.mdl.RestRequestType;
import com.eastspring.tom.cart.core.svc.RestApiSvc;
import com.eastspring.tom.cart.core.svc.StateSvc;
import com.eastspring.tom.cart.core.utl.DateTimeUtil;
import io.restassured.response.Response;
import org.apache.http.HttpResponse;
import org.apache.http.auth.AuthScope;
import org.apache.http.auth.UsernamePasswordCredentials;
import org.apache.http.client.CredentialsProvider;
import org.apache.http.client.methods.HttpGet;
import org.apache.http.client.methods.HttpPost;
import org.apache.http.entity.StringEntity;
import org.apache.http.impl.client.BasicCredentialsProvider;
import org.apache.http.impl.client.CloseableHttpClient;
import org.apache.http.impl.client.HttpClients;
import org.apache.http.util.EntityUtils;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;

import java.io.IOException;
import java.io.UnsupportedEncodingException;
import java.util.HashMap;
import java.util.Map;

import static com.eastspring.tom.cart.constant.BrsApiConstants.*;

public class BrsApiUtl {

    private static final Logger LOGGER = LoggerFactory.getLogger(BrsApiUtl.class);

    private static final String BRS_API_BASE_URL = "https://eastspring.blackrock.com/api/trading";
    private static final String VND_COM_BLACKROCK_REQUEST_ID = "VND.com.blackrock.Request-ID";
    private static final String VND_COM_BLACKROCK_ORIGIN_TIMESTAMP = "VND.com.blackrock.Origin-Timestamp";
    private static final String VND_COM_BLACKROCK_API_KEY = "VND.com.blackrock.API-Key";
    private static final String CONTENT_TYPE = "Content-Type";
    private static final String APPLICATION_JSON = "application/json";

    @Autowired
    private StateSvc stateSvc;

    @Autowired
    private DateTimeUtil dateTimeUtil;

    @Autowired
    private RestApiSvc restApiSvc;

    private Map<String, String> getBrsApiDefaultHeaders() {
        Map<String, String> headers = new HashMap<>();
        headers.put(VND_COM_BLACKROCK_REQUEST_ID, BRS_REQUEST_ID);
        headers.put(VND_COM_BLACKROCK_ORIGIN_TIMESTAMP, dateTimeUtil.getTimestamp("MM/DD/YYYY"));
        headers.put(VND_COM_BLACKROCK_API_KEY, stateSvc.getStringVar(BRS_API_KEY));
        headers.put(CONTENT_TYPE, APPLICATION_JSON);
        return headers;
    }

    public Response getRequest(final String endPoint, final Map<String, String> queryParams) {
        restApiSvc.setApiBaseUri(BRS_API_BASE_URL);
        restApiSvc.setApiEndPoint(endPoint);

        restApiSvc.setBasicAuthentication(stateSvc.getStringVar(BRS_USERNAME),
                stateSvc.getStringVar(BRS_PASSWORD));

        restApiSvc.setHeaderParams(getBrsApiDefaultHeaders());

        restApiSvc.setEndPointParamsVar(queryParams);
        final Response response = restApiSvc.sendRequest(RestRequestType.GET);

        final Integer statusCode = restApiSvc.getStatusCode();

        if (statusCode != 200) {
            LOGGER.error("Status code mismatch, expected = 200, actual = {}", statusCode);
            throw new CartException(CartExceptionType.PROCESSING_FAILED, "Status code mismatch, expected = 200, actual = {}", statusCode);
        }

        return response;
    }

    public Response postRequest(final String endPoint, final String postBody) {
        restApiSvc.setApiBaseUri(BRS_API_BASE_URL);
        restApiSvc.setApiEndPoint(endPoint);

        restApiSvc.setBasicAuthentication(stateSvc.getStringVar(BRS_USERNAME),
                stateSvc.getStringVar(BRS_PASSWORD));

        restApiSvc.setHeaderParams(getBrsApiDefaultHeaders());

        restApiSvc.setBodyParam(postBody);
        final Response response = restApiSvc.sendRequest(RestRequestType.POST);

        final Integer statusCode = restApiSvc.getStatusCode();

        if (statusCode != 200) {
            LOGGER.error("Status code mismatch, expected = 200, actual = {}", statusCode);
            throw new CartException(CartExceptionType.PROCESSING_FAILED, "Status code mismatch, expected = 200, actual = {}", statusCode);
        }

        return response;
    }

    //can be removed
    public CloseableHttpClient createHttpClient() {
        CredentialsProvider result = new BasicCredentialsProvider();
        result.setCredentials(AuthScope.ANY, new UsernamePasswordCredentials(stateSvc.getStringVar(BRS_USERNAME), stateSvc.getStringVar(BRS_PASSWORD)));
        CloseableHttpClient httpClient = HttpClients.custom().setDefaultCredentialsProvider(result).build();
        return httpClient;
    }

    //can be removed
    public void closeHttpClent(CloseableHttpClient httpClient) {
        httpClient.getConnectionManager().shutdown();
    }

    //can be removed
    public HttpPost createHttpPost(String endpointUrl) {
        HttpPost httpPost = new HttpPost(endpointUrl);
        httpPost.addHeader("content-type", "application/json");
        httpPost.addHeader("VND.com.blackrock.Request-ID", BRS_REQUEST_ID);
        String timeStamp = dateTimeUtil.getTimestamp("MM/DD/YYYY");
        httpPost.addHeader("VND.com.blackrock.Origin-Timestamp", timeStamp);
        httpPost.addHeader("VND.com.blackrock.API-Key", stateSvc.getStringVar(BRS_API_KEY));
        return httpPost;
    }

    //can be removed
    public HttpGet createHttpGet(String endpointUrl) {
        HttpGet httpGet = new HttpGet(endpointUrl);
        httpGet.addHeader("accept", "application/json");
        httpGet.addHeader("VND.com.blackrock.Request-ID", BRS_REQUEST_ID);
        String timeStamp = dateTimeUtil.getTimestamp("MM/DD/YYYY");
        httpGet.addHeader("VND.com.blackrock.Origin-Timestamp", timeStamp);
        httpGet.addHeader("VND.com.blackrock.API-Key", stateSvc.getStringVar(BRS_API_KEY));

        return httpGet;
    }

    //can be removed
    public HttpPost setBodyParameters(HttpPost httpPost, String apiBodyParameters) throws UnsupportedEncodingException {
        //Set the request post body
        StringEntity userEntity = null;
        userEntity = new StringEntity(apiBodyParameters);
        httpPost.setEntity(userEntity);
        return httpPost;
    }

    //can be removed
    public HttpResponse getHTTPPostResponse(CloseableHttpClient httpClient, HttpPost httpPost) throws IOException {
        //Send the request; It will immediately return the response in HttpResponse object if any
        HttpResponse response = null;
        response = httpClient.execute(httpPost);
        return response;
    }

    //can be removed
    public HttpResponse getHTTPGetResponse(CloseableHttpClient httpClient, HttpGet httpGet) throws IOException {
        //Send the request; It will immediately return the response in HttpResponse object if any
        HttpResponse response = null;
        response = httpClient.execute(httpGet);
        return response;
    }

    //can be removed
    public String getResponseBody(HttpResponse response) {
        //verify the valid error code first
        int statusCode = 0;
        String responseBody = null;
        try {
            statusCode = response.getStatusLine().getStatusCode();
            responseBody = EntityUtils.toString(response.getEntity());
        } catch (Exception e) {
            LOGGER.error("error: ", e);
            throw new CartException(CartExceptionType.PROCESSING_FAILED, "API call failed with status [{}]", statusCode);
        }
        return responseBody;
    }


}
