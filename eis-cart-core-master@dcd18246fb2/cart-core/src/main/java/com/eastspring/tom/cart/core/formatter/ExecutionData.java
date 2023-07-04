package com.eastspring.tom.cart.core.formatter;

public class ExecutionData {

    private String feature;
    private String scenario;
    private String tags;
    private double duration;
    private String status;
    private String errorMessage;

    public void setFeature(String feature) {
        this.feature = feature;
    }

    public void setScenario(String scenario) {
        this.scenario = scenario;
    }

    public void setTags(String tags) {
        this.tags = tags;
    }

    public void setDuration(double duration) {
        this.duration = duration;
    }

    public void setStatus(String status) {
        this.status = status;
    }

    public void setErrorMessage(String errorMessage) {
        this.errorMessage = errorMessage;
    }

    @Override
    public String toString() {
        return feature + "/t"
                + scenario + "/t"
                + tags + "/t"
                + duration + "/t"
                + status + "/t"
                + "\"" + errorMessage + "\"";
    }

}
