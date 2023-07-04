package com.eastspring.tom.cart.core.utl;

import com.eastspring.tom.cart.core.CartCoreTestConfig;
import com.eastspring.tom.cart.core.CartException;
import com.eastspring.tom.cart.core.utl.pojo.Person;
import org.junit.Assert;
import org.junit.BeforeClass;
import org.junit.Rule;
import org.junit.Test;
import org.junit.rules.ExpectedException;
import org.junit.runner.RunWith;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.test.context.ContextConfiguration;
import org.springframework.test.context.junit4.SpringJUnit4ClassRunner;
import org.w3c.dom.Document;
import org.w3c.dom.NodeList;
import org.xml.sax.SAXException;

import javax.xml.parsers.ParserConfigurationException;
import javax.xml.transform.TransformerException;
import java.io.File;
import java.io.IOException;
import java.util.Arrays;
import java.util.Collections;
import java.util.List;

@RunWith( SpringJUnit4ClassRunner.class )
@ContextConfiguration( classes = {CartCoreUtlConfig.class} )
public class XmlUtilRunIT {

    @Autowired
    private XmlUtil xmlUtil;

    @Autowired
    private FileDirUtil fileDirUtil;


    @BeforeClass
    public static void setUpClass() {
        CartCoreTestConfig.configureLogging(XmlUtilRunIT.class);
    }

    @Rule
    public ExpectedException thrown = ExpectedException.none();

    @Test
    public void testPrettyPrint() throws Exception {
        String result = xmlUtil.prettyPrint("<?xml version=\"1.0\" ?><root><abc><def>a</def></abc><abc><def>b</def></abc></root>", false);
        System.out.println(result);
    }

    @Test
    public void testReadFromFile() {
        Person person = xmlUtil.readFromFile(new File("target/test-classes/xml/person.xml"), Person.class);
        Assert.assertEquals("TOM", person.getName());
        Assert.assertEquals(22, person.getAge());
    }

    @Test
    public void testReadFromString() {
        String content = fileDirUtil.readFileToString("target/test-classes/xml/person.xml");
        Person person = xmlUtil.readFromString(content, Person.class);
        Assert.assertEquals("TOM", person.getName());
        Assert.assertEquals(22, person.getAge());
    }

    @Test
    public void testAddElement_addNewElementTop() throws ParserConfigurationException, IOException, SAXException, TransformerException {
        final String file = "target/test-classes/xml/person.xml";
        final Document document = xmlUtil.insertNewElements(file, "NAME", "GENDER", Collections.singletonList("M"));

        Assert.assertEquals("GENDER", document.getFirstChild().getFirstChild().getNextSibling().getNodeName());
        Assert.assertEquals("M", document.getFirstChild().getFirstChild().getNextSibling().getTextContent());
    }

    @Test
    public void testAddElement_addNewArrayElements() throws ParserConfigurationException, IOException, SAXException, TransformerException {
        final String file = "target/test-classes/xml/person.xml";
        final List<String> list = Arrays.asList("uiuiuiuiuu", "23423423423", "dsfdfdfdfd");
        final Document document = xmlUtil.insertNewElements(file, "NAME", "GENDER", list);
        NodeList nodes = document.getElementsByTagName("GENDER");
        System.out.println(xmlUtil.prettyPrint(xmlUtil.transformDocToString(document), true));
        Assert.assertEquals(3, nodes.getLength());
    }

    @Test
    public void testAddElement_addNewArrayElementsExceptionHandling() throws ParserConfigurationException, IOException, SAXException, TransformerException {
        thrown.expect(CartException.class);
        thrown.expectMessage("Unable to find element with tag [NAMES]");
        final String file = "target/test-classes/xml/person.xml";
        final List<String> list = Arrays.asList("uiuiuiuiuu", "23423423423", "dsfdfdfdfd");
        xmlUtil.insertNewElements(file, "NAMES", "GENDER", list);
    }


    @Test
    public void testRemoveElementFromXmlByTag_withDefaultIndex() {
        String file = "target/test-classes/xml/TestUtils.xml";
        Document document = xmlUtil.removeElementByTag(file, "ADDRESS", 0);
        NodeList node = document.getElementsByTagName("ADDRESS");
        Assert.assertEquals(1, node.getLength());
        Assert.assertEquals("SENGKANG", node.item(0).getTextContent());
    }

    @Test
    public void testRemoveElementFromXmlByTag_withIndex() {
        String file = "target/test-classes/xml/TestUtils.xml";
        Document document = xmlUtil.removeElementByTag(file, "ADDRESS", 1);
        NodeList node = document.getElementsByTagName("ADDRESS");
        Assert.assertEquals(1, node.getLength());
        Assert.assertEquals("0102", node.item(0).getTextContent());
    }

    @Test
    public void testRemoveElementFromXmlByTag_invalidCustomIndex() {
        thrown.expect(CartException.class);
        thrown.expectMessage("Tag name [ADDRESS] with index [2] not available");
        String file = "target/test-classes/xml/TestUtils.xml";
        Document document = xmlUtil.removeElementByTag(file, "ADDRESS", 2);
        document.getElementsByTagName("ADDRESS");
    }

    @Test
    public void testRemoveElementFromXml_fileNotAvailable() {
        thrown.expect(CartException.class);
        thrown.expectMessage("Unable to get Document object from XML file");
        String file = "target/test-classes/xml/dummy.xml";
        xmlUtil.removeElementByTag(file, "DUMMY", 0);
    }

    @Test
    public void testRemoveElementFromXmlByXpath() {
        String file = "target/test-classes/xml/person.xml";
        Document document = xmlUtil.removeElementByXpath(file, "//PERSON/NAME");
        NodeList node = document.getElementsByTagName("NAME");
        Assert.assertEquals(0, node.getLength());
    }

    @Test
    public void testRemoveElementFromXml_XpathExceptionHandling() {
        thrown.expect(CartException.class);
        thrown.expectMessage("Unable to remove xml element by xpath");
        String file = "target/test-classes/xml/person.xml";
        xmlUtil.removeElementByXpath(file, "//PERSON/NAM");
    }

    @Test
    public void testTransformDocToFile() throws ParserConfigurationException, IOException, SAXException, TransformerException {
        final String file = "target/test-classes/xml/TestUtils.xml";
        final String transformedFile = "target/test-classes/xml/TestUtils_transformed.xml";
        Document document = xmlUtil.insertNewElements(file, "NAME", "GENDER", Collections.singletonList("M"));
        xmlUtil.transformDocToFile(document, transformedFile);
        fileDirUtil.verifyFileExists(transformedFile);
    }

    @Test
    public void testTransformDocToFile_Exception() {
        thrown.expect(CartException.class);
        thrown.expectMessage("Unable Transform Document to a file");
        final String file = "target/test-classes/TestUtils_transformed.xml";
        xmlUtil.transformDocToFile(null, file);
    }

}






