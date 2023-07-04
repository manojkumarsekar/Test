package stepdefinitions.Solvency;

import com.eastspring.qa.cart.core.exceptions.CartException;
import com.eastspring.qa.cart.core.exceptions.CartExceptionType;
import io.cucumber.java.en.Given;
import io.cucumber.java.en.When;
import com.eastspring.qa.solvency.lookup.ReportType;
import com.eastspring.qa.solvency.utils.business.ValidationReportFileUtil;

public class HomeSteps extends BaseSolvencySteps {

    @Given("the user launch Solvency app")
    public void launchApp() {
        homePage.launchApp();
        if (!homePage.isPageDisplayed()){
            throw new CartException(CartExceptionType.ASSERTION_ERROR, "Solvency home page is not displayed");
        }
    }

    @When("^the user navigate from home to Lbu upload (.+) page$")
    public void navigateToLbuUploadPage(String reportName) {
        homePage.selectLBUUpload();
        if(!homePage.isSelectPortfolioDisplayed())
        {
            homePage.selectLBUUpload();
        }
        homePage.selectTabMenu(reportName);
        if (!lbuUploadPage.isPageDisplayed()){
            throw new CartException(CartExceptionType.ASSERTION_ERROR, "Solvency LBU portfolio page is not displayed");
        }
    }

    @When("^the user navigate from home to validation (.+) page$")
    public void navigateToValidationPage(String reportName) {
        ReportType reportType = ValidationReportFileUtil.lookupReportType(reportName);
        homePage.selectValidation();
        if(!homePage.isSelectValidationDisplayed())
        {
            homePage.selectValidation();
        }
        homePage.selectMenu(reportType.uiText);
        if (!validationPage.isPageDisplayed()){
            throw new CartException(CartExceptionType.ASSERTION_ERROR, "Solvency Validation portfolio page is not displayed");
        }
    }

    @When("^the user navigate from home to Report (.+) page$")
    public void navigateToReportPage(String reportName) {
        ReportType reportType = ValidationReportFileUtil.lookupReportType(reportName);
        homePage.selectReports();
        if(!homePage.isSelectReportsDisplayed())
        {
            homePage.selectReports();
        }
        homePage.selectMenu(reportType.uiText);
        if (!validationPage.isPageDisplayed()){
            throw new CartException(CartExceptionType.ASSERTION_ERROR, "Solvency Validation portfolio page is not displayed");
        }
    }

    @When("^the user navigate from home to Data Upload (.+) page$")
    public void navigateToDataUploadPage(String reportName) {
        ReportType reportType = ValidationReportFileUtil.lookupReportType(reportName);
        homePage.selectDataUpload();
        if(!homePage.isSelectDataUploadDisplayed())
        {
            homePage.selectDataUpload();
        }
        homePage.selectMenu(reportType.uiText);

        if (!validationPage.isPageDisplayed()){
            throw new CartException(CartExceptionType.ASSERTION_ERROR, "Solvency Validation portfolio page is not displayed");
        }
    }

}