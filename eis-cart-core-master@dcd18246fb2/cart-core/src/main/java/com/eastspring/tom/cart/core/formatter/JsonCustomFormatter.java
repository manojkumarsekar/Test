package com.eastspring.tom.cart.core.formatter;

import com.eastspring.tom.cart.core.CartBootstrap;
import com.eastspring.tom.cart.core.svc.StateSvc;
import cucumber.api.*;
import cucumber.api.event.*;
import cucumber.api.formatter.NiceAppendable;
import gherkin.ast.Background;
import gherkin.ast.Feature;
import gherkin.ast.ScenarioDefinition;
import gherkin.ast.Step;
import gherkin.deps.com.google.gson.Gson;
import gherkin.deps.com.google.gson.GsonBuilder;
import gherkin.deps.net.iharder.Base64;
import gherkin.pickles.Argument;
import gherkin.pickles.*;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import java.text.SimpleDateFormat;
import java.util.*;

/*
Reference from cucumber.runtime.formatter and customized as per TOMCART
 */
public class JsonCustomFormatter implements ConcurrentEventListener {

    private static final Logger LOGGER = LoggerFactory.getLogger(JsonCustomFormatter.class);

    // Secrets or Passwords should not be expanded in html reports
    private static final String ALLOW_MASKING_SECRETS = "cucumber.json.allow.masking.secrets";

    private static final List<String> MASK_ARGUMENT_EXPANSION_KEYWORDS = Collections.singletonList(".pass");
    private static final String MASK = "*******";
    private static final String VAR_IDENTIFIER = "${";

    private String currentFeatureFile;
    private List<Map<String, Object>> featureMaps = new ArrayList<>();
    private List<Map<String, Object>> currentElementsList;
    private Map<String, Object> currentElementMap;
    private Map<String, Object> currentTestCaseMap;
    private List<Map<String, Object>> currentStepsList;
    private Map<String, Object> currentStepOrHookMap;
    private Map<String, Object> currentBeforeStepHookList = new HashMap<>();
    private final Gson gson = new GsonBuilder().setPrettyPrinting().create();
    private NiceAppendable out;
    private final TestSourcesCustomModel testSources = new TestSourcesCustomModel();

    private EventHandler<TestSourceRead> testSourceReadHandler = this::handleTestSourceRead;
    private EventHandler<TestCaseStarted> caseStartedHandler = this::handleTestCaseStarted;
    private EventHandler<TestStepStarted> stepStartedHandler = this::handleTestStepStarted;
    private EventHandler<TestStepFinished> stepFinishedHandler = this::handleTestStepFinished;
    private EventHandler<TestRunFinished> runFinishedHandler = event -> finishReport();
    private EventHandler<WriteEvent> writeEventhandler = this::handleWrite;
    private EventHandler<EmbedEvent> embedEventhandler = this::handleEmbed;

    private StateSvc stateSvc = (StateSvc) CartBootstrap.getBean(StateSvc.class);

    public JsonCustomFormatter() {
    }

    @SuppressWarnings("WeakerAccess") // Used by PluginFactory
    public JsonCustomFormatter(Appendable out) {
        this.out = new NiceAppendable(out);
    }

    @Override
    public void setEventPublisher(EventPublisher publisher) {
        publisher.registerHandlerFor(TestSourceRead.class, testSourceReadHandler);
        publisher.registerHandlerFor(TestCaseStarted.class, caseStartedHandler);
        publisher.registerHandlerFor(TestStepStarted.class, stepStartedHandler);
        publisher.registerHandlerFor(TestStepFinished.class, stepFinishedHandler);
        publisher.registerHandlerFor(WriteEvent.class, writeEventhandler);
        publisher.registerHandlerFor(EmbedEvent.class, embedEventhandler);
        publisher.registerHandlerFor(TestRunFinished.class, runFinishedHandler);
    }

    private boolean isArgumentToBeMasked(final String argument) {
        final String maskingFlag = stateSvc.getStringVar(ALLOW_MASKING_SECRETS);
        if (Objects.equals(maskingFlag, "") || "false".equalsIgnoreCase(maskingFlag)) {
            return false;
        }
        for (String keyword : MASK_ARGUMENT_EXPANSION_KEYWORDS) {
            if (argument.toLowerCase().contains(keyword)) {
                //LOGGER.debug("Masking [{}]", argument);
                return true;
            }
        }
        return false;
    }

    private String expandArgument(final String originalArgument) {
        if (isArgumentToBeMasked(originalArgument)) {
            //LOGGER.debug("Masking [{}] with [{}]", originalArgument, MASK);
            return MASK;
        }

        if (originalArgument.contains(VAR_IDENTIFIER)) {
            return stateSvc.expandVar(originalArgument);
        }
        final String variable = stateSvc.getStringVar(originalArgument);
        return !Objects.equals(variable, "") ? variable : originalArgument;
    }

    private String expandTestStep(String expression) {
        if (expression == null)
            return null;

        int varStart = expression.indexOf(VAR_IDENTIFIER);
        if (varStart >= 0) {
            String varName;
            String expanded = "";
            String temp;
            while (varStart >= 0) {
                int varEnd = expression.indexOf('}', varStart + 2);
                if (varEnd > varStart + 1) {
                    varName = expression.substring(varStart + VAR_IDENTIFIER.length(), varEnd);
                    temp = stateSvc.getStringVar(varName);
                    if(!"".equals(temp)){
                        temp = expandArgument(varName);
                    }
                    expanded = expression.substring(0, varStart) + temp + expression.substring(varEnd + 1);
                }
                expression = expanded;
                varStart = expanded.indexOf(VAR_IDENTIFIER);
            }
            return expanded;
        }
        return expression;
    }

    private void handleTestSourceRead(TestSourceRead event) {
        testSources.addTestSourceReadEvent(event.uri, event);
    }

    private void handleTestCaseStarted(TestCaseStarted event) {
        if (currentFeatureFile == null || !currentFeatureFile.equals(event.testCase.getUri())) {
            currentFeatureFile = event.testCase.getUri();
            Map<String, Object> currentFeatureMap = createFeatureMap(event.testCase);
            featureMaps.add(currentFeatureMap);
            currentElementsList = (List<Map<String, Object>>) currentFeatureMap.get("elements");
        }
        currentTestCaseMap = createTestCase(event);
        if (testSources.hasBackground(currentFeatureFile, event.testCase.getLine())) {
            currentElementMap = createBackground(event.testCase);
            currentElementsList.add(currentElementMap);
        } else {
            currentElementMap = currentTestCaseMap;
        }
        currentElementsList.add(currentTestCaseMap);
        currentStepsList = (List<Map<String, Object>>) currentElementMap.get("steps");
    }

    private void handleTestStepStarted(TestStepStarted event) {
        if (event.testStep instanceof PickleStepTestStep) {
            PickleStepTestStep testStep = (PickleStepTestStep) event.testStep;
            if (isFirstStepAfterBackground(testStep)) {
                currentElementMap = currentTestCaseMap;
                currentStepsList = (List<Map<String, Object>>) currentElementMap.get("steps");
            }
            currentStepOrHookMap = createTestStep(testStep);
            //add beforeSteps list to current step
            if (currentBeforeStepHookList.containsKey(HookType.Before.toString())) {
                currentStepOrHookMap.put(HookType.Before.toString(), currentBeforeStepHookList.get(HookType.Before.toString()));
                currentBeforeStepHookList.clear();
            }
            currentStepsList.add(currentStepOrHookMap);
        } else if (event.testStep instanceof HookTestStep) {
            HookTestStep hookTestStep = (HookTestStep) event.testStep;
            currentStepOrHookMap = createHookStep(hookTestStep);
            addHookStepToTestCaseMap(currentStepOrHookMap, hookTestStep.getHookType());
        } else {
            throw new IllegalStateException();
        }
    }

    private void handleWrite(WriteEvent event) {
        addOutputToHookMap(event.text);
    }

    private void handleEmbed(EmbedEvent event) {
        addEmbeddingToHookMap(event.data, event.mimeType);
    }

    private void handleTestStepFinished(TestStepFinished event) {
        currentStepOrHookMap.put("match", createMatchMap(event.testStep, event.result));
        currentStepOrHookMap.put("result", createResultMap(event.result));
    }

    private void finishReport() {
        out.append(gson.toJson(featureMaps));
        out.close();
    }

    private Map<String, Object> createFeatureMap(TestCase testCase) {
        Map<String, Object> featureMap = new HashMap<>();
        featureMap.put("uri", testCase.getUri());
        featureMap.put("elements", new ArrayList<Map<String, Object>>());
        Feature feature = testSources.getFeature(testCase.getUri());
        if (feature != null) {
            featureMap.put("keyword", feature.getKeyword());
            featureMap.put("name", feature.getName());
            featureMap.put("description", feature.getDescription() != null ? feature.getDescription() : "");
            featureMap.put("line", feature.getLocation().getLine());
            featureMap.put("id", TestSourcesCustomModel.convertToId(feature.getName()));
            featureMap.put("tags", feature.getTags());

        }
        return featureMap;
    }

    private Map<String, Object> createTestCase(TestCaseStarted event) {
        Map<String, Object> testCaseMap = new HashMap<>();

        testCaseMap.put("start_timestamp", getDateTimeFromTimeStamp(event.getTimeStamp()));

        TestCase testCase = event.getTestCase();

        testCaseMap.put("name", testCase.getName());
        testCaseMap.put("line", testCase.getLine());
        testCaseMap.put("type", "scenario");
        TestSourcesCustomModel.AstNode astNode = testSources.getAstNode(currentFeatureFile, testCase.getLine());
        if (astNode != null) {
            testCaseMap.put("id", TestSourcesCustomModel.calculateId(astNode));
            ScenarioDefinition scenarioDefinition = TestSourcesCustomModel.getScenarioDefinition(astNode);
            testCaseMap.put("keyword", scenarioDefinition.getKeyword());
            testCaseMap.put("description", scenarioDefinition.getDescription() != null ? scenarioDefinition.getDescription() : "");
        }
        testCaseMap.put("steps", new ArrayList<Map<String, Object>>());
        if (!testCase.getTags().isEmpty()) {
            List<Map<String, Object>> tagList = new ArrayList<>();
            for (PickleTag tag : testCase.getTags()) {
                Map<String, Object> tagMap = new HashMap<>();
                tagMap.put("name", tag.getName());
                tagList.add(tagMap);
            }
            testCaseMap.put("tags", tagList);
        }
        return testCaseMap;
    }

    private Map<String, Object> createBackground(TestCase testCase) {
        TestSourcesCustomModel.AstNode astNode = testSources.getAstNode(currentFeatureFile, testCase.getLine());
        if (astNode != null) {
            Background background = TestSourcesCustomModel.getBackgroundForTestCase(astNode);
            Map<String, Object> testCaseMap = new HashMap<>();
            testCaseMap.put("name", background.getName());
            testCaseMap.put("line", background.getLocation().getLine());
            testCaseMap.put("type", "background");
            testCaseMap.put("keyword", background.getKeyword());
            testCaseMap.put("description", background.getDescription() != null ? background.getDescription() : "");
            testCaseMap.put("steps", new ArrayList<Map<String, Object>>());
            return testCaseMap;
        }
        return null;
    }

    private boolean isFirstStepAfterBackground(PickleStepTestStep testStep) {
        TestSourcesCustomModel.AstNode astNode = testSources.getAstNode(currentFeatureFile, testStep.getStepLine());
        if (astNode != null) {
            return currentElementMap != currentTestCaseMap && !TestSourcesCustomModel.isBackgroundStep(astNode);
        }
        return false;
    }

    private Map<String, Object> createTestStep(PickleStepTestStep testStep) {
        Map<String, Object> stepMap = new HashMap<>();
        stepMap.put("name", expandTestStep(testStep.getStepText()));
        stepMap.put("line", testStep.getStepLine());
        TestSourcesCustomModel.AstNode astNode = testSources.getAstNode(currentFeatureFile, testStep.getStepLine());
        if (!testStep.getStepArgument().isEmpty()) {
            Argument argument = testStep.getStepArgument().get(0);
            if (argument instanceof PickleString) {
                stepMap.put("doc_string", createDocStringMap(argument));
            } else if (argument instanceof PickleTable) {
                stepMap.put("rows", createDataTableList(argument));
            }
        }
        if (astNode != null) {
            Step step = (Step) astNode.node;
            stepMap.put("keyword", step.getKeyword());
        }
        return stepMap;
    }

    private Map<String, Object> createDocStringMap(Argument argument) {
        Map<String, Object> docStringMap = new HashMap<>();
        PickleString docString = ((PickleString) argument);
        docStringMap.put("value", this.expandArgument(docString.getContent()));
        docStringMap.put("line", docString.getLocation().getLine());
        docStringMap.put("content_type", docString.getContentType());
        return docStringMap;
    }

    private List<Map<String, Object>> createDataTableList(Argument argument) {
        List<Map<String, Object>> rowList = new ArrayList<>();
        for (PickleRow row : ((PickleTable) argument).getRows()) {
            Map<String, Object> rowMap = new HashMap<>();
            rowMap.put("cells", createCellList(row));
            rowList.add(rowMap);
        }
        return rowList;
    }

    private List<String> createCellList(PickleRow row) {
        List<String> cells = new ArrayList<>();
        for (PickleCell cell : row.getCells()) {
            cells.add(this.expandArgument(cell.getValue()));
        }
        return cells;
    }

    private Map<String, Object> createHookStep(HookTestStep hookTestStep) {
        return new HashMap<>();
    }

    private void addHookStepToTestCaseMap(Map<String, Object> currentStepOrHookMap, HookType hookType) {
        String hookName;
        if (hookType.toString().contains("after"))
            hookName = "after";
        else
            hookName = "before";


        Map<String, Object> mapToAddTo;
        switch (hookType) {
            case Before:
                mapToAddTo = currentTestCaseMap;
                break;
            case After:
                mapToAddTo = currentTestCaseMap;
                break;
            case BeforeStep:
                mapToAddTo = currentBeforeStepHookList;
                break;
            case AfterStep:
                mapToAddTo = currentStepsList.get(currentStepsList.size() - 1);
                break;
            default:
                mapToAddTo = currentTestCaseMap;
        }

        if (!mapToAddTo.containsKey(hookName)) {
            mapToAddTo.put(hookName, new ArrayList<Map<String, Object>>());
        }
        ((List<Map<String, Object>>) mapToAddTo.get(hookName)).add(currentStepOrHookMap);
    }

    private void addOutputToHookMap(String text) {
        if (!currentStepOrHookMap.containsKey("output")) {
            currentStepOrHookMap.put("output", new ArrayList<String>());
        }
        ((List<String>) currentStepOrHookMap.get("output")).add(text);
    }

    private void addEmbeddingToHookMap(byte[] data, String mimeType) {
        if (!currentStepOrHookMap.containsKey("embeddings")) {
            currentStepOrHookMap.put("embeddings", new ArrayList<Map<String, Object>>());
        }
        Map<String, Object> embedMap = createEmbeddingMap(data, mimeType);
        ((List<Map<String, Object>>) currentStepOrHookMap.get("embeddings")).add(embedMap);
    }

    private Map<String, Object> createEmbeddingMap(byte[] data, String mimeType) {
        Map<String, Object> embedMap = new HashMap<>();
        embedMap.put("mime_type", mimeType);
        embedMap.put("data", Base64.encodeBytes(data));
        return embedMap;
    }

    private Map<String, Object> createMatchMap(TestStep step, Result result) {
        Map<String, Object> matchMap = new HashMap<>();
        if (step instanceof PickleStepTestStep) {
            PickleStepTestStep testStep = (PickleStepTestStep) step;
            if (!testStep.getDefinitionArgument().isEmpty()) {
                List<Map<String, Object>> argumentList = new ArrayList<>();

                int offsetAdjustment = 0;
                for (cucumber.api.Argument argument : testStep.getDefinitionArgument()) {
                    Map<String, Object> argumentMap = new HashMap<>();

                    CharSequence argumentActualValue = argument.getValue();
                    int argumentActualStart = argument.getStart();
                    String argumentMapValue;

                    if (argumentActualValue != null) {
                        if (((String) argumentActualValue).contains(VAR_IDENTIFIER)) {
                            if(offsetAdjustment != 0){
                                argumentActualStart -= offsetAdjustment;
                            }
                            final String argumentExpandValue = this.expandArgument(((String) argumentActualValue).replace("\"", ""));
                            offsetAdjustment = calculateOffsetAdjustment(offsetAdjustment, argumentActualValue, argumentExpandValue);
                            argumentMapValue = "\"" + argumentExpandValue + "\"";
                        } else {
                            argumentActualStart -= offsetAdjustment;
                            argumentMapValue = argumentActualValue.toString();
                        }

                        argumentMap.put("val", argumentMapValue);
                        argumentMap.put("offset", argumentActualStart);
                    }
                    argumentList.add(argumentMap);
                }
                matchMap.put("arguments", argumentList);
            }
        }
        if (!result.is(Result.Type.UNDEFINED)) {
            matchMap.put("location", step.getCodeLocation());
        }
        return matchMap;
    }


    //in case of expand value length is more actual value length, we need to add the adjustment from actualOffsetStart,
    //-2 is for truncating double quotes from actualValue (charsequence) length
    private int calculateOffsetAdjustment(int adjustment, CharSequence actualValue, String expandedValue) {
        adjustment += (actualValue.length() - 2) - expandedValue.length();
        return adjustment;
    }


    private Map<String, Object> createResultMap(Result result) {
        Map<String, Object> resultMap = new HashMap<>();
        resultMap.put("status", result.getStatus().lowerCaseName());
        if (result.getErrorMessage() != null) {
            resultMap.put("error_message", result.getErrorMessage());
        }
        if (result.getDuration() != 0) {
            resultMap.put("duration", result.getDuration());
        }
        return resultMap;
    }

    private String getDateTimeFromTimeStamp(long timeStampMillis) {
        SimpleDateFormat sdf = new SimpleDateFormat("yyyy-MM-dd'T'HH:mm:ss.SSSXXX");
        sdf.setTimeZone(TimeZone.getTimeZone("UTC"));

        return sdf.format(new Date(timeStampMillis));
    }
}
