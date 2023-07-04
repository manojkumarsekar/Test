package com.eastspring.tom.cart.core.svc;

import com.eastspring.tom.cart.core.CartCoreTestConfig;
import com.github.tomakehurst.wiremock.junit.WireMockRule;
import io.restassured.response.Response;
import org.junit.Assert;
import org.junit.Before;
import org.junit.BeforeClass;
import org.junit.Rule;
import org.junit.Test;
import org.junit.rules.ExpectedException;
import org.junit.runner.RunWith;
import org.mockito.MockitoAnnotations;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.test.context.ContextConfiguration;
import org.springframework.test.context.junit4.SpringJUnit4ClassRunner;

import java.io.File;
import java.util.Calendar;

import static com.github.tomakehurst.wiremock.client.WireMock.aResponse;
import static com.github.tomakehurst.wiremock.client.WireMock.containing;
import static com.github.tomakehurst.wiremock.client.WireMock.equalToJson;
import static com.github.tomakehurst.wiremock.client.WireMock.get;
import static com.github.tomakehurst.wiremock.client.WireMock.post;
import static com.github.tomakehurst.wiremock.client.WireMock.stubFor;
import static com.github.tomakehurst.wiremock.client.WireMock.urlPathMatching;
import static com.github.tomakehurst.wiremock.core.WireMockConfiguration.wireMockConfig;


@RunWith(SpringJUnit4ClassRunner.class)
@ContextConfiguration(classes = {CartCoreSvcUtlTestConfig.class})
public class ControlMSvcTest {
    private static final Logger LOGGER = LoggerFactory.getLogger(ControlMSvcTest.class);
    private static final String HTTP_LOCALHOST = "http://localhost:";

    @Rule
    public WireMockRule wireMockRule = new WireMockRule(wireMockConfig().dynamicPort());

    @Autowired
    private ControlMSvc service;

    @Autowired
    private RestApiSvc restApiSvc;

    @Rule
    public ExpectedException thrown = ExpectedException.none();


    private static final String session = "{\n" +
            "  \"username\": \"manoj.kumar\",\n" +
            "  \"token\": \"38ADDD2AA8A4DF18CABACAF92D139F27DCD0E55ED54FC81DBE0A347491474067BA7792440CC9B46144349E441FE958FE9043E68A116BB04FA2BFD123B3F53368\",\n" +
            "  \"version\": \"9.20.110\"\n" +
            "}";

    private static final String orderBody = "{\n" +
            "  \"ctm\": \"CTM_UAT\",\n" +
            "  \"folder\":\"EIS-APP-DMP-INTRADAY-DEV108\",\n" +
            "  \"hold\": \"true\",\n" +
            "  \"ignoreCriteria\": \"true\",\n" +
            "  \"independentFlow\": \"true\"\n" +
            "\n" +
            "}";

    private static final String orderResponse = "{\n" +
            "  \"runId\": \"a4a02f08-a5fd-48ab-8286-71abab9beedb\",\n" +
            "  \"statusURI\": \"https://sgrtssymqsku3yz:8443/automation-api/run/status/a4a02f08-a5fd-48ab-8286-71abab9beedb\"\n" +
            "}";

    private static final String runStatusOutput = "{\n" +
            "  \"statuses\": [\n" +
            "    {\n" +
            "      \"jobId\": \"CTM_UAT:5ahdj\",\n" +
            "      \"folderId\": \"CTM_UAT:00000\",\n" +
            "      \"numberOfRuns\": 0,\n" +
            "      \"name\": \"UEISCDMPD_API_TEST_JOB1\",\n" +
            "      \"folder\": \"EIS-APP-DMP-INTRADAY-DEV108/EIS_DMP_STACS_TO_BRS_DEV108\",\n" +
            "      \"type\": \"Command\",\n" +
            "      \"status\": \"Wait Condition\",\n" +
            "      \"held\": true,\n" +
            "      \"deleted\": false,\n" +
            "      \"startTime\": \"\",\n" +
            "      \"endTime\": \"\",\n" +
            "      \"outputURI\": \"Job did not run, it has no output\",\n" +
            "      \"logURI\": \"https://sgrtssymqsku3yz:8443/automation-api/run/job/CTM_UAT:5ahdj/log\"\n" +
            "    }\n" +
            "  ],\n" +
            "  \"startIndex\": 0,\n" +
            "  \"itemsPerPage\": 25,\n" +
            "  \"total\": 1\n" +
            "}";

    private static final String jobLog = "14:01:06 21-Apr-2021  ORDERED JOB:2310007; DAILY FORCED, ODATE 20210421	5065";

    private static final String jobOutput = "+ /dmp/scripts/capture_file_transfer.sh -s BRS -w /dmp/in/korea -p 'esi_Korea_price_bm_levels_*.csv'\n" +
            "==================================================================\n" +
            "These are the parameters that was passed    \n" +
            "SOURCE_ID            = BRS           \n" +
            "INPUT_DATA_DIR       = /dmp/in/korea      \n" +
            "FILE_PATTERN         = esi_Korea_price_bm_levels_*.csv        \n" +
            "DELAY                = 2               \n" +
            "FILE_NOT_FOUND_ERR   = 50  ";

    private static final String CONTROL_M_URI_BASE = "controlm.api.uri.base";
    private static final String CONTROL_M_URI_LOGIN = "controlm.api.uri.endpoint.login";
    private static final String CONTROL_M_URI_ORDER = "controlm.api.uri.endpoint.order";
    private static final String CONTROL_M_URI_STATUS = "controlm.api.uri.endpoint.status";
    private static final String CONTROL_M_URI_FREE = "controlm.api.uri.endpoint.free";
    private static final String CONTROL_M_URI_OUTPUT = "controlm.api.uri.endpoint.output";
    private static final String CONTROL_M_URI_LOG = "controlm.api.uri.endpoint.log";
    private static final String jobId = "0987654321";
    private static final String runId = "f6fe40e8-9a1b-470c-8328-012dfdf88af3";
    private static final String sessionToken = "123456789";


    @Before
    public void initMocks() {
        MockitoAnnotations.initMocks(this);
    }


    @BeforeClass
    public static void setUpClass() {
        CartCoreTestConfig.configureLogging(ControlMSvcTest.class);
    }


    @Before
    public void setApiBaseUri() {
        restApiSvc.setApiBaseUri(HTTP_LOCALHOST + wireMockRule.port());
    }


    @Test
    public void testGetTodayOdate() {
        String todayOdate = service.getTodayOdate();
        LOGGER.info("today's ODATE: {}", todayOdate);
        Calendar todayCalendar = Calendar.getInstance();
        Assert.assertNotNull(todayOdate);
        Assert.assertEquals(8, todayOdate.length());
        Assert.assertEquals((long) todayCalendar.get(Calendar.YEAR), (long) Long.valueOf(todayOdate.substring(0, 4)));
        Assert.assertEquals((long) todayCalendar.get(Calendar.MONTH) + 1, (long) Long.valueOf(todayOdate.substring(4, 6)));
        Assert.assertEquals((long) todayCalendar.get(Calendar.DAY_OF_MONTH), (long) Long.valueOf(todayOdate.substring(6, 8)));
    }


    @Test
    public void testcreateApiSession() {

        stubFor(post(urlPathMatching("/mockApi/post"))
                .withHeader("Content-Type", containing("application/json"))
                .withRequestBody(equalToJson("{\"username\": \"manoj.kumar\", \"password\": \"123456\" }"))
                .willReturn(aResponse()
                        .withBody(session))
        );

        System.setProperty(CONTROL_M_URI_BASE, HTTP_LOCALHOST + wireMockRule.port());
        System.setProperty(CONTROL_M_URI_LOGIN, "/mockApi/post");
        Response actualResponse = service.createApiSession("manoj.kumar", "123456");
        Assert.assertEquals(session, actualResponse.asString());
    }

    @Test
    public void testorderJob() {
        final File file = new File("src/test/resources/__files/order_job_request.json");
        stubFor(post(urlPathMatching("/automation-api/run/order"))
                .withHeader("Content-Type", containing("application/json"))
                .withHeader("Authorization", containing("Bearer 123456789"))
                .withRequestBody(equalToJson(orderBody))
                .willReturn(aResponse()
                        .withBody(orderResponse))
        );
        System.setProperty(CONTROL_M_URI_BASE, HTTP_LOCALHOST + wireMockRule.port());
        System.setProperty(CONTROL_M_URI_ORDER, "/automation-api/run/order");
        Response actualResponse = service.orderJob(sessionToken, file);
        Assert.assertEquals(orderResponse, actualResponse.asString());
    }


    @Test
    public void testgetJobStatusByRunId() {
        stubFor(get(urlPathMatching("/automation-api/run/status/" + runId))
                .withHeader("Content-Type", containing("application/json"))
                .withHeader("Authorization", containing("Bearer 123456789"))
                .willReturn(aResponse()
                        .withBody(runStatusOutput))
        );
        System.setProperty(CONTROL_M_URI_BASE, HTTP_LOCALHOST + wireMockRule.port());
        System.setProperty(CONTROL_M_URI_STATUS, "/automation-api/run/status/");
        Response actualResponse = service.getJobStatusByRunId(sessionToken, runId);
        Assert.assertEquals(runStatusOutput, actualResponse.asString());
    }

    @Test
    public void testfreeByJobId() {
        stubFor(post(urlPathMatching("/automation-api/run/job/" + jobId + "/free"))
                .withHeader("Content-Type", containing("application/json"))
                .withHeader("Authorization", containing("Bearer 123456789"))
                .willReturn(aResponse()
                        .withStatus(200))
        );
        System.setProperty(CONTROL_M_URI_BASE, HTTP_LOCALHOST + wireMockRule.port());
        System.setProperty(CONTROL_M_URI_FREE, "/automation-api/run/job/%s/free");
        service.freeByJobId(sessionToken, jobId);
        Assert.assertEquals(200, restApiSvc.getStatusCode().intValue());
    }

    @Test
    public void testgetJobOutputByJobId() {
        stubFor(get(urlPathMatching("/automation-api/run/job/" + jobId + "/output"))
                .withHeader("Content-Type", containing("application/json"))
                .withHeader("Authorization", containing("Bearer 123456789"))
                .willReturn(aResponse()
                        .withBody(jobOutput))
        );
        System.setProperty(CONTROL_M_URI_BASE, HTTP_LOCALHOST + wireMockRule.port());
        System.setProperty(CONTROL_M_URI_OUTPUT, "/automation-api/run/job/%s/output");
        Response actualResponse = service.getJobOutputByJobId(sessionToken, jobId);
        Assert.assertEquals(jobOutput, actualResponse.asString());
    }


    @Test
    public void testGetJobLogDetailsByJobId() {
        stubFor(get(urlPathMatching("/automation-api/run/job/" + jobId + "/log"))
                .withHeader("Content-Type", containing("application/json"))
                .withHeader("Authorization", containing("Bearer 123456789"))
                .willReturn(aResponse()
                        .withBody(jobLog))
        );
        System.setProperty(CONTROL_M_URI_BASE, HTTP_LOCALHOST + wireMockRule.port());
        System.setProperty(CONTROL_M_URI_LOG, "/automation-api/run/job/%s/log");
        Response actualResponse = service.getJobLogDetailsByJobId(sessionToken, jobId);
        Assert.assertEquals(jobLog, actualResponse.asString());
    }

}


