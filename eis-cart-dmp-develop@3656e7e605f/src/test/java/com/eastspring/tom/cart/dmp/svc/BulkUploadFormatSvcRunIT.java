package com.eastspring.tom.cart.dmp.svc;

import com.eastspring.tom.cart.constant.AssetType;
import com.eastspring.tom.cart.constant.MapConstants;
import com.eastspring.tom.cart.core.CartException;
import com.eastspring.tom.cart.core.svc.DatabaseSvc;
import com.eastspring.tom.cart.core.svc.StateSvc;
import com.eastspring.tom.cart.dmp.CartDmpTestConfig;
import com.eastspring.tom.cart.dmp.integration.CartDmpStepsSvcUtlConfig;
import org.apache.commons.collections4.map.ListOrderedMap;
import org.junit.Assert;
import org.junit.BeforeClass;
import org.junit.Rule;
import org.junit.Test;
import org.junit.rules.ExpectedException;
import org.junit.runner.RunWith;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.test.context.ContextConfiguration;
import org.springframework.test.context.junit4.SpringJUnit4ClassRunner;

import java.util.HashMap;
import java.util.Map;

import static com.eastspring.tom.cart.dmp.svc.BulkUploadFormatSvc.TRADE_PARAMETERS_CANNOT_BE_NULL_OR_EMPTY;

@RunWith(SpringJUnit4ClassRunner.class)
@ContextConfiguration(classes = {CartDmpStepsSvcUtlConfig.class})
public class BulkUploadFormatSvcRunIT {

    @Autowired
    private BulkUploadFormatSvc bulkUploadFormatSvc;

    @Autowired
    private DatabaseSvc databaseSvc;

    @Autowired
    private StateSvc stateSvc;

    @BeforeClass
    public static void setUpclass() {
        CartDmpTestConfig.configureLogging(BulkUploadFormatSvcRunIT.class);
    }

    @Rule
    public ExpectedException thrown = ExpectedException.none();

    @Test
    public void testGetContentMap_EmptyMap() {
        thrown.expectMessage(TRADE_PARAMETERS_CANNOT_BE_NULL_OR_EMPTY);
        thrown.expect(CartException.class);
        Map<String, String> testParams = new HashMap<>();
        bulkUploadFormatSvc.getContentMap(testParams);
    }

    @Test
    public void testGetContentMap_NullMap() {
        thrown.expectMessage(TRADE_PARAMETERS_CANNOT_BE_NULL_OR_EMPTY);
        thrown.expect(CartException.class);
        bulkUploadFormatSvc.getContentMap(null);
    }

    @Test
    public void testGetContentMap_InvalidAssetType() {
        thrown.expectMessage("Undefined Asset Type [invalid]");
        thrown.expect(CartException.class);

        Map<String, String> testParams = new HashMap<>();
        testParams.put(MapConstants.ASSET_TYPE, "invalid");

        bulkUploadFormatSvc.getContentMap(testParams);
    }

    @Test
    public void testGetContentMap_FX() {
        Map<String, String> testParams = new HashMap<>();

        //Below are mandatory fields for FX
        testParams.put(MapConstants.ASSET_TYPE, AssetType.FX_FWRDS);
        testParams.put(MapConstants.IDENTIFIER, "EURUSD");
        testParams.put(MapConstants.TXN_TYPE, "Buy");
        testParams.put(MapConstants.TRD_DATE, "2018-06-01");
        testParams.put(MapConstants.SETT_DATE, "2018-06-04");

        ListOrderedMap<String, String> content = bulkUploadFormatSvc.getContentMap(testParams);

        Assert.assertEquals(21, content.keyList().size());
        Assert.assertEquals(21, content.valueList().size());
        Assert.assertTrue(content.valueList().contains("EURUSD"));
    }


}
