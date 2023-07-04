package com.eastspring.tom.cart.constant;

import org.joda.time.format.DateTimeFormat;
import org.joda.time.format.DateTimeFormatter;

public class Formats {

    private Formats() {
    }

    public static final DateTimeFormatter BRS_TIMESTAMP_FOR_NEW_AMEND_FILE = DateTimeFormat.forPattern("yyyyMMdd_HH");
    public static final DateTimeFormatter BRS_TIMESTAMP_FOR_CANCEL_FILE = DateTimeFormat.forPattern("yyyyMMdd_HH");
    public static final DateTimeFormatter BRS_TRADE_NUGGET_TIMESTAMP = DateTimeFormat.forPattern("yyyyMMdd");

    public static final String BULK_UPLOAD_FILE_FOR_NEW_AMEND = "esi_brs_tradein_cis_%s";
    public static final String BULK_UPLOAD_FILE_FOR_CANCEL = "esi_brs_tradein_cash_collateral_cancel_%s";
    public static final String TRADE_NUGGET_PATTERN = "esi_ADX_I.%s*";

}
