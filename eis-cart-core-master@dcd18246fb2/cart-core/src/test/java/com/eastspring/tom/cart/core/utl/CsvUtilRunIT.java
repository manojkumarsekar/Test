package com.eastspring.tom.cart.core.utl;

import com.eastspring.tom.cart.core.CartCoreTestConfig;
import com.eastspring.tom.cart.core.mdl.CsvFileSpec;
import com.eastspring.tom.cart.core.svc.CartCoreSvcUtlTestConfig;
import com.eastspring.tom.cart.cst.EncodingConstants;
import org.junit.Assert;
import org.junit.BeforeClass;
import org.junit.Test;
import org.junit.runner.RunWith;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.test.context.ContextConfiguration;
import org.springframework.test.context.junit4.SpringJUnit4ClassRunner;

import java.util.List;

@RunWith(SpringJUnit4ClassRunner.class)
@ContextConfiguration(classes = {CartCoreSvcUtlTestConfig.class})
public class CsvUtilRunIT {
    @Autowired
    private CsvUtil csvUtil;

    @Autowired
    private FileDirUtil fileDirUtil;

    @BeforeClass
    public static void setUpClass() {
        CartCoreTestConfig.configureLogging(CsvUtilRunIT.class);
    }

    @Test
    public void testGetCsvHeaderNamesAsArray() throws Exception {
        String filename = fileDirUtil.getMavenTestResourcesPath("csv-transform/file-transform-sample-01.csv");
        CsvFileSpec csvFileSpec = new CsvFileSpec(filename, EncodingConstants.UTF_8, ',');
        String[] result = csvUtil.getCsvHeaderNamesAsArray(csvFileSpec);
        Assert.assertNotNull(result);
        Assert.assertEquals(4, result.length);
        Assert.assertEquals("title1", result[0]);
        Assert.assertEquals("header name 2", result[1]);
        Assert.assertEquals(" header Name 3", result[2]);
        Assert.assertEquals("header4", result[3]);
    }

    @Test
    public void testGetCsvHeaderNamesAsList() throws Exception {
        String filename = fileDirUtil.getMavenTestResourcesPath("csv-transform/file-transform-sample-01.csv");
        CsvFileSpec csvFileSpec = new CsvFileSpec(filename, EncodingConstants.UTF_8, ',');
        List<String> result = csvUtil.getCsvHeaderNamesAsList(csvFileSpec);
        Assert.assertNotNull(result);
        Assert.assertEquals(4, result.size());
        Assert.assertEquals("title1", result.get(0));
        Assert.assertEquals("header name 2", result.get(1));
        Assert.assertEquals(" header Name 3", result.get(2));
        Assert.assertEquals("header4", result.get(3));
    }
}
