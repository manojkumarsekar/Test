package com.eastspring.tom.cart.dmp.pages;

import com.eastspring.tom.cart.core.CartException;
import com.eastspring.tom.cart.core.CartExceptionType;
import com.eastspring.tom.cart.core.steps.WebSteps;
import com.eastspring.tom.cart.core.svc.ThreadSvc;
import com.eastspring.tom.cart.core.svc.WebTaskSvc;
import com.eastspring.tom.cart.core.utl.FormatterUtil;
import com.eastspring.tom.cart.dmp.utl.DmpGsPortalUtl;
import org.openqa.selenium.By;
import org.openqa.selenium.NoSuchElementException;
import org.openqa.selenium.StaleElementReferenceException;
import org.openqa.selenium.WebElement;
import org.openqa.selenium.support.ui.ExpectedConditions;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import com.eastspring.tom.cart.dmp.pages.customer.master.AccountMasterPage;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.Map;
import java.util.Set;

import static com.eastspring.tom.cart.constant.CommonLocators.*;
import static com.eastspring.tom.cart.dmp.mdl.GSUIFields.*;

public class LockFieldsAndEntityPage {

    private static final Logger LOGGER = LoggerFactory.getLogger(LockFieldsAndEntityPage.class);
    public static final String ENTER = "ENTER";

    //region Bean Declaration
    @Autowired
    private FormatterUtil formatter;

    @Autowired
    private WebTaskSvc webTaskSvc;

    @Autowired
    private DmpGsPortalUtl dmpGsPortalUtl;

    @Autowired
    private HomePage homePage;

    @Autowired
    private ThreadSvc threadSvc;

    @Autowired
    private WebSteps webSteps;

    @Autowired
    private AccountMasterPage accountMasterPage;

    public static final String GS_LOCK_MENUBAR_POPUP = "xpath://div[@class='v-menubar-popup']";
    public static final String GS_LOCK_MENUBAR_POPUP_NORMAL_LOCK = GS_LOCK_MENUBAR_POPUP + "//span[text()='Normal Lock']";
    public static final String GS_LOCK_MENUBAR_POPUP_PERPETUAL_LOCK = GS_LOCK_MENUBAR_POPUP + "//span[text()='Perpetual Lock']";
    public static final String GS_LOCK_MENUBAR_POPUP_REMOVE_LOCK = GS_LOCK_MENUBAR_POPUP + "//span[text()='Remove Lock']";
    public static final String GS_LOCK_MENUBAR_POPUP_RECORD_LOCK = GS_LOCK_MENUBAR_POPUP + "//span[text()='Record Lock']";

    public static final String GS_LOCKTYPE_COMMENTS = "xpath://div[@class='popupContent']//span[contains(text(),'Lock Type')]/..//following-sibling::textarea";

    public static final String GS_LOCK_FIELD = "xpath://div[contains(@class,'v-horizontallayout-gsFieldMargin')]//div[contains(text(),'%s')]/../..//*[contains(@class,'textarea') or contains(@class,'textfield')]";

    public static final String GS_LOCK_NORMAL_LOCK_ICON = "xpath://div[contains(@class,'v-caption-gsYellowIcon')]//span[@class='v-icon FontAwesome']";
    public static final String GS_LOCK_PERPETUAL_LOCK_ICON = "xpath://div[contains(@class,'v-caption-gsRedIcon')]//span[@class='v-icon FontAwesome']";
    public static final String GS_LOCK_RECORD_LOCK_ICON = "xpath://div[contains(@class,'v-caption-gsBlueIcon')]//span[@class='v-icon FontAwesome']";

    public static final String GS_LOCK_ENTITY_LOCK_MSG = "xpath://span[contains(text(),'Entity is Locked')]";

    public void lockEntity() {
        try {
            webTaskSvc.click(GS_OTHERS_MENU_BUTTON);
            threadSvc.sleepSeconds(1);
            webTaskSvc.click(GS_OTHERS_LOCK_BUTTON);
            By commentsElement = webTaskSvc.getByReference(GS_POPUP_LOCK_COMMENT_TEXTFIELD);

            webTaskSvc.getWebDriverWait(120)
                    .ignoring(StaleElementReferenceException.class)
                    .ignoring(NoSuchElementException.class)
                    .until(ExpectedConditions.elementToBeClickable(commentsElement));
            threadSvc.sleepSeconds(2);
            dmpGsPortalUtl.inputText(GS_POPUP_LOCK_COMMENT_TEXTFIELD, "Locked By Automation user", ENTER, true);
            webTaskSvc.click(GS_POPUP_CONTENT_SAVE_BUTTON);
            By by = webTaskSvc.getByReference(GS_POPUP_CONTENT_SAVE_BUTTON);
            webTaskSvc.getWebDriverWait(180)
                    .until(ExpectedConditions.invisibilityOfElementLocated(by));
            dmpGsPortalUtl.waitTillSuccessNotificationMessageAppears();
        } catch (Exception e) {
            final String activeScreenName = dmpGsPortalUtl.getActiveScreenName();
            LOGGER.error("Unable to Lock Entity in Screen [{}]", activeScreenName, e);
            throw new CartException(CartExceptionType.PROCESSING_FAILED, "Unable to Lock Entity in Screen [{}]", activeScreenName);
        }
    }

    public void unLockEntity() {
        try {
            webTaskSvc.click(GS_OTHERS_MENU_BUTTON);
            threadSvc.sleepSeconds(1);
            By unLockElementRef = webTaskSvc.getByReference(GS_OTHERS_UNLOCK_BUTTON);
            webTaskSvc.getWebDriverWait(60)
                    .ignoring(StaleElementReferenceException.class)
                    .ignoring(NoSuchElementException.class)
                    .until(ExpectedConditions.elementToBeClickable(unLockElementRef));
            webTaskSvc.click(GS_OTHERS_UNLOCK_BUTTON);
            webTaskSvc.getWebDriverWait(180)
                    .until(ExpectedConditions.invisibilityOfElementLocated(unLockElementRef));
            dmpGsPortalUtl.waitTillSuccessNotificationMessageAppears();
        } catch (Exception e) {
            final String activeScreenName = dmpGsPortalUtl.getActiveScreenName();
            LOGGER.error("Unable to UnLock Entity in Screen [{}]", activeScreenName, e);
            throw new CartException(CartExceptionType.PROCESSING_FAILED, "Unable to UnLock Entity in Screen [{}]", activeScreenName);
        }
    }

    public void AddLockOnField(String lockType, String fieldName) {
        String iconType = null;
        try {
            String xpath = formatter.format(GS_LOCK_FIELD, fieldName);
            webSteps.rightClickOp(xpath, false);
            By lockElementRef = webTaskSvc.getByReference(GS_LOCK_MENUBAR_POPUP_NORMAL_LOCK);
            webTaskSvc.getWebDriverWait(60)
                    .ignoring(StaleElementReferenceException.class)
                    .ignoring(NoSuchElementException.class)
                    .until(ExpectedConditions.elementToBeClickable(lockElementRef));

            if (lockType.toLowerCase().contains("normal")) {
                webTaskSvc.click(GS_LOCK_MENUBAR_POPUP_NORMAL_LOCK);
                iconType = GS_LOCK_NORMAL_LOCK_ICON;
            } else if (lockType.toLowerCase().contains("perpetual")) {
                webTaskSvc.click(GS_LOCK_MENUBAR_POPUP_PERPETUAL_LOCK);
                iconType = GS_LOCK_PERPETUAL_LOCK_ICON;
            } else if (lockType.toLowerCase().contains("record")) {
                webTaskSvc.click(GS_LOCK_MENUBAR_POPUP_RECORD_LOCK);
                iconType = GS_LOCK_RECORD_LOCK_ICON;
            } else {
                LOGGER.error("Undefined Lock type[{}]", lockType);
            }

            By commentsElementRef = webTaskSvc.getByReference(GS_LOCKTYPE_COMMENTS);
            webTaskSvc.getWebDriverWait(60)
                    .ignoring(StaleElementReferenceException.class)
                    .ignoring(NoSuchElementException.class)
                    .until(ExpectedConditions.elementToBeClickable(commentsElementRef));
            dmpGsPortalUtl.inputText(GS_LOCKTYPE_COMMENTS, "Locked By Automation user", ENTER, true);

            webTaskSvc.click(GS_POPUP_CONTENT_SAVE_BUTTON);
            webTaskSvc.getWebDriverWait(180)
                    .until(ExpectedConditions.invisibilityOfElementLocated(commentsElementRef));
            By by = webTaskSvc.getByReference(iconType);
            webTaskSvc.waitForElementToAppear(by, 60);
        } catch (Exception e) {
            final String activeScreenName = dmpGsPortalUtl.getActiveScreenName();
            LOGGER.error("Unable to add Lock type [{}] on field [{}] in Screen [{}]", lockType, fieldName, activeScreenName, e);
            throw new CartException(CartExceptionType.PROCESSING_FAILED, "Unable to add Lock type [{}] on field [{}] in Screen [{}]", lockType, fieldName, activeScreenName, e);
        }
    }


    public void removeLockOnField(String fieldName) {
        try {
            String xpath = formatter.format(GS_LOCK_FIELD, fieldName);
            webSteps.rightClickOp(xpath, false);
            By lockElementRef = webTaskSvc.getByReference(GS_LOCK_MENUBAR_POPUP_NORMAL_LOCK);
            webTaskSvc.getWebDriverWait(60)
                    .ignoring(StaleElementReferenceException.class)
                    .ignoring(NoSuchElementException.class)
                    .until(ExpectedConditions.elementToBeClickable(lockElementRef));

            webTaskSvc.click(GS_LOCK_MENUBAR_POPUP_REMOVE_LOCK);
            webTaskSvc.getWebDriverWait(180)
                    .until(ExpectedConditions.invisibilityOfElementLocated(lockElementRef));
            webTaskSvc.waitForElementDisappear(GS_LOCK_NORMAL_LOCK_ICON, 60);
        } catch (Exception e) {
            final String activeScreenName = dmpGsPortalUtl.getActiveScreenName();
            LOGGER.error("Unable to Remove Lock on field [{}] in Screen [{}]", fieldName, activeScreenName, e);
            throw new CartException(CartExceptionType.PROCESSING_FAILED, "Unable to Remove Lock on field [{}] in Screen [{}]", fieldName, activeScreenName, e);
        }
    }

    public boolean isFieldLocked(String lockType) {
        try {
            boolean isFieldLocked = false;
            if (lockType.toLowerCase().contains("normal")) {
                isFieldLocked = webTaskSvc.getWebElementRef(GS_LOCK_NORMAL_LOCK_ICON).isDisplayed();
            } else if (lockType.toLowerCase().contains("perpetual")) {
                isFieldLocked = webTaskSvc.getWebElementRef(GS_LOCK_PERPETUAL_LOCK_ICON).isDisplayed();
            }
            return isFieldLocked;
        } catch (Exception e) {
            LOGGER.error("Field is not locked using lock type {}", lockType, e);
            throw new CartException(CartExceptionType.EXPECTED_WEBELEMENT_DOESNT_EXIST, "Field is not locked using lock type {}", lockType, e);
        }
    }

    public boolean isEntityLocked() {
        WebElement lockMsg = webTaskSvc.getWebElementRef(GS_LOCK_ENTITY_LOCK_MSG);
        if (lockMsg != null) {
            return lockMsg.isDisplayed();
        } else {
            return false;
        }
    }

    public boolean isRecordLocked(String actionType) {
        int noOfLockIconsDisplayed = webTaskSvc.findElementsByXPath(GS_LOCK_RECORD_LOCK_ICON.replace("xpath:", "")).size();
        return actionType.equals("locked")
                ?webTaskSvc.getWebElementRef(GS_LOCK_RECORD_LOCK_ICON).isDisplayed() && noOfLockIconsDisplayed>1
                :noOfLockIconsDisplayed==0;
    }

}
