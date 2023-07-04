package com.eastspring.tom.cart.dmp.steps;

import com.eastspring.tom.cart.core.CartException;
import com.eastspring.tom.cart.core.CartExceptionType;
import com.eastspring.tom.cart.core.steps.DatabaseSteps;
import com.eastspring.tom.cart.core.steps.HostSteps;
import com.eastspring.tom.cart.core.svc.*;
import com.eastspring.tom.cart.core.utl.*;
import com.eastspring.tom.cart.dmp.svc.DmpWorkflowContext;
import com.eastspring.tom.cart.dmp.svc.DmpWorkflowSvc;
import com.eastspring.tom.cart.dmp.svc.ResearchReportBrsApiSvc;
import com.eastspring.tom.cart.dmp.svc.ResearchReportEmailSvc;
import com.eastspring.tom.cart.dmp.utl.DmpFileHandlingUtl;
import com.eastspring.tom.cart.dmp.utl.DmpGsWorkflowUtl;
import com.eastspring.tom.cart.dmp.utl.ReconFileHandler;
import com.eastspring.tom.cart.dmp.utl.mdl.ReconInputSpec;
import com.eastspring.tom.cart.dmp.utl.mdl.ReconOutputSpec;
import com.eastspring.tom.cart.dmp.utl.mdl.ReconType;
import com.google.common.base.Strings;
import io.cucumber.datatable.DataTable;
import org.apache.commons.io.FileUtils;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.util.StringUtils;
import tomcart.glue.DmpGsWorkflowStepsDef;

import java.io.File;
import java.util.*;
import java.util.regex.Matcher;
import java.util.regex.Pattern;
import java.util.stream.Collectors;

import static com.eastspring.tom.cart.constant.BrsApiConstants.BRS_API_TEMPLATES_RELATIVE_PATH;

public class DmpGsWorkflowSteps {
    private static final Logger LOGGER = LoggerFactory.getLogger(DmpGsWorkflowSteps.class);

    public static final String GSWF_TEMPLATE_PARAM_PREFIX = "gs.wf.template.param";
    public static final char PSV_FILE_DELIMITER = '|';
    public static final char CSV_FILE_DELIMITER = ',';
    private static final String UTF_8 = "UTF-8";
    private static final String GET_INSTR_ID_SQL_QUERY = "SELECT INSTR_ID FROM FT_T_ISID WHERE ISS_ID IN ('${ID_BB_GLOBAL}') AND END_TMS IS NULL";

    private static final String SOURCE_ID = "SOURCE_ID";
    private static final String ID_BB_GLOBAL = "ID_BB_GLOBAL";
    private static final String INSTR_ID = "INSTR_ID";
    private static final String COMMIT = "COMMIT";

    private static final String WORKFLOW_MAX_POLLING_TIME = "workflow.max.polling.time";

    public static final String VERIFICATION_FAILED_EXPECTED_ACTUAL = "Verification failed, Expected [{}], Actual [{}]";

    private static final List<String> TEST_PORTFOLIO_NAMING_PATTERN = Arrays.asList("TST", "U_TT", "TEST");

    @Autowired
    private DmpWorkflowSvc dmpWorkflowSvc;

    @Autowired
    private StateSvc stateSvc;

    @Autowired
    private FileDirSvc fileDirSvc;

    @Autowired
    private FmTemplateSvc fmTemplateSvc;

    @Autowired
    private XmlSvc xmlSvc;

    @Autowired
    private DataTableUtil dataTableUtil;

    @Autowired
    private FileDirUtil fileDirUtil;

    @Autowired
    private DmpFileHandlingUtl dmpFileHandlingUtl;

    @Autowired
    private DateTimeUtil dateTimeUtil;

    @Autowired
    private DatabaseSvc databaseSvc;

    @Autowired
    private ThreadSvc threadSvc;

    @Autowired
    private ExcelFileSvc excelFileSvc;

    @Autowired
    private DmpGsWorkflowUtl dmpGsWorkflowUtl;

    @Autowired
    private HostSteps hostSteps;

    @Autowired
    private ResearchReportEmailSvc researchReportEmailSvc;

    @Autowired
    private ResearchReportBrsApiSvc researchReportBrsApiSvc;

    @Autowired
    private ScenarioUtil scenarioUtil;

    @Autowired
    private WorkspaceDirSvc workspaceDirSvc;

    @Autowired
    private ReconFileHandler reconFileHandler;

    @Autowired
    private DatabaseSteps databaseSteps;

    @Autowired
    private WorkspaceUtil workspaceUtil;

    public void setWebServiceConfigName(String wsConfigName) {
        dmpWorkflowSvc.setWebServiceConfigName(wsConfigName);
    }

    public void setTemplateParam(String paramName, String paramValue) {
        dmpGsWorkflowUtl.setTemplateParam(paramName, paramValue);
    }

    public void clearPredefinedTemplateParams() {
        dmpGsWorkflowUtl.clearAllTemplateParams();
    }

    public void sendWebServiceRequestUsingTemplateFile(String templateFile, String responseFile) {
        dmpGsWorkflowUtl.sendWebServiceRequestUsingTemplateFile(templateFile, responseFile, new HashMap<>());
    }

    public void processWorkFlowRequest(String templateFile, String responseFile, DataTable templateParams) {
        Map<String, String> templateParamsMap = dataTableUtil.getTwoColumnAsMap(templateParams);
        dmpGsWorkflowUtl.processWorkFlowRequest(templateFile, responseFile, templateParamsMap);
    }

    public void sendWebServiceRequestUsingXMLFile(String xmlFile, String responseFile) {
        String evidenceDir = fileDirSvc.createTestEvidenceSubDir("/gswf");
        LOGGER.debug("evidenceDir: [{}]", evidenceDir);
        FileDirSvc.FileDir fileDir = fileDirSvc.decomposePath(xmlFile);

        fmTemplateSvc.setTemplateLocation(fileDir.getDir());

        DmpWorkflowContext context = null;
        try {
            String soapRequestRawMessage = FileUtils.readFileToString(new File(xmlFile), UTF_8);
            LOGGER.debug("soapRequestRawMessage: [{}]", soapRequestRawMessage);

            context = dmpWorkflowSvc.getDmpWorkflowContext();
            LOGGER.debug("invoking web service to endpoint [{}]", context.getEndpoint());
            String body = dmpWorkflowSvc.invokeWebService(context, soapRequestRawMessage);

            FileUtils.writeStringToFile(new File(responseFile), body, UTF_8, false);
            LOGGER.debug("soapResponse: [{}]", body);
        } catch (Exception e) {
            LOGGER.error("error: ", e);
            throw new CartException(CartExceptionType.PROCESSING_FAILED, "failed to send SOAP WS request to [{}]", context != null ? context.getEndpoint() : "");
        }
    }

    public void processWorkFlowRequestAndWaitTillCompletion(String templateFile, String responseFile, DataTable templateParams, Integer maxPollTimeSec) {
        Map<String, String> templateParamsMap = dataTableUtil.getTwoColumnAsMap(templateParams);
        String expandedTemplateFile = stateSvc.expandVar(templateFile);
        String stringVar = stateSvc.getStringVar(WORKFLOW_MAX_POLLING_TIME);
        Integer maxPollTime = Strings.isNullOrEmpty(stringVar) ? maxPollTimeSec : Integer.parseInt(stringVar);
        LOGGER.debug("Setting Max Polltime as [{}]", maxPollTime);

        dmpGsWorkflowUtl.processWorkFlowRequestAndWaitTillCompletion(expandedTemplateFile, responseFile, templateParamsMap, maxPollTime);
    }

    public void extractColumnValueFromCSVFileAndAssignToVariables(Integer dataRowToRead, String fileName, String localDir, DataTable fieldsNVars, String refColumnInCSVFile) {
        Map<String, String> variableMap = dataTableUtil.getTwoColumnAsMap(fieldsNVars);
        dmpGsWorkflowUtl.extractColumnValueFromInputFileAndAssignToVariable(dataRowToRead, fileName, localDir, variableMap, CSV_FILE_DELIMITER, refColumnInCSVFile);
    }

    public void extractColumnValueFromPSVFileAndAssignToVariables(Integer dataRowToRead, String fileName, String localDir, DataTable fieldsNVars) {
        Map<String, String> variableMap = dataTableUtil.getTwoColumnAsMap(fieldsNVars);
        dmpGsWorkflowUtl.extractColumnValueFromInputFileAndAssignToVariable(dataRowToRead, fileName, localDir, variableMap, PSV_FILE_DELIMITER, SOURCE_ID);
    }

    public void extractColumnValueFromPSVFileAndAssignToVariables(Integer dataRowToRead, String fileName, String localDir, DataTable fieldsNVars, String referenceColumn) {
        Map<String, String> variableMap = dataTableUtil.getTwoColumnAsMap(fieldsNVars);
        dmpGsWorkflowUtl.extractColumnValueFromInputFileAndAssignToVariable(dataRowToRead, fileName, localDir, variableMap, PSV_FILE_DELIMITER, referenceColumn);
    }

    public void extractColumnValueFromBBGPSVFileAndAssignToVariables(Integer dataRowToRead, String fileName, String localDir, DataTable fieldsNVars) {
        Map<String, String> variableMap = dataTableUtil.getTwoColumnAsMap(fieldsNVars);
        dmpGsWorkflowUtl.extractColumnValueFromBBGPSVFileAndAssignToVariables(dataRowToRead, fileName, localDir, variableMap);
    }

    public void extractColumnValueFromEXCELFileAndAssignToVariables(Integer dataRowToRead, String fileName, String localDir, DataTable fieldsNVars) {
        Map<String, String> variableMap = dataTableUtil.getTwoColumnAsMap(fieldsNVars);
        dmpGsWorkflowUtl.extractColumnValueFromEXCELFileAndAssignToVariables(dataRowToRead, fileName, localDir, variableMap);
    }

    public void changePatternsInTemplateAndCreateNewFile(String inputFile, String templateFile, String parentFolder, Map<String, String> varCodesMap) {
        final String fullParentFolderPath = workspaceDirSvc.normalize(stateSvc.expandVar(parentFolder));
        final String templateFilePath = fullParentFolderPath + "/template/" + stateSvc.expandVar(templateFile);
        final String testDataFilePath = fullParentFolderPath + "/testdata/" + stateSvc.expandVar(inputFile);
        dmpGsWorkflowUtl.changePatternsInTemplateAndCreateNewFile(testDataFilePath, templateFilePath, varCodesMap);
    }


    public void invokeReconciliations(ReconType reconType, ReconFileHandler fileHandler) {
        final String sourceFile = fileHandler.resolveSourceFile();
        final String targetFile = fileHandler.resolveTargetFile();
        final String exceptionsFile = fileHandler.resolveExceptionFile();

        switch (reconType) {
            case SRC_TARGET_EXACT_MATCH:
                expectBothFilesShouldBeSame(sourceFile, targetFile, exceptionsFile);
                break;
            case SRC_TARGET_EXACT_MATCH_WITH_ORDER:
                expectBothFilesShouldBeSame(sourceFile, targetFile, exceptionsFile);
                break;
            case SRC_ALL_MATCH:
                expectAllRecordsExistInTargetFile(sourceFile, targetFile, exceptionsFile);
                break;
            case SRC_NONE_MATCH:
                expectNoRecordsExistsInTargetFile(sourceFile, targetFile, exceptionsFile);
                break;
        }
    }

    /**
     * Expect both files should be same irrespective of the order of records in it.
     *
     * @param currFile       the curr file
     * @param refFile        the ref file
     * @param exceptionsFile the exceptions file
     */
    public void expectBothFilesShouldBeSame(final String currFile, final String refFile, final String exceptionsFile) {
        final String[] files = reconFileHandler.generateFilesRemovingColumns(currFile, refFile);

        ReconInputSpec inputSpec = ReconInputSpec.builder()
                .file1(files[0])
                .file2(files[1])
                .ignoreRowCount(false)
                .lookForRecords(true)
                .considerOrder(false)
                .ignoreHeader(false)
                .build();

        ReconOutputSpec outputSpec = dmpFileHandlingUtl.reconcileFlatFiles(inputSpec);
        if (outputSpec.getIsMatch()) {
            LOGGER.info("Reconciliations is successful, records in both files are matching");
        } else {
            LOGGER.error("Exceptions file [{}] created...", exceptionsFile);
            fileDirUtil.writeStringToFile(exceptionsFile, "");
            fileDirUtil.copyInputStreamToFile(dmpFileHandlingUtl.convertListToInputStream(outputSpec.getExceptions()), new File(exceptionsFile));
            scenarioUtil.embed(fileDirUtil.readFileToByteArray(exceptionsFile), "text/plain");
            LOGGER.error(outputSpec.getErrorMessage());
            throw new CartException(CartExceptionType.VALIDATION_FAILED, outputSpec.getErrorMessage());
        }
    }

    /**
     * Expect both files should be same and in same order.
     *
     * @param currFile       the curr file
     * @param refFile        the ref file
     * @param exceptionsFile the exceptions file
     */
    public void expectBothFilesShouldBeSameWithSameOrder(final String currFile, final String refFile, final String exceptionsFile) {
        final String[] files = reconFileHandler.generateFilesRemovingColumns(currFile, refFile);

        ReconInputSpec inputSpec = ReconInputSpec.builder()
                .file1(files[0])
                .file2(files[1])
                .ignoreRowCount(false)
                .lookForRecords(true)
                .considerOrder(true)
                .ignoreHeader(false)
                .build();

        ReconOutputSpec outputSpec = dmpFileHandlingUtl.reconcileFlatFiles(inputSpec);

        if (outputSpec.getIsMatch()) {
            LOGGER.info("Reconciliations is successful, records in both files are matching and in same order");
        } else {
            LOGGER.error("Exceptions file [{}] created...", exceptionsFile);
            fileDirUtil.writeStringToFile(exceptionsFile, "");
            fileDirUtil.copyInputStreamToFile(dmpFileHandlingUtl.convertListToInputStream(outputSpec.getExceptions()), new File(exceptionsFile));
            scenarioUtil.embed(fileDirUtil.readFileToByteArray(exceptionsFile), "text/plain");
            LOGGER.error(outputSpec.getErrorMessage() + " Or Order mismatch");
            throw new CartException(CartExceptionType.VALIDATION_FAILED, outputSpec.getErrorMessage() + " Or Order mismatch");
        }
    }

    /**
     * Expect all records exist in target file.
     *
     * @param srcFile        the src file
     * @param targetFile     the target file
     * @param exceptionsFile the exceptions file
     */
    public void expectAllRecordsExistInTargetFile(final String srcFile, final String targetFile, final String exceptionsFile) {
        final String[] files = reconFileHandler.generateFilesRemovingColumns(srcFile, targetFile);

        ReconInputSpec inputSpec = ReconInputSpec.builder()
                .file1(files[0])
                .file2(files[1])
                .ignoreRowCount(true)
                .lookForRecords(true)
                .considerOrder(false)
                .ignoreHeader(false)
                .build();

        ReconOutputSpec outputSpec = dmpFileHandlingUtl.reconcileFlatFiles(inputSpec);

        if (outputSpec.getIsMatch()) {
            LOGGER.info("Reconciliation is Successful, all records in src file exist in target file");
        } else {
            LOGGER.error("Exceptions file [{}] created...", exceptionsFile);
            fileDirUtil.writeStringToFile(exceptionsFile, "");
            fileDirUtil.copyInputStreamToFile(dmpFileHandlingUtl.convertListToInputStream(outputSpec.getExceptions()), new File(exceptionsFile));
            scenarioUtil.embed(fileDirUtil.readFileToByteArray(exceptionsFile), "text/plain");
            LOGGER.error(outputSpec.getErrorMessage());
            throw new CartException(CartExceptionType.VALIDATION_FAILED, outputSpec.getErrorMessage());
        }
    }

    /**
     * Expect no records exists in target file.
     *
     * @param srcFile        the src file
     * @param targetFile     the target file
     * @param exceptionsFile the exceptions file
     */
    public void expectNoRecordsExistsInTargetFile(final String srcFile, final String targetFile, final String exceptionsFile) {
        final String[] files = reconFileHandler.generateFilesRemovingColumns(srcFile, targetFile);

        ReconInputSpec inputSpec = ReconInputSpec.builder()
                .file1(files[0])
                .file2(files[1])
                .ignoreRowCount(true)
                .lookForRecords(false)
                .considerOrder(false)
                .ignoreHeader(true)
                .build();

        ReconOutputSpec outputSpec = dmpFileHandlingUtl.reconcileFlatFiles(inputSpec);

        if (outputSpec.getIsMatch()) {
            LOGGER.info("Reconciliation is Successful, no record in src file exist in target file");
        } else {
            LOGGER.error("Exceptions file [{}] created...", exceptionsFile);
            fileDirUtil.writeStringToFile(exceptionsFile, "");
            fileDirUtil.copyInputStreamToFile(dmpFileHandlingUtl.convertListToInputStream(outputSpec.getExceptions()), new File(exceptionsFile));
            scenarioUtil.embed(fileDirUtil.readFileToByteArray(exceptionsFile), "text/plain");
            LOGGER.error("[{}], Exceptions details are available in [{}]", outputSpec.getErrorMessage(), exceptionsFile);
            throw new CartException(CartExceptionType.VALIDATION_FAILED, outputSpec.getErrorMessage());
        }
    }

    /**
     * To reuse the same instrument for Security Tests, we need to set END_TMS to SYSDATE as a cleanup activity.
     * At times, DMP is throwing SQL Unique Constraint exception (which is valid from DMP side) while executing Query with
     * START_TMS=LAST_CHG_TMS, but it works without this condition
     * so, catch block is added to execute same query without START_TMS condition
     *
     * @param dbConfig database config as per properties file
     * @param issIds   ISS_IDs seperated by Comma (,)
     */
    public void setEndTmsToSYSDATEAsPerDBConfig(String dbConfig, String issIds) {
        String inCondition = stateSvc.expandVar(issIds);
        String queryToExecute = "UPDATE FT_T_ISID \n" +
                "  SET END_TMS=SYSDATE,START_TMS=LAST_CHG_TMS\n" +
                "  WHERE INSTR_ID IN (SELECT INSTR_ID FROM FT_T_ISID WHERE ISS_ID IN (" + inCondition + ")) AND END_TMS IS NULL;\n" +
                "  COMMIT;";

        databaseSvc.setDatabaseConnectionToConfig(dbConfig);
        try {
            databaseSvc.executeMultipleQueries(queryToExecute);
        } catch (Exception e) {
            LOGGER.info("Exception occurred while setting END_TMS to SYSDATE, Invoking Workaround...");
            databaseSvc.executeMultipleQueries(queryToExecute.replace(",START_TMS=LAST_CHG_TMS", ""));
        }
    }

    public void addBBInstrumentsToTheBBPriceGroup(String bbPriceFeedFile) {

        String expandPriceFeed = stateSvc.expandVar(bbPriceFeedFile);

        String sqlToFindGrpId = "select ISS_GRP_OID from ft_t_isgr where ISS_GRP_ID = 'BBPRICEGRP'";
        databaseSvc.executeSqlQueryAssignResultsToVars(sqlToFindGrpId, Collections.singletonList("ISS_GRP_OID"));

        String insertSQLQuery = "INSERT INTO FT_T_ISGP (PRNT_ISS_GRP_OID,START_TMS,ISS_GRP_OID,INSTR_ID,LAST_CHG_TMS,LAST_CHG_USR_ID,PRT_PURP_TYP,END_TMS,PART_TYP,PRT_DESC,PART_CURR_CDE,DATA_STAT_TYP,DATA_SRC_ID,PART_CAMT,PART_CPCT,ISID_OID,MKT_ISS_OID,ISGP_OID,REF_ISS_GRP_OID)\n" +
                "    SELECT '${ISS_GRP_OID}',TO_DATE(SYSDATE,'DD/MM/RR HH12:MI:SS'),NULL,'${INSTR_ID}',TO_DATE(SYSDATE,'DD/MM/RR HH12:MI:SS'),'AUTO','MEMBER  ',NULL,NULL,NULL,NULL,'ACTIVE',NULL,NULL,NULL,NULL,NULL,NEW_OID(),NULL FROM DUAL\n" +
                "    WHERE NOT EXISTS\n" +
                "    (\n" +
                "        SELECT 1 FROM FT_T_ISGP\n" +
                "        WHERE INSTR_ID = '${INSTR_ID}'\n" +
                "        AND PRNT_ISS_GRP_OID = '${ISS_GRP_OID}'\n" +
                "    )";

        int noOfBBDataRecords = dmpFileHandlingUtl.getNoOfBBDataRecords(expandPriceFeed);

        for (int i = 1; i <= noOfBBDataRecords; i++) {
            String bbGlobalId = dmpFileHandlingUtl.getBBPriceFileFieldData(expandPriceFeed, i, ID_BB_GLOBAL);
            stateSvc.setStringVar(ID_BB_GLOBAL, bbGlobalId);
            databaseSvc.executeSqlQueryAssignResultsToVars(GET_INSTR_ID_SQL_QUERY, Collections.singletonList(INSTR_ID));
            databaseSvc.executeMultipleQueries(insertSQLQuery);
        }
        databaseSvc.executeMultipleQueries(COMMIT);
    }

    public void updateBBInstrumentRecordsWithESIPRPTEODInISPCTable(String bbPriceFeedFile) {
        String expandPriceFeed = stateSvc.expandVar(bbPriceFeedFile);
        String updateSQLQuery = "UPDATE FT_T_ISPC\n" +
                "      SET PPED_OID = 'ESIPRPTEOD'\n" +
                "      WHERE INSTR_ID IN (SELECT INSTR_ID FROM FT_T_ISID WHERE ISS_ID IN ('${ID_BB_GLOBAL}') AND END_TMS IS NULL)\n" +
                "      AND TO_CHAR(PRC_TMS,'YYYYMMDD') = '${PRC_TMS}'";

        int noOfBBDataRecords = dmpFileHandlingUtl.getNoOfBBDataRecords(expandPriceFeed);

        for (int i = 1; i <= noOfBBDataRecords; i++) {
            String bbGlobalId = dmpFileHandlingUtl.getBBPriceFileFieldData(expandPriceFeed, i, ID_BB_GLOBAL);
            stateSvc.setStringVar(ID_BB_GLOBAL, bbGlobalId);
            databaseSvc.executeMultipleQueries(updateSQLQuery);
        }
        databaseSvc.executeMultipleQueries(COMMIT);
    }

    public void deleteBBInstrumentRecordsFromDMP(String bbPriceFeedFile) {
        String expandPriceFeed = stateSvc.expandVar(bbPriceFeedFile);
        String deleteSQLQuery = "DELETE FT_T_ISPS WHERE ISS_PRC_ID IN (SELECT ISS_PRC_ID FROM FT_T_ISPC WHERE INSTR_ID = '${INSTR_ID}') AND TO_CHAR(PRC_TMS,'YYYYMMDD') = '${PRC_TMS}';\n" +
                "    DELETE FT_T_GPCS WHERE INSTR_ID = '${INSTR_ID}' AND ISS_PRC_ID IN (SELECT ISS_PRC_ID FROM FT_T_ISPC WHERE INSTR_ID = '${INSTR_ID}') AND TO_CHAR(PRC_TMS,'YYYYMMDD') = '${PRC_TMS}';\n" +
                "    DELETE FT_T_ISPC WHERE INSTR_ID = '${INSTR_ID}' AND TO_CHAR(PRC_TMS,'YYYYMMDD') = '${PRC_TMS}';";

        int noOfBBDataRecords = dmpFileHandlingUtl.getNoOfBBDataRecords(expandPriceFeed);

        for (int i = 1; i <= noOfBBDataRecords; i++) {
            String bbGlobalId = dmpFileHandlingUtl.getBBPriceFileFieldData(expandPriceFeed, i, ID_BB_GLOBAL);
            stateSvc.setStringVar(ID_BB_GLOBAL, bbGlobalId);
            databaseSvc.executeSqlQueryAssignResultsToVars(GET_INSTR_ID_SQL_QUERY, Collections.singletonList(INSTR_ID));
            databaseSvc.executeMultipleQueries(deleteSQLQuery);
        }
        databaseSvc.executeMultipleQueries(COMMIT);
    }

    public void setupBBPriceInstrumentsWithBNPFeed(String instrFile, String instrFeedPath) {
        String expandInstrFile = stateSvc.expandVar(instrFile);
        String expandInstrFeedPath = stateSvc.expandVar(instrFeedPath);
        String expandedFilePath = stateSvc.expandVar(expandInstrFeedPath) + File.separator + stateSvc.expandVar(expandInstrFile);
        String sqlQuery = "SELECT COUNT(*) AS EISLSTID_COUNT FROM FT_T_ISID\n" +
                "WHERE INSTR_ID IN (SELECT INSTR_ID FROM FT_T_ISID WHERE ISS_ID IN ('BB_ID_VAR') AND END_TMS IS NULL)\n" +
                "AND ID_CTXT_TYP = 'EISLSTID'";

        LOGGER.info("setupBBPriceInstruments: Setting Instruments through BNP Feed");
        int rowCount = (int) fileDirUtil.getRowsCountInFile(expandedFilePath);

        LOGGER.info("Row Count in [{}] file is [{}]", expandedFilePath, rowCount);
        boolean isFeedLoadRequired = false;

        for (int i = 2; i <= rowCount; i++) {
            String bbId = dmpFileHandlingUtl.getColumnValueFromDelimiterSeparatedFile(expandedFilePath, i, SOURCE_ID, "BLOOMBERG_GLOBAL_ID", PSV_FILE_DELIMITER);
            databaseSvc.executeSqlQueryAssignResultsToVars(sqlQuery.replace("BB_ID_VAR", bbId), Collections.singletonList("EISLSTID_COUNT"));

            int listIDsCount = Integer.parseInt(stateSvc.getStringVar("EISLSTID_COUNT"));

            LOGGER.info("EISLSTID's found for the instrument [{}] are [{}]", bbId, listIDsCount);

            if (listIDsCount > 1 || listIDsCount == 0) {
                String instrId = dmpFileHandlingUtl.getColumnValueFromDelimiterSeparatedFile(expandedFilePath, i, SOURCE_ID, INSTR_ID, PSV_FILE_DELIMITER);
                String isin = dmpFileHandlingUtl.getColumnValueFromDelimiterSeparatedFile(expandedFilePath, i, SOURCE_ID, "ISIN", PSV_FILE_DELIMITER);
                String sedol = dmpFileHandlingUtl.getColumnValueFromDelimiterSeparatedFile(expandedFilePath, i, SOURCE_ID, "SEDOL", PSV_FILE_DELIMITER);
                String hipSecurityCode = dmpFileHandlingUtl.getColumnValueFromDelimiterSeparatedFile(expandedFilePath, i, SOURCE_ID, "HIP_SECURITY_CODE", PSV_FILE_DELIMITER);
                String hipExt2Id = dmpFileHandlingUtl.getColumnValueFromDelimiterSeparatedFile(expandedFilePath, i, SOURCE_ID, "HIP_EXT2_ID", PSV_FILE_DELIMITER);
                String exchangeTicker = dmpFileHandlingUtl.getColumnValueFromDelimiterSeparatedFile(expandedFilePath, i, SOURCE_ID, "EXCHANGE_TICKER", PSV_FILE_DELIMITER);
                this.setEndTmsToSYSDATEAsPerDBConfig("dmp.db.VD", "'" + bbId + "','" + instrId + "','" + isin + "','" + sedol + "','" + hipSecurityCode + "','" + hipExt2Id + "','" + exchangeTicker + "'");
                this.setEndTmsToSYSDATEAsPerDBConfig("dmp.db.GC", "'" + bbId + "','" + instrId + "','" + isin + "','" + sedol + "','" + hipSecurityCode + "','" + hipExt2Id + "','" + exchangeTicker + "'");
                isFeedLoadRequired = true;
            }
        }

        if (isFeedLoadRequired) {
            LOGGER.info("Setting up Instruments for Bloomberg ESIPX Testing as multiple EISLSTID are found!!");
            Map<String, String> paramsMap = new HashMap<>();
            paramsMap.put("FILE_PATTERN", expandInstrFile);
            paramsMap.put("MESSAGE_TYPE", "EIS_MT_BNP_SECURITY");
            paramsMap.put("BUSINESS_FEED", "");
            hostSteps.copyLocalFilesToRemote(expandInstrFeedPath, Collections.singletonList(expandInstrFile), "dmp.ssh.inbound", stateSvc.getStringVar("dmp.ssh.inbound.path"));
            dmpGsWorkflowUtl.processWorkFlowRequestAndWaitTillCompletion(DmpGsWorkflowStepsDef.PROCESS_FILES_TEMPLATE_PATH, DmpGsWorkflowStepsDef.ASYNC_RESPONSE_FILE_PATH, paramsMap, DmpGsWorkflowStepsDef.MAX_POLL_TIME_SECONDS_SMALL);
        }
    }

    /**
     * It is to verify list of columns are present in the file or not.
     *
     * @param filepath   the filepath
     * @param columnList the column list - List of columns to verify
     */
    public void verifyColumnAvailable(final String filepath, final List<String> columnList) {
        final String expandFilePath = stateSvc.expandVar(filepath);

        if (!fileDirUtil.verifyFileExists(expandFilePath)) {
            LOGGER.error("File [{}] is not available!!!", expandFilePath);
            throw new CartException(CartExceptionType.IO_ERROR, "File [{}] is not available!!!", expandFilePath);
        }

        final String header = fileDirUtil.readFileLineToString(expandFilePath, 1);
        boolean result = true;
        List<String> missingColumns = new ArrayList<>();

        for (String column : columnList) {
            if (!header.contains(column)) {
                result = false;
                missingColumns.add(column);
            }
        }
        if (!result) {
            LOGGER.error("Column Verification is failed, missing columns/sequence in the file are: [{}]", missingColumns);
            throw new CartException(CartExceptionType.VERIFICATION_FAILED, "Column Verification is failed, missing columns/sequence in the file are: [{}]", missingColumns);
        }
    }


    /**
     * Verify column value from csv.
     * It Identifies Row Number of the file based on RefCol and RefVal and reads the actual value of ColToVerify
     * and if Actual Column Value and Expected Column Value are not Equal, Exception will be thrown.
     *
     * @param colToVerify the name of the column to verify
     * @param expectedVal the expected value of Column to verify
     * @param refCol      the ref col
     * @param refVal      the ref val
     * @param filename    the filename
     */
    public void verifyColumnValueFromCSV(final String colToVerify, final String expectedVal, final String refCol, final String refVal, final String filename) {
        final String expandColToVerify = stateSvc.expandVar(colToVerify);
        final String expandExpectedVal = stateSvc.expandVar(expectedVal);
        final String expandRefCol = stateSvc.expandVar(refCol);
        final String expandRefVal = stateSvc.expandVar(refVal);
        final String expandFilename = stateSvc.expandVar(filename);

        final String actualVal = dmpFileHandlingUtl.getColumnValueWithReferenceValue(expandFilename, expandColToVerify, expandRefCol, expandRefVal, CSV_FILE_DELIMITER);

        if (!expandExpectedVal.equals(actualVal)) {
            LOGGER.error(VERIFICATION_FAILED_EXPECTED_ACTUAL, expandExpectedVal, actualVal);
            throw new CartException(CartExceptionType.VERIFICATION_FAILED, VERIFICATION_FAILED_EXPECTED_ACTUAL, expandExpectedVal, actualVal);
        }
    }

    /**
     * Verify column value from csv.
     * It Identifies Row Number of the file based on RefCol and RefVal map and reads the actual value of ColToVerify
     * and if Actual Column Value and Expected Column Value are not Equal, Exception will be thrown.
     *
     * @param colToVerify       the col to verify
     * @param expectedVal       the expected val
     * @param refColumnValueMap the column val map
     * @param filename          the filename
     */
    public void verifyColumnValueFromCSV(final String colToVerify, final String expectedVal, final Map<String, String> refColumnValueMap, final String filename) {
        final String expandColToVerify = stateSvc.expandVar(colToVerify);
        final String expandExpectedVal = stateSvc.expandVar(expectedVal);
        final String expandFilename = stateSvc.expandVar(filename);

        final String actualVal = dmpFileHandlingUtl.getColumnValueWithReferenceValue(expandFilename, expandColToVerify, refColumnValueMap, CSV_FILE_DELIMITER);

        if (!expandExpectedVal.equals(actualVal)) {
            LOGGER.error(VERIFICATION_FAILED_EXPECTED_ACTUAL, expandExpectedVal, actualVal);
            throw new CartException(CartExceptionType.VERIFICATION_FAILED, VERIFICATION_FAILED_EXPECTED_ACTUAL, expandExpectedVal, actualVal);
        }
    }


    public void iExpectColumnValuesOfCSVFileShouldBeAsPerCondition(final String column, final String file, final String valOrPattern, final boolean lookForMatch) {
        final String expandColumn = stateSvc.expandVar(column);
        final String expandFilename = stateSvc.expandVar(file);

        final List<String> listOfColumnValues = dmpFileHandlingUtl.getFieldValuesFromFileWithHeader(expandFilename, 1, "", expandColumn, CSV_FILE_DELIMITER);

        Pattern pattern = Pattern.compile(valOrPattern);
        listOfColumnValues.forEach(s -> {
            Matcher matcher = pattern.matcher(s);
            if (lookForMatch) {
                if (!matcher.find()) {
                    LOGGER.error("Verification failed as some of the values of column [{}] does not match with given value or pattern [{}]", expandColumn, valOrPattern);
                    throw new CartException(CartExceptionType.VERIFICATION_FAILED, "Verification failed as some of the values of column [{}] does not match with given value or pattern [{}]", expandColumn, valOrPattern);
                }
            } else {
                if (matcher.find()) {
                    LOGGER.error("Verification failed as some of the values of column [{}] match with give value or pattern [{}]", expandColumn, valOrPattern);
                    throw new CartException(CartExceptionType.VERIFICATION_FAILED, "Verification failed as some of the values of column [{}] match with give value or pattern [{}]", expandColumn, valOrPattern);
                }
            }
        });
    }

    /**
     * Extract job id from jblg table.
     * This is just to abstract the query and capture JOB_ID into variable with 1 step
     *
     * @param var the var to store JOB_ID
     */
    public void iExtractJobIdFromJblgTable(final String var) {
        final String sqlQuery = "WITH JOB_DETAILS AS \n" +
                "(SELECT jblg.job_id as JOB_ID, 'CHILD_JOB' as JOB_TYPE FROM\n" +
                "      (SELECT instance_id, prnt_instance_id FROM\n" +
                "        (SELECT wfri.instance_id, tokn1.instance_id prnt_instance_id, workflow_nme FROM   FT_WF_WFRI wfri\n" +
                "        LEFT JOIN FT_WF_TOKN tokn1\n" +
                "        ON   (wfri.prnt_token_id = tokn1.token_id)\n" +
                "        JOIN FT_WF_WFDF wfdf \n" +
                "        USING (workflow_id)\n" +
                "        ) iview\n" +
                "        CONNECT BY PRIOR INSTANCE_ID = PRNT_INSTANCE_ID\n" +
                "        START WITH prnt_instance_id  = '${flowResultId}'\n" +
                "      ) runtime_instance,\n" +
                "      ft_t_jblg jblg\n" +
                "    WHERE JBLG.INSTANCE_ID = RUNTIME_INSTANCE.INSTANCE_ID\n" +
                "    union\n" +
                "    SELECT jblg.job_id as JOB_ID, 'PARENT_JOB' as JOB_TYPE  FROM\n" +
                "      (SELECT instance_id FROM\n" +
                "        (SELECT wfri.instance_id, workflow_nme FROM   FT_WF_WFRI wfri\n" +
                "        JOIN FT_WF_WFDF wfdf \n" +
                "        USING (workflow_id)\n" +
                "        where wfri.instance_id = '${flowResultId}'\n" +
                "        ) iview\n" +
                "      ) runtime_instance,\n" +
                "      ft_t_jblg jblg\n" +
                "    WHERE JBLG.INSTANCE_ID = RUNTIME_INSTANCE.INSTANCE_ID)\n" +
                "SELECT JOB_ID as " + var + " FROM JOB_DETAILS WHERE JOB_TYPE = CASE WHEN EXISTS (SELECT 1 FROM JOB_DETAILS WHERE JOB_TYPE = 'CHILD_JOB') THEN 'CHILD_JOB' ELSE 'PARENT_JOB' END";

        databaseSvc.executeSqlQueryAssignResultsToVars(sqlQuery, Collections.singletonList(var));
    }

    /**
     * Expect there are no duplicates records in file.
     *
     * @param file the filepath
     */
    public void iExpectThereAreNoDuplicatesRecordsInFile(final String file) {
        final String expandFile = workspaceDirSvc.normalize(stateSvc.expandVar(file));
        if (dmpFileHandlingUtl.hasDuplicateRecordsInFile(expandFile)) {
            LOGGER.error("Duplicate records found in the file [{}]", expandFile);
            throw new CartException(CartExceptionType.VERIFICATION_FAILED, "Duplicate records found in the file [{}]", expandFile);
        }
    }

    /**
     * Verify no of occurrences of string in file.
     *
     * @param strToSearch the str to search
     * @param file        the file
     * @param expectedCnt the expected cnt
     */
    public void verifyNoOfOccurrencesOfStringInFile(final String strToSearch, final String file, final Integer expectedCnt) {
        final String expandFile = workspaceDirSvc.normalize(stateSvc.expandVar(file));
        final String expandString = stateSvc.expandVar(strToSearch);
        final Integer expandExpectedCnt = Integer.valueOf(stateSvc.expandVar(String.valueOf(expectedCnt)));

        final String fileContent = fileDirUtil.readFileToString(expandFile);
        Integer actualCnt = StringUtils.countOccurrencesOf(fileContent, expandString);

        if (!expandExpectedCnt.equals(actualCnt)) {
            LOGGER.error("Verification failed as Expected No.of Occurrences of String [{}] are [{}], but actual are [{}]", expandString, expandExpectedCnt, actualCnt);
            throw new CartException(CartExceptionType.VERIFICATION_FAILED, "Verification failed as Expected No.of Occurrences of String [{}] are [{}], but actual are [{}]", expandString, expandExpectedCnt, actualCnt);
        }
    }

    public void sendEmailUsingTemplate(String emailBodyTemplatesDir, String emailBodyDir, DataTable emailParamsMap) {
        Map<String, String> templateParamsMap = dataTableUtil.getTwoColumnAsMap(emailParamsMap);
        final String expandTemplateString = stateSvc.expandVar(emailBodyTemplatesDir);
        researchReportEmailSvc.sendEmailUsingBodyTemplate(expandTemplateString, emailBodyDir, templateParamsMap);
    }

    public void postOrderUsingBRSApi(String brsapiBodyTemplatesDir, String brsapiBodyDir, DataTable orderParamsTable) {
        Map<String, String> templateParamsMap = dataTableUtil.getTwoColumnAsMap(orderParamsTable);
        this.exitIfNotTestPortfolio(templateParamsMap.get("PORTFOLIO_TICKER"));
        researchReportBrsApiSvc.postBRSOrderUsingBodyTemplate(brsapiBodyTemplatesDir, brsapiBodyDir, templateParamsMap);
    }

    public void retrieveOrderUsingBRSApi(String brsapiResponse, String orderNumber, DataTable orderRetrieveParamsTable) {
        Map<String, String> orderParamsMap = dataTableUtil.getTwoColumnAsMap(orderRetrieveParamsTable);
        researchReportBrsApiSvc.retrieveBRSOrderDetails(brsapiResponse, orderNumber, orderParamsMap);
    }

    public void retrieveTradeUsingBRSApi(String tradeReference, List<String> tradeVars) {
        final String expandTradeRef = stateSvc.expandVar(tradeReference);
        final Map<String, Object> tradeRecordDetails = researchReportBrsApiSvc.retrieveBRSTradeDetails(expandTradeRef);

        for (String key : tradeVars) {
            final String value = (String) tradeRecordDetails.getOrDefault(key, "Json key not available");
            stateSvc.setStringVar(key, value);
        }
    }

    public void placeTradeUsingBrsApi(String postBodyTemplate, Map<String, String> tradeParams) {
        exitIfNotTestPortfolio(tradeParams.get("PORTFOLIO_TICKER"));

        for (Map.Entry<String, String> entry: tradeParams.entrySet()) {
           stateSvc.setStringVar(entry.getKey(), entry.getValue());
        }

        final String absoluteBrsTemplateFilePath = getAbsoluteBrsTemplateFilePath(postBodyTemplate);
        LOGGER.debug("Using [{}] Body Template for Placing Trade", absoluteBrsTemplateFilePath);

        Integer.parseInt(tradeParams.get("TRADE_PRICE"));
        Integer.parseInt(tradeParams.get("TRADE_QTY"));

        final String jsonBodyContent = stateSvc.expandVar(fileDirUtil.readFileToString(absoluteBrsTemplateFilePath));

        final Map<String, Object> allocations = researchReportBrsApiSvc.placeBrsTrade(jsonBodyContent);
        for (Map.Entry<String, Object> entry : allocations.entrySet()) {
            stateSvc.setStringVar(entry.getKey(), entry.getValue().toString());
        }
    }

    //This can be used in Orders function as well while refactoring
    private String getAbsoluteBrsTemplateFilePath(final String templateFileName) {
        final String fullPath = BRS_API_TEMPLATES_RELATIVE_PATH + File.separator + stateSvc.expandVar(templateFileName);
        return workspaceDirSvc.normalize(fullPath);
    }

    /**
     * Extract job id from jblg table then execute FT_T_JBLG query to check number of records success\total\completed in DMP.
     *
     * @param columnName  name of the column to be verified like success, completed or total
     * @param recordCount number of records count
     */
    public void checkProcessWorkFlowRecordCount(String columnName, String recordCount) {
        String expectedColName = null;
        columnName = columnName.toLowerCase();
        switch (columnName) {
            case ("success"):
                expectedColName = "TASK_SUCCESS_CNT";
                break;
            case ("completed"):
                expectedColName = "TASK_CMPLTD_CNT";
                break;
            case ("total"):
                expectedColName = "TASK_TOT_CNT";
                break;
            case ("partial"):
                expectedColName = "TASK_PARTIAL_CNT";
                break;
            case ("filtered"):
                expectedColName = "TASK_FILTERED_CNT";
                break;
            case ("fail"):
                expectedColName = "TASK_FAILED_CNT";
        }
        iExtractJobIdFromJblgTable("JOB_ID");
        final String jblgSql = "SELECT COUNT(*) AS JBLG_ROW_COUNT FROM FT_T_JBLG\n" +
                "WHERE JOB_ID = '${JOB_ID}'\n" +
                "AND " + expectedColName + " ='" + recordCount + "'\n" +
                "AND JOB_STAT_TYP ='CLOSED'";
        databaseSteps.iExpectValueOfColumnShouldMatch("JBLG_ROW_COUNT", "1", jblgSql);
    }


    public void compareExcelFiles(final String actualFilePath, final String expectedFilePath, final Integer sheetIndex) {
        final String actualExcel = workspaceDirSvc.normalize(stateSvc.expandVar(actualFilePath));
        final String actualCsv = fileDirUtil.getTempDir() + File.separator + fileDirUtil.getFileName(actualExcel, true) + ".csv";

        final String expectedExcel = workspaceDirSvc.normalize(stateSvc.expandVar(expectedFilePath));
        final String expectedCsv = fileDirUtil.getTempDir() + File.separator + fileDirUtil.getFileName(expectedExcel, true) + ".csv";

        final String exceptionsFile = fileDirUtil.getFileParentAbsolutePath(expectedExcel) + File.separator + "exceptions_" + dateTimeUtil.getTimestamp() + ".csv";

        excelFileSvc.convertExcelToCsv(actualExcel, actualCsv, sheetIndex);
        excelFileSvc.convertExcelToCsv(expectedExcel, expectedCsv, sheetIndex);

        LOGGER.debug("actualCsv [{}]", actualCsv);
        LOGGER.debug("expectedCsv [{}]", expectedCsv);
        LOGGER.debug("exceptionsCsv [{}]", exceptionsFile);

        this.expectBothFilesShouldBeSame(actualCsv, expectedCsv, exceptionsFile);
    }

    public void iExpectRecordsAreSorted(String file) {
        final String expandedFile = workspaceDirSvc.normalize(stateSvc.expandVar(file));
        LOGGER.debug(expandedFile);

        if (!fileDirUtil.verifyFileExists(expandedFile)) {
            LOGGER.error("File [{}] does not exists!", expandedFile);
            throw new CartException(CartExceptionType.IO_ERROR, "File [{}] does not exists!", expandedFile);
        } else {
            if (!checkSortingOrderInHiportFile(expandedFile)) {
                LOGGER.error("Sorting order applied to the records is incorrect in file {}", file);
                throw new CartException(CartExceptionType.VERIFICATION_FAILED, "Verification failed for sorting order of published file {}", file);

            }
        }
    }

    private boolean checkSortingOrderInHiportFile(String file) {
        List<String> buyTxnCode = Arrays.asList("01", "03", "19");
        List<String> sellTxnCode = Arrays.asList("02", "04", "20");

        List<String> contents = dmpFileHandlingUtl.getFileContentToList(file);

        List<String> fileContents = contents.subList(1, contents.size() - 1).stream()
                .map(txnTypes -> txnTypes.substring(20, 22))
                .collect(Collectors.toList());

        List<Integer> buyRowNo = fileContents.stream()
                .filter(txnTypes -> buyTxnCode.contains(txnTypes))
                .map(rowNo -> fileContents.indexOf(rowNo))
                .collect(Collectors.toList());

        List<Integer> sellRowNo = fileContents.stream()
                .filter(txnTypes -> sellTxnCode.contains(txnTypes))
                .map(rowNo -> fileContents.indexOf(rowNo))
                .collect(Collectors.toList());

        boolean isSorted = false;

        if (buyRowNo.size() == 0 || sellRowNo.size() == 0) {
            isSorted = true;
        } else {
            for (int rowListIndex = 0; rowListIndex < buyRowNo.size(); rowListIndex++) {
                if (buyRowNo.get(rowListIndex) < sellRowNo.get(0)) {
                    isSorted = true;
                } else {
                    throw new CartException(CartExceptionType.VERIFICATION_FAILED, "Verification failed for sorting order of published file {}", file);
                }
            }
        }
        return isSorted;
    }

    void exitIfNotTestPortfolio(final String portfolioName) {
        final List<String> portfolio = TEST_PORTFOLIO_NAMING_PATTERN.stream().
                filter(portfolioName::startsWith).collect(Collectors.toList());
        if (portfolio.isEmpty()) {
            LOGGER.error("Test User cannot place order for live portfolio [{}]", portfolioName);
            throw new CartException(CartExceptionType.VALIDATION_FAILED, "Test User cannot place order for live portfolio [{}]", portfolioName);
        }
    }
}
