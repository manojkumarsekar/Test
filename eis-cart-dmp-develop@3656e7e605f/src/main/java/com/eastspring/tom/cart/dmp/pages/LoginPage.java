package com.eastspring.tom.cart.dmp.pages;

import com.eastspring.tom.cart.core.CartException;
import com.eastspring.tom.cart.core.CartExceptionType;
import com.eastspring.tom.cart.core.svc.WebTaskSvc;
import com.eastspring.tom.cart.dmp.steps.DmpGsPortalSteps;
import com.eastspring.tom.cart.dmp.utl.DmpGsPortalUtl;
import org.openqa.selenium.By;
import org.openqa.selenium.NoSuchElementException;
import org.openqa.selenium.StaleElementReferenceException;
import org.openqa.selenium.support.ui.ExpectedConditions;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;

import java.time.Duration;

public class LoginPage {

    private static final Logger LOGGER = LoggerFactory.getLogger(DmpGsPortalSteps.class);

    public static final String GS_UI_USERNAME_ID = "j_username";
    public static final String GS_UI_PASSWORD_ID = "j_password"; // NOSONAR
    public static final String GS_UI_LOGIN_ID = "login";
    public static final String GS_UI_MENU_DROPDOWN = "//div[contains(@class, 'gsPopupViewMenu')]";
    public static final String LOGIN_IS_NOT_SUCCESSFUL_UNABLE_TO_NAVIGATE_TO_HOME_PAGE = "Login is not Successful, Unable to Navigate to HomePage";

    @Autowired
    private WebTaskSvc webTaskSvc;

    public void enterUserName(final String userName) {
        webTaskSvc.enterTextIntoById(userName, GS_UI_USERNAME_ID);
    }

    public void enterPassword(final String password) {
        webTaskSvc.enterTextIntoById(password, GS_UI_PASSWORD_ID);
    }

    public void clickLoginButton() {
        webTaskSvc.submitId(GS_UI_LOGIN_ID);
    }

    public boolean isLoginSuccessful() {
        try {
            webTaskSvc.getWebDriverWait(10)
                    .ignoring(NoSuchElementException.class)
                    .ignoring(StaleElementReferenceException.class)
                    .pollingEvery(Duration.ofSeconds(1))
                    .until(ExpectedConditions.visibilityOfElementLocated(By.xpath(GS_UI_MENU_DROPDOWN)));
            return true;
        } catch (Exception e) {
            return false;
        }
    }

    public void loginIntoGs(final String username, final String password) {
        By by = webTaskSvc.getByReference("id:" + GS_UI_USERNAME_ID);
        webTaskSvc.waitForElementToAppear(by, 120);
        this.enterUserName(username);
        this.enterPassword(password);
        this.clickLoginButton();

        if (!isLoginSuccessful()) {
            LOGGER.error(LOGIN_IS_NOT_SUCCESSFUL_UNABLE_TO_NAVIGATE_TO_HOME_PAGE);
            throw new CartException(CartExceptionType.VALIDATION_FAILED, LOGIN_IS_NOT_SUCCESSFUL_UNABLE_TO_NAVIGATE_TO_HOME_PAGE);
        }
    }
}
