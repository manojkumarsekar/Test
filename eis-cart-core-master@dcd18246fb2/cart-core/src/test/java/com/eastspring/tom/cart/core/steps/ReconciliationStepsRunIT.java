package com.eastspring.tom.cart.core.steps;

import com.eastspring.tom.cart.core.CartCoreTestConfig;
import com.eastspring.tom.cart.core.flt.ColumnFilterPredicates;
import com.eastspring.tom.cart.core.mdl.ExcelToCsvParam;
import com.eastspring.tom.cart.core.mdl.HighlightedExcelRequest;
import com.eastspring.tom.cart.core.svc.CompressionSvc;
import com.eastspring.tom.cart.core.svc.ReconciliationSvc;
import com.eastspring.tom.cart.core.utl.DateTimeUtil;
import com.eastspring.tom.cart.core.utl.FileDirUtil;
import com.eastspring.tom.cart.cst.EncodingConstants;
import org.junit.Assert;
import org.junit.BeforeClass;
import org.junit.Test;
import org.junit.runner.RunWith;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.test.context.ContextConfiguration;
import org.springframework.test.context.junit4.SpringJUnit4ClassRunner;

import java.util.List;

import static com.eastspring.tom.cart.core.svc.CsvSvcIT.SOURCE_MONIKER_CPR;
import static com.eastspring.tom.cart.core.svc.CsvSvcIT.TARGET_MONIKER_BNP;

@RunWith(SpringJUnit4ClassRunner.class)
@ContextConfiguration(classes = {CartCoreStepsSvcUtlTestConfig.class})
public class ReconciliationStepsRunIT {
    private static final Logger LOGGER = LoggerFactory.getLogger(ReconciliationStepsRunIT.class);

    public static final String TEMPLATE_LOCATION = "c:/tomwork/recon/testdata/report-templates";
    public static final String REPORT_FILE = "c:/tomwork/recon/testout/report.html";
    public static final String MISMATCH_CSV_FILE_FULLPATH = "c:/tomwork/recon/testout/mismatchRows.csv";
    public static final String MISMATCH_EXCEL_FILE_FULLPATH = "c:/tomwork/recon/testout/mismatchRows.xls";
    public static final String MATCH_CSV_FILE_FULLPATH = "c:/tomwork/recon/testout/matchRows.csv";
    public static final String SOURCE_SURPLUS_CSV_FILE_FULLPATH = "c:/tomwork/recon/testout/sourceSurplusRows.csv";
    public static final String TARGET_SURPLUS_CSV_FILE_FULLPATH = "c:/tomwork/recon/testout/targetSurplusRows.csv";

    @Autowired
    private ReconciliationSteps steps;

    @Autowired
    private CompressionSvc compressionSvc;

    @Autowired
    private DateTimeUtil dateTimeUtil;

    @Autowired
    private FileDirUtil fileDirUtil;

    @BeforeClass
    public static void initLogging() {
        CartCoreTestConfig.configureLogging(ReconciliationStepsRunIT.class);
    }

    //    @Test
    public void testLoadingPerformanceL1ReportAndReconcile() throws Exception {
        String timestamp = dateTimeUtil.getTimestamp();
        String srcDir = "c:/tomwork/recon/testdata";

        String filename1 = "ESI_Jan2017.csv";
        String tableNamePrefix1 = "CPR_BOR_NEW_Raw_";
        String tableName1 = tableNamePrefix1 + timestamp;

        String filename2 = "BNP_B4_CPR_Jan2017.csv";
        String tableNamePrefix2 = "BNP_BOR_NEW_Raw_";
        String tableName2 = tableNamePrefix2 + timestamp;

        steps.loadCsvToReconDb(srcDir, filename1, tableName1, EncodingConstants.UTF_16, '\t', ColumnFilterPredicates::stripPercentage);
//        steps.loadCsvToReconDb(srcDir, filename2, tableName2, EncodingConstants.UTF_8, ',', ColumnFilterPredicates::stripPercentage);
//        steps.dbReconcileL1(tableName1, tableName2);
    }

    public static final String TEMPLATE_FILE = "BNP_CPR_BOR_Recon.xml";

    //    @Test
    public void testGenerateDbReconcileSummaryReport() throws Exception {
        steps.generateDbReconcileSummaryReport(REPORT_FILE, TEMPLATE_LOCATION, TEMPLATE_FILE);
    }

    //    @Test
    public void testExportMatchMismatchToCsvFile() throws Exception {
        steps.exportMatchMismatchToCsvFile(MATCH_CSV_FILE_FULLPATH, MISMATCH_CSV_FILE_FULLPATH, SOURCE_SURPLUS_CSV_FILE_FULLPATH, TARGET_SURPLUS_CSV_FILE_FULLPATH, 4);
    }

    @Test
    public void testGenerateMismatchExcelFileFromMismatchCsvFile_csvL1() throws Exception {
        HighlightedExcelRequest request = new HighlightedExcelRequest();
        String mismatchCsvFullpath = fileDirUtil.getMavenTestResourcesPath("performance/L1-mismatchRows.csv");
        String highlightedExcelFullpath = fileDirUtil.getMavenTestResourcesPath("performance/L1-mismatchRows-out.xls");
        String resultRefFile = fileDirUtil.getMavenTestResourcesPath("performance/L1-mismatchRows-ref.xls");
        request.setCsvFileFullpath(mismatchCsvFullpath);
        request.setHighlightedExcelFileFullpath(highlightedExcelFullpath);
        request.setSourceName(SOURCE_MONIKER_CPR);
        request.setTargetName(TARGET_MONIKER_BNP);
        request.setMatchName(ReconciliationSvc.MATCH_NAME);
        request.setMatchWithToleranceName(ReconciliationSvc.MATCH_WITH_TOLERANCE_NAME);
        request.setEncoding(EncodingConstants.UTF_8);
        request.setSeparator(',');
        steps.generateMismatchExcelFileFromMismatchCsvFile(request);
//        Assert.assertTrue(fileDirUtil.contentEquals(highlightedExcelFullpath, resultRefFile));
    }

    //    @Test
    public void testLoadCsvToReconDb_tsv_utf16() throws Exception {
        steps.loadCsvToReconDb(fileDirUtil.getMavenTestResourcesPath("recon"), "tsv-utf16-sample.csv", "MyLoadCsvTableNameTsvUtf16", EncodingConstants.UTF_16, '\t', ColumnFilterPredicates::stripPercentage);
    }

    /**
     * <p>This test depends on MSSQL database, which currently is not available in the Bamboo Agent machine. COMMENTED OUT.</p>
     *
     * @throws Exception exception
     */
//    @Test
    public void testLoadCsvToReconDb_csv_utf8() throws Exception {
        steps.loadCsvToReconDb(fileDirUtil.getMavenTestResourcesPath("recon"), "csv-utf8-sample.csv", "MyLoadCsvTableNameCsvUtf8", EncodingConstants.UTF_8, ',', ColumnFilterPredicates::stripPercentage);
    }

    @Test
    public void testConvertExcelToCsv() throws Exception {
        String srcFullpath = fileDirUtil.getMavenTestResourcesPath("recon/performance_l1/CPR2010JUL_20100901_09-25 FINAL.xls");
        String dstFullpath = fileDirUtil.getMavenTestResourcesPath("recon/performance_l1/result.csv");
        ExcelToCsvParam param = new ExcelToCsvParam();
        param.setSheetName("All Funds");
        param.setSrcFullpath(srcFullpath);
        param.setDstFullpath(dstFullpath);
        param.setColsLimit(75);
        steps.convertExcelToCsv(param);
    }


    //    @Test
    public void testFilterFilesContainSignature() throws Exception {
        String baseDir = fileDirUtil.getMavenTestResourcesPath("recon/performance_l1");
        List<String> filePaths = steps.filterFilesContainSignature(baseDir, "*FINAL*");

        Assert.assertNotNull(filePaths);
        Assert.assertEquals(3, filePaths.size());
        Assert.assertEquals("CPR201007_20100901_09-25 FINAL (JUL 2010).zip", fileDirUtil.getFilenameFromPath(filePaths.get(0)));
        Assert.assertEquals("CPR2010JUL_20100901_09-25 FINAL - Copy.xls", fileDirUtil.getFilenameFromPath(filePaths.get(1)));
        Assert.assertEquals("CPR2010JUL_20100901_09-25 FINAL.xls", fileDirUtil.getFilenameFromPath(filePaths.get(2)));
    }


    /**
     * This method tests the creation of K: drive CSV file from K: drive's ZIP file.
     *
     * @throws Exception allows to throw any exceptions
     */
    //@Test
    public void testKDriveCsvCreation() throws Exception {
        String baseDir = fileDirUtil.getMavenTestResourcesPath("recon/performance_l1");
        List<String> filePaths = steps.filterFilesContainSignature(baseDir, "*FINAL*JUL 2010*.zip");

        Assert.assertNotNull(filePaths);
        Assert.assertEquals(1, filePaths.size());

        String filename = fileDirUtil.getFilenameFromPath(filePaths.get(0));

        Assert.assertEquals("CPR201007_20100901_09-25 FINAL (JUL 2010).zip", filename);

        String expandedSrcDir = fileDirUtil.getMavenTestResourcesPath("recon/performance_l1");
        String testOutDir = fileDirUtil.ensureTestOutDirExist("recon/performance_l1");

        System.out.println(testOutDir);
        String resultFullpath = compressionSvc.unzipSingleFile(expandedSrcDir + "/" + filename, testOutDir);

        System.out.println(resultFullpath);

        Assert.assertTrue(fileDirUtil.contentEquals(fileDirUtil.getMavenTestResourcesPath("recon/performance_l1/CPR2010JUL_20100901_09-25 FINAL.xls"), resultFullpath));
    }

    /**
     * <p>TODO: This is a wobbly test. need to revisit later: works well in Windows, does not work well in Linux.</p>
     */
//    @Test
    public void testGetCsvFromKDriveZip() {
        String kDriveSrc = fileDirUtil.getMavenTestResourcesPath("recon/performance_l1");
        String zipFilePattern = "*FINAL*JUL 2010*.zip";
        String testOutDir = fileDirUtil.ensureTestOutDirExist("recon/performance_l1");

        String result = steps.getCsvFromKDriveZip(kDriveSrc, zipFilePattern, testOutDir, testOutDir);

        Assert.assertNotNull(result);
        Assert.assertTrue(result.endsWith("recon\\performance_l1\\CPR2010JUL_20100901_09-25 FINAL.csv"));
        String refExpectedFile = fileDirUtil.getMavenTestResourcesPath("recon/performance_l1/CPR2010JUL_20100901_09-25 FINAL.csv");
        if ("LINUX".equalsIgnoreCase(System.getProperty("os.name"))) {
            String content = fileDirUtil.readFileToString(refExpectedFile);
            String newContent = content.replaceAll("\r", "");
            fileDirUtil.writeStringToFile(refExpectedFile, newContent);
        }

        Assert.assertTrue(fileDirUtil.contentEquals(refExpectedFile, result));
    }


    @Test
    public void testConvertCsvColsNumericPrecision() throws Exception {
        String srcFile = fileDirUtil.getMavenTestResourcesPath("csv-transform/file-transform-numprecision-02.csv");
        String colNames = "col2,col4";
        int decimalPoint = 2;
        String dstFile = fileDirUtil.getMavenTestResourcesPath("csv-transform/file-transform-numprecision-02-out1.csv");
        String refFile = fileDirUtil.getMavenTestResourcesPath("csv-transform/file-transform-numprecision-02-ref1.csv");
        steps.convertCsvColsNumPrecision(srcFile, colNames, decimalPoint, dstFile);
        fileDirUtil.contentEquals(dstFile, refFile);
    }

}
