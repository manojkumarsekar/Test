package com.eastspring.tom.cart.core.svc;

import com.eastspring.tom.cart.core.CartCoreTestConfig;
import com.eastspring.tom.cart.core.CartException;
import com.eastspring.tom.cart.core.utl.FileDirUtil;
import com.eastspring.tom.cart.core.utl.WorkspaceUtil;
import com.eastspring.tom.cart.core.utl.XPathUtil;
import org.junit.Assert;
import org.junit.BeforeClass;
import org.junit.Rule;
import org.junit.Test;
import org.junit.rules.ExpectedException;
import org.junit.runner.RunWith;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.test.context.ContextConfiguration;
import org.springframework.test.context.junit4.SpringJUnit4ClassRunner;

@RunWith( SpringJUnit4ClassRunner.class )
@ContextConfiguration( classes = {CartCoreSvcUtlTestConfig.class} )
public class XmlSvcIT {
    private static final Logger LOGGER = LoggerFactory.getLogger(XmlSvcIT.class);
    public static final String XML_NODE_ATTRIBUTES_PATH = "xml/with_attributes.xml";

    @Autowired
    private StateSvc stateSvc;

    @Autowired
    private WorkspaceUtil workspaceUtil;

    @Autowired
    private XmlSvc xmlSvc;

    @Autowired
    private FileDirUtil fileDirUtil;

    @Autowired
    private XPathUtil xPathUtil;

    @Autowired
    private WorkspaceDirSvc workspaceDirSvc;

    @Rule
    public ExpectedException thrown = ExpectedException.none();

    @BeforeClass
    public static void initLogging() {
        CartCoreTestConfig.configureLogging(XmlSvcIT.class);
    }

    @Test
    public void testExtractAttributeValueFromXmlUsingXpathToVar() throws Exception {
        String xmlFile = fileDirUtil.getMavenTestResourcesPath(XML_NODE_ATTRIBUTES_PATH);
        String xpathString = "//Portfolio[@PortfolioId='GLEM1']/Asset";
        String varName = "attributeVal";
        xmlSvc.extractAttributeValueFromXmlUsingXpathToVar(xmlFile, xpathString, "AssetName", varName);
        Assert.assertEquals("ICICI BANK ADR REP 2 ORD", stateSvc.getStringVar(varName));
    }

    @Test
    public void testExtractAttributeValueFromXmlUsingXpathToVar_exception() throws Exception {
        thrown.expect(CartException.class);
        thrown.expectMessage("Processing failed while parsing Node");
        String xmlFile = fileDirUtil.getMavenTestResourcesPath(XML_NODE_ATTRIBUTES_PATH);
        String xpathString = "//Portfolio[@PortfolioId='OBCB1']/Asset";
        String varName = "attributeVal";
        xmlSvc.extractAttributeValueFromXmlUsingXpathToVar(xmlFile, xpathString, "AssetName", varName);
        Assert.assertEquals(null, stateSvc.getStringVar(varName));
    }

}
