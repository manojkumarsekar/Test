package com.eastspring.qa.cart.core.utils.core;

import com.eastspring.qa.cart.core.configmanagers.RunConfigManager;
import com.eastspring.qa.cart.core.exceptions.CartException;
import com.eastspring.qa.cart.core.exceptions.CartExceptionType;

import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.text.SimpleDateFormat;
import java.util.Date;

/**
 * This class encapsulates workspace utility functionalities.
 * TOMCART workspace has certain default layout with possible override.
 * This class encapsulates the functionality.
 */
public class WorkspaceUtil {

    private static final Path reportDir = Paths.get(getBaseDir(), "testout", "report");
    private static final Path executionReportDir = Paths.get(reportDir.toString(), "Execution-"
            + new SimpleDateFormat("yyyyMMdd_HHmmssSSS").format(new Date()));

    public static String getBaseDir() {
        return System.getProperty("user.dir");
    }

    public static String getResourceDir() {
        return getPathString(getBaseDir(), "src", "main", "resources");
    }

    public static String getTestDir() {
        return getPathString(getBaseDir(), "src", "test");
    }

    public static String getTestResourceDir() {
        return getPathString(getTestDir(), "resources");
    }

    public static String getTestConfigDir() {
        return getPathString(getTestResourceDir(), "config");
    }

    public static String getWebDriverDir() {
        return getPathString(getTestResourceDir(), "webdrivers");
    }

    public static String getRootTestDataDir() {
        return getPathString(getTestResourceDir(), "testdata");
    }

    public static String getTestDataDir() {
        String envName = RunConfigManager.ENV_NAME;
        return getTestDataDir(envName);
    }

    public static String getTestDataDir(String env) {
        return getPathString(getRootTestDataDir(), env);
    }

    public static String getCommonTestDataDir() {
        return getPathString(getRootTestDataDir(), "common");
    }

    public static String getFeaturesDir() {
        return getPathString(getTestDir(), "features");
    }

    public static String getReportsRootDir() {
        return reportDir.toString();
    }

    public static String getExecutionReportsDir() {
        return executionReportDir.toString();
    }

    protected static String getPathString(String first, String... params) {
        return getPath(first, params).toString();
    }

    protected static Path getPath(String first, String... params) {
        Path targetPath = Paths.get(first, params);
        if (!Files.exists(targetPath)) {
            throw new CartException(CartExceptionType.FILE_NOT_FOUND,
                    "Workspace folder [{}] is not found. Please set the mandatory folders as per framework guidelines",
                    targetPath.toString());
        }
        return targetPath;
    }
}