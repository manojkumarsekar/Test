package com.eastspring.tom.cart.core.svc;

import com.eastspring.tom.cart.core.CartCoreTestConfig;
import com.eastspring.tom.cart.core.steps.CartCoreStepsSvcUtlTestConfig;
import com.eastspring.tom.cart.core.utl.FileDirUtil;
import org.junit.BeforeClass;
import org.junit.Test;
import org.junit.runner.RunWith;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.test.context.ContextConfiguration;
import org.springframework.test.context.junit4.SpringJUnit4ClassRunner;

@RunWith(SpringJUnit4ClassRunner.class)
@ContextConfiguration(classes = {CartCoreStepsSvcUtlTestConfig.class})
public class CompressionSvcRunIT {

    @Autowired
    private CompressionSvc compressionSvc;

    @Autowired
    private FileDirUtil fileDirUtil;

    @BeforeClass
    public static void setUpClass() {
        CartCoreTestConfig.configureLogging(CompressionSvcRunIT.class);
    }

    @Test
    public void testUnzipSingleFile() throws Exception {
        String expandedSrcDir = fileDirUtil.getMavenTestResourcesPath("recon/performance_l1");
        String filename = "CPR201007_20100901_09-25 FINAL (JUL 2010).zip";
        String testOutDir = fileDirUtil.ensureTestOutDirExist("recon/performance_l1");
        System.out.println(testOutDir);
        String resultFullpath = compressionSvc.unzipSingleFile(expandedSrcDir + "/" + filename, testOutDir);
        System.out.println(resultFullpath);
    }
}
