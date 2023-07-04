package com.eastspring.tom.cart.dmp.steps;

import com.eastspring.tom.cart.core.CartException;
import com.eastspring.tom.cart.core.CartExceptionType;
import com.eastspring.tom.cart.core.svc.ControlMSvc;
import com.eastspring.tom.cart.core.svc.RestApiSvc;
import com.eastspring.tom.cart.core.svc.StateSvc;
import com.eastspring.tom.cart.core.svc.ThreadSvc;
import com.eastspring.tom.cart.core.utl.AwaitilityUtil;
import com.eastspring.tom.cart.core.utl.ScenarioUtil;
import com.eastspring.tom.cart.dmp.utl.DmpGsWorkflowUtl;
import com.google.common.base.Strings;
import io.restassured.response.Response;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;

import java.io.File;
import java.util.HashMap;
import java.util.Map;
import java.util.concurrent.Callable;

public class ControlMServiceSteps {

    private static final Logger LOGGER = LoggerFactory.getLogger(ControlMServiceSteps.class);
    private static final String UNABLE_TO_CREATE_SESSION_WITH_DEFAULT_CREDENTIALS = "Unable to create Session with default credentials";
    private static final String CTM = "ctm";
    private static final String FOLDER = "folder";
    private static final String HOLD = "hold";
    private static final String IGNORE_CRITERIA = "ignoreCriteria";
    private static final String INDEPENDENT_FLOW = "independentFlow";
    private static final String TRUE = "true";
    private static final String RUN_ID = "runId";
    private static final String PARENT_FOLDER = "parentFolder";
    private static final String ENDED_OK = "ENDED OK.";
    private static final String ENDED_NOTOK = "ENDED NOTOK.";
    private static final String JOB_STATE_CHANGED_TO_WAIT_HOST = "Job STATE CHANGED TO Wait Host";
    private static final String JOB_COMPLETED_WITH_STATUS = "Job [{}] completed with status [{}]";

    private static final String CONTROL_M_USER = "controlm.api.default.user";
    private static final String CONTROL_M_PASS = "controlm.api.default.pass";
    private static final String CONTROL_M_SERVER = "controlm.api.server";

    private static final String ORDER_FILE_JSON_PATH = "tests/test-data/ControlM/";
    private static final String JSON_BODY_TEMPLATE = "order_job_request_template.txt";
    private static final String JSON_BODY = "order_job_request.json";

    private static final String CONTROLM_SESSION_TOKEN_VAR = "controlm.session.token";

    @Autowired
    private RestApiSvc restApiSvc;

    @Autowired
    private StateSvc stateSvc;

    @Autowired
    private ControlMSvc controlMSvc;

    @Autowired
    private ThreadSvc threadSvc;

    @Autowired
    private DmpGsWorkflowUtl dmpGsWorkflowUtl;

    @Autowired
    private AwaitilityUtil awaitilityUtil;

    @Autowired
    private ScenarioUtil scenarioUtil;

    /**
     * The given method will create control-M api session with default parameters.
     */
    public void createSession() {
        LOGGER.debug("Creating ControlM session with default credentials");
        createSession(stateSvc.getStringVar(CONTROL_M_USER), stateSvc.getStringVar(CONTROL_M_PASS));
    }

    /**
     * Create a control M API session.
     *
     * @param username the username
     * @param password the password
     */
    public void createSession(String username, String password) {
        LOGGER.debug("Creating ControlM session with username [{}] and password [{}]", username, "*******");

        final Response session = controlMSvc.createApiSession(username, password);
        final String token = (String) restApiSvc.getObjectFromResponse(session, "token");

        if (Strings.isNullOrEmpty(token)) {
            LOGGER.error(UNABLE_TO_CREATE_SESSION_WITH_DEFAULT_CREDENTIALS);
            throw new CartException(CartExceptionType.VALIDATION_FAILED, UNABLE_TO_CREATE_SESSION_WITH_DEFAULT_CREDENTIALS);
        }
        stateSvc.setStringVar(CONTROLM_SESSION_TOKEN_VAR, token);
    }

    /**
     * The given method will create order job using session and json body with order body params.
     *
     * @param session   this will provide the valid session for create order
     * @param bodyParam this will hold the json body which required to create the order
     */
    private void orderControlMEntity(String session, File bodyParam) {
        final Response response = controlMSvc.orderJob(session, bodyParam);

        scenarioUtil.write(response.asString());

        final String runId = (String) restApiSvc.getObjectFromResponse(response, RUN_ID);

        if (Strings.isNullOrEmpty(runId)) {
            LOGGER.error("Unable to fetch runID after ordering ControlM Entity");
            throw new CartException(CartExceptionType.VALIDATION_FAILED, "Unable to fetch runID after ordering ControlM Entity");
        }
        stateSvc.setStringVar(RUN_ID, runId);
    }

    /*
    This function is generates order request file from the template.
     */
    private File generateOrderJsonFile(Map<String, String> orderParams) {
        final String testDataFilePath = ORDER_FILE_JSON_PATH + JSON_BODY;
        final String templateFilePath = ORDER_FILE_JSON_PATH + JSON_BODY_TEMPLATE;

        stateSvc.setStringVar(CTM, stateSvc.getStringVar(CONTROL_M_SERVER));
        stateSvc.setStringVar(FOLDER, orderParams.get(PARENT_FOLDER));
        stateSvc.setStringVar(HOLD, orderParams.getOrDefault(HOLD, TRUE));
        stateSvc.setStringVar(IGNORE_CRITERIA, orderParams.getOrDefault(IGNORE_CRITERIA, TRUE));
        stateSvc.setStringVar(INDEPENDENT_FLOW, orderParams.getOrDefault(INDEPENDENT_FLOW, TRUE));

        dmpGsWorkflowUtl.changePatternsInTemplateAndCreateNewFile(testDataFilePath, templateFilePath, new HashMap<>());
        return new File(testDataFilePath);
    }

    /**
     * Order control m folder.
     *
     * @param folderRelativePath the folder relative path
     * @param orderParams        the order params
     */
    public void orderControlMFolder(String folderRelativePath, Map<String, String> orderParams) {
        LOGGER.debug("Order ControlM folder [{}]", folderRelativePath);

        final String token = stateSvc.getStringVar(CONTROLM_SESSION_TOKEN_VAR);

        String[] folderPath = stateSvc.expandVar(folderRelativePath).split("/");
        orderParams.put(PARENT_FOLDER, folderPath[0].trim());

        final File payload = generateOrderJsonFile(orderParams);
        orderControlMEntity(token, payload);

        controlMSvc.retainSubFolderFromOrderedList(token, stateSvc.getStringVar(RUN_ID), folderRelativePath);
    }

    /**
     * Order control m job.
     *
     * @param jobRelativePath the job relative path
     * @param orderParams     the order params
     */
    public void orderControlMJob(String jobRelativePath, Map<String, String> orderParams) {
        LOGGER.debug("Order ControlM job [{}]", jobRelativePath);

        final String token = stateSvc.getStringVar(CONTROLM_SESSION_TOKEN_VAR);

        String[] jobPath = stateSvc.expandVar(jobRelativePath).split("/");
        orderParams.put(PARENT_FOLDER, jobPath[0].trim());

        final File payload = generateOrderJsonFile(orderParams);

        orderControlMEntity(token, payload);

        controlMSvc.retainJobFromOrderedList(token, stateSvc.getStringVar(RUN_ID), jobPath[jobPath.length - 1].trim());
    }

    /**
     * Once the job/subfolder ordered, this method will free the ordered job/subfolder.
     * Assumption is runId must be captured before calling this function.
     */
    public void freeOrderedEntity() {
        threadSvc.sleepSeconds(2);

        final String runID = stateSvc.getStringVar(RUN_ID);
        LOGGER.debug("Getting job status for run id [{}]", runID);

        Response result = controlMSvc.getJobStatusByRunId(stateSvc.getStringVar(CONTROLM_SESSION_TOKEN_VAR), runID);
        final String jobId = (String) restApiSvc.getObjectFromResponse(result, "statuses[0].jobId");

        if (Strings.isNullOrEmpty(jobId)) {
            LOGGER.error("Cannot free job/folder with Empty or Null jobID");
            throw new CartException(CartExceptionType.VALIDATION_FAILED, "Cannot free job/folder with Empty or Null jobID");
        }
        controlMSvc.freeByJobId(stateSvc.getStringVar(CONTROLM_SESSION_TOKEN_VAR), jobId);
    }


    /**
     * Check the job status untill the time limit specified
     * This function uses recursion logic to verify JOB status PASS|FAILED.
     * If FAILED, then throws errors and halt code
     *
     * @param maxWaitTimeInSeconds the time limit set in seconds for verification
     */
    public void waitTillJobStatusEndedOK(int maxWaitTimeInSeconds) {
        final String token = stateSvc.getStringVar(CONTROLM_SESSION_TOKEN_VAR);

        threadSvc.sleepSeconds(2);

        Response res = controlMSvc.getJobStatusByRunId(token, stateSvc.getStringVar(RUN_ID));
        int statuses = (int) this.restApiSvc.getObjectFromResponse(res, "statuses.size");

        String jobId;
        String name;
        String type;
        boolean isDeleted;

        for (int i = 0; i < statuses; i++) {
            jobId = (String) restApiSvc.getObjectFromResponse(res, "statuses[" + i + "].jobId");
            name = (String) restApiSvc.getObjectFromResponse(res, "statuses[" + i + "].name");
            type = (String) this.restApiSvc.getObjectFromResponse(res, "statuses[" + i + "].type");
            isDeleted = (Boolean) this.restApiSvc.getObjectFromResponse(res, "statuses[" + i + "].deleted");

            if (!type.contains("Sub-Table") && !type.contains("Folder") && !isDeleted) {

                final String jobName = name;
                final String jobIdentifier = jobId;

                Callable<Boolean> condition = () -> {
                    threadSvc.sleepSeconds(2);
                    final Response result = controlMSvc.getJobLogDetailsByJobId(token, jobIdentifier);
                    scenarioUtil.write(result.asString());

                    if (result.asString().contains(ENDED_OK)) {
                        LOGGER.info(JOB_COMPLETED_WITH_STATUS, jobName, ENDED_OK);
                        return true;
                    } else if (result.asString().contains(ENDED_NOTOK)) {
                        LOGGER.error(JOB_COMPLETED_WITH_STATUS, jobName, ENDED_NOTOK);
                        throw new CartException(CartExceptionType.VERIFICATION_FAILED, JOB_COMPLETED_WITH_STATUS, jobName, ENDED_NOTOK);
                    } else if (result.asString().contains(JOB_STATE_CHANGED_TO_WAIT_HOST)) {
                        LOGGER.error(JOB_COMPLETED_WITH_STATUS, jobName, JOB_STATE_CHANGED_TO_WAIT_HOST);
                        throw new CartException(CartExceptionType.VERIFICATION_FAILED, JOB_COMPLETED_WITH_STATUS, jobName, JOB_STATE_CHANGED_TO_WAIT_HOST);
                    }
                    return false;
                };

                if (!awaitilityUtil.waitUntil(condition, maxWaitTimeInSeconds)) {
                    LOGGER.error("JOB [{}] status has not ENDED OK", jobName);
                    throw new CartException(CartExceptionType.VERIFICATION_FAILED, "JOB [{}] status has not ENDED OK", jobName);
                }
            }
        }
    }


    /**
     * Check the job status until the time limit specified
     * This function uses recursion logic to verify JOB status PASS|FAILED.
     * If PASSED, then throws errors and halt code
     *
     * @param maxWaitTimeInSeconds the time limit set in seconds for verification
     */
    public void waitTillJobStatusEndedNOTOK(int maxWaitTimeInSeconds) {
        final String token = stateSvc.getStringVar(CONTROLM_SESSION_TOKEN_VAR);

        threadSvc.sleepSeconds(2);

        Response res = controlMSvc.getJobStatusByRunId(token, stateSvc.getStringVar(RUN_ID));
        int statuses = (int) this.restApiSvc.getObjectFromResponse(res, "statuses.size");

        String jobId;
        String name;
        String type;
        boolean isDeleted;

        for (int i = 0; i < statuses; i++) {
            jobId = (String) restApiSvc.getObjectFromResponse(res, "statuses[" + i + "].jobId");
            name = (String) restApiSvc.getObjectFromResponse(res, "statuses[" + i + "].name");
            type = (String) this.restApiSvc.getObjectFromResponse(res, "statuses[" + i + "].type");
            isDeleted = (Boolean) this.restApiSvc.getObjectFromResponse(res, "statuses[" + i + "].deleted");

            if (!type.contains("Sub-Table") && !type.contains("Folder") && !isDeleted) {

                final String jobName = name;
                final String jobIdentifier = jobId;

                final Callable<Boolean> condition = () -> {
                    threadSvc.sleepSeconds(2);
                    final Response result = controlMSvc.getJobLogDetailsByJobId(token, jobIdentifier);
                    scenarioUtil.write("Job Log:");
                    scenarioUtil.write(result.asString());

                    if (result.asString().contains(ENDED_NOTOK)) {
                        LOGGER.info(JOB_COMPLETED_WITH_STATUS, jobName, ENDED_NOTOK);
                        return true;
                    } else if (result.asString().contains(ENDED_OK)) {
                        LOGGER.error(JOB_COMPLETED_WITH_STATUS, jobName, ENDED_OK);
                        throw new CartException(CartExceptionType.VERIFICATION_FAILED, JOB_COMPLETED_WITH_STATUS, jobName, ENDED_OK);
                    } else if (result.asString().contains(JOB_STATE_CHANGED_TO_WAIT_HOST)) {
                        LOGGER.error(JOB_COMPLETED_WITH_STATUS, jobName, JOB_STATE_CHANGED_TO_WAIT_HOST);
                        throw new CartException(CartExceptionType.VERIFICATION_FAILED, JOB_COMPLETED_WITH_STATUS, jobName, JOB_STATE_CHANGED_TO_WAIT_HOST);
                    }
                    return false;
                };

                if (!awaitilityUtil.waitUntil(condition, maxWaitTimeInSeconds)) {
                    LOGGER.error("JOB [{}] status has not ENDED NOTOK", jobName);
                    throw new CartException(CartExceptionType.VERIFICATION_FAILED, "JOB [{}] status has not ENDED NOTOK", jobName);
                }
            }
        }
    }


}
