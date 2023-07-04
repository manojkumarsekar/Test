package com.eastspring.tom.cart.core.svc;

import com.eastspring.tom.cart.core.CartException;
import com.eastspring.tom.cart.core.CartExceptionType;
import com.eastspring.tom.cart.core.statutl.Conditions;
import com.eastspring.tom.cart.core.utl.FileDirUtil;
import com.eastspring.tom.cart.core.utl.WorkspaceUtil;
import com.eastspring.tom.cart.core.utl.XPathUtil;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.w3c.dom.Node;

import java.util.List;
import java.util.Objects;

public class XmlSvc {

    private static final Logger LOGGER = LoggerFactory.getLogger(XmlSvc.class);

    @Autowired
    private FileDirUtil fileDirUtil;

    @Autowired
    private StateSvc stateSvc;

    @Autowired
    private WorkspaceUtil workspaceUtil;

    @Autowired
    private XPathUtil xPathUtil;

    @Autowired
    private WorkspaceDirSvc workspaceDirSvc;


    public List<String> extractValueFromXmlFileUsingXPath(final String xmlFile, final String xpathFile) {
        final String xmlString = fileDirUtil.readFileToString(workspaceDirSvc.normalize(xmlFile));
        final String xpathQuery = fileDirUtil.verifyFileExists(workspaceDirSvc.normalize(xpathFile)) ?
                stateSvc.expandVar(fileDirUtil.readFileToString(workspaceDirSvc.normalize(xpathFile))) :
                xpathFile;

        final List<String> result = xPathUtil.extractByXPath(xmlString, xpathQuery);
        LOGGER.debug("result: {}", Objects.toString(result));
        return result;
    }

    public int getElementCount(final String xmlFile, final String xpathFile) {
        return extractValueFromXmlFileUsingXPath(xmlFile, xpathFile).size();
    }

    public List<String> extractValueFromXmlFileUsingTagName(final String xmlFile, final String tagName) {
        final String xmlString = fileDirUtil.readFileToString(workspaceDirSvc.normalize(xmlFile));
        final List<String> result = xPathUtil.extractByTagName(xmlString, tagName);
        LOGGER.debug("result: {}", Objects.toString(result));
        return result;
    }

    public void extractSingleValueFromXmlFileUsingXPathToVar(final String xmlFile, final String xpathFile, final String varName, final Integer index) {
        final List<String> resultList = this.extractValueFromXmlFileUsingXPath(xmlFile, xpathFile);
        String singleResult = "";
        if (!Conditions.isNullOrEmpty(resultList)) {
            if (index > resultList.size() - 1) {
                LOGGER.error("Can't get index [{}] value as max index available in xml with given xpath is [{}]", index, resultList.size() - 1);
                throw new CartException(CartExceptionType.IO_ERROR, "Can't get index [{}] value as max index available in xml with given xpath is [{}]", index, resultList.size() - 1);
            }
            singleResult = resultList.get(index);
            stateSvc.setStringVar(varName, singleResult);
        }
        LOGGER.debug("content of variable {} = [{}]", varName, singleResult);
    }


    public void extractValueFromXmlUsingTagNameToVar(final String xmlFile, final String tagName, final String varName, final Integer index) {
        final List<String> resultList = this.extractValueFromXmlFileUsingTagName(xmlFile, tagName);
        String singleResult = "";
        if (!Conditions.isNullOrEmpty(resultList)) {
            if (index > resultList.size() - 1) {
                LOGGER.error("Can't get index [{}] value as max index available in xml with given Tag name is [{}]", index, resultList.size() - 1);
                throw new CartException(CartExceptionType.IO_ERROR, "Can't get index [{}] value as max index available in xml with given Tag name is [{}]", index, resultList.size() - 1);
            }
            singleResult = resultList.get(index);
            stateSvc.setStringVar(varName, singleResult);
        }
        LOGGER.debug("content of variable {} = [{}]", varName, singleResult);
    }

    public void extractAttributeValueFromXmlUsingXpathToVar(final String xmlFile, final String xpath, final String attributeName, final String varName) {
        String xmlFileFullpath = workspaceDirSvc.normalize(this.stateSvc.expandVar(xmlFile));
        String xmlString = this.fileDirUtil.readFileToString(xmlFileFullpath);
        Node node = xPathUtil.getXMLNodeByXpath(xmlString, xpath);
        stateSvc.setStringVar(varName, this.xPathUtil.getAttributeByNode(node, attributeName));
    }

    public void assignChildNodeCountToVariable(final String xmlFile, final String xpath, final String childNodeName, final String varName) {
        final String xmlFileFullPath = workspaceDirSvc.normalize(xmlFile);
        final String xmlString = this.fileDirUtil.readFileToString(xmlFileFullPath);
        stateSvc.setStringVar(varName, String.valueOf(xPathUtil.getChildNodesCount(xmlString, xpath, childNodeName)));
    }


}
