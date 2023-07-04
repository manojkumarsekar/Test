package com.eastspring.tom.cart.core.svc;

import com.eastspring.tom.cart.core.CartCoreTestConfig;
import com.eastspring.tom.cart.core.mdl.CsvFileSpec;
import com.eastspring.tom.cart.core.mdl.FileTransformation;
import com.eastspring.tom.cart.core.utl.CsvUtil;
import com.eastspring.tom.cart.core.utl.FileDirUtil;
import com.eastspring.tom.cart.cst.EncodingConstants;
import org.joda.time.format.DateTimeFormat;
import org.joda.time.format.DateTimeFormatter;
import org.junit.Assert;
import org.junit.BeforeClass;
import org.junit.Test;
import org.junit.runner.RunWith;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.test.context.ContextConfiguration;
import org.springframework.test.context.junit4.SpringJUnit4ClassRunner;

import java.math.BigDecimal;
import java.math.RoundingMode;
import java.util.*;

@RunWith(SpringJUnit4ClassRunner.class)
@ContextConfiguration(classes = {CartCoreSvcUtlTestConfig.class})
public class FileTransformSvcRunIT {
    @Autowired
    private CsvUtil csvUtil;

    @Autowired
    private FileDirUtil fileDirUtil;

    @Autowired
    private FileTransformSvc fileTransformSvc;

    @BeforeClass
    public static void setUpClass() {
        CartCoreTestConfig.configureLogging(FileTransformSvcRunIT.class);
    }

    @Test
    public void testReadJsonConfigAsMap() throws Exception {
        String configFullpath = fileDirUtil.getMavenTestResourcesPath("csv-transform/sample_config.json");

        Map map = fileTransformSvc.readJsonConfigAsMap(configFullpath);

        List<FileTransformation> transformations = fileTransformSvc.getTransformations();

        Assert.assertNotNull(transformations);
        Assert.assertEquals(5, transformations.size());

        FileTransformation ft0 = transformations.get(0);
        Assert.assertEquals(FileTransformSvc.CONVERT_ENCODING, ft0.getId());

        FileTransformation ft1 = transformations.get(1);
        Assert.assertEquals(FileTransformSvc.CONVERT_DELIMITER, ft1.getId());

        FileTransformation ft2 = transformations.get(2);
        Assert.assertEquals(FileTransformSvc.OMIT_INITIAL_LINES, ft2.getId());

        FileTransformation ft3 = transformations.get(3);
        Assert.assertEquals(FileTransformSvc.STRIP_CHAR_FROM_COLS, ft3.getId());

        FileTransformation ft4 = transformations.get(4);
        Assert.assertEquals(FileTransformSvc.TRIM_COLS, ft4.getId());
    }

    @Test
    public void testTransform() throws Exception {
    }

    @Test
    public void testRemoveColumnsByNames() throws Exception {
        String srcFile = fileDirUtil.getMavenTestResourcesPath("csv-transform/file-transform-sample-01.csv");
        String dstFile = fileDirUtil.getMavenTestResourcesPath("csv-transform/file-transform-sample-01-temp1.csv");
        CsvFileSpec csvFileSpec = new CsvFileSpec(srcFile, EncodingConstants.UTF_8, ',');
        List<String> result = csvUtil.getCsvHeaderNamesAsList(csvFileSpec);
        Assert.assertNotNull(result);
        Assert.assertEquals(4, result.size());
        Assert.assertEquals("title1", result.get(0));
        Assert.assertEquals("header name 2", result.get(1));
        Assert.assertEquals(" header Name 3", result.get(2));
        Assert.assertEquals("header4", result.get(3));

        List<String> columnNamesToBeRemoved = new ArrayList<String>() {
            {
                add("header name 2");
                add(" header Name 3");
            }
        };
        fileTransformSvc.csvTransformRemoveColsByNames(columnNamesToBeRemoved, srcFile, dstFile);
    }

    @Test
    public void testCsvTransformColsByNames_var1() throws Exception {
        List<String> colsToNormalize = Arrays.asList("col3", "col5");
        String sourcePattern = "dd-MMM-yyyy";
        String targetPattern = "yyyy-MM-dd";
        String srcFile = fileDirUtil.getMavenTestResourcesPath("csv-transform/file-transform-sample-02.csv");
        String dstFile = fileDirUtil.getMavenTestResourcesPath("csv-transform/file-transform-sample-02-temp1.csv");
        final DateTimeFormatter srcParser = DateTimeFormat.forPattern(sourcePattern);
        final DateTimeFormatter dstFormatter = DateTimeFormat.forPattern(targetPattern);
        fileTransformSvc.csvTransformColsByNamesDefault(colsToNormalize, srcFile, dstFile, (String x, Integer m) -> x != null ? dstFormatter.print(srcParser.parseDateTime(x)) : null);
    }

    @Test
    public void testCsvTransformColsByNames_var2() throws Exception {
        List<String> colsToNormalize = Arrays.asList("col3");
        String sourcePattern = "MMM dd, yyyy";
        String targetPattern = "yyyy-MM-dd";
        String srcFile = fileDirUtil.getMavenTestResourcesPath("csv-transform/file-transform-sample-03.csv");
        String dstFile = fileDirUtil.getMavenTestResourcesPath("csv-transform/file-transform-sample-03-temp1.csv");
        String refFile = fileDirUtil.getMavenTestResourcesPath("csv-transform/file-transform-sample-03-ref1.csv");
        final DateTimeFormatter srcParser = DateTimeFormat.forPattern(sourcePattern);
        final DateTimeFormatter dstFormatter = DateTimeFormat.forPattern(targetPattern);
        fileTransformSvc.csvTransformColsByNamesDefault(colsToNormalize, srcFile, dstFile, (String x, Integer m) -> x != null ? dstFormatter.print(srcParser.parseDateTime(x)) : null);
        fileDirUtil.contentEquals(dstFile, refFile);
    }

    @Test
    public void testCsvTransformColsByNames_var3() throws Exception {
        List<String> colsToNormalize = Arrays.asList("col5");
        String sourcePattern = "dd/MM/yyyy HH:mm a";
        String targetPattern = "yyyy-MM-dd";
        String srcFile = fileDirUtil.getMavenTestResourcesPath("csv-transform/file-transform-sample-03.csv");
        String dstFile = fileDirUtil.getMavenTestResourcesPath("csv-transform/file-transform-sample-03-temp2.csv");
        String refFile = fileDirUtil.getMavenTestResourcesPath("csv-transform/file-transform-sample-03-ref2.csv");
        final DateTimeFormatter srcParser = DateTimeFormat.forPattern(sourcePattern);
        final DateTimeFormatter dstFormatter = DateTimeFormat.forPattern(targetPattern);
        fileTransformSvc.csvTransformColsByNamesDefault(colsToNormalize, srcFile, dstFile, (String x, Integer m) -> x != null ? dstFormatter.print(srcParser.parseDateTime(x)) : null);
        fileDirUtil.contentEquals(dstFile, refFile);
    }

    @Test
    public void testCsvTransformColsByNames_numPrecision1() throws Exception {
        List<String> colsToNormalize = Arrays.asList("col2");
        final int decimalPoint = 4;
        String srcFile = fileDirUtil.getMavenTestResourcesPath("csv-transform/file-transform-numprecision-01.csv");
        String dstFile = fileDirUtil.getMavenTestResourcesPath("csv-transform/file-transform-numprecision-01-out1.csv");
        String refFile = fileDirUtil.getMavenTestResourcesPath("csv-transform/file-transform-numprecision-01-ref1.csv");
        fileTransformSvc.csvTransformColsByNamesDefault(colsToNormalize, srcFile, dstFile, (String x, Integer m) -> x != null && !"".equals(x) ? new BigDecimal(x).setScale(decimalPoint, RoundingMode.HALF_UP).toPlainString() : "");
        fileDirUtil.contentEquals(dstFile, refFile);
    }
}
