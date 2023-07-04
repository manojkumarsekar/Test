package com.eastspring.tom.cart.core.steps;

import com.eastspring.tom.cart.core.CartCoreTestConfig;
import com.eastspring.tom.cart.core.svc.StateSvc;
import com.eastspring.tom.cart.core.utl.WorkspaceUtil;
import org.junit.BeforeClass;
import org.junit.Test;
import org.junit.runner.RunWith;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.test.context.ContextConfiguration;
import org.springframework.test.context.junit4.SpringRunner;

import java.util.Arrays;
import java.util.Collections;

@RunWith(SpringRunner.class)
@ContextConfiguration(classes = {CartCoreStepsSvcUtlTestConfig.class})
public class HostStepsIT {

    public static final String DMP_SSH_INBOUND_PATH = "${dmp.ssh.inbound.path}";
    public static final String DMP_SSH_INBOUND = "dmp.ssh.inbound";

    @Autowired
    private HostSteps steps;

    @Autowired
    private StateSvc stateSvc;

    @Autowired
    private WorkspaceUtil workspaceUtil;

    @BeforeClass
    public static void initLogging() {
        CartCoreTestConfig.configureLogging(HostStepsIT.class);
    }

    @Test
    public void testHostSteps() {
        stateSvc.useNamedEnvironment("TOM_DEV1");
        workspaceUtil.setBaseDir(System.getProperty("user.dir"));
        String localDir = "target/test-classes/remote/upload";
        final String file = "bbg_prices.out";
        steps.copyLocalFilesToRemote(localDir, Collections.singletonList(file), DMP_SSH_INBOUND, DMP_SSH_INBOUND_PATH);
        steps.expectFileAvailableInFolderAfterProcessing(DMP_SSH_INBOUND, DMP_SSH_INBOUND_PATH, Collections.singletonList(file));
        steps.saveFileAs(DMP_SSH_INBOUND_PATH + "/" + file, DMP_SSH_INBOUND_PATH + "/" + file + "_1", DMP_SSH_INBOUND);
        steps.expectFileAvailableInFolderAfterProcessing(DMP_SSH_INBOUND, DMP_SSH_INBOUND_PATH, Collections.singletonList(file + "_1"));
        steps.renameFile(DMP_SSH_INBOUND_PATH + "/" + file + "_1", DMP_SSH_INBOUND_PATH + "/" + file + "_2", DMP_SSH_INBOUND);
        steps.expectFileAvailableInFolderAfterProcessing(DMP_SSH_INBOUND, DMP_SSH_INBOUND_PATH, Collections.singletonList(file + "_2"));
        steps.removeFileIfExists(DMP_SSH_INBOUND, DMP_SSH_INBOUND_PATH, Arrays.asList(file, file + "_2"));
    }
}
