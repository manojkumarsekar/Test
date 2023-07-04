package com.eastspring.qa.cart.core.runners;


import com.eastspring.qa.cart.context.CartCoreConfig;
import com.eastspring.qa.cart.core.CartBootstrap;
import com.eastspring.qa.cart.core.exceptions.CartException;
import com.eastspring.qa.cart.core.exceptions.CartExceptionType;
import com.eastspring.qa.cart.core.lookUps.ExecutionMode;
import com.eastspring.qa.cart.core.report.CartLogger;
import com.eastspring.qa.cart.core.utils.core.WorkspaceUtil;
import com.google.common.base.Strings;
import org.apache.commons.io.FileUtils;
import com.eastspring.qa.cart.core.configmanagers.RunConfigManager;

import java.io.File;
import java.io.IOException;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.util.*;


/**
 * <p>Main class where the execution starts. The method invokes some default parameters.</p>
 */
public class CucumberRunner {
    public static final String TRUE = "true";
    public static final String APPLY_CUSTOM_JSON = "cucumber.json.apply.custom.formatter";

    /**
     * @param mainArgs arguments for the main methods
     * @throws Throwable catch all throwable
     */
    public static void main(String... mainArgs) throws Throwable {
        init();
        springBootUp();
        List<String> cucumberOptions = getCucumberArgs(mainArgs);
        String[] resultType = new String[0];
        byte exitStatus = io.cucumber.core.cli.Main.run(cucumberOptions.toArray(resultType), Thread.currentThread().getContextClassLoader());
        tearDown();
        CartBootstrap.done();
        System.exit(exitStatus);
    }

    private static void init() {
        try {
            FileUtils.forceMkdir(new File(WorkspaceUtil.getExecutionReportsDir()));
        } catch (IOException e) {
            throw new CartException(e, CartExceptionType.IO_ERROR, "Failed to create execution report directory");
        }
        terminateWebDrivers();
        ExecutionMode execMode = RunConfigManager.EXECUTION_MODE; //Initialize RunConfigManager
    }

    private static void springBootUp() {
        try {
            CartBootstrap.setConfigClass(Class.forName("com.eastspring.qa.cart.context.CartExtendedConfig"));
        } catch (ClassNotFoundException | NoClassDefFoundError CFE) {
            CartBootstrap.setConfigClass(CartCoreConfig.class);
        }
        CartBootstrap.init();
    }

    private static List<String> getCucumberArgs(String... mainArgs) {
        String[] alwaysArgs = new String[]{
                "--monochrome"
        };

        // ToDo: assort features parameters in main and additional args;
        // use enhanced config managers once it is made available


        Path executionReportDir = Paths.get(WorkspaceUtil.getExecutionReportsDir());
        String relativeReportPath = Paths.get(WorkspaceUtil.getBaseDir())
                .relativize(executionReportDir)
                .toString()
                .replace("\\", "/");
        String[] additionalArgs = new String[]{
                getFeatureDir(),
                "--plugin", "pretty",
                "--plugin", "html:" + relativeReportPath + "/report.html",
                "--plugin", "junit:" + relativeReportPath + "/jUnitReport.xml",
                "--plugin", "json:" + relativeReportPath + "/report.json",
                "--plugin", "com.eastspring.qa.cart.core.report.CucumberEventHandler",
                "--glue", getGlue(),
                "--glue", "com.eastspring.qa.cart.core.report",
                "--threads", String.valueOf(RunConfigManager.THREAD_COUNT),
        };

        List<String> allArgsList = new ArrayList<>();
        allArgsList.addAll(Arrays.asList(alwaysArgs));
        allArgsList.addAll(Arrays.asList(mainArgs));
        allArgsList.addAll(Arrays.asList(additionalArgs));
        setCucumberFilterTags();
        CartLogger.debug("Main.main args: {}", Objects.toString(allArgsList));
        return allArgsList;
    }

    private static String getFeatureDir() {
        String defaultValue = WorkspaceUtil.getFeaturesDir();
        String customValue = System.getProperty("cucumber.features");
        customValue = (!Strings.isNullOrEmpty(customValue)) ? customValue :
                RunConfigManager.TestScope.FEATURES;
        return (!Strings.isNullOrEmpty(customValue)) ? customValue : defaultValue;
    }

    private static String getGlue() {
        String defaultValue = "stepdefinitions";
        String customValue = System.getProperty("cucumber.glue");
        customValue = (!Strings.isNullOrEmpty(customValue)) ? customValue :
                RunConfigManager.TestScope.GLUE;
        return (!Strings.isNullOrEmpty(customValue)) ? customValue : defaultValue;
    }

    private static void setCucumberFilterTags() {
        String sysPropFilters = System.getProperty("cucumber.filter.tags");
        String inputTags = RunConfigManager.TestScope.filterTags.equals("") ? "" : RunConfigManager.TestScope.filterTags;
        inputTags = sysPropFilters == null ? inputTags : sysPropFilters;
        String exclusionTags = "not (@noRun)";
        inputTags = inputTags.equals("") ? exclusionTags : "(" + inputTags + ") and " + exclusionTags;
        System.setProperty("cucumber.filter.tags", inputTags);
        RunConfigManager.TestScope.filterTags = inputTags;
    }

    protected static void tearDown() {
        terminateWebDrivers();
        // close db connections
    }

    private static void terminateWebDrivers() {
        if (System.getProperty("os.name").toUpperCase().contains("WINDOWS")) {
            try {
                Runtime.getRuntime().exec("taskKill /F /fi \"Imagename eq ChromeDriver*\"");
                Runtime.getRuntime().exec("taskKill /F /fi \"Imagename eq IEDriver*\"");
            } catch (IOException e) {
                e.printStackTrace();
            }
        }
    }
}