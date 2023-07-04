package com.eastspring.qa.solvency.pages.solvency;


import com.eastspring.qa.cart.core.configmanagers.AppConfigManager;
import com.eastspring.qa.cart.core.configmanagers.RunConfigManager;
import org.openqa.selenium.By;
import org.springframework.beans.factory.annotation.Autowired;

import java.util.*;

public class DataUploadPage extends BaseSolvencyPage {

    @Autowired
    private AppConfigManager appConfigManager;
    public int DEFAULT_PAGE_WAIT_SECONDS = RunConfigManager.Web.PAGE_TIMEOUT_SECONDS;

    private static class Locators {
        protected static final By selectMonth = By.xpath("//select[@id='ctl00_ContentPlaceHolder1_lstFile']");
        protected static final By btnViewData = By.xpath("//a[@id='btnDisplay']");
        protected static final By btnUpload = By.xpath("//a[@id='btnUpload']");

    }

    public void lstMonth(String porfolioDataUploadName) {
        selectItemBy(DataUploadPage.Locators.selectMonth, SELECT_ACTION.VISIBLE_TEXT, porfolioDataUploadName);
    }


    public void clickViewDataButton() {
        clickElement(DataUploadPage.Locators.btnViewData);
    }

    public void waitUntilUploadButton() {
        fluentWaitUntilVisible(Locators.btnUpload);
    }

    public void clickUploadButton() {

        clickElement(DataUploadPage.Locators.btnUpload);


    }

    public void waitForAlertOkButton() {
        waitForAlertAndSwitch(DEFAULT_PAGE_WAIT_SECONDS).accept();
    }

    public static List<LinkedHashMap<String, String>> removeColumns(List<LinkedHashMap<String, String>> records, String colName) {
        records.forEach(map -> map.keySet().removeIf(colName::contains));
        return records;
    }

}