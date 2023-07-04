package com.eastspring.tom.cart.dmp.svc;


import com.eastspring.tom.cart.core.CartException;
import com.eastspring.tom.cart.core.CartExceptionType;
import com.eastspring.tom.cart.core.svc.StateSvc;
import com.eastspring.tom.cart.core.utl.WsClientUtil;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;

/**
 * @author Daniel Baktiar
 * @since 2017-09
 */
public class DmpWorkflowSvc {
    public static final String GSWF_DEFAULT_CONFIG_NAME = "gs.wf.default.wsconfig.name";
    public static final Logger LOGGER = LoggerFactory.getLogger(DmpWorkflowSvc.class);

    @Autowired
    private StateSvc stateSvc;

    @Autowired
    private WsClientUtil wsClientUtil;

    public String invokeWebService(DmpWorkflowContext context, String soapRequestRawMessage) {
        try {
            return wsClientUtil.submitRawSoapRequest(context.getEndpoint(), context.getCredentialsProvider(), soapRequestRawMessage);
        } catch (Exception e) {
            LOGGER.error("Unable to Submit Soap request", e);
            throw new CartException(CartExceptionType.PROCESSING_FAILED, "Unable to Submit Soap request");
        }
    }

    public DmpWorkflowContext getDmpWorkflowContext() {
        DmpWorkflowContext context = new DmpWorkflowContext();
        String configName = stateSvc.getStringVar(GSWF_DEFAULT_CONFIG_NAME);
        context.setProtocol(stateSvc.getStringVar(configName + ".protocol"));
        context.setHost(stateSvc.getStringVar(configName + ".host"));
        context.setContext(stateSvc.getStringVar(configName + ".context"));
        String portStr = stateSvc.getStringVar(configName + ".port");
        context.setUsername(stateSvc.getStringVar(configName + ".user"));
        context.setPassword(stateSvc.getStringVar(configName + ".pass"));
        if (portStr == null || "".equalsIgnoreCase(portStr.trim())) {
            if ("http".equalsIgnoreCase(context.getProtocol())) {
                context.setPort(80);
            } else if ("https".equalsIgnoreCase(context.getProtocol())) {
                context.setPort(443);
            } else {
                throw new CartException(CartExceptionType.PROCESSING_FAILED, "unknown protocol [{}]", context.getProtocol());
            }
        } else {
            context.setPort(Integer.valueOf(portStr));
        }
        return context;
    }


    public void setWebServiceConfigName(String wsConfigName) {
        stateSvc.setStringVar(GSWF_DEFAULT_CONFIG_NAME, wsConfigName);
    }
}
