package com.eastspring.tom.cart.core.steps;

import com.eastspring.tom.cart.core.CartException;
import com.eastspring.tom.cart.core.CartExceptionType;
import com.eastspring.tom.cart.core.svc.StateSvc;
import com.eastspring.tom.cart.core.svc.XmlSvc;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;

import java.util.List;
import java.util.Map;

public class XmlValidationSteps {

    private static final Logger LOGGER = LoggerFactory.getLogger(XmlValidationSteps.class);

    public static final String XML_VERIFICATION_FAILED = "XML verification is failed, Actual Value is [{}] and Expected Value is [{}]";
    private static final String EXPECTED_ELEMENT_COUNT_BY_XPATH_IS_BUT_ACTUAL_COUNT_IS = "Expected Element Count by Xpath [{}] is [{}], but actual count is [{}]";

    @Autowired
    private StateSvc stateSvc;

    @Autowired
    private XmlSvc xmlSvc;


    public void assignChildNodesCountToVariable(final String xmlFile, final String parentXpath, final String childNode, final String varName) {
        String expandXmlFile = stateSvc.expandVar(xmlFile);
        String expandParentXpath = stateSvc.expandVar(parentXpath);
        String expandChildNodeName = stateSvc.expandVar(childNode);
        xmlSvc.assignChildNodeCountToVariable(expandXmlFile, expandParentXpath, expandChildNodeName, varName);
    }

    public void extractAttributeValueFromXmlUsingXpathToVar(String xmlFile, List<Map<String, String>> keyList) {
        String xpath, attributeName, varName;
        for (Map<String, String> row : keyList) {
            xpath = stateSvc.expandVar(row.get("xpath"));
            attributeName = stateSvc.expandVar(row.get(("attributeName")));
            varName = stateSvc.expandVar(row.get("variableName"));
            LOGGER.debug("Row Data - xpath query : " + xpath + " Attribute Name: " + attributeName + " Variable Name : " + varName);
            xmlSvc.extractAttributeValueFromXmlUsingXpathToVar(xmlFile, xpath, attributeName, varName);
        }
    }

    public void extractSingleValueFromXmlFileUsingXPathToVar(final String xmlFile, final String xpathFile, final String varName, final Integer index) {
        final String expandXmlFile = stateSvc.expandVar(xmlFile);
        final String expandXpathFile = stateSvc.expandVar(xpathFile);
        xmlSvc.extractSingleValueFromXmlFileUsingXPathToVar(expandXmlFile, expandXpathFile, varName, index);
    }

    public void verifyXpathValueInXml(final String xmlFile, final String xpath, final String expectedValue) {
        final String expandXmlFile = stateSvc.expandVar(xmlFile);
        final String expandXpath = stateSvc.expandVar(xpath);
        final String expandExpectedVal = stateSvc.expandVar(expectedValue);

        List<String> resultList = xmlSvc.extractValueFromXmlFileUsingXPath(expandXmlFile, expandXpath);

        String singleResult = "";
        if (resultList != null && !resultList.isEmpty()) {
            singleResult = resultList.get(0).trim();
        }
        if (!singleResult.equals(expandExpectedVal)) {
            LOGGER.error(XML_VERIFICATION_FAILED, singleResult, expectedValue);
            throw new CartException(CartExceptionType.VERIFICATION_FAILED, XML_VERIFICATION_FAILED, singleResult, expectedValue);
        }
    }

    public void extractValueFromXmlUsingTagNameToVar(final String xmlFile, final String tagName, final String varName, final Integer index) {
        final String expandXmlFile = stateSvc.expandVar(xmlFile);
        final String expandTagName = stateSvc.expandVar(tagName);
        xmlSvc.extractValueFromXmlUsingTagNameToVar(expandXmlFile, expandTagName, varName, index);
    }

    public void verifyTagValueInXml(final String xmlFile, final String tagName, final String expectedValue) {
        final String expandXmlFile = stateSvc.expandVar(xmlFile);
        final String expandTagName = stateSvc.expandVar(tagName);
        final String expandExpectedVal = stateSvc.expandVar(expectedValue);
        List<String> resultList = xmlSvc.extractValueFromXmlFileUsingTagName(expandXmlFile, expandTagName);

        String singleResult = "";
        if (resultList != null && !resultList.isEmpty()) {
            singleResult = resultList.get(0).trim();
        }
        if (!singleResult.equals(expandExpectedVal)) {
            LOGGER.error(XML_VERIFICATION_FAILED, singleResult, expandExpectedVal);
            throw new CartException(CartExceptionType.VERIFICATION_FAILED, XML_VERIFICATION_FAILED, singleResult, expandExpectedVal);
        }
    }

    public void extractValuesFromXmlFileUsingTagOrXpathToVar(final String xmlFile, final Integer index, final Map<String, String> keyValueMap) {
        final String expandXmlFile = stateSvc.expandVar(xmlFile);
        for (Map.Entry<String, String> entry : keyValueMap.entrySet()) {
            if (stateSvc.expandVar(entry.getKey()).substring(0, 1).equals("/")) {
                xmlSvc.extractSingleValueFromXmlFileUsingXPathToVar(expandXmlFile, stateSvc.expandVar(entry.getKey()), entry.getValue(), index);
            } else {
                xmlSvc.extractValueFromXmlUsingTagNameToVar(expandXmlFile, stateSvc.expandVar(entry.getKey()), entry.getValue(), index);
            }
        }
    }

    public void verifyXmlElementCountByXpath(final String xmlFile, final String xpath, final int expectedCount) {
        final String expandXmlFile = stateSvc.expandVar(xmlFile);
        final String expandXpath = stateSvc.expandVar(xpath);
        final int elementCount = xmlSvc.getElementCount(expandXmlFile, expandXpath);
        if (expectedCount != elementCount) {
            LOGGER.error(EXPECTED_ELEMENT_COUNT_BY_XPATH_IS_BUT_ACTUAL_COUNT_IS, expandXpath, expectedCount, elementCount);
            throw new CartException(CartExceptionType.VERIFICATION_FAILED, EXPECTED_ELEMENT_COUNT_BY_XPATH_IS_BUT_ACTUAL_COUNT_IS, expandXpath, expectedCount, elementCount);
        }
    }
}
