package com.eastspring.tom.cart.dmp.pages.exception.management;

import com.eastspring.tom.cart.core.CartException;
import com.eastspring.tom.cart.core.CartExceptionType;
import com.eastspring.tom.cart.core.steps.WebSteps;
import com.eastspring.tom.cart.core.svc.StateSvc;
import com.eastspring.tom.cart.core.svc.ThreadSvc;
import com.eastspring.tom.cart.core.svc.WebTaskSvc;
import com.eastspring.tom.cart.core.utl.DateTimeUtil;
import com.eastspring.tom.cart.core.utl.FormatterUtil;
import com.eastspring.tom.cart.dmp.pages.HomePage;
import com.eastspring.tom.cart.dmp.steps.DmpGsPortalSteps;
import com.eastspring.tom.cart.dmp.utl.DmpGsPortalUtl;
import org.openqa.selenium.By;
import org.openqa.selenium.WebDriverException;
import org.openqa.selenium.WebElement;
import org.openqa.selenium.support.ui.ExpectedConditions;
import org.openqa.selenium.support.ui.WebDriverWait;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;

import java.util.ArrayList;
import java.util.LinkedHashMap;
import java.util.List;

import static com.eastspring.tom.cart.constant.CommonLocators.GS_POPUP_DATE_SELECTOR;
import static com.eastspring.tom.cart.constant.CommonLocators.GS_POPUP_SET_BUTTON;
import static com.eastspring.tom.cart.constant.CommonLocators.GS_RELOAD_BUTTON;
import static com.eastspring.tom.cart.dmp.utl.DmpGsPortalUtl.MAX_RETRIES;

public class TransactionAndExceptionsPage {

    private static final Logger LOGGER = LoggerFactory.getLogger(TransactionAndExceptionsPage.class);

    @Autowired
    private HomePage homePage;

    @Autowired
    private DmpGsPortalUtl dmpGsPortalUtl;

    @Autowired
    private ThreadSvc threadSvc;

    @Autowired
    private WebSteps webSteps;

    @Autowired
    private WebTaskSvc webTaskSvc;

    @Autowired
    private StateSvc stateSvc;

    @Autowired
    private FormatterUtil formatter;

    @Autowired
    private DmpGsPortalSteps dmpGsPortalSteps;

    @Autowired
    private DateTimeUtil dateTimeUtil;

    public static final String GS_SUBMITTED_MESSAGE_LOCATOR = "xpath://*[@id='Exception.ExceptionDetail.SubmittedMessage.SubmittedMsg']//textarea";
    public static final String GS_NOTIFICATION_OCC_COUNT_LOCATOR = "xpath://*[@id='Exception.ExceptionDetail.NotificationOccurrenceCount']//input";
    public static final String GS_NOTIFICATION_STATUS_LOCATOR = "xpath://*[@id='Exception.ExceptionDetail.NotificationStatus']//input";
    public static final String GS_RESUBMIT_LOCATOR = "xpath://div[contains(@class,'v-button-gsMargin')]//span[text()='Resubmit']/../..";
    public static final String GS_CLOSE_LOCATOR = "xpath://div[contains(@class,'v-button-gsMargin')]//span[text()='Close']/../..";
    public static final String GS_REASSIGN_LOCATOR = "xpath://div[contains(@class,'v-button-gsMargin')]//span[text()='Re-Assign']/../..";
    public static final String GS_REPAIR_LOCATOR = "xpath://div[contains(@class,'v-button-gsMargin')]//span[text()='Repair']/../..";
    public static final String GS_NOTIFICATION_DATE_LOCATOR = "xpath://div[@class='filters-panel']/div[contains(@class,'filterwrapper')][1]";

    private String notificationCountBefore;

    public void setNotificationCountBefore(String notificationCountBefore) {
        this.notificationCountBefore = notificationCountBefore;
    }

    public TransactionAndExceptionsPage navigateToTransactionAndExceptions() {
        LOGGER.debug("Navigating to Transactions and Exceptions Screen");
        homePage.clickMenuDropdown()
                .selectMenu("Exception Management")
                .selectMenu("Transactions & Exceptions");
        homePage.verifyGSTabDisplayed("Transactions & Exceptions");
        return this;
    }

    public void searchTransaction(final LinkedHashMap<String, String> dataMap) {
        List<String> dropdownFields = new ArrayList<>();
        dropdownFields.add("Message Type");
        dropdownFields.add("Notification Status");
        dropdownFields.add("Main Entity Type");
        dropdownFields.add("Default Severity");

        for (String key : dataMap.keySet()) {
            boolean isFiltered;
            if (dropdownFields.contains(key)) {
                isFiltered = dmpGsPortalUtl.filterTable(key, dataMap.get(key), true);
            } else {
                isFiltered = dmpGsPortalUtl.filterTable(key, dataMap.get(key), false);
            }

            if (isFiltered) {
                dmpGsPortalUtl.waitTillFilterIsSuccess(key, dataMap.get(key));
            }
        }
    }


    public TransactionAndExceptionsPage filterNotificationDateWithCurrDate() {
        String formattedDate = dateTimeUtil.getTimestamp("dd-MM-yyyy");
        selectNotificationCreationdate(formattedDate);
        threadSvc.sleepSeconds(2);
        return this;
    }

    public TransactionAndExceptionsPage resubmitTransactionAndExceptions() {
        dmpGsPortalUtl.inputText(GS_SUBMITTED_MESSAGE_LOCATOR, "Test Automation", "ENTER", false);
        threadSvc.sleepSeconds(1);
        webTaskSvc.click(GS_RESUBMIT_LOCATOR);
        webTaskSvc.click(GS_RELOAD_BUTTON);
        this.waitForNotificationCountToReflect(Integer.parseInt(getNotificationCount()));
        threadSvc.sleepSeconds(2);
        return this;
    }

    public String getNotificationCount() {
        return webTaskSvc.getWebElementAttribute(GS_NOTIFICATION_OCC_COUNT_LOCATOR, "value");
    }

    public void waitForNotificationCountToReflect(final int Count) {
        int notificationCount = Integer.parseInt(getNotificationCount());
        int numOfOccurrences = 0;
        while (notificationCount == Count && numOfOccurrences < 30) {
            WebElement element = webTaskSvc.getWebElementRef(GS_RELOAD_BUTTON);
            webTaskSvc.getJavaScriptExecutor().executeScript("arguments[0].click();", element);
            threadSvc.sleepSeconds(1);
            notificationCount = Integer.parseInt(getNotificationCount());
            numOfOccurrences++;
        }
    }

    public String getNotificationStatus() {
        return webTaskSvc.getWebElementAttribute(GS_NOTIFICATION_STATUS_LOCATOR, "value");
    }

    public TransactionAndExceptionsPage closeTransactionAndExceptions() {
        webTaskSvc.click(GS_CLOSE_LOCATOR);
        threadSvc.sleepSeconds(5);
        webTaskSvc.click(GS_RELOAD_BUTTON);
        threadSvc.sleepSeconds(10);
        webTaskSvc.waitForAttributeValueEqualsExpectedValue(GS_NOTIFICATION_STATUS_LOCATOR,"value","CLOSED",30);
        return this;
    }

    private TransactionAndExceptionsPage selectNotificationCreationdate(final String dateStr) {
        try {
            final Integer date = Integer.parseInt(dateStr.substring(0, dateStr.indexOf("-")));
            webTaskSvc.click(GS_NOTIFICATION_DATE_LOCATOR);
            webTaskSvc.click(formatter.format(GS_POPUP_DATE_SELECTOR, date));
            webTaskSvc.click(GS_POPUP_SET_BUTTON);
        } catch (Exception e) {
            LOGGER.error("Error while selecting Date [{}]", dateStr, e);
            throw new CartException(CartExceptionType.PROCESSING_FAILED, "Error while selecting Date [{}]", dateStr);
        }
        return this;
    }
}
