package com.eastspring.tom.cart.constant;


public class BrsApiConstants {

    private BrsApiConstants() {
    }

    public static final String BRS_API_TEMPLATES_RELATIVE_PATH = "tests/test-data/brsapi/template";
    public static final String BRS_API_BODY_RELATIVE_PATH = "tests/test-data/brsapi";

    public static final String BRS_REQUEST_ID = "e1b67475-cb45-ca0d-ae22-417cdfc7841d";
    public static final String BRS_API_KEY = "brs.api.key";
    public static final String BRS_USERNAME = "brs.api.username";
    public static final String BRS_PASSWORD = "brs.api.password";
    public static final String BRS_ORDER_NUMBER = "brs.api.order.number";
    public static final String BRS_ORDER_API_URL = "brs.api.order.url";
    public static final String BRS_API_FILE = "brsBodyApi.txt";
    public static final String BRS_ORDER_API_TEMPLATE_FILE = "OrderAPIBodyTemplate.txt";
    public static final String BRS_ORDER_API_RESPONSE_FILE = "brsPostOrderResponse.json";

    public static final String BRS_DEFAULT_TRADE_API_BODY_TEMPLATE_FILE = "DefaultTradeAPIBodyTemplate.txt";

    public static final String BRS_TRADES_API_ENDPOINT = "/trades/v1/trade";
    public static final String BRS_ORDERS_API_ENDPOINT = "/orders/v2/order";

    public static final String TRADE_RECORD_BY_INVNUM_JSON_PATH = "tradeDataByPortfolioId.%s.tradeRecordByInvnum.%s";

    public static final String TRADE_RESPONSE_ALLOCATIONS_JSON_PATH = "postBlockTradeResults[0].blockTrades[0].allocations[0]";
    public static final String TRADE_RESPONSE_ERROR_JSON_PATH = "postBlockTradeResults[0]";

}
