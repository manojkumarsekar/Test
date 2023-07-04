package com.eastspring.qa.solvency.pages.solvency;


import org.openqa.selenium.By;

public class ValidationPage extends BaseSolvencyPage {


    private static class Locators {
        protected static final By selectMonth = By.xpath("//select[@id='ctl00_ContentPlaceHolder1_lstMonth']");
        protected static final By selectYear = By.xpath("//select[@id='ctl00_ContentPlaceHolder1_lstYear']");
        protected static final By selectRegion = By.xpath("//input[@id='ctl00_ContentPlaceHolder1_lstRegion_2']");
        protected static final By selectLBU = By.xpath("//select[@id='ctl00_ContentPlaceHolder1_lstLBU']");
        protected static final By btnGHOIntegritySubmit = By.xpath("//a[@id='btnSubmit']");
        protected static final By selectLBUCOLYear = By.xpath("//select[@name='ctl00$ContentPlaceHolder1$lstYear']");
        protected static final By selectLBUColMonth = By.xpath("//select[@name='ctl00$ContentPlaceHolder1$lstMonth']");
        protected static final By btnSubmit = By.xpath("//a[@id='ctl00_ContentPlaceHolder1_btnSubmit']");

    }

    public boolean isPageDisplayed() {
        waitTillPageLoads();
        return isRegionFieldDisplayed();
    }

    public boolean isRegionFieldDisplayed() {
        return isElementVisible(Locators.selectRegion);
    }

    public void selectRegion() {
        clickElement(Locators.selectRegion);
    }

    public void selectLBU(String LBU)
    {
        selectItemBy(Locators.selectLBU, SELECT_ACTION.VALUE, LBU);
    }

    public void selectMonth(String prevMonth) {
        selectItemBy(Locators.selectMonth, SELECT_ACTION.VISIBLE_TEXT, prevMonth);
    }
    public void lstLBUColYear(String prevMonth) {
        selectItemBy(Locators.selectLBUColMonth, SELECT_ACTION.VISIBLE_TEXT, prevMonth);
    }
    public void selectYear(String year) {
        selectItemBy(Locators.selectYear, SELECT_ACTION.VALUE, year);
    }
    public void selectLBUCOLYear(String year) {
        selectItemBy(Locators.selectLBUCOLYear, SELECT_ACTION.VALUE, year);
    }

    public void waitUntilFileDownload() {

        waitTillPageLoads();
    }
    public void clickGHOIntegritySubmitButton() {

        clickElement(Locators.btnGHOIntegritySubmit);
    }

    public void clickSubmitButton() {
        clickElement(Locators.btnSubmit);
    }

}