package com.eastspring.tom.cart.core.svc;

import com.eastspring.tom.cart.core.CartException;
import com.eastspring.tom.cart.core.CartExceptionType;
import com.eastspring.tom.cart.core.mdl.*;
import com.eastspring.tom.cart.core.utl.*;
import com.eastspring.tom.cart.cst.EncodingConstants;
import freemarker.template.Template;
import freemarker.template.TemplateException;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;

import java.io.File;
import java.io.IOException;
import java.sql.PreparedStatement;
import java.sql.SQLException;
import java.util.Arrays;
import java.util.Collections;
import java.util.List;
import java.util.Map;

import static com.eastspring.tom.cart.core.svc.JdbcSvc.INTERNAL_DB_RECON;

public class ReconciliationSvc {
    private static final Logger LOGGER = LoggerFactory.getLogger(ReconciliationSvc.class);

    public static final String SOURCE_SURPLUS = "SourceSurplus";
    public static final String MISMATCH = "Mismatch";
    public static final String MATCH = "Match";
    public static final String TARGET_SURPLUS = "TargetSurplus";
    public static final String SELECT_MATCH_MISMATCH_TEMPLATE = "SELECT Mismatch, Match, SourceSurplus, TargetSurplus FROM ComparisonRequest WHERE ComparisonRequestId=%s";
    public static final String SELECT_REPORT_ATTRIBUTES_TEMPLATE = "SELECT b.ComparisonGUID, b.NumericTolerance, b.CaseSensitive, b.StartTime, b.EndTime, b.SourceRecordCount, b.TargetRecordCount, b.SourceDuplicateRecordCount, b.TargetDuplicateRecordCount, b.SourceSurplusRecordCount, b.TargetSurplusRecordCount, b.MismatchRecordCount FROM (SELECT MAX(ComparisonRequestId) AS LastId FROM dbo.ComparisonRequest) a LEFT JOIN dbo.ComparisonRequest b ON a.LastId = b.ComparisonRequestId";
    public static final String KEY = "KEY";
    public static final String MATCH_NAME = "Match";
    public static final String MATCH_WITH_TOLERANCE_NAME = "Match~";

    protected static final List<String> COLUMN_LIST = Arrays.asList("SEQ_ID", "NAME", "PORTFOLIO_ID", "MONTHLY_AMOUNT", "DESCRIPTION");
    protected static final List<String> KEY_COLUMN_LIST = Arrays.asList("NAME", "PORTFOLIO_ID");

    public static final String INMEM_DB_NAME = "reconc.db.INMEM";
    public static final String RECONC_TABLE_1 = "RECONC_TABLE_1";
    public static final String RECONC_TABLE_2 = "RECONC_TABLE_2";

    public static final String RECON_GLOBAL_NUMERICAL_MATCH_TOLERANCE = "recon.global.numerical.match.tolerance";
    public static final String RECON_GLOBAL_NUMERICAL_MATCH_TYPE = "recon.global.numerical.match.type";
    public static final String READ_CSV_CREATE_TABLE_SQL = "CREATE TABLE %s (SEQ_ID VARCHAR(255), NAME VARCHAR(255), PORTFOLIO_ID VARCHAR(255), MONTHLY_AMOUNT NUMERIC(31,15), DESCRIPTION VARCHAR(255))";
    public static final String INSERT_INTO_CSV_SQL = "INSERT INTO %s (SEQ_ID, NAME, PORTFOLIO_ID, MONTHLY_AMOUNT, DESCRIPTION) SELECT SEQ_ID, NAME, PORTFOLIO_ID, MONTHLY_AMOUNT, DESCRIPTION FROM CSVREAD('%s')";
    public static final String SOURCE_MONIKER = "SourceMoniker";
    public static final String TARGET_MONIKER = "TargetMoniker";

    @Autowired
    private CsvSvc csvSvc;

    @Autowired
    private DatabaseSvc databaseSvc;

    @Autowired
    private ExcelFileSvc excelFileSvc;

    @Autowired
    private FmTemplateSvc fmTemplateSvc;

    @Autowired
    private JdbcSvc jdbcSvc;

    @Autowired
    private FileDirUtil fileDirUtil;

    @Autowired
    private FlywayUtil flywayUtil;

    @Autowired
    private FormatterUtil formatterUtil;

    @Autowired
    private SqlStringUtil sqlStringUtil;

    @Autowired
    private StateSvc stateSvc;

    @Autowired
    private WorkspaceUtil workspaceUtil;

    @Autowired
    private WriterUtil writerUtil;

    @Autowired
    private ScenarioUtil scenarioUtil;


    public void initNamedInMemoryDb() {
        jdbcSvc.createNamedConnection(ReconciliationSvc.INMEM_DB_NAME);
    }

    private List<String> constructReconProcedureInParams(final Map<String, String> params) {
        String[] inParams = new String[15];
        inParams[0] = params.get("SourceTable");
        inParams[1] = params.get("TargetTable");
        inParams[2] = params.get("MatchKeySourceList");
        if (!"null".equalsIgnoreCase(params.get("ExcludedColumnSourceList")))
            inParams[3] = params.get("ExcludedColumnSourceList");
        if (!"null".equalsIgnoreCase(params.get("ExcludedColumnTargetList")))
            inParams[4] = params.get("ExcludedColumnTargetList");
        if (!"null".equalsIgnoreCase(params.get("DisplayOnlyColumnSourceList")))
            inParams[5] = params.get("DisplayOnlyColumnSourceList");
        if (!"null".equalsIgnoreCase(params.get("DisplayOnlyColumnTargetList")))
            inParams[6] = params.get("DisplayOnlyColumnTargetList");
        if (!"null".equalsIgnoreCase(params.get("ColumnMappingList")))
            inParams[7] = params.get("ColumnMappingList");
        if (!"null".equalsIgnoreCase(params.get("NumericTolerance")))
            inParams[8] = params.get("NumericTolerance");
        if (!"null".equalsIgnoreCase(params.get("CaseSensitiveFlag")))
            inParams[9] = params.get("CaseSensitiveFlag");
        if (!"null".equalsIgnoreCase(params.get("IgnoreOrphanColumnsFlag")))
            inParams[10] = params.get("IgnoreOrphanColumnsFlag");
        inParams[11] = params.get("0"); //OptimizedStorageFlag

        if (!"null".equalsIgnoreCase(params.get(SOURCE_MONIKER))) {
            inParams[12] = params.get(SOURCE_MONIKER);
            stateSvc.setStringVar(SOURCE_MONIKER, inParams[12]);
        } else {
            stateSvc.setStringVar(SOURCE_MONIKER, "A");
        }

        if (!"null".equalsIgnoreCase(params.get(TARGET_MONIKER))) {
            inParams[13] = params.get(TARGET_MONIKER);
            stateSvc.setStringVar(TARGET_MONIKER, inParams[13]);
        } else {
            stateSvc.setStringVar(TARGET_MONIKER, "B");
        }
        return Arrays.asList(inParams);
    }

    /**
     * Reconcile.
     * Call dbo.Compare stored procedure with given inParams
     * ComparisonRequestId will be stored into a variable, which is a key value to retrieve the result set
     *
     * @param connName the conn name
     * @param params   the Stored procedure params
     */
    public void reconcile(final String connName, final Map<String, String> params) {
        jdbcSvc.executeStoredProcedureOnNamedConnection(connName, "dbo.Compare", constructReconProcedureInParams(params),
                Collections.singletonList("ComparisonRequestId"));
    }

    public void validateReconciliations(final String connName, final Integer comparisonRequestId) {
        String sql = "select * from dbo.ComparisonRequest where ComparisonRequestId = " + comparisonRequestId;
        ComparisonRequest result = jdbcSvc.executeQueryOnNamedConnectionLoadResultIntoObject(connName, sql, ComparisonRequest.class).get(0);
        if (!result.getSourceRecordCount().equals(result.getMatchRecordCount())) {
            this.generateReconExceptionsFiles(result);
        } else {
            LOGGER.info("Reconciliation is successful");
        }
    }

    private void logMismatchSmells(ComparisonRequest resultObject) {
        String sql = "select ColumnName from " + resultObject.getMismatchSmellView() + " where MismatchCount <> 0";
        List<String> smellColumns = jdbcSvc.getColumnValuesOnNamedConnection(databaseSvc.getCurrentConfigPrefix(), sql, "ColumnName");
        LOGGER.error("Column mismatches are found in [{}] columns", smellColumns);
    }

    private void generateReconExceptionsFiles(ComparisonRequest comparisonRequest) {
        File tempDir = fileDirUtil.createTempDir("ReconExceptions_");
        try {
            String sql = "select * from %s";

            if (comparisonRequest.getSourceDuplicateRecordCount() > 0) {
                LOGGER.error("There are Duplicate Records found in Source table [{}]", comparisonRequest.getSourceTable());
                String csvFilePath = tempDir + File.separator + "source_duplicates.csv";
                databaseSvc.exportQueryTableDataToCSVFile(csvFilePath, formatterUtil.format(sql, comparisonRequest.getSourceDuplicateView()));
            }

            if (comparisonRequest.getSourceSurplusRecordCount() > 0) {
                LOGGER.error("There are Surplus Records found in Source table [{}]", comparisonRequest.getSourceTable());
                String csvFilePath = tempDir + File.separator + "source_surplus.csv";
                databaseSvc.exportQueryTableDataToCSVFile(csvFilePath, formatterUtil.format(sql, comparisonRequest.getSourceSurplusView()));
            }

            if (comparisonRequest.getTargetDuplicateRecordCount() > 0) {
                LOGGER.error("There are Duplicate Records found in Target table [{}]", comparisonRequest.getTargetTable());
                String csvFilePath = tempDir + File.separator + "target_duplicates.csv";
                databaseSvc.exportQueryTableDataToCSVFile(csvFilePath, formatterUtil.format(sql, comparisonRequest.getTargetDuplicateView()));
            }

            if (comparisonRequest.getTargetSurplusRecordCount() > 0) {
                LOGGER.error("There are Surplus Records found in Target table [{}]", comparisonRequest.getTargetTable());
                String csvFilePath = tempDir + File.separator + "target_surplus.csv";
                databaseSvc.exportQueryTableDataToCSVFile(csvFilePath, formatterUtil.format(sql, comparisonRequest.getTargetSurplusView()));
            }

            if (comparisonRequest.getMismatchRecordCount() > 0) {
                LOGGER.error("There are Mismatches in the Source [{}] and Target [{}] tables records", comparisonRequest.getSourceTable(), comparisonRequest.getTargetTable());
                this.logMismatchSmells(comparisonRequest);
                String tempCsvFilePath = tempDir + File.separator + "mismatches.csv";
                String excelFilePath = tempDir + File.separator + "mismatches.xls";
                databaseSvc.exportQueryTableDataToCSVFile(tempCsvFilePath, formatterUtil.format(sql, comparisonRequest.getMismatchView()));

                HighlightedExcelRequest request = new HighlightedExcelRequest();
                request.setCsvFileFullpath(tempCsvFilePath);
                request.setHighlightedExcelFileFullpath(excelFilePath);
                request.setSourceName(stateSvc.getStringVar(SOURCE_MONIKER));
                request.setTargetName(stateSvc.getStringVar(TARGET_MONIKER));
                request.setMatchName(ReconciliationSvc.MATCH_NAME);
                request.setMatchWithToleranceName(ReconciliationSvc.MATCH_WITH_TOLERANCE_NAME);
                request.setEncoding(EncodingConstants.UTF_8);
                request.setSeparator(',');
                this.generateXLSFromMismatchCSV(request);
            }
        } catch (Exception e) {
            LOGGER.error("Exception occurred while capturing Recon Exceptions!!!");
            throw new CartException(CartExceptionType.PROCESSING_FAILED, "Exception occurred while capturing Recon Exceptions!!!");
        }
        scenarioUtil.write("Exception files are created in " + tempDir.getAbsolutePath());
        fileDirUtil.openFolderInFileExplorer(tempDir.getAbsolutePath());
        LOGGER.error("Reconciliation is unsuccessful");
        throw new CartException(CartExceptionType.VERIFICATION_FAILED, "Reconciliation is unsuccessful");
    }

    public void generateXLSFromMismatchCSV(HighlightedExcelRequest request) {
        CsvProfile csvProfile = csvSvc.profileCsvCols(request.getCsvFileFullpath(), request.getEncoding(), request.getSeparator());
        List<KeyMetadata> keyMetadataList = csvSvc.getKeyMetadataFromHeader(csvProfile, KEY);
        SourceTargetMatch sourceTargetMatch = new SourceTargetMatch(request.getSourceName(), request.getTargetName(), request.getMatchName());
        List<ComparisonColPairMetadata> metadataList = csvSvc.getComparisonColPairMetadataFromHeader(csvProfile, sourceTargetMatch, request.getMatchWithToleranceName());
        ExcelFileSvc.ExcelWorkbook workbook = excelFileSvc.createNewWorkbook(ExcelFileSvc.WorkbookType.XLS);
        excelFileSvc.writeAsHighlightedFile(workbook, request.getCsvFileFullpath(), request.getHighlightedExcelFileFullpath(), keyMetadataList, metadataList, ReconciliationSvc.MISMATCH);
        fileDirUtil.forceDelete(request.getCsvFileFullpath());
    }

    public void reconcile(String connName, String csvFilename1, String csvFilename2, String leftOnlyFilename, String rightOnlyFilename) {
        LOGGER.debug("reconcile(), connName={}, csvFilename1={}, csvFilname2={}, leftOnlyFilename={}, rightOnlyFilename={}", connName, csvFilename1, csvFilename2, leftOnlyFilename, rightOnlyFilename);

        String createTable1 = generateReadCsvCreateTable(RECONC_TABLE_1);
        jdbcSvc.executeOnNamedConnection(connName, createTable1);
        String insertTable1 = generateReadCsvInsertIntoStatement(RECONC_TABLE_1, csvFilename1);
        jdbcSvc.executeOnNamedConnection(connName, insertTable1);

        String createTable2 = generateReadCsvCreateTable(RECONC_TABLE_2);
        jdbcSvc.executeOnNamedConnection(connName, createTable2);
        String insertTable2 = generateReadCsvInsertIntoStatement(RECONC_TABLE_2, csvFilename2);
        jdbcSvc.executeOnNamedConnection(connName, insertTable2);

        fileDirUtil.forceCreateDirContainingFile(leftOnlyFilename);
        fileDirUtil.forceCreateDirContainingFile(rightOnlyFilename);

        String leftOnlySqlQuery = generateOuterOnlyQuery(leftOnlyFilename, RECONC_TABLE_1, RECONC_TABLE_2, COLUMN_LIST, KEY_COLUMN_LIST);
        String rightOnlySqlQuery = generateOuterOnlyQuery(leftOnlyFilename, RECONC_TABLE_2, RECONC_TABLE_1, COLUMN_LIST, KEY_COLUMN_LIST);
        jdbcSvc.executeOnNamedConnection(connName, leftOnlySqlQuery);
        jdbcSvc.executeOnNamedConnection(connName, rightOnlySqlQuery);
    }

    public String generateOuterOnlyQuery(String csvFilename, String tableName1, String tableName2, List<String> columnList, List<String> keyColumnList) {
        StringBuilder formatterSb = new StringBuilder("CALL CSVWRITE('%s', 'SELECT ");
        formatterSb.append(sqlStringUtil.zipJoin(columnList, ", ", "a.", ""));
        formatterSb.append(" FROM %s a LEFT JOIN %s b ON ");
        formatterSb.append(sqlStringUtil.zipJoinJoinClause(keyColumnList, "a", "b"));
        formatterSb.append(" WHERE b.");
        formatterSb.append(keyColumnList.get(0));
        formatterSb.append(" IS NULL', 'charset=UTF-8 fieldSeparator=,')");
        return formatterUtil.format(formatterSb.toString(), csvFilename, tableName1, tableName2);
    }

    public String generateReadCsvCreateTable(String table) {
        String sqlStmt = formatterUtil.format(READ_CSV_CREATE_TABLE_SQL, table);
        LOGGER.debug("  sqlStmt: [{}]", sqlStmt);
        return sqlStmt;
    }

    public String generateReadCsvInsertIntoStatement(String table, String csvFilename) {
        LOGGER.debug("readCsvToTable: reading file [{}]", csvFilename);
        String csvInsertIntoStmt = formatterUtil.format(INSERT_INTO_CSV_SQL, table, csvFilename);
        LOGGER.debug("  csvInsertIntoStmt: [{}]", csvInsertIntoStmt);
        return csvInsertIntoStmt;
    }


    /**
     * <p>This method sets the global match tolerance.</p>
     * <p>The global match tolerance will be used a the default tolerance whenever possible on all numeric reconciliation
     * unless there are column level overrides.</p>
     *
     * @param tolerance global (blanket) match tolerance
     */
    public void setGlobalNumericalMatchTolerance(String tolerance) {
        stateSvc.setStringVar(RECON_GLOBAL_NUMERICAL_MATCH_TOLERANCE, tolerance);
    }

    public void setGlobalNumericalMatchToleranceType(MatchTolerance matchToleranceType) {
        stateSvc.setStringVar(RECON_GLOBAL_NUMERICAL_MATCH_TYPE, matchToleranceType.name());
    }

    /**
     * <p>This method loads the given CSV file to the Test Automation framework&aphos;s into a database table
     * as <b>varchar</b> with minimal possible column length.</p>
     *
     * @param srcDir    the folder location of the CSV file
     * @param filename  the CSV filename
     * @param tableName table name
     * @param encoding  encoding
     * @param separator separator
     */
    public void loadCsvToReconDb(String srcDir, String filename, String tableName, String encoding, char separator, ColumnFilterPredicate columnFilterPredicate) {
        loadCsvToReconDb2(new CsvLoadInfo(srcDir, filename, tableName, encoding), separator, columnFilterPredicate, 20, null, false);
    }

    public void loadCsvToReconDb2(CsvLoadInfo csvLoadInfo, char separator, ColumnFilterPredicate columnFilterPredicate, int sqlCreateMinChar, String createTableSql, boolean bnpDna) {
        // used in:
        // - ABOR/IBOR Performance and Attribution reconciliation (L1 Report)
        // - Equity Performance and Attribution reconciliation (L3 Report)
        jdbcSvc.createNamedConnection(INTERNAL_DB_RECON);
        String fullpath = csvLoadInfo.getSrcDir() + '/' + csvLoadInfo.getFilename();
        String tableName = csvLoadInfo.getTableName();
        String encoding = csvLoadInfo.getEncoding();
        LOGGER.debug("tableName: [{}]", tableName);
        LOGGER.debug("fullpath: [{}]", fullpath);
        SqlCsvResult sqlCsvResult = csvSvc.getSqlCreateTableFromCsv2(tableName, fullpath, encoding, separator, sqlCreateMinChar);
        CsvProfile csvProfile = sqlCsvResult.getCsvProfile();
        if (createTableSql == null) {
            String sqlcCreateTableDdl = sqlCsvResult.getSqlQuery();
            jdbcSvc.executeOnNamedConnection(INTERNAL_DB_RECON, sqlcCreateTableDdl);
        } else {
            jdbcSvc.executeOnNamedConnection(INTERNAL_DB_RECON, createTableSql);
        }
        String sqlInsertCommand = csvSvc.getPrepStmtInsertCommand(tableName, Arrays.asList(csvProfile.getHeaders()));
        PreparedStatement preparedStatement = jdbcSvc.getPreparedStatementOnNamedConnection(INTERNAL_DB_RECON, sqlInsertCommand);

        if (bnpDna) {
            csvSvc.bnpDnaInsertPreparedStatementFromCsvFile(fullpath, INTERNAL_DB_RECON, csvProfile.getHeaderCount(), preparedStatement, columnFilterPredicate, encoding, separator);
        } else {
            csvSvc.insertPreparedStatementFromCsvFile(fullpath, INTERNAL_DB_RECON, csvProfile.getHeaderCount(), preparedStatement, columnFilterPredicate, encoding, separator);
        }

        try {
            preparedStatement.close();
        } catch (SQLException e) {
            LOGGER.error("failed to close prepared statement", e);
            throw new CartException(CartExceptionType.UNSATISFIED_IMPLICIT_ASSUMPTION, "failed to close prepared statement");
        }
    }


    /**
     * <p>This method prepares the database reconciliation engine.</p>
     */
    public void prepareDbReconciliationEngine() {
        databaseSvc.setDatabaseConnectionToConfig(INTERNAL_DB_RECON);
        String jdbcUrl = stateSvc.getStringVar(INTERNAL_DB_RECON + ".jdbc.url");
        String jdbcUser = stateSvc.getStringVar(INTERNAL_DB_RECON + ".jdbc.user");
        String jdbcPass = stateSvc.getStringVar(INTERNAL_DB_RECON + ".jdbc.pass");

        LOGGER.debug("prepareDbReconciliationEngine: init internal database for reconciliation");
        LOGGER.debug("  jdbcUrl: [{}]", jdbcUrl);
        LOGGER.debug("  jdbcUser: [{}]", jdbcUser);
        LOGGER.debug("  jdbcPass: ********");
        flywayUtil.setDataSource(jdbcUrl, jdbcUser, jdbcPass);
        flywayUtil.baseline();
        flywayUtil.migrate();
    }

    public void generateDbReconcileSummaryReport(String reportFile, String templateLocation, String templateFile) {
        jdbcSvc.createNamedConnection(INTERNAL_DB_RECON);
        Map<String, String> dataModel = jdbcSvc.executeSingleRowQueryOnNamedConnection(INTERNAL_DB_RECON, SELECT_REPORT_ATTRIBUTES_TEMPLATE);

        String reportDirName = new File(reportFile).getAbsoluteFile().getParentFile().getAbsolutePath();
        LOGGER.debug("creating folder [{}]", reportDirName);
        fileDirUtil.forceMakeDirs(reportDirName);
        String templateDir = workspaceUtil.getTestDataDir() + '/' + templateLocation;
        LOGGER.debug("template location: [{}]", templateDir);
        fmTemplateSvc.setTemplateLocation(templateDir);
        Template template;
        try {
            LOGGER.debug("template file: [{}]", templateFile);
            template = fmTemplateSvc.getTemplate(templateFile);
            template.process(dataModel, writerUtil.getPrintWriterByPrintStream(System.out)); // NOSONAR
            template.process(dataModel, writerUtil.getPrintWriterByFilename(reportFile));
        } catch (TemplateException e) {
            LOGGER.error("error writing using template file [{}]", templateFile, e);
            throw new CartException(CartExceptionType.UNSATISFIED_IMPLICIT_ASSUMPTION, "error writing using template file [{}]", templateFile);
        } catch (IOException e) {
            LOGGER.error("error while writing to report file [{}]", reportFile, e);
            throw new CartException(CartExceptionType.IO_ERROR, "error while writing to report file [{}]", reportFile);
        }
    }

    public void exportMatchMismatchToCsvFile(String matchFileFullpath, String mismatchFileFullpath, String sourceSurplusFileFullpath, String targetSurplusFileFullpath, int fixedDigits) {
        // used in:
        // - Performance L1
        // - Performance L3
        jdbcSvc.createNamedConnection(INTERNAL_DB_RECON);
        String selectLatestComparisonId = "SELECT MAX(ComparisonRequestId) AS LatestComparisonRequestId FROM ComparisonRequest";
        Map<String, String> result = jdbcSvc.executeSingleRowQueryOnNamedConnection(INTERNAL_DB_RECON, selectLatestComparisonId);
        String comparisonRequestId = result.get("LatestComparisonRequestId");
        String selectMatchMismatchQuery = String.format(SELECT_MATCH_MISMATCH_TEMPLATE, comparisonRequestId);
        Map<String, String> dataModel = jdbcSvc.executeSingleRowQueryOnNamedConnection(INTERNAL_DB_RECON, selectMatchMismatchQuery);

        if (fixedDigits <= 0) {
            csvSvc.exportTableViewToCsvFile(INTERNAL_DB_RECON, dataModel.get(MATCH), matchFileFullpath);
            csvSvc.exportTableViewToCsvFile(INTERNAL_DB_RECON, dataModel.get(MISMATCH), mismatchFileFullpath);
            csvSvc.exportTableViewToCsvFile(INTERNAL_DB_RECON, dataModel.get(SOURCE_SURPLUS), sourceSurplusFileFullpath);
            csvSvc.exportTableViewToCsvFile(INTERNAL_DB_RECON, dataModel.get(TARGET_SURPLUS), targetSurplusFileFullpath);

        } else {
            csvSvc.exportTableViewToCsvFileWithFixedDigitNums(INTERNAL_DB_RECON, dataModel.get(MATCH), matchFileFullpath, fixedDigits);
            csvSvc.exportTableViewToCsvFileWithFixedDigitNums(INTERNAL_DB_RECON, dataModel.get(MISMATCH), mismatchFileFullpath, fixedDigits);
            csvSvc.exportTableViewToCsvFileWithFixedDigitNums(INTERNAL_DB_RECON, dataModel.get(SOURCE_SURPLUS), sourceSurplusFileFullpath, fixedDigits);
            csvSvc.exportTableViewToCsvFileWithFixedDigitNums(INTERNAL_DB_RECON, dataModel.get(TARGET_SURPLUS), targetSurplusFileFullpath, fixedDigits);
        }
    }

    public void exportMatchMismatchToCsvFileWithWhereClause(String matchFileFullpath, String mismatchFileFullpath, String sourceSurplusFileFullpath, String targetSurplusFileFullpath, int fixedDigits, String whereClauseMatchMismatch, String whereClauseSurplus) {
        // used in:
        // - Performance L1
        // - Performance L3
        jdbcSvc.createNamedConnection(INTERNAL_DB_RECON);
        String selectLatestComparisonId = "SELECT MAX(ComparisonRequestId) AS LatestComparisonRequestId FROM ComparisonRequest";
        Map<String, String> result = jdbcSvc.executeSingleRowQueryOnNamedConnection(INTERNAL_DB_RECON, selectLatestComparisonId);
        String comparisonRequestId = result.get("LatestComparisonRequestId");
        String selectMatchMismatchQuery = String.format(SELECT_MATCH_MISMATCH_TEMPLATE, comparisonRequestId);
        Map<String, String> dataModel = jdbcSvc.executeSingleRowQueryOnNamedConnection(INTERNAL_DB_RECON, selectMatchMismatchQuery);

        if (fixedDigits <= 0) {
            csvSvc.exportTableViewToCsvFileWithWhereClause(INTERNAL_DB_RECON, dataModel.get(MATCH), matchFileFullpath, whereClauseMatchMismatch);
            csvSvc.exportTableViewToCsvFileWithWhereClause(INTERNAL_DB_RECON, dataModel.get(MISMATCH), mismatchFileFullpath, whereClauseMatchMismatch);
            csvSvc.exportTableViewToCsvFileWithWhereClause(INTERNAL_DB_RECON, dataModel.get(SOURCE_SURPLUS), sourceSurplusFileFullpath, whereClauseSurplus);
            csvSvc.exportTableViewToCsvFileWithWhereClause(INTERNAL_DB_RECON, dataModel.get(TARGET_SURPLUS), targetSurplusFileFullpath, whereClauseSurplus);

        } else {
            csvSvc.exportTableViewToCsvFileWithFixedDigitNumsWithWhereClause(INTERNAL_DB_RECON, dataModel.get(MATCH), matchFileFullpath, fixedDigits, whereClauseMatchMismatch);
            csvSvc.exportTableViewToCsvFileWithFixedDigitNumsWithWhereClause(INTERNAL_DB_RECON, dataModel.get(MISMATCH), mismatchFileFullpath, fixedDigits, whereClauseMatchMismatch);
            csvSvc.exportTableViewToCsvFileWithFixedDigitNumsWithWhereClause(INTERNAL_DB_RECON, dataModel.get(SOURCE_SURPLUS), sourceSurplusFileFullpath, fixedDigits, whereClauseSurplus);
            csvSvc.exportTableViewToCsvFileWithFixedDigitNumsWithWhereClause(INTERNAL_DB_RECON, dataModel.get(TARGET_SURPLUS), targetSurplusFileFullpath, fixedDigits, whereClauseSurplus);
        }
    }


    public void getHighlightedExcelFileFromCsvFile(String csvFileFullpath, String excelFileFullpath, SourceTargetMatch sourceTargetMatch, String matchWithToleranceName, String encoding, char separator) {
        // used in:
        // - Performance and Attribution reconciliation (L1 Report)
        CsvProfile csvProfile = csvSvc.profileCsvCols(csvFileFullpath, encoding, separator);
        List<KeyMetadata> keyMetadataList = csvSvc.getKeyMetadataFromHeader(csvProfile, KEY);
        List<ComparisonColPairMetadata> metadataList = csvSvc.getComparisonColPairMetadataFromHeader(csvProfile, sourceTargetMatch, matchWithToleranceName);
        ExcelFileSvc.ExcelWorkbook workbook = excelFileSvc.createNewWorkbook(ExcelFileSvc.WorkbookType.XLS);
        excelFileSvc.writeAsHighlightedFile(workbook, csvFileFullpath, excelFileFullpath, keyMetadataList, metadataList, ReconciliationSvc.MISMATCH);
    }

}
