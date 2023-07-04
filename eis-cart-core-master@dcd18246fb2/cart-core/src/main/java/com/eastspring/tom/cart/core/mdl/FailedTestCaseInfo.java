package com.eastspring.tom.cart.core.mdl;

import java.util.List;
import java.util.stream.Collectors;

public class FailedTestCaseInfo {

    private String featurePath;
    private String scenarioName;
    private List<String> listOfTags;
    private String errorMessage;
    private String timeStamp;

    public FailedTestCaseInfo(String featurePath, String scenarioName, List<String> listOfTags, String errorMessage, String timeStamp) {
        this.featurePath = featurePath;
        this.scenarioName = scenarioName;
        this.listOfTags = listOfTags;
        this.errorMessage = errorMessage;
        this.timeStamp = timeStamp;
    }

    public String getFeaturePath() {
        return featurePath;
    }

    public String getScenarioName() {
        return scenarioName;
    }

    public String getErrorMessage() {
        return errorMessage;
    }

    public String getTimeStamp() {
        return timeStamp;
    }

    public String getConcatenatedTags() {
        return this.listOfTags.stream().collect(Collectors.joining(" and "));
    }

    @Override
    public String toString() {
        return "Feature: " + featurePath + "\n" +
                "Scenario: " + scenarioName + "\n" +
                "Tags: " + listOfTags + "\n" +
                "Failed at: " + timeStamp + "\n" +
                "Error Message: " + errorMessage;
    }
}
