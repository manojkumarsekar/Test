package com.eastspring.tom.cart.core.svc;


import com.eastspring.tom.cart.core.CartCoreTestConfig;
import com.eastspring.tom.cart.core.CartException;
import com.eastspring.tom.cart.core.utl.FileDirUtil;
import org.junit.Assert;
import org.junit.Before;
import org.junit.Rule;
import org.junit.Test;
import org.junit.rules.ExpectedException;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.MockitoAnnotations;
import org.mockito.Spy;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import static org.mockito.Mockito.when;


public class RuntimeRemoteSvcTest {
    private static final Logger LOGGER = LoggerFactory.getLogger(RuntimeRemoteSvcTest.class);

    @Spy
    @InjectMocks
    private RuntimeRemoteSvc runtimeRemoteSvc;

    @Mock
    private FileDirUtil fileDirUtil;

    @Rule
    public ExpectedException thrown = ExpectedException.none();

    @Before
    public void initMocks() {
        MockitoAnnotations.initMocks(this);
        CartCoreTestConfig.configureLogging(RuntimeRemoteSvcTest.class);
    }

    @Test
    public void testGetOsNormalizedRuntimePath_nullCondition() {
        when(runtimeRemoteSvc.isWindowsRuntime()).thenReturn(false);
        Assert.assertNull(runtimeRemoteSvc.getOsNormalizedRuntimePath(""));
    }

    @Test
    public void testSshUpload_FileNotAvailableException() {
        when(fileDirUtil.fileDirExist("file_not_available.csv")).thenReturn(false);
        thrown.expect(CartException.class);
        thrown.expectMessage("File [file_not_available.csv] not available");
        runtimeRemoteSvc.sshUpload(RuntimeRemoteSvcIT.HOST_NAME, RuntimeRemoteSvcIT.HOST_PORT, RuntimeRemoteSvcIT.HOST_USER, "file_not_available.csv", "/home/jbossadm/automatedtest-dev");
    }

    @Test
    public void testSshUpload_SshException() {
        when(fileDirUtil.fileDirExist("file_available.csv")).thenReturn(true);
        thrown.expect(CartException.class);
        thrown.expectMessage(RuntimeRemoteSvc.ERROR_OPENING_SSH_CONNECTION);
        runtimeRemoteSvc.sshUpload(RuntimeRemoteSvcIT.HOST_NAME, RuntimeRemoteSvcIT.HOST_PORT, "dummy", "file_available.csv", "/home/jbossadm/automatedtest-dev");
    }

    @Test
    public void testSshDownload_Exception() {
        thrown.expect(CartException.class);
        thrown.expectMessage(RuntimeRemoteSvc.ERROR_OPENING_SSH_CONNECTION);
        runtimeRemoteSvc.sshDownload(RuntimeRemoteSvcIT.HOST_NAME, RuntimeRemoteSvcIT.HOST_PORT, RuntimeRemoteSvcIT.HOST_USER, "file_not_available.csv", "");
    }

    @Test
    public void testSshFileExists_Exception() {
        thrown.expect(CartException.class);
        thrown.expectMessage(RuntimeRemoteSvc.ERROR_OPENING_SSH_CONNECTION);
        runtimeRemoteSvc.sshFileExists(RuntimeRemoteSvcIT.HOST_NAME, 23, RuntimeRemoteSvcIT.HOST_USER, "/home/jbossadm/automatedtest-dev/file_not_available.csv");
    }

    @Test
    public void testSshFileExistsWithRegEx_Exception() {
        thrown.expect(CartException.class);
        thrown.expectMessage(RuntimeRemoteSvc.ERROR_OPENING_SSH_CONNECTION);
        runtimeRemoteSvc.sshFileExistsWithRegEx(RuntimeRemoteSvcIT.HOST_NAME, 22, "nouser", "/home/jbossadm/automatedtest-dev", "*.csv");
    }

}
