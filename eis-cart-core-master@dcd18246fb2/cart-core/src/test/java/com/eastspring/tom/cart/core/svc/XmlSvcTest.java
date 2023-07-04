package com.eastspring.tom.cart.core.svc;

import com.eastspring.tom.cart.core.CartCoreTestConfig;
import com.eastspring.tom.cart.core.CartException;
import com.eastspring.tom.cart.core.utl.FileDirUtil;
import com.eastspring.tom.cart.core.utl.WorkspaceUtil;
import com.eastspring.tom.cart.core.utl.XPathUtil;
import org.junit.Assert;
import org.junit.Before;
import org.junit.BeforeClass;
import org.junit.Rule;
import org.junit.Test;
import org.junit.rules.ExpectedException;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.MockitoAnnotations;

import java.util.ArrayList;
import java.util.Arrays;
import java.util.List;

import static org.mockito.Mockito.times;
import static org.mockito.Mockito.verify;
import static org.mockito.Mockito.when;

public class XmlSvcTest {

    private static final String XML_FILE_XML = "xml-file.xml";
    private static final String TESTXPATH_NODE = "//testxpath/node";

    @BeforeClass
    public static void setUpClass() {
        CartCoreTestConfig.configureLogging(XmlSvcTest.class);
    }

    @Before
    public void initMocks() {
        MockitoAnnotations.initMocks(this);
    }

    @InjectMocks
    private XmlSvc xmlSvc;

    @Rule
    public ExpectedException thrown = ExpectedException.none();

    @Mock
    private FileDirUtil fileDirUtil;

    @Mock
    private StateSvc stateSvc;

    @Mock
    private WorkspaceUtil workspaceUtil;

    @Mock
    private XPathUtil xPathUtil;

    @Mock
    private WorkspaceDirSvc workspaceDirSvc;

    @Test
    public void testExtractValueFromXmlFileUsingXPathFile() throws Exception {
        String xmlFile = XML_FILE_XML;
        String xpathFile = "xpath-file.file";
        String xmlString = "<?xml version=\"1.0\"?><abc><def>1</def><ghi>This is the XML</ghi></abc>";
        String xpathString = "/abc/ghi/text()";
        List<String> xpathResult = new ArrayList<>();
        xpathResult.add("This is the XML");

        when(workspaceDirSvc.normalize(xmlFile)).thenReturn(xmlFile);
        when(workspaceDirSvc.normalize(xpathFile)).thenReturn(xpathFile);

        when(fileDirUtil.readFileToString(xmlFile)).thenReturn(xmlString);
        when(fileDirUtil.verifyFileExists(xpathFile)).thenReturn(true);
        when(fileDirUtil.readFileToString(xpathFile)).thenReturn(xpathString);
        when(stateSvc.expandVar(xpathString)).thenReturn(xpathString);
        when(xPathUtil.extractByXPath(xmlString, xpathString)).thenReturn(xpathResult);

        List<String> result = xmlSvc.extractValueFromXmlFileUsingXPath(xmlFile, xpathFile);
        Assert.assertNotNull(result);
        Assert.assertEquals(1, result.size());
        Assert.assertEquals("This is the XML", result.get(0));
    }

    @Test
    public void testExtractValueFromXmlFileUsingXPathQuery() throws Exception {
        String xmlFile = XML_FILE_XML;
        String xpathFile = "xpath-file.file";
        String xmlString = "<?xml version=\"1.0\"?><abc><def>1</def><ghi>This is the XML</ghi></abc>";
        String xpathString = "/abc/ghi/text()";
        List<String> xpathResult = new ArrayList<>();
        xpathResult.add("This is the XML");

        when(workspaceDirSvc.normalize(xmlFile)).thenReturn(xmlFile);
        when(workspaceDirSvc.normalize(xpathFile)).thenReturn(xpathFile);

        when(fileDirUtil.readFileToString(xmlFile)).thenReturn(xmlString);
        when(fileDirUtil.verifyFileExists(xpathFile)).thenReturn(false);
        when(stateSvc.expandVar(xpathString)).thenReturn(xpathString);
        when(xPathUtil.extractByXPath(xmlString, xpathString)).thenReturn(xpathResult);

        List<String> result = xmlSvc.extractValueFromXmlFileUsingXPath(xmlFile, xpathString);
        Assert.assertNotNull(result);
        Assert.assertEquals(1, result.size());
        Assert.assertEquals("This is the XML", result.get(0));
    }

    @Test
    public void testExtractSingleValueFromXmlFileUsingXPathToVar_zeroIndex() throws Exception {
        String xmlFile = XML_FILE_XML;
        String xpathFile = "xpath-file.file";
        String varName = "this.is.my.var.name";
        List<String> xpathResult = new ArrayList<>();
        xpathResult.add("This is the XML");

        when(xmlSvc.extractValueFromXmlFileUsingXPath(xmlFile, xpathFile)).thenReturn(xpathResult);

        xmlSvc.extractSingleValueFromXmlFileUsingXPathToVar(xmlFile, xpathFile, varName, 0);
        verify(stateSvc, times(1)).setStringVar(varName, "This is the XML");
    }

    @Test
    public void testExtractSingleValueFromXmlFileUsingXPathToVar_nonzeroIndex() throws Exception {
        String xmlFile = XML_FILE_XML;
        String xpathFile = "xpath-file.file";
        String varName = "this.is.my.var.name";
        List<String> xpathResult = new ArrayList<>();
        xpathResult.add("This is the XML");
        xpathResult.add("index1 test");

        when(xmlSvc.extractValueFromXmlFileUsingXPath(xmlFile, xpathFile)).thenReturn(xpathResult);

        xmlSvc.extractSingleValueFromXmlFileUsingXPathToVar(xmlFile, xpathFile, varName, 1);
        verify(stateSvc, times(1)).setStringVar(varName, "index1 test");
    }

    @Test
    public void testExtractSingleValueFromXmlFileUsingXPathToVar_exception() {
        thrown.expect(CartException.class);
        thrown.expectMessage("value as max index available in xml with given xpath is");

        String xmlFile = XML_FILE_XML;
        String xpathString = "/abc/ghi/text()";
        String varName = "this.is.my.var.name";

        List<String> xpathResult = new ArrayList<>();
        xpathResult.add("This is the XML");

        when(xmlSvc.extractValueFromXmlFileUsingXPath(xmlFile, xpathString)).thenReturn(xpathResult);

        xmlSvc.extractSingleValueFromXmlFileUsingXPathToVar(xmlFile, xpathString, varName, 1);
        verify(stateSvc, times(0)).setStringVar(varName, "index1 test");
    }

    @Test
    public void testExtractValueFromXmlFileUsingTagName() {
        String xmlFile = XML_FILE_XML;
        String xmlString = "<?xml version=\"1.0\"?><abc><def>1</def><ghi>This is the XML</ghi></abc>";
        String tagName = "ghi";

        List<String> expectedResult = new ArrayList<>();
        expectedResult.add("This is the XML");

        when(workspaceDirSvc.normalize(xmlFile)).thenReturn(xmlFile);
        when(fileDirUtil.readFileToString(xmlFile)).thenReturn(xmlString);

        when(xPathUtil.extractByTagName(xmlString, tagName)).thenReturn(expectedResult);

        List<String> result = xmlSvc.extractValueFromXmlFileUsingTagName(xmlFile, tagName);
        Assert.assertEquals(expectedResult.size(), result.size());
        Assert.assertEquals(expectedResult.get(0), result.get(0));
    }

    @Test
    public void testExtractValueFromXmlUsingTagNameToVar() {
        String xmlFile = XML_FILE_XML;
        String xmlString = "<?xml version=\"1.0\"?><abc><def>1</def><ghi>This is the XML1</ghi><ghi>This is the XML2</ghi></abc>";
        String tagName = "ghi";
        String varName = "var.name";

        when(workspaceDirSvc.normalize(xmlFile)).thenReturn(xmlFile);
        when(fileDirUtil.readFileToString(xmlFile)).thenReturn(xmlString);

        List<String> expectedResult = new ArrayList<>();
        expectedResult.add("This is the XML1");
        expectedResult.add("This is the XML2");

        when(xPathUtil.extractByTagName(xmlString, tagName)).thenReturn(expectedResult);
        xmlSvc.extractValueFromXmlUsingTagNameToVar(xmlFile, tagName, varName, 0);
        verify(stateSvc, times(1)).setStringVar(varName, expectedResult.get(0));

        xmlSvc.extractValueFromXmlUsingTagNameToVar(xmlFile, tagName, varName, 1);
        verify(stateSvc, times(1)).setStringVar(varName, expectedResult.get(1));
    }

    @Test
    public void testExtractValueFromXmlUsingTagNameToVar_exception() {
        thrown.expect(CartException.class);
        thrown.expectMessage("value as max index available in xml with given Tag name is");

        String xmlFile = XML_FILE_XML;
        String xmlString = "<?xml version=\"1.0\"?><abc><def>1</def><ghi>This is the XML1</ghi><ghi>This is the XML2</ghi></abc>";
        String tagName = "ghi";
        String varName = "var.name";

        List<String> expectedResult = new ArrayList<>();
        expectedResult.add("This is the XML1");

        when(xmlSvc.extractValueFromXmlFileUsingTagName(xmlString, tagName)).thenReturn(expectedResult);
        xmlSvc.extractValueFromXmlUsingTagNameToVar(xmlFile, tagName, varName, 1);
        verify(stateSvc, times(0)).setStringVar(varName, expectedResult.get(1));
    }

    @Test
    public void testGetElementCount_elementExists() {
        when(xmlSvc.extractValueFromXmlFileUsingXPath(XML_FILE_XML, TESTXPATH_NODE)).thenReturn(Arrays.asList("tag1", "tag2"));
        final int elementCount = xmlSvc.getElementCount(XML_FILE_XML, TESTXPATH_NODE);
        Assert.assertEquals(2, elementCount);
    }

    @Test
    public void testGetElementCount_elementNotExists() {
        when(xmlSvc.extractValueFromXmlFileUsingXPath(XML_FILE_XML, TESTXPATH_NODE)).thenReturn(new ArrayList<>());
        final int elementCount = xmlSvc.getElementCount(XML_FILE_XML, TESTXPATH_NODE);
        Assert.assertEquals(0, elementCount);
    }
}
