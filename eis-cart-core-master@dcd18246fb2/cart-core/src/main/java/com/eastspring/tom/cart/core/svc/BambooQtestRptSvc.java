package com.eastspring.tom.cart.core.svc;

import com.eastspring.tom.cart.core.CartException;
import com.eastspring.tom.cart.core.CartExceptionType;
import com.eastspring.tom.cart.core.mdl.QtestFeatureRpt;
import com.eastspring.tom.cart.core.mdl.QtestRptScenario;
import com.eastspring.tom.cart.core.mdl.QtestRptStep;
import com.eastspring.tom.cart.core.utl.CukesTagUtil;
import com.eastspring.tom.cart.core.utl.FileDirUtil;
import com.fasterxml.jackson.databind.JsonNode;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.google.common.base.Strings;
import org.apache.commons.text.StringEscapeUtils;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;

import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.Paths;
import java.util.*;
import java.util.regex.Pattern;
import java.util.stream.Collectors;

/**
 * <p>This service class encapsulates functionalities around Bamboo - QTest Integration.</p>
 * <p>Bamboo is a continuous build/continuous integration/continuou deployment tool from Atlassian.</p>
 * <p>QTest is a Quality Assurance tool and portal from QASymphony.</p>
 */
public class BambooQtestRptSvc {

    private static final Logger LOGGER = LoggerFactory.getLogger(BambooQtestRptSvc.class);

    public static final String THE_OUTPUT_FILE_PARAMETER_MUST_NOT_BE_NULL_OR_EMPTY = "The [outputFile] parameter must not be null or empty";
    public static final String THE_JSON_REPORT_FILE_PARAMETER_MUST_NOT_BE_NULL_OR_EMPTY = "The [jsonReportFile] parameter must not be null or empty";
    public static final String ERROR_WHILE_PARSING_CUCUMBER_JSON_REPORT_FILE = "Error while parsing Cucumber JSON report file [{}]";
    public static final String PASSED = "passed";
    public static final String RESULT = "result";
    private static final String NAME = "name";
    public static final String STATUS = "status";
    public static final String JIRA_SPACES_MUST_NOT_BE_NULL_AND_MUST_NOT_CONTAIN_NULL_VALUE = "jiraSpaces must not be null, and must not contain null value";
    public static final String QTEST_JIRASPACES_CONFIGKEY = "qtest.jiraspaces";
    public static final String THE_QTEST_JIRASPACES_NEEDED = "The [qtest.jiraspaces] needs to be defined in tomcart-private.properties, example: qtest.jiraspaces=TOM,EISST";

    @Autowired
    private CukesTagUtil cukesTagUtil;

    @Autowired
    private FileDirUtil fileDirUtil;

    @Autowired
    private StateSvc stateSvc;

    /**
     * <p>This method takes a Cucumber JSON report file, converts it into Bamboo-QTest Integration consumable
     * formats.</p>
     *
     * @param jsonReportFile the fullpath of the JSON report file
     * @param outputFile     the fullpath of test XML output file
     */
    public void generateSurefireReport(String jsonReportFile, String outputFile) {
        if (Strings.isNullOrEmpty(jsonReportFile)) {
            LOGGER.error(THE_JSON_REPORT_FILE_PARAMETER_MUST_NOT_BE_NULL_OR_EMPTY);
            throw new CartException(CartExceptionType.INCOMPLETE_PARAMS, THE_JSON_REPORT_FILE_PARAMETER_MUST_NOT_BE_NULL_OR_EMPTY);
        }
        if (Strings.isNullOrEmpty(outputFile)) {
            LOGGER.error(THE_OUTPUT_FILE_PARAMETER_MUST_NOT_BE_NULL_OR_EMPTY);
            throw new CartException(CartExceptionType.INCOMPLETE_PARAMS, THE_OUTPUT_FILE_PARAMETER_MUST_NOT_BE_NULL_OR_EMPTY);
        }
        String jiraSpacesString = stateSvc.getStringVar(QTEST_JIRASPACES_CONFIGKEY);
        if (Strings.isNullOrEmpty(jiraSpacesString)) {
            LOGGER.error(THE_QTEST_JIRASPACES_NEEDED);
            throw new CartException(CartExceptionType.PROCESSING_FAILED, THE_QTEST_JIRASPACES_NEEDED);
        }
        LOGGER.info("Generating Bamboo-QTest Integration report...");
        LOGGER.debug("  jsonReportFile: [{}]", jsonReportFile);
        LOGGER.debug("  outputFile: [{}]", outputFile);

        Set<String> jiraSpaces = new TreeSet<>();
        for (String jiraSpace : jiraSpacesString.split(",")) {
            jiraSpaces.add(jiraSpace.toLowerCase());
        }

        fileDirUtil.forceMakeDirs(fileDirUtil.getDirnameFromPath(outputFile));
        QtestFeatureRpt qtestFeatureRpt = parseJsonIntoQtestFeatureRpt(jsonReportFile);
        fileDirUtil.writeStringToFile(outputFile, getXmlOutput(qtestFeatureRpt, jiraSpaces));
    }

    /**
     * <p>This method produces the Surefire XML report that will be consumed by Atlassian Bamboo, which in turn
     * will pass the data to the QTEST reports.</p>
     *
     * @param qtestFeatureRpt @{@link QtestFeatureRpt} object
     * @return the XML output (@{@link String}
     */
    public String getXmlOutput(QtestFeatureRpt qtestFeatureRpt, Set<String> jiraSpaces) {
        if (jiraSpaces == null) {
            LOGGER.error(JIRA_SPACES_MUST_NOT_BE_NULL_AND_MUST_NOT_CONTAIN_NULL_VALUE);
            throw new CartException(CartExceptionType.PROCESSING_FAILED, JIRA_SPACES_MUST_NOT_BE_NULL_AND_MUST_NOT_CONTAIN_NULL_VALUE);
        }
        String envName = stateSvc.getStringVar(StateSvc.CURRENT_ENV_NAME);
        StringBuilder sb = new StringBuilder();
        sb.append("<?xml version=\"1.0\" encoding=\"UTF-8\" ?>\n");
        sb.append(
                "<testsuite tests=\"3\" failures=\"0\" name=\"TEST-TOMR3_INTF_RIMES-001_infile\" time=\"0\" errors=\"0\" skipped=\"0\">\n");
        Set<String> featureTags = new HashSet<>();
        final Pattern pattern = cukesTagUtil.getJiraTicketTagPattern(jiraSpaces);
        if (qtestFeatureRpt.getTags() != null) {
            featureTags.addAll(qtestFeatureRpt.getTags());
        }
        for (QtestRptScenario scenario : qtestFeatureRpt.getScenarios()) {
            for (QtestRptStep step : scenario.getSteps()) {
                TreeSet<String> cascadedTags = new TreeSet<>();
                cascadedTags.addAll(featureTags);
                if (scenario.getTags() != null) {
                    cascadedTags.addAll(scenario.getTags());
                }
                String jiraTickets = Objects.toString(cascadedTags.stream()
                        .filter(x -> pattern.matcher(x).find())
                        .map(x -> cukesTagUtil.getJiraTicketFromTag(x, pattern))
                        .collect(Collectors.toList()));
                if (step.getStatus()) {
                    sb.append(String.format("  <testcase classname=\"[%s]%s %s\" name=\"%s\" time=\"0\"/>\n",
                            envName, jiraTickets, StringEscapeUtils.escapeXml10(scenario.getName()), StringEscapeUtils.escapeXml10(step.getName())));
                } else {
                    String errorMessage = step.getErrorMessage();
                    sb.append(String.format("  <testcase classname=\"[%s]%s %s\" name=\"%s\" time=\"0\"><error message=\"Attribute error message\" type=\"Error Type\">%s</error></testcase>\n",
                            envName, jiraTickets, StringEscapeUtils.escapeXml10(scenario.getName()), StringEscapeUtils.escapeXml10(step.getName()), StringEscapeUtils.escapeXml10(errorMessage)));
                }
            }
        }
        sb.append("</testsuite>\n");
        return sb.toString();
    }

    /**
     * <p>This method parses the report.json file to get the information needed to generate the surefire report file.</p>
     *
     * @param jsonReportFile the JSON report file
     * @return a @{@link QtestFeatureRpt} object representing the parsed JSON file
     */
    public QtestFeatureRpt parseJsonIntoQtestFeatureRpt(String jsonReportFile) {
        String featureName;
        QtestFeatureRpt result;
        ObjectMapper mapper = new ObjectMapper();
        try {
            JsonNode rootNode = mapper.readTree(Files.readAllBytes(Paths.get(jsonReportFile)));
            JsonNode featureNode = rootNode.path(0);
            featureName = featureNode.path(NAME).asText();
            Iterator<JsonNode> i = featureNode.path("elements").iterator();
            List<QtestRptScenario> scenarios = new ArrayList<>();
            while (i.hasNext()) {
                JsonNode elementsNode = i.next();
                String type = elementsNode.path("type").asText();
                if ("scenario".equals(type)) {
                    String name = elementsNode.path("name").asText();
                    Iterator<JsonNode> j = elementsNode.path("steps").iterator();
                    List<QtestRptStep> steps = new ArrayList<>();
                    while (j.hasNext()) {
                        JsonNode stepNode = j.next();
                        steps.add(new QtestRptStep(stepNode.path("name").asText(),
                                PASSED.equalsIgnoreCase(stepNode.path(RESULT).path(STATUS).asText()),
                                stepNode.path(RESULT).path("error_message").asText()));
                    }
                    scenarios.add(new QtestRptScenario(name, steps, extractTagNames(elementsNode)));
                }
            }
            result = new QtestFeatureRpt(featureName, scenarios, extractTagNames(featureNode));
        } catch (IOException e) {
            LOGGER.error(ERROR_WHILE_PARSING_CUCUMBER_JSON_REPORT_FILE, jsonReportFile, e);
            throw new CartException(CartExceptionType.INCOMPLETE_PARAMS, ERROR_WHILE_PARSING_CUCUMBER_JSON_REPORT_FILE, jsonReportFile);
        }

        return result;
    }

    private Set<String> extractTagNames(JsonNode hasTagsNode) {
        Iterator<JsonNode> k = hasTagsNode.path("tags").iterator();
        Set<String> tags = new TreeSet<>();
        while (k.hasNext()) {
            JsonNode tagNode = k.next();
            tags.add(tagNode.path("name").asText());
        }
        return tags;
    }
}
