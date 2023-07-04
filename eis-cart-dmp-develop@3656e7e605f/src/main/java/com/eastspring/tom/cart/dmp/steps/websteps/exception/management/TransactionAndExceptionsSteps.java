package com.eastspring.tom.cart.dmp.steps.websteps.exception.management;

import com.eastspring.tom.cart.core.CartException;
import com.eastspring.tom.cart.core.CartExceptionType;
import com.eastspring.tom.cart.core.svc.StateSvc;
import com.eastspring.tom.cart.dmp.pages.exception.management.TransactionAndExceptionsPage;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;

import javax.script.ScriptEngine;
import javax.script.ScriptEngineManager;
import javax.script.ScriptException;
import java.util.LinkedHashMap;

public class TransactionAndExceptionsSteps {

    private static final Logger LOGGER = LoggerFactory.getLogger(TransactionAndExceptionsSteps.class);

    @Autowired
    private TransactionAndExceptionsPage transactionAndExceptionsPage;

    @Autowired
    private StateSvc stateSvc;

    public void iSearchForTransactionAndExceptions(LinkedHashMap<String, String> map) {
        transactionAndExceptionsPage.navigateToTransactionAndExceptions()
                .searchTransaction(map);
    }

    public void iResubmitTransactionAndException() {
        transactionAndExceptionsPage.resubmitTransactionAndExceptions();
    }

    public void iCaptureNotificationCountForTransaction(String variable) {
        String value = transactionAndExceptionsPage.getNotificationCount();
        String expandedVar = stateSvc.expandVar(value);
        stateSvc.setStringVar(variable, expandedVar);
        LOGGER.debug("assignValueToVar: set {} := [{}]", variable, expandedVar);
        transactionAndExceptionsPage.setNotificationCountBefore(value);
    }

    public void iExpectNotificationCountIncreased(String expression) {
        String expandExpression = stateSvc.expandVar(expression);
        ScriptEngineManager factory = new ScriptEngineManager();
        ScriptEngine engine = factory.getEngineByName("JavaScript");
        try {
            int notificationCountAfter = Integer.parseInt(transactionAndExceptionsPage.getNotificationCount());
            Integer expectedNotificationCount = (Integer) engine.eval(expandExpression);
            LOGGER.debug("Evaluated value [{}]", expectedNotificationCount);
            if (expectedNotificationCount != notificationCountAfter) {
                LOGGER.error("Notification Occurrence Count: Expected Value [{}], but Actual Value [{}]", expectedNotificationCount, notificationCountAfter);
                throw new CartException(CartExceptionType.VERIFICATION_FAILED, "Notification Occurrence Count: Expected Value [{}], but Actual Value [{}]", expectedNotificationCount, notificationCountAfter);
            }
        } catch (ScriptException e) {
            LOGGER.error("Evaluation Error", e);
            throw new CartException(CartExceptionType.PROCESSING_FAILED, "Evaluation Error");
        }
    }

    public void iCloseTransactionAndException() {
        transactionAndExceptionsPage.closeTransactionAndExceptions();
    }

    public void iExpectTransactionAndExceptionClosed() {
        final String notificationStatusActual = transactionAndExceptionsPage.getNotificationStatus();
        if (!"CLOSED".equals(notificationStatusActual)) {
            LOGGER.error("Transaction and Exception not closed: Expected Value [{}], but Actual Value [{}]", "CLOSED", notificationStatusActual);
            throw new CartException(CartExceptionType.VERIFICATION_FAILED, "Transaction and Exception not closed: Expected Value [{}], but Actual Value [{}]", "CLOSED", notificationStatusActual);
        }
    }
}
