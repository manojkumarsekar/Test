package com.eastspring.tom.cart.core.steps;

import com.eastspring.tom.cart.core.CartCoreTestConfig;
import com.eastspring.tom.cart.core.CartException;
import com.eastspring.tom.cart.core.svc.StateSvc;
import com.eastspring.tom.cart.core.utl.FileDirUtil;
import com.eastspring.tom.cart.core.utl.WorkspaceUtil;
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
import java.util.HashMap;
import java.util.Map;

import static com.eastspring.tom.cart.core.steps.PdfValidationSteps.PDF_COMPARE_MODE_VAR;
import static com.eastspring.tom.cart.core.svc.PdfValidationSvc.PDF_COMPARE_IMAGE_MODE;
import static com.eastspring.tom.cart.core.svc.PdfValidationSvcRunIT.TEST_PDF_FILE;
import static com.eastspring.tom.cart.core.svc.PdfValidationSvcRunIT.TEST_PDF_FILE_INVALID_DATA;

@RunWith(SpringJUnit4ClassRunner.class)
@ContextConfiguration(classes = {CartCoreStepsSvcUtlTestConfig.class})
public class PdfValidationStepsRunIT {

    @Autowired
    private PdfValidationSteps pdfValidationSteps;

    @Autowired
    private FileDirUtil fileDirUtil;

    @Autowired
    private StateSvc stateSvc;

    @Autowired
    private WorkspaceUtil workspaceUtil;

    @Rule
    public ExpectedException thrown = ExpectedException.none();

    @BeforeClass
    public static void initLogging() {
        CartCoreTestConfig.configureLogging(PdfValidationStepsRunIT.class);
    }

    @Before
    public void setUp() {
        workspaceUtil.setBaseDir(System.getProperty("user.dir"));
    }


    @Test
    public void testProcessPdfFile() {
        pdfValidationSteps.processPdfFile(TEST_PDF_FILE);
        String path = pdfValidationSteps.getPdfFile().getName();
        Assert.assertTrue(TEST_PDF_FILE.contains(path));
    }

    @Test
    public void testAssignPdfTextToVar() {
        pdfValidationSteps.processPdfFile(TEST_PDF_FILE);
        pdfValidationSteps.assignPdfTextToVar(1, "Var1");
        Assert.assertNotNull(stateSvc.getStringVar("Var1"));
    }

    @Test
    public void testVerifyValueOccurrencesInPdf_allMatch() {
        Map<String, String> testMap = new HashMap<>();
        testMap.put("TOM_UAT", "2");
        testMap.put("NULL", "0");
        pdfValidationSteps.processPdfFile(TEST_PDF_FILE);
        pdfValidationSteps.verifyValueOccurrencesInPdf(testMap);
    }

    @Test
    public void testVerifyValueOccurrencesInPdf_mismatch() {
        thrown.expect(CartException.class);
        thrown.expectMessage("Verify Occurrences of Text is failed with errors");
        Map<String, String> testMap = new HashMap<>();
        testMap.put("polished", "2");
        testMap.put("NULL", "1");
        testMap.put("NULL1", "1");
        pdfValidationSteps.processPdfFile(TEST_PDF_FILE);
        pdfValidationSteps.verifyValueOccurrencesInPdf(testMap);
    }

    @Test
    public void testVerifyValueCoordinatesInPdf() {
        Map<String, String> testMap = new HashMap<>();
        testMap.put("x=52,y=150,width=50,height=60", "p string va");
        pdfValidationSteps.processPdfFile(TEST_PDF_FILE);
        pdfValidationSteps.verifyValueCoordinatesInPdf(1, testMap);
    }

    @Test
    public void testComparePdf_success() {
        try {
            pdfValidationSteps.comparePdf(new File(TEST_PDF_FILE), new File(TEST_PDF_FILE));
        } catch (CartException e) {
            Assert.assertTrue(false);
        }
    }

    @Test
    public void testComparePdf_exception_text() {
        thrown.expect(CartException.class);
        thrown.expectMessage("Pdf Comparison failed, please find the attachment for detailed errors");
        pdfValidationSteps.comparePdf(new File(TEST_PDF_FILE), new File(TEST_PDF_FILE_INVALID_DATA));
        Assert.assertTrue(fileDirUtil.fileDirExist("target/test-classes/pdf/pdfDiff.txt"));
    }

    @Test
    public void testComparePdf_exception_image() {
        thrown.expect(CartException.class);
        thrown.expectMessage("Pdf Comparison failed, please find the attachment for detailed errors");
        stateSvc.setStringVar(PDF_COMPARE_MODE_VAR, PDF_COMPARE_IMAGE_MODE);
        pdfValidationSteps.comparePdf(new File(TEST_PDF_FILE), new File(TEST_PDF_FILE_INVALID_DATA));
        Assert.assertTrue(fileDirUtil.fileDirExist("target/test-classes/pdf/pdfDiff.pdf"));
    }
}
