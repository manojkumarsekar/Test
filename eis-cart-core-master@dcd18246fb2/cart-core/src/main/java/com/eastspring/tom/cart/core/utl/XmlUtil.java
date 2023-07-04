package com.eastspring.tom.cart.core.utl;

import com.eastspring.tom.cart.core.CartException;
import com.eastspring.tom.cart.core.CartExceptionType;
import com.fasterxml.jackson.dataformat.xml.XmlMapper;
import org.apache.commons.io.FileUtils;
import org.apache.xml.serialize.OutputFormat;
import org.apache.xml.serialize.XMLSerializer;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.w3c.dom.*;
import org.xml.sax.InputSource;
import org.xml.sax.SAXException;

import javax.xml.parsers.DocumentBuilder;
import javax.xml.parsers.DocumentBuilderFactory;
import javax.xml.parsers.ParserConfigurationException;
import javax.xml.transform.OutputKeys;
import javax.xml.transform.Transformer;
import javax.xml.transform.TransformerException;
import javax.xml.transform.TransformerFactory;
import javax.xml.transform.dom.DOMSource;
import javax.xml.transform.stream.StreamResult;
import javax.xml.xpath.XPathConstants;
import javax.xml.xpath.XPathExpression;
import javax.xml.xpath.XPathFactory;
import java.io.*;
import java.nio.charset.StandardCharsets;
import java.util.List;

public class XmlUtil {

    private static final Logger LOGGER = LoggerFactory.getLogger(XmlUtil.class);

    @Autowired
    private XmlMapper mapper;

    public <T> T readFromFile(final File file, final Class<T> objectClass) {
        try {
            return mapper.readValue(file, objectClass);
        } catch (IOException e) {
            LOGGER.error("IO Exception while parsing file [{}]", file, e);
            throw new CartException(CartExceptionType.IO_ERROR, "IO Exception while reading file [{}]", file);
        }
    }

    public <T> T readFromString(final String content, final Class<T> objectClass) {
        try {
            return mapper.readValue(content, objectClass);
        } catch (IOException e) {
            LOGGER.error("IO Exception while parsing content", e);
            throw new CartException(CartExceptionType.IO_ERROR, "IO Exception while reading content");
        }
    }

    /**
     * Add new element array document.
     *
     * @param xmlPath          the xml path
     * @param beforeEleTagName the before element after which new array of elements to be added
     * @param newEleTagName    the new element tag name
     * @param newEleValues     the new element values
     * @return the document
     */
    public Document insertNewElements(final String xmlPath, final String beforeEleTagName, final String newEleTagName, List<String> newEleValues) {
        File xmlFile = new File(xmlPath);

        final Document doc = getDocument(xmlFile);
        final NodeList beforeElements = doc.getElementsByTagName(beforeEleTagName);

        if (beforeElements.getLength() == 0) {
            LOGGER.error("Unable to find element with tag [{}]", beforeEleTagName);
            throw new CartException(CartExceptionType.PROCESSING_FAILED, "Unable to find element with tag [{}]", beforeEleTagName);
        }

        final Node beforeNode = beforeElements.item(0);
        final Node parentNode = beforeNode.getParentNode();

        Text text;
        Element element;
        for (String value : newEleValues) {
            text = doc.createTextNode(value);
            element = doc.createElement(newEleTagName);
            element.appendChild(text);
            parentNode.insertBefore(element, beforeNode);
        }
        return doc;
    }

    private Document getDocument(File xmlFile) {
        try {
            DocumentBuilderFactory docFactory = DocumentBuilderFactory.newInstance();
            docFactory.setIgnoringElementContentWhitespace(true);
            DocumentBuilder docBuilder = docFactory.newDocumentBuilder();
            return docBuilder.parse(xmlFile);
        } catch (ParserConfigurationException | SAXException | IOException e) {
            LOGGER.error("Unable to get Document object from XML file [{}]", e, xmlFile);
            throw new CartException(CartExceptionType.IO_ERROR, "Unable to get Document object from XML file [{}]", xmlFile);
        }
    }

    /**
     * Remove element by tag document.
     *
     * @param xmlPath the xml path
     * @param tagName the tag name
     * @param index   the index
     * @return the document
     */
    public Document removeElementByTag(String xmlPath, String tagName, Integer index) {
        File xmlFile = new File(xmlPath);
        Document doc = getDocument(xmlFile);
        final NodeList elements = doc.getElementsByTagName(tagName);
        if (elements.getLength() >= index + 1) {
            Node parent = elements.item(index).getParentNode();
            parent.removeChild(elements.item(index));
            parent.normalize();
            return doc;
        } else {
            LOGGER.error("Tag name [{}] with index [{}] not available", tagName, index);
            throw new CartException(CartExceptionType.PROCESSING_FAILED, "Tag name [{}] with index [{}] not available", tagName, index);
        }
    }

    /**
     * Remove element by xpath document.
     *
     * @param xmlPath the xml path
     * @param xpath   the xpath
     * @return the document
     */
    public Document removeElementByXpath(String xmlPath, String xpath) {
        File xmlFile = new File(xmlPath);
        try {
            Document doc = getDocument(xmlFile);
            XPathExpression expression = XPathFactory.newInstance().newXPath().compile(xpath);
            Node node = (Node) expression.evaluate(doc, XPathConstants.NODE);
            node.getParentNode().removeChild(node);
            return doc;
        } catch (Exception e) {
            LOGGER.error("Unable to remove xml element by xpath [{}]", xpath, e);
            throw new CartException(CartExceptionType.IO_ERROR, "Unable to remove xml element by xpath [{}]", xpath);
        }
    }

    public String transformDocToString(Document document) {
        try {
            Transformer transformer = TransformerFactory.newInstance().newTransformer();
            transformer.setOutputProperty(OutputKeys.INDENT, "yes");
            StreamResult result = new StreamResult(new StringWriter());
            DOMSource source = new DOMSource(document);
            transformer.transform(source, result);
            return result.getWriter().toString();
        } catch (TransformerException e) {
            LOGGER.error("Transformer Exception", e);
            throw new CartException(CartExceptionType.IO_ERROR, "Transformer Exception");
        }
    }

    public void transformDocToFile(Document document, String filePath) {
        try {
            final String xmlString = prettyPrint(transformDocToString(document), true);
            FileUtils.writeStringToFile(new File(filePath), xmlString, StandardCharsets.UTF_8);
        } catch (Exception e) {
            LOGGER.error("Unable Transform Document to a file [{}]", filePath, e);
            throw new CartException(CartExceptionType.IO_ERROR, "Unable Transform Document to a file [{}]", filePath);
        }
    }

    /**
     * <p>This method returns a pretty print version of the given source XML string.</p>
     */
    public String prettyPrint(String srcXmlString, boolean omitXmlDeclaration) {
        DocumentBuilderFactory factory = DocumentBuilderFactory.newInstance();

        String result;
        try {
            DocumentBuilder builder = factory.newDocumentBuilder();
            InputSource is = new InputSource(new StringReader(srcXmlString));
            Document document = builder.parse(is);
            OutputFormat format = new OutputFormat(document);
            format.setIndenting(true);
            format.setIndent(2);
            format.setOmitXMLDeclaration(omitXmlDeclaration);
            format.setLineWidth(Integer.MAX_VALUE);
            Writer outXml = new StringWriter();
            XMLSerializer serializer = new XMLSerializer(outXml, format);
            serializer.serialize(document);
            result = outXml.toString();
        } catch (SAXException e) {
            LOGGER.error("SAXException", e);
            throw new CartException(CartExceptionType.UNSATISFIED_IMPLICIT_ASSUMPTION, "SAXException");
        } catch (IOException e) {
            LOGGER.error("IOException", e);
            throw new CartException(CartExceptionType.IO_ERROR, "IOException");
        } catch (ParserConfigurationException e) {
            LOGGER.error("ParserConfigurationException", e);
            throw new CartException(CartExceptionType.IO_ERROR, "ParserConfigurationException");
        }
        return result;
    }


}

