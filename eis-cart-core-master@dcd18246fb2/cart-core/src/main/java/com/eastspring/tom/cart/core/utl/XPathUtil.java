package com.eastspring.tom.cart.core.utl;

import com.eastspring.tom.cart.core.CartException;
import com.eastspring.tom.cart.core.CartExceptionType;
import com.google.common.base.Strings;
import org.apache.xerces.dom.DeferredElementImpl;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.w3c.dom.Document;
import org.w3c.dom.Node;
import org.w3c.dom.NodeList;
import org.xml.sax.InputSource;

import javax.xml.parsers.DocumentBuilder;
import javax.xml.parsers.DocumentBuilderFactory;
import javax.xml.transform.OutputKeys;
import javax.xml.transform.Transformer;
import javax.xml.transform.TransformerException;
import javax.xml.transform.TransformerFactory;
import javax.xml.transform.dom.DOMSource;
import javax.xml.transform.stream.StreamResult;
import javax.xml.xpath.XPath;
import javax.xml.xpath.XPathConstants;
import javax.xml.xpath.XPathExpressionException;
import javax.xml.xpath.XPathFactory;
import java.io.StringReader;
import java.io.StringWriter;
import java.util.ArrayList;
import java.util.List;

public class XPathUtil {

    private static final Logger LOGGER = LoggerFactory.getLogger(XPathUtil.class);

    public static final String FAILED_ON_PARSING_XML_INVALID_XML = "failed on parsing XML (invalid XML [{}])";
    public static final String FAILED_ON_EXECUTING_XPATH_QUERY = "failed on executing xpath query [{}]";

    /**
     * This method extract @{@link String} values by performing XPath query on the given xmlString.
     *
     * @param xmlString
     * @param xpathQuery
     * @return
     */
    public List<String> extractByXPath(String xmlString, String xpathQuery) {
        XPathFactory xPathFactory = XPathFactory.newInstance();
        XPath xPath = xPathFactory.newXPath();
        InputSource document = new InputSource(new StringReader(xmlString));
        List<String> result = new ArrayList<>();
        try {
            Object rowsObj = xPath.evaluate(xpathQuery, document, XPathConstants.NODESET);
            NodeList rows = (NodeList) rowsObj;
            for (int i = 0; i < rows.getLength(); i++) {
                Node node = rows.item(i);
                result.add(node.getTextContent());
            }
        } catch (XPathExpressionException e) {
            LOGGER.error(FAILED_ON_PARSING_XML_INVALID_XML, xmlString, e);
            throw new CartException(CartExceptionType.PROCESSING_FAILED, FAILED_ON_PARSING_XML_INVALID_XML, xmlString);

        } catch (Exception e) {
            LOGGER.error(FAILED_ON_EXECUTING_XPATH_QUERY, xpathQuery, e);
            throw new CartException(CartExceptionType.PROCESSING_FAILED, FAILED_ON_EXECUTING_XPATH_QUERY, xpathQuery);
        }
        return result;
    }

    public List<String> extractByTagName(String xmlString, String tagName) {
        List<String> result = new ArrayList<>();
        try {
            InputSource is = new InputSource();
            is.setCharacterStream(new StringReader(xmlString));
            DocumentBuilderFactory dbf = DocumentBuilderFactory.newInstance();
            DocumentBuilder db = dbf.newDocumentBuilder();
            NodeList nodeList = db.parse(is).getElementsByTagName(tagName);
            for (int i = 0; i <= nodeList.getLength() - 1; i++) {
                result.add(nodeList.item(i).getFirstChild().getNodeValue());
            }
        } catch (Exception e) {
            LOGGER.error("failed to extract tag name", e);
            throw new CartException(CartExceptionType.PROCESSING_FAILED, "failed to extract tag name");
        }
        return result;
    }


    /**
     * Gets xml node by xpath
     *
     * @param xmlString  the xml string
     * @param xpathQuery the xpath query
     * @return the xml node
     */
    public Node getXMLNodeByXpath(final String xmlString, final String xpathQuery) {
        Node resultNode;
        try {
            InputSource is = new InputSource();
            is.setCharacterStream(new StringReader(xmlString));
            DocumentBuilderFactory dbf = DocumentBuilderFactory.newInstance();
            Document document = dbf.newDocumentBuilder().parse(is);

            XPath xPath = XPathFactory.newInstance().newXPath();
            resultNode = (Node) xPath.evaluate(xpathQuery, document, XPathConstants.NODE);
        } catch (Exception e) {
            LOGGER.error(FAILED_ON_PARSING_XML_INVALID_XML, xmlString, e);
            throw new CartException(CartExceptionType.PROCESSING_FAILED, FAILED_ON_PARSING_XML_INVALID_XML, xmlString);
        }

        if (resultNode == null) {
            LOGGER.error(FAILED_ON_EXECUTING_XPATH_QUERY, xpathQuery);
            throw new CartException(CartExceptionType.PROCESSING_FAILED, FAILED_ON_EXECUTING_XPATH_QUERY, xpathQuery);
        }
        return resultNode;
    }

    public String extractByNode(final Node node) {
        try {
            StringWriter buf = new StringWriter();
            Transformer transformer = TransformerFactory.newInstance().newTransformer();
            transformer.setOutputProperty(OutputKeys.OMIT_XML_DECLARATION, "yes");
            transformer.transform(new DOMSource(node), new StreamResult(buf));
            return buf.toString();
        } catch (TransformerException e) {
            LOGGER.error("Processing failed while parsing Node", e);
            throw new CartException(CartExceptionType.PROCESSING_FAILED, "Processing failed while parsing Node");
        }
    }

    public String getAttributeByNode(final Node node, final String attributeName) {
        try {
            if ((Strings.isNullOrEmpty(attributeName)) || (!node.hasAttributes())) {
                LOGGER.error("attributeName value might be null or Given xpath node not having any attributes");
                throw new CartException(CartExceptionType.IO_ERROR, "attributeName value might be null or Given xpath node not having any attributes");
            }
            return ((DeferredElementImpl) node).getAttribute(attributeName);
        } catch (Exception e) {
            LOGGER.error("Processing failed while parsing Node", e);
            throw new CartException(CartExceptionType.PROCESSING_FAILED, "Processing failed while parsing Node");
        }
    }


    public int getChildNodesCount(final String xmlString, final String xpathQuery, final String childNodeName) {
        int count = 0;
        try {
            final Node node = this.getXMLNodeByXpath(xmlString, xpathQuery);
            if (node.hasChildNodes()) {
                final NodeList childNodes = node.getChildNodes();
                for (int i = 0; i <= childNodes.getLength() - 1; i++) {
                    if (childNodeName.equals(childNodes.item(i).getNodeName())) {
                        count++;
                    }
                }
            }
        } catch (CartException e) {
            //ignore exception as any exception while execution should return count as 0
        }
        LOGGER.debug("{} Child nodes with name {} under parent node {}", count, childNodeName, xpathQuery);
        return count;
    }


}



