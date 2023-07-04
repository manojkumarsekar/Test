package com.eastspring.tom.cart.core.svc;

import com.eastspring.tom.cart.core.CartException;
import com.eastspring.tom.cart.core.CartExceptionType;
import com.eastspring.tom.cart.core.mdl.*;
import com.eastspring.tom.cart.core.utl.FormatterUtil;
import com.google.common.base.Strings;
import io.restassured.RestAssured;
import io.restassured.response.Response;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;

import java.io.File;
import java.util.*;
import java.util.stream.Collectors;

public class ControlMSvc {

    private static final Logger LOGGER = LoggerFactory.getLogger(ControlMSvc.class);

    private static final String JOB_PREFIX = "5701 JOB '";
    private static final String SUBFOLDER_PREFIX = "5701 Sub folder '";
    private static final String PARSING_FAILED_UNKNOWN_CONTROL_M_OUTPUT_LINE = "Parsing failed: Unknown Control-M output line: [{}]";
    private static final String ORDERNO = ", orderno='";
    private static final String PARSING_FAILED_UNABLE_TO_LOCATE_ORDERID = "parsing failed, unable to locate orderid";
    public static final String PARSE_FAILED_LINE_MUST_NOT_BE_NULL = "parse failed, line must not be null";

    private static final String CONTROL_M_URI_BASE = "controlm.api.uri.base";
    private static final String CONTROL_M_URI_LOGIN = "controlm.api.uri.endpoint.login";
    private static final String CONTROL_M_URI_ORDER = "controlm.api.uri.endpoint.order";
    private static final String CONTROL_M_URI_STATUS = "controlm.api.uri.endpoint.status";
    private static final String CONTROL_M_URI_FREE = "controlm.api.uri.endpoint.free";
    private static final String CONTROL_M_URI_DELETE = "controlm.api.uri.endpoint.delete";
    private static final String CONTROL_M_URI_OUTPUT = "controlm.api.uri.endpoint.output";
    private static final String CONTROL_M_URI_LOG = "controlm.api.uri.endpoint.log";

    private static final String CONTENT_TYPE = "Content-Type";
    private static final String APPLICATION_JSON = "application/json";
    private static final String AUTHORIZATION = "Authorization";

    private static final String SESSION_BODY = "{" +
            "\"username\": \"%s\", " +
            "\"password\": \"%s\" " +
            "}";
    private static final String PLEASE_SET_BEFORE_CALLING_CONTROL_M_API_TEST_CASES = "Please set [{}] before calling ControlM Api test cases";

    @Autowired
    private FormatterUtil formatterUtil;

    @Autowired
    private RuntimeRemoteSvc runtimeRemoteSvc;

    @Autowired
    private StateSvc stateSvc;

    @Autowired
    private RestApiSvc restApiSvc;


    public String getTodayOdate() {
        return formatterUtil.format("%1$tY%1$tm%1$td", Calendar.getInstance().getTime());
    }

    /**
     * <p>This method parses a single output line from Control-M CTMORDER command.</p>
     *
     * @param line the line, sequence of characters
     * @return a @{@link ControlMOutputLine} object representing the output line
     */
    public ControlMOutputLine parseOutputLine(final String line) {
        if (line == null) {
            LOGGER.error(PARSE_FAILED_LINE_MUST_NOT_BE_NULL);
            throw new CartException(CartExceptionType.PROCESSING_FAILED, PARSE_FAILED_LINE_MUST_NOT_BE_NULL);
        } else if (line.startsWith(JOB_PREFIX)) {
            int startOfJobFullpath = JOB_PREFIX.length();
            int endOfJobFullpath = line.indexOf('\'', startOfJobFullpath);
            String jobFullpath = line.substring(startOfJobFullpath, endOfJobFullpath);
            List<String> jobPathList = new ArrayList<>(Arrays.asList(jobFullpath.split("/")));
            String jobName = jobPathList.remove(jobPathList.size() - 1);
            String folderName = String.join("/", jobPathList);
            return new ControlMOutputLine(ControlMOutputType.JOB, folderName, jobName, getOrderid(line, endOfJobFullpath));
        } else if (line.startsWith(SUBFOLDER_PREFIX)) {
            int startOfFolderName = SUBFOLDER_PREFIX.length();
            int endOfFolderName = line.indexOf('\'', startOfFolderName);
            String folderName = line.substring(startOfFolderName, endOfFolderName);
            return new ControlMOutputLine(ControlMOutputType.SUBFOLDER, folderName, null, getOrderid(line, endOfFolderName));
        } else {
            LOGGER.error(PARSING_FAILED_UNKNOWN_CONTROL_M_OUTPUT_LINE, line);
            throw new CartException(CartExceptionType.PROCESSING_FAILED, PARSING_FAILED_UNKNOWN_CONTROL_M_OUTPUT_LINE, line);
        }
    }

    /**
     * <p>A helper method to extract the orderid attribute.</p>
     *
     * @param line      the output line
     * @param startFrom offset to start scanning the keyword from
     * @return the orderid string
     */
    private String getOrderid(String line, int startFrom) {
        int startOfOrderid = line.indexOf(ORDERNO, startFrom);
        if (startOfOrderid < 0) {
            LOGGER.error(PARSING_FAILED_UNABLE_TO_LOCATE_ORDERID, line);
            throw new CartException(CartExceptionType.PROCESSING_FAILED, PARSING_FAILED_UNABLE_TO_LOCATE_ORDERID, line);
        } else {
            startOfOrderid += ORDERNO.length();
        }
        int endOfOrderid = line.indexOf('\'', startOfOrderid);
        return line.substring(startOfOrderid, endOfOrderid);
    }

    /**
     * <p>This method segregtes which Control-M CTMORDER results need to be retained and which ones can be killed.</p>
     *
     * @param folder folder name of the job we are going to test (all under need to be retained)
     * @param lines  list of @{@link ControlMOutputLine} object
     * @return @{@link ControlMSegregatedOutputLines} object
     */
    public ControlMSegregatedOutputLines segregateOutputLinesByFolder(String folder, List<ControlMOutputLine> lines) {
        List<ControlMOutputLine> toRetainList = lines.stream()
                .filter(line -> line != null &&
                        ControlMOutputType.JOB.equals(line.getType()) &&
                        (folder.equals(line.getFolderName()) || line.getFolderName().startsWith(folder + "/")))
                .collect(Collectors.toList());
        List<ControlMOutputLine> toKillList = lines.stream()
                .filter(line -> line != null &&
                        ControlMOutputType.JOB.equals(line.getType()) &&
                        !(folder.equals(line.getFolderName()) || line.getFolderName().startsWith(folder + "/")))
                .collect(Collectors.toList());
        return new ControlMSegregatedOutputLines(toRetainList, toKillList);
    }

    public ControlMSegregatedOutputLines getSegregatedOutputFromString(final String folder, final String outputString) {
        String nonNullOutput = outputString != null ? outputString : "";
        String[] splittedString = ("|" + nonNullOutput + "|").split("\\r?\\n", -1);
        splittedString[0] = splittedString[0].substring(1);
        int lastIndex = splittedString.length - 1;
        splittedString[lastIndex] = splittedString[lastIndex].substring(0, splittedString[lastIndex].length() - 1);
        List<String> rows = new ArrayList<>(Arrays.asList(splittedString));
        return segregateOutputLinesByFolder(folder, rows.stream().map(this::parseOutputLine).collect(Collectors.toList()));
    }

    public RemoteOutput runCliControlM(String commandLine) {
        String controlMHost = stateSvc.expandVar("${controlm.host.ssh.host}");
        String controlMPort = stateSvc.expandVar("${controlm.host.ssh.port}");
        int controlMPortNum = Strings.isNullOrEmpty(controlMPort) ? 22 : Integer.parseInt(controlMPort);
        String controlMUser = stateSvc.expandVar("${controlm.host.ssh.user}");
        return runtimeRemoteSvc.sshRemoteExecute(controlMHost, controlMPortNum, controlMUser, "CONTROLM=/opt/controlm/ctm\nLD_LIBRARY_PATH=/opt/controlm/ctm/exe\nexport CONTROLM LD_LIBRARY_PATH\n" + commandLine);
    }

    /*
    Code snippet to get controlm api prop value from map.
     */
    private String getControlMApiPropValue(final String prop) {
        String result = stateSvc.getStringVar(prop);
        if (Strings.isNullOrEmpty(result)) {
            LOGGER.error(PLEASE_SET_BEFORE_CALLING_CONTROL_M_API_TEST_CASES, prop);
            throw new CartException(CartExceptionType.UNDEFINED, PLEASE_SET_BEFORE_CALLING_CONTROL_M_API_TEST_CASES, prop);
        }
        return result;
    }

    /**
     * Create api session.
     *
     * @param username the username
     * @param pass     the pass
     * @return {@link Response}
     */
    public Response createApiSession(String username, String pass) {
        final String body = formatterUtil.format(SESSION_BODY, username, pass);

        RestAssured.useRelaxedHTTPSValidation();
        restApiSvc.setApiBaseUri(getControlMApiPropValue(CONTROL_M_URI_BASE));
        restApiSvc.setApiEndPoint(getControlMApiPropValue(CONTROL_M_URI_LOGIN));
        restApiSvc.setHeaderParams(CONTENT_TYPE, APPLICATION_JSON);
        restApiSvc.setBodyParam(body);
        restApiSvc.sendRequest(RestRequestType.POST);
        return restApiSvc.getResponse();
    }

    /*
    Code snippet to setup session in header params
     */
    private void setupApiSessionHeader(final String session) {
        restApiSvc.setHeaderParams(new HashMap<String, String>() {{
            put(CONTENT_TYPE, APPLICATION_JSON);
            put(AUTHORIZATION, "Bearer " + session);
        }});
    }

    /**
     * Order job or Folder.
     *
     * @param sessionToken      the session token
     * @param jsonOrderBodyFile the json order body file
     * @return {@link Response}
     */
    public Response orderJob(String sessionToken, File jsonOrderBodyFile) {
        try {

            restApiSvc.setApiBaseUri(getControlMApiPropValue(CONTROL_M_URI_BASE));

            restApiSvc.setApiEndPoint(getControlMApiPropValue(CONTROL_M_URI_ORDER));
            setupApiSessionHeader(sessionToken);
            restApiSvc.setBodyParam(jsonOrderBodyFile);
            restApiSvc.sendRequest(RestRequestType.POST);
            return restApiSvc.getResponse();
        } catch (Exception e) {
            LOGGER.error("Caught exception while ordering job", e);
            throw new CartException(CartExceptionType.PROCESSING_FAILED, "Caught exception while ordering job");
        }
    }

    /**
     * Gets job status API Response by RunID.
     *
     * @param sessionToken the session token
     * @param runId        the run id
     * @return {@link Response}
     */
    public Response getJobStatusByRunId(String sessionToken, String runId) {
        try {

            restApiSvc.setApiBaseUri(getControlMApiPropValue(CONTROL_M_URI_BASE));

            restApiSvc.setApiEndPoint(getControlMApiPropValue(CONTROL_M_URI_STATUS) + runId + "?startIndex=0");
            setupApiSessionHeader(sessionToken);
            restApiSvc.sendRequest(RestRequestType.GET);
            return restApiSvc.getResponse();
        } catch (Exception e) {
            LOGGER.error("Caught exception while getting job status by run id [{}]", runId, e);
            throw new CartException(CartExceptionType.PROCESSING_FAILED, "Caught exception while getting job status by run id [{}]", runId);
        }
    }


    /**
     * Delete the ordered job by ID.
     *
     * @param sessionToken the session token
     * @param jobId        the job Id
     */
    private void deleteByJobId(String sessionToken, String jobId) {
        try {
            final String deleteEndPoint = formatterUtil.format(getControlMApiPropValue(CONTROL_M_URI_DELETE), jobId);

            restApiSvc.setApiBaseUri(getControlMApiPropValue(CONTROL_M_URI_BASE));

            restApiSvc.setApiEndPoint(deleteEndPoint);
            setupApiSessionHeader(sessionToken);
            restApiSvc.sendRequest(RestRequestType.POST);
        } catch (Exception e) {
            LOGGER.error("Caught exception during delete by job id [{}]", jobId, e);
            throw new CartException(CartExceptionType.PROCESSING_FAILED, "Caught exception during delete by job id [{}]", jobId);
        }
    }

    /**
     * Retain job.
     * This is a workaround to retain only the job which is ordered due to ControlM API known bug.
     * Once the bug is fixed, we need to refactor this function.
     *
     * @param sessionToken the session token
     * @param runId        the run id
     * @param jobName      the job name
     */
    public void retainJobFromOrderedList(String sessionToken, String runId, String jobName) {
        Response responseByRunID = getJobStatusByRunId(sessionToken, runId);

        int statuses = (int) restApiSvc.getObjectFromResponse(responseByRunID, "statuses.size");

        for (int i = 0; i < statuses; i++) {
            String jobId = (String) restApiSvc.getObjectFromResponse(responseByRunID, "statuses[" + i + "].jobId");
            String type = (String) restApiSvc.getObjectFromResponse(responseByRunID, "statuses[" + i + "].type");
            String name = (String) restApiSvc.getObjectFromResponse(responseByRunID, "statuses[" + i + "].name");

            if (!type.contains("Sub-Table") && !type.contains("Folder") &&
                    !name.contains(jobName)
                    ) {
                deleteByJobId(sessionToken, jobId);
            }
        }
    }

    /**
     * Retain sub folder from ordered list.
     *
     * @param sessionToken the session token
     * @param runId        the run id
     * @param subFolder    the sub folder
     */
    public void retainSubFolderFromOrderedList(String sessionToken, String runId, String subFolder) {
        Response responseByRunID = getJobStatusByRunId(sessionToken, runId);
        int statuses = (int) restApiSvc.getObjectFromResponse(responseByRunID, "statuses.size");

        for (int i = 0; i < statuses; i++) {
            String jobId = (String) restApiSvc.getObjectFromResponse(responseByRunID, "statuses[" + i + "].jobId");
            String type = (String) restApiSvc.getObjectFromResponse(responseByRunID, "statuses[" + i + "].type");
            String folder = (String) restApiSvc.getObjectFromResponse(responseByRunID, "statuses[" + i + "].folder");

            if (!type.contains("Sub-Table") && !type.contains("Folder") &&
                    !folder.contains(subFolder)
                    ) {
                deleteByJobId(sessionToken, jobId);
            }
        }
    }

    /**
     * Free by job id.
     *
     * @param sessionToken the session token
     * @param jobId        the job id
     */
    public void freeByJobId(String sessionToken, String jobId) {
        try {
            final String freeEndPoint = formatterUtil.format(getControlMApiPropValue(CONTROL_M_URI_FREE), jobId);

            restApiSvc.setApiBaseUri(getControlMApiPropValue(CONTROL_M_URI_BASE));

            restApiSvc.setApiEndPoint(freeEndPoint);
            setupApiSessionHeader(sessionToken);
            restApiSvc.sendRequest(RestRequestType.POST);
        } catch (Exception e) {
            LOGGER.error("Caught exception during free by job id [{}]", jobId, e);
            throw new CartException(CartExceptionType.PROCESSING_FAILED, "Caught exception during free by job id [{}]", jobId);
        }
    }

    /**
     * Gets job output by job id.
     *
     * @param sessionToken the session token
     * @param jobId        the job id
     * @return {@link Response}
     */
    public Response getJobOutputByJobId(String sessionToken, String jobId) {
        try {
            final String outputEndPoint = formatterUtil.format(getControlMApiPropValue(CONTROL_M_URI_OUTPUT), jobId);

            restApiSvc.setApiBaseUri(getControlMApiPropValue(CONTROL_M_URI_BASE));

            restApiSvc.setApiEndPoint(outputEndPoint);

            restApiSvc.setEndPointParamsVar(new HashMap<String, String>() {{
                put("runNo", "0");
            }});
            setupApiSessionHeader(sessionToken);
            restApiSvc.sendRequest(RestRequestType.GET);
            return restApiSvc.getResponse();
        } catch (Exception e) {
            LOGGER.error("Caught exception during getting output by job id [{}]", jobId, e);
            throw new CartException(CartExceptionType.PROCESSING_FAILED, "Caught exception during getting output job id [{}]", jobId);
        }
    }


    /**
     * Gets job log details.
     *
     * @param sessionToken the session token
     * @param jobId        the job id
     * @return {@link Response}
     */
    public Response getJobLogDetailsByJobId(String sessionToken, String jobId) {
        try {
            final String logEndPoint = formatterUtil.format(getControlMApiPropValue(CONTROL_M_URI_LOG), jobId);

            restApiSvc.setApiBaseUri(getControlMApiPropValue(CONTROL_M_URI_BASE));
            restApiSvc.setApiEndPoint(logEndPoint);

            restApiSvc.setEndPointParamsVar(new HashMap<String, String>() {{
                put("runNo", "0");
            }});
            setupApiSessionHeader(sessionToken);
            restApiSvc.sendRequest(RestRequestType.GET);
            return restApiSvc.getResponse();
        } catch (Exception e) {
            LOGGER.error("Caught exception during getting log by job id [{}]", jobId, e);
            throw new CartException(CartExceptionType.PROCESSING_FAILED, "Caught exception during getting log job id [{}]", jobId);
        }
    }
}
