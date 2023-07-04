package com.eastspring.tom.cart.core.svc;

import com.eastspring.tom.cart.core.CartCoreTestConfig;
import com.eastspring.tom.cart.core.utl.TcpUtil;
import org.junit.Before;
import org.junit.BeforeClass;
import org.junit.Test;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.MockitoAnnotations;

import static org.mockito.Mockito.verify;
import static org.mockito.Mockito.when;

public class EnvVerificationSvcTest {
    @InjectMocks
    private EnvVerificationSvc svc;

    @Mock
    private StateSvc stateSvc;

    @Mock
    private TcpUtil tcpUtil;

    @BeforeClass
    public static void initLogging() {
        CartCoreTestConfig.configureLogging(EnvVerificationSvcTest.class);
    }

    @Before
    public void initMocks() {
        MockitoAnnotations.initMocks(this);
    }

    @Test
    public void testVerifyReachableTcpService() throws Exception {
        String host = "${my.host}";
        String expandedHost = "localhost";
        String tcpPortStr = "${my.ip.address}";
        String expandedTcpPortStr = "22";
        when(stateSvc.expandVar(host)).thenReturn(expandedHost);
        when(stateSvc.expandVar(tcpPortStr)).thenReturn(expandedTcpPortStr);
        svc.verifyReachableTcpService(host, tcpPortStr);
        verify(tcpUtil).openSocket(expandedHost, Integer.parseInt(expandedTcpPortStr));
    }

    @Test
    public void testVerifyNamedSshLogin() {
        svc.verifyNamedHostSshLogin("my.named.host");
    }
}
