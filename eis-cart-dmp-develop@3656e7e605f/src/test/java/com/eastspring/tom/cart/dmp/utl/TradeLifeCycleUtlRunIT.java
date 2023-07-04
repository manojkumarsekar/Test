/*package com.eastspring.tom.cart.dmp.utl;

import com.eastspring.tom.cart.constant.AssetType;
import com.eastspring.tom.cart.constant.MapConstants;
import com.eastspring.tom.cart.constant.TradeConstants;
import com.eastspring.tom.cart.core.CartException;
import com.eastspring.tom.cart.core.svc.StateSvc;
import com.eastspring.tom.cart.core.utl.FileDirUtil;
import com.eastspring.tom.cart.core.utl.WorkspaceUtil;
import com.eastspring.tom.cart.core.utl.XPathUtil;
import com.eastspring.tom.cart.dmp.CartDmpTestConfig;
import com.eastspring.tom.cart.dmp.integration.CartDmpStepsSvcUtlConfig;
import org.hamcrest.CoreMatchers;
import org.joda.time.DateTime;
import org.junit.Assert;
import org.junit.Before;
import org.junit.BeforeClass;
import org.junit.Rule;
import org.junit.Test;
import org.junit.rules.ExpectedException;
import org.junit.runner.RunWith;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.test.context.ContextConfiguration;
import org.springframework.test.context.junit4.SpringJUnit4ClassRunner;

import java.io.File;
import java.nio.file.Paths;
import java.util.HashMap;
import java.util.Map;

@RunWith(SpringJUnit4ClassRunner.class)
@ContextConfiguration(classes = {CartDmpStepsSvcUtlConfig.class})
public class TradeLifeCycleUtlRunIT {

    private static final String EXPECTED_CUSIP_VALUE = "SB0LMTQ39";
    private static final String RESOURCES_TLC_PATH = "src/test/resources/tlc";

    @Autowired
    private TradeLifeCycleUtl tradeLifeCycleUtl;

    @Autowired
    private WorkspaceUtil workspaceUtil;

    @Autowired
    private StateSvc stateSvc;

    @Autowired
    private FileDirUtil fileDirUtil;

    @Autowired
    private XPathUtil xPathUtil;

    @Rule
    public ExpectedException thrown = ExpectedException.none();

    @BeforeClass
    public static void setUpclass() {
        CartDmpTestConfig.configureLogging(TradeLifeCycleUtlRunIT.class);
    }

    @Before
    public void before() {
        workspaceUtil.setBaseDir(System.getProperty("user.dir"));
    }

    private Map<String, String> createTradeParamsMap() {
        Map<String, String> testMap = new HashMap<>();
        testMap.put(MapConstants.ASSET_TYPE, "Equity");
        testMap.put(MapConstants.PORTFOLIO, "TSTALCHEF");
        testMap.put(MapConstants.FUND_ID, "4033");
        testMap.put(MapConstants.IDENTIFIER, "US01609WAP77");
        testMap.put(MapConstants.TXN_TYPE, "Buy");
        testMap.put(MapConstants.TXN_STATUS, "New");
        testMap.put(MapConstants.TRD_DATE, "2018-06-01");
        testMap.put(MapConstants.SETT_DATE, "2018-06-04");
        testMap.put(MapConstants.TRD_QTY, "1");
        testMap.put(MapConstants.TRD_PRICE, "1.1");
        testMap.put(MapConstants.TRD_EX_BROKER, "TEST");
        testMap.put(MapConstants.TRD_EX_DESK, "DV");
        return testMap;
    }


    @Test
    public void testExtractSMDetailsAndAssignToVars_validSmFile() {
        String xmlFilePath = Paths.get("target/test-classes/tlc/sm1.xml").normalize().toString();
        tradeLifeCycleUtl.extractSMValuesAndAssignToVars(xmlFilePath, AssetType.EQUITY);
        String capturedCusipValue = stateSvc.getStringVar(TradeConstants.CUSIP);
        Assert.assertEquals(EXPECTED_CUSIP_VALUE, capturedCusipValue);
    }

    @Test
    public void testExtractSMDetailsAndAssignToVars_NotSmFile() {
        thrown.expect(CartException.class);
        thrown.expectMessage("Error while processing extract SM Details");
        String xmlFilePath = Paths.get("target/test-classes/files/bbg_prices.out").normalize().toString();
        tradeLifeCycleUtl.extractSMValuesAndAssignToVars(xmlFilePath, AssetType.EQUITY);
    }

    @Test
    public void testGetTransactionTemplateFileName() {
        Assert.assertEquals("Equity" + File.separator + "equity_transaction_buy_new.xml",
                tradeLifeCycleUtl.resolveTxnXmlTemplate(createTradeParamsMap()));
    }

    @Test
    public void testGetTransactionTemplateFileName_FXFwd() {
        Map<String, String> map = createTradeParamsMap();
        map.put(MapConstants.ASSET_TYPE, "FXFwd");
        Assert.assertEquals("FX" + File.separator + "fx_transaction_buy_new.xml",
                tradeLifeCycleUtl.resolveTxnXmlTemplate(map));
    }

    @Test
    public void testGetTransactionTemplateFileName_FXSpot() {
        Map<String, String> map = createTradeParamsMap();
        map.put(MapConstants.ASSET_TYPE, "FXSpot");
        Assert.assertEquals("FX" + File.separator + "fx_transaction_buy_new.xml",
                tradeLifeCycleUtl.resolveTxnXmlTemplate(map));
    }

    @Test
    public void testGenerateTradeNuggetsTarballName() {
        String generatedFileName = tradeLifeCycleUtl.generateTradeNuggetsTarballName(DateTime.now());
        Assert.assertThat(generatedFileName, CoreMatchers.containsString("esi_ADX_I."));
    }

    @Test
    public void testSetTradeParamVars() {
        tradeLifeCycleUtl.setDefaultTradeVars(createTradeParamsMap());
        Assert.assertEquals("6/1/2018", stateSvc.getStringVar("TRD_DATE"));
        Assert.assertEquals("6/4/2018", stateSvc.getStringVar("SETT_DATE"));
        Assert.assertEquals("1.0000000000", stateSvc.getStringVar("TRD_QTY"));
        Assert.assertEquals("1.1000000000", stateSvc.getStringVar("TRD_PRICE"));
        Assert.assertEquals("TSTALCHEF", stateSvc.getStringVar("PORTFOLIO"));
    }

    @Test
    public void testGetTempDirPath() {
        Assert.assertTrue(fileDirUtil.fileDirExist(String.valueOf(tradeLifeCycleUtl.getTempDirPath("nuggets"))));
    }

    @Test
    public void testSetAssetXMLVar() {
        File securityDump = new File(RESOURCES_TLC_PATH + File.separator + "brs_sm_dump.xml");
        Map<String, String> testMap = new HashMap<>();
        testMap.put(MapConstants.ASSET_TYPE, AssetType.EQ_OPTIONS);
        testMap.put(MapConstants.IDENTIFIER, "Z922RK0P9");
        tradeLifeCycleUtl.setAssetXMLVar(testMap, securityDump);
        String asset_xml = stateSvc.getStringVar("ASSET_XML");
        Assert.assertNotEquals("", asset_xml);
    }

    @Test
    public void testExtractAssetXMLFromBrsDump() {
        File securityDump = new File(RESOURCES_TLC_PATH + File.separator + "brs_sm_dump.xml");
        String actualAssetXml = tradeLifeCycleUtl.extractAssetXMLFromBrsDump(createTradeParamsMap(), securityDump);
        String expectedAssetXml = fileDirUtil.readFileToString(String.valueOf(new File(RESOURCES_TLC_PATH + File.separator + "expected_asset.xml")));
        Assert.assertEquals(expectedAssetXml.replaceAll("[\\r|\\n| ]", ""), actualAssetXml.replaceAll("[\\r|\\n| ]", ""));
    }

    @Test
    public void testExtractAssetXMLFromBrsDump_FxFwds() {
        File securityDump = new File(RESOURCES_TLC_PATH + File.separator + "brs_sm_dump.xml");
        Map<String, String> testMap = createTradeParamsMap();
        testMap.put(MapConstants.ASSET_TYPE, AssetType.FX_FWRDS);
        testMap.put(MapConstants.IDENTIFIER, "USDSGD");
        String xml = tradeLifeCycleUtl.extractAssetXMLFromBrsDump(testMap, securityDump);
        Assert.assertEquals("SGD", xPathUtil.extractByXPath(xml, "//FX_FWRD//CURRENCY").get(0));
    }

    @Test
    public void testExtractAssetXMLFromBrsDump_FxSpot() {
        File securityDump = new File(RESOURCES_TLC_PATH + File.separator + "brs_sm_dump.xml");
        Map<String, String> testMap = createTradeParamsMap();
        testMap.put(MapConstants.ASSET_TYPE, AssetType.FX_SPOTS);
        testMap.put(MapConstants.IDENTIFIER, "ZARJPY");
        String xml = tradeLifeCycleUtl.extractAssetXMLFromBrsDump(testMap, securityDump);
        Assert.assertEquals("JPY", xPathUtil.extractByXPath(xml, "//FX_SPOT//CURRENCY").get(0));
    }

    @Test
    public void testExtractAssetXMLFromBrsDump_Futures() {
        File securityDump = new File(RESOURCES_TLC_PATH + File.separator + "brs_sm_dump.xml");
        Map<String, String> testMap = createTradeParamsMap();
        testMap.put(MapConstants.ASSET_TYPE, AssetType.FUTURES);
        testMap.put(MapConstants.IDENTIFIER, "BTSU82015");
        String xml = tradeLifeCycleUtl.extractAssetXMLFromBrsDump(testMap, securityDump);
        Assert.assertEquals("FUTURE", xPathUtil.extractByXPath(xml, "//FUTURE_FIN//SM_SEC_GROUP").get(0));
    }

    @Test
    public void testExtractAssetXMLFromBrsDump_EQOptions() {
        File securityDump = new File(RESOURCES_TLC_PATH + File.separator + "brs_sm_dump.xml");
        Map<String, String> testMap = createTradeParamsMap();
        testMap.put(MapConstants.ASSET_TYPE, AssetType.EQ_OPTIONS);
        testMap.put(MapConstants.IDENTIFIER, "Z922RK0P9");
        String xml = tradeLifeCycleUtl.extractAssetXMLFromBrsDump(testMap, securityDump);
        Assert.assertEquals("10", xPathUtil.extractByXPath(xml, "//NOTIONAL_FACE").get(0));
    }


    @Test
    public void testExtractAssetXMLFromBrsDump_identifierNotAvailable_when_dump_check_is_false() {
        stateSvc.setStringVar("tlc.brs.dump.check", "false");
        Map<String, String> testMap = createTradeParamsMap();
        testMap.put(MapConstants.IDENTIFIER, "NOT_FOUND");
        File securityDump = new File(RESOURCES_TLC_PATH + File.separator + "brs_sm_dump.xml");
        String xml = tradeLifeCycleUtl.extractAssetXMLFromBrsDump(testMap, securityDump);
        Assert.assertEquals("sm.xml cannot be formed for identifier: NOT_FOUND", xml);
    }

    @Test
    public void testExtractAssetXMLFromBrsDump_identifierNotAvailable_when_dump_check_is_true() {
        thrown.expect(CartException.class);
        thrown.expectMessage("failed while generating sm.xml for identifier [NOT_FOUND] from BRS Dump");
        stateSvc.setStringVar("tlc.brs.dump.check", "true");
        Map<String, String> testMap = createTradeParamsMap();
        testMap.put(MapConstants.IDENTIFIER, "NOT_FOUND");
        File securityDump = new File(RESOURCES_TLC_PATH + File.separator + "brs_sm_dump.xml");
        tradeLifeCycleUtl.extractAssetXMLFromBrsDump(testMap, securityDump);
    }

    @Test
    public void testGenerateExtId() {
        tradeLifeCycleUtl.generateExtId(AssetType.EQUITY, "New");
        String invNum = stateSvc.getStringVar(TradeConstants.EXT_ID1);
        Assert.assertNotEquals("", invNum);
        tradeLifeCycleUtl.generateExtId(AssetType.EQUITY, "Amend");
        Assert.assertEquals(invNum, stateSvc.getStringVar(TradeConstants.EXT_ID1));
        tradeLifeCycleUtl.generateExtId(AssetType.EQUITY, "Cancel");
        Assert.assertEquals(invNum, stateSvc.getStringVar(TradeConstants.EXT_ID1));
    }

}
*/