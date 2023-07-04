package com.eastspring.tom.cart.core.steps;

import com.eastspring.tom.cart.core.CartException;
import com.eastspring.tom.cart.core.CartExceptionType;
import com.eastspring.tom.cart.core.mdl.RegexVars;
import com.eastspring.tom.cart.core.svc.StateSvc;
import com.eastspring.tom.cart.core.svc.WorkspaceDirSvc;
import com.eastspring.tom.cart.core.utl.*;
import com.google.common.base.Strings;
import org.apache.commons.lang3.StringUtils;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;

import java.util.ArrayList;
import java.util.List;
import java.util.UUID;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

import static com.eastspring.tom.cart.core.svc.DataTableSvc.FILE_PREFIX;
import static com.eastspring.tom.cart.core.svc.StateSvc.VAR_INDICATOR;

public class ConfigSteps {
    private static final Logger LOGGER = LoggerFactory.getLogger(ConfigSteps.class);

    @Autowired
    private MathUtil mathUtil;

    @Autowired
    private StateSvc stateSvc;

    @Autowired
    private WorkspaceUtil workspaceUtil;

    @Autowired
    private DateTimeUtil dateTimeUtil;

    @Autowired
    private StringVerifyUtil stringVerifyUtil;

    @Autowired
    private FileDirUtil fileDirUtil;

    @Autowired
    private WorkspaceDirSvc workspaceDirSvc;

    @Autowired
    private ScenarioUtil scenarioUtil;

    @Autowired
    private JsonUtil jsonUtil;


    public void generateUuidAndStoreInVariable(String varName) {
        String uuid = UUID.randomUUID().toString();
        assignValueToVar(uuid, varName);
    }

    public void assignValueToVar(String value, String varName) {
        String expandedValue = stateSvc.expandVar(value);
        if (expandedValue.startsWith(FILE_PREFIX)) {
            expandedValue = fileDirUtil.readFileToString(workspaceDirSvc.normalize(expandedValue.replaceFirst(FILE_PREFIX, "").trim()));
        }
        stateSvc.setStringVar(varName, expandedValue);
    }

    public void assignFormattedDateToVar(String dateFormat, String varName) {
        if (Strings.isNullOrEmpty(dateFormat)) {
            LOGGER.error("dateFormat should be valid and is mandatory");
            throw new CartException(CartExceptionType.INCOMPLETE_PARAMS, "dateFormat should be valid and is mandatory");
        }
        String timestamp = dateTimeUtil.getTimestamp(dateFormat);
        stateSvc.setStringVar(varName, timestamp);
    }

    /**
     * <p> Give date can be updated with this function. Modifiers should be in the format of +2d - add 2 days to the given date
     * -2m i.e. deduct 2 months from the given date. similarly +1y which adds 1 year to the given date
     * </p>
     */
    public void modifyDateAndConvertFormat(String dateVar, String modifiers, String srcFormat, String destFormat, String outputVar) {
        if (dateVar.substring(VAR_INDICATOR.length(), dateVar.length() - 1).equals(outputVar)) {
            LOGGER.error("Cannot accept source [{}] and target [{}] variable with same name", dateVar, outputVar);
            throw new CartException(CartExceptionType.UNSATISFIED_IMPLICIT_ASSUMPTION, "Cannot accept source [{}] and target [{}] variable with same name", dateVar, outputVar);
        }
        final String expandedDateVar = stateSvc.expandVar(dateVar);
        final String updatedDate = dateTimeUtil.updateDateAndChangeFormat(expandedDateVar, modifiers, srcFormat, destFormat).toUpperCase();
        stateSvc.setStringVar(outputVar, updatedDate);
        LOGGER.debug("modifyDateAndConvertFormat: date {} modified to [{}]", expandedDateVar, updatedDate);
    }

    /**
     * Verify values equal.
     *
     * @param value1 the value 1
     * @param value2 the value 2
     */
    public void verifyValuesEqual(final String value1, final String value2) {
        final String expanded1 = stateSvc.expandVar(value1);
        final String expanded2 = stateSvc.expandVar(value2);
        final String expected = StringUtils.normalizeSpace(expanded1.contains("\\n\\r") ? expanded1.replace("\\n\\r", "") : expanded1);
        final String actual = StringUtils.normalizeSpace(expanded2.contains("\\n\\r") ? expanded2.replace("\\n\\r", "") : expanded2);
        stringVerifyUtil.match(expected, actual);
    }

    /**
     * Verify values equal.
     *
     * @param value1 the value 1
     * @param value2 the value 2
     */
    public void verifyValuesNotEqual(final String value1, final String value2) {
        final String expanded1 = stateSvc.expandVar(value1);
        final String expanded2 = stateSvc.expandVar(value2);
        final String expected = StringUtils.normalizeSpace(expanded1.contains("\\n\\r") ? expanded1.replace("\\n\\r", "") : expanded1);
        final String actual = StringUtils.normalizeSpace(expanded2.contains("\\n\\r") ? expanded2.replace("\\n\\r", "") : expanded2);
        stringVerifyUtil.notMatch(expected, actual);
    }


    /**
     * Evaluating user entered math function
     */
    public void computeMathExpAndAssignToVar(final String expression, final String resultVar) {
        if (Strings.isNullOrEmpty(expression)) {
            LOGGER.error("expression should be valid Math expression and is mandatory");
            throw new CartException(CartExceptionType.INCOMPLETE_PARAMS, "expression should be valid Math expression and is mandatory");
        }
        final String expressionExpanded = stateSvc.expandVar(expression);
        stateSvc.setStringVar(resultVar, mathUtil.computeExpression(expressionExpanded));
    }

    /**
     * Remove var.
     *
     * @param varName the var name
     */
    public void removeVar(final String varName) {
        final String expandVar = stateSvc.expandVar(varName);
        stateSvc.removeStringVar(expandVar);
    }


    /**
     * <p>Setting the environment context of the test to pick configuration from certain named environment,
     * which also tells the runtime to pick the environment configuration from a given environment properties
     * file.
     * </p>
     *
     * @param envName name of the named environment
     */
    public void useNamedEnvironment(String envName) {
        stateSvc.useNamedEnvironment(envName);
    }


    /**
     * Evaluate reg ex in target.
     * It basically verifies given value exist in the target string
     * in case we want to verify and capture values are the same time, we can use regex patterns.
     * Please check tests for this function on the usage.
     *
     * @param target         the target text or string
     * @param values         the values to be verified in target string
     * @param noOfOccurrence the index of occurrence
     */
    public void evaluateRegExInTarget(final String target, final List<String> values, final Integer noOfOccurrence) {
        final String expandTarget = stateSvc.expandVar(target);
        RegexVars regexVars;
        List<String> exceptions = new ArrayList<>();

        Pattern pattern;
        Matcher matcher;

        for (String value : values) {
            regexVars = stateSvc.expandToRegExGroups(stateSvc.expandVar(value));
            pattern = Pattern.compile(regexVars.getExpression(), Pattern.MULTILINE);
            matcher = pattern.matcher(expandTarget);
            int index = 1;//default occurrence
            boolean valueFound = false;

            while (matcher.find()) {
                int varsSize = regexVars.getVars().size();
                if (varsSize <= 0) {
                    valueFound = true;
                    break;
                } else {
                    if (noOfOccurrence == index) {
                        for (int i = 0; i <= varsSize - 1; i++) {
                            final String varName = regexVars.getVars().get(i);
                            final String val = matcher.group(i + 1).trim();
                            stateSvc.setStringVar(varName, val);
                            scenarioUtil.embed(("REGEX Captured " + varName + " -> " + val).getBytes(), "text/plain");
                            valueFound = true;
                        }
                        break;
                    }
                    index++;
                }
            }

            if (!valueFound) {
                exceptions.add(stateSvc.expandVar(value));
            }
        }

        if (exceptions.size() > 0) {
            LOGGER.error("Evaluation|verification failed for {} values at expected occurrence [{}]", exceptions, noOfOccurrence);
            throw new CartException(CartExceptionType.VERIFICATION_FAILED, "Evaluation|verification failed for {} values at expected occurrence [{}]", exceptions, noOfOccurrence);
        }
    }


    public void readJsonPathValueFromFile(final String jsonPath, final String jsonFilePath, final String outputVar) {
        final String expandJsonPath = stateSvc.expandVar(jsonPath);
        final String enrichedFilePath = workspaceDirSvc.normalize(jsonFilePath);
        final String jsonContent = fileDirUtil.readFileToString(enrichedFilePath);
        readJsonPathValueFromString(expandJsonPath, jsonContent, outputVar);
    }

    public void readJsonPathValueFromString(final String jsonPath, final String jsonContent, final String outputVar) {
        final String expandJsonPath = stateSvc.expandVar(jsonPath);
        final String expandJsonContent = stateSvc.expandVar(jsonContent);
        final String value = (String) jsonUtil.readObjectByJsonpath(expandJsonContent, expandJsonPath);
        stateSvc.setStringVar(outputVar, value);
    }

}
