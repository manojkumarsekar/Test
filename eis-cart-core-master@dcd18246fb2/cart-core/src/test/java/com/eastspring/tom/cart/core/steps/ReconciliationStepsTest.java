package com.eastspring.tom.cart.core.steps;

import com.eastspring.tom.cart.core.CartCoreTestConfig;
import com.eastspring.tom.cart.core.CartException;
import com.eastspring.tom.cart.core.mdl.ColumnFilterPredicate;
import com.eastspring.tom.cart.core.mdl.MatchTolerance;
import com.eastspring.tom.cart.core.svc.*;
import com.eastspring.tom.cart.core.utl.FileDirUtil;
import com.eastspring.tom.cart.core.utl.WorkspaceUtil;
import com.eastspring.tom.cart.core.utl.WriterUtil;
import freemarker.template.Template;
import org.junit.Before;
import org.junit.BeforeClass;
import org.junit.Rule;
import org.junit.Test;
import org.junit.rules.ExpectedException;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.MockitoAnnotations;

import java.util.Arrays;
import java.util.List;

import static org.mockito.Mockito.*;

public class ReconciliationStepsTest {
    public static final String TEST_WORKING_DIR = "c:/tomcart-work";

    public static final String FILE_1 = "testdata/csvreconc/test1.csv";
    public static final String FILE_2 = "testdata/csvreconc/test2.csv";

    public static final String LEFT_ONLY = "testevidence/csvreconc/leftonly.csv";
    public static final String RIGHT_ONLY = "testevidence/csvreconc/rightonly.csv";

    public static final String FULLPATH_FILE_1 = TEST_WORKING_DIR + "/" + FILE_1;
    public static final String FULLPATH_FILE_2 = TEST_WORKING_DIR + "/" + FILE_2;
    public static final String FULLPATH_FILE_LEFT_ONLY = TEST_WORKING_DIR + "/" + LEFT_ONLY;
    public static final String FULLPATH_FILE_RIGHT_ONLY = TEST_WORKING_DIR + "/" + RIGHT_ONLY;


    @InjectMocks
    private ReconciliationSteps steps;

    @Mock
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
    private WorkspaceDirSvc workspaceDirSvc;

    @Mock
    private WorkspaceUtil workspaceUtil;

    @Mock
    private WriterUtil writerUtil;

    @Rule
    public ExpectedException thrown = ExpectedException.none();

    @BeforeClass
    public static void initLogging() {
        CartCoreTestConfig.configureLogging(ReconciliationStepsTest.class);
    }

    @Before
    public void initMocks() {
        MockitoAnnotations.initMocks(this);
    }


    @Test
    public void testReconcileFiles_success() throws Exception {
        when(workspaceUtil.getBaseDir()).thenReturn(TEST_WORKING_DIR);
        when(fileDirUtil.addPrefixIfNotAbsolute(FILE_1, TEST_WORKING_DIR)).thenReturn(FULLPATH_FILE_1);
        when(fileDirUtil.addPrefixIfNotAbsolute(FILE_2, TEST_WORKING_DIR)).thenReturn(FULLPATH_FILE_2);
        when(fileDirUtil.addPrefixIfNotAbsolute(LEFT_ONLY, TEST_WORKING_DIR)).thenReturn(FULLPATH_FILE_LEFT_ONLY);
        when(fileDirUtil.addPrefixIfNotAbsolute(RIGHT_ONLY, TEST_WORKING_DIR)).thenReturn(FULLPATH_FILE_RIGHT_ONLY);
        when(fileDirUtil.verifyFileExists(FULLPATH_FILE_1)).thenReturn(true);
        when(fileDirUtil.verifyFileExists(FULLPATH_FILE_2)).thenReturn(true);

        steps.reconcileFiles(FILE_1, FILE_2, LEFT_ONLY, RIGHT_ONLY);

        verify(reconciliationSvc).reconcile(ReconciliationSvc.INMEM_DB_NAME, FULLPATH_FILE_1, FULLPATH_FILE_2, FULLPATH_FILE_LEFT_ONLY, FULLPATH_FILE_RIGHT_ONLY);
    }

    @Test
    public void testReconcileFiles_prefixedSourceDoesntExist() {
        when(workspaceUtil.getBaseDir()).thenReturn(TEST_WORKING_DIR);
        when(fileDirUtil.addPrefixIfNotAbsolute(FILE_1, TEST_WORKING_DIR)).thenReturn(FULLPATH_FILE_1);
        when(fileDirUtil.addPrefixIfNotAbsolute(FILE_2, TEST_WORKING_DIR)).thenReturn(FULLPATH_FILE_2);
        when(fileDirUtil.addPrefixIfNotAbsolute(LEFT_ONLY, TEST_WORKING_DIR)).thenReturn(FULLPATH_FILE_LEFT_ONLY);
        when(fileDirUtil.addPrefixIfNotAbsolute(RIGHT_ONLY, TEST_WORKING_DIR)).thenReturn(FULLPATH_FILE_RIGHT_ONLY);
        when(fileDirUtil.verifyFileExists(FULLPATH_FILE_1)).thenReturn(false);
        thrown.expect(CartException.class);
        thrown.expectMessage("left hand side file [testdata/csvreconc/test1.csv] does not exist");

        steps.reconcileFiles(FILE_1, FILE_2, LEFT_ONLY, RIGHT_ONLY);
    }

    @Test
    public void testReconcileFiles_prefixedTargetDoesntExist() {
        when(workspaceUtil.getBaseDir()).thenReturn(TEST_WORKING_DIR);
        when(fileDirUtil.addPrefixIfNotAbsolute(FILE_1, TEST_WORKING_DIR)).thenReturn(FULLPATH_FILE_1);
        when(fileDirUtil.addPrefixIfNotAbsolute(FILE_2, TEST_WORKING_DIR)).thenReturn(FULLPATH_FILE_2);
        when(fileDirUtil.addPrefixIfNotAbsolute(LEFT_ONLY, TEST_WORKING_DIR)).thenReturn(FULLPATH_FILE_LEFT_ONLY);
        when(fileDirUtil.addPrefixIfNotAbsolute(RIGHT_ONLY, TEST_WORKING_DIR)).thenReturn(FULLPATH_FILE_RIGHT_ONLY);
        when(fileDirUtil.verifyFileExists(FULLPATH_FILE_1)).thenReturn(true);
        when(fileDirUtil.verifyFileExists(FULLPATH_FILE_2)).thenReturn(false);
        thrown.expect(CartException.class);
        thrown.expectMessage("right hand side file [testdata/csvreconc/test2.csv] does not exist");

        steps.reconcileFiles(FILE_1, FILE_2, LEFT_ONLY, RIGHT_ONLY);
    }

    @Test
    public void testGenerateDbReconcileReport() {
        String reportFile = "report-file.file";
        String templateLocation = "/template/location";
        String templateFile = "template-file.file";
        steps.generateDbReconcileSummaryReport(reportFile, templateLocation, templateFile);
        verify(reconciliationSvc, times(1)).generateDbReconcileSummaryReport(reportFile, templateLocation, templateFile);
    }

    @Test
    public void testExportMatchMismatchToCsvFile() {
        String matchFileFullpath = "/a/b/c";
        String mismatchFileFullpath = "/a/b/d";
        String sourceSurplusFileFullpath = "/dir1/source.surplus";
        String targetSurplusFileFullpath = "/dir2/target.surplus";
        steps.exportMatchMismatchToCsvFile(matchFileFullpath, mismatchFileFullpath, sourceSurplusFileFullpath, targetSurplusFileFullpath, 4);
        verify(reconciliationSvc, times(1)).exportMatchMismatchToCsvFile(matchFileFullpath, mismatchFileFullpath, sourceSurplusFileFullpath, targetSurplusFileFullpath, 4);
    }


    @Test
    public void testConvertCsvColsNumPrecision() {
        String srcFile = "def/ghi.csv";
        String dstFile = "/abc/jkl/mno.csv";
        String colNames = "abc,def,ghi";
        int decimalPoint = 4;

        List<String> expectedColsToConvert = Arrays.asList("abc", "def", "ghi");

        when(workspaceDirSvc.normalize(srcFile)).thenReturn("/tomwork/def/ghi.csv");
        when(workspaceDirSvc.normalize(dstFile)).thenReturn("/abc/jkl/mno.csv");
        when(fileDirUtil.getDirnameFromPath("/abc/jkl/mno.csv")).thenReturn("/abc/jkl");

        steps.convertCsvColsNumPrecision(srcFile, colNames, decimalPoint, dstFile);

        verify(fileDirUtil, times(1)).forceMkdir("/abc/jkl");
        verify(csvSvc, times(1)).convertColsNumPrecision("/tomwork/def/ghi.csv", expectedColsToConvert, decimalPoint, "/abc/jkl/mno.csv");
    }

    @Test
    public void testPrepareDbReconciliationEngine() {
        steps.prepareDbReconciliationEngine();
        verify(reconciliationSvc, times(1)).prepareDbReconciliationEngine();
    }

    @Test
    public void testConvertCsvColsDateFormat() {
        String srcFile = "a/b";
        String dstFile = "c/d";
        String normalizedSrcFile = "c:/x/a/b";
        String normalizedDstFile = "c:/x/c/d";
        String colNames = "col1,col_2,COL3";
        List<String> colsToConvert = Arrays.asList("col1", "col_2", "COL3");
        String sourcePattern = "/m/n";
        String targetPattern = "/";
        when(workspaceDirSvc.normalize(srcFile)).thenReturn(normalizedSrcFile);
        when(workspaceDirSvc.normalize(dstFile)).thenReturn(normalizedDstFile);
        when(fileDirUtil.getDirnameFromPath(normalizedDstFile)).thenReturn("c:/x/c");
        steps.convertCsvColsDateFormat(srcFile, colNames, sourcePattern, targetPattern, dstFile);
        verify(fileDirUtil, times(1)).forceMkdir("c:/x/c");
        verify(csvSvc, times(1)).convertCsvColsDateFormat(normalizedSrcFile, colsToConvert, sourcePattern, targetPattern, normalizedDstFile);
    }

    @Test
    public void testLoadCsvToReconDb() {
        String srcDir = "c:/ab/c";
        String filename = "helloworld.csv";
        String tableName = "hello_table";
        String encoding = "UTF-8";
        char separator = ',';
        ColumnFilterPredicate columnFilterPredicate = new ColumnFilterPredicate() {
            @Override
            public String operation(int columnNum, String value) {
                return null;
            }
        };
        steps.loadCsvToReconDb(srcDir, filename, tableName, encoding, separator, columnFilterPredicate);
        verify(reconciliationSvc, times(1)).loadCsvToReconDb(srcDir, filename, tableName, encoding, separator, columnFilterPredicate);
    }

    @Test
    public void testSetGlobalNumericalTolerance() {
        steps.setGlobalNumericalMatchTolerance("0.001");

        verify(reconciliationSvc, times(1)).setGlobalNumericalMatchTolerance("0.001");
    }

    @Test
    public void testSetGlobalNumericalToleranceType() {
        steps.setGlobalNumericalMatchToleranceType("EXACT");

        verify(reconciliationSvc, times(1)).setGlobalNumericalMatchToleranceType(MatchTolerance.EXACT);
    }
}
