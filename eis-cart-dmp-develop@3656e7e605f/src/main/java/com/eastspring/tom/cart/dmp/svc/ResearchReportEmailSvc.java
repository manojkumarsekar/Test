package com.eastspring.tom.cart.dmp.svc;

import com.eastspring.tom.cart.constant.EmailConstants;
import com.eastspring.tom.cart.core.svc.StateSvc;
import com.eastspring.tom.cart.core.utl.FileDirUtil;
import com.eastspring.tom.cart.core.utl.WorkspaceUtil;
import com.eastspring.tom.cart.dmp.utl.EmailUtl;
import java.io.File;
import java.util.Map;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;

public class ResearchReportEmailSvc {

    private static final Logger LOGGER = LoggerFactory.getLogger(ResearchReportEmailSvc.class);

    @Autowired
    private EmailUtl emailUtl;

    @Autowired
    private StateSvc stateSvc;

    @Autowired
    private FileDirUtil fileDirUtil;

    @Autowired
    private WorkspaceUtil workspaceUtil;


    public String generateEmailBody(String emailBodyTemplatesDir, String emailBodyDir, Map<String, String> emailParamsMap) {
        emailUtl.constructEmailTemplateParamsFromMap(emailParamsMap);
        String emaibodyFileName = emailBodyDir + File.separator + EmailConstants.EMAIL_FILE;
        String fullemailFilePath = fileDirUtil.addPrefixIfNotAbsolute(emaibodyFileName, workspaceUtil.getBaseDir());
        LOGGER.debug("Email body File Full Path [{}]", fullemailFilePath);
        fileDirUtil.writeStringToFile(fullemailFilePath, stateSvc.expandVar(fileDirUtil.readFileToString(emailBodyTemplatesDir)));
        return emaibodyFileName;
    }

    public void sendEmailUsingBodyTemplate(String emailBodyTemplates, String emailBodyDir, Map<String, String> emailParamsMap) {
        String emailContentFileName = generateEmailBody(emailBodyTemplates, emailBodyDir, emailParamsMap);
        emailUtl.sendEmail(emailContentFileName);
    }
}
