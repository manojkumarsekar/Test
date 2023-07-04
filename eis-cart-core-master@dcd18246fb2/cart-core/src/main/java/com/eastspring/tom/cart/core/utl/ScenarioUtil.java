package com.eastspring.tom.cart.core.utl;

import com.eastspring.tom.cart.core.CartException;
import com.eastspring.tom.cart.core.CartExceptionType;
import cucumber.api.Result;
import cucumber.api.Scenario;

import java.lang.reflect.Field;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.Map;
import java.util.Optional;
import java.util.stream.Stream;

public class ScenarioUtil {

    private static final String OR = "or";

    private InheritableThreadLocal<Scenario> scenario = new InheritableThreadLocal<>();

    private Map<String, String> failedFeaturesMap = new HashMap<>();
    private StringBuilder reRunnableTags = new StringBuilder();

    public Scenario getScenario() {
        return scenario.get();
    }


    @SuppressWarnings( "unchecked" )
    public String getErrorMessage() {
        final Field stepResults;
        try {
            stepResults = scenario.get().getClass().getDeclaredField("stepResults");
            stepResults.setAccessible(true);
            final Stream<Result> stream = ((ArrayList<Result>) stepResults.get(scenario.get())).stream();
            final Optional<String> failed = stream.filter(r -> r.getStatus().name().equals("FAILED"))
                    .map(Result::getErrorMessage)
                    .findFirst();
            return failed.get();
        } catch (NoSuchFieldException | IllegalAccessException e) {
            throw new CartException(CartExceptionType.INVALID_INVOCATION_PARAMS, "Exception", e.getMessage());
        }
    }

    public void setCurrentScenario(Scenario scenario) {
        this.scenario.set(scenario);
    }

    private String getRawFeature() {
        return scenario.get().getId().split(";")[0];
    }

    public String getRawFeaturePath() {
        final String featureName = "Feature ";
        return featureName + getRawFeature().substring(0, 1).toUpperCase() + getRawFeature().substring(1);
    }

    /**
     * It returns only the relative path of the current feature.
     */
    public String getFeaturePath() {
        return getRawFeature().split(":")[1];
    }


    public void write(final String data) {
        try {
            if (this.getScenario() != null) {
                this.getScenario().write(data);
            }
        } catch (Exception e) {
            //ignore
        }
    }

    public void embed(final byte[] bytes, final String var1) {
        if (this.getScenario() != null) {
            this.getScenario().embed(bytes, var1);
        }
    }

    public ArrayList<String> getTagNames() {
        if (this.getScenario() != null) {
            return (ArrayList<String>) this.getScenario().getSourceTagNames();
        }
        return new ArrayList<>();
    }

    public boolean isTagPresent(final String tag) {
        return getTagNames().contains(tag);
    }

    public boolean isScenarioFailed() {
        return this.getScenario() != null && this.getScenario().isFailed();
    }

    public String getScenarioName() {
        if (this.getScenario() != null) {
            return this.getScenario().getName();
        }
        return "";
    }
}
