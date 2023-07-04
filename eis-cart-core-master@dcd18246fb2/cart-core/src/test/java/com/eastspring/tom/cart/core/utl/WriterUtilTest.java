package com.eastspring.tom.cart.core.utl;

import com.eastspring.tom.cart.core.CartCoreTestConfig;
import org.junit.Before;
import org.junit.BeforeClass;
import org.junit.Test;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.MockitoAnnotations;

import java.io.PrintStream;
import java.io.PrintWriter;

import static org.junit.Assert.assertNotNull;

public class WriterUtilTest {
    @InjectMocks
    private WriterUtil writerUtil;

    @Mock
    private PrintStream printStream;

    @BeforeClass
    public static void setUpClass() {
        CartCoreTestConfig.configureLogging(WriterUtilTest.class);
    }

    @Before
    public void initMocks() {
        MockitoAnnotations.initMocks(this);
    }

    @Test
    public void testGetPrintWriterByPrintStream() {
        PrintWriter printWriter = writerUtil.getPrintWriterByPrintStream(printStream);
        assertNotNull(printWriter);
    }
}
