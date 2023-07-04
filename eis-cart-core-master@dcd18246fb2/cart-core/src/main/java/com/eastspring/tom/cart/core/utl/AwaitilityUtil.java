package com.eastspring.tom.cart.core.utl;

import org.awaitility.Awaitility;
import org.awaitility.core.ConditionTimeoutException;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import java.util.concurrent.Callable;
import java.util.concurrent.TimeUnit;

import static org.awaitility.Awaitility.await;

public class AwaitilityUtil {

    private static final Logger LOGGER = LoggerFactory.getLogger(AwaitilityUtil.class);

    private static final Integer DEFAULT_MAX_POLL_TIMEOUT = 30;
    private static final Integer DEFAULT_POLL_INTERVAL = 2;

    public AwaitilityUtil() {
        Awaitility.setDefaultPollDelay(0, TimeUnit.SECONDS);
    }

    public boolean waitUntil(Callable<Boolean> conditionEvaluator) {
        try {
            LOGGER.debug("Considering Default Max pollout as [{}]", DEFAULT_MAX_POLL_TIMEOUT);
            await().atMost(DEFAULT_MAX_POLL_TIMEOUT, TimeUnit.SECONDS)
                    .with()
                    .pollInterval(DEFAULT_POLL_INTERVAL, TimeUnit.SECONDS)
                    .until(conditionEvaluator);
            return true;
        } catch (ConditionTimeoutException e) {
            LOGGER.debug("Condition evaluated as false");
            return false;
        }
    }

    public boolean waitUntil(Callable<Boolean> conditionEvaluator, Integer maxTimeoutInSec) {
        LOGGER.debug("Awaitility callable function waiting for [{}] seconds", maxTimeoutInSec);
        try {
            await().atMost(maxTimeoutInSec, TimeUnit.SECONDS)
                    .with()
                    .pollInterval(DEFAULT_POLL_INTERVAL, TimeUnit.SECONDS)
                    .until(conditionEvaluator);
            return true;
        } catch (ConditionTimeoutException e) {
            LOGGER.debug("Condition evaluated as false");
            return false;
        }
    }


}
