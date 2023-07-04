package com.eastspring.tom.cart.core.utl;

import com.eastspring.tom.cart.core.CartCoreTestConfig;
import org.junit.After;
import org.junit.Before;
import org.junit.BeforeClass;
import org.junit.Test;
import org.junit.runner.RunWith;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.test.context.ContextConfiguration;
import org.springframework.test.context.junit4.SpringJUnit4ClassRunner;

import static com.eastspring.tom.cart.core.utl.WorkspaceUtil.DEFAULT_BASE_DIR;
import static com.eastspring.tom.cart.core.utl.WorkspaceUtil.USER_DEFINED_FEATURE_DIR;
import static org.junit.Assert.assertEquals;

@RunWith(SpringJUnit4ClassRunner.class)
@ContextConfiguration(classes = {CartCoreUtlConfig.class})
public class WorkspaceUtilRunIT {

    @Autowired
    private WorkspaceUtil workspaceUtil;

    @BeforeClass
    public static void setUpClass() {
        CartCoreTestConfig.configureLogging(WorkspaceUtilRunIT.class);
    }

    private String osName;

    @Before
    public void setUp() {
        workspaceUtil.setBaseDir(DEFAULT_BASE_DIR);
    }

    @After
    public void tearDown() {
        System.setProperty("tomcart.relative.path", "");
        System.setProperty("tomcart.basedir", "");
    }

    @Test
    public void testGetBaseDir() {
        String baseDir = workspaceUtil.getBaseDir();
        String neutralizedBaseDir = ("" + baseDir.charAt(0)).toLowerCase() + baseDir.substring(1);
        assertEquals(DEFAULT_BASE_DIR, neutralizedBaseDir);
    }

    @Test
    public void testDefaultBaseDir() {
        System.setProperty("tomcart.relative.path", "false");
        System.setProperty("tomcart.basedir", "");
        WorkspaceUtil wu = new WorkspaceUtil();
        assertEquals(DEFAULT_BASE_DIR, wu.getBaseDir());
    }

    @Test
    public void testUserSpecifiedBaseDir() {
        System.setProperty("tomcart.relative.path", "false");
        System.setProperty("tomcart.basedir", "/tomcart/tomrt-linux");
        WorkspaceUtil wu = new WorkspaceUtil();
        assertEquals("/tomcart/tomrt-linux", wu.getBaseDir());
    }

    @Test
    public void testGetEnvDir() {
        String envDir = workspaceUtil.getEnvDir();
        String neutralizedEnvDir = ("" + envDir.charAt(0)).toLowerCase() + envDir.substring(1);
        assertEquals(DEFAULT_BASE_DIR + "/config", neutralizedEnvDir);
    }

    @Test
    public void testGetTestDataDir() {
        String testDataDir = workspaceUtil.getTestDataDir();
        String neutralizedTestDataDir = ("" + testDataDir.charAt(0)).toLowerCase() + testDataDir.substring(1);
        assertEquals(DEFAULT_BASE_DIR + "/tests/test-data", neutralizedTestDataDir);
    }

    @Test
    public void testGetTestEvidenceDir() {
        String testEvidenceDir = workspaceUtil.getTestEvidenceDir();
        String neutralizedTestEvidenceDir = ("" + testEvidenceDir.charAt(0)).toLowerCase() + testEvidenceDir.substring(1);
        assertEquals(DEFAULT_BASE_DIR + "/testout/evidence", neutralizedTestEvidenceDir);
    }

    @Test
    public void testGetFeaturesDir() {
        System.clearProperty(USER_DEFINED_FEATURE_DIR);
        String featuresDir = workspaceUtil.getFeaturesDir();
        String neutralizedFeaturesDir = ("" + featuresDir.charAt(0)).toLowerCase() + featuresDir.substring(1);
        assertEquals(DEFAULT_BASE_DIR + "/tests/features", neutralizedFeaturesDir);
    }

    @Test
    public void testGetFeaturesDir_userDefined() {
        System.setProperty(USER_DEFINED_FEATURE_DIR, "/features");
        String featuresDir = workspaceUtil.getFeaturesDir();
        String neutralizedFeaturesDir = ("" + featuresDir.charAt(0)).toLowerCase() + featuresDir.substring(1);
        assertEquals("/features", neutralizedFeaturesDir);
    }

    @Test
    public void testGetUserDownloadDir_windows() {
        String originalOs = System.getProperty("os.name");
        String originalUserHome = System.getProperty("user.home");
        System.setProperty("os.name", "windows");
        System.setProperty("user.home", "C:\\Users\\DummyUser1");
        try {
            assertEquals("C:\\Users\\DummyUser1\\Downloads", workspaceUtil.getUserDownloadDir());
        } finally {
            System.setProperty("os.name", originalOs);
            System.setProperty("user.home", originalUserHome);
        }
    }

    @Test
    public void testGetUserDownloadDir_linux() {
        String originalOs = System.getProperty("os.name");
        String originalUserHome = System.getProperty("user.home");
        System.setProperty("os.name", "linux");
        System.setProperty("user.home", "/home/user1");
        try {
            assertEquals("/home/user1/Downloads", workspaceUtil.getUserDownloadDir());
        } finally {
            System.setProperty("os.name", originalOs);
            System.setProperty("user.home", originalUserHome);
        }
    }
}
