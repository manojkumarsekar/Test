/*package com.eastspring.tom.cart.dmp.utl;

import com.eastspring.tom.cart.constant.TradeConstants;
import com.eastspring.tom.cart.core.svc.StateSvc;
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
import org.springframework.validation.Errors;
import org.springframework.validation.FieldError;

import java.util.Arrays;
import java.util.List;

@RunWith(SpringJUnit4ClassRunner.class)
@ContextConfiguration(classes = {CartDmpStepsSvcUtlConfig.class})
public class TradeValidationUtlRunIT {

    @Autowired
    private WorkspaceUtil workspaceUtil;

    @Autowired
    private TradeValidationUtl tradeValidationUtl;

    @Autowired
    private FileDirUtil fileDirUtil;

    @Autowired
    private StateSvc stateSvc;

    @BeforeClass
    public static void setUpClass() {
        CartDmpTestConfig.configureLogging(TradeValidationUtlRunIT.class);
    }

    @Before
    public void before() {
        workspaceUtil.setBaseDir(System.getProperty("user.dir"));
        //Setting touch count to 1 as latestTouchCount is used for runtime comparison
        stateSvc.setStringVar(TradeConstants.TOUCH_COUNT, "1");
    }

    @Test
    public void testValidateTradeFactory_equity_success() {
        stateSvc.setStringVar("ASSET_TYPE", "Equity");
        String actualTrade = fileDirUtil.readFileToString("target/test-classes/tlc/Equity/actual_trade.xml");
        String expectedTrade = fileDirUtil.readFileToString("target/test-classes/tlc/Equity/expected_trade_with_no_error.xml");

        Errors errors = tradeValidationUtl.validateBrsTrade(actualTrade, expectedTrade);
        stateSvc.removeStringVar("ASSET_TYPE");

        Assert.assertEquals(0, errors.getErrorCount());
    }

    @Test
    public void testValidateTradeFactory_equity_unSuccess() {
        stateSvc.setStringVar("ASSET_TYPE", "Equity");
        String actualTrade = fileDirUtil.readFileToString("target/test-classes/tlc/Equity/actual_trade.xml");
        String expectedTrade = fileDirUtil.readFileToString("target/test-classes/tlc/Equity/expected_trade_with_error.xml");

        Errors errors = tradeValidationUtl.validateBrsTrade(actualTrade, expectedTrade);
        stateSvc.removeStringVar("ASSET_TYPE");

        Assert.assertEquals(1, errors.getErrorCount());

        List<FieldError> fieldErrors = errors.getFieldErrors();
        Assert.assertEquals("deskType", fieldErrors.get(0).getField());
        Assert.assertEquals("[CAS, CASH]", Arrays.toString(fieldErrors.get(0).getArguments()));
        Assert.assertEquals("Mismatched values.", fieldErrors.get(0).getDefaultMessage());

    }

    @Test
    public void testValidateTradeFactory_equity_unSuccess_withCancel() {
        stateSvc.setStringVar("TXN_STATUS", "Cancel");
        stateSvc.setStringVar("ASSET_TYPE", "Equity");

        String actualTrade = fileDirUtil.readFileToString("target/test-classes/tlc/Equity/actual_trade.xml");
        String expectedTrade = fileDirUtil.readFileToString("target/test-classes/tlc/Equity/expected_trade_with_error.xml");

        Errors errors = tradeValidationUtl.validateBrsTrade(actualTrade, expectedTrade);
        stateSvc.removeStringVar("TXN_STATUS");
        stateSvc.removeStringVar("ASSET_TYPE");

        Assert.assertEquals(2, errors.getErrorCount());
        Assert.assertTrue(errors.getFieldErrors().toString().contains("deskType"));
        Assert.assertTrue(errors.getFieldErrors().toString().contains("trdStatus"));
    }

    @Test
    public void testValidateTradeFactory_bond_success() {
        stateSvc.setStringVar("ASSET_TYPE", "Bond");
        String actualTrade = fileDirUtil.readFileToString("target/test-classes/tlc/Bond/actual_trade.xml");
        String expectedTrade = fileDirUtil.readFileToString("target/test-classes/tlc/Bond/expected_trade_with_no_error.xml");
        Errors errors = tradeValidationUtl.validateBrsTrade(actualTrade, expectedTrade);
        stateSvc.removeStringVar("ASSET_TYPE");

        Assert.assertEquals(0, errors.getErrorCount());
    }

    @Test
    public void testValidateTradeFactory_bond_unSuccess() {
        stateSvc.setStringVar("ASSET_TYPE", "Bond");

        String actualTrade = fileDirUtil.readFileToString("target/test-classes/tlc/Bond/actual_trade.xml");
        String expectedTrade = fileDirUtil.readFileToString("target/test-classes/tlc/Bond/expected_trade_with_error.xml");

        Errors errors = tradeValidationUtl.validateBrsTrade(actualTrade, expectedTrade);
        stateSvc.removeStringVar("ASSET_TYPE");

        Assert.assertEquals(2, errors.getErrorCount());

        List<FieldError> fieldErrors = errors.getFieldErrors();
        Assert.assertEquals("portfolio", fieldErrors.get(0).getField());
        Assert.assertEquals("[TSTALCHE, TSTALCHEF]", Arrays.toString(fieldErrors.get(0).getArguments()));
        Assert.assertEquals("Mismatched values.", fieldErrors.get(0).getDefaultMessage());
        Assert.assertEquals("trdOrgFace", fieldErrors.get(1).getField());
        Assert.assertEquals("[300000000.0000000000, 3000000000.0000000000]", Arrays.toString(fieldErrors.get(1).getArguments()));
        Assert.assertEquals("Mismatched values.", fieldErrors.get(1).getDefaultMessage());
    }

    @Test
    public void testValidateTradeFactory_fx_success() {
        stateSvc.setStringVar("ASSET_TYPE", "FXFwd");
        stateSvc.setStringVar("TXN_STATUS", "Cancel");

        String actualTrade = fileDirUtil.readFileToString("target/test-classes/tlc/Fx/actual_trade_cancel.xml");
        String expectedTrade = fileDirUtil.readFileToString("target/test-classes/tlc/Fx/expected_trade_with_no_error.xml");

        Errors errors = tradeValidationUtl.validateBrsTrade(actualTrade, expectedTrade);
        stateSvc.removeStringVar("ASSET_TYPE");
        stateSvc.removeStringVar("TXN_STATUS");

        Assert.assertEquals(0, errors.getErrorCount());
    }

    @Test
    public void testValidateTradeFactory_fx_unSuccess() {
        stateSvc.setStringVar("ASSET_TYPE", "FXFwd");
        stateSvc.setStringVar("TXN_STATUS", "Cancel");

        String actualTrade = fileDirUtil.readFileToString("target/test-classes/tlc/Fx/actual_trade_cancel.xml");
        String expectedTrade = fileDirUtil.readFileToString("target/test-classes/tlc/Fx/expected_trade_with_error.xml");

        Errors errors = tradeValidationUtl.validateBrsTrade(actualTrade, expectedTrade);
        stateSvc.removeStringVar("ASSET_TYPE");
        stateSvc.removeStringVar("TXN_STATUS");

        Assert.assertEquals(1, errors.getErrorCount());

        List<FieldError> fieldErrors = errors.getFieldErrors();
        Assert.assertEquals("descInstrument", fieldErrors.get(0).getField());
        Assert.assertEquals("[SGD/EUR, EUR/SGD]", Arrays.toString(fieldErrors.get(0).getArguments()));
        Assert.assertEquals("Mismatched values.", fieldErrors.get(0).getDefaultMessage());
    }


    @Test
    public void testValidateTradeFactory_futures_success() {
        stateSvc.setStringVar("ASSET_TYPE", "Futures");

        String actualTrade = fileDirUtil.readFileToString("target/test-classes/tlc/Futures/actual_trade.xml");
        String expectedTrade = fileDirUtil.readFileToString("target/test-classes/tlc/Futures/expected_trade_with_no_error.xml");

        Errors errors = tradeValidationUtl.validateBrsTrade(actualTrade, expectedTrade);
        stateSvc.removeStringVar("ASSET_TYPE");

        Assert.assertEquals(0, errors.getErrorCount());
    }

    @Test
    public void testValidateTradeFactory_futures_unSuccess() {
        stateSvc.setStringVar("ASSET_TYPE", "Futures");

        String actualTrade = fileDirUtil.readFileToString("target/test-classes/tlc/Futures/actual_trade.xml");
        String expectedTrade = fileDirUtil.readFileToString("target/test-classes/tlc/Futures/expected_trade_with_error.xml");

        Errors errors = tradeValidationUtl.validateBrsTrade(actualTrade, expectedTrade);
        stateSvc.removeStringVar("ASSET_TYPE");

        Assert.assertEquals(1, errors.getErrorCount());

        List<FieldError> fieldErrors = errors.getFieldErrors();
        Assert.assertEquals("cusip", fieldErrors.get(0).getField());
        Assert.assertEquals("[RTSH9206, RTSH92016]", Arrays.toString(fieldErrors.get(0).getArguments()));
        Assert.assertEquals("Mismatched values.", fieldErrors.get(0).getDefaultMessage());
    }

}
*/