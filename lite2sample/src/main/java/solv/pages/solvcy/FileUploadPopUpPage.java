package com.eastspring.qa.solvency.pages.solvency;





public class FileUploadPopUpPage extends BaseSolvencyPage {

    private static class Locators {
        protected static final String windowPortfolioSURL = "SolvencyAzurePreprod/LbuPortfolioPopUp.aspx";
        protected static final String windowPositionSURL = "SolvencyAzurePreprod/LbuPositionPopUp.aspx";
    }

    public void close() {
        getDriver().close();
    }

    public void switchToPortfolioWindow() {
        switchToWindowByURL(Locators.windowPortfolioSURL, true);
    }

    public void switchToPositionWindow() {
        switchToWindowByURL(Locators.windowPositionSURL, true);
    }

}