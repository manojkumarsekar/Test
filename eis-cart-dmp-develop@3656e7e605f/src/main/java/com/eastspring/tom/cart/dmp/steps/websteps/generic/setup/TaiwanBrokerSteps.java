package com.eastspring.tom.cart.dmp.steps.websteps.generic.setup;

import com.eastspring.tom.cart.core.CartException;
import com.eastspring.tom.cart.core.CartExceptionType;
import com.eastspring.tom.cart.dmp.pages.generic.setup.TaiwanBrokerPage;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;

import java.util.LinkedHashMap;

public class TaiwanBrokerSteps {

    private static final Logger LOGGER = LoggerFactory.getLogger(TaiwanBrokerSteps.class);

    @Autowired
    private TaiwanBrokerPage taiwanBrokerPage;

    public void iCreateTaiwanBroker(final LinkedHashMap<String, String> dataMap) {
        taiwanBrokerPage.navigateToScreen("Generic Setup", "Taiwan Broker Setup");
        taiwanBrokerPage.invokeSetup();
        taiwanBrokerPage.fillTaiwanBrokerSetup(dataMap, false);
    }

}
