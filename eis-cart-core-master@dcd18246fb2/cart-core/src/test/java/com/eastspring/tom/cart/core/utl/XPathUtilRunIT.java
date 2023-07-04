package com.eastspring.tom.cart.core.utl;

import com.eastspring.tom.cart.core.CartCoreTestConfig;
import com.eastspring.tom.cart.core.CartException;
import org.junit.Assert;
import org.junit.BeforeClass;
import org.junit.Rule;
import org.junit.Test;
import org.junit.rules.ExpectedException;
import org.junit.runner.RunWith;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.test.context.ContextConfiguration;
import org.springframework.test.context.junit4.SpringJUnit4ClassRunner;
import org.w3c.dom.Node;

import java.util.List;

@RunWith( SpringJUnit4ClassRunner.class )
@ContextConfiguration( classes = {CartCoreUtlConfig.class} )
public class XPathUtilRunIT {

    public static final String XML1 = "<?xml version=\"1.0\" ?><animals type=\"collection\"><dogs type=\"collection\"><dog>blacky</dog><dog>chewy</dog></dogs></animals>";
    public static final String XML2 = "<animalGroups><animalGroup><mamal>dolphin</mamal><mamal>narwhal</mamal></animalGroup><animalGroup><mamal>dog</mamal></animalGroup></animalGroups>";
    public static final String XML3 = "<SOAP-ENV:Envelope xmlns:SOAP-ENV=\"http://schemas.xmlsoap.org/soap/envelope/\"><SOAP-ENV:Header/><SOAP-ENV:Body><ProcessFilesDirectoryResult xmlns=\"http://www.thegoldensource.com/EventRaiserService.wsdl\"><flowResultId>++6SGKSmgZjzq001</flowResultId></ProcessFilesDirectoryResult></SOAP-ENV:Body></SOAP-ENV:Envelope>";

    @Autowired
    private XPathUtil xpathUtil;

    @Autowired
    private FileDirUtil fileDirUtil;

    @Rule
    public ExpectedException thrown = ExpectedException.none();

    @BeforeClass
    public static void setUpClass() {
        CartCoreTestConfig.configureLogging(XPathUtilRunIT.class);
    }

    @Test
    public void testExtractUsingXPathQuery_singleValue() throws Exception {
        List<String> result = xpathUtil.extractByXPath(XML1, "/animals/dogs/dog");
        Assert.assertNotNull(result);
        Assert.assertEquals(2, result.size());
        Assert.assertEquals("blacky", result.get(0));
        Assert.assertEquals("chewy", result.get(1));
    }

    @Test
    public void testExtractUsingXPathQuery_multiValue() throws Exception {
        List<String> result = xpathUtil.extractByXPath(XML2, "/animalGroups/animalGroup/mamal");
        Assert.assertNotNull(result);
        Assert.assertEquals(3, result.size());
        Assert.assertEquals("dolphin", result.get(0));
        Assert.assertEquals("narwhal", result.get(1));
        Assert.assertEquals("dog", result.get(2));
    }

    @Test
    public void testExtractUsingXPathQuery_notFound() throws Exception {
        List<String> result = xpathUtil.extractByXPath(XML2, "/animalGroops/animalGroup/mamal");
        Assert.assertNotNull(result);
        Assert.assertEquals(0, result.size());
    }

    @Test
    public void testExtractUsingXPathQuery_dmpWorkflowSoapRequest1() throws Exception {
        List<String> result = xpathUtil.extractByXPath(XML3, "/*[local-name() = 'Envelope']/*[local-name() = 'Body']/*[local-name() = 'ProcessFilesDirectoryResult']/*[local-name() = 'flowResultId']");
        Assert.assertNotNull(result);
        Assert.assertEquals(1, result.size());
        Assert.assertEquals("++6SGKSmgZjzq001", result.get(0));
    }

    @Test
    public void testExtractUsingXPathQuery_neg_emptyXml() throws Exception {
        thrown.expect(CartException.class);
        thrown.expectMessage("failed on parsing XML (invalid XML [])");
        List<String> result = xpathUtil.extractByXPath("", "/animalGroups/animalGroup/mamal");
        Assert.assertNotNull(result);
        Assert.assertEquals(0, result.size());
    }

    @Test
    public void testExtractUsingXPathQuery_neg_headerOnlyXml() throws Exception {
        thrown.expect(CartException.class);
        thrown.expectMessage("failed on parsing XML (invalid XML [<?xml version=\"1.0\" ?>])");
        List<String> result = xpathUtil.extractByXPath("<?xml version=\"1.0\" ?>", "/animalGroups/animalGroup/mamal");
        Assert.assertNotNull(result);
        Assert.assertEquals(0, result.size());
    }

    @Test
    public void testExtractUsingXPathQuery_neg_deformedXml() throws Exception {
        thrown.expect(CartException.class);
        thrown.expectMessage("failed on parsing XML (invalid XML [<?xml version=\"1.0\" ?><abc></def>])");
        List<String> result = xpathUtil.extractByXPath("<?xml version=\"1.0\" ?><abc></def>", "/animalGroups/animalGroup/mamal");
        Assert.assertNotNull(result);
        Assert.assertEquals(0, result.size());
    }

    @Test
    public void testExtractByXPath() {
        String content = fileDirUtil.readFileToString("target/test-classes/ws/TC_05_LOANXID.xml");
        List<String> list = xpathUtil.extractByXPath(content, "//CUSIP2_set//CODE[text()='8']/../IDENTIFIER");
        Assert.assertNotNull(list.get(0));
        Assert.assertNotNull(list.get(1));
    }

    @Test
    public void testExtractByTagName() {
        List<String> result = xpathUtil.extractByTagName(XML2, "mamal");
        Assert.assertEquals(3, result.size());
        Assert.assertEquals("dolphin", result.get(0));
        Assert.assertEquals("narwhal", result.get(1));
        Assert.assertEquals("dog", result.get(2));
    }

    @Test
    public void testExtractByTagName_TagName_DoesntMatch() {
        List<String> result = xpathUtil.extractByTagName(XML2, "birds");
        Assert.assertEquals(0, result.size());
    }

    @Test
    public void testExtractByTagName_ExceptionCheck() {
        thrown.expect(CartException.class);
        thrown.expectMessage("failed to extract tag name");
        List<String> result = xpathUtil.extractByTagName("<?xml version=\"1.0\" ?><abc></def>", "birds");
        Assert.assertNotNull(result);
        Assert.assertEquals(0, result.size());
    }

    @Test
    public void testGetXMLNodeByXpath() {
        Node result = xpathUtil.getXMLNodeByXpath(XML2, "/animalGroups/animalGroup/mamal");
        Assert.assertNotNull(result);
        Assert.assertEquals("animalGroup", result.getParentNode().getNodeName());
        Assert.assertNull(result.getNodeValue());
        Assert.assertEquals("mamal", result.getNodeName());
        Assert.assertEquals("dolphin", result.getTextContent());
    }

    @Test
    public void testGetXMLNodeByXpath_BlankXml() {
        thrown.expect(CartException.class);
        thrown.expectMessage("failed on parsing XML (invalid XML [])");
        xpathUtil.getXMLNodeByXpath("", "/animalGroups/animalGroup/mamal");
    }

    @Test
    public void testGetXMLNodeByXpath_invalidXpath() {
        String xpath = "/animalGroups/animalGroup/ma";
        thrown.expect(CartException.class);
        thrown.expectMessage("failed on executing xpath query [/animalGroups/animalGroup/ma]");
        xpathUtil.getXMLNodeByXpath(XML2, xpath);
    }

    @Test
    public void testExtractByNode() {
        String xmlData = fileDirUtil.readFileToString("target/test-classes/xml/transaction.xml");
        Node node = xpathUtil.getXMLNodeByXpath(xmlData, "//ID1[text()='EQ_214211']//ancestor::TRADE");
        String extract = xpathUtil.extractByNode(node);
        Assert.assertEquals(xpathUtil.extractByTagName(extract, "ID1").get(0), "EQ_214211");
    }

    @Test
    public void testGetAttributeByXpath() {
        String xmlData = fileDirUtil.readFileToString("target/test-classes/xml/with_attributes.xml");
        Node node = xpathUtil.getXMLNodeByXpath(xmlData, "//Portfolio[@PortfolioId='GLEM1']/Asset");
        Assert.assertEquals(xpathUtil.getAttributeByNode(node, "AssetName"), "ICICI BANK ADR REP 2 ORD");
    }

    @Test
    public void testGetAttributeByXpath_invalidAttribute() {
        String xmlData = fileDirUtil.readFileToString("target/test-classes/xml/with_attributes.xml");
        Node node = xpathUtil.getXMLNodeByXpath(xmlData, "//Portfolio[@PortfolioId='GLEM1']/Asset");
        Assert.assertEquals(xpathUtil.getAttributeByNode(node, "AssetadsadName"), "");
        thrown.expect(CartException.class);
        thrown.expectMessage("Processing failed while parsing Node");
        xpathUtil.getAttributeByNode(node, "");
    }

    @Test
    public void testGetAttributeByXpath_invalidNode() {
        thrown.expect(CartException.class);
        thrown.expectMessage("Processing failed while parsing Node");
        String xmlData = fileDirUtil.readFileToString("target/test-classes/xml/with_attributes.xml");
        Node node = xpathUtil.getXMLNodeByXpath(xmlData, "//Portfolio[@PortfolioId='OBCB1']/Asset");
        Assert.assertEquals(xpathUtil.getAttributeByNode(node, "AssetName"), "");
        xpathUtil.getAttributeByNode(node, "");
    }

    @Test
    public void testGetChildNodesCount_validChildNodeName() {
        final String xmlData = fileDirUtil.readFileToString("target/test-classes/xml/with_attributes.xml");
        final int count = xpathUtil.getChildNodesCount(xmlData, "//Portfolios", "Portfolio");
        Assert.assertEquals(3, count);
    }

    @Test
    public void testGetChildNodesCount_noChildNodes() {
        final String xmlData = fileDirUtil.readFileToString("target/test-classes/xml/with_attributes.xml");
        final int count = xpathUtil.getChildNodesCount(xmlData, "//Transactions", "Portfolio");
        Assert.assertEquals(0, count);
    }

    @Test
    public void testGetChildNodesCount_invalidNodes() {
        final String xmlData = fileDirUtil.readFileToString("target/test-classes/xml/with_attributes.xml");
        final int count = xpathUtil.getChildNodesCount(xmlData, "//Portfolios", "invalid");
        Assert.assertEquals(0, count);
    }

    @Test
    public void testGetChildNodesCount_invalidParentXpath() {
        final String xmlData = fileDirUtil.readFileToString("target/test-classes/xml/with_attributes.xml");
        final int count = xpathUtil.getChildNodesCount(xmlData, "//Portfolios1", "invalid");
        Assert.assertEquals(0, count);
    }



}
