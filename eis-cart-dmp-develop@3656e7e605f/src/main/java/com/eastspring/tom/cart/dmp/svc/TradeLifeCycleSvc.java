package com.eastspring.tom.cart.dmp.svc;

import com.eastspring.tom.cart.constant.MapConstants;
import com.eastspring.tom.cart.constant.TradeConstants;
import com.eastspring.tom.cart.core.CartException;
import com.eastspring.tom.cart.core.CartExceptionType;
import com.eastspring.tom.cart.core.svc.StateSvc;
import com.eastspring.tom.cart.core.svc.WorkspaceDirSvc;
import com.eastspring.tom.cart.core.utl.DateTimeUtil;
import com.eastspring.tom.cart.core.utl.FileDirUtil;
import com.eastspring.tom.cart.dmp.utl.BusinessDayUtl;
import com.eastspring.tom.cart.dmp.utl.TarUtl;
import com.eastspring.tom.cart.dmp.utl.TradeLifeCycleUtl;
import com.eastspring.tom.cart.dmp.utl.mdl.TrdNuggetsSpec;
import com.google.common.base.Strings;
import org.joda.time.DateTime;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;

import java.io.File;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.util.Arrays;
import java.util.Map;
import java.util.stream.Collectors;

import static com.eastspring.tom.cart.constant.TradeConstants.ISO_DATE_FORMAT;

public class TradeLifeCycleSvc {

    private static final Logger LOGGER = LoggerFactory.getLogger(TradeLifeCycleSvc.class);

    private static final String PROCESSING_FAILED = "Processing failed";
    private static final String SM_DUMP_FILENAME = "brs_sm_dump.xml";
    public static final String TLC_CONNECTED_MODE = "tlc.engine.connected.mode";
    public static final String TLC_UAT_BULK_UPLOAD_FLAG = "tlc.server.bulk.upload.flag";

    @Autowired
    private WorkspaceDirSvc workspaceDirSvc;

    @Autowired
    private TradeLifeCycleUtl tradeLifeCycleUtl;

    @Autowired
    private TrdNuggetsSpec trdNuggetsSpec;

    @Autowired
    private TarUtl tarUtl;

    @Autowired
    private StateSvc stateSvc;

    @Autowired
    private FileDirUtil fileDirUtil;

    @Autowired
    private BusinessDayUtl businessDayUtl;

    @Autowired
    private DateTimeUtil dateTimeUtil;


    public Path generateTradeNuggetsTar(final Map<String, String> tradeParamsMap) {

        if (tradeParamsMap.isEmpty() || tradeParamsMap.containsValue("")) {
            String missingKeys = tradeParamsMap.entrySet().stream().filter(entry -> entry.getValue().equals("")).map(Map.Entry::getKey).collect(Collectors.joining(","));
            LOGGER.error("All Trade Parameters must be populated. Values are missing for [{}] params", missingKeys);
            throw new CartException(CartExceptionType.INCOMPLETE_PARAMS, "All Trade Parameters must be populated. Values are missing for [{}] params", missingKeys);
        }

        String templateDir = workspaceDirSvc.normalize(trdNuggetsSpec.getTrdNuggetsTemplatePath());
        String tradeNuggetsDir = workspaceDirSvc.normalize(trdNuggetsSpec.getTrdNuggetsGenerationPath());

        tradeLifeCycleUtl.setDefaultTradeVars(tradeParamsMap);
        File smXml = this.generateSmXml(templateDir, tradeNuggetsDir, tradeParamsMap);

        tradeLifeCycleUtl.setConditionalTradeVars(tradeParamsMap);
        File txnXml = this.generateTxnXml(templateDir, tradeNuggetsDir, tradeParamsMap);

        String tradeNuggetPath = tradeNuggetsDir + File.separator + tradeLifeCycleUtl.generateTradeNuggetsTarballName(DateTime.now());
        try {
            tarUtl.compress(tradeNuggetPath, Arrays.asList(smXml.getAbsolutePath(), txnXml.getAbsolutePath()));
        } catch (Exception e) {
            LOGGER.error(PROCESSING_FAILED, e);
            throw new CartException(CartExceptionType.PROCESSING_FAILED, PROCESSING_FAILED);
        }
        return Paths.get(tradeNuggetPath);
    }

    private File generateSmXml(final String templatesDir, final String tradeNuggetsDir, final Map<String, String> tradeParamsMap) {

        File brsDump = new File(templatesDir + File.separator + SM_DUMP_FILENAME);
        tradeLifeCycleUtl.setAssetXMLVar(tradeParamsMap, brsDump);

        String smXml = tradeNuggetsDir + File.separator + TradeConstants.SM_FILE;
        String smXmlTemplate = templatesDir + File.separator + TradeConstants.SM_TEMPLATE_FILE;

        fileDirUtil.writeStringToFile(smXml, stateSvc.expandVar(fileDirUtil.readFileToString(smXmlTemplate)));

        tradeLifeCycleUtl.extractSMValuesAndAssignToVars(smXml, tradeParamsMap.get(MapConstants.ASSET_TYPE));

        return new File(smXml);
    }

    public File generateTxnXml(final String templatesDir, final String tradeNuggetsDir, final Map<String, String> tradeParamsMap) {
        String txnXml = tradeNuggetsDir + File.separator + TradeConstants.TXN_FILE;
        String txnXmlTemplate = workspaceDirSvc.normalize(templatesDir + File.separator + tradeLifeCycleUtl.resolveTxnXmlTemplate(tradeParamsMap));

        if (fileDirUtil.fileDirExist(txnXmlTemplate)) {
            fileDirUtil.writeStringToFile(txnXml, stateSvc.expandVar(fileDirUtil.readFileToString(txnXmlTemplate)));
            return new File(txnXml);
        } else {
            LOGGER.error("Transaction Template [{}] Not Found", txnXmlTemplate);
            throw new CartException(CartExceptionType.IO_ERROR, "Transaction Template [{}] Not Found", txnXmlTemplate);
        }
    }

    public Path generateTradeAckXml(final Path tradeNuggetPath) {
        String tmsAckFile = tradeLifeCycleUtl.generateTradeAckXmlName(DateTime.now());

        String tmsAckFilePath = workspaceDirSvc.normalize(trdNuggetsSpec.getTrdNuggetsGenerationPath()) + File.separator + tmsAckFile;
        String tmsAckTemplatePath = workspaceDirSvc.normalize(trdNuggetsSpec.getTrdNuggetsTemplatePath()) + File.separator + TradeConstants.TMS_ACK_TEMPLATE;

        try {
            File txnFile = tarUtl.getFileFromTar(tradeNuggetPath.toFile(), TradeConstants.TXN_FILE);
            tradeLifeCycleUtl.extractTxnFileValueAndAssignToVars(txnFile.toString());

            String tmsAckContent = fileDirUtil.readFileToString(tmsAckTemplatePath);
            fileDirUtil.writeStringToFile(tmsAckFilePath, stateSvc.expandVar(tmsAckContent));

            LOGGER.debug("Tms Ack File is generated [{}] for BrsTrade Nuggets [{}]", tmsAckFile, tradeNuggetPath.getFileName());

        } catch (Exception e) {
            LOGGER.error(PROCESSING_FAILED, e);
            throw new CartException(CartExceptionType.PROCESSING_FAILED, PROCESSING_FAILED);
        }
        return Paths.get(tmsAckFilePath);
    }

    /**
     * Resolve tlc date string.
     *
     * @param format the input is in the format of T, T+1, T+2 etc...
     * @return the string is valid date based on format
     */
    public String resolveTLCDate(final String format) {
        String expandFormat = stateSvc.expandVar(format).trim();
        if (!expandFormat.matches("T(\\+\\d*)?") || Strings.isNullOrEmpty(expandFormat)) {
            LOGGER.error("Input [{}] Should be either T or T+N (N is 1,2...N) format", expandFormat);
            throw new CartException(CartExceptionType.INCOMPLETE_PARAMS, "Input [{}] Should be either T or T+N (N is 1,2...N) format", expandFormat);
        }
        String tDate = dateTimeUtil.getTimestamp(ISO_DATE_FORMAT);
        int increment = expandFormat.equals("T") || expandFormat.equals("T+") ? 0 : Integer.parseInt(expandFormat.substring(2));

        String resolvedDate = increment == 0 ? tDate : businessDayUtl.getNextBizDay(tDate, increment);
        LOGGER.debug("Given Format [{}], Resolved Date [{}]", format, resolvedDate);
        return resolvedDate;
    }

    /**
     * Auxiliary method to return the TLC_CONNECTED_MODE property value.
     *
     * @return true/false
     */
    public boolean isTlcInConnectedMode() {
        return Boolean.valueOf(stateSvc.getStringVar(TLC_CONNECTED_MODE));
    }

    /**
     * Auxiliary method to return the TLC_UAT_BULK_UPLOAD_FLAG property value.
     *
     * @return the boolean
     */
    public boolean canCopyF365IntoUAT() {
        return Boolean.valueOf(stateSvc.getStringVar(TLC_UAT_BULK_UPLOAD_FLAG));
    }

    public boolean isTlcValidationCheckEnabled() {
        return Boolean.valueOf(stateSvc.getStringVar("tlc.validation.check"));
    }


}
