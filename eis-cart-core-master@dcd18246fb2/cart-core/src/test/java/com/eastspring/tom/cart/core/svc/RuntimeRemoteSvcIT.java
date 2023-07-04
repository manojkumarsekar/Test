package com.eastspring.tom.cart.core.svc;

import com.eastspring.tom.cart.core.CartCoreTestConfig;
import com.eastspring.tom.cart.core.utl.FileDirUtil;
import com.eastspring.tom.cart.core.utl.WorkspaceUtil;
import com.google.common.base.Strings;
import org.junit.Assert;
import org.junit.BeforeClass;
import org.junit.Test;
import org.junit.runner.RunWith;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.test.context.ContextConfiguration;
import org.springframework.test.context.junit4.SpringJUnit4ClassRunner;

@RunWith(SpringJUnit4ClassRunner.class)
@ContextConfiguration(classes = {CartCoreSvcUtlTestConfig.class})
public class RuntimeRemoteSvcIT {

    public static final String HOST_NAME = "vsgeisluapp01";
    public static final int HOST_PORT = 22;
    public static final String HOST_USER = "tom_exec";

    @Autowired
    private RuntimeRemoteSvc runtimeRemoteSvc;

    @Autowired
    private WorkspaceUtil workspaceUtil;

    @Autowired
    private FileDirUtil fileDirUtil;

    @BeforeClass
    public static void initLogging() {
        if (System.getProperty("os.name").equalsIgnoreCase("LINUX")) {
            System.setProperty("tomcart.log4j.config", "file:/tomcart/tomrt-linux/cart/conf/log4j.xml");
            System.setProperty("tomcart.basedir", ".");
        }
        CartCoreTestConfig.configureLogging(RuntimeRemoteSvcIT.class);
    }

    @Test
    public void testGetRuntimeDir() {
        String result = runtimeRemoteSvc.getRuntimeDir();
        String osName = System.getProperty("os.name");

        if (osName.toLowerCase().startsWith("windows")) {
            Assert.assertEquals("c:/tomrt-win", result);
        } else {
            Assert.assertEquals("/opt/tomrt-linux", result);
        }
    }

    @Test
    public void testGetOsNormalizedRuntimePath() {
        String result = runtimeRemoteSvc.getOsNormalizedRuntimePath("/tools/pscp.exe");
        String osName = System.getProperty("os.name");

        if (osName.toLowerCase().startsWith("windows")) {
            Assert.assertEquals("c:\\tomrt-win\\tools\\pscp.exe", result);
        } else {
            Assert.assertEquals("\\opt\\tomrt-linux\\tools\\pscp.exe", result);
        }
    }

    @Test
    public void testSshDownload() {
        String testFileToUpload = fileDirUtil.getMavenTestResourcesPath("remote/upload/bbg_prices.out");
        String downloadDir = fileDirUtil.getMavenTestResourcesPath("remote");
        String remoteDir = "/home/jbossadm/automatedtest-dev";
        runtimeRemoteSvc.sshUpload(HOST_NAME, HOST_PORT, HOST_USER, testFileToUpload, remoteDir);
        runtimeRemoteSvc.sshDownload(HOST_NAME, HOST_PORT, HOST_USER, "/home/jbossadm/automatedtest-dev/bbg_prices.out", downloadDir + "/bbg_prices.out");
    }

    @Test
    public void testSshUpload() {
        String testDir = fileDirUtil.getMavenTestResourcesPath("remote/upload/bbg_prices.out");
        String remoteDir = "/home/jbossadm/automatedtest-dev";
        runtimeRemoteSvc.sshUpload(HOST_NAME, HOST_PORT, HOST_USER, testDir, remoteDir);
        runtimeRemoteSvc.sshRemoteExecute(HOST_NAME, HOST_PORT, HOST_USER, "rm " + remoteDir);
    }

    @Test
    public void testGetTimeStamp_withFormat() {
        String timeStamp = runtimeRemoteSvc.getTimeStamp("vsgeisluapp01", 22, "tom_exec", "%m-%d-%y");
        Assert.assertTrue(timeStamp.matches("\\d{2}-\\d{2}-\\d{2}"));
    }

    @Test
    public void testGetTimeStamp() {
        String timeStamp = runtimeRemoteSvc.getTimeStamp("vsgeisluapp01", 22, "tom_exec", null);
        Assert.assertFalse(Strings.isNullOrEmpty(timeStamp));
    }

    @Test
    public void testSshFileExists_fileExists() {
        String testdataDir = fileDirUtil.getMavenTestResourcesPath("remote/upload/bbg_prices.out");
        String remoteDestDir = "/home/jbossadm/automatedtest-dev";
        runtimeRemoteSvc.sshUpload(HOST_NAME, HOST_PORT, HOST_USER, testdataDir, remoteDestDir);
        Assert.assertTrue(runtimeRemoteSvc.sshFileExists(HOST_NAME, HOST_PORT, HOST_USER, remoteDestDir + "/bbg_prices.out"));
    }

    @Test
    public void testSshFileExists_fileNotExists() {
        String remoteDestDir = "/home/jbossadm/automatedtest-dev";
        Assert.assertTrue(!runtimeRemoteSvc.sshFileExists(HOST_NAME, HOST_PORT, HOST_USER, remoteDestDir + "/file_not_exists.csv"));
    }

    @Test
    public void testSshFileExistsWithRegEx_fileExists() {
        String testdataDir = fileDirUtil.getMavenTestResourcesPath("remote/upload/bbg_prices.out");
        String remoteDestDir = "/home/jbossadm/automatedtest-dev";
        runtimeRemoteSvc.sshUpload(HOST_NAME, HOST_PORT, HOST_USER, testdataDir, remoteDestDir);
        Assert.assertTrue(runtimeRemoteSvc.sshFileExistsWithRegEx(HOST_NAME, HOST_PORT, HOST_USER, remoteDestDir, "bbg*.out"));
    }

    @Test
    public void testSshFileExistsWithRegEx_fileNotExists() {
        String remoteDestDir = "/home/jbossadm/automatedtest-dev";
        Assert.assertTrue(!runtimeRemoteSvc.sshFileExistsWithRegEx(HOST_NAME, HOST_PORT, HOST_USER, remoteDestDir, "no_file*"));
    }
}
