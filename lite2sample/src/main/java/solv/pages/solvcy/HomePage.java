package com.eastspring.qa.solvency.pages.solvency;

import com.eastspring.qa.cart.core.configmanagers.AppConfigManager;
import com.eastspring.qa.cart.core.exceptions.CartException;
import com.eastspring.qa.cart.core.exceptions.CartExceptionType;
import com.eastspring.qa.cart.core.utils.core.WorkspaceUtil;
import org.openqa.selenium.By;
import org.springframework.beans.factory.annotation.Autowired;

import java.util.function.Predicate;


public class HomePage extends BaseSolvencyPage {

    @Autowired
    private AppConfigManager appConfigManager;

    private static class Locators {
        public static String verticalMenuXpath = "//a[contains(@class,'igdm_Office2007BlackMenuItemVerticalLink')]";
        public static String horizontalMenuXpath = "//a[contains(@class,'igdm_Office2007BlackMenuItemHorizontalRootLink')]";
        protected static final By eltMainMenu = By.xpath(horizontalMenuXpath + "/span[contains(text(),'" + TextMap.LBUFileUpload + "')]");
        protected static final By tabLBUFileUpload = By.xpath(horizontalMenuXpath + "/span[contains(text(),'" + TextMap.LBUFileUpload + "')]");
        protected static final By tabValidation = By.xpath(horizontalMenuXpath + "/span[contains(text(),'" + TextMap.validation + "')]");
        protected static final By menuPortfolio = By.xpath(verticalMenuXpath + "/span[contains(text(),'" + TextMap.portfolioFileUpload + "')]");
        protected static final By menuCIC_D1 = By.xpath(verticalMenuXpath + "/span[contains(text(),'" + TextMap.reportCICD1D20 + "')]");
        protected static final By menuGHOIntegrity = By.xpath(verticalMenuXpath + "/span[contains(text(),'" + TextMap.reportGHOIntegrity + "')]");
        protected static final By menuLBUReports = By.xpath(verticalMenuXpath + "/span[contains(text(),'" + TextMap.LBUReports + "')]");
        protected static final By tabReports = By.xpath(horizontalMenuXpath + "/span[contains(text(),'" + TextMap.reports + "')]");
        protected static final By menuGHOReports = By.xpath(verticalMenuXpath + "/span[contains(text(),'" + TextMap.GHOReport + "')]");
        protected static final By menuRegionalReports = By.xpath(verticalMenuXpath + "/span[contains(text(),'" + TextMap.RegionalReport + "')]");
        protected static final By menuLBUConsolReports = By.xpath(verticalMenuXpath + "/span[contains(text(),'" + TextMap.LBUConsolReport + "')]");
        protected static final By menuPortfolioDataUpload = By.xpath(verticalMenuXpath + "/span[contains(text(),'" + TextMap.PortfolioDataUpload + "')]");
        protected static final By tabDataUpload = By.xpath(horizontalMenuXpath + "/span[contains(text(),'" + TextMap.dataUpload + "')]");
        protected static final By menuPositionDataUpload = By.xpath(verticalMenuXpath + "/span[contains(text(),'" + TextMap.PositionDataUpload + "')]");
        protected static final By menuPosition = By.xpath(verticalMenuXpath + "/span[contains(text(),'" + TextMap.positionFileUpload + "')]");
        protected static final By menuFxRateComparison = By.xpath(verticalMenuXpath + "/span[contains(text(),'" + TextMap.FxRateComparisonReport + "')]");
    }

    private static class TextMap {
        protected static final String reportCICD1D20 = "CIC/D1/D2O";
        protected static final String reportGHOIntegrity = "GHO Integrity";
        protected static final String LBUReports = "LBU Reports";
        protected static final String GHOReportsICP = "GHO Report ICP";
        protected static final String GHOReportsINS = "GHO Report INS";
        protected static final String GHOReportsPOR = "GHO Report POR";
        protected static final String GHOReportsTRP = "GHO Report TRP";
        protected static final String RegionalReport = "Regional Report";
        protected static final String LBUConsolReport = "LBU and Consol data Comparison Reports";
        protected static final String GHOReport = "GHO Report";
        protected static final String PortfolioDataUpload = "Portfolio Data Upload";
        protected static final String PositionDataUpload = "Position Data Upload";
        protected static final String menuPosition = "Position";
        protected static final String menuPortfolio = "Portfolio";
        protected static final String FxRateComparisonReport = "FX Rate Comparison Reports";
        protected static final String dataUpload = "Data Upload";
        protected static final String positionFileUpload = "Position File Upload";
        protected static final String portfolioFileUpload = "Portfolio File Upload";
        protected static final String LBUFileUpload = "LBU File Upload";
        protected static final String validation = "Validation";
        protected static final String reports = "Reports";
    }

    public void launchApp() {
        openWebUrl(appConfigManager.get("solvency.web.UI.url"), true);
    }

    public boolean isPageDisplayed() {
        fluentWaitUntilVisible(Locators.tabLBUFileUpload);
        return isMainMenuDisplayed();
    }

    public boolean isMainMenuDisplayed() {
        return isElementVisible(Locators.eltMainMenu);
    }

    public void selectLBUUpload() {
        clickElement(Locators.tabLBUFileUpload);
    }

    public boolean isSelectPortfolioDisplayed() {

        return isElementVisible(Locators.menuPortfolio);
    }

    public void selectTabMenu(String LBUMenuName) {
        if (TextMap.menuPosition.equalsIgnoreCase(LBUMenuName)) {
            clickElement(Locators.menuPosition);
        } else if (TextMap.menuPortfolio.equalsIgnoreCase(LBUMenuName)) {
            clickElement(Locators.menuPortfolio);
        }
        else{
            throw new CartException(CartExceptionType.INVALID_PARAM,
                    "Select menu is not displayed");
        }
    }

    public boolean isSelectValidationDisplayed() {
        return isElementVisible(Locators.menuCIC_D1);
    }
    public void selectMenu(String reportName) {

        Predicate<String> p = s -> s.equalsIgnoreCase(reportName);

        if (p.test(TextMap.reportCICD1D20)) {
            clickElement(Locators.menuCIC_D1);
        } else if (p.test(TextMap.reportGHOIntegrity)) {
            clickElement(Locators.menuGHOIntegrity);
        } else if (p.test(TextMap.LBUReports)) {
            clickElement(Locators.menuLBUReports);
        } else if (p.test(TextMap.GHOReportsICP) || p.test(TextMap.GHOReportsINS) || p.test(TextMap.GHOReportsPOR) || p.test(TextMap.GHOReportsTRP)) {
            clickElement(Locators.menuGHOReports);
        } else if (p.test(TextMap.RegionalReport)) {
            clickElement(Locators.menuRegionalReports);
        } else if (p.test(TextMap.LBUConsolReport)) {
            clickElement(Locators.menuLBUConsolReports);
        } else if (p.test(TextMap.GHOReport)) {
            clickElement(Locators.menuLBUConsolReports);
        } else if (p.test(TextMap.PortfolioDataUpload)) {
            clickElement(Locators.menuPortfolioDataUpload);
        } else if (p.test(TextMap.PositionDataUpload)) {
            clickElement(Locators.menuPositionDataUpload);
        } else if (p.test(TextMap.FxRateComparisonReport)) {
            clickElement(Locators.menuFxRateComparison);
        } else {
            throw new CartException(CartExceptionType.INVALID_PARAM,
                    "Select menu is not displayed");
        }
    }

    public void selectValidation() {
        clickElement(Locators.tabValidation);
    }

    public void selectCICD1D2OMenu() {
        clickElement(Locators.menuCIC_D1);
    }


    public void selectReports() {
        clickElement(Locators.tabReports);
    }

    public void selectDataUpload() {
        clickElement(Locators.tabDataUpload);
    }

    public boolean isSelectReportsDisplayed() {
        return isElementVisible(Locators.menuLBUReports);
    }

    public boolean isSelectDataUploadDisplayed() {
        return isElementVisible(Locators.menuPortfolioDataUpload);

    }

}