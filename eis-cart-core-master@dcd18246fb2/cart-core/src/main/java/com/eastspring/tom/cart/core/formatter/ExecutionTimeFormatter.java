package com.eastspring.tom.cart.core.formatter;

import cucumber.api.Result;
import cucumber.api.event.*;
import cucumber.api.formatter.NiceAppendable;
import gherkin.pickles.PickleTag;

import java.util.LinkedList;
import java.util.List;
import java.util.stream.Collectors;

public class ExecutionTimeFormatter implements ConcurrentEventListener {

    private static final int NANO_SECONDS = 1000000000;

    private NiceAppendable out;

    private List<ExecutionData> listOfExecutionData = new LinkedList<>();

    private ExecutionData data;

    public ExecutionTimeFormatter(Appendable out) {
        this.out = new NiceAppendable(out);
    }

    @Override
    public void setEventPublisher(EventPublisher publisher) {
        publisher.registerHandlerFor(TestCaseStarted.class, this::handleTestCaseStarted);
        publisher.registerHandlerFor(TestCaseFinished.class, this::handleTestCaseFinished);
        publisher.registerHandlerFor(TestRunFinished.class, this::generateJson);
    }

    private void generateJson(TestRunFinished event) {
        final String content = listOfExecutionData.stream()
                .map(ExecutionData::toString)
                .collect(Collectors.joining("\n"));
        out.append("FeaturePath/tScenario/tTags/tDuration(seconds)/tStatus/tErrorMessage\n");
        out.append(content);
        out.close();
    }
    private void handleTestCaseFinished(TestCaseFinished event) {
        final Result.Type status = event.result.getStatus();
        data.setDuration((double) event.result.getDuration() / NANO_SECONDS);

        data.setStatus(status.name());

        if (status.equals(Result.Type.FAILED)) {
            String errorMessage = event.result.getErrorMessage();
            data.setErrorMessage(errorMessage.substring(0, errorMessage.indexOf("at ") - 1).trim());
        }
        listOfExecutionData.add(data);
    }

    private void handleTestCaseStarted(TestCaseStarted event) {
        data = new ExecutionData();
        data.setFeature(event.testCase.getUri().replace("file:", ""));
        data.setScenario(event.testCase.getName());
        data.setTags(collectTags(event));
    }

    private String collectTags(TestCaseStarted event) {
        return event.testCase.getTags()
                .stream()
                .map(PickleTag::getName)
                .collect(Collectors.joining(" "));
    }

}
