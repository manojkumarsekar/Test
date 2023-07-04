# cart-dmp

# Introduction

Core component that contains Data Management Platform (DMP) test automation code.


#-------------------------------------------------------------------------------
#JIRA: TOM-3047
#-------------------------------------------------------------------------------
As a part of Ticket TOM-3047,
1. TradeLifeCycleUtl.java is written with logic of generating Trade Nuggets (tar.gz) file with sm.xml and transaction.xml
2. TradeLifeCycleUtlRunIT.java is written to cover the integration tests for the methods in above class
3. target/test-classes/tlc contains test files sm.xml and transaction_buy_new_template.xml
4. Build the project: mvn clean install
5. Open TradeLifeCycleUtlRunIT.java class and run @Test: testGenerateTradeNuggets. This method is written to test "generateTradeNuggets" functionality.
6. @Test: testGenerateTradeNuggets method is configured to consume, sm.xml, Tran Type (Ex:BUY) and Tran Status (Ex:NEW)
7. Upon successful execution, esi_ADX_I.<Timestamp>.tar.gz file is created in the set location (Ex:target/test-classes/tlc/nuggets)

Note: Directory to read templates and directory to save trade nuggets file is configured through setter properties.
Ex: tradeNuggetsTemplates.setTradeNuggetsTemplatePath("target/test-classes/tlc");
    tradeNuggetsTemplates.setTradeNuggetsGenerationPath("target/test-classes/tlc/nuggets");
