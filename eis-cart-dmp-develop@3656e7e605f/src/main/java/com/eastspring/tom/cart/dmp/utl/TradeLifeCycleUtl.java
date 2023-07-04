package com.eastspring.tom.cart.dmp.utl;

import com.eastspring.tom.cart.constant.AssetType;
import com.eastspring.tom.cart.constant.Formats;
import com.eastspring.tom.cart.constant.MapConstants;
import com.eastspring.tom.cart.constant.TradeConstants;
import com.eastspring.tom.cart.core.CartException;
import com.eastspring.tom.cart.core.CartExceptionType;
import com.eastspring.tom.cart.core.svc.RuntimeRemoteSvc;
import com.eastspring.tom.cart.core.svc.StateSvc;
import com.eastspring.tom.cart.core.svc.ThreadSvc;
import com.eastspring.tom.cart.core.svc.XmlSvc;
import com.eastspring.tom.cart.core.utl.DateTimeUtil;
import com.eastspring.tom.cart.core.utl.FileDirUtil;
import com.eastspring.tom.cart.core.utl.FormatterUtil;
import com.eastspring.tom.cart.core.utl.XPathUtil;
import com.eastspring.tom.cart.core.utl.XmlUtil;
import com.google.common.base.Strings;
import org.joda.time.DateTime;
import org.joda.time.format.DateTimeFormat;
import org.joda.time.format.DateTimeFormatter;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.w3c.dom.Node;

import java.io.File;
import java.io.IOException;
import java.nio.file.Files;
import java.util.Map;
import java.util.concurrent.atomic.AtomicInteger;
import java.util.concurrent.atomic.AtomicLong;

import static com.eastspring.tom.cart.constant.Formats.TRADE_NUGGET_PATTERN;
import static com.eastspring.tom.cart.constant.TradeConstants.ISO_DATE_FORMAT;
import static com.eastspring.tom.cart.dmp.steps.DmpTradeLifeCycleSteps.TLC_SERVER;

public class TradeLifeCycleUtl {

    private static final Logger LOGGER = LoggerFactory.getLogger(TradeLifeCycleUtl.class);

    private static final String SEDOL_XPATH = "//CUSIP2_set//CODE[text()='C']/../IDENTIFIER";
    private static final String ISIN_XPATH = "//CUSIP_ALIAS_set//CODE[text()='70']/../IDENTIFIER";
    private static final String ISIN_ALT_XPATH = "//CUSIP2_set//CODE[text()='I']/../IDENTIFIER";
    private static final String CUSIP_TAG = "CUSIP";
    private static final String INSTR_DESC_TAG = "DESC_INSTMT";
    private static final String CURRENCY_TAG = "CURRENCY";
    private static final String TICKER_TAG = "TICKER";
    private static final String FUND_TAG = "FUND";
    private static final String INV_NUM_TAG = "INVNUM";
    private static final String TOUCH_COUNT_TAG = "TOUCH_COUNT";

    private static final String SM_IDENTIFIER_XPATH = "//IDENTIFIER[text() = '%s']";
    private static final String SM_FX_FWRD_XPATH = "//FX_FWRD//ASSET_BENCHMARK[text() = '%s']";
    private static final String SM_FX_SPOT_XPATH = "//FX_SPOT//ASSET_BENCHMARK[text() = '%s']";
    private static final String SM_CUSIP_XPATH = "//CUSIP[text() = '%s']";

    private static final String TRANSACTION_XML_TEMPLATE_NAME = "%s_transaction_%s_%s.xml";

    private static final DateTimeFormatter ADX_TIMESTAMP_FORMAT = DateTimeFormat.forPattern("yyyyMMdd_HHmmss");
    private static final DateTimeFormatter TMSACK_TIMESTAMP_FORMAT = DateTimeFormat.forPattern("yyyyMMdd");

    private static final AtomicInteger BRS_AI = new AtomicInteger(1);
    private static final AtomicInteger BNP_AI = new AtomicInteger(1);

    private static final String BRS_NUMBER_FORMAT = "%.10f";

    private static final String ACCRUAL_DT_TAG = "ACCRUAL_DT";
    private static final String FIRST_PAY_DT_TAG = "FIRST_PAY_DT";
    private static final String MATURITY_TAG = "MATURITY";
    private static final String SM_SEC_TYPE_TAG = "SM_SEC_TYPE";
    public static final String FUTURE_CODE_TAG = "FUTURE_CODE";
    public static final String SM_SEC_GROUP_TAG = "SM_SEC_GROUP";
    public static final String DESC_INSTMT_2_TAG = "DESC_INSTMT2";
    public static final String NOTIONAL_FACE_TAG = "NOTIONAL_FACE";
    public static final String OPTION_EQUITY_DESC_INSTMT_XPATH = "//OPTION_EQUITY//DESC_INSTMT";
    public static final String OPTION_EQUITY_TICKER_XPATH = "//OPTION_EQUITY//TICKER";
    public static final String OPTION_EQUITY_CUSIP_XPATH = "//OPTION_EQUITY//CUSIP";

    public static final int NUGGET_POLLING_INTERVAL = 60;
    public static final String GET_NUGGET_COMMAND = "cd %s;find . -type f -newermt '%s' -name '%s' -exec zgrep -q -a '%s' {} \\; -exec basename {} \\;|sort -r|head -1";
    public static final String GET_TRANSACTION_COMMAND = "tar xfO %s/%s transaction.xml";
    public static final String TLC_NUGGET_WAIT_SECONDS = "tlc.nuggets.wait.seconds";
    public static final String TLC_FILE_PROCESS_WAIT_SECONDS = "tlc.file.process.wait.seconds";

    private static AtomicLong atomicExtId1 = new AtomicLong(Long.MIN_VALUE);

    private File tempDir;

    @Autowired
    private XPathUtil xPathUtil;

    @Autowired
    private StateSvc stateSvc;

    @Autowired
    private DateTimeUtil dateTimeUtil;

    @Autowired
    private FormatterUtil formatterUtil;

    @Autowired
    private FileDirUtil fileDirUtil;

    @Autowired
    private XmlSvc xmlSvc;

    @Autowired
    private XmlUtil xmlUtil;

    @Autowired
    private RuntimeRemoteSvc runtimeRemoteSvc;

    @Autowired
    private ThreadSvc threadSvc;

    public File getTempDir() {
        return tempDir;
    }

    public void setTempDir(File tempDir) {
        this.tempDir = tempDir;
    }

    public void setAssetXMLVar(Map<String, String> tradeParamsMap, File brsDump) {
        String xml = this.extractAssetXMLFromBrsDump(tradeParamsMap, brsDump);

        if (!xml.contains("sm.xml cannot be formed") && AssetType.EQ_OPTIONS.equalsIgnoreCase(tradeParamsMap.get(MapConstants.ASSET_TYPE))) {
            String underlyingCusip = xPathUtil.extractByTagName(xml, "UNDERLYING_CUSIP").get(0);
            tradeParamsMap.put(MapConstants.IDENTIFIER, underlyingCusip);
            xml = this.extractAssetXMLFromBrsDump(tradeParamsMap, brsDump) + "\r" + xml;
        }
        stateSvc.setStringVar("ASSET_XML", xml);
    }

    public synchronized void generateExtId(final String assetType, final String txnStatus) {

        if ("New".equalsIgnoreCase(txnStatus)) {
            String nanos = String.valueOf(atomicExtId1.updateAndGet((v) -> Math.max(v + 1, System.nanoTime())));
            final String random = AssetType.AssetShortCode.valueOf(assetType).getAssetCode() + "_" + String.valueOf(nanos).substring(nanos.length() - 8);

            LOGGER.info("BrsTrade EXT_ID1 [{}] Generated for New BrsTrade", random);

            stateSvc.setStringVar(TradeConstants.EXT_ID1, random);
            stateSvc.setStringVar(TradeConstants.TOUCH_COUNT, "1");
        } else {
            stateSvc.setStringVar(TradeConstants.TOUCH_COUNT, String.valueOf(Integer.valueOf(stateSvc.getStringVar(TradeConstants.TOUCH_COUNT)) + 1));
            LOGGER.info("BrsTrade EXT_ID1 [{}] is copied for Amend/Cancel BrsTrade", stateSvc.getStringVar(TradeConstants.EXT_ID1));
        }
    }

    public File getTempDirPath(final String folderName) {
        try {
            File tempDir = Files.createTempDirectory(folderName + "-").toFile();
            LOGGER.debug("TempDir [{}] created...", tempDir.getAbsolutePath());
            return tempDir;
        } catch (IOException e) {
            LOGGER.error("Exception creating Temp Dir...", e);
            throw new CartException(CartExceptionType.IO_ERROR, "Exception creating Temp Dir...");
        }
    }

    public String resolveTxnXmlTemplate(final Map<String, String> tradeParamMap) {
        //FXFwd and FXSpot is converted to FX
        String assetType = tradeParamMap.get(MapConstants.ASSET_TYPE).startsWith("FX") ? "FX" :
                tradeParamMap.get(MapConstants.ASSET_TYPE);

        String templateName = formatterUtil.format(TRANSACTION_XML_TEMPLATE_NAME,
                assetType.toLowerCase(),
                tradeParamMap.get(MapConstants.TXN_TYPE).toLowerCase(),
                tradeParamMap.get(MapConstants.TXN_STATUS).toLowerCase());

        return assetType + File.separator + templateName;
    }

    public String generateTradeNuggetsTarballName(final DateTime dateTime) {
        String adxTimestamp = ADX_TIMESTAMP_FORMAT.print(dateTime);
        return formatterUtil.format("esi_ADX_I.%s_%05d.tar.gz", adxTimestamp, BRS_AI.getAndIncrement());
    }

    public String generateTradeAckXmlName(final DateTime dateTime) {
        String tmsAckTimestamp = TMSACK_TIMESTAMP_FORMAT.print(dateTime);
        return String.format("esi_brs_tmsack_%s_%05d.xml", tmsAckTimestamp, BNP_AI.getAndIncrement());
    }


    public String extractAssetXMLFromBrsDump(final Map<String, String> tradeParams, final File brsDumpFile) {
        final String identifier = tradeParams.get(MapConstants.IDENTIFIER);
        final String assetType = tradeParams.get(MapConstants.ASSET_TYPE);

        try {
            String xpath;
            if (AssetType.FX_FWRDS.equalsIgnoreCase(assetType)) {
                xpath = SM_FX_FWRD_XPATH;
            } else if (AssetType.FX_SPOTS.equalsIgnoreCase(assetType)) {
                xpath = SM_FX_SPOT_XPATH;
            } else if (AssetType.FUTURES.equalsIgnoreCase(assetType) ||
                    AssetType.EQ_OPTIONS.equalsIgnoreCase(assetType)) {
                xpath = SM_CUSIP_XPATH;
            } else {
                xpath = SM_IDENTIFIER_XPATH;
            }

            String xmlString = fileDirUtil.readFileToString(brsDumpFile.toString());
            Node node = xPathUtil.getXMLNodeByXpath(xmlString, String.format(xpath, identifier));

            Node parentNode = node.getParentNode();
            while (!parentNode.getNodeName().equals("ASSET")) {
                parentNode = parentNode.getParentNode();
            }
            return xPathUtil.extractByNode(parentNode);
        } catch (Exception e) {
            String brsDumpChk = stateSvc.getStringVar("tlc.brs.dump.check");
            if (Strings.isNullOrEmpty(brsDumpChk) || !Boolean.valueOf(brsDumpChk)) {
                return "sm.xml cannot be formed for identifier: " + identifier;
            }
            LOGGER.error("failed while generating sm.xml for identifier [{}] from BRS Dump", e, identifier);
            throw new CartException(CartExceptionType.PROCESSING_FAILED, "failed while generating sm.xml for identifier [{}] from BRS Dump", identifier);
        }
    }

    /**
     * Extract sm details and assign to vars. It extracts CUSIP, INSTRUMENT DESCRIPTION, SEDOL
     * CURRENCY, TICKER and ISIN code from sm.xml and assign to variables
     *
     * @param smFile the sm xml file
     */
    public void extractSMValuesAndAssignToVars(final String smFile, final String assetType) {
        try {
            xmlSvc.extractValueFromXmlUsingTagNameToVar(smFile, CUSIP_TAG, TradeConstants.CUSIP, 0);
            xmlSvc.extractValueFromXmlUsingTagNameToVar(smFile, INSTR_DESC_TAG, TradeConstants.INSTR_DESC, 0);
            xmlSvc.extractValueFromXmlUsingTagNameToVar(smFile, CURRENCY_TAG, TradeConstants.CURRENCY, 0);
            xmlSvc.extractValueFromXmlUsingTagNameToVar(smFile, TICKER_TAG, TradeConstants.TICKER, 0);
            xmlSvc.extractSingleValueFromXmlFileUsingXPathToVar(smFile, SEDOL_XPATH, TradeConstants.SEDOL, 0);

            xmlSvc.extractSingleValueFromXmlFileUsingXPathToVar(smFile, ISIN_XPATH, TradeConstants.ISIN, 0);
            if ("".equals(stateSvc.getStringVar(TradeConstants.ISIN))) {
                LOGGER.debug("Querying sm.xml with alternate ISIN Xpath [{}]", ISIN_ALT_XPATH);
                xmlSvc.extractSingleValueFromXmlFileUsingXPathToVar(smFile, ISIN_ALT_XPATH, TradeConstants.ISIN, 0);
            }

            if (AssetType.BOND.equalsIgnoreCase(assetType)) {
                xmlSvc.extractValueFromXmlUsingTagNameToVar(smFile, ACCRUAL_DT_TAG, TradeConstants.ACCRU_DATE, 0);
                xmlSvc.extractValueFromXmlUsingTagNameToVar(smFile, FIRST_PAY_DT_TAG, TradeConstants.FIRST_PAY_DT, 0);
                xmlSvc.extractValueFromXmlUsingTagNameToVar(smFile, MATURITY_TAG, TradeConstants.MATURITY_DATE, 0);
                xmlSvc.extractValueFromXmlUsingTagNameToVar(smFile, SM_SEC_TYPE_TAG, TradeConstants.SM_SEC_TYPE, 0);
            }

            if (assetType.startsWith("FX")) {
                xmlSvc.extractValueFromXmlUsingTagNameToVar(smFile, DESC_INSTMT_2_TAG, TradeConstants.DESC_INSTMT2, 0);
                xmlSvc.extractValueFromXmlUsingTagNameToVar(smFile, SM_SEC_GROUP_TAG, TradeConstants.SM_SEC_GROUP, 0);
                xmlSvc.extractValueFromXmlUsingTagNameToVar(smFile, SM_SEC_TYPE_TAG, TradeConstants.SM_SEC_TYPE, 0);
            }

            if (AssetType.FUTURES.equalsIgnoreCase(assetType)) {
                xmlSvc.extractValueFromXmlUsingTagNameToVar(smFile, MATURITY_TAG, TradeConstants.MATURITY_DATE, 0);
                xmlSvc.extractValueFromXmlUsingTagNameToVar(smFile, FUTURE_CODE_TAG, TradeConstants.FUTURE_CODE, 0);
            }

            if (AssetType.EQ_OPTIONS.equalsIgnoreCase(assetType)) {
                //EQUITY OPTIONS handling is different for CUSIP and TICKER
                xmlSvc.extractSingleValueFromXmlFileUsingXPathToVar(smFile, OPTION_EQUITY_DESC_INSTMT_XPATH, TradeConstants.INSTR_DESC, 0);
                xmlSvc.extractSingleValueFromXmlFileUsingXPathToVar(smFile, OPTION_EQUITY_TICKER_XPATH, TradeConstants.TICKER, 0);
                xmlSvc.extractSingleValueFromXmlFileUsingXPathToVar(smFile, OPTION_EQUITY_CUSIP_XPATH, TradeConstants.CUSIP, 0);
                xmlSvc.extractValueFromXmlUsingTagNameToVar(smFile, MATURITY_TAG, TradeConstants.MATURITY_DATE, 0);
                xmlSvc.extractValueFromXmlUsingTagNameToVar(smFile, FUTURE_CODE_TAG, TradeConstants.FUTURE_CODE, 0);
                xmlSvc.extractValueFromXmlUsingTagNameToVar(smFile, NOTIONAL_FACE_TAG, TradeConstants.NOTIONAL_FACE, 0);
            }
        } catch (Exception e) {
            LOGGER.error("Error while processing extract SM Details", e);
            throw new CartException(CartExceptionType.PROCESSING_FAILED, "Error while processing extract SM Details");
        }
    }

    /**
     * Extract Transaction details and assign to vars.
     * It extracts, FUND,INV_NUM and TOUCH_COUNT from transaction xml file
     *
     * @param txnFile
     */
    public void extractTxnFileValueAndAssignToVars(final String txnFile) {
        try {
            xmlSvc.extractValueFromXmlUsingTagNameToVar(txnFile, FUND_TAG, TradeConstants.FUND, 0);
            xmlSvc.extractValueFromXmlUsingTagNameToVar(txnFile, INV_NUM_TAG, TradeConstants.INV_NUM, 0);
            xmlSvc.extractValueFromXmlUsingTagNameToVar(txnFile, TOUCH_COUNT_TAG, TradeConstants.TOUCH_COUNT, 0);
        } catch (Exception e) {
            LOGGER.error("Error while processing extract Transaction Details", e);
            throw new CartException(CartExceptionType.PROCESSING_FAILED, "Error while processing extract Transaction Details");
        }
    }

    public void setDefaultTradeVars(final Map<String, String> tradeParamsMap) {
        stateSvc.setStringVar("TRD_DATE", dateTimeUtil.convertDateFormat(tradeParamsMap.get(MapConstants.TRD_DATE), ISO_DATE_FORMAT, "M/d/YYYY"));
        stateSvc.setStringVar("ACK_DATE", dateTimeUtil.convertDateFormat(tradeParamsMap.get(MapConstants.TRD_DATE), ISO_DATE_FORMAT, "MM/dd/YYYY"));
        stateSvc.setStringVar("SETT_DATE", dateTimeUtil.convertDateFormat(tradeParamsMap.get(MapConstants.SETT_DATE), ISO_DATE_FORMAT, "M/d/YYYY"));
        stateSvc.setStringVar("TRD_QTY", String.format(BRS_NUMBER_FORMAT, Double.parseDouble(tradeParamsMap.get(MapConstants.TRD_QTY))));
        stateSvc.setStringVar("TRD_PRICE", String.format(BRS_NUMBER_FORMAT, Double.parseDouble(tradeParamsMap.get(MapConstants.TRD_PRICE))));
        stateSvc.setStringVar("PORTFOLIO", tradeParamsMap.get(MapConstants.PORTFOLIO));
        stateSvc.setStringVar("FUND", tradeParamsMap.get(MapConstants.FUND_ID));
        stateSvc.setStringVar("DESK_TYPE", tradeParamsMap.get(MapConstants.TRD_EX_DESK));
        stateSvc.setStringVar("TRD_CPTY", tradeParamsMap.get(MapConstants.TRD_EX_BROKER));
        stateSvc.setStringVar("TXN_STATUS", tradeParamsMap.get(MapConstants.TXN_STATUS));
        stateSvc.setStringVar("ASSET_TYPE", tradeParamsMap.get(MapConstants.ASSET_TYPE));
    }

    public void setConditionalTradeVars(final Map<String, String> tradeParamsMap) {

        Double trdPrincipal = Double.parseDouble(tradeParamsMap.get(MapConstants.TRD_QTY)) * Double.parseDouble(tradeParamsMap.get(MapConstants.TRD_PRICE));
        String assetType = tradeParamsMap.get(MapConstants.ASSET_TYPE);

        if (AssetType.EQUITY.equalsIgnoreCase(assetType)) {
            stateSvc.setStringVar("TRD_PRINCIPAL", String.format(BRS_NUMBER_FORMAT, trdPrincipal));
        } else if (AssetType.BOND.equalsIgnoreCase(assetType)) {
            stateSvc.setStringVar("TRD_PRINCIPAL", String.format(BRS_NUMBER_FORMAT, trdPrincipal / 100));
        }

        if (assetType.startsWith("FX")) {
            stateSvc.setStringVar("TRD_PRINCIPAL", String.format(BRS_NUMBER_FORMAT, trdPrincipal));
            stateSvc.setStringVar("DESC_INSTMT2", tradeParamsMap.get(MapConstants.IDENTIFIER).substring(0, 3));
            stateSvc.setStringVar("CURRENCY", tradeParamsMap.get(MapConstants.IDENTIFIER).substring(3, 6));
            stateSvc.setStringVar("SM_SEC_TYPE", tradeParamsMap.get(MapConstants.ASSET_TYPE).equals(AssetType.FX_FWRDS) ? "FWRD" : "SPOT");
            stateSvc.setStringVar("DESC_INSTMT", tradeParamsMap.get(MapConstants.IDENTIFIER).substring(0, 3) + "/" + tradeParamsMap.get(MapConstants.IDENTIFIER).substring(3, 6));
            stateSvc.setStringVar("TRD_PRICE_INVERSE",
                    String.format(BRS_NUMBER_FORMAT, 1 / Double.parseDouble(tradeParamsMap.get(MapConstants.TRD_PRICE))));

        }

        if (AssetType.FUTURES.equalsIgnoreCase(assetType)) {
            stateSvc.setStringVar("CUSIP", tradeParamsMap.get(MapConstants.IDENTIFIER));
            stateSvc.setStringVar("EX_BROKER", tradeParamsMap.get(MapConstants.TRD_EX_BROKER));
        }

        if (AssetType.EQ_OPTIONS.equalsIgnoreCase(assetType)) {
            stateSvc.setStringVar("CUSIP", tradeParamsMap.get(MapConstants.IDENTIFIER));
            stateSvc.setStringVar("EX_BROKER", tradeParamsMap.get(MapConstants.TRD_EX_BROKER));

            String notionalFace = Strings.isNullOrEmpty(stateSvc.getStringVar(TradeConstants.NOTIONAL_FACE))
                    ? "1"
                    : stateSvc.getStringVar(TradeConstants.NOTIONAL_FACE);

            stateSvc.setStringVar("TRD_PRINCIPAL", String.format(BRS_NUMBER_FORMAT,
                    trdPrincipal * Double.parseDouble(notionalFace)));
        }
    }

    /**
     * Gets trade nugget name.
     * This function uses look up value argument to find desired BrsTrade nuggets and
     * waits tlc.scenario.wait.seconds in the tradeNuggetPath.
     *
     * @param tradeNuggetPath the trade nugget path
     * @param lookUpValue     the look up value
     * @return the trade nugget name
     */
    public String getTradeNuggetName(final String tradeNuggetPath, final String lookUpValue) {
        final String remoteHost = stateSvc.getStringVar(TLC_SERVER + ".host");
        final Integer port = Integer.parseInt(stateSvc.getStringVar(TLC_SERVER + ".port"));
        final String user = stateSvc.getStringVar(TLC_SERVER + ".user");
        final String maxPollTime = stateSvc.getStringVar(TLC_NUGGET_WAIT_SECONDS);

        final String nuggetPattern = formatterUtil.format(TRADE_NUGGET_PATTERN, Formats.BRS_TRADE_NUGGET_TIMESTAMP.print(new DateTime()));

        threadSvc.sleepSeconds(1);
        final String timestamp = runtimeRemoteSvc.getTimeStamp(remoteHost, port, user, null);
        final String getNuggetCmd = formatterUtil.format(GET_NUGGET_COMMAND, tradeNuggetPath, timestamp, nuggetPattern, lookUpValue);
        LOGGER.debug("Get TradeNugget Command [{}]", getNuggetCmd);

        String output = "";
        long millisStart = dateTimeUtil.currentTimeMillis();
        long millisCurrent = millisStart;

        while (Strings.isNullOrEmpty(output.trim()) && (millisCurrent - millisStart) / 1000 <= Long.valueOf(maxPollTime)) {
            output = runtimeRemoteSvc.sshRemoteExecute(remoteHost, port, user, getNuggetCmd).getOutput();
            if (Strings.isNullOrEmpty(output.trim())) {
                threadSvc.sleepSeconds(NUGGET_POLLING_INTERVAL);
            }
            millisCurrent = dateTimeUtil.currentTimeMillis();
        }

        if (Strings.isNullOrEmpty(output)) {
            LOGGER.error("Cannot find BrsTrade Nugget with value [{}]", lookUpValue);
            throw new CartException(CartExceptionType.VALIDATION_FAILED, "Cannot find BrsTrade Nugget with value [{}]", lookUpValue);
        }
        return output.trim();
    }

    public void waitTillF365Processed(final String filePath) {
        final String remoteHost = stateSvc.getStringVar(TLC_SERVER + ".host");
        final Integer port = Integer.parseInt(stateSvc.getStringVar(TLC_SERVER + ".port"));
        final String user = stateSvc.getStringVar(TLC_SERVER + ".user");
        String maxPollTime = stateSvc.getStringVar(TLC_FILE_PROCESS_WAIT_SECONDS);

        if (Strings.isNullOrEmpty(maxPollTime)) {
            maxPollTime = String.valueOf(1);
        }

        boolean isFileExists = true;
        long millisStart = dateTimeUtil.currentTimeMillis();
        long millisCurrent = millisStart;

        while (isFileExists && (millisCurrent - millisStart) / 1000 <= Long.valueOf(maxPollTime)) {
            isFileExists = runtimeRemoteSvc.sshFileExists(remoteHost, port, user, filePath);
            if (isFileExists) {
                LOGGER.info("Waiting for file [{}] to be processed", filePath);
                threadSvc.sleepSeconds(30);
            }
            millisCurrent = dateTimeUtil.currentTimeMillis();
        }
        LOGGER.info("Is file [{}] processed ? [{}]", filePath, !isFileExists);
    }

    /**
     * Gets trade data.
     * This function reads transaction.xml from Nugget without unzipping and returns TRADE node xml
     * In case of multiple <TRADE></TRADE> blocks in transaction.xml, this function retrieves specific TRADE block based on xpath
     *
     * @param tradeNuggetPath the trade nugget path
     * @param nuggetName      the nugget name
     * @param xpathQuery      the xpath query
     */
    public String getActualTradeData(final String tradeNuggetPath, final String nuggetName, final String xpathQuery) {

        try {
            final String remoteHost = stateSvc.getStringVar(TLC_SERVER + ".host");
            final Integer port = Integer.parseInt(stateSvc.getStringVar(TLC_SERVER + ".port"));
            final String user = stateSvc.getStringVar(TLC_SERVER + ".user");

            final String command = formatterUtil.format(GET_TRANSACTION_COMMAND, tradeNuggetPath, nuggetName);

            LOGGER.debug("Executing Command [{}]", command);
            String trades = runtimeRemoteSvc.sshRemoteExecute(remoteHost, port, user, command).getOutput().trim();

            if (Strings.isNullOrEmpty(trades)) {
                LOGGER.error("Unable to retrieve transaction.xml data from Nugget [{}]", nuggetName);
                throw new CartException(CartExceptionType.PROCESSING_FAILED, "Unable to retrieve transaction.xml data from Nugget [{}]", nuggetName);
            }
            //retrieving specific BrsTrade xml (in case of multiple TRADE blocks in single Transaction.xml)
            return xPathUtil.extractByNode(xPathUtil.getXMLNodeByXpath(trades, xpathQuery));
        } catch (Exception e) {
            LOGGER.error("Processing failed while fetching BrsTrade Data from Transaction xml", e);
            throw new CartException(CartExceptionType.PROCESSING_FAILED, "Processing failed while fetching BrsTrade Data from Transaction xml");
        }
    }

}
