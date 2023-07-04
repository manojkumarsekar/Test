package com.eastspring.tom.cart.core.utl;

import com.google.common.base.Strings;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import java.nio.file.Paths;

/**
 * This class encapsulates workspace utility functionalities.
 * TOMCART workspace has certain default layout with possible override.
 * This class encapsulates the functionality.
 */
public class WorkspaceUtil {

    private static final Logger LOGGER = LoggerFactory.getLogger(WorkspaceUtil.class);

    public static final String DEFAULT_BASE_DIR = "c:/tomwork/cart-tests";

    public static final String USER_DEFINED_FEATURE_DIR = "tomcart.featuresdir";

    private String baseDir;

    public WorkspaceUtil() {
        if ("true".equals(System.getProperty("tomcart.relative.path"))) {
            String absolutePath = Paths.get(".").toAbsolutePath().normalize().toString();
            baseDir = absolutePath.replaceAll("\\\\", "/");
        } else {
            baseDir = DEFAULT_BASE_DIR;
        }
        String userSpecifiedBaseDir = System.getProperty("tomcart.basedir");
        if (!Strings.isNullOrEmpty(userSpecifiedBaseDir)) {
            baseDir = userSpecifiedBaseDir;
        }
        LOGGER.debug("Basedir: [{}]", baseDir);
    }

    public void setBaseDir(String baseDir) {
        this.baseDir = baseDir;
    }

    public String getBaseDir() {
        return baseDir;
    }

    public String getEnvDir() {
        return baseDir + "/config";
    }

    public String getTestDataDir() {
        return baseDir + "/tests/test-data";
    }

    public String getTestEvidenceDir() {
        return baseDir + "/testout/evidence";
    }

    public String getFeaturesDir() {
        final String userDefinedFeaturesDir = System.getProperty(USER_DEFINED_FEATURE_DIR);
        if (!Strings.isNullOrEmpty(userDefinedFeaturesDir)) {
            LOGGER.debug("Fetching features from user defined directory [{}]", userDefinedFeaturesDir);
            return userDefinedFeaturesDir;
        }
        return baseDir + "/tests/features";
    }

    public String getReportsDir() {
        return baseDir + "/testout/report";
    }

    public String getUserDownloadDir() {
        String osName = System.getProperty("os.name");
        String userHome = System.getProperty("user.home");
        if ("windows".equalsIgnoreCase(osName)) {
            return userHome + "\\Downloads";
        } else {
            return userHome + "/Downloads";
        }
    }
}
