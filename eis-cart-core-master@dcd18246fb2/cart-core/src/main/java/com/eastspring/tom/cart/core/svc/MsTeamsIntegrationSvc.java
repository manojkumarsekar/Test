package com.eastspring.tom.cart.core.svc;

import com.eastspring.tom.cart.core.CartException;
import com.eastspring.tom.cart.core.CartExceptionType;
import com.eastspring.tom.cart.core.mdl.RestRequestType;
import com.eastspring.tom.cart.core.utl.FileDirUtil;
import org.springframework.beans.factory.annotation.Autowired;

import java.util.regex.Matcher;

public class MsTeamsIntegrationSvc {

    private static final String MESSAGE_CARD_JSON_PATH = "";

    @Autowired
    private RestApiSvc restApiSvc;

    @Autowired
    private FileDirUtil fileDirUtil;

    @Autowired
    private StateSvc stateSvc;

    public void sendNotification(final String msHook, final String payloadFile) {

        final int splitter = msHook.indexOf("webhook") + "webhook".length();

        restApiSvc.setApiBaseUri(msHook.substring(0, splitter));
        restApiSvc.setApiEndPoint(msHook.substring(splitter));
        restApiSvc.setHeaderParams("Content-Type", "application/json");

        final String varValue = fileDirUtil.readFileToString(payloadFile)
                .replaceAll("\"", Matcher.quoteReplacement("\\\""))
                .replaceAll("\n", "\n\n");

        stateSvc.setStringVar("data", varValue);

        restApiSvc.setBodyParam(stateSvc.expandVar(fileDirUtil.readFileToString(MESSAGE_CARD_JSON_PATH)));
        restApiSvc.sendRequest(RestRequestType.POST);

        if (restApiSvc.getStatusCode() != 200) {
            //LOGGER.error
            throw new CartException(CartExceptionType.IO_ERROR,"");
        }

    }
}
