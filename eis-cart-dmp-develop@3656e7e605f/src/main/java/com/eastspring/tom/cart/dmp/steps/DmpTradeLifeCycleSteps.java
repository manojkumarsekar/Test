package com.eastspring.tom.cart.dmp.steps;

import com.eastspring.tom.cart.constant.FileType;
import com.eastspring.tom.cart.constant.MapConstants;
import com.eastspring.tom.cart.constant.Source;
import com.eastspring.tom.cart.constant.TradeConstants;
import com.eastspring.tom.cart.core.CartException;
import com.eastspring.tom.cart.core.CartExceptionType;
import com.eastspring.tom.cart.core.steps.DatabaseSteps;
import com.eastspring.tom.cart.core.steps.HostSteps;
import com.eastspring.tom.cart.core.svc.StateSvc;
import com.eastspring.tom.cart.core.svc.ThreadSvc;
import com.eastspring.tom.cart.core.utl.FileDirUtil;
import com.eastspring.tom.cart.core.utl.FormatterUtil;
import com.eastspring.tom.cart.core.utl.XPathUtil;
import com.eastspring.tom.cart.dmp.svc.TradeLifeCycleSvc;
import com.eastspring.tom.cart.dmp.utl.BulkUploadUtl;
import com.eastspring.tom.cart.dmp.utl.BusinessDayUtl;
import com.eastspring.tom.cart.dmp.utl.DmpGsWorkflowUtl;
import com.eastspring.tom.cart.dmp.utl.TradeLifeCycleUtl;
import com.eastspring.tom.cart.dmp.utl.TradeValidationUtl;
import com.eastspring.tom.cart.dmp.utl.mdl.TrdNuggetsSpec;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.validation.Errors;
import org.springframework.validation.FieldError;
import org.w3c.dom.Node;

import java.io.File;
import java.nio.file.Path;
import java.util.Arrays;
import java.util.Collections;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import static com.eastspring.tom.cart.constant.TradeConstants.TXN_FILE;
import static tomcart.glue.DmpGsWorkflowStepsDef.ASYNC_RESPONSE_FILE_PATH;
import static tomcart.glue.DmpGsWorkflowStepsDef.FILE_TRANSFER_TEMPLATE_PATH;
import static tomcart.glue.DmpGsWorkflowStepsDef.MAX_POLL_TIME_SECONDS_SMALL;

public class DmpTradeLifeCycleSteps {

    private static final Logger LOGGER = LoggerFactory.getLogger(DmpTradeLifeCycleSteps.class);

    public static final String DESTINATION_HOST = "dmp.ssh.inbound";
    public static final String TLC_TEMPLATES_PATH = "tlc.templates.path";
    public static final String TLC_BRS_CONFIG = "tlc.brs.config";
    public static final String TLC_BNP_CONFIG = "tlc.bnp.config";
    public static final String TLC_BRS_ARCHIVE_PATH = "tlc.brs.archive.path";
    public static final String TLC_BRS_INBOUND_PATH = "tlc.brs.inbound.path";
    public static final String TLC_BNP_ARCHIVE_PATH = "tlc.bnp.archive.path";
    public static final String TLC_BNP_INBOUND_PATH = "tlc.bnp.inbound.path";

    public static final String BRS = "BRS";
    public static final String UNSUPPORTED_OPERATION = "Unsupported Operation";
    public static final String DMP_SQL_QUERY = "SELECT COUNT(*) FROM FT_T_JBLG\n" +
            "WHERE JOB_INPUT_TXT LIKE '%%%s'\n" +
            "AND JOB_CONFIG_TXT = '%s'\n" +
            "AND JOB_STAT_TYP = 'CLOSED'\n";

    //SLEEP_SEC set to 0 in real time,
    //and can be adjusted for demo purpose to view the file movement from Inbound to Archive
    public static final Integer SLEEP_SEC = 0;
    public static final String CONFIG_SOURCE = "CONFIG_SOURCE";
    public static final String ARCHIVE_FILE_PATH = "ARCHIVE_FILE_PATH";
    public static final String FILE_PATH = "FILE_PATH";
    public static final String FILE_PATTERN = "FILE_PATTERN";
    public static final String COPY_LOCAL_FILES_TO_REMOTE_IS_NOT_INITIATING_IN_CONNECTED_MODE = "Copy Local Files to Remote is not initiating in Connected Mode...";
    public static final String TLC_SERVER = "tlc.server";
    public static final String TLC_SERVER_IN_PATH = "tlc.server.in.path";
    public static final String TLC_SERVER_NUGGET_PATH = "tlc.server.nugget.path";

    private Path tradeNuggetTarPath;

    public Path getTradeNuggetTarPath() {
        return tradeNuggetTarPath;
    }

    private Path tradeAckXmlPath;

    public Path getTradeAckXmlPath() {
        return tradeAckXmlPath;
    }

    @Autowired
    private HostSteps hostSteps;

    @Autowired
    private StateSvc stateSvc;

    @Autowired
    private TradeLifeCycleSvc tradeLifeCycleSvc;

    @Autowired
    private TradeLifeCycleUtl tradeLifeCycleUtl;

    @Autowired
    private TrdNuggetsSpec trdNuggetsSpec;

    @Autowired
    private DmpGsWorkflowUtl dmpGsWorkflowUtl;

    @Autowired
    private DatabaseSteps dbSteps;

    @Autowired
    private ThreadSvc threadSvc;

    @Autowired
    private BulkUploadUtl bulkUploadUtl;

    @Autowired
    private BusinessDayUtl businessDayUtl;

    @Autowired
    private FormatterUtil formatterUtil;

    @Autowired
    private XPathUtil xPathUtil;

    @Autowired
    private FileDirUtil fileDirUtil;

    @Autowired
    private TradeValidationUtl tradeValidationUtl;


    public void placeTrade(final Map<String, String> tradeParamsMap) {
        tradeLifeCycleUtl.setTempDir(tradeLifeCycleUtl.getTempDirPath("TLC"));

        tradeLifeCycleUtl.setDefaultTradeVars(tradeParamsMap);
        tradeLifeCycleUtl.setConditionalTradeVars(tradeParamsMap);
        tradeLifeCycleUtl.generateExtId(tradeParamsMap.get(MapConstants.ASSET_TYPE), tradeParamsMap.get(MapConstants.TXN_STATUS));

        Path bulkUploadPath = bulkUploadUtl.createBulkUploadFile(tradeParamsMap);
        LOGGER.info("Bulk upload File [{}] is created...", bulkUploadPath.getFileName().toString());

        File mockTxnXml = tradeLifeCycleSvc.generateTxnXml(stateSvc.getStringVar(TLC_TEMPLATES_PATH),
                tradeLifeCycleUtl.getTempDir().getAbsolutePath(), tradeParamsMap);
        LOGGER.info("Mock transaction.xml is created [{}]", mockTxnXml.getAbsolutePath());

        //Copy bulk upload file into UAT FTP location
        if (tradeLifeCycleSvc.canCopyF365IntoUAT()) {
            final List<String> fileList = Collections.singletonList(bulkUploadPath.getFileName().toString());
            final String uatServerPath = stateSvc.getStringVar(TLC_SERVER_IN_PATH);
            final String localDir = bulkUploadPath.getParent().toString();

            tradeLifeCycleUtl.waitTillF365Processed(uatServerPath + "/" + fileList.get(0));

            hostSteps.copyLocalFilesToRemote(localDir, fileList, TLC_SERVER, uatServerPath);
        }
    }

    public void validateTransactionXml() {

        if (!tradeLifeCycleSvc.isTlcValidationCheckEnabled()) {
            LOGGER.info("Skipping Transaction xml validation");
            return;
        }

        String tlcNuggetGenPath = stateSvc.getStringVar(TLC_SERVER_NUGGET_PATH);

        String latestExtId = stateSvc.getStringVar(TradeConstants.EXT_ID1);
        LOGGER.info("Getting latest ExtId [{}] for searching nugget", latestExtId);

        String nuggetName = tradeLifeCycleUtl.getTradeNuggetName(tlcNuggetGenPath, formatterUtil.format("<ID1>%s</ID1>", latestExtId));
        LOGGER.info("BrsTrade Nugget captured as [{}]", nuggetName);

        String actualTradeXml = tradeLifeCycleUtl.getActualTradeData(tlcNuggetGenPath, nuggetName, formatterUtil.format("//ID1[text()='%s']//ancestor::TRADE", latestExtId));
        LOGGER.info("Actual Trade Xml is Captured as [{}]", actualTradeXml);

        Errors errors = tradeValidationUtl.validateBrsTrade(actualTradeXml, this.getMockTradeXml());

        if (errors.hasErrors()) {
            List<FieldError> fieldErrors = errors.getFieldErrors();
            for (FieldError fe : fieldErrors) {
                LOGGER.error("Field name: [{}], Default message: [{}], Arguments: [{}]", fe.getField(), fe.getDefaultMessage(), Arrays.toString(fe.getArguments()));
            }
            LOGGER.error("transaction xml validation failed with [{}] errors", errors.getErrorCount());
            throw new CartException(CartExceptionType.VERIFICATION_FAILED, "transaction xml validation failed with [{}] errors", errors.getErrorCount());
        }
        LOGGER.info("Transaction xml validation is successful");
    }


    public void generateTradeNuggets(final Map<String, String> tradeParamsMap) {
        tradeLifeCycleUtl.setTempDir(tradeLifeCycleUtl.getTempDirPath("TLC"));

        trdNuggetsSpec.setTrdNuggetsTemplatePath(stateSvc.getStringVar(TLC_TEMPLATES_PATH));
        trdNuggetsSpec.setTrdNuggetsGenerationPath(tradeLifeCycleUtl.getTempDir().getAbsolutePath());
        tradeLifeCycleUtl.generateExtId(tradeParamsMap.get(MapConstants.ASSET_TYPE), tradeParamsMap.get(MapConstants.TXN_STATUS));

        tradeNuggetTarPath = tradeLifeCycleSvc.generateTradeNuggetsTar(tradeParamsMap);

        Path bulkUploadPath = bulkUploadUtl.createBulkUploadFile(tradeParamsMap);
        LOGGER.info("Bulk upload File [{}] is created...", bulkUploadPath.getFileName().toString());

        //Copy bulk upload file into UAT FTP location
        if (tradeLifeCycleSvc.canCopyF365IntoUAT()) {
            final String localDir = bulkUploadPath.getParent().toString();
            final List<String> fileList = Collections.singletonList(bulkUploadPath.getFileName().toString());
            final String uatServerPath = stateSvc.getStringVar(TLC_SERVER_IN_PATH);

            hostSteps.copyLocalFilesToRemote(localDir, fileList, TLC_SERVER, uatServerPath);
        }

        final String tarDirectory = getTradeNuggetTarPath().getParent().toString();
        final String tarFilename = getTradeNuggetTarPath().getFileName().toString();

        LOGGER.info("BrsTrade Nuggets [{}] are generated...", tarFilename);

        if (tradeLifeCycleSvc.isTlcInConnectedMode()) {
            LOGGER.info(COPY_LOCAL_FILES_TO_REMOTE_IS_NOT_INITIATING_IN_CONNECTED_MODE);
        } else {
            hostSteps.copyLocalFilesToRemote(tarDirectory, Collections.singletonList(tarFilename), DESTINATION_HOST, stateSvc.getStringVar(TLC_BRS_INBOUND_PATH));
            threadSvc.sleepSeconds(SLEEP_SEC);
        }
    }

    public void generateTradeAckXml() {
        tradeAckXmlPath = tradeLifeCycleSvc.generateTradeAckXml(getTradeNuggetTarPath());

        final String tmsAckXmlDir = getTradeAckXmlPath().getParent().toString();
        final String tmsAckXmlName = getTradeAckXmlPath().getFileName().toString();

        LOGGER.info("Tms Ack file [{}] is generated...", tmsAckXmlName);

        if (tradeLifeCycleSvc.isTlcInConnectedMode()) {
            LOGGER.debug(COPY_LOCAL_FILES_TO_REMOTE_IS_NOT_INITIATING_IN_CONNECTED_MODE);
        } else {
            hostSteps.copyLocalFilesToRemote(tmsAckXmlDir, Collections.singletonList(tmsAckXmlName), DESTINATION_HOST, stateSvc.getStringVar(TLC_BNP_INBOUND_PATH));
            threadSvc.sleepSeconds(SLEEP_SEC);
        }
    }

    public void initiateTLCFileTransferJob(final Source source) {

        if (tradeLifeCycleSvc.isTlcInConnectedMode()) {
            LOGGER.info("File Transfer Jobs from source [{}] are not initiating in Connected Mode...", source.name());
        } else {
            final Map<String, String> templateParams = new HashMap<>();

            final String configSrcProp = source.name().equals(BRS) ? TLC_BRS_CONFIG : TLC_BNP_CONFIG;
            final String archiveProp = source.name().equals(BRS) ? TLC_BRS_ARCHIVE_PATH : TLC_BNP_ARCHIVE_PATH;
            final String inboundProp = source.name().equals(BRS) ? TLC_BRS_INBOUND_PATH : TLC_BNP_INBOUND_PATH;
            final Path filename = source.name().equalsIgnoreCase(BRS) ? getTradeNuggetTarPath().getFileName() : getTradeAckXmlPath().getFileName();

            templateParams.put(CONFIG_SOURCE, stateSvc.getStringVar(configSrcProp));
            templateParams.put(ARCHIVE_FILE_PATH, stateSvc.getStringVar(archiveProp));
            templateParams.put(FILE_PATH, stateSvc.getStringVar(inboundProp));
            templateParams.put(FILE_PATTERN, filename.toString());

            dmpGsWorkflowUtl.processWorkFlowRequestAndWaitTillCompletion(FILE_TRANSFER_TEMPLATE_PATH, ASYNC_RESPONSE_FILE_PATH, templateParams, MAX_POLL_TIME_SECONDS_SMALL);
            LOGGER.info("File Transfer from Source [{}] is initiated...", source);
        }
    }

    public void iExpectFileIsSuccessfullyArchived(final FileType filetype) {
        final String filename;
        final String archiveDir;

        if (tradeLifeCycleSvc.isTlcInConnectedMode()) {
            LOGGER.info("File [{}] Archive Verification is Skipped in Connected Mode...", filetype.name());
        } else {
            if (FileType.TRADE_NUGGETS.equals(filetype)) {
                filename = getTradeNuggetTarPath().getFileName().toString();
                archiveDir = stateSvc.getStringVar(TLC_BRS_ARCHIVE_PATH);
            } else if (FileType.TMS_ACK.equals(filetype)) {
                filename = getTradeAckXmlPath().getFileName().toString();
                archiveDir = stateSvc.getStringVar(TLC_BNP_ARCHIVE_PATH);
            } else {
                LOGGER.error(UNSUPPORTED_OPERATION);
                throw new CartException(CartExceptionType.INVALID_INVOCATION_PARAMS, UNSUPPORTED_OPERATION);
            }
            hostSteps.expectFileAvailableInFolderAfterProcessing(DESTINATION_HOST, archiveDir, Collections.singletonList(filename));
        }
    }

    public void iExpectDMPRecordIsCreatedForFileProcessing(final FileType filetype) {
        final String filename;
        final String formattedSql;

        if (tradeLifeCycleSvc.isTlcInConnectedMode()) {
            LOGGER.info("DMP Record Verification for [{}] is Skipped in Connected Mode...", filetype.name());
        } else {
            if (FileType.TRADE_NUGGETS.equals(filetype)) {
                filename = getTradeNuggetTarPath().getFileName().toString();
                formattedSql = String.format(DMP_SQL_QUERY, filename, Source.BRS);
            } else if (FileType.TMS_ACK.equals(filetype)) {
                filename = getTradeAckXmlPath().getFileName().toString();
                formattedSql = String.format(DMP_SQL_QUERY, filename, Source.BNP);
            } else {
                LOGGER.error(UNSUPPORTED_OPERATION);
                throw new CartException(CartExceptionType.INVALID_INVOCATION_PARAMS, UNSUPPORTED_OPERATION);
            }
            dbSteps.expectRecordsInTableWithQuery(formattedSql);
        }
    }


    public Map<String, String> updateTradeParamsMapWithActualDates(final Map<String, String> tradeParams) {
        final String tradeDate = tradeLifeCycleSvc.resolveTLCDate(tradeParams.get(MapConstants.TRD_DATE));
        final String settleDate = tradeLifeCycleSvc.resolveTLCDate(tradeParams.get(MapConstants.SETT_DATE));

        tradeParams.put(MapConstants.TRD_DATE, tradeDate);
        tradeParams.put(MapConstants.SETT_DATE, settleDate);

        LOGGER.debug("BrsTrade parameters After updating dates => [{}]", tradeParams);
        return tradeParams;
    }


    public void setCurrentDateVar(final String currentDate) {
        stateSvc.setStringVar("CURR_DATE", currentDate);
    }

    public void setIncrementVar(final Integer increment) {
        stateSvc.setStringVar("INCREMENT", String.valueOf(increment));
    }

    public void validateNextBizDay(final String nextBizDay) {
        final String currDate = stateSvc.getStringVar("CURR_DATE");
        final Integer increment = Integer.parseInt(stateSvc.getStringVar("INCREMENT"));
        final String actualNextBizDay = businessDayUtl.getNextBizDay(currDate, increment);

        if (!actualNextBizDay.equals(nextBizDay)) {
            LOGGER.error("Next Biz Day Validation failed, Actual [{}], expected [{}]", actualNextBizDay, nextBizDay);
            throw new CartException(CartExceptionType.VALIDATION_FAILED, "Next Biz Day Validation failed, Actual [{}], expected [{}]", actualNextBizDay, nextBizDay);
        }
    }

    //This is just an auxillary method
    private String getMockTradeXml() {
        String filepath = tradeLifeCycleUtl.getTempDir().getAbsolutePath() + File.separator + TXN_FILE;
        String txnContent = fileDirUtil.readFileToString(filepath);
        Node node = xPathUtil.getXMLNodeByXpath(txnContent, "//TRADE");
        return xPathUtil.extractByNode(node);
    }
}
