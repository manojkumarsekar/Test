package com.eastspring.tom.cart.dmp.utl;

import com.eastspring.tom.cart.constant.AssetType;
import com.eastspring.tom.cart.constant.TradeConstants;
import com.eastspring.tom.cart.core.svc.StateSvc;
import com.eastspring.tom.cart.core.utl.XmlUtil;
import com.eastspring.tom.cart.dmp.mdl.BondTrade;
import com.eastspring.tom.cart.dmp.mdl.BrsTrade;
import com.eastspring.tom.cart.dmp.mdl.EqOpTrade;
import com.eastspring.tom.cart.dmp.mdl.EquityTrade;
import com.eastspring.tom.cart.dmp.mdl.FutureTrade;
import com.eastspring.tom.cart.dmp.mdl.FxTrade;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.validation.BindException;
import org.springframework.validation.Errors;

public class TradeValidationUtl {

    private static final Logger LOGGER = LoggerFactory.getLogger(TradeValidationUtl.class);

    @Autowired
    private XmlUtil xmlUtil;

    @Autowired
    private StateSvc stateSvc;

    public synchronized Errors validateBrsTrade(final String actualTrade, final String mockTrade) {
        Errors errors = new BindException(new BrsTrade(), "BrsTrade");
        String assetType = stateSvc.getStringVar("ASSET_TYPE");

        switch (assetType) {
            case AssetType.EQUITY:
                errors = new BindException(new EquityTrade(), "EquityTrade");
                validateTrade(actualTrade, mockTrade, errors, EquityTrade.class);
                break;

            case AssetType.BOND:
                errors = new BindException(new BondTrade(), "BondTrade");
                validateTrade(actualTrade, mockTrade, errors, BondTrade.class);
                break;

            case AssetType.FX_FWRDS:
            case AssetType.FX_SPOTS:
                errors = new BindException(new FxTrade(), "FxTrade");
                validateTrade(actualTrade, mockTrade, errors, FxTrade.class);
                break;
            case AssetType.FUTURES:
                errors = new BindException(new FutureTrade(), "FuturesTrade");
                validateTrade(actualTrade, mockTrade, errors, FutureTrade.class);
                break;
            case AssetType.EQ_OPTIONS:
                errors = new BindException(new EqOpTrade(), "EqOpTrade");
                validateTrade(actualTrade, mockTrade, errors, EqOpTrade.class);
                break;
        }
        return errors;
    }

    private <T extends BrsTrade> void validateTrade(final String actualTrade, final String mockTrade, final Errors errors, final Class<T> clazz) {
        BrsTrade actualTradeObj = xmlUtil.readFromString(actualTrade, clazz);
        BrsTrade mockTradeObj = xmlUtil.readFromString(mockTrade, clazz);

        this.genericTradeValidations(actualTradeObj, mockTradeObj, errors);

        if (clazz.equals(EquityTrade.class)) {
            this.equityValidations(actualTradeObj, mockTradeObj, errors);
        } else if (clazz.equals(BondTrade.class)) {
            this.bondValidations(actualTradeObj, mockTradeObj, errors);
        } else if (clazz.equals(FxTrade.class)) {
            this.fxValidations(actualTradeObj, mockTradeObj, errors);
        } else if (clazz.equals(FutureTrade.class)) {
            this.futuresValidations(actualTradeObj, mockTradeObj, errors);
        } else if (clazz.equals(EqOpTrade.class)) {
            this.eqOptionsValidations(actualTradeObj, mockTradeObj, errors);
        }
    }

    private void genericTradeValidations(final BrsTrade actualTrade, final BrsTrade mockTrade, Errors errors) {

        if ("Cancel".equalsIgnoreCase(stateSvc.getStringVar("TXN_STATUS"))) {
            FieldValidatorUtl.validateEqual("trdStatus", "C", actualTrade.getTrdStatus(), errors);
        }

        FieldValidatorUtl.validateEqual("deskType", mockTrade.getDeskType(), actualTrade.getDeskType(), errors);
        FieldValidatorUtl.validateEqual("portfolio", mockTrade.getPortfolio(), actualTrade.getPortfolio(), errors);
        FieldValidatorUtl.validateEqual("secGroup", mockTrade.getSecGroup(), actualTrade.getSecGroup(), errors);
        FieldValidatorUtl.validateEqual("touchCount", this.getLatestTouchCount(), actualTrade.getTouchCount(), errors);
        FieldValidatorUtl.validateEqual("tranType", mockTrade.getTranType(), actualTrade.getTranType(), errors);
        FieldValidatorUtl.validateEqual("tranType1", mockTrade.getTranType1(), actualTrade.getTranType1(), errors);
        FieldValidatorUtl.validateEqual("trdCounterParty", mockTrade.getTrdCounterParty(), actualTrade.getTrdCounterParty(), errors);
        FieldValidatorUtl.validateEqual("trdLocation", mockTrade.getTrdLocation(), actualTrade.getTrdLocation(), errors);
        FieldValidatorUtl.validateEqual("trdModifyDate", mockTrade.getTrdModifyDate(), actualTrade.getTrdModifyDate(), errors);
        FieldValidatorUtl.validateEqual("trdOrigEntryDate", mockTrade.getTrdOrigEntryDate(), actualTrade.getTrdOrigEntryDate(), errors);
        FieldValidatorUtl.validateEqual("trdOrgFace", mockTrade.getTrdOrgFace(), actualTrade.getTrdOrgFace(), errors);
        FieldValidatorUtl.validateEqual("trdPrice", mockTrade.getTrdPrice(), actualTrade.getTrdPrice(), errors);
        FieldValidatorUtl.validateEqual("trdPrincipal", mockTrade.getTrdPrincipal(), actualTrade.getTrdPrincipal(), errors);
        FieldValidatorUtl.validateEqual("trdTradeDate", mockTrade.getTrdTradeDate(), actualTrade.getTrdTradeDate(), errors);
        FieldValidatorUtl.validateEqual("trdSettleDate", mockTrade.getTrdSettleDate(), actualTrade.getTrdSettleDate(), errors);
        FieldValidatorUtl.validateEqual("units", mockTrade.getUnits(), actualTrade.getUnits(), errors);
        FieldValidatorUtl.validateNotNull("trdVersion", actualTrade.getTrdVersion(), errors);
        FieldValidatorUtl.validateNotNull("invNum", actualTrade.getInvNum(), errors);
        FieldValidatorUtl.validateNotNull("cusip", actualTrade.getCusip(), errors);
        FieldValidatorUtl.validateNotNull("fund", actualTrade.getFund(), errors);
        FieldValidatorUtl.validateEqual("trdExBrokerCode", mockTrade.getTrdExBrokerCode(), actualTrade.getTrdExBrokerCode(), errors);
    }

    private void equityValidations(final BrsTrade actualTrade, final BrsTrade mockTrade, Errors errors) {
        FieldValidatorUtl.validateNotNull("isin", actualTrade.getIsin(), errors);
        FieldValidatorUtl.validateNotNull("sedol", actualTrade.getSedol(), errors);
        FieldValidatorUtl.validateEqual("secType", mockTrade.getSecType(), actualTrade.getSecType(), errors);
    }

    private void bondValidations(final BrsTrade actualTrade, final BrsTrade mockTrade, Errors errors) {
        FieldValidatorUtl.validateNotNull("isin", actualTrade.getIsin(), errors);
        FieldValidatorUtl.validateNotNull("sedol", actualTrade.getSedol(), errors);
        FieldValidatorUtl.validateNotNull("secType", actualTrade.getSecType(), errors);
        FieldValidatorUtl.validateNotNull("accrualDate", ((BondTrade) actualTrade).getAccrualDate(), errors);
        FieldValidatorUtl.validateEqual("cpnType", ((BondTrade) mockTrade).getCpnType(), ((BondTrade) actualTrade).getCpnType(), errors);
        FieldValidatorUtl.validateEqual("execTimeSrc", ((BondTrade) mockTrade).getExecTimeSrc(), ((BondTrade) actualTrade).getExecTimeSrc(), errors);
        FieldValidatorUtl.validateNotNull("firstPayDt", ((BondTrade) actualTrade).getFirstPayDt(), errors);
        FieldValidatorUtl.validateNotNull("maturity", ((BondTrade) actualTrade).getMaturity(), errors);
        FieldValidatorUtl.validateNotNull("smCouponFreq", ((BondTrade) actualTrade).getSmCouponFreq(), errors);
        FieldValidatorUtl.validateNotNull("trdInterest", ((BondTrade) actualTrade).getSmCouponFreq(), errors);
    }

    private void fxValidations(final BrsTrade actualTrade, final BrsTrade mockTrade, final Errors errors) {
        FieldValidatorUtl.validateEqual("secType", mockTrade.getSecType(), actualTrade.getSecType(), errors);
        FieldValidatorUtl.validateEqual("descInstrument", ((FxTrade) mockTrade).getDescInstrument(), ((FxTrade) actualTrade).getDescInstrument(), errors);
        FieldValidatorUtl.validateEqual("fxPayAmt", ((FxTrade) mockTrade).getFxPayAmt(), ((FxTrade) actualTrade).getFxPayAmt(), errors);
        FieldValidatorUtl.validateEqual("fxPayCurr", ((FxTrade) mockTrade).getFxPayCurr(), ((FxTrade) actualTrade).getFxPayCurr(), errors);
        FieldValidatorUtl.validateEqual("fxPayCurr", ((FxTrade) mockTrade).getFxPayCurr(), ((FxTrade) actualTrade).getFxPayCurr(), errors);
        FieldValidatorUtl.validateEqual("fxPrice", ((FxTrade) mockTrade).getFxPrice(), ((FxTrade) actualTrade).getFxPrice(), errors);
        FieldValidatorUtl.validateEqual("fxPriceSpot", ((FxTrade) mockTrade).getFxPriceSpot(), ((FxTrade) actualTrade).getFxPriceSpot(), errors);
        FieldValidatorUtl.validateEqual("fxRcvAmt", ((FxTrade) mockTrade).getFxRcvAmt(), ((FxTrade) actualTrade).getFxRcvAmt(), errors);
        FieldValidatorUtl.validateEqual("fxRcvCurr", ((FxTrade) mockTrade).getFxRcvCurr(), ((FxTrade) actualTrade).getFxRcvCurr(), errors);
        FieldValidatorUtl.validateEqual("smCurrency", ((FxTrade) mockTrade).getSmCurrency(), ((FxTrade) actualTrade).getSmCurrency(), errors);
    }

    private void futuresValidations(final BrsTrade actualTrade, final BrsTrade mockTrade, final Errors errors) {
        FieldValidatorUtl.validateEqual("cusip", mockTrade.getCusip(), actualTrade.getCusip(), errors);
        FieldValidatorUtl.validateNotNull("maturity", ((FutureTrade) actualTrade).getMaturity(), errors);
        FieldValidatorUtl.validateNotNull("secType", actualTrade.getSecType(), errors);
    }

    private void eqOptionsValidations(final BrsTrade actualTrade, final BrsTrade mockTrade, final Errors errors) {
        FieldValidatorUtl.validateEqual("cusip", mockTrade.getCusip(), actualTrade.getCusip(), errors);
        FieldValidatorUtl.validateEqual("secType", mockTrade.getSecType(), actualTrade.getSecType(), errors);
        FieldValidatorUtl.validateNotNull("maturity", ((EqOpTrade) actualTrade).getMaturity(), errors);
        FieldValidatorUtl.validateNotNull("trdConvexity", ((EqOpTrade) actualTrade).getTrdConvexity(), errors);
        FieldValidatorUtl.validateNotNull("trdDropRate", ((EqOpTrade) actualTrade).getTrdDropRate(), errors);
        FieldValidatorUtl.validateNotNull("trdDuration", ((EqOpTrade) actualTrade).getTrdDuration(), errors);
    }

    private String getLatestTouchCount() {
        return stateSvc.getStringVar(TradeConstants.TOUCH_COUNT);
    }
}


