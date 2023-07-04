package com.eastspring.tom.cart.core.utl;

import com.eastspring.tom.cart.core.CartCoreTestConfig;
import org.junit.BeforeClass;
import org.junit.Test;
import org.junit.runner.RunWith;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.test.context.ContextConfiguration;
import org.springframework.test.context.junit4.SpringJUnit4ClassRunner;

import java.io.PrintWriter;

import static org.junit.Assert.assertNotNull;

@RunWith(SpringJUnit4ClassRunner.class)
@ContextConfiguration(classes = {CartCoreUtlConfig.class})
public class WriterUtilRunIT {
    @Autowired
    private FileDirUtil fileDirUtil;

    @Autowired
    private WriterUtil writerUtil;

    @BeforeClass
    public static void setUpClass() {
        CartCoreTestConfig.configureLogging(WriterUtilRunIT.class);
    }


    @Test
    public void testGetPrintWriterByFilename() {
        String fileFullpath = fileDirUtil.getMavenTestResourcesPath("writerUtil.file");
        PrintWriter printWriter = writerUtil.getPrintWriterByFilename(fileFullpath);
        assertNotNull(printWriter);
        fileDirUtil.forceDelete(fileFullpath);
    }
}
