package com.eastspring.tom.cart.dmp.pages.myworklist;

import com.eastspring.tom.cart.core.steps.WebSteps;
import com.eastspring.tom.cart.core.svc.StateSvc;
import com.eastspring.tom.cart.core.svc.ThreadSvc;
import com.eastspring.tom.cart.core.svc.WebTaskSvc;
import com.eastspring.tom.cart.core.utl.FormatterUtil;
import com.eastspring.tom.cart.dmp.pages.HomePage;
import com.eastspring.tom.cart.dmp.steps.DmpGsPortalSteps;
import com.eastspring.tom.cart.dmp.utl.DmpGsPortalUtl;
import org.openqa.selenium.*;
import org.openqa.selenium.support.ui.ExpectedConditions;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;

import static com.eastspring.tom.cart.constant.CommonLocators.*;
import static com.eastspring.tom.cart.dmp.utl.DmpGsPortalUtl.MAX_RETRIES;

public class MyWorkListPage {
    private static final Logger LOGGER = LoggerFactory.getLogger(MyWorkListPage.class);

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

    public static final String GS_WORKLIST_MYWORKLIST_SUBMENU = "//span[@class='v-button-caption'][text()='My Worklist']/ancestor::div[contains(@class,'v-button-gsSubMenu')]";
    public static final String GS_WORKLIST_MYWORKLIST_COMPLETE_BUTTON = "//span[text()='Complete']/../..";
    public static final String GS_WORKLIST_MYWORKLIST_REJECT_BUTTON = "xpath://span[text()='Reject']/../..";
    public static final String GS_WORKLIST_MYWORKLIST_CLOSE_BUTTON = "xpath://span[text()='Close']/../..";
    public static final String GS_WORKLIST_MYWORKLIST_REASSIGN_BUTTON = "xpath://span[text()='Re-Assign']/../..";


    public MyWorkListPage navigateToMyWorkList() {
        homePage.clickMenuDropdown();
        homePage.selectMenu("My Worklist");

        webTaskSvc.getWebDriverWait(200)
                .ignoring(StaleElementReferenceException.class)
                .ignoring(WebDriverException.class)
                .until(ExpectedConditions.elementToBeClickable(By.xpath(GS_WORKLIST_MYWORKLIST_SUBMENU)))
                .click();

        threadSvc.sleepMillis(1000);
        homePage.verifyGSTabDisplayed("My Worklist");
        return this;
    }


    public MyWorkListPage filterMyWorkListWithEntityId(final String value) {
        dmpGsPortalUtl.filterTable("Main Entity Id", value, false);
        return this;
    }

    public MyWorkListPage filterMyWorkListWithEntityName(final String value) {
        dmpGsPortalUtl.filterTable("Main Entity Name", value, false);
        return this;
    }

    public MyWorkListPage filterMyWorkListWithTaskStatus(final String value) {
        dmpGsPortalUtl.filterTable("Task Status", value, true);
        threadSvc.sleepSeconds(1);
        return this;
    }

    //Customized with Retries as it tend to fail because of synchronization issues
    public MyWorkListPage openRecordToAuthorize(final String recordIdentifier) {
        dmpGsPortalUtl.waitTillTableRowCount(GS_DATA_TABLE_XPATH, 1);
        dmpGsPortalUtl.openRecord(GS_DATA_TABLE_ROW, recordIdentifier);
        threadSvc.sleepSeconds(2);

        WebElement element;
        int retry = 0;
        do {
            webTaskSvc.setImplicitWait(5);
            element = webTaskSvc.getWebDriverWait(60).ignoring(NoSuchElementException.class)
                    .ignoring(StaleElementReferenceException.class).until(ExpectedConditions.elementToBeClickable(By.xpath(GS_WORKLIST_MYWORKLIST_COMPLETE_BUTTON)));
            webTaskSvc.setDefaultImplicitWait();
            if (element == null) {
                LOGGER.debug("Retrying OpenRecord to Act on it...");
                dmpGsPortalUtl.openRecord(GS_DATA_TABLE_ROW, recordIdentifier);
                threadSvc.sleepSeconds(2);
            }
            retry++;
        } while (element == null && retry <= MAX_RETRIES * 2);
        return this;
    }

    public void authorizeRequest() {
        webTaskSvc.clickXPath(GS_WORKLIST_MYWORKLIST_COMPLETE_BUTTON);
        dmpGsPortalUtl.inputText(GS_MYWORKLIST_COMMENTS, "Authorized by automation user", "", true);
        threadSvc.sleepSeconds(1);
        webTaskSvc.click(GS_COMPLETE_COMMENTS_BUTTON);
        webTaskSvc.waitForElementDisappear(GS_COMPLETE_COMMENTS_BUTTON, 360);
    }

    public void rejectRequest() {
        webTaskSvc.click(GS_WORKLIST_MYWORKLIST_REJECT_BUTTON);
        dmpGsPortalUtl.inputText(GS_MYWORKLIST_COMMENTS, "Rejected by automation user", "", true);
        threadSvc.sleepSeconds(1);
        webTaskSvc.click(GS_REJECT_COMMENTS_BUTTON);
        webTaskSvc.waitForElementDisappear(GS_REJECT_COMMENTS_BUTTON, 360);
    }

    public void reassignRequest(String reassign) {
        webTaskSvc.click(GS_WORKLIST_MYWORKLIST_REASSIGN_BUTTON);
        dmpGsPortalUtl.inputText(GS_MYWORKLIST_REASSSIGN, reassign, "ENTER", true);
        dmpGsPortalUtl.inputText(GS_MYWORKLIST_COMMENTS, "Reassigned by automation user", "", true);
        threadSvc.sleepSeconds(1);
        webTaskSvc.click(GS_REASSIGN_COMMENTS_BUTTON);
        webTaskSvc.waitForElementDisappear(GS_REASSIGN_COMMENTS_BUTTON, 360);
    }

    public void closeRequest() {
        webTaskSvc.click(GS_WORKLIST_MYWORKLIST_CLOSE_BUTTON);
        dmpGsPortalUtl.inputText(GS_MYWORKLIST_COMMENTS, "Closed by automation user", "", true);
        threadSvc.sleepSeconds(1);
        webTaskSvc.click(GS_CLOSE_COMMENTS_BUTTON);
        webTaskSvc.waitForElementDisappear(GS_CLOSE_COMMENTS_BUTTON, 360);
    }

    public boolean isNotificationDisplayed() {

        WebElement notification = webTaskSvc.getWebElementRef(GS_NOTIFICATION_CAPTION);
        Integer counter = 0;

        while (notification == null && counter <= 30) {
            notification = webTaskSvc.getWebElementRef(GS_COMPLETE_COMMENTS_BUTTON);
            counter++;
        }
        return notification != null;
    }

}
