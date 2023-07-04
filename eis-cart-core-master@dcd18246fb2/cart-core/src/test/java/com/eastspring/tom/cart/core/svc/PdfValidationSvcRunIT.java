package com.eastspring.tom.cart.core.svc;

import com.eastspring.tom.cart.cfg.CartCoreConfig;
import com.eastspring.tom.cart.core.CartCoreTestConfig;
import com.eastspring.tom.cart.core.CartException;
import com.eastspring.tom.cart.core.utl.FileDirUtil;
import com.eastspring.tom.cart.core.utl.WorkspaceUtil;
import org.apache.pdfbox.pdmodel.PDDocument;
import org.apache.pdfbox.pdmodel.PDPage;
import org.junit.Assert;
import org.junit.Before;
import org.junit.BeforeClass;
import org.junit.Rule;
import org.junit.Test;
import org.junit.rules.ExpectedException;
import org.junit.runner.RunWith;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.test.context.ContextConfiguration;
import org.springframework.test.context.junit4.SpringJUnit4ClassRunner;

import java.io.File;
import java.io.IOException;
import java.util.Collections;

import static com.eastspring.tom.cart.core.svc.PdfValidationSvc.PDF_COMPARE_AUTOIMAGE_TRANSITION;
import static com.eastspring.tom.cart.core.svc.PdfValidationSvc.PDF_COMPARE_IMAGE_MODE;
import static com.eastspring.tom.cart.core.svc.PdfValidationSvc.PDF_COMPARE_TEXT_MODE;

@RunWith(SpringJUnit4ClassRunner.class)
@ContextConfiguration(classes = {CartCoreConfig.class})
public class PdfValidationSvcRunIT {

    public static final String TEST_PDF_FILE = "target/test-classes/pdf/sample.pdf";
    public static final String TEST_PDF_FILE_INVALID_COUNT = "target/test-classes/pdf/sample_count_mismatch.pdf";
    public static final String TEST_PDF_FILE_INVALID_DATA = "target/test-classes/pdf/sample_data_missing.pdf";

    @Autowired
    private PdfValidationSvc pdfValidationSvc;

    @Autowired
    private FileDirUtil fileDirUtil;

    @Autowired
    private StateSvc stateSvc;

    @Autowired
    private WorkspaceUtil workspaceUtil;

    @Rule
    public ExpectedException thrown = ExpectedException.none();

    @BeforeClass
    public static void setUpClass() {
        CartCoreTestConfig.configureLogging(PdfValidationSvcRunIT.class);
    }

    @Before
    public void before() {
        workspaceUtil.setBaseDir(System.getProperty("user.dir"));
    }

    @Test
    public void testLoadFile() throws IOException {
        PDDocument pdDocument = pdfValidationSvc.getPdDocument(new File(TEST_PDF_FILE));
        Assert.assertTrue(pdDocument != null);
        pdDocument.close();
    }

    @Test
    public void testGetPdfText() {
        String pdfText = pdfValidationSvc.getPdfText(new File(TEST_PDF_FILE));
        Assert.assertTrue(pdfText.contains("workflow.max.polling.time"));
    }

    @Test
    public void testGetPdfPageRef_validPageNumber() throws IOException {
        PDDocument pdDocument = pdfValidationSvc.getPdDocument(new File(TEST_PDF_FILE));
        PDPage pdfPageRef = pdfValidationSvc.getPdfPageRef(pdDocument, 1);
        pdDocument.close();
        Assert.assertNotNull(pdfPageRef);
    }

    @Test
    public void testGetPdfPageRef_invalidPageNumber_greater() throws IOException {
        thrown.expect(CartException.class);
        thrown.expectMessage("Cannot access page number [2] as it contains [1] pages");
        PDDocument pdDocument = pdfValidationSvc.getPdDocument(new File(TEST_PDF_FILE));
        pdfValidationSvc.getPdfPageRef(pdDocument, 2);
        pdDocument.close();
    }

    @Test
    public void testGetPdfPageRef_invalidPageNumber_lesser() throws IOException {
        thrown.expect(CartException.class);
        thrown.expectMessage("Page Number cannot be less than or equal to 0");
        PDDocument pdDocument = pdfValidationSvc.getPdDocument(new File(TEST_PDF_FILE));
        pdfValidationSvc.getPdfPageRef(pdDocument, -1);
        pdDocument.close();
    }

    @Test
    public void testGetPdfTextByCoordinates_integers() {
        String text = pdfValidationSvc.getPdfTextByCoordinates(new File(TEST_PDF_FILE), 1, 52, 150, 50, 60);
        Assert.assertEquals("p string va", text);
    }

    @Test
    public void testGetPdfTextByCoordinates_doubles() {
        String text = pdfValidationSvc.getPdfTextByCoordinates(new File(TEST_PDF_FILE), 1, 52.1, 150.2, 50.1, 60.1);
        Assert.assertEquals("p string va", text);
    }

    @Test
    public void testComparePdf_Text_sameFiles() {
        boolean result = pdfValidationSvc.comparePdf(new File(TEST_PDF_FILE), new File(TEST_PDF_FILE), PDF_COMPARE_TEXT_MODE);
        Assert.assertTrue(result);
    }

    @Test
    public void testComparePdf_Text_mismatchData_withExclusion() {
        pdfValidationSvc.setExclusionList(Collections.singletonList("PORTFOLIO_TEMPLATE"));
        boolean result = pdfValidationSvc.comparePdf(new File(TEST_PDF_FILE), new File(TEST_PDF_FILE_INVALID_DATA), PDF_COMPARE_TEXT_MODE);
        Assert.assertTrue(result);
    }

    @Test
    public void testComparePdf_Text_mismatchCount_file1HasMoreRecords() {
        boolean result = pdfValidationSvc.comparePdf(new File(TEST_PDF_FILE), new File(TEST_PDF_FILE_INVALID_COUNT), PDF_COMPARE_TEXT_MODE);
        Assert.assertFalse(result);
        Assert.assertTrue(fileDirUtil.fileDirExist("target/test-classes/pdf/pdfDiff.txt"));
        fileDirUtil.forceDelete("target/test-classes/pdf/pdfDiff.txt");
    }

    @Test
    public void testComparePdf_Text_mismatchCount_autoImageModeSet() {
        stateSvc.setStringVar(PDF_COMPARE_AUTOIMAGE_TRANSITION, "true");
        boolean result = pdfValidationSvc.comparePdf(new File(TEST_PDF_FILE), new File(TEST_PDF_FILE_INVALID_COUNT), PDF_COMPARE_TEXT_MODE);
        stateSvc.removeStringVar(PDF_COMPARE_AUTOIMAGE_TRANSITION);
        Assert.assertFalse(result);
        Assert.assertTrue(fileDirUtil.fileDirExist("target/test-classes/pdf/pdfDiff.pdf"));
        fileDirUtil.forceDelete("target/test-classes/pdf/pdfDiff.txt");
    }

    @Test
    public void testComparePdf_Text_mismatchCount_file2HasMoreRecords() {
        boolean result = pdfValidationSvc.comparePdf(new File(TEST_PDF_FILE_INVALID_COUNT), new File(TEST_PDF_FILE), PDF_COMPARE_TEXT_MODE);
        Assert.assertFalse(result);
        Assert.assertTrue(fileDirUtil.fileDirExist("target/test-classes/pdf/pdfDiff.txt"));
        fileDirUtil.forceDelete("target/test-classes/pdf/pdfDiff.txt");
    }

    @Test
    public void testComparePdf_Text_mismatchData() {
        boolean result = pdfValidationSvc.comparePdf(new File(TEST_PDF_FILE), new File(TEST_PDF_FILE_INVALID_DATA), PDF_COMPARE_TEXT_MODE);
        Assert.assertFalse(result);
        Assert.assertTrue(fileDirUtil.fileDirExist("target/test-classes/pdf/pdfDiff.txt"));
        fileDirUtil.forceDelete("target/test-classes/pdf/pdfDiff.txt");
    }


    @Test
    public void testComparePdf_Image_mismatchData() {
        boolean result = pdfValidationSvc.comparePdf(new File(TEST_PDF_FILE), new File(TEST_PDF_FILE_INVALID_DATA), PDF_COMPARE_IMAGE_MODE);
        Assert.assertFalse(result);
        Assert.assertTrue(fileDirUtil.fileDirExist("target/test-classes/pdf/pdfDiff.pdf"));
        fileDirUtil.forceDelete("target/test-classes/pdf/pdfDiff.pdf");
    }

    @Test
    public void testGetPdfTextByPage() {
        String pdfText = pdfValidationSvc.getPdfTextByPage(new File("target/test-classes/pdf/multipage.pdf"), 5);
        Assert.assertTrue(pdfText.contains("This document is issued by Eastspring Investments (Singapore) Limited (UEN:"));
    }

}
