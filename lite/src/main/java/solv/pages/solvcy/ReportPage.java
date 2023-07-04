package com.eastspring.qa.solvency.pages.solvency;

import org.openqa.selenium.By;

public class ReportPage extends BaseSolvencyPage {

    private static class Locators {
        protected static final By btnSubmit = By.xpath("//a[@id='ctl00_ContentPlaceHolder1_btnSubmit']");
    }

    public void clickSubmitButton() {

        clickElement(ReportPage.Locators.btnSubmit);
    }


}