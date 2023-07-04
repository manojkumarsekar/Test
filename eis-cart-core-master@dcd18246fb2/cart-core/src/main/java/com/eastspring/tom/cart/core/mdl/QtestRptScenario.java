package com.eastspring.tom.cart.core.mdl;

import java.util.List;
import java.util.Set;

public class QtestRptScenario {
    private final String name;
    private final List<QtestRptStep> steps;
    private final Set<String> tags;

    public QtestRptScenario(final String name, final List<QtestRptStep> steps, final Set<String> tags) {
        this.name = name;
        this.steps = steps;
        this.tags = tags;
    }

    public String getName() {
        return name;
    }

    public List<QtestRptStep> getSteps() {
        return steps;
    }

    public Set<String> getTags() {
        return tags;
    }
}
