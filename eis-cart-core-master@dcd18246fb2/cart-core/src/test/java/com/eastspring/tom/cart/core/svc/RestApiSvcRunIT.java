package com.eastspring.tom.cart.core.svc;

import com.eastspring.tom.cart.core.CartCoreTestConfig;
import com.eastspring.tom.cart.core.CartException;
import com.eastspring.tom.cart.core.mdl.RestRequestType;
import com.eastspring.tom.cart.core.utl.FileDirUtil;
import com.eastspring.tom.cart.core.utl.pojo.Person;
import com.github.tomakehurst.wiremock.junit.WireMockRule;
import io.restassured.http.ContentType;
import io.restassured.response.Response;
import org.junit.*;
import org.junit.rules.ExpectedException;
import org.junit.runner.RunWith;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.test.context.ContextConfiguration;
import org.springframework.test.context.junit4.SpringJUnit4ClassRunner;

import java.util.ArrayList;
import java.util.HashMap;

import static com.github.tomakehurst.wiremock.client.WireMock.*;
import static com.github.tomakehurst.wiremock.core.WireMockConfiguration.wireMockConfig;

//wire mock looks for "__files" location by default
@RunWith( SpringJUnit4ClassRunner.class )
@ContextConfiguration( classes = {CartCoreSvcUtlTestConfig.class} )
public class RestApiSvcRunIT {

    private static final String HTTP_LOCALHOST = "http://localhost:";

    @Autowired
    private RestApiSvc restApiSvc;

    @Autowired
    private FileDirUtil fileDirUtil;

    @Rule
    public WireMockRule wireMockRule = new WireMockRule(wireMockConfig().dynamicPort());

    @Rule
    public ExpectedException thrown = ExpectedException.none();

    @BeforeClass
    public static void setUpClass() {
        CartCoreTestConfig.configureLogging(RestApiSvcRunIT.class);
    }

    @Before
    public void setApiBaseUri() {
        restApiSvc.setApiBaseUri(HTTP_LOCALHOST + wireMockRule.port());
    }

    @Test
    public void testSendRequest_GET() {
        stubFor(get(urlPathMatching("/mockApi/get"))
                .withQueryParam("search_term", equalTo("WireMock"))
                .willReturn(aResponse()
                        .withStatus(200)
                        .withHeader("Content-Type", String.valueOf(ContentType.JSON))
                        .withBodyFile("/testResponse.json")));

        restApiSvc.setApiEndPoint("/mockApi/get");
        restApiSvc.setEndPointParamsVar(new HashMap<String, String>() {
            {
                put("search_term", "WireMock");
            }
        });

        restApiSvc.setHeaderParams(new HashMap<String, String>() {{
            put("Content-Type", "application/json");
        }});

        //restApiSvc.setRequestLogging();
        restApiSvc.sendRequest(RestRequestType.GET);

        Assert.assertEquals(200, restApiSvc.getStatusCode().intValue());
        Object orderId = restApiSvc.getObjectFromResponse("postOrderResults.orderId");
        Object results = restApiSvc.getObjectFromResponse("postOrderResults");
        String orderId1 = restApiSvc.getValueFromResponse("postOrderResults.orderId");

        Assert.assertEquals("2257313", orderId1);
        Assert.assertEquals("2257313", ((ArrayList) orderId).get(0).toString());
        Assert.assertEquals(5, ((HashMap) ((ArrayList) results).get(0)).size());
    }

    @Test
    public void testSendRequest_POST() {
        stubFor(post(urlPathMatching("/mockApi/post"))
                .withHeader("Content-Type", containing("application/json"))
                .withRequestBody(equalToJson("{ \"status\" : \"OK\"}"))
                .willReturn(aResponse()
                        .withStatus(201)
                        .withBody("Created"))
        );

        //restApiSvc.setRequestLogging();

        restApiSvc.setApiEndPoint("/mockApi/post");
        restApiSvc.setBodyParam("{ \"status\" : \"OK\"}");
        restApiSvc.setHeaderParams(new HashMap<String, String>() {{
            put("Content-Type", "application/json");
        }});

        restApiSvc.setRequestLogging();
        restApiSvc.sendRequest(RestRequestType.POST);

        Assert.assertEquals(201, restApiSvc.getStatusCode().intValue());
        Assert.assertEquals("Created", restApiSvc.getResponseAsString());
    }

    @Test
    public void testSendRequest_DELETE() {
        stubFor(delete(urlEqualTo("/mockApi/delete/WireMock"))
                .withHeader("Content-Type", containing("application/json"))
                .willReturn(aResponse()
                        .withStatus(200)
                        .withBody("Deleted")));

        restApiSvc.setApiEndPoint("/mockApi/delete/WireMock");
        restApiSvc.setHeaderParams(new HashMap<String, String>() {{
            put("Content-Type", "application/json");
        }});
        restApiSvc.sendRequest(RestRequestType.DELETE);

        Assert.assertEquals(200, restApiSvc.getStatusCode().intValue());
        Assert.assertEquals("Deleted", restApiSvc.getResponseAsString());
    }

    @Test
    public void testSendRequest_endPointIsNotSet() {
        thrown.expect(CartException.class);
        thrown.expectMessage("Endpoint is not set, cannot process the request");

        stubFor(delete(urlEqualTo("/mockApi/delete/WireMock"))
                .withHeader("Content-Type", containing("application/json"))
                .willReturn(aResponse()
                        .withStatus(200)
                        .withBody("Deleted")));

        restApiSvc.setApiEndPoint("");
        restApiSvc.sendRequest(RestRequestType.DELETE);
    }

    @Test
    public void testSendRequest_requestNotImplemented() {
        thrown.expect(CartException.class);
        thrown.expectMessage("Request type [HEAD] is not implemented");
        stubFor(delete(urlEqualTo("/mockApi/delete/WireMock"))
                .withHeader("Content-Type", containing("application/json"))
                .willReturn(aResponse()
                        .withStatus(200)
                        .withBody("Deleted")));

        restApiSvc.setApiEndPoint("/mockApi/delete/WireMock");
        restApiSvc.sendRequest(RestRequestType.HEAD);
    }

    @Test
    public void testSendRequest_readResponseIntoPojo() {
        stubFor(get(urlPathMatching("/mockApi/get"))
                .willReturn(aResponse()
                        .withStatus(200)
                        .withBodyFile("/testPojo.json")));

        restApiSvc.setApiEndPoint("/mockApi/get");
        Response response = restApiSvc.sendRequest(RestRequestType.GET);
        Person person = restApiSvc.getResponseIntoObject(response, "", Person.class);

        Assert.assertEquals("TOMCART", person.getName());
        Assert.assertEquals(3, person.getAge());
    }

   /* @Test
    public void test() {
        //restApiSvc.setApiBaseUri("https://www.googleapis.com");
        restApiSvc.setApiEndPoint("https://www.googleapis.com/books/v1/volumes/s1gVAAAAYAAJ");
        restApiSvc.sendRequest(RestRequestType.GET);
        System.out.println(restApiSvc.getResponseAsString());
    }*/

}


