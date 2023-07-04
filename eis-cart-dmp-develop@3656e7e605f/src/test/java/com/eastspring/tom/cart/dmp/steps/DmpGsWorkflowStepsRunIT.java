package com.eastspring.tom.cart.dmp.steps;

import com.eastspring.tom.cart.core.CartException;
import com.eastspring.tom.cart.core.svc.StateSvc;
import com.eastspring.tom.cart.core.utl.FileDirUtil;
import com.eastspring.tom.cart.core.utl.WorkspaceUtil;
import com.eastspring.tom.cart.dmp.CartDmpTestConfig;
import com.eastspring.tom.cart.dmp.integration.CartDmpStepsSvcUtlConfig;
import com.eastspring.tom.cart.dmp.utl.ReconFileHandler;
import org.junit.Assert;
import org.junit.Before;
import org.junit.BeforeClass;
import org.junit.Rule;
import org.junit.Test;
import org.junit.rules.ExpectedException;
import org.junit.runner.RunWith;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.test.context.ContextConfiguration;
import org.springframework.test.context.junit4.SpringRunner;

import java.util.ArrayList;
import java.util.Arrays;
import java.util.Collections;
import java.util.List;

import static com.eastspring.tom.cart.dmp.utl.DmpFileHandlingUtl.RECONCILIATION_FAILED_BECAUSE_OF_DATA_MISMATCH;
import static com.eastspring.tom.cart.dmp.utl.mdl.ReconType.*;

@RunWith( SpringRunner.class )
@ContextConfiguration( classes = {CartDmpStepsSvcUtlConfig.class} )
public class DmpGsWorkflowStepsRunIT {

    @Autowired
    private DmpGsWorkflowSteps steps;

    @Autowired
    private StateSvc stateSvc;

    @Autowired
    private FileDirUtil fileDirUtil;

    @Autowired
    private WorkspaceUtil workspaceUtil;

    @Autowired
    private ReconFileHandler reconFileHandler;

    @BeforeClass
    public static void setUpClass() {
        CartDmpTestConfig.configureLogging(DmpGsWorkflowStepsRunIT.class);
    }

    @Rule
    public ExpectedException thrown = ExpectedException.none();

    @Before
    public void setUpBaseDir() {
        workspaceUtil.setBaseDir(System.getProperty("user.dir"));
    }

    @Test
    public void testVerifyColumnInFile() {
        final String file = "target/test-classes/files/outbound.csv";
        steps.verifyColumnAvailable(file, Arrays.asList(",Exchange,", ",TICKER,BCUSIP   ,Local Currency"));
    }

    @Test
    public void testVerifyColumnInFile_Exception() {
        thrown.expect(CartException.class);
        thrown.expectMessage("Column Verification is failed, missing columns/sequence in the file are: [[,TICKER,Local Currency,BCUSIP   ,]]");
        final String file = "target/test-classes/files/outbound.csv";
        steps.verifyColumnAvailable(file, Arrays.asList(",Exchange,", ",TICKER,Local Currency,BCUSIP   ,"));
    }

    @Test
    public void testExpectBothFilesShouldBeSame_Success() {
        final String refFile = "target/test-classes/files/reconcile/orders.csv";
        final String currFile = "target/test-classes/files/reconcile/orders_current_noExceptions.csv";
        final String excpFile = "target/test-classes/files/reconcile/exceptions_same_success.csv";

        steps.expectBothFilesShouldBeSame(refFile, currFile, excpFile);

        Assert.assertFalse(fileDirUtil.verifyFileExists(excpFile));
    }

    @Test
    public void testExpectBothFilesShouldBeSame_ExceptionWithMissingRecords() {
        thrown.expect(CartException.class);
        thrown.expectMessage(RECONCILIATION_FAILED_BECAUSE_OF_DATA_MISMATCH);

        final String refFile = "target/test-classes/files/reconcile/orders.csv";
        final String currFile = "target/test-classes/files/reconcile/orders_missingRecords.csv";
        final String excpFile = "target/test-classes/files/reconcile/exceptions_missing_records.csv";

        steps.expectBothFilesShouldBeSame(refFile, currFile, excpFile);

        Assert.assertTrue(fileDirUtil.verifyFileExists(excpFile));
    }

    @Test
    public void testExpectBothFilesShouldBeSame_Exception() {
        thrown.expect(CartException.class);
        thrown.expectMessage(RECONCILIATION_FAILED_BECAUSE_OF_DATA_MISMATCH);

        final String refFile = "target/test-classes/files/reconcile/orders.csv";
        final String currFile = "target/test-classes/files/reconcile/orders_current_withExceptions.csv";
        final String excpFile = "target/test-classes/files/reconcile/exceptions_2.csv";

        steps.expectBothFilesShouldBeSame(refFile, currFile, excpFile);

        Assert.assertTrue(fileDirUtil.verifyFileExists(excpFile));
    }

    @Test
    public void testExpectAllRecordsInTargetFile_Success() {

        final String file1 = "target/test-classes/files/reconcile/ignoreRowCnt/file1.txt";
        final String file2 = "target/test-classes/files/reconcile/ignoreRowCnt/file2.txt";
        final String excpFile = "target/test-classes/files/reconcile/exceptions_3.csv";

        Assert.assertFalse(fileDirUtil.verifyFileExists(excpFile));
        steps.expectAllRecordsExistInTargetFile(file1, file2, excpFile);
    }

    @Test
    public void testExpectAllRecordsInTargetFileXml_Success() {

        final String file1 = "target/test-classes/files/reconcile/ignoreRowCnt/file1.xml";
        final String file2 = "target/test-classes/files/reconcile/ignoreRowCnt/file2.xml";
        final String excpFile = "target/test-classes/files/reconcile/exceptions.xml";

        steps.expectAllRecordsExistInTargetFile(file1, file2, excpFile);
        Assert.assertFalse(fileDirUtil.verifyFileExists(excpFile));
    }

    @Test
    public void testExpectAllRecordsInTargetFileXml_Exception() {
        thrown.expect(CartException.class);
        thrown.expectMessage(RECONCILIATION_FAILED_BECAUSE_OF_DATA_MISMATCH);

        final String file1 = "target/test-classes/files/reconcile/ignoreRowCnt/file3.xml";
        final String file2 = "target/test-classes/files/reconcile/ignoreRowCnt/file4.xml";
        final String excpFile = "target/test-classes/files/reconcile/exceptions_2.xml";

        steps.expectAllRecordsExistInTargetFile(file1, file2, excpFile);
        Assert.assertTrue(fileDirUtil.verifyFileExists(excpFile));
    }

    @Test
    public void testExpectAllRecordsInTargetFile_Exception() {
        thrown.expect(CartException.class);
        thrown.expectMessage(RECONCILIATION_FAILED_BECAUSE_OF_DATA_MISMATCH);

        final String file1 = "target/test-classes/files/reconcile/ignoreRowCnt/file3.txt";
        final String file2 = "target/test-classes/files/reconcile/ignoreRowCnt/file2.txt";
        final String excpFile = "target/test-classes/files/reconcile/exceptions_4.csv";

        steps.expectAllRecordsExistInTargetFile(file1, file2, excpFile);
        Assert.assertEquals("11", fileDirUtil.readFileToString(excpFile));
    }

    @Test
    public void testExpectNoRecordsExistsInTargetFile_Success() {
        final String file1 = "target/test-classes/files/reconcile/ignoreRowCnt/file1.txt";
        final String file2 = "target/test-classes/files/reconcile/orders.csv";
        final String excpFile = "target/test-classes/files/reconcile/exceptions_5.csv";

        steps.expectNoRecordsExistsInTargetFile(file1, file2, excpFile);
        Assert.assertFalse(fileDirUtil.verifyFileExists(excpFile));
    }

    @Test
    public void testExpectNoRecordsExistsInTargetFile_Exception() {
        thrown.expect(CartException.class);
        thrown.expectMessage(RECONCILIATION_FAILED_BECAUSE_OF_DATA_MISMATCH);

        final String file1 = "target/test-classes/files/reconcile/ignoreRowCnt/file2.txt";
        final String file2 = "target/test-classes/files/reconcile/ignoreRowCnt/file1.txt";
        final String excpFile = "target/test-classes/files/reconcile/exceptions_6.csv";

        steps.expectNoRecordsExistsInTargetFile(file1, file2, excpFile);
        Assert.assertFalse(fileDirUtil.verifyFileExists(excpFile));
    }

    @Test
    public void testVerifyColumnValueFromCSV() {
        final String file = "target/test-classes/files/double_quotes.txt";
        steps.verifyColumnValueFromCSV("\"ISIN\"", "TH0765010Z16", "\"ACCT_ID\"", "ALGLVE", file);
    }

    @Test
    public void testVerifyNoOfOccurrencesOfStringInFile() {
        final String file = "target/test-classes/files/outbound.csv";
        steps.verifyNoOfOccurrencesOfStringInFile("BPM0TCWH0", file, 1);
    }

    @Test
    public void testVerifyNoOfOccurrencesOfStringInFile_Exception() {
        thrown.expect(CartException.class);
        thrown.expectMessage("Verification failed as Expected No.of Occurrences of String [BPM0TCWH0] are [0], but actual are [1]");

        final String file = "target/test-classes/files/outbound.csv";

        steps.verifyNoOfOccurrencesOfStringInFile("BPM0TCWH0", file, 0);
    }

    @Test
    public void testExpectBothFilesShouldBeSameWithSameOrder_success() {
        final String refFile = "target/test-classes/files/reconcile/orders.csv";
        final String currFile = "target/test-classes/files/reconcile/orders_current_noExceptions.csv";
        final String excpFile = "target/test-classes/files/reconcile/exceptions_same_order.csv";

        steps.expectBothFilesShouldBeSameWithSameOrder(refFile, currFile, excpFile);

        Assert.assertFalse(fileDirUtil.verifyFileExists(excpFile));
    }

    @Test
    public void testExpectBothFilesShouldBeSameWithSameOrder_failure() {
        thrown.expect(CartException.class);
        thrown.expectMessage("Reconciliation failed because of data mismatch Or Order mismatch");

        final String refFile = "target/test-classes/files/reconcile/orders.csv";
        final String currFile = "target/test-classes/files/reconcile/orders_current_different_sequence.csv";
        final String excpFile = "target/test-classes/files/reconcile/exceptions_1.csv";

        steps.expectBothFilesShouldBeSameWithSameOrder(refFile, currFile, excpFile);
    }

    @Test
    public void testExpectBothFilesShouldBeSame_ExcludeColumns_Success() {
        final String refFile = "target/test-classes/files/test.csv";
        final String currFile = "target/test-classes/files/test1.csv";
        final String excpFile = "target/test-classes/files/exceptions_columns_success.csv";
        List<String> exclude = new ArrayList<>();
        exclude.add("A");
        exclude.add("C");
        reconFileHandler.setExcludedColumns(exclude);
        steps.expectBothFilesShouldBeSameWithSameOrder(refFile, currFile, excpFile);
        Assert.assertFalse(fileDirUtil.verifyFileExists(excpFile));
        reconFileHandler.setExcludedColumns(exclude);
        steps.expectBothFilesShouldBeSame(refFile, currFile, excpFile);
        Assert.assertFalse(fileDirUtil.verifyFileExists(excpFile));
    }

    @Test
    public void testExpectBothFilesShouldBeSame_ExcludeColumns_Failure() {
        thrown.expect(CartException.class);
        thrown.expectMessage("Reconciliation failed because of data mismatch");
        final String refFile = "target/test-classes/files/test.csv";
        final String currFile = "target/test-classes/files/test1.csv";
        final String excpFile = "target/test-classes/files/exceptions_same_failure.csv";
        List<String> exclude = new ArrayList<>();
        exclude.add("B");
        reconFileHandler.setExcludedColumns(exclude);
        steps.expectBothFilesShouldBeSame(refFile, currFile, excpFile);
        Assert.assertTrue(fileDirUtil.verifyFileExists(excpFile));
        reconFileHandler.setExcludedColumns(exclude);
        steps.expectBothFilesShouldBeSameWithSameOrder(refFile, currFile, excpFile);
        Assert.assertTrue(fileDirUtil.verifyFileExists(excpFile));
    }

    @Test
    public void testExpectNoRecordsExistsInTargetFile_ExcludeHeader_Success() {
        final String file1 = "target/test-classes/files/exclude_header.csv";
        final String file2 = "target/test-classes/files/test1.csv";
        final String excpFile = "target/test-classes/files/exceptions_exclude_header_success.csv";
        List<String> exclude = new ArrayList<>();
        exclude.add("B");
        reconFileHandler.setExcludedColumns(exclude);
        steps.expectNoRecordsExistsInTargetFile(file1, file2, excpFile);
        Assert.assertFalse(fileDirUtil.verifyFileExists(excpFile));
    }

    @Test
    public void testExpectNoRecordsExistsInTargetFile_ExcludeHeader_Failure() {
        thrown.expect(CartException.class);
        thrown.expectMessage(RECONCILIATION_FAILED_BECAUSE_OF_DATA_MISMATCH);
        final String file1 = "target/test-classes/files/test.csv";
        final String file2 = "target/test-classes/files/test1.csv";
        final String excpFile = "target/test-classes/files/exceptions_exclude_header_failure.csv";

        reconFileHandler.setExcludedColumns(Collections.singletonList("B"));

        steps.expectNoRecordsExistsInTargetFile(file1, file2, excpFile);
        Assert.assertTrue(fileDirUtil.verifyFileExists(excpFile));
    }


    @Test
    public void testCompareExcelFiles_matched() {
        final String expected = "target/test-classes/excel/Expected.xlsx";
        final String actual = "target/test-classes/excel/Actual_match.xlsx";
        steps.compareExcelFiles(actual, expected, 0);
    }

    @Test
    public void testCompareExcelFiles_not_matched() {
        thrown.expect(CartException.class);
        thrown.expectMessage(RECONCILIATION_FAILED_BECAUSE_OF_DATA_MISMATCH);

        final String expected = "target/test-classes/excel/Expected.xlsx";
        final String actual = "target/test-classes/excel/Actual_notmatch.xlsx";
        steps.compareExcelFiles(actual, expected, 0);
    }

    @Test
    public void testInvokeReconciliations_recon_pass() {
        final String refFile = "target/test-classes/files/reconcile/orders.csv";
        final String currFile = "target/test-classes/files/reconcile/orders_current_noExceptions.csv";
        steps.invokeReconciliations(SRC_TARGET_EXACT_MATCH, reconFileHandler.setFiles(refFile, currFile));
    }

    @Test
    public void testInvokeReconciliations_exclude_columns_all_match_recon_pass() {
        final String refFile = "target/test-classes/files/test.csv";
        final String currFile = "target/test-classes/files/test1.csv";

        reconFileHandler.setExcludedColumns(Arrays.asList("A", "C"));
        steps.invokeReconciliations(SRC_TARGET_EXACT_MATCH_WITH_ORDER, reconFileHandler.setFiles(refFile, currFile));
    }

    @Test
    public void testInvokeReconciliations_exclude_columns_all_match_recon_fail() {
        thrown.expect(CartException.class);
        thrown.expectMessage("Reconciliation failed because of data mismatch");
        final String refFile = "target/test-classes/files/test.csv";
        final String currFile = "target/test-classes/files/test1.csv";

        reconFileHandler.setExcludedColumns(Collections.singletonList("C"));
        steps.invokeReconciliations(SRC_TARGET_EXACT_MATCH_WITH_ORDER, reconFileHandler.setFiles(refFile, currFile));
    }


    @Test
    public void testInvokeReconciliations_none_match_recon_pass() {
        final String file1 = "target/test-classes/files/reconcile/ignoreRowCnt/file1.txt";
        final String file2 = "target/test-classes/files/reconcile/orders.csv";
        steps.invokeReconciliations(SRC_NONE_MATCH, reconFileHandler.setFiles(file1, file2));
    }

    @Test
    public void testInvokeReconciliations_fileNotAvailable() {
        thrown.expect(CartException.class);
        thrown.expectMessage("test_NA.csv] not available");
        final String refFile = "target/test-classes/files/test_NA.csv";
        final String currFile = "target/test-classes/files/test.csv";
        steps.invokeReconciliations(SRC_ALL_MATCH, reconFileHandler.setFiles(refFile, currFile));
    }

    @Test
    public void testIExpectRecordsAreSorted_validScenario() {
        String sortedFile = "target/test-classes/files/sortedfile.qqq";
        steps.iExpectRecordsAreSorted(sortedFile);
    }

    @Test
    public void testIExpectRecordsAreSorted_unsortedScenario() {
        String unsortedFile = "target/test-classes/files/unsortedfile.qqq";
        thrown.expectMessage("Verification failed for sorting order of published file");
        steps.iExpectRecordsAreSorted(unsortedFile);
    }

    @Test
    public void testIExpectRecordsAreSorted_missingFileScenario() {
        String file = "target/test-classes/files/sortedfile1.qqq";
        thrown.expectMessage("sortedfile1.qqq] does not exists!");
        steps.iExpectRecordsAreSorted(file);
    }

    @Test
    public void testInvokeReconciliations_recon_blankfile() {
        final String refFile = "target/test-classes/files/reconcile/orders.csv";
        final String currFile = "target/test-classes/files/reconcile/file_with_no_contents.csv";
        thrown.expectMessage("file_with_no_contents.csv] not available or the available file is blank");
        steps.invokeReconciliations(SRC_TARGET_EXACT_MATCH, reconFileHandler.setFiles(refFile, currFile));
    }

    @Test
    public void testisTestPortfolioUsedTestPortfolio() {
        String portfolioName = "TSTTPORT01";
        steps.exitIfNotTestPortfolio(portfolioName);
    }

    @Test
    public void testisTestPortfolioUsedNonTestPortfolio() {
        String portfolioName = "TTPORT01";
        thrown.expectMessage("Test User cannot place order for live portfolio");
        steps.exitIfNotTestPortfolio(portfolioName);
    }
}
