@bdd @xml_bdd
Feature: This feature is to test Xml Steps def code

  Scenario: Assign variables

    Given I assign "target/test-classes/xml/with_attributes.xml" to variable "XML_FILE_1"
    Given I assign "target/test-classes/xml/xpathQuery.xpath" to variable "XPATH_QUERY_FILE_PATH"

  Scenario: Extract xml attribute values into variables

    When I extract attribute values from the xml file "${XML_FILE_1}" and assign to variables:
      | xpath                                   | attributeName | variableName |
      | //Portfolio[@PortfolioId='GLEM1']/Asset | AssetId       | AST_ID       |

    Then I expect the value of var "${AST_ID}" equals to "GLEM1_ESL2242132"

  Scenario: Extract xml values into variables based on query file and query

    When I extract a value from the XML file "${XML_FILE_1}" using XPath query in file "${XPATH_QUERY_FILE_PATH}" to variable "ASSET1"
    And I extract a value from the XML file "${XML_FILE_1}" using XPath query in file "//Portfolios//Portfolio/Asset1" to variable "ASSET2"

    Then I expect the value of var "${ASSET1}" equals to "${ASSET2}"

  Scenario: Extract xml value by tag name without index

    When I extract value from the xml file "${XML_FILE_1}" with tagName "Portfolio1" to variable "PORT1"
    Then I expect the value of var "${PORT1}" equals to "TEST_PORT1"

  Scenario: Extract xml value by tag name with index

    When I extract value from the XML file "${XML_FILE_1}" with tagName "Portfolio1" at index 1 to variable "PORT2"
    Then I expect the value of var "${PORT2}" equals to "TEST_PORT2"

  Scenario: Extract xml value by xpath name without index

    When I extract value from the xml file "${XML_FILE_1}" with xpath "//Portfolio1" to variable "PORT1"
    Then I expect the value of var "${PORT1}" equals to "TEST_PORT1"

  Scenario: Extract xml value by xpath name with index

    When I extract value from the XML file "${XML_FILE_1}" with xpath "//Portfolio1" at index 1 to variable "PORT2"
    Then I expect the value of var "${PORT2}" equals to "TEST_PORT2"










