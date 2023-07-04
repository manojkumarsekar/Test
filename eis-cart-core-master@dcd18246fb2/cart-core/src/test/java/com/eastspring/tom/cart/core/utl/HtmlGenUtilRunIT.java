package com.eastspring.tom.cart.core.utl;

import com.eastspring.tom.cart.core.CartCoreTestConfig;
import org.junit.Assert;
import org.junit.BeforeClass;
import org.junit.Test;
import org.junit.runner.RunWith;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.test.context.ContextConfiguration;
import org.springframework.test.context.junit4.SpringJUnit4ClassRunner;

import java.util.Arrays;
import java.util.List;

@RunWith( SpringJUnit4ClassRunner.class )
@ContextConfiguration( classes = {CartCoreUtlConfig.class} )
public class HtmlGenUtilRunIT {

    private static final String EXPECTED_STRING = "<table style=\"width:100%\" border=\"1\" cellpadding=\"10\"><tbody><tr><th>Column1</th><th>Column2</th><th>Column3</th></tr><tr><td style=\"text-align:center\" >R1C1</td><td style=\"text-align:center\" >R1C2</td><td style=\"text-align:center\" >R1C3</td></tr></tbody></table>\n";

    @Autowired
    private HtmlGenUtil htmlGenUtil;

    @Autowired
    private FileDirUtil fileDirUtil;


    @BeforeClass
    public static void setUpClass() {
        CartCoreTestConfig.configureLogging(HtmlGenUtilRunIT.class);
    }

    @Test
    public void testGenerateSourceCode() {
        List<String> headers = Arrays.asList("Column1", "Column2", "Column3");
        final String header = htmlGenUtil.createHeader(headers);
        final String row1 = htmlGenUtil.createRow(Arrays.asList("R1C1", "R1C2", "R1C3"));
        final List<String> entries = Arrays.asList(header, row1);
        final String actual = htmlGenUtil.generateHtmlCode(entries);
        Assert.assertEquals(EXPECTED_STRING.trim(), actual.trim());
    }


}
