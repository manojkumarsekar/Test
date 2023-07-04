package com.eastspring.tom.cart.dmp.svc;

import com.eastspring.tom.cart.constant.AssetType;
import com.eastspring.tom.cart.constant.MapConstants;
import com.eastspring.tom.cart.constant.TradeConstants;
import com.eastspring.tom.cart.core.CartException;
import com.eastspring.tom.cart.core.CartExceptionType;
import com.eastspring.tom.cart.core.svc.DatabaseSvc;
import com.eastspring.tom.cart.core.svc.StateSvc;
import org.apache.commons.collections4.map.ListOrderedMap;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;

import java.util.Arrays;
import java.util.Map;

public class BulkUploadFormatSvc {

    private static final Logger LOGGER = LoggerFactory.getLogger(BulkUploadFormatSvc.class);
    private static final String NO_SETTLEMENT = "No Settlement";
    private static final String NA = "N/A";

    public static final String ISIN = "ISIN";
    public static final String SEDOL = "SEDOL";
    public static final String BCUSIP = "BCUSIP";

    public static final String EXT_ID1 = "EXT_ID1";
    public static final String PORTFOLIO = "PORTFOLIO";
    public static final String TRANSACTION = "TRANSACTION";
    public static final String QUANTITY = "QUANTITY";
    public static final String PRICE_CCY_PAIR = "PRICE_CCY_PAIR";
    public static final String PRICE = "PRICE";
    public static final String EX_BROKER = "EX_BROKER";
    public static final String EX_DESK_TYPE = "EX_DESK_TYPE";
    public static final String TRADE_DATE = "TRADE_DATE";
    public static final String SECURITY_SMARTCUT_FX_DEALT_CURRENCY = "SECURITY.SMARTCUT.FX_DEALT_CURRENCY";
    public static final String SECURITY_SMARTCUT_FX_CONTRA_CURRENCY = "SECURITY.SMARTCUT.FX_CONTRA_CURRENCY";
    public static final String SECURITY_SMARTCUT_FX_VALUE_DATE = "SECURITY.SMARTCUT.FX_VALUE_DATE";
    public static final String SECURITY_SMARTCUT_FX_TYPE = "SECURITY.SMARTCUT.FX_TYPE";
    public static final String FORWARD_POINTS = "FORWARD_POINTS";
    public static final String DELIVERY = "DELIVERY";
    public static final String DELIVERY_2 = "DELIVERY2";
    public static final String SETTLEMENT_INSTRUCTION = "SETTLEMENT_INSTRUCTION";
    public static final String SETTLEMENT_INSTRUCTION_2 = "SETTLEMENT_INSTRUCTION2";
    public static final String CONFIRMED_WITH = "CONFIRMED_WITH";
    public static final String CONFIRMED_BY = "CONFIRMED_BY";
    public static final String TRADER = "TRADER";
    public static final String SECURITY_ISIN = "SECURITY.ISIN";
    public static final String SECURITY_SEDOL = "SECURITY.SEDOL";
    public static final String SECURITY_CUSIP = "SECURITY.CUSIP";
    public static final String SETTLE_DATE = "SETTLE_DATE";

    public static final String SQL_TO_GET_IDENTIFIERS = "SELECT DISTINCT B.ISS_ID AS ISIN, C.ISS_ID AS SEDOL, D.ISS_ID AS BCUSIP FROM FT_T_ISID A\n" +
            "JOIN FT_T_ISID B\n" +
            "    ON A.INSTR_ID = B.INSTR_ID AND B.ID_CTXT_TYP = 'ISIN'\n" +
            "JOIN FT_T_ISID C\n" +
            "    ON A.INSTR_ID = C.INSTR_ID AND C.ID_CTXT_TYP = 'SEDOL'\n" +
            "JOIN FT_T_ISID D\n" +
            "    ON A.INSTR_ID = D.INSTR_ID AND D.ID_CTXT_TYP = 'BCUSIP'\n" +
            "WHERE A.ISS_ID = '%s'\n";

    public static final String TRADE_PARAMETERS_CANNOT_BE_NULL_OR_EMPTY = "Trade Parameters Cannot be Null or Empty";
    public static final String UNDEFINED_ASSET_TYPE = "Undefined Asset Type [{}]";

    @Autowired
    private DatabaseSvc databaseSvc;

    @Autowired
    private StateSvc stateSvc;

    private String tlcUser;

    public void setTlcUser() {
        tlcUser = stateSvc.getStringVar("tlc.authorised.user");
    }

    /**
     * Gets content of Trade Parameters map Headers as Key and Data as Value in the map.
     *
     * @param tradeParams the trade params
     * @return the content map
     */
    public ListOrderedMap<String, String> getContentMap(final Map<String, String> tradeParams) {
        if (tradeParams == null || tradeParams.isEmpty()) {
            LOGGER.error(TRADE_PARAMETERS_CANNOT_BE_NULL_OR_EMPTY);
            throw new CartException(CartExceptionType.UNDEFINED, TRADE_PARAMETERS_CANNOT_BE_NULL_OR_EMPTY);
        }

        if ("Cancel".equalsIgnoreCase(tradeParams.get(MapConstants.TXN_STATUS))) {
            return getCancelContentMap(tradeParams);
        }

        String assetType = tradeParams.get(MapConstants.ASSET_TYPE);
        ListOrderedMap<String, String> content;

        switch (assetType) {
            case AssetType.FX_FWRDS:
            case AssetType.FX_SPOTS:
                content = this.getFXContentMap(tradeParams);
                break;
            case AssetType.EQUITY:
                content = this.getEQContentMap(tradeParams);
                break;
            case AssetType.BOND:
                content = this.getFIContentMap(tradeParams);
                break;
            case AssetType.FUTURES:
            case AssetType.EQ_OPTIONS:
                content = this.getDerivativesContentMap(tradeParams);
                break;
            default:
                LOGGER.error(UNDEFINED_ASSET_TYPE, assetType);
                throw new CartException(CartExceptionType.UNDEFINED, UNDEFINED_ASSET_TYPE, assetType);
        }
        return content;
    }

    private ListOrderedMap<String, String> getCancelContentMap(final Map<String, String> tradeParams) {
        ListOrderedMap<String, String> cancelTrade = new ListOrderedMap<>();
        cancelTrade.put(PORTFOLIO, tradeParams.get(MapConstants.PORTFOLIO));
        cancelTrade.put(EXT_ID1, stateSvc.getStringVar(TradeConstants.EXT_ID1));
        return cancelTrade;
    }


    private ListOrderedMap<String, String> getDerivativesContentMap(final Map<String, String> tradeParams) {
        ListOrderedMap<String, String> derivativesMap = new ListOrderedMap<>();
        this.setTlcUser();

        derivativesMap.put(EXT_ID1, stateSvc.getStringVar(TradeConstants.EXT_ID1));
        derivativesMap.put(PORTFOLIO, tradeParams.get(MapConstants.PORTFOLIO));
        derivativesMap.put(TRANSACTION, tradeParams.get(MapConstants.TXN_TYPE).toUpperCase());
        derivativesMap.put(EX_BROKER, tradeParams.get(MapConstants.TRD_EX_BROKER));
        derivativesMap.put(QUANTITY, tradeParams.get(MapConstants.TRD_QTY));
        derivativesMap.put(PRICE, tradeParams.get(MapConstants.TRD_PRICE));
        derivativesMap.put(TRADE_DATE, tradeParams.get(MapConstants.TRD_DATE).replaceAll("-", ""));
        derivativesMap.put(SETTLE_DATE, tradeParams.get(MapConstants.SETT_DATE).replaceAll("-", ""));
        derivativesMap.put(SECURITY_ISIN, "");
        derivativesMap.put(SECURITY_SEDOL, "");
        derivativesMap.put(SECURITY_CUSIP, stateSvc.getStringVar("CUSIP"));
        derivativesMap.put(EX_DESK_TYPE, tradeParams.get(MapConstants.TRD_EX_DESK));
        derivativesMap.put(TRADER, tlcUser);
        derivativesMap.put(DELIVERY, NO_SETTLEMENT);
        derivativesMap.put(SETTLEMENT_INSTRUCTION, NA);
        derivativesMap.put(CONFIRMED_WITH, tlcUser);
        derivativesMap.put(CONFIRMED_BY, tlcUser);
        return derivativesMap;
    }

    private ListOrderedMap<String, String> getEQContentMap(final Map<String, String> tradeParams) {
        ListOrderedMap<String, String> equityMap = new ListOrderedMap<>();

        this.setInstrumentIdentifiers(tradeParams.get(MapConstants.IDENTIFIER));
        this.setTlcUser();

        equityMap.put(EXT_ID1, stateSvc.getStringVar(TradeConstants.EXT_ID1));
        equityMap.put(PORTFOLIO, tradeParams.get(MapConstants.PORTFOLIO));
        equityMap.put(TRANSACTION, tradeParams.get(MapConstants.TXN_TYPE).toUpperCase());
        equityMap.put(SECURITY_ISIN, stateSvc.getStringVar(ISIN));
        equityMap.put(SECURITY_SEDOL, stateSvc.getStringVar(SEDOL));
        equityMap.put(SECURITY_CUSIP, stateSvc.getStringVar(BCUSIP));
        equityMap.put(EX_BROKER, tradeParams.get(MapConstants.TRD_EX_BROKER));
        equityMap.put(EX_DESK_TYPE, tradeParams.get(MapConstants.TRD_EX_DESK));
        equityMap.put(QUANTITY, tradeParams.get(MapConstants.TRD_QTY));
        equityMap.put(PRICE, tradeParams.get(MapConstants.TRD_PRICE));
        equityMap.put(TRADE_DATE, tradeParams.get(MapConstants.TRD_DATE).replaceAll("-", ""));
        equityMap.put(SETTLE_DATE, tradeParams.get(MapConstants.SETT_DATE).replaceAll("-", ""));
        equityMap.put(TRADER, tlcUser);
        equityMap.put(DELIVERY, NO_SETTLEMENT);
        equityMap.put(SETTLEMENT_INSTRUCTION, NA);
        equityMap.put(CONFIRMED_WITH, tlcUser);
        equityMap.put(CONFIRMED_BY, tlcUser);

        return equityMap;
    }

    private ListOrderedMap<String, String> getFIContentMap(final Map<String, String> tradeParams) {
        ListOrderedMap<String, String> fiMap = new ListOrderedMap<>();

        this.setTlcUser();

        fiMap.put(EXT_ID1, stateSvc.getStringVar(TradeConstants.EXT_ID1));
        fiMap.put(PORTFOLIO, tradeParams.get(MapConstants.PORTFOLIO));
        fiMap.put(TRANSACTION, tradeParams.get(MapConstants.TXN_TYPE).toUpperCase());
        fiMap.put(SECURITY_ISIN, "");
        fiMap.put(SECURITY_SEDOL, tradeParams.get(MapConstants.IDENTIFIER));
        fiMap.put(SECURITY_CUSIP, "");
        fiMap.put(EX_BROKER, tradeParams.get(MapConstants.TRD_EX_BROKER));
        fiMap.put(EX_DESK_TYPE, tradeParams.get(MapConstants.TRD_EX_DESK));
        fiMap.put(QUANTITY, tradeParams.get(MapConstants.TRD_QTY));
        fiMap.put(PRICE, tradeParams.get(MapConstants.TRD_PRICE));
        fiMap.put(TRADE_DATE, tradeParams.get(MapConstants.TRD_DATE).replaceAll("-", ""));
        fiMap.put(SETTLE_DATE, tradeParams.get(MapConstants.SETT_DATE).replaceAll("-", ""));
        fiMap.put(TRADER, tlcUser);
        fiMap.put(DELIVERY, NO_SETTLEMENT);
        fiMap.put(SETTLEMENT_INSTRUCTION, NA);
        fiMap.put(CONFIRMED_WITH, tlcUser);
        fiMap.put(CONFIRMED_BY, tlcUser);
        return fiMap;
    }

    private ListOrderedMap<String, String> getFXContentMap(final Map<String, String> tradeParams) {
        ListOrderedMap<String, String> fxMap = new ListOrderedMap<>();
        this.setTlcUser();

        fxMap.put(EXT_ID1, stateSvc.getStringVar(TradeConstants.EXT_ID1));
        fxMap.put(PORTFOLIO, tradeParams.get(MapConstants.PORTFOLIO));
        fxMap.put(TRANSACTION, tradeParams.get(MapConstants.TXN_TYPE).toUpperCase());
        fxMap.put(QUANTITY, tradeParams.get(MapConstants.TRD_QTY));
        fxMap.put(PRICE_CCY_PAIR, tradeParams.get(MapConstants.IDENTIFIER));
        fxMap.put(PRICE, tradeParams.get(MapConstants.TRD_PRICE));
        fxMap.put(EX_BROKER, tradeParams.get(MapConstants.TRD_EX_BROKER));
        fxMap.put(EX_DESK_TYPE, tradeParams.get(MapConstants.TRD_EX_DESK));
        fxMap.put(TRADE_DATE, tradeParams.get(MapConstants.TRD_DATE).replaceAll("-", ""));
        fxMap.put(SECURITY_SMARTCUT_FX_DEALT_CURRENCY, stateSvc.getStringVar("DESC_INSTMT2"));
        fxMap.put(SECURITY_SMARTCUT_FX_CONTRA_CURRENCY, stateSvc.getStringVar("CURRENCY"));
        fxMap.put(SECURITY_SMARTCUT_FX_VALUE_DATE, tradeParams.get(MapConstants.SETT_DATE).replaceAll("-", ""));
        fxMap.put(SECURITY_SMARTCUT_FX_TYPE, stateSvc.getStringVar("SM_SEC_TYPE"));
        //Intentionally left blank, Below field does not have mapping value
        fxMap.put(FORWARD_POINTS, "");
        fxMap.put(DELIVERY, NO_SETTLEMENT);
        fxMap.put(DELIVERY_2, NO_SETTLEMENT);
        fxMap.put(SETTLEMENT_INSTRUCTION, NA);
        fxMap.put(SETTLEMENT_INSTRUCTION_2, NA);
        fxMap.put(CONFIRMED_WITH, tlcUser);
        fxMap.put(CONFIRMED_BY, tlcUser);
        fxMap.put(TRADER, tlcUser);
        return fxMap;
    }


    /**
     * Takes any identifier i.e. ISS_ID and retrieves ISIN, SEDOL and BCUSIP and assign values to same variables.
     *
     * @param identifier
     */
    private void setInstrumentIdentifiers(final String identifier) {
        final String sql = String.format(SQL_TO_GET_IDENTIFIERS, identifier);
        databaseSvc.executeSqlQueryAssignResultsToVars(sql, Arrays.asList(ISIN, SEDOL, BCUSIP));
    }


}

