package com.eastspring.tom.cart.dmp.utl;

import com.eastspring.tom.cart.core.CartException;
import com.eastspring.tom.cart.core.utl.FileDirUtil;
import com.eastspring.tom.cart.core.utl.FormatterUtil;
import com.eastspring.tom.cart.core.utl.WorkspaceUtil;
import com.eastspring.tom.cart.dmp.CartDmpTestConfig;
import com.eastspring.tom.cart.dmp.integration.CartDmpStepsSvcUtlConfig;
import com.eastspring.tom.cart.dmp.utl.mdl.ReconInputSpec;
import com.eastspring.tom.cart.dmp.utl.mdl.ReconOutputSpec;
import org.junit.Assert;
import org.junit.BeforeClass;
import org.junit.Rule;
import org.junit.Test;
import org.junit.rules.ExpectedException;
import org.junit.runner.RunWith;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.test.context.ContextConfiguration;
import org.springframework.test.context.junit4.SpringJUnit4ClassRunner;

import java.io.File;
import java.io.FileNotFoundException;
import java.nio.file.Paths;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.stream.Collectors;

import static com.eastspring.tom.cart.dmp.steps.DmpGsWorkflowSteps.CSV_FILE_DELIMITER;
import static com.eastspring.tom.cart.dmp.utl.DmpFileHandlingUtl.MISSING_RECORDS_HEADER;
import static com.eastspring.tom.cart.dmp.utl.DmpFileHandlingUtl.RECONCILIATION_FAILED_BECAUSE_OF_DATA_MISMATCH;
import static com.eastspring.tom.cart.dmp.utl.DmpFileHandlingUtl.REGX_TIME_FORMAT;

@RunWith( SpringJUnit4ClassRunner.class )
@ContextConfiguration( classes = {CartDmpStepsSvcUtlConfig.class} )
public class DmpFileHandlingUtlRunIT {

    @Autowired
    private DmpFileHandlingUtl dmpFileHandlingUtl;

    @Autowired
    private FileDirUtil fileDirUtil;

    @Autowired
    private FormatterUtil formatterUtil;

    @Autowired
    private WorkspaceUtil workspaceUtil;

    @BeforeClass
    public static void setUpClass() {
        CartDmpTestConfig.configureLogging(DmpFileHandlingUtlRunIT.class);
    }

    @Rule
    public ExpectedException thrown = ExpectedException.none();

    @Test
    public void testGetBBPriceFileFields() {
        String filePath = Paths.get("target/test-classes/files/bbg_prices.out").normalize().toString();
        List<String> listOfFields = dmpFileHandlingUtl.getBBPriceFileFields(filePath);
        Assert.assertEquals(20, listOfFields.size());
        System.out.println(listOfFields);
    }

    @Test
    public void testGetBBPriceFileData_Test1() {
        String filePath = Paths.get("target/test-classes/files/bbg_prices.out").normalize().toString();
        String fieldData = dmpFileHandlingUtl.getBBPriceFileFieldData(filePath, 1, "ID_BB_GLOBAL");
        Assert.assertEquals("BBG000T1JRF9", fieldData);
    }

    @Test
    public void testGetBBPriceFileData_Test2() {
        String filePath = Paths.get("target/test-classes/files/bbg_prices.out").normalize().toString();
        String fieldData = dmpFileHandlingUtl.getBBPriceFileFieldData(filePath, 1, "ID_CUSIP");
        Assert.assertEquals("N.A.", fieldData);
    }

    @Test
    public void testGetBBPriceFileData_FieldNotAvailable() {
        thrown.expect(CartException.class);
        thrown.expectMessage("not available in the Price file");
        String filePath = Paths.get("target/test-classes/files/bbg_prices.out").normalize().toString();
        dmpFileHandlingUtl.getBBPriceFileFieldData(filePath, 1, "ID_BB");
    }

    @Test
    public void testGetNoOfBBDataRecords() {
        String filePath = Paths.get("target/test-classes/files/bbg_prices.out").normalize().toString();
        Integer noOfDataRecords = dmpFileHandlingUtl.getNoOfBBDataRecords(filePath);
        Assert.assertEquals(4, (int) noOfDataRecords);
    }

    @Test
    public void testGetColumnValueMapFromExcel() {
        String filePath = Paths.get("target/test-classes/files/ESI_PRICE_1_Template.xlsx").normalize().toString();
        Map<String, String> result = dmpFileHandlingUtl.getColumnValueMapFromExcel(filePath, 0, 1);
        Assert.assertEquals("100.5", result.entrySet()
                .stream()
                .filter(x -> x.getKey().equals("PRICE"))
                .map(Map.Entry::getValue)
                .collect(Collectors.joining()));
    }

    @Test
    public void testGetColumnValueMapFromExcel_InvalidIndex() {
        thrown.expect(CartException.class);
        thrown.expectMessage(DmpFileHandlingUtl.PROCESSING_FAILED);
        String filePath = Paths.get("target/test-classes/files/ESI_PRICE_1_Template.xlsx").normalize().toString();
        dmpFileHandlingUtl.getColumnValueMapFromExcel(filePath, 2, 1);
    }

    @Test
    public void testGetColumnValueMapFromExcel_InvalidFilePath() {
        thrown.expect(CartException.class);
        thrown.expectMessage(DmpFileHandlingUtl.PROCESSING_FAILED);
        String filePath = Paths.get("target/test-classes/files/No_file.xlsx").normalize().toString();
        dmpFileHandlingUtl.getColumnValueMapFromExcel(filePath, 1, 1);
    }

    @Test
    public void testGetColumnValueMapFromExcel_NullResultMap() {
        thrown.expect(CartException.class);
        thrown.expectMessage(DmpFileHandlingUtl.PROCESSING_FAILED);
        String filePath = Paths.get("target/test-classes/files/ESI_PRICE_1_Template.xlsx").normalize().toString();
        dmpFileHandlingUtl.getColumnValueMapFromExcel(filePath, 0, 3);

    }

    @Test
    public void testGetFileContentToList() {
        String filePath = Paths.get("target/test-classes/files/bbg_prices.out").normalize().toString();
        List<String> result = dmpFileHandlingUtl.getFileContentToList(filePath);
        Assert.assertEquals("START-OF-FILE", result.stream().filter(x -> x.equals("START-OF-FILE")).collect(Collectors.joining()));
        Assert.assertEquals("END-OF-FILE", result.stream().filter(x -> x.equals("END-OF-FILE")).collect(Collectors.joining()));
    }

    @Test
    public void testGetFileContentToList_bulkFile() {
        String filePath = Paths.get("target/test-classes/files/factsheet.csv").normalize().toString();
        List<String> result = dmpFileHandlingUtl.getFileContentToList(filePath);
        Assert.assertTrue(result.size() > 50000);
    }

    @Test
    public void testGetFileContentToList_FileNotFound() {
        thrown.expect(CartException.class);
        thrown.expectMessage("does not exists!");
        String filePath = Paths.get("target/test-classes/files/No_file.xlsx").normalize().toString();
        dmpFileHandlingUtl.getFileContentToList(filePath);
    }

    @Test
    public void testGetColumnValueWithReferenceValue() {
        final String file = "target/test-classes/files/outbound.csv";
        final String expectedVal = "S61334504";
        final String actualVal = dmpFileHandlingUtl.getColumnValueWithReferenceValue(file, "BCUSIP", "ISIN", "TW0002377009", CSV_FILE_DELIMITER);
        Assert.assertEquals(expectedVal, actualVal);
    }

    @Test
    public void testGetColumnValueWithReferenceValue_RefValNotFound() {
        thrown.expect(CartException.class);
        thrown.expectMessage("Failed to find Value [TW00023770] under Column [ISIN] in file [target/test-classes/files/outbound.csv]");
        final String file = "target/test-classes/files/outbound.csv";
        dmpFileHandlingUtl.getColumnValueWithReferenceValue(file, "BCUSIP", "ISIN", "TW00023770", CSV_FILE_DELIMITER);
    }


    @Test
    public void testTruncateTimeStamp() throws FileNotFoundException {
        final String file = "target/test-classes/files/regex/orders_withTimeStamp.csv";
        final String outfile = "target/test-classes/files/regex/orders_withTimeStamp_1.csv";
        dmpFileHandlingUtl.truncateTimestampInFile(file, REGX_TIME_FORMAT, false);
        Assert.assertTrue(fileDirUtil.readFileLineToString(file, 1).matches("(.*)" + REGX_TIME_FORMAT + "(.*)"));
        Assert.assertFalse(fileDirUtil.readFileLineToString(outfile, 1).matches("(.*)" + REGX_TIME_FORMAT + "(.*)"));
    }

    @Test
    public void testFormatXml() {
        final String file = "target/test-classes/files/xml-format/unformat.xml";
        final String outfile = "target/test-classes/files/xml-format/unformat_1.xml";

        fileDirUtil.writeStringToFile(file, "<?xml version='1.0' encoding='UTF-8'?><GFCash><CashRecord><MessageFunc>NEWM</MessageFunc></CashRecord></GFCash>");

        dmpFileHandlingUtl.formatXml(file, false, false);
        Assert.assertTrue(fileDirUtil.verifyFileExists(outfile));
    }

    @Test
    public void testgetColumnValueWithReferenceValue() {
        final String file = "target/test-classes/files/esi_brs_p_price.csv";
        Map<String, String> refColsData = new HashMap<>();
        refColsData.put("ISIN", "TH0371010Z13");
        refColsData.put("SOURCE", "ESTHF");
        refColsData.put("CLIENT_ID", "ESL1992457");
        final String expectedVal = "23.6";
        final String actualVal = dmpFileHandlingUtl.getColumnValueWithReferenceValue(file, "PRICE", refColsData, CSV_FILE_DELIMITER);
        Assert.assertEquals(expectedVal, actualVal);
    }


    @Test
    public void testGetColumnValueWithReferenceValue_noUniqueRow() {
        thrown.expect(CartException.class);
        thrown.expectMessage("Records not found with column [ISIN] and value [TH0371010Z]");
        Map<String, String> refColsData = new HashMap<>();
        refColsData.put("ISIN", "TH0371010Z");
        refColsData.put("SOURCE", "ESTHF");
        final String file = "target/test-classes/files/esi_brs_p_price.csv";
        dmpFileHandlingUtl.getColumnValueWithReferenceValue(file, "PRICE", refColsData, CSV_FILE_DELIMITER);
    }


    @Test
    public void testGetColumnValueWithReferenceValue_uniqueWith2ndParam() {
        final String file = "target/test-classes/files/esi_brs_p_price.csv";
        Map<String, String> refColsData = new HashMap<>();
        refColsData.put("ISIN", "TH0834010017");
        refColsData.put("SOURCE", "ESTHX");
        final String expectedVal = "94";
        final String actualVal = dmpFileHandlingUtl.getColumnValueWithReferenceValue(file, "PRICE", refColsData, CSV_FILE_DELIMITER);
        Assert.assertEquals(expectedVal, actualVal);
    }

    @Test
    public void testGetColumnValueWithReferenceValue_uniqueFoundAtLastRow() {
        final String file = "target/test-classes/files/esi_brs_p_price.csv";
        Map<String, String> refColsData = new HashMap<>();
        refColsData.put("ISIN", "TH0834010017");
        refColsData.put("SOURCE", "ESTHY");
        final String expectedVal = "95.5";
        final String actualVal = dmpFileHandlingUtl.getColumnValueWithReferenceValue(file, "PRICE", refColsData, CSV_FILE_DELIMITER);
        Assert.assertEquals(expectedVal, actualVal);
    }

    @Test
    public void testGetColumnValueWithReferenceValue_multipleRows() {
        thrown.expect(CartException.class);
        thrown.expectMessage("Unique Record not found with given params [{ISIN=TH0834010017}]");
        final String file = "target/test-classes/files/esi_brs_p_price.csv";
        Map<String, String> refColsData = new HashMap<>();
        refColsData.put("ISIN", "TH0834010017");
        dmpFileHandlingUtl.getColumnValueWithReferenceValue(file, "PRICE", refColsData, CSV_FILE_DELIMITER);
    }

    @Test
    public void testGetColumnValueWithReferenceValue_checkAllColumns() {
        final String file = "target/test-classes/files/test.csv";
        Map<String, String> refColsData = new HashMap<>();
        refColsData.put("A", "a");
        refColsData.put("B", "y");
        refColsData.put("C", "g");
        Assert.assertEquals("g", dmpFileHandlingUtl.getColumnValueWithReferenceValue(file, "C", refColsData, CSV_FILE_DELIMITER));
    }

    //@Test -- no need to run this on every build
    public void testGetColumnValueWithReferenceValue_bulkFile() {
        final String file = "target/test-classes/files/factsheet.csv";
        Map<String, String> refColsData = new HashMap<>();
        refColsData.put("ISIN", "TH0737036C04");
        refColsData.put("SHORT_DESC", "MSCTY");
        refColsData.put("INDUS_CLASS", "MSCI Countries");
        Assert.assertEquals("TH0737036C04", dmpFileHandlingUtl.getColumnValueWithReferenceValue(file, "SECURITY_ALIAS", refColsData, CSV_FILE_DELIMITER));
    }

    @Test
    public void testGetFieldValuesFromFileWithHeader_CSV() {
        final String file = "target/test-classes/files/filetest1.csv";
        final String content = "Header1,Header2,Header3\n1,2,3\n4,5,6";
        fileDirUtil.writeStringToFile(file, content);
        List<String> list = dmpFileHandlingUtl.getFieldValuesFromFileWithHeader(file, 1, "Header1", "Header2", ',');
        Assert.assertEquals("2", list.get(0));
        Assert.assertEquals("5", list.get(1));
    }

    @Test
    public void testGetFieldValuesFromFileWithHeader_CSV_withoutReference() {
        final String file = "target/test-classes/files/filetest1.csv";
        final String content = "Header1,Header2,Header3\n1,2,3\n4,5,6";
        fileDirUtil.writeStringToFile(file, content);
        List<String> list = dmpFileHandlingUtl.getFieldValuesFromFileWithHeader(file, 1, "", "Header2", ',');
        Assert.assertEquals("2", list.get(0));
        Assert.assertEquals("5", list.get(1));
    }

    @Test
    public void testGetFieldValuesFromFileWithHeader_PSV() {
        final String file = "target/test-classes/files/filetest1.out";
        final String content = "Header1|Header2|Header3\n1|2|3\n4|5|6";
        fileDirUtil.writeStringToFile(file, content);
        List<String> list = dmpFileHandlingUtl.getFieldValuesFromFileWithHeader(file, 1, "Header1", "Header2", '|');
        Assert.assertEquals("2", list.get(0));
        Assert.assertEquals("5", list.get(1));
    }

    @Test
    public void testGetFieldValuesFromFileWithHeader_PSV_With_Extra_Content() {
        final String file = "target/test-classes/files/filetest1_extra.out";
        final String content = "Header1|Header2|Header3\n1|2|3\n4|5|6\nEnd Of File";
        fileDirUtil.writeStringToFile(file, content);
        List<String> list = dmpFileHandlingUtl.getFieldValuesFromFileWithHeader(file, 1, "Header1", "Header2", '|');
        Assert.assertEquals("2", list.get(0));
        Assert.assertEquals("5", list.get(1));
    }

    @Test
    public void testGetFieldValuesFromFileWithHeader_PSV_withoutReference() {
        final String file = "target/test-classes/files/filetest1.out";
        final String content = "Header1|Header2|Header3\n1|2|3\n4|5|6";
        fileDirUtil.writeStringToFile(file, content);
        List<String> list = dmpFileHandlingUtl.getFieldValuesFromFileWithHeader(file, 1, "", "Header2", '|');
        Assert.assertEquals("2", list.get(0));
        Assert.assertEquals("5", list.get(1));
    }

    @Test
    public void testGetFieldValuesFromFileWithHeader_CSV_withDiffReference() {
        final String file = "target/test-classes/files/filetest1.csv";
        final String content = "Header1,Header2,Header3\n2,3\n5,6";
        fileDirUtil.writeStringToFile(file, content);
        List<String> list = dmpFileHandlingUtl.getFieldValuesFromFileWithHeader(file, 1, "Header2", "Header3", ',');
        Assert.assertEquals("3", list.get(0));
        Assert.assertEquals("6", list.get(1));
    }

    @Test
    public void getFieldValuesFromFileWithHeader_CSV_withDoubleQuotes() {
        final String file = "target/test-classes/files/double_quotes.txt";
        List<String> list = dmpFileHandlingUtl.getFieldValuesFromFileWithHeader(file, 1, "\"PERIOD_FROM_DATE\"", "\"CLIENT_PORTFOLIO_GROUPING_NAME\"", ',');
        Assert.assertEquals("IOF", list.get(0));
    }

    @Test
    public void testGetFieldValuesFromFileWithHeader_ColumnNotFoundException() {
        thrown.expect(CartException.class);
        thrown.expectMessage("Failed to find Value under Column [Heyader2] in file [target/test-classes/files/filetest1.csv]");
        String file = "target/test-classes/files/filetest1.csv";
        dmpFileHandlingUtl.getFieldValuesFromFileWithHeader(file, 1, "Header1", "Heyader2", ',');
    }

    @Test
    public void testDuplicateRowsCheck_DuplicatesExist() {
        final String file = "target/test-classes/files/duplicates/dups.csv";
        Assert.assertTrue(dmpFileHandlingUtl.hasDuplicateRecordsInFile(file));
    }

    @Test
    public void testDuplicateRowsCheck_NoDuplicatesExist() {
        final String file = "target/test-classes/files/duplicates/nodups.csv";
        Assert.assertFalse(dmpFileHandlingUtl.hasDuplicateRecordsInFile(file));
    }

    @Test
    public void testReconcileFlatFiles_oneFileHasMoreRecords() {
        final String currFile = "target/test-classes/files/reconcile/ignoreRowCnt/file1.txt";
        final String referenceFile = "target/test-classes/files/reconcile/ignoreRowCnt/file2.txt";

        ReconInputSpec inputSpec = ReconInputSpec.builder()
                .file1(currFile)
                .file2(referenceFile)
                .ignoreRowCount(false)
                .lookForRecords(true)
                .considerOrder(false)
                .ignoreHeader(false)
                .build();

        ReconOutputSpec outputSpec = dmpFileHandlingUtl.reconcileFlatFiles(inputSpec);
        Assert.assertEquals(outputSpec.getExceptions().get(0), formatterUtil.format(MISSING_RECORDS_HEADER, new File(currFile).getAbsolutePath(), new File(referenceFile).getAbsolutePath()));
        Assert.assertEquals(outputSpec.getExceptions().get(1).trim(), "[Line: 7] => 7");
    }


    @Test
    public void testReconcileFlatFiles_missingRecordsInBoth() {
        final String currFile = "target/test-classes/files/reconcile/ignoreRowCnt/file2.txt"; //10 records
        final String referenceFile = "target/test-classes/files/reconcile/ignoreRowCnt/file3.txt"; //7 records

        ReconInputSpec inputSpec = ReconInputSpec.builder()
                .file1(currFile)
                .file2(referenceFile)
                .ignoreRowCount(false)
                .lookForRecords(true)
                .considerOrder(false)
                .ignoreHeader(false)
                .build();

        ReconOutputSpec outputSpec = dmpFileHandlingUtl.reconcileFlatFiles(inputSpec);

        Assert.assertFalse(outputSpec.getIsMatch());
        Assert.assertEquals(RECONCILIATION_FAILED_BECAUSE_OF_DATA_MISMATCH, outputSpec.getErrorMessage());
        Assert.assertEquals(outputSpec.getExceptions().get(0), formatterUtil.format(MISSING_RECORDS_HEADER, new File(referenceFile).getAbsolutePath(), new File(currFile).getAbsolutePath()));
        Assert.assertEquals(outputSpec.getExceptions().get(1).trim(), "[Line: 7] => 7");
        Assert.assertTrue(outputSpec.getExceptions().contains(formatterUtil.format(MISSING_RECORDS_HEADER, new File(currFile).getAbsolutePath(), new File(referenceFile).getAbsolutePath())));
    }


    @Test
    public void testGetFilesExcludingColumns() {
        workspaceUtil.setBaseDir(System.getProperty("user.dir"));
        String file1 = "target/test-classes/files/test_excludeCol.csv";
        String file2 = "target/test-classes/files/test_excludeCol2.csv";
        List<String> exclude = new ArrayList<>();
        exclude.add("B");
        String[] result = dmpFileHandlingUtl.getFilesExcludingColumns(exclude, file1, file2);
        Assert.assertTrue(fileDirUtil.verifyFileExists(result[0]));
        Assert.assertTrue(fileDirUtil.verifyFileExists(result[1]));

    }

    @Test
    public void testGetFilesExcludingColumns_withNullValues() {
        workspaceUtil.setBaseDir(System.getProperty("user.dir"));
        String file1 = "target/test-classes/files/SSDR_SBL_datareport_20190927_1.csv";
        List<String> exclude = new ArrayList<>();
        exclude.add("SBL %");
        exclude.add("DOI %");
        String[] result = dmpFileHandlingUtl.getFilesExcludingColumns(exclude, file1);
        Assert.assertTrue(fileDirUtil.verifyFileExists(result[0]));
    }

    @Test
    public void testGetFilesExcludingColumnsWithIndices() {
        workspaceUtil.setBaseDir(System.getProperty("user.dir"));

        String file1 = "target/test-classes/files/test_excludeCol.csv";
        List<Integer> excludeIndices = new ArrayList<>();
        excludeIndices.add(1);
        String[] result = dmpFileHandlingUtl.getFilesExcludingColumns(excludeIndices, file1);
        final String headerWithIndicesTrim = fileDirUtil.readFileLineToString(result[0], 1);

        List<String> excludeColumns = new ArrayList<>();
        excludeColumns.add("B");
        result = dmpFileHandlingUtl.getFilesExcludingColumns(excludeColumns, file1);
        final String headerWithColumnsTrim = fileDirUtil.readFileLineToString(result[0], 1);
        Assert.assertEquals(headerWithColumnsTrim, headerWithIndicesTrim);
    }

}
