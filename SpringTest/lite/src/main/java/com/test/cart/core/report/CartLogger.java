package com.eastspring.qa.cart.core.report;


import io.cucumber.java.Scenario;
import net.masterthought.cucumber.Configuration;
import net.masterthought.cucumber.ReportBuilder;
import org.apache.commons.io.FileUtils;
import com.eastspring.qa.cart.core.CartBootstrap;
import com.eastspring.qa.cart.core.configmanagers.RunConfigManager;
import com.eastspring.qa.cart.core.lookUps.AttachmentType;
import com.eastspring.qa.cart.core.lookUps.CartLogLevel;
import com.eastspring.qa.cart.core.lookUps.ScreenshotFormat;
import com.eastspring.qa.cart.core.lookUps.ScreenshotLevel;
import com.eastspring.qa.cart.core.services.web.WebDriverManagerSvc;
import com.eastspring.qa.cart.core.utils.core.WorkspaceUtil;
import org.openqa.selenium.OutputType;
import org.openqa.selenium.TakesScreenshot;
import org.openqa.selenium.WebDriver;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.slf4j.helpers.MessageFormatter;

import java.io.File;
import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.nio.file.StandardOpenOption;
import java.text.SimpleDateFormat;
import java.time.Duration;
import java.util.*;


public class CartLogger {

    private static final Logger LOGGER = LoggerFactory.getLogger("ReportLogger");
    private static final String CSV_SUMMARY = "executionSummary.csv";
    private static final String LOG_FILE = "executionLog.txt";

    private static final InheritableThreadLocal<Scenario> scenarioList = new InheritableThreadLocal<>();
    private static final InheritableThreadLocal<String> testIDs = new InheritableThreadLocal<>();
    private static final List<ExecutionSummary.DataSet> executionSummaryList = new ArrayList<>();

    public static void setScenario(Scenario scenario) {
        scenarioList.set(scenario);
    }

    protected static void forceLog(String message) {
        LOGGER.info(message);
        writeLogToFile(message, CartLogLevel.INFO, true);
    }

    public static void debug(String message) {
        LOGGER.debug(message);
        writeLogToFile(message, CartLogLevel.DEBUG);
    }

    public static void debug(String message, Object... args) {
        String formattedMessage = MessageFormatter.arrayFormat(message, args).getMessage();
        debug(formattedMessage);
    }

    public static void info(String message) {
        LOGGER.info(message);
        writeLogToFile(message, CartLogLevel.INFO);
        report(message);
    }

    public static void info(String message, Object... args) {
        String formattedMessage = MessageFormatter.arrayFormat(message, args).getMessage();
        info(formattedMessage);
    }

    public static void warn(String message) {
        LOGGER.warn(message);
        writeLogToFile(message, CartLogLevel.WARN);
        report(message);
    }

    public static void warn(String message, Object... args) {
        String formattedMessage = MessageFormatter.arrayFormat(message, args).getMessage();
        warn(formattedMessage);
    }

    public static void error(String message) {
        LOGGER.error(message);
        writeLogToFile(message, CartLogLevel.ERROR);
        report(message);
    }

    public static void error(String message, Object... args) {
        String formattedMessage = MessageFormatter.arrayFormat(message, args).getMessage();
        error(formattedMessage);
    }

    public static void error(String message, Throwable throwable, Object... args) {
        String formattedMessage = MessageFormatter.arrayFormat(message, args).getMessage();
        error(formattedMessage + ";Exception message:" + throwable.getMessage());
    }

    static void report(String message) {
        try {
            scenarioList.get().log(message);
        } catch (Exception ignored) {
        }
    }

    public static void generateReports() {
        final String targetDir = WorkspaceUtil.getExecutionReportsDir();
        File reportOutputDirectory = new File(Paths.get(targetDir, "/summary").toString());
        debug("Cucumber reports are generated in [{}]", reportOutputDirectory.getAbsolutePath());

        List<String> jsonFiles = new ArrayList<>();
        File directory = new File(targetDir);
        File[] files = directory.listFiles((file, name) -> name.endsWith(".json"));
        if (files != null && files.length > 0) {
            for (File f : files) {
                jsonFiles.add(targetDir + "/" + f.getName());
            }
        }

        Configuration configuration = new Configuration(reportOutputDirectory, RunConfigManager.PROJECT_NAME);
        configuration.setBuildNumber(RunConfigManager.BUILD_NUMBER);
        configuration.setTagsToExcludeFromChart("^@org.eis.cart.*", "^@eisst.*");
        configuration.addClassifications("Environment", RunConfigManager.ENV_NAME);
        configuration.addClassifications("Browser", RunConfigManager.Web.BROWSER.toString());
        ReportBuilder reportBuilder = new ReportBuilder(jsonFiles, configuration);
        reportBuilder.generateReports();
    }

    public static void initTest(String testName, List<String> testTags) {
        String testID = parseTestId(testTags);
        forceLog("[StartScenario]" + testName);
        testIDs.set(testID);
    }

    protected static void teardownTest(String suiteName, String testName,
                                       List<String> testTags, String status,
                                       String exceptionInfo, Duration executionTime) {
        storeTestSummary(suiteName, testName, testTags, status, exceptionInfo, executionTime);
        forceLog("[EndOfScenario]" + testName + " : " + status);
    }

    protected static void tearDownSuite() {
        ExecutionSummary.writeSummaryToCSV(
                Paths.get(WorkspaceUtil.getExecutionReportsDir(), CSV_SUMMARY),
                executionSummaryList
        );
    }

    protected static void tearDown() {
        ExecutionSummary.writeSummaryToCSV(
                Paths.get(WorkspaceUtil.getExecutionReportsDir(), CSV_SUMMARY),
                executionSummaryList
        );
    }

    public static void insertScreenshotToReport(byte[] file) {
        if (RunConfigManager.Report.SCREENSHOT_FORMAT.equals(ScreenshotFormat.PNG)) {
            insertFileToReport(file, AttachmentType.PNG);
        } else {
            insertScreenshotAsBase64ToReport(file);
        }
    }

    private static void insertScreenshotAsBase64ToReport(byte[] file) {
        String encodedString = Base64.getEncoder().encodeToString(file);
        scenarioList.get().attach(encodedString, "image/png", getUniqueTimeStamp());
    }

    public static void insertFileToReport(byte[] file, AttachmentType extension) {
        String fileName = getUniqueTimeStamp();
        insertFileToReport(file, fileName, extension);
    }

    public static void insertFileToReport(byte[] file, String fileName, AttachmentType extension) {
        Path filePath = Paths.get(WorkspaceUtil.getExecutionReportsDir(), fileName + "." + extension.toString());
        try {
            FileUtils.writeByteArrayToFile(new File(filePath.toString()), file);
            scenarioList.get().attach(file, extension.mimeType, fileName);
        } catch (IOException ioException) {
            debug(ioException.getMessage());
        }
    }

    private static void storeTestSummary(String suiteName, String testName,
                                         List<String> testTags, String status,
                                         String exceptionInfo, Duration executionTime) {
        ExecutionSummary.DataSet dataSet = new ExecutionSummary.DataSet();
        dataSet.testID = testIDs.get();
        dataSet.suiteName = suiteName;
        dataSet.testName = testName;
        dataSet.testTags = String.join(";", testTags);
        dataSet.status = status;
        dataSet.exceptionType = exceptionInfo;
        dataSet.executionTime = String.valueOf(executionTime.getSeconds());
        dataSet.executionTimeInMinutes = String.valueOf(executionTime.toMinutes());
        executionSummaryList.add(dataSet);
    }

    private static void writeLogToFile(String message, CartLogLevel level) {
        writeLogToFile(message, level, false);
    }

    private static void writeLogToFile(String message, CartLogLevel level, boolean isForced) {
        if (!isLogLevelInScope(level, isForced)) return;
        Path logFile = Paths.get(WorkspaceUtil.getExecutionReportsDir(), LOG_FILE);
        try {
            if (!Files.exists(logFile)) Files.createFile(logFile);
            Files.write(logFile,
                    ("[" + getUniqueTimeStamp() + "]["
                            + (isForced ? "CART_LOG" : level.toString())
                            + "]:" + message).getBytes(),
                    StandardOpenOption.APPEND);
            Files.write(logFile, System.lineSeparator().getBytes(), StandardOpenOption.APPEND);
        } catch (IOException e) {
            e.printStackTrace();
        }
    }

    private static String getUniqueTimeStamp() {
        int threadCount = RunConfigManager.THREAD_COUNT;
        return
                (threadCount > 1 ? "T_" + Thread.currentThread().getName() : "T_01")
                        + "_"
                        + new SimpleDateFormat("yyyyMMdd_hhmmssSS").format(new Date());
    }

    private static String parseTestId(List<String> testTags) {
        String identifier = RunConfigManager.Jira.JIRA_KEY;
        String jiraId = testTags.stream()
                .filter(tag -> tag.toUpperCase().contains(identifier.toUpperCase()))
                .findFirst()
                .orElseThrow(() -> new IllegalArgumentException(
                        "Failed to locate jiraID for scenario"
                ));
        return jiraId.replace("@", "");
    }

    protected static void autoInsertScreenshot(Boolean isScenarioFailed) {
        boolean alwaysScreenshot = RunConfigManager.Report.SCREENSHOT_LEVEL.equals(ScreenshotLevel.ALWAYS);
        boolean neverCaptureScreenshot = RunConfigManager.Report.SCREENSHOT_LEVEL.equals(ScreenshotLevel.NEVER);

        if (neverCaptureScreenshot || (!alwaysScreenshot && !isScenarioFailed)) return;
        WebDriverManagerSvc webDriverManagerSvc = (WebDriverManagerSvc) CartBootstrap.getBean(WebDriverManagerSvc.class);
        WebDriver webDriver = webDriverManagerSvc.getNullOrWebDriver();
        if (webDriver != null) {
            insertScreenshotToReport(
                    ((TakesScreenshot) webDriver).getScreenshotAs(OutputType.BYTES)
            );
        }
    }

    private static boolean isLogLevelInScope(CartLogLevel cartLogLevel, boolean isForced) {
        int scope = RunConfigManager.Report.CART_LOG_LEVEL.level;
        int input = cartLogLevel.level;
        return isForced || input >= scope;
    }
}