package com.eastspring.tom.cart.dmp.svc;

import com.eastspring.tom.cart.core.svc.StateSvc;
import com.eastspring.tom.cart.core.utl.WorkspaceUtil;
import com.eastspring.tom.cart.dmp.CartDmpTestConfig;
import com.eastspring.tom.cart.dmp.integration.CartDmpStepsSvcUtlConfig;
import java.util.HashMap;
import java.util.Map;
import org.junit.*;
import org.junit.rules.ExpectedException;
import org.junit.runner.RunWith;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.test.context.ContextConfiguration;
import org.springframework.test.context.junit4.SpringJUnit4ClassRunner;

@RunWith(SpringJUnit4ClassRunner.class)
@ContextConfiguration(classes = {CartDmpStepsSvcUtlConfig.class})
public class ResearchReportBrsApiSvcRunIT {
    private static final Logger LOGGER = LoggerFactory.getLogger(ResearchReportBrsApiSvcRunIT.class);
    @Autowired
    private ResearchReportBrsApiSvc researchReportBrsApiSvc;

    @Autowired
    private WorkspaceUtil workspaceUtil;

    @Autowired
    private StateSvc stateSvc;

    @Rule
    public ExpectedException thrown = ExpectedException.none();

    @BeforeClass
    public static void setUpclass() {
        CartDmpTestConfig.configureLogging(ResearchReportBrsApiSvcRunIT.class);
    }

    @Before
    public void before() {
        workspaceUtil.setBaseDir(System.getProperty("user.dir"));
    }

    @Test
    public void testgenerateAPIBodyParameters() {

        String ORDER_FILES_TEMPLATE_PATH = "src/test/resources/brsapitemplate";
        String ORDER_FILES_BODY_PATH = "target/test-classes/brsapitemplate";
        Map<String, String> testMap = new HashMap<>();
        testMap.put("ASSET_ID", "BRSJVJDV1");
        testMap.put("ORDER_TRAN_TYPE", "BUY");
        testMap.put("BASKET_ID", "TEST_API_ORDER_123");
        testMap.put("PORTFOLIO_TICKER", "TSTTT16");
        testMap.put("QUANTITY", "1000");
        testMap.put("TRADE_PURPOSE", "ESI. TW DEQ Buy Sell");
        testMap.put("LIMIT_PRICE", "100");
        testMap.put("MARKET_PRICE", "200");
        String orderbodyFilename = researchReportBrsApiSvc.generateAPIBodyParameters(ORDER_FILES_TEMPLATE_PATH, ORDER_FILES_BODY_PATH, testMap);
        Assert.assertEquals(orderbodyFilename.equals(null), false);
    }

}
