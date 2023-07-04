package com.eastspring.tom.cart.core.steps;

import com.eastspring.tom.cart.core.CartException;
import com.eastspring.tom.cart.core.CartExceptionType;
import com.eastspring.tom.cart.core.mdl.FailedTestCaseInfo;
import com.eastspring.tom.cart.core.svc.FileDirSvc;
import com.eastspring.tom.cart.core.svc.MsTeamsIntegrationSvc;
import com.eastspring.tom.cart.core.svc.StateSvc;
import com.eastspring.tom.cart.core.svc.WebTaskSvc;
import com.eastspring.tom.cart.core.utl.DateTimeUtil;
import com.eastspring.tom.cart.core.utl.FileDirUtil;
import com.eastspring.tom.cart.core.utl.ScenarioUtil;
import com.eastspring.tom.cart.core.utl.WorkspaceUtil;
import com.google.common.base.Strings;
import cucumber.api.Scenario;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;

import java.io.File;
import java.util.ArrayList;
import java.util.LinkedHashMap;

public class HooksSteps {

    private static final Logger LOGGER = LoggerFactory.getLogger(HooksSteps.class);

    private static final String SKIP_ALL_SCENARIOS_ERROR_MESSAGE = "Previous scenario [{}] in the same feature failed, Hence skipping remaining scenarios";
    private static final String TRUE = "true";

    LinkedHashMap<String, String> failuresMap = new LinkedHashMap<>();
    StringBuilder reRunnableTags = new StringBuilder();

    @Autowired
    private WebTaskSvc webTaskSvc;

    @Autowired
    private ScenarioUtil scenarioUtil;

    @Autowired
    private DateTimeUtil dateTimeUtil;

    @Autowired
    private FileDirSvc fileDirSvc;

    @Autowired
    private WorkspaceUtil workspaceUtil;

    @Autowired
    private FileDirUtil fileDirUtil;

    @Autowired
    private StateSvc stateSvc;

    @Autowired
    private MsTeamsIntegrationSvc msTeamsIntegrationSvc;

    private static final String SKIP_ALL_SCENARIOS_ON_FAILURE = "cucumber.skip.all.scenarios.onfailure";
    private static final String QUIT_ON_FAILURE = "QuitFeatureOnFailure";
    private static final String CURRENT_FEATURE = "FeatureFileName";
    private static final String LATEST_SCENARIO = "FailedScenario";

    public void setScenario(Scenario scenario) {
        scenarioUtil.setCurrentScenario(scenario);
        LOGGER.info("Execution started for [{}]:[{}]", scenarioUtil.getRawFeaturePath(), scenarioUtil.getScenarioName());
    }

    public void tearDownProcess() {
        LOGGER.info("Execution finished for [{}]:[{}]", scenarioUtil.getRawFeaturePath(), scenarioUtil.getScenarioName());
        if (scenarioUtil.isScenarioFailed()) {
            collectFailedTestInfo();
            sendTeamsNotification();
            if (amIExecutingWebScenario()) {
                webTaskSvc.takeScreenshotWithNamePrefix("OnFailure");
                LOGGER.info("Quitting WebDriver On Failure");
                webTaskSvc.quitWebDriver();
            }
        } else {
            if (amIExecutingWebScenario() && !(skipQuitDriverAtSuccess())) {
                LOGGER.info("Quitting WebDriver On Success");
                webTaskSvc.quitWebDriver();
            }
        }
    }


    private String getLatestErrorInfoFile() {
        return workspaceUtil.getReportsDir() + File.separator + "latest_error_info.log";
    }

    private void writeLatestFailureInfo(FailedTestCaseInfo info) {
        fileDirUtil.writeStringToFile(getLatestErrorInfoFile(), info.toString());
    }

    private void sendTeamsNotification() {
        final String flag = stateSvc.getStringVar("msteams.integration.enabled");
        final String msHook = stateSvc.getStringVar("msteams.webhook");

        if (!Strings.isNullOrEmpty(flag) && flag.equalsIgnoreCase(TRUE)) {
            LOGGER.debug("MS Teams Notification Integration enabled...");
            if (!Strings.isNullOrEmpty(msHook)) {
                msTeamsIntegrationSvc.sendNotification(msHook, getLatestErrorInfoFile());
            }
        }
    }

    public LinkedHashMap<String, String> getFailuresMap() {
        return failuresMap;
    }

    public String getReRunnableTags() {
        if (reRunnableTags.toString().endsWith("or" + " ")) {
            final int lastOrIndex = reRunnableTags.lastIndexOf("or");
            reRunnableTags.replace(lastOrIndex - 1, lastOrIndex + 2, "");
        }
        return reRunnableTags.toString();
    }

    private void collectFailedTestInfo() {
        final String feature = scenarioUtil.getFeaturePath();
        final String scenario = scenarioUtil.getScenarioName();
        final ArrayList<String> tagNames = scenarioUtil.getTagNames();
        final String errorMessage = scenarioUtil.getErrorMessage();
        final String timestamp = dateTimeUtil.getTimestamp("dd-MM-yyyy HH:mm:ss");

        scenarioUtil.write("Scenario failed at " + timestamp);

        LOGGER.debug("Failed feature -> [{}]", feature);
        LOGGER.debug("Failed scenario -> [{}]", scenario);
        LOGGER.debug("Failed Tags -> [{}]", tagNames.toString());
        LOGGER.debug("Failed Reason -> [{}]", errorMessage);

        final FailedTestCaseInfo info = new FailedTestCaseInfo(feature, scenario, tagNames, errorMessage, timestamp);
        writeLatestFailureInfo(info);
        collectFailedTestCases(info);
    }

    private boolean amIExecutingWebScenario() {
        return scenarioUtil.isTagPresent("@web");
    }

    private boolean skipQuitDriverAtSuccess() {
        return scenarioUtil.isTagPresent("@skip_driver_quit");
    }

    private void collectFailedTestCases(FailedTestCaseInfo failedTestCaseInfo) {
        if (isCollectFeaturesEnabled()) {
            collectFeatures(failedTestCaseInfo);
        } else {
            collectScenarios(failedTestCaseInfo);
        }
    }

    private void collectFeatures(FailedTestCaseInfo info) {
        final String featurePath = info.getFeaturePath();
        if (!failuresMap.containsKey(featurePath)) {
            final String tags = info.getConcatenatedTags();
            failuresMap.put(featurePath, tags);
            concatTagsWithOr(tags);
        }
    }

    private void collectScenarios(FailedTestCaseInfo info) {
        final String featurePath = info.getFeaturePath();
        final String scenarioName = info.getScenarioName();
        final String tags = info.getConcatenatedTags();
        failuresMap.put(featurePath + " -> " + scenarioName, tags);
        concatTagsWithOr(tags);
    }

    private void concatTagsWithOr(final String individualTags) {
        reRunnableTags.append(individualTags).append(" or ");
    }

    private boolean isCollectFeaturesEnabled() {
        final String var = stateSvc.getStringVar("collect.failures.for");
        return Strings.isNullOrEmpty(var) || "features".equalsIgnoreCase(var);
    }

    public void quitAllScenariosOnFailure() {
        if (isSkipAllScenariosOnFailureEnabled()) {
            final String failedFeature = stateSvc.getStringVar(CURRENT_FEATURE);
            final String quitOnFailure = stateSvc.getStringVar(QUIT_ON_FAILURE);

            if (quitOnFailure.equalsIgnoreCase(TRUE)
                    && failedFeature.equalsIgnoreCase(scenarioUtil.getFeaturePath())) {
                String scenarioName = stateSvc.getStringVar(LATEST_SCENARIO);
                LOGGER.error(SKIP_ALL_SCENARIOS_ERROR_MESSAGE, scenarioName);
                throw new CartException(CartExceptionType.UNDEFINED, SKIP_ALL_SCENARIOS_ERROR_MESSAGE, scenarioName);
            } else {
                stateSvc.setStringVar(CURRENT_FEATURE, "");
                stateSvc.setStringVar(QUIT_ON_FAILURE, "false");
                stateSvc.setStringVar(LATEST_SCENARIO, "");
            }
        }
    }

    public void setSkipScenariosFlagOnFailure() {
        if (scenarioUtil.isScenarioFailed() && isSkipAllScenariosOnFailureEnabled()) {
            stateSvc.setStringVar(CURRENT_FEATURE, scenarioUtil.getFeaturePath());
            stateSvc.setStringVar(QUIT_ON_FAILURE, TRUE);
            stateSvc.setStringVar(LATEST_SCENARIO, scenarioUtil.getScenarioName());
        }
    }

    private boolean isSkipAllScenariosOnFailureEnabled() {
        final String var = stateSvc.getStringVar(SKIP_ALL_SCENARIOS_ON_FAILURE);
        return !Strings.isNullOrEmpty(var) && var.equalsIgnoreCase(TRUE);
    }
}
