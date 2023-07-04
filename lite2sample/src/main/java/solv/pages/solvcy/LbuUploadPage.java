package com.eastspring.qa.solvency.pages.solvency;

import com.eastspring.qa.cart.core.configmanagers.AppConfigManager;
import org.openqa.selenium.By;
import org.springframework.beans.factory.annotation.Autowired;


public class LbuUploadPage extends BaseSolvencyPage {

    @Autowired
    private AppConfigManager appConfigManager;

    private static class Locators {
        public static final String windowUrl = "solvencyAzurePreprod";
        protected static final By edtFilePath = By.xpath("//input[@id='ctl00_ContentPlaceHolder1_UploadedFile']");
        protected static final By tblLBUDetails = By.xpath("//th[@key='LBU']");
    }

    public boolean isPageDisplayed() {
        fluentWaitUntilVisible(Locators.edtFilePath);
        return isFileFieldDisplayed();
    }

    public void switchToWindow() {
        switchToWindowByURL(Locators.windowUrl, true);
    }

    public boolean isFileFieldDisplayed() {
        return isElementVisible(Locators.edtFilePath);
    }

    public void setFilePath(String filePath) {
        sendKeys(Locators.edtFilePath, filePath);
    }

    public boolean isLBUDetailTableDisplayed() {
        return isElementVisible(Locators.tblLBUDetails);
    }


}