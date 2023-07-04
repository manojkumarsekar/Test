package com.eastspring.tom.cart.core.utl;

import com.eastspring.tom.cart.core.svc.StatePropertiesSvc;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

public class SensitivePassAwareDebugLogUtil {
    private static final Logger LOGGER = LoggerFactory.getLogger(SensitivePassAwareDebugLogUtil.class);

    public void sensitivePassAwareDebugLog(String name, String result, String endedWithPassPostfixMessage, String otherMessage) {
        if (name != null && name.endsWith(StatePropertiesSvc.PASS_POSTFIX)) {
            LOGGER.debug(endedWithPassPostfixMessage);
        } else {
            if (name != null && !name.startsWith("cucumber.json")) {
                LOGGER.debug(otherMessage, result);
            }
        }
    }
}
