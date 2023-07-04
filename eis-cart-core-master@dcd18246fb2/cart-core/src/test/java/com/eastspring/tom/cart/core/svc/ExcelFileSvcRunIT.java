package com.eastspring.tom.cart.core.svc;

import com.eastspring.tom.cart.core.CartCoreTestConfig;
import com.eastspring.tom.cart.core.CartException;
import com.eastspring.tom.cart.core.utl.FileDirUtil;
import org.apache.poi.ss.usermodel.Sheet;
import org.apache.poi.ss.usermodel.Workbook;
import org.junit.Assert;
import org.junit.BeforeClass;
import org.junit.Rule;
import org.junit.Test;
import org.junit.rules.ExpectedException;
import org.junit.runner.RunWith;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.test.context.ContextConfiguration;
import org.springframework.test.context.junit4.SpringJUnit4ClassRunner;

import static com.eastspring.tom.cart.core.svc.ExcelFileSvc.WORKBOOK_CANNOT_BE_NULL;
import static org.hamcrest.CoreMatchers.instanceOf;

@RunWith( SpringJUnit4ClassRunner.class )
@ContextConfiguration( classes = {CartCoreSvcUtlTestConfig.class} )
public class ExcelFileSvcRunIT {
    @Autowired
    private ExcelFileSvc excelFileSvc;

    @Autowired
    private FileDirUtil fileDirUtil;

    @Rule
    public ExpectedException thrown = ExpectedException.none();

    @BeforeClass
    public static void setUpClass() {
        CartCoreTestConfig.configureLogging(FileTransformSvcRunIT.class);
    }


    @Test
    public void testGetWorkbook_successXls() throws Exception {
        String excelFilePath = fileDirUtil.getMavenTestResourcesPath("excel/PositionHeaders001.xls");
        Workbook workbook = excelFileSvc.getWorkbook(excelFilePath);
        Assert.assertNotNull(workbook);
    }

    @Test
    public void testGetWorkbook_successXlsx() throws Exception {
        String excelFilePath = fileDirUtil.getMavenTestResourcesPath("excel/PositionHeadersX001.xlsx");
        Workbook workbook = excelFileSvc.getWorkbook(excelFilePath);
        Assert.assertThat(workbook, instanceOf(Workbook.class));
    }

    @Test
    public void testGetWorkbook_failure() {
        thrown.expect(CartException.class);
        thrown.expectMessage("error while processing Excel file");
        String excelFilePath = fileDirUtil.getMavenTestResourcesPath("excel/no_file.xls");
        excelFileSvc.getWorkbook(excelFilePath);
    }

    @Test
    public void testGetSheet_success() {
        String excelFilePath = fileDirUtil.getMavenTestResourcesPath("excel/PositionHeadersX001.xlsx");
        Workbook workbook = excelFileSvc.getWorkbook(excelFilePath);
        Sheet sheet = excelFileSvc.getSheet(workbook, "ESI_BRS_POSITIONFX_20170824_1");
        Assert.assertThat(sheet, instanceOf(Sheet.class));
    }

    @Test
    public void testGetSheet_failure_sheet_notexist() {
        thrown.expect(CartException.class);
        thrown.expectMessage("Sheet named [NA] not found in the Workbook!");
        String excelFilePath = fileDirUtil.getMavenTestResourcesPath("excel/PositionHeadersX001.xlsx");
        Workbook workbook = excelFileSvc.getWorkbook(excelFilePath);
        excelFileSvc.getSheet(workbook, "NA");
    }

    @Test
    public void testGetSheet_failure_workbook_isnull() {
        thrown.expect(CartException.class);
        thrown.expectMessage(WORKBOOK_CANNOT_BE_NULL);
        excelFileSvc.getSheet(null, "ESI_BRS_POSITIONFX_20170824_1");
    }

    @Test
    public void testGetSheetAtIndex_success() {
        String excelFilePath = fileDirUtil.getMavenTestResourcesPath("excel/PositionHeadersX001.xlsx");
        Workbook workbook = excelFileSvc.getWorkbook(excelFilePath);
        Sheet sheet = excelFileSvc.getSheet(workbook, 0);
        Assert.assertThat(sheet, instanceOf(Sheet.class));
    }

    @Test
    public void testGetSheetAtIndex_failure_sheet_notexist() {
        thrown.expect(CartException.class);
        thrown.expectMessage(ExcelFileSvc.GET_SHEET_PROCESSING_FAILED);
        String excelFilePath = fileDirUtil.getMavenTestResourcesPath("excel/PositionHeadersX001.xlsx");
        Workbook workbook = excelFileSvc.getWorkbook(excelFilePath);
        excelFileSvc.getSheet(workbook, 1);
    }

    @Test
    public void testGetRowCount_with3rows() {
        String excelFilePath = fileDirUtil.getMavenTestResourcesPath("excel/PositionHeadersX001.xlsx");
        Workbook workbook = excelFileSvc.getWorkbook(excelFilePath);
        Sheet sheet = excelFileSvc.getSheet(workbook, 0);
        Integer rowCount = excelFileSvc.getRowCount(sheet);
        Assert.assertEquals(3, (int) rowCount);
    }

    @Test
    public void testGetRowCount_with_null_sheet() {
        Integer rowCount = excelFileSvc.getRowCount(null);
        Assert.assertEquals(-1, (int) rowCount);
    }

    @Test
    public void testConvertExcelToCsv() {
        final String excelPath = "target/test-classes/excel/Expected.xlsx";
        final String csvPath = "target/test-classes/excel/Expected.csv";
        excelFileSvc.convertExcelToCsv(excelPath, csvPath, 0);
        Assert.assertTrue(fileDirUtil.verifyFileExists(csvPath));
        Assert.assertTrue(fileDirUtil.getRowsCountInFile(csvPath) > 2);
    }

    @Test
    public void testConvertExcelToCsv_fileNotAvailable() {
        thrown.expectMessage("Unable to convert Excel file [target/test-classes/excel/not_available.xlsx] to Csv");
        thrown.expect(CartException.class);
        final String excelPath = "target/test-classes/excel/not_available.xlsx";
        final String csvPath = "target/test-classes/excel/Expected.csv";
        excelFileSvc.convertExcelToCsv(excelPath, csvPath, 0);
    }

    @Test
    public void testConvertExcelToCsv_invalidIndex() {
        thrown.expectMessage("Unable to convert Excel file [target/test-classes/excel/Expected.xlsx] to Csv");
        thrown.expect(CartException.class);
        final String excelPath = "target/test-classes/excel/Expected.xlsx";
        final String csvPath = "target/test-classes/excel/Expected.csv";
        excelFileSvc.convertExcelToCsv(excelPath, csvPath, -1);
    }
}
