package com.eastspring.tom.cart.core.steps;

import com.eastspring.tom.cart.core.mdl.RemoteOutput;
import com.eastspring.tom.cart.core.svc.ControlMSvc;
import com.eastspring.tom.cart.core.svc.RuntimeRemoteSvc;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;

public class ControlMSteps {
    private static final Logger LOGGER = LoggerFactory.getLogger(ControlMSteps.class);

    @Autowired
    private RuntimeRemoteSvc runtimeRemoteSvc;

    @Autowired
    private ControlMSvc controlMSvc;

    public void executeControlMJob(String jobName, String parentFolder) {
        String[] ctmOrderCmd = new String[]{
                "/opt/controlm/ctm/exe/ctmorder",
                "-FOLDER",
                parentFolder,
                "-NAME",
                jobName,
                "-ODATE",
                controlMSvc.getTodayOdate(),
                "-FORCE",
                "y",
                "-INTO_FOLDER_ORDERID ALONE"
        };

        String cmdLine = String.join(" ", ctmOrderCmd);
        LOGGER.debug("cmdLine: [{}]", cmdLine);

        RemoteOutput remoteOutput = controlMSvc.runCliControlM(cmdLine);
        LOGGER.debug("Output [{}]", remoteOutput.getOutput());
    }

    public void executeControlMSmartFolder(final String smartFolderName, final String parentFolder) {
        String[] ctmOrderCmd = new String[]{
                "/opt/controlm/ctm/exe/ctmorder",
                "-FOLDER",
                parentFolder,
                "-NAME",
                smartFolderName,
                "-ODATE",
                controlMSvc.getTodayOdate(),
                "-FORCE",
                "y",
                "-INTO_FOLDER_ORDERID NEWF"
        };

        String cmdLine = String.join(" ", ctmOrderCmd);
        LOGGER.debug("cmdLine: [{}]", cmdLine);

        RemoteOutput remoteOutput = controlMSvc.runCliControlM(cmdLine);
        LOGGER.debug("Output [{}]", remoteOutput.getOutput());

    }


}
