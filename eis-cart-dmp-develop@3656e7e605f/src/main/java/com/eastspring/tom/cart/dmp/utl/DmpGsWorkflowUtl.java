package com.eastspring.tom.cart.dmp.utl;

import com.eastspring.tom.cart.core.CartException;
import com.eastspring.tom.cart.core.CartExceptionType;
import com.eastspring.tom.cart.core.steps.DatabaseSteps;
import com.eastspring.tom.cart.core.svc.DatabaseSvc;
import com.eastspring.tom.cart.core.svc.ExcelFileSvc;
import com.eastspring.tom.cart.core.svc.FileDirSvc;
import com.eastspring.tom.cart.core.svc.FmTemplateSvc;
import com.eastspring.tom.cart.core.svc.StatePropertiesSvc;
import com.eastspring.tom.cart.core.svc.StateSvc;
import com.eastspring.tom.cart.core.svc.ThreadSvc;
import com.eastspring.tom.cart.core.svc.WorkspaceDirSvc;
import com.eastspring.tom.cart.core.svc.XmlSvc;
import com.eastspring.tom.cart.core.utl.DataTableUtil;
import com.eastspring.tom.cart.core.utl.DateTimeUtil;
import com.eastspring.tom.cart.core.utl.FileDirUtil;
import com.eastspring.tom.cart.core.utl.FormatterUtil;
import com.eastspring.tom.cart.core.utl.ScenarioUtil;
import com.eastspring.tom.cart.core.utl.WorkspaceUtil;
import com.eastspring.tom.cart.core.utl.XPathUtil;
import com.eastspring.tom.cart.core.utl.XmlUtil;
import com.eastspring.tom.cart.dmp.steps.DmpGsWorkflowSteps;
import com.eastspring.tom.cart.dmp.svc.DmpWorkflowContext;
import com.eastspring.tom.cart.dmp.svc.DmpWorkflowSvc;
import com.google.common.base.Strings;
import freemarker.template.Template;
import org.apache.commons.io.FileUtils;
import org.apache.commons.io.FilenameUtils;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;

import java.io.BufferedWriter;
import java.io.File;
import java.io.FileWriter;
import java.util.Arrays;
import java.util.Collections;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;
import java.util.Set;
import java.util.stream.Collectors;

import static com.eastspring.tom.cart.dmp.mdl.WorkflowSpec.WORKFLOW_CHECK_SQL;

public class DmpGsWorkflowUtl {

    private static final Logger LOGGER = LoggerFactory.getLogger(DmpGsWorkflowSteps.class);
    private static final String DATA_ROW_ERROR_MSG = "data Row should be Greater than Equal to 2 as Header row starts from 1";
    public static final String GSWF_TEMPLATE_PARAM_PREFIX = "gs.wf.template.param";
    private static final String UTF_8 = "UTF-8";
    public static final String XPATH_FLOW_RESULT_XPATH = "//*[local-name() = 'flowResultId']";
    private static final String INBOUND_PATH = "INBOUND_PATH";
    private static final String ARCHIVE_PATH = "ARCHIVE_PATH";
    private static final String OUTBOUND_PATH = "OUTBOUND_PATH";

    private static final String DMP_SSH_INBOUND_PATH = "dmp.ssh.inbound.path";
    private static final String DMP_SSH_ARCHIVE_PATH = "dmp.ssh.archive.path";
    private static final String DMP_SSH_OUTBOUND_PATH = "dmp.ssh.outbound.path";
    private static final String DONE = "DONE";
    private static final String RESPONSE_FILE_IS_NOT_CREATED = "Response file is not created [{}]";
    private static final String UNABLE_TO_RETRIEVE_FLOW_RESULT_ID_FROM_XML_RESPONSE = "Unable to retrieve flowResultId from Xml response [{}]";
    private static final String FLOW_RESULT_ID = "flowResultId";
    public static final String WF_RUNTIME_STAT_TYP = "WF_RUNTIME_STAT_TYP";
    private static final String WORKFLOW_WITH_INSTANCE_ID_IS_FAILED = "Workflow with instance id [{}] is FAILED!!!";
    private static final String FAILED = "FAILED";
    private static final String GOLDENPRICE_WORKFLOW_IDENTIFICATION = "even:RaiseEIS_PricingProcessConsolidatedAsynchron";
    private static final String REUTERSDSSWRAPPER_WORKFLOW_IDENTIFICATION = "even:RaiseEIS_ReutersDSSWrapperAsynchron";

    private static final List<String> FLAT_FILE_TYPES = Arrays.asList("out", "csv", "xml", "qqq", "txt", "json");

    public static final String WORKFLOW_PUB_DESCRIPTION_QUERY = "SELECT PUB_DESCRIPTION FROM ft_cfg_pub1 WHERE pub1_oid = ( SELECT substr(variable_val_txt,3) FROM ft_wf_wfrv WHERE variable_id = '%s' AND variable_nme = 'pub1OID')";
    private static final String WORKFLOW_STACK_TRACE_ERROR = "select wfti.runtime_info_blob from ft_wf_wfri wfri, ft_wf_tokn tokn, ft_wf_wfti wfti where wfri.instance_id = tokn.instance_id and tokn.token_id = wfti.token_id\n" +
            "and wfri.instance_id = '%s' and wfti.row_seq_num = 0";

    private static final String GC_PRICING_INSTR_ID_QUERY = " select LISTAGG (instr_id,';') WITHIN GROUP (ORDER BY instr_id) instr_id from FT_T_ISID\n" +
            "     where iss_id in (%s) \n" +
            "     and end_tms is null";

    private static final String BASE_NTEL_QUERY = "SELECT COUNT(*) AS CNT FROM FT_T_NTEL NTEL JOIN FT_T_TRID TRID " +
            "ON NTEL.LAST_CHG_TRN_ID=TRID.TRN_ID " +
            "WHERE TRID.JOB_ID=";

    private static final String JOB_ID = "JOB_ID";
    private static final String JOBD_ID_EMPTY_WARNING = "job id is empty, please ensure JOB_ID variable is set before executing NTEL query";
    public static final String EVEN_INSTRUMENTS = "even:Instruments";
    private static final String EVEN_ISSUE_GROUP = "even:IssueGroup";
    public static final String EVEN_POSITIONS_SOURCE = "even:PositionsSource";
    private static final String EVEN_PRICEPOINTEVENTDEFINITIONID = "even:PricePointEventDefinitionId";
    private static final String INSTRUMENTS = "INSTRUMENTS";
    private static final String POSITIONS_SOURCE = "POSITIONS_SOURCE";

    @Autowired
    private StateSvc stateSvc;

    @Autowired
    private StatePropertiesSvc statePropertiesSvc;

    @Autowired
    private DateTimeUtil dateTimeUtil;

    @Autowired
    private XmlUtil xmlUtil;

    @Autowired
    private XPathUtil xPathUtil;

    @Autowired
    private ExcelFileSvc excelFileSvc;

    @Autowired
    private FileDirUtil fileDirUtil;

    @Autowired
    private FileDirSvc fileDirSvc;

    @Autowired
    private FmTemplateSvc fmTemplateSvc;

    @Autowired
    private DmpWorkflowSvc dmpWorkflowSvc;

    @Autowired
    private DmpFileHandlingUtl dmpFileHandlingUtl;

    @Autowired
    private ThreadSvc threadSvc;

    @Autowired
    private XmlSvc xmlSvc;

    @Autowired
    private DataTableUtil dataTableUtil;

    @Autowired
    private DatabaseSvc databaseSvc;

    @Autowired
    private WorkspaceUtil workspaceUtil;

    @Autowired
    private WorkspaceDirSvc workspaceDirSvc;

    @Autowired
    private DatabaseSteps databaseSteps;

    @Autowired
    private ScenarioUtil scenarioUtil;

    @Autowired
    private FormatterUtil formatterUtil;


    public void setTemplateParam(String paramName, String paramValue) {
        stateSvc.setStringVar(GSWF_TEMPLATE_PARAM_PREFIX + "." + paramName, stateSvc.expandVar(paramValue));
    }

    public void processWorkFlowRequest(String templateFile, String responseFile, Map<String, String> templateParamsMap) {
        constructTemplateParamsFromMap(templateParamsMap);
        sendWebServiceRequestUsingTemplateFile(templateFile, responseFile, templateParamsMap);
    }

    /**
     * Clear all template params.
     * Calling this function before setting new template params is required because, it will flush out all the existing template variables.
     */
    public void clearAllTemplateParams() {
        Map<String, String> templateParams = stateSvc.getValueStringMapFromPrefix(GSWF_TEMPLATE_PARAM_PREFIX, true);
        for (String key : templateParams.keySet()) {
            stateSvc.removeStringVar(GSWF_TEMPLATE_PARAM_PREFIX + "." + key);
        }
    }

    private void constructTemplateParamsFromMap(final Map<String, String> templateParamsMap) {
        for (String key : templateParamsMap.keySet()) {
            setTemplateParam(key, templateParamsMap.get(key));
        }

        setTemplateParam(INBOUND_PATH, stateSvc.getStringVar(DMP_SSH_INBOUND_PATH));
        setTemplateParam(ARCHIVE_PATH, stateSvc.getStringVar(DMP_SSH_ARCHIVE_PATH));
        setTemplateParam(OUTBOUND_PATH, stateSvc.getStringVar(DMP_SSH_OUTBOUND_PATH));

        Map<String, String> defaultParams = statePropertiesSvc.getGlobalMapValueFromPrefix(GSWF_TEMPLATE_PARAM_PREFIX, true);

        LOGGER.debug("Setting default template values as per tomcart-private.properties");
        String actualKey;
        for (String key : defaultParams.keySet()) {
            actualKey = key.replace(GSWF_TEMPLATE_PARAM_PREFIX + ".", "");
            if (!templateParamsMap.containsKey(actualKey)) {
                this.setTemplateParam(actualKey, defaultParams.get(key));
            }
        }
    }

    private void insertGoldenPriceWorkflowDynamicInstrIds(List<String> instrIds, String xmlPath) {
        LOGGER.debug("Writing GoldenPrice Consolidated workflow with Dynamic instrIds {}", instrIds);
        xmlUtil.transformDocToFile(xmlUtil.removeElementByTag(xmlPath, EVEN_INSTRUMENTS, 0), xmlPath);
        xmlUtil.transformDocToFile(xmlUtil.insertNewElements(xmlPath, EVEN_ISSUE_GROUP, EVEN_INSTRUMENTS, instrIds), xmlPath);
    }

    private void insertReutersWorkflowDynamicPositions(List<String> positionsSource, String xmlPath) {
        LOGGER.debug("Writing Reuters Consolidated workflow with Dynamic positionsSource {}", positionsSource);
        xmlUtil.transformDocToFile(xmlUtil.removeElementByTag(xmlPath, EVEN_POSITIONS_SOURCE, 0), xmlPath);
        xmlUtil.transformDocToFile(xmlUtil.insertNewElements(xmlPath, EVEN_PRICEPOINTEVENTDEFINITIONID, EVEN_POSITIONS_SOURCE, positionsSource), xmlPath);
    }

    //TODO This function needs to be refactored when the conditions for Dynamic values grows
    public void modifyWorkflowXmlWithDynamicValues(final String xmlPath, final Map<String, String> templateParamsMap) {
        final List<String> goldenPriceWorkflow = xmlSvc.extractValueFromXmlFileUsingTagName(xmlPath, GOLDENPRICE_WORKFLOW_IDENTIFICATION);
        if (goldenPriceWorkflow.size() >= 1) {
            final String instruments = stateSvc.expandVar(templateParamsMap.get(INSTRUMENTS));
            if (!Strings.isNullOrEmpty(instruments)) {
                final List<String> instrIds = fetchDBValuesIntoListByCsvString(instruments, GC_PRICING_INSTR_ID_QUERY);
                insertGoldenPriceWorkflowDynamicInstrIds(instrIds, xmlPath);
                return;
            }
        }
        final List<String> reutersDSSWrapper = xmlSvc.extractValueFromXmlFileUsingTagName(xmlPath, REUTERSDSSWRAPPER_WORKFLOW_IDENTIFICATION);
        if (reutersDSSWrapper.size() >= 1) {
            final String position = stateSvc.expandVar(templateParamsMap.get(POSITIONS_SOURCE));
            if (!Strings.isNullOrEmpty(position)) {
                List<String> positionsSource = Arrays.stream(position.split(";"))
                        .map(String::trim)
                        .collect(Collectors.toList());
                insertReutersWorkflowDynamicPositions(positionsSource, xmlPath);
                return;
            }
        }
    }

    private List<String> fetchDBValuesIntoListByCsvString(String csvString, String sqlToFetchList) {
        final String inConditionValues = Arrays.stream(stateSvc.expandVar(csvString).split(","))
                .map(String::trim)
                .collect(Collectors.joining("','", "'", "'"));

        final String formattedQuery = formatterUtil.format(sqlToFetchList, inConditionValues);
        final String sqlOutput = databaseSvc.executeSingleValueQueryOnNamedConnection(formattedQuery);
        return Arrays.stream(sqlOutput.split(";"))
                .map(String::trim)
                .collect(Collectors.toList());
    }

    public synchronized void sendWebServiceRequestUsingTemplateFile(String templateFile, String responseFile, Map<String, String> templateParamsMap) {
        String evidenceDir = fileDirSvc.createTestEvidenceSubDir("/gswf");
        LOGGER.debug("evidenceDir: [{}]", evidenceDir);

        FileDirSvc.FileDir fileDir = fileDirSvc.decomposePath(templateFile);
        fmTemplateSvc.setTemplateLocation(fileDir.getDir());

        Map<String, String> valueMap = stateSvc.getValueStringMapFromPrefix(GSWF_TEMPLATE_PARAM_PREFIX, true);
        String outFilename;
        try {
            String file = fileDir.getFile();
            Template template = fmTemplateSvc.getTemplate(file);
            outFilename = evidenceDir + "/request1.xml";
            BufferedWriter out = new BufferedWriter(new FileWriter(outFilename));
            template.process(valueMap, out);
        } catch (Exception e) {
            LOGGER.error("failed to load template [{}]", templateFile, e);
            throw new CartException(CartExceptionType.PROCESSING_FAILED, "failed to load template [{}]", templateFile);
        }

        modifyWorkflowXmlWithDynamicValues(outFilename, templateParamsMap);

        DmpWorkflowContext context = null;
        try {
            String soapRequestRawMessage = FileUtils.readFileToString(new File(outFilename), UTF_8);
            LOGGER.debug("soapRequestRawMessage: [{}]", soapRequestRawMessage);

            context = dmpWorkflowSvc.getDmpWorkflowContext();
            LOGGER.info("invoking web service to endpoint [{}]", context.getEndpoint());
            String body = dmpWorkflowSvc.invokeWebService(context, soapRequestRawMessage);

            FileUtils.writeStringToFile(new File(responseFile), body, UTF_8, false);
            LOGGER.debug("soapResponse: [{}]", body);
        } catch (Exception e) {
            LOGGER.error("error: ", e);
            throw new CartException(CartExceptionType.PROCESSING_FAILED, "failed to send SOAP WS request to [{}]", context != null ? context.getEndpoint() : "");
        }
    }


    public void processWorkFlowRequestAndWaitTillCompletion(String templateFile, String responseFile, Map<String, String> templateParams, Integer maxPollTimeSec) {

        String fullResponseFilePath = fileDirUtil.addPrefixIfNotAbsolute(responseFile, workspaceUtil.getBaseDir());
        LOGGER.debug("Response File Full Path [{}]", fullResponseFilePath);

        this.processWorkFlowRequest(templateFile, fullResponseFilePath, templateParams);
        threadSvc.sleepSeconds(2);

        if (fileDirUtil.verifyFileExists(fullResponseFilePath)) {
            List<String> xpathResult = xmlSvc.extractValueFromXmlFileUsingXPath(fullResponseFilePath, XPATH_FLOW_RESULT_XPATH);

            if (xpathResult.size() == 0) {
                String xmlResponse = fileDirUtil.readFileToString(fullResponseFilePath);
                LOGGER.error(UNABLE_TO_RETRIEVE_FLOW_RESULT_ID_FROM_XML_RESPONSE, xmlResponse);
                throw new CartException(CartExceptionType.PROCESSING_FAILED, UNABLE_TO_RETRIEVE_FLOW_RESULT_ID_FROM_XML_RESPONSE, xmlResponse);
            }
            String flowResultId = xpathResult.get(0);
            stateSvc.setStringVar(FLOW_RESULT_ID, flowResultId);

            LOGGER.debug("Polling [{}] seconds for Job completion status", maxPollTimeSec);

            String expandSql = stateSvc.expandVar(WORKFLOW_CHECK_SQL);
            this.pollUntilWorkflowComplete(expandSql, flowResultId, maxPollTimeSec);
        } else {
            LOGGER.error(RESPONSE_FILE_IS_NOT_CREATED, fullResponseFilePath);
            throw new CartException(CartExceptionType.VALIDATION_FAILED, RESPONSE_FILE_IS_NOT_CREATED, fullResponseFilePath);
        }

    }

    /**
     * Change patterns in template and create new file.
     *
     * @param testDataFilePath the input file
     * @param templateFilePath the template file
     * @param dataTableMap     the data table map
     */
    public void changePatternsInTemplateAndCreateNewFile(String testDataFilePath, String templateFilePath, Map<String, String> dataTableMap) {
        if (dataTableMap.size() != 0) {
            Set<String> vars = dataTableMap.keySet();
            for (String varName : vars) {
                String varValue = dataTableMap.get(varName);
                if (varValue.contains("DateTimeFormat:")) {
                    final String format = varValue.replaceFirst("DateTimeFormat:", "").trim();
                    stateSvc.setStringVar(varName, dateTimeUtil.getTimestamp(format));
                } else {
                    stateSvc.setStringVar(varName, varValue);
                }
            }
        }

        final String fileType = FilenameUtils.getExtension(testDataFilePath);

        if (fileType.equalsIgnoreCase("xls") || fileType.equalsIgnoreCase("xlsx")) {
            excelFileSvc.expandVarsInExcelAndSaveAs(templateFilePath, testDataFilePath);
        }

        if (FLAT_FILE_TYPES.contains(fileType)) {
            final String templateContent = fileDirUtil.readFileToString(templateFilePath);
            LOGGER.debug("template content: [{}]", templateContent);
            fileDirUtil.writeStringToFile(testDataFilePath, stateSvc.expandVar(templateContent));
        }
    }

    ///This function is common to Pipe separated (PSV) and Comma separated Files (CSV)
    public void extractColumnValueFromInputFileAndAssignToVariable(Integer dataRowInFile, String fileName, String localDir, Map<String, String> variableMap, char delimiter, String refField) {
        if (dataRowInFile < 2) {
            LOGGER.error(DATA_ROW_ERROR_MSG);
            throw new CartException(CartExceptionType.INCOMPLETE_PARAMS, DATA_ROW_ERROR_MSG);
        }

        String localDirFullPath = workspaceDirSvc.normalize(stateSvc.expandVar(localDir));

        String expandedFileName = localDirFullPath + File.separator + stateSvc.expandVar(fileName);
        int rowsInFile = (int) fileDirUtil.getRowsCountInFile(expandedFileName);

        if (rowsInFile < dataRowInFile) {
            LOGGER.error("data Row should not be greater than available rows in file [{}]", rowsInFile);
            throw new CartException(CartExceptionType.INCOMPLETE_PARAMS, "data Row should not be greater than available rows in file [{}]", rowsInFile);
        }

        Set<String> fieldSet = variableMap.keySet();
        String valueToCapture;

        for (String fieldToCapture : fieldSet) {
            valueToCapture = dmpFileHandlingUtl.getColumnValueFromDelimiterSeparatedFile(expandedFileName, dataRowInFile, refField, fieldToCapture, delimiter);
            stateSvc.setStringVar(variableMap.get(fieldToCapture), valueToCapture);
            LOGGER.debug("Value [{}] of given rownum [{}] is captured in [{}]", valueToCapture, dataRowInFile, variableMap.get(fieldToCapture));
        }
    }

    public void extractColumnValueFromEXCELFileAndAssignToVariables(Integer dataRowToRead, String fileName, String localDir, Map<String, String> varMap) {

        String localDirFullPath = workspaceDirSvc.normalize(stateSvc.expandVar(localDir));
        String expandedFileName = localDirFullPath + File.separator + stateSvc.expandVar(fileName);
        if (dataRowToRead < 2) {
            LOGGER.error(DATA_ROW_ERROR_MSG);
            throw new CartException(CartExceptionType.INCOMPLETE_PARAMS, DATA_ROW_ERROR_MSG);
        }
        //User wants to retrieve 2nd row in excel (assuming 1row as header), while reading data from Excel, we need to decrement by 1 because in Excel, row index starts from 0
        Map<String, String> dataMap = dmpFileHandlingUtl.getColumnValueMapFromExcel(expandedFileName, 0, dataRowToRead - 1);
        Set<String> fieldSet = varMap.keySet();

        for (String fieldToCapture : fieldSet) {
            String fldValFromDataMap = dataMap.get(fieldToCapture);
            stateSvc.setStringVar(varMap.get(fieldToCapture), fldValFromDataMap);
        }
    }

    public void extractColumnValueFromBBGPSVFileAndAssignToVariables(Integer dataRowToRead, String fileName, String localDir, Map<String, String> varMap) {

        String localDirFullPath = workspaceDirSvc.normalize(stateSvc.expandVar(localDir));
        String expandedFileName = localDirFullPath + File.separator + stateSvc.expandVar(fileName);
        Set<String> fieldSet = varMap.keySet();
        String valueToCapture;

        for (String fieldToCapture : fieldSet) {
            valueToCapture = dmpFileHandlingUtl.getBBPriceFileFieldData(expandedFileName, dataRowToRead, fieldToCapture);
            if (valueToCapture.equals("")) {
                valueToCapture = null;
            }
            stateSvc.setStringVar(varMap.get(fieldToCapture), valueToCapture);
            LOGGER.debug("Value [{}] of given rownum [{}] is captured in [{}]", valueToCapture, dataRowToRead, varMap.get(fieldToCapture));
        }
    }


    /**
     * Poll until workflow completion status.
     * This function uses recursion logic to verify JOB status DONE|FAILED.
     * If FAILED, then capture PUB_DESCRIPTION field and update in the logs (except for DWH database)
     *
     * @param sql          the sql to check job completion status
     * @param flowResultId the flow result id is just to logging purpose
     * @param maxPollSec   the max poll sec
     */
    public void pollUntilWorkflowComplete(final String sql, final String flowResultId, final Integer maxPollSec) {
        if (maxPollSec <= 0) {
            LOGGER.error("Workflow with instance id [{}] status showing as [{}] even after max polling time", flowResultId, stateSvc.getStringVar(WF_RUNTIME_STAT_TYP));
            throw new CartException(CartExceptionType.PROCESSING_FAILED, "Workflow with instance id [{}] status showing as [{}] even after max polling time", flowResultId, stateSvc.getStringVar(WF_RUNTIME_STAT_TYP));
        }

        databaseSteps.executeQueryAndExtractValues(sql, Collections.singletonList(WF_RUNTIME_STAT_TYP));
        String wfStatus = stateSvc.getStringVar(WF_RUNTIME_STAT_TYP);
        long millisStart = dateTimeUtil.currentTimeMillis();

        if (DONE.equals(wfStatus)) {
            LOGGER.info("Workflow with instance id [{}] is successfully completed", flowResultId);
        } else if (FAILED.equals(wfStatus)) {
            if (!"dmp.db.DW".equals(databaseSvc.getCurrentConfigPrefix())) {
                this.printPubDescription(flowResultId);
            }
            this.printStackTraceError(flowResultId);
            LOGGER.error(WORKFLOW_WITH_INSTANCE_ID_IS_FAILED, flowResultId);
            throw new CartException(CartExceptionType.PROCESSING_FAILED, WORKFLOW_WITH_INSTANCE_ID_IS_FAILED, flowResultId);
        } else {
            threadSvc.sleepSeconds(2);
            pollUntilWorkflowComplete(sql, flowResultId, (int) (maxPollSec - (dateTimeUtil.currentTimeMillis() - millisStart) / 1000));
        }
    }

    private void printStackTraceError(final String instanceId) {
        try {
            final String tempFile = fileDirUtil.getTempDir() + File.separator + "stackTraceBlob.txt";
            databaseSvc.executeSqlQuerySaveBlobToFile(formatterUtil.format(WORKFLOW_STACK_TRACE_ERROR, instanceId), tempFile);
            final String stackTrace = fileDirUtil.readFileToString(tempFile);
            if (!Strings.isNullOrEmpty(stackTrace)) {
                LOGGER.error("Workflow failed with error stack as [{}]", stackTrace);
                scenarioUtil.write("Workflow failed with error stack as " + stackTrace);
            }
        } catch (Exception e) {
            //ignore
        }
    }

    private void printPubDescription(final String instanceId) {
        try {
            final String pubDescription = databaseSvc.executeSingleValueQueryOnNamedConnection(formatterUtil.format(WORKFLOW_PUB_DESCRIPTION_QUERY, instanceId), "PUB_DESCRIPTION");
            if (!Strings.isNullOrEmpty(pubDescription)) {
                LOGGER.error("pub_description for this workflow captured as [{}]", pubDescription);
                scenarioUtil.write("pub_description for this workflow captured as [" + pubDescription + "]");
            }
        } catch (Exception e) {
            //ignore
        }
    }


    /**
     * Construct ntel verification query string.
     * This function is constructs NTEL verification query based on column (NTEL table) and values passed by user
     *
     * @param columnValueMap the column value map
     * @return the string (complete SQL query for FT_T_NTEL verification)
     */
    public String constructNTELVerificationQuery(final LinkedHashMap<String, String> columnValueMap) {
        final String jobId = columnValueMap.getOrDefault(JOB_ID, stateSvc.getStringVar(JOB_ID));

        if (Strings.isNullOrEmpty(jobId)) {
            LOGGER.error(JOBD_ID_EMPTY_WARNING);
            throw new CartException(CartExceptionType.PROCESSING_FAILED, JOBD_ID_EMPTY_WARNING);
        }

        LOGGER.debug("Constructing NTEL query with JOB_ID => [{}]", jobId);

        StringBuilder completeSql = new StringBuilder(BASE_NTEL_QUERY)
                .append("'")
                .append(jobId)
                .append("'");

        for (Map.Entry<String, String> entry : columnValueMap.entrySet()) {
            if (!entry.getKey().equals(JOB_ID)) {
                String column = entry.getKey();
                String value = stateSvc.expandVar(entry.getValue());

                completeSql.append(" AND ");

                if (column.charAt(4) == '.') {
                    completeSql.append(column);
                } else {
                    completeSql.append("NTEL.")
                            .append(column);
                }
                completeSql.append(value.contains("%") ? " like " : "=")
                        .append("'")
                        .append(value)
                        .append("'");
            }
        }

        LOGGER.debug("FT_T_NTEL Verification query [{}]", completeSql.toString());
        scenarioUtil.write("FT_T_NTEL Verification query " + completeSql.toString());
        return completeSql.toString();
    }
}
