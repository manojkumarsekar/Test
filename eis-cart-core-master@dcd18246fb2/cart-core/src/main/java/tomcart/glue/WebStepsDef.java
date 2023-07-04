package tomcart.glue;

import com.eastspring.tom.cart.core.CartBootstrap;
import com.eastspring.tom.cart.core.steps.WebSteps;
import cucumber.api.java8.En;

/**
 * @author Daniel Baktiar
 * @since 2017-09
 */
public class WebStepsDef implements En {

    private WebSteps webSteps = (WebSteps) CartBootstrap.getBean(WebSteps.class);


    public WebStepsDef() {

        // wiki documented
        Then("I pause for {int} seconds", (Integer seconds) -> webSteps.pauseForSeconds(seconds));

        Then("I pause for {string} seconds", (String seconds) -> webSteps.pauseForSecondsWithVar(seconds));

        Then("I switch to the next browser tab", () -> webSteps.switchToNextBrowserTab());


        // wiki documented
        Then("I move the downloaded file with name {string} to test evidence folder {string}",
                (String filename, String destLocation) ->
                        webSteps.moveDownloadedFileToTestEvidenceDir(filename, destLocation));

        Then("I click the web element with xpath {string} on browser window that has web element with xpath {string}",
                (String toClickWebElementXPath, String windowSelectorXPath) ->
                        webSteps.clickXPathWhenOnWindowThatHasXPath(toClickWebElementXPath, windowSelectorXPath));

        Then("I perform selection of the visible text {string} on web element {string}", (String visibleText, String webElementId) ->
                webSteps.selectVisibleText(visibleText, webElementId));

        ///////////////////////////////////////////////////////////////////////////////////////////////
        // HIGH LEVEL WEB OPERATIONS - BUSINESS USERS NOT ASSUMING THEY KNOW HOW TO OPERATES BROWSER
        // --
        // I open the STAR Compliance application, etc. - no descriptions on the underlying technology (web application)

        ///////////////////////////////
        // HIGH LEVEL WEB OPERATIONS

        Then("I take a screenshot", () -> webSteps.takeScreenshot());

        //It internally does driver.quit, which leads to closing Driver instance
        Then("I close all opened web browsers", () -> webSteps.closeAllOpenBrowsers());

        //It does driver.close, just closing the browser instance
        Then("I close web browsers instance", () -> webSteps.closeBrowserInstance());

        Given("I open a web session from URL {string}", (String url) -> webSteps.openWebUrl(url));

        ///////////////////////////////////////////////////////////////
        // MEDIUM LEVEL WEB OPERATIONS - I need to know how CART configuration

        When("I open a web session from web configuration {string}",
                (String webConfigName) -> webSteps.openSessionByWebConfigName(webConfigName));

        Then("I click on the named web element {string}",
                (String propKey) -> webSteps.clickByPropKey(propKey));


        ///////////////////////////////////////////////////////////////////////////////////////////////
        // LOW LEVEL WEB OPERATIONS - I know DOM id/name/class, CSS, and probably a bit of Javascript!

        When("I click the web element {string}", (String webElement) -> webSteps.clickOp(webElement));

        When("I right click the web element {string}", (String webElement) -> webSteps.rightClickOp(webElement, true));

        When("I enter the text {string} into web element with id {string}",
                (String text, String webElementId) -> webSteps.enterTextIntoById(text, webElementId));

        When("I enter the text {string} into web element {string} followed by {string} key",
                (String text, String webElement, String followingKey) -> webSteps.enterTextIntoGeneric(text, webElement, true, followingKey, 30));

        When("I enter the text {string} into web element {string}",
                (String text, String webElement) -> webSteps.enterTextIntoGeneric(text, webElement, true, null, 30));

        When("I enter below text into web element {string}",
                (String webElement, String docString) -> webSteps.enterTextIntoGeneric(docString, webElement, true, null, 30));


        When("I assign the {string} attribute of element {string} to {string}",
                (String attribute, String locator, String variable) -> webSteps.readAttributeFromLocator(attribute, locator, variable));

        When("I expect the {string} attribute of element {string} equals to {string}",
                (String attribute, String locator, String expectedValue) -> webSteps.verifyAttributeFromLocator(attribute, locator, expectedValue));

        When("I click the web element with id {string}", (String webElementId) -> webSteps.clickById(webElementId));

        When("I submit the web element {string}", (String opOnWebElement) -> webSteps.submit(opOnWebElement));

        When("I click the web element with CSS class {string}",
                (String cssClass) -> webSteps.clickByCss(cssClass));

        When("I click using Javascript the web element with xpath {string}",
                (String xpath) -> webSteps.clickXPathUsingJavascript(xpath));

        Then("I click the web element with xpath {string}", (String xpath) -> webSteps.clickByXpath(xpath));

        Then("I expect to see the web element with xpath {string}",
                (String xpath) -> webSteps.webElementByXPathShown(xpath));

        Then("I expect to see the web element with id {string}",
                (String webElementId) -> webSteps.webElementByIdShown(webElementId));

        Given("I set the web configuration of {string} from properties with prefix {string}",
                (String webConfigName, String propPrefix) -> webSteps.setWebConfigToPropPrefix(webConfigName, propPrefix));

        Then("I save the downloaded file {string} to location {string}",
                (String downloadedFileName, String destDir) -> webSteps.moveDownloadedFileToTestEvidenceDir(downloadedFileName, destDir));

        ///////////////////////////////////////////
        // EXPOSES SOME LOW LEVEL WEB DRIVER API

        Then("I assign current browser window handle name to variable {string}", (String varName) -> webSteps.assignCurrentBrowserWindowHandleNameToVar(varName));


        Then("I wait maximum {int} seconds for the element {string} to appear", (Integer maxTimeToWait, String webElement) ->
                webSteps.waitMaxTimeForTheElementToAppear(maxTimeToWait, webElement, true)
        );

        When("I scroll the web element {string} into view", (String webElement) -> webSteps.scrollElementIntoView(webElement));


    }
}
