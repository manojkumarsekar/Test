package com.eastspring.tom.cart.core.svc;

import com.eastspring.tom.cart.core.CartCoreTestConfig;
import com.eastspring.tom.cart.core.CartException;
import com.eastspring.tom.cart.core.CartExceptionType;
import com.eastspring.tom.cart.core.mdl.FileTransformation;
import com.eastspring.tom.cart.cst.EncodingConstants;
import org.junit.*;
import org.junit.rules.ExpectedException;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.MockitoAnnotations;

import static org.mockito.Mockito.times;
import static org.mockito.Mockito.verify;

public class FileTransformSvcTest {
    @BeforeClass
    public static void setUpClass() {
        CartCoreTestConfig.configureLogging(FileTransformSvcTest.class);
    }

    @InjectMocks
    private FileTransformSvc fileTransformSvc;

    @Mock
    private FileDirSvc fileDirSvc;

    @Rule
    public ExpectedException thrown = ExpectedException.none();

    @Before
    public void initMocks() {
        MockitoAnnotations.initMocks(this);
    }

    @Test
    public void testTransform_convertEncoding_success() throws Exception {
        FileTransformation ft = new FileTransformation();
        ft.setId("convert-encoding");
        ft.setFrom(EncodingConstants.UTF_16);
        ft.setTo(EncodingConstants.UTF_8);
        ft.setSrcFile("srcFile");
        ft.setDstFile("dstFile");

        fileTransformSvc.transform(ft);

        verify(fileDirSvc, times(1)).copyWithEncodingConversion(ft.getSrcFile(), ft.getDstFile(), ft.getFrom(), ft.getTo());
    }

    @Test
    public void testTransform_convertDelimiter_success() throws Exception {
        FileTransformation ft = new FileTransformation();
        ft.setId("convert-delimiter");
        ft.setFrom("\t");
        ft.setTo(",");
        ft.setSrcFile("srcFile");
        ft.setDstFile("dstFile");

        fileTransformSvc.transform(ft);

        verify(fileDirSvc, times(1)).copyWithDelimiterConversion(ft.getSrcFile(), ft.getDstFile(), ft.getFrom(), ft.getTo());
    }

    @Test
    public void testTransform_ftNull() throws Exception {
        Exception thrown = null;

        try {
            fileTransformSvc.transform(null);
        } catch (Exception e) {
            thrown = e;
        }

        Assert.assertNotNull(thrown);
        Assert.assertTrue(thrown instanceof CartException);
        CartException ce = (CartException) thrown;
        Assert.assertEquals(CartExceptionType.UNSATISFIED_IMPLICIT_ASSUMPTION, ce.getExceptionType());
        Assert.assertEquals("transformation must not be null", ce.getMessage());
    }

    @Test
    public void testTransform_ftTransformIdNull() throws Exception {
        Exception thrown = null;

        FileTransformation ft = new FileTransformation();
        ft.setId(null);

        try {
            fileTransformSvc.transform(ft);
        } catch (Exception e) {
            thrown = e;
        }

        Assert.assertNotNull(thrown);
        Assert.assertTrue(thrown instanceof CartException);
        CartException ce = (CartException) thrown;
        Assert.assertEquals(CartExceptionType.UNSATISFIED_IMPLICIT_ASSUMPTION, ce.getExceptionType());
        Assert.assertEquals("transformation id must not be null", ce.getMessage());
    }

    @Test
    public void testCsvTransformColsByNames_nullColsToNormalize() {
        thrown.expect(CartException.class);
        thrown.expectMessage("column to normalize name list must not be null");
        fileTransformSvc.csvTransformColsByNames(null, null, null, null, null, null);
    }
}
