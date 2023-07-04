package com.eastspring.qa.cart.core.report;


import io.cucumber.plugin.ConcurrentEventListener;
import io.cucumber.plugin.event.*;
import org.apache.commons.io.FilenameUtils;
import org.apache.commons.lang3.StringUtils;

import java.net.URI;
import java.net.URLDecoder;


public class CucumberEventHandler implements ConcurrentEventListener {

    @Override
    public void setEventPublisher(EventPublisher publisher) {
        publisher.registerHandlerFor(TestRunStarted.class, testRunStarted -> {
        });
        publisher.registerHandlerFor(TestCaseStarted.class, testCaseStarted);

        publisher.registerHandlerFor(TestStepStarted.class, testStepStarted);
        publisher.registerHandlerFor(TestStepFinished.class, testStepEnded);

        publisher.registerHandlerFor(TestCaseFinished.class, testCaseEnded);
        publisher.registerHandlerFor(TestRunFinished.class, testRunEnded);
    }

    private EventHandler<TestCaseStarted> testCaseStarted = testCaseStarted -> {
        TestCase testCase = testCaseStarted.getTestCase();
        CartLogger.initTest(testCase.getName(), testCase.getTags());
    };

    private EventHandler<TestStepStarted> testStepStarted = testStepStarted -> {
        TestStep testStep = testStepStarted.getTestStep();
        if (testStep instanceof PickleStepTestStep) {
            CartLogger.debug("[StartStep]" + ((PickleStepTestStep) testStep).getStep().getText());
        }
    };

    private EventHandler<TestStepFinished> testStepEnded = testStepEnded -> {
        Result result = testStepEnded.getResult();
        TestStep testStep = testStepEnded.getTestStep();
        if (result.getError() != null) {
            CartLogger.error("[StepFailure]" + result.getError().getMessage());
        }
        if (testStep instanceof PickleStepTestStep) {
            CartLogger.debug("[EndOfStep]" + ((PickleStepTestStep) testStep).getStep().getText() + " : " + result.getStatus());
        }
        if (!result.getStatus().is(Status.PASSED) && !result.getStatus().is(Status.FAILED)) {
            return;
        }
        if (testStepEnded.getTestStep().getClass().toString().contains("HookTestStep")) {
            return;
        }
    };

    private EventHandler<TestCaseFinished> testCaseEnded = testCaseEnded -> {
        String exceptionInfo = "";
        Result result = testCaseEnded.getResult();
        try {
            if (result.getError() != null) {
                exceptionInfo = result.getError().getClass().getSimpleName()
                        + ":" + StringUtils.left(result.getError().getMessage().replace("\n", ""), 100);
            }
        } catch (Exception ignored) {
        }
        URI fileURI = testCaseEnded.getTestCase().getUri();

        CartLogger.teardownTest(FilenameUtils.getBaseName(URLDecoder.decode(fileURI.toString()))
                , testCaseEnded.getTestCase().getName()
                , testCaseEnded.getTestCase().getTags()
                , result.getStatus().toString()
                , exceptionInfo
                , result.getDuration()
        );
    };

    private EventHandler<TestRunFinished> testRunEnded = testRunFinished -> {
        CartLogger.generateReports();
        CartLogger.tearDown();
    };

}