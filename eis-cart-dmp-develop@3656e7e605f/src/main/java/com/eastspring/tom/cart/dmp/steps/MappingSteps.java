package com.eastspring.tom.cart.dmp.steps;

import com.eastspring.tom.cart.constant.VndRequestType;
import com.eastspring.tom.cart.core.CartException;
import com.eastspring.tom.cart.core.CartExceptionType;
import com.eastspring.tom.cart.core.steps.ConfigSteps;
import com.eastspring.tom.cart.core.steps.DatabaseSteps;
import com.eastspring.tom.cart.core.steps.HostSteps;
import com.eastspring.tom.cart.core.svc.DatabaseSvc;
import com.eastspring.tom.cart.core.svc.StateSvc;
import com.eastspring.tom.cart.core.svc.WorkspaceDirSvc;
import com.eastspring.tom.cart.core.utl.FileDirUtil;
import com.eastspring.tom.cart.core.utl.FormatterUtil;
import com.eastspring.tom.cart.core.utl.ScenarioUtil;
import com.eastspring.tom.cart.dmp.utl.DmpGsWorkflowUtl;
import org.apache.commons.lang3.EnumUtils;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;

import java.io.File;
import java.util.*;
import java.util.stream.Collectors;

import static tomcart.glue.DmpGsWorkflowStepsDef.ASYNC_RESPONSE_FILE_PATH;

public class MappingSteps {

    private static final Logger LOGGER = LoggerFactory.getLogger(MappingSteps.class);
    private static final String DMP_DB_GC = "dmp.db.GC";
    private static final String DMP_DB_VD = "dmp.db.VD";
    private static final String DMP_SSH_INBOUND = "dmp.ssh.inbound";
    private static final String DMP_SSH_INBOUND_PATH_VAR = "${dmp.ssh.inbound.path}";

    private static final String VREQ_FILE_SEQUENCE_NUMBER_QUERY = "SELECT LPAD(%s+1,8,'0') AS SEQ FROM DUAL";
    private static final String RESPONSE_FILE_NAME_QUERY = "SELECT SUBSTR(FILE_PATTERN_TYP,0,INSTR(FILE_PATTERN_TYP,'*')-1)|| '%s' " +
            "|| '.out' AS RESPONSE_FILE_NAME_1 FROM FT_CFG_VRTY WHERE VND_RQST_TYP = '%s'";

    private static final String WRAPPER_CLASS_NOT_DEFINED_FOR_VND_RQST_TYP = "Wrapper class not defined for VND_RQST_TYP => [{}]";

    @Autowired
    private DmpGsWorkflowSteps wfSteps;

    @Autowired
    private HostSteps hostSteps;

    @Autowired
    private DmpGsWorkflowUtl dmpGsWorkflowUtl;

    @Autowired
    private DatabaseSvc databaseSvc;

    @Autowired
    private DatabaseSteps databaseSteps;

    @Autowired
    private WorkspaceDirSvc workspaceDirSvc;

    @Autowired
    private StateSvc stateSvc;

    @Autowired
    private FileDirUtil fileDirUtil;

    @Autowired
    private ConfigSteps configSteps;

    @Autowired
    private ScenarioUtil scenarioUtil;

    @Autowired
    private FormatterUtil formatterUtil;


    public void inactivateInstruments(final String instruments, final String dbIdentifier) {
        final String dbConfig = dbIdentifier.equalsIgnoreCase("vd") ? DMP_DB_VD : DMP_DB_GC;
        String formattedInstruments = instruments;

        if (!instruments.startsWith("'")) {
            formattedInstruments = "'" +
                    Arrays.stream(instruments.split(",")).map(String::trim).collect(Collectors.joining("','"))
                    + "'";
        }
        wfSteps.setEndTmsToSYSDATEAsPerDBConfig(dbConfig, formattedInstruments);
    }

    public void copyFilesIntoDmpInbound(final List<String> files) {
        for (String file : files) {
            hostSteps.copyLocalFilesToRemote(new File(file).getParent(),
                    Collections.singletonList(new File(file).getName()),
                    DMP_SSH_INBOUND,
                    DMP_SSH_INBOUND_PATH_VAR);
        }
    }

    public void processFileLoad(final Map<String, String> templateParams, final String template, final Integer timeoutInSeconds) {
        dmpGsWorkflowUtl.processWorkFlowRequestAndWaitTillCompletion(template,
                ASYNC_RESPONSE_FILE_PATH,
                templateParams,
                timeoutInSeconds);
    }

    public void verifyExceptionsInDmp(final LinkedHashMap<String, String> columnValueMap, final Integer expectedRecords) {
        final String sql = dmpGsWorkflowUtl.constructNTELVerificationQuery((columnValueMap));
        final Integer actualRecords = Integer.parseInt(databaseSvc.executeSingleValueQueryOnNamedConnection(sql, "CNT"));
        if (!actualRecords.equals(expectedRecords)) {
            LOGGER.error("Verification failed, Expected No. of exceptions [{}], Actual Exceptions [{}]", expectedRecords, actualRecords);
            throw new CartException(CartExceptionType.VERIFICATION_FAILED, "Verification failed, Expected No. of exceptions [{}], Actual Exceptions [{}]", expectedRecords, actualRecords);
        }
    }

    private String getRequestReplySequenceNumber(final String value) {
        final String query = formatterUtil.format(VREQ_FILE_SEQUENCE_NUMBER_QUERY, value);
        final String sequenceNumber = databaseSvc.executeSingleValueQueryOnNamedConnection(query);
        LOGGER.debug("BB RequestReply Sequence Number [{}]", sequenceNumber);
        return sequenceNumber;
    }

    private String getRequestReplyResponseFileName(final String sequenceNumber, final String vndRequestType) {
        final String query = formatterUtil.format(RESPONSE_FILE_NAME_QUERY, sequenceNumber, vndRequestType);
        final String responseFileName = databaseSvc.executeSingleValueQueryOnNamedConnection(query);
        LOGGER.debug("BB RequestReply Response filename [{}] based on Sequence Number [{}]", responseFileName, sequenceNumber);
        return responseFileName;
    }

    public void processRequestReplyPrerequisites(Map<String, String> map) {
        final String vndRequestType = stateSvc.expandVar(map.get("VND_RQST_TYP"));
        final String responseTemplatePath = stateSvc.expandVar(map.get("RESPONSE_TEMPLATE_PATH"));
        final String bbPath = stateSvc.expandVar(map.get("BB_PATH"));
        final List<String> responseTemplateFiles = Arrays.stream(stateSvc.expandVar(map.get("RESPONSE_TEMPLATE_FILES")).split(";"))
                .map(String::trim)
                .collect(Collectors.toList());
        if (!EnumUtils.isValidEnum(VndRequestType.class, vndRequestType.toUpperCase())) {
            LOGGER.debug(WRAPPER_CLASS_NOT_DEFINED_FOR_VND_RQST_TYP, vndRequestType);
            throw new CartException(CartExceptionType.VALIDATION_FAILED, WRAPPER_CLASS_NOT_DEFINED_FOR_VND_RQST_TYP, vndRequestType);
        }
        String sequenceNumber = getRequestReplySequenceNumber("VREQ_FILE_SEQ.NEXTVAL");
        hostSteps.copyLocalFilesToRemote(responseTemplatePath, responseTemplateFiles, DMP_SSH_INBOUND, bbPath);
        for (String responseTemplateFile : responseTemplateFiles) {
            String responseFileName = getRequestReplyResponseFileName(sequenceNumber, vndRequestType);
            hostSteps.renameFile(bbPath + "/" + responseTemplateFile, bbPath + "/" + responseFileName, DMP_SSH_INBOUND);
            if (responseTemplateFiles.size() > 1) {
                sequenceNumber = getRequestReplySequenceNumber(sequenceNumber);
            }
        }
        stateSvc.setStringVar("LATEST_SEQ", sequenceNumber);
        scenarioUtil.write("LATEST_SEQ => " + sequenceNumber);
    }

}
