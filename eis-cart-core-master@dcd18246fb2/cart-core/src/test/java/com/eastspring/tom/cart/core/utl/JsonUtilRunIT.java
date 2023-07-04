package com.eastspring.tom.cart.core.utl;

import com.eastspring.tom.cart.cfg.CartCoreConfig;
import com.eastspring.tom.cart.core.CartCoreTestConfig;
import com.eastspring.tom.cart.core.CartException;
import com.eastspring.tom.cart.core.mdl.RestRequestType;
import com.eastspring.tom.cart.core.svc.RestApiSvc;
import io.restassured.response.Response;
import org.junit.Assert;
import org.junit.BeforeClass;
import org.junit.Rule;
import org.junit.Test;
import org.junit.rules.ExpectedException;
import org.junit.runner.RunWith;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.test.context.ContextConfiguration;
import org.springframework.test.context.junit4.SpringJUnit4ClassRunner;

import java.io.File;
import java.util.HashMap;
import java.util.Map;

@RunWith( SpringJUnit4ClassRunner.class )
@ContextConfiguration( classes = {CartCoreConfig.class} )
public class JsonUtilRunIT {

    @Autowired
    private JsonUtil jsonUtil;

    @Autowired
    private RestApiSvc restApiSvc;

    @Autowired
    private FileDirUtil fileDirUtil;

    @Rule
    public ExpectedException thrown = ExpectedException.none();

    @BeforeClass
    public static void setUpClass() {
        CartCoreTestConfig.configureLogging(JsonUtilRunIT.class);
    }

    @Test
    public void testJsonStringToMAP() {
        String json = "{\"name\":\"xxx\", \"age\":29}";
        Map<String, Object> resultMap = jsonUtil.jsonStringIntoMap(json);
        Assert.assertEquals(resultMap.get("name"), "xxx");
        Assert.assertEquals(resultMap.get("age"), "29");
    }

    @Test
    public void testJsonFileToMAP() {
        final File file = new File("target/test-classes/__files/testPojo.json");
        Map<String, Object> resultMap = jsonUtil.jsonFileToMap(file);
        Assert.assertNotNull(resultMap);
        Assert.assertEquals(resultMap.get("name").toString(), "TOMCART");
        Assert.assertEquals(resultMap.get("age").toString(), "3");
    }

    @Test
    public void testReadingJsonObjectByJsonPath() {
        final String s = fileDirUtil.readFileToString("target/test-classes/test.json");
        String portfolioName = (String) jsonUtil.readObjectByJsonpath(s, "portfoliosByPortfolioId.4590.portfolioName");
        Assert.assertEquals("UAT_EASTSPRING Training 03", portfolioName);
    }

    @Test
    public void testReadingJsonObjectByJsonPath_absolute() {
        final String s = fileDirUtil.readFileToString("target/test-classes/test.json");
        String portfolioName = (String) jsonUtil.readObjectByJsonpath(s, "$.portfoliosByPortfolioId.4590.portfolioName");
        Assert.assertEquals("UAT_EASTSPRING Training 03", portfolioName);
    }

    @Test
    public void testReadingHashMapByJsonPath() {
        final String s = fileDirUtil.readFileToString("target/test-classes/test.json");
        Map<String, Object> map = (HashMap<String, Object>) jsonUtil.readObjectByJsonpath(s, "portfoliosByPortfolioId.4590");
        Assert.assertEquals(15, map.size());
        Assert.assertEquals("UAT_EASTSPRING Training 03", map.get("portfolioName"));
    }

    @Test
    public void testReadingJsonObjectByJsonPath_invalidJsonPath() {
        thrown.expect(CartException.class);
        thrown.expectMessage("Unable to parse the json string using jsonpath");
        final String s = fileDirUtil.readFileToString("target/test-classes/test.json");
        String portfolioName = (String) jsonUtil.readObjectByJsonpath(s, "$.portfoliosByPortfolioId.4590.portfoli");
        Assert.assertEquals("UAT_EASTSPRING Training 03", portfolioName);
    }
    
}
