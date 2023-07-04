package tomcart.glue;

import com.eastspring.tom.cart.core.CartBootstrap;
import com.eastspring.tom.cart.core.steps.XmlValidationSteps;
import com.eastspring.tom.cart.core.utl.DataTableUtil;
import cucumber.api.java.en.Then;
import cucumber.api.java.en.When;
import cucumber.api.java8.En;
import io.cucumber.datatable.DataTable;

public class XmlStepsDef implements En {

    private XmlValidationSteps steps = (XmlValidationSteps) CartBootstrap.getBean(XmlValidationSteps.class);
    private DataTableUtil dataTableUtil = (DataTableUtil) CartBootstrap.getBean(DataTableUtil.class);

    @When( "I assign count of child nodes {string} under node xpath {string} from the (xml|XML) file {string} to variable {string}" )
    public void readChildNodeCount(final String childNodeName, final String parentNodeXpath, final String xmlFile, final String varName) {
        steps.assignChildNodesCountToVariable(xmlFile, parentNodeXpath, childNodeName, varName);
    }

    @Then( "I expect element count from the (xml|XML) file {string} by xpath {string} should be {int}" )
    public void verifyXmlElementCountByXpath(final String xmlFile, final String xpath, final int expectedCount) {
        steps.verifyXmlElementCountByXpath(xmlFile, xpath, expectedCount);
    }

    public XmlStepsDef() {

        When("I extract attribute values from the (xml|XML) file {string} and assign to variables:", (final String xmlFile, final DataTable dataTable) ->
                steps.extractAttributeValueFromXmlUsingXpathToVar(xmlFile, dataTableUtil.getListOfMaps(dataTable)));

        Then("I extract a value from the (xml|XML) file {string} using XPath query in file {string} to variable {string}", (final String xmlFile, final String xpathFile, final String varName) ->
                steps.extractSingleValueFromXmlFileUsingXPathToVar(xmlFile, xpathFile, varName, 0)
        );

        Then("I expect value from (xml|XML) file {string} with tagName {string} should be {string}", (final String xmlFile, final String tagName, final String expectedResult) ->
                steps.verifyTagValueInXml(xmlFile, tagName, expectedResult)
        );

        Then("I expect value from (xml|XML) file {string} with xpath {string} should be {string}", (final String xmlFile, final String xpath, final String expectedResult) ->
                steps.verifyXpathValueInXml(xmlFile, xpath, expectedResult)
        );

        Then("I extract value from the (xml|XML) file {string} with tagName {string} to variable {string}", (final String xmlFile, final String tagName, final String varName) ->
                steps.extractValueFromXmlUsingTagNameToVar(xmlFile, tagName, varName, 0)
        );

        Then("I extract value from the (xml|XML) file {string} with tagName {string} at index {int} to variable {string}", (final String xmlFile, final String tagName, final Integer index, final String varName) ->
                steps.extractValueFromXmlUsingTagNameToVar(xmlFile, tagName, varName, index)
        );

        Then("I extract value from the (xml|XML) file {string} with xpath {string} at index {int} to variable {string}", (final String xmlFile, final String xpathQuery, final Integer index, final String varName) ->
                steps.extractSingleValueFromXmlFileUsingXPathToVar(xmlFile, xpathQuery, varName, index)
        );

        Then("I extract value from the (xml|XML) file {string} with xpath {string} to variable {string}", (final String xmlFile, final String xpathQuery, final String varName) ->
                steps.extractSingleValueFromXmlFileUsingXPathToVar(xmlFile, xpathQuery, varName, 0)
        );

        Then("I extract below values from the (xml|XML) file {string}  with xpath or tagName at index {int} and assign to variables:", (final String xmlFile, final Integer index, final DataTable dataTable) ->
                steps.extractValuesFromXmlFileUsingTagOrXpathToVar(xmlFile, index, dataTableUtil.getTwoColumnAsMap(dataTable)));

    }
}
