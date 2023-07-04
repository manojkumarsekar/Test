/*package com.eastspring.tom.cart.dmp.utl;

import com.eastspring.tom.cart.constant.AssetType;
import com.eastspring.tom.cart.constant.MapConstants;
import com.eastspring.tom.cart.core.utl.FileDirUtil;
import com.eastspring.tom.cart.core.utl.WorkspaceUtil;
import com.eastspring.tom.cart.dmp.CartDmpTestConfig;
import com.eastspring.tom.cart.dmp.integration.CartDmpStepsSvcUtlConfig;
import org.junit.Assert;
import org.junit.Before;
import org.junit.BeforeClass;
import org.junit.Test;
import org.junit.runner.RunWith;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.test.context.ContextConfiguration;
import org.springframework.test.context.junit4.SpringJUnit4ClassRunner;

import java.nio.file.Path;
import java.util.HashMap;
import java.util.Map;

@RunWith(SpringJUnit4ClassRunner.class)
@ContextConfiguration(classes = {CartDmpStepsSvcUtlConfig.class})
public class BulkUploadUtlRunIT {

    @Autowired
    private BulkUploadUtl bulkUploadUtl;

    @Autowired
    private TradeLifeCycleUtl tradeLifeCycleUtl;

    @Autowired
    private FileDirUtil fileDirUtil;

    @Autowired
    private WorkspaceUtil workspaceUtil;

    @BeforeClass
    public static void setUpClass() {
        CartDmpTestConfig.configureLogging(BulkUploadUtlRunIT.class);
    }

    @Before
    public void setBasedir() {
        workspaceUtil.setBaseDir(".");
    }

    @Test
    public void testCreateBulkUploadFile_FX() {
        tradeLifeCycleUtl.setTempDir(tradeLifeCycleUtl.getTempDirPath("TLC"));
        Map<String, String> testParams = new HashMap<>();

        testParams.put(MapConstants.ASSET_TYPE, AssetType.FX_FWRDS);
        testParams.put(MapConstants.PORTFOLIO, "TSTALCHEF");
        testParams.put(MapConstants.IDENTIFIER, "EURUSD");
        testParams.put(MapConstants.TXN_TYPE, "Buy");
        testParams.put(MapConstants.TRD_DATE, "2018-06-01");
        testParams.put(MapConstants.SETT_DATE, "2018-06-04");
        testParams.put(MapConstants.TRD_QTY, "990930");
        testParams.put(MapConstants.TRD_PRICE, "0.752728638753");
        testParams.put(MapConstants.TRD_EX_BROKER, "SCB-ES");
        testParams.put(MapConstants.TRD_EX_DESK, "SCB-SG");

        Path bulkUploadFile = bulkUploadUtl.createBulkUploadFile(testParams);

        Assert.assertTrue(fileDirUtil.fileDirExist(String.valueOf(bulkUploadFile)));
    }

    @Test
    public void testCreateBulkUploadFile_Futures() {
        tradeLifeCycleUtl.setTempDir(tradeLifeCycleUtl.getTempDirPath("TLC"));
        Map<String, String> testParams = new HashMap<>();
        testParams.put(MapConstants.ASSET_TYPE, AssetType.FUTURES);
        testParams.put(MapConstants.PORTFOLIO, "TSTALCHEF");
        testParams.put(MapConstants.IDENTIFIER, "IN67554HHG");
        testParams.put(MapConstants.TXN_TYPE, "Buy");
        testParams.put(MapConstants.TRD_DATE, "2018-06-01");
        testParams.put(MapConstants.SETT_DATE, "2018-06-04");
        testParams.put(MapConstants.TRD_QTY, "990930");
        testParams.put(MapConstants.TRD_PRICE, "0.752728638753");
        testParams.put(MapConstants.TRD_EX_BROKER, "SCB-ES");
        testParams.put(MapConstants.TRD_EX_DESK, "SCB-SG");
        Path bulkUploadFile = bulkUploadUtl.createBulkUploadFile(testParams);
        Assert.assertTrue(fileDirUtil.fileDirExist(String.valueOf(bulkUploadFile)));
    }
}*/