package com.eastspring.tom.cart.dmp.svc;

import com.eastspring.tom.cart.constant.MapConstants;
import com.eastspring.tom.cart.core.CartException;
import com.eastspring.tom.cart.core.utl.DateTimeUtil;
import com.eastspring.tom.cart.core.utl.FileDirUtil;
import com.eastspring.tom.cart.core.utl.WorkspaceUtil;
import com.eastspring.tom.cart.dmp.CartDmpTestConfig;
import com.eastspring.tom.cart.dmp.integration.CartDmpStepsSvcUtlConfig;
import com.eastspring.tom.cart.dmp.utl.BusinessDayUtl;
import com.eastspring.tom.cart.dmp.utl.mdl.TrdNuggetsSpec;
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

import java.nio.file.Path;
import java.util.HashMap;
import java.util.Map;

import static com.eastspring.tom.cart.constant.TradeConstants.ISO_DATE_FORMAT;

@RunWith(SpringJUnit4ClassRunner.class)
@ContextConfiguration(classes = {CartDmpStepsSvcUtlConfig.class})
public class TradeLifeCycleSvcRunIT {

    private static final String RESOURCES_TLC_PATH = "src/test/resources/tlc";

    @Autowired
    private TradeLifeCycleSvc tradeLifeCycleSvc;

    @Autowired
    private FileDirUtil fileDirUtil;

    @Autowired
    private TrdNuggetsSpec trdNuggetsSpec;

    @Autowired
    private WorkspaceUtil workspaceUtil;

    @Autowired
    private BusinessDayUtl businessDayUtl;

    @Autowired
    private DateTimeUtil dateTimeUtil;

    @Rule
    public ExpectedException thrown = ExpectedException.none();


    @BeforeClass
    public static void setUpclass() {
        CartDmpTestConfig.configureLogging(TradeLifeCycleSvcRunIT.class);
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
    public void testGenerateTradeNuggetsTar_EmptyMap() {
        thrown.expect(CartException.class);
        thrown.expectMessage("All Trade Parameters must be populated. Values are missing for [] params");
        tradeLifeCycleSvc.generateTradeNuggetsTar(new HashMap<>());
    }

    @Test
    public void testGenerateTradeNuggetsTar_MissingParamValues() {
        thrown.expect(CartException.class);
        thrown.expectMessage("All Trade Parameters must be populated");
        Map<String, String> testMap = createTradeParamsMap();
        testMap.put(MapConstants.PORTFOLIO, "");
        testMap.put(MapConstants.IDENTIFIER, "");
        tradeLifeCycleSvc.generateTradeNuggetsTar(testMap);
    }


    @Test
    public void testTradeLifeCycleFlow() {
        trdNuggetsSpec.setTrdNuggetsTemplatePath(RESOURCES_TLC_PATH);
        trdNuggetsSpec.setTrdNuggetsGenerationPath("target/test-classes/tlc/nuggets");
        Path tradeNuggets = tradeLifeCycleSvc.generateTradeNuggetsTar(createTradeParamsMap());
        Path tradeAck = tradeLifeCycleSvc.generateTradeAckXml(tradeNuggets);
        Assert.assertTrue(fileDirUtil.verifyFileExists(tradeNuggets.toString()));
        Assert.assertTrue(fileDirUtil.verifyFileExists(tradeAck.toString()));
    }

    @Test
    public void testResolveTLCDate_T() {
        final String format = "T";
        String expected = dateTimeUtil.getTimestamp(ISO_DATE_FORMAT);
        Assert.assertEquals(expected, tradeLifeCycleSvc.resolveTLCDate(format));
    }

    @Test
    public void testResolveTLCDate_T0() {
        final String format = "T+0";
        String expected = dateTimeUtil.getTimestamp(ISO_DATE_FORMAT);
        Assert.assertEquals(expected, tradeLifeCycleSvc.resolveTLCDate(format));
    }

    @Test
    public void testResolveTLCDate_WrongFormat() {
        thrown.expect(CartException.class);
        thrown.expectMessage("Input [] Should be either T or T+N (N is 1,2...N) format");
        final String format = "";
        tradeLifeCycleSvc.resolveTLCDate(format);
    }

    @Test
    public void testResolveTLCDate_T2() {
        final String format = "T+2";
        String expected = businessDayUtl.getNextBizDay(dateTimeUtil.getTimestamp(ISO_DATE_FORMAT), 2);
        Assert.assertEquals(expected, tradeLifeCycleSvc.resolveTLCDate(format));
    }


}
