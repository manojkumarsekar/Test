package com.eastspring.tom.cart.core.svc;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;

/**
 * @author Daniel Baktiar
 * @since 2017-09
 */
public class ThreadSvc {
    private static final Logger LOGGER = LoggerFactory.getLogger(ThreadSvc.class);

    @Autowired
    private StateSvc stateSvc;

    /**
     * @param millis
     */
    public void sleepMillis(long millis) {
        LOGGER.debug("sleepMillis({})", millis);
        try {
            Thread.sleep(millis);
        } catch(InterruptedException e) { // NOSONAR
        }
    }

    public void sleepSeconds(int seconds) {
        sleepMillis(seconds * 1000L);
    }

    /**
     *
     */
    public void inbetweenStepsWait() {
        LOGGER.debug("inbetweenStepsWait()");
        try {
            Thread.sleep(stateSvc.getLongVar("web.inbetween.steps.wait.millis"));
        } catch(InterruptedException e) { // NOSONAR
        }
    }
}
