package com.eastspring.tom.cart.core.mdl;

import java.util.List;
import java.util.Set;

public class QtestFeatureRpt {
    private final String featureName;
    private final List<QtestRptScenario> scenarios;
    private final Set<String> tags;

    public QtestFeatureRpt(final String featureName, final List<QtestRptScenario> scenarios, final Set<String> tags) {
        this.featureName = featureName;
        this.scenarios = scenarios;
        this.tags = tags;
    }

    public String getFeatureName() {
        return featureName;
    }

    public List<QtestRptScenario> getScenarios() {
        return scenarios;
    }

    public Set<String> getTags() {
        return tags;
    }
}
