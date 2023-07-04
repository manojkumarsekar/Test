package com.eastspring.qa.cart.core.utils.sync;

import com.eastspring.qa.cart.core.report.CartLogger;
import com.eastspring.qa.cart.core.configmanagers.RunConfigManager;


public class ThreadUtil {
    public static void sleepMillis(long millis) {
        CartLogger.debug("sleepMillis({})", millis);
        try {
            Thread.sleep(millis);
        } catch (InterruptedException e) { // NOSONAR
        }
    }

    public static void sleepSeconds(int seconds) {
        sleepMillis(seconds * 1000L);
    }

    public static void intermittentWait() {
        sleepMillis(RunConfigManager.INTERMITTENT_WAIT_SECONDS * 1000L);
    }

}