package com.eastspring.tom.cart.core.svc;

import com.eastspring.tom.cart.core.CartCoreTestConfig;
import com.eastspring.tom.cart.core.utl.FileDirUtil;
import com.eastspring.tom.cart.core.utl.WorkspaceUtil;
import org.junit.Assert;
import org.junit.BeforeClass;
import org.junit.Test;
import org.junit.runner.RunWith;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.test.context.ContextConfiguration;
import org.springframework.test.context.junit4.SpringJUnit4ClassRunner;

@RunWith(SpringJUnit4ClassRunner.class)
@ContextConfiguration(classes = {CartCoreSvcUtlTestConfig.class})
public class WorkspaceDirSvcRunIT {
    private static final Logger LOGGER = LoggerFactory.getLogger(WorkspaceDirSvcRunIT.class);

    @Autowired
    private FileDirUtil fileDirUtil;

    @Autowired
    private WorkspaceDirSvc workspaceDirSvc;

    @Autowired
    private WorkspaceUtil workspaceUtil;

    @BeforeClass
    public static void setUpClass() {
        CartCoreTestConfig.configureLogging(WorkspaceDirSvcRunIT.class);
    }

    @Test
    public void testNormalize_relative() throws Exception {
        String result = workspaceDirSvc.normalize("tests/features/tools/csv");
        String workspaceBaseDir = workspaceUtil.getBaseDir();
        String expectedPath = workspaceBaseDir + "/tests/features/tools/csv";
        Assert.assertNotNull(result);
        Assert.assertEquals(expectedPath, result);
    }

//    @Test
    // TODO: fix this, this does not work in Linux Bamboo agent!
    public void testNormalize_absolute() throws Exception {
        String result = workspaceDirSvc.normalize("d:/tmp/tests/features/tools/csv");
        String expectedPath = "d:/tmp/tests/features/tools/csv";
        Assert.assertNotNull(result);
        Assert.assertEquals(expectedPath, result);
    }
}
