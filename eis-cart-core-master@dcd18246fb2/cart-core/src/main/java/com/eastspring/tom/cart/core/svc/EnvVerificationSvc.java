package com.eastspring.tom.cart.core.svc;

import com.eastspring.tom.cart.core.utl.TcpUtil;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;

public class EnvVerificationSvc {
    private static final Logger LOGGER = LoggerFactory.getLogger(EnvVerificationSvc.class);

    @Autowired
    private StateSvc stateSvc;

    @Autowired
    private TcpUtil tcpUtil;

    public void verifyReachableTcpService(String host, String tcpPortStr) {
        String hostExpanded = stateSvc.expandVar(host);
        String tcpPortExpanded = stateSvc.expandVar(tcpPortStr);
        int tcpPort = Integer.parseInt(tcpPortExpanded.trim());
        LOGGER.debug("verify: TCP endpoint: reachable [{}:{}]", hostExpanded, tcpPort);
        tcpUtil.openSocket(hostExpanded, tcpPort);
        LOGGER.debug("  verify: TCP endpoint: TCP socket connection verified");
    }

    public void verifyNamedHostSshLogin(String namedHost) {
        LOGGER.debug("verify: SSH login: to named host[{}]", namedHost);
        // implement this
        // TOM-2814 to implement verifyNamedHostSshLogin()
        LOGGER.debug("  verify: SSH login: result OK");
    }
}
