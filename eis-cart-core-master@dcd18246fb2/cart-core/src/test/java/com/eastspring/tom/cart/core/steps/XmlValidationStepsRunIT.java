package com.eastspring.tom.cart.core.steps;

import com.eastspring.tom.cart.core.CartCoreTestConfig;
import com.eastspring.tom.cart.core.svc.StateSvc;
import com.eastspring.tom.cart.core.CartException;
import com.eastspring.tom.cart.core.utl.FileDirUtil;
import com.eastspring.tom.cart.core.utl.WorkspaceUtil;
import org.junit.*;
import org.junit.rules.ExpectedException;
import org.junit.runner.RunWith;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.test.context.ContextConfiguration;
import org.springframework.test.context.junit4.SpringJUnit4ClassRunner;

import java.util.*;


@RunWith( SpringJUnit4ClassRunner.class )
@ContextConfiguration( classes = {CartCoreStepsSvcUtlTestConfig.class} )
public class XmlValidationStepsRunIT {
    private static final Logger LOGGER = LoggerFactory.getLogger(XmlValidationStepsRunIT.class);

    @Autowired
    private XmlValidationSteps xmlValidationSteps;

    @Autowired
    private StateSvc stateSvc;

    @Autowired
    private WorkspaceUtil workspaceUtil;

    @Autowired
    private FileDirUtil fileDirUtil;

    @BeforeClass
    public static void initLogging() {
        CartCoreTestConfig.configureLogging(XmlValidationStepsRunIT.class);
    }

    @Rule
    public ExpectedException thrown = ExpectedException.none();

    @Before
    public void setUpBaseDir() {
        workspaceUtil.setBaseDir(System.getProperty("user.dir"));
    }

    @Test
    public void testExtractAttributeValueFromXmlUsingXpathToVar_Success() {
        final String xml_file = "target/test-classes/xml/with_attributes.xml";
        List<Map<String, String>> list = new ArrayList<>();
        Map<String, String> valueMap = new HashMap<>();
        valueMap.put("xpath", "//Portfolio[@PortfolioId='GLEM1']/Asset");
        valueMap.put("attributeName", "AssetId");
        valueMap.put("variableName", "AST_ID");
        list.add(valueMap);
        xmlValidationSteps.extractAttributeValueFromXmlUsingXpathToVar(xml_file, list);
        Assert.assertEquals("GLEM1_ESL2242132", stateSvc.getStringVar("AST_ID"));
    }

    @Test
    public void testExtractAttributeValueFromXmlUsingXpathToVar_Exception() {
        thrown.expect(CartException.class);
        thrown.expectMessage("Processing failed while parsing Node");
        final String xml_file = "target/test-classes/xml/with_attributes.xml";
        List<Map<String, String>> list = new ArrayList<>();
        Map<String, String> valueMap = new HashMap<>();
        valueMap.put("xpath", "//Portfolio[@PortfolioId='OBCB1']/Asset");
        valueMap.put("attributeName", "AssetId");
        valueMap.put("variableName", "AST_ID");
        list.add(valueMap);
        xmlValidationSteps.extractAttributeValueFromXmlUsingXpathToVar(xml_file, list);
        Assert.assertEquals(null, stateSvc.getStringVar("AST_ID"));
    }


    @Test
    public void testAssignChildNodesCountToVariable() {
        final String xmlFile = "target/test-classes/xml/with_attributes.xml";
        xmlValidationSteps.assignChildNodesCountToVariable(xmlFile, "//Snapshot", "Transactions", "var");
        Assert.assertEquals("1", stateSvc.getStringVar("var"));
    }

}
