package com.eastspring.tom.cart.core.svc;

import com.eastspring.tom.cart.core.CartCoreTestConfig;
import com.eastspring.tom.cart.core.utl.*;
import freemarker.template.Template;
import org.junit.Before;
import org.junit.BeforeClass;
import org.junit.Test;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.MockitoAnnotations;

import java.io.File;
import java.io.PrintWriter;
import java.util.HashMap;
import java.util.Map;

import static com.eastspring.tom.cart.core.svc.JdbcSvc.INTERNAL_DB_RECON;
import static com.eastspring.tom.cart.core.svc.ReconciliationSvc.SELECT_REPORT_ATTRIBUTES_TEMPLATE;
import static org.mockito.Mockito.*;

public class ReconciliationSvcTest {
    @InjectMocks
    private ReconciliationSvc reconciliationSvc;

    @Mock
    private CsvSvc csvSvc;

    @Mock
    private FileDirUtil fileDirUtil;

    @Mock
    private FmTemplateSvc fmTemplateSvc;

    @Mock
    private JdbcSvc jdbcSvc;

    @Mock
    private Template template;

    @Mock
    private WorkspaceUtil workspaceUtil;

    @Mock
    private WriterUtil writerUtil;

    @Before
    public void initMocks() {
        MockitoAnnotations.initMocks(this);
    }

    @BeforeClass
    public static void initLogging() {
        CartCoreTestConfig.configureLogging(ReconciliationSvcTest.class);
    }

    @Test
    public void testExportMatchMismatchToCsvFile() {
        String comparisonRequestId = "39";
        String matchFileFullpath = "/a/b/c";
        String mismatchFileFullpath = "/a/b/d";
        String sourceSurplusFileFullpath = "/dir1/source.surplus";
        String targetSurplusFileFullpath = "/dir2/target.surplus";
        Map<String, String> requestIdResultMap = new HashMap<String, String>() {{
            put("LatestComparisonRequestId", comparisonRequestId);
        }};
        Map<String, String> dataMap = new HashMap<String, String>() {{
            put("Match", "matchTableName01");
            put("Mismatch", "mismatchTableName01");
            put("SourceSurplus", "sourceSurplusTableName01");
            put("TargetSurplus", "targetSurplusTableName01");
        }};
        when(jdbcSvc.executeSingleRowQueryOnNamedConnection(INTERNAL_DB_RECON, "SELECT MAX(ComparisonRequestId) AS LatestComparisonRequestId FROM ComparisonRequest")).thenReturn(requestIdResultMap);
        when(jdbcSvc.executeSingleRowQueryOnNamedConnection(INTERNAL_DB_RECON, "SELECT Mismatch, Match, SourceSurplus, TargetSurplus FROM ComparisonRequest WHERE ComparisonRequestId=39")).thenReturn(dataMap);

        reconciliationSvc.exportMatchMismatchToCsvFile(matchFileFullpath, mismatchFileFullpath, sourceSurplusFileFullpath, targetSurplusFileFullpath, 4);
        verify(jdbcSvc, times(1)).createNamedConnection(INTERNAL_DB_RECON);
        verify(csvSvc, times(1)).exportTableViewToCsvFileWithFixedDigitNums(INTERNAL_DB_RECON, "matchTableName01", matchFileFullpath, 4);
        verify(csvSvc, times(1)).exportTableViewToCsvFileWithFixedDigitNums(INTERNAL_DB_RECON, "mismatchTableName01", mismatchFileFullpath, 4);
        verify(csvSvc, times(1)).exportTableViewToCsvFileWithFixedDigitNums(INTERNAL_DB_RECON, "sourceSurplusTableName01", sourceSurplusFileFullpath, 4);
        verify(csvSvc, times(1)).exportTableViewToCsvFileWithFixedDigitNums(INTERNAL_DB_RECON, "targetSurplusTableName01", targetSurplusFileFullpath, 4);
    }

    @Test
    public void testGenerateDbReconcileReport() throws Exception {
        String reportFile = "report-file.file";
        String templateLocation = "template/location";
        String templateFile = "template-file.file";
        Map<String, String> dataMap = new HashMap<String, String>() {{
            put("attribute1", "value1");
        }};
        PrintWriter printWriterSystemOut = new PrintWriter(System.out);
        PrintWriter fileWriter = new PrintWriter(new File(reportFile));
        when(jdbcSvc.executeSingleRowQueryOnNamedConnection(INTERNAL_DB_RECON, SELECT_REPORT_ATTRIBUTES_TEMPLATE)).thenReturn(dataMap);
        when(fmTemplateSvc.getTemplate(templateFile)).thenReturn(template);
        when(writerUtil.getPrintWriterByPrintStream(System.out)).thenReturn(printWriterSystemOut);
        when(writerUtil.getPrintWriterByFilename(reportFile)).thenReturn(fileWriter);
        when(workspaceUtil.getTestDataDir()).thenReturn("c:/testdata");

        reconciliationSvc.generateDbReconcileSummaryReport(reportFile, templateLocation, templateFile);

        verify(fmTemplateSvc, times(1)).setTemplateLocation("c:/testdata/template/location");
        verify(jdbcSvc, times(1)).createNamedConnection(INTERNAL_DB_RECON);
        verify(template, times(1)).process(dataMap, printWriterSystemOut);
        verify(template, times(1)).process(dataMap, fileWriter);
    }
}
