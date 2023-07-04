eis-cart-lite
Cart-lite is lite and scalable version of "Cart", an In-house Framework For Testing.

Libraries used
SpringBoot framework - for dependency injection
Cucumber
Maven
Selenium
Before you start
Understand Cucumber test frameworks
Understand SpringBoot dependency injection
Understand POM (Page-object-model) and BDD concepts
Setup workstation
Folders
The structure of core framework library is below:

| cart-lite root
|____ cart-lite pom.xml
|____ cart-core root
|____ cart-core-lite pom.xml
|____ src/main
|       |____ java
|       |       |____ com.eastspring.qa.cart
|       |       |       |____ context [Application context from SpringBoot Configuration class]
|       |       |       |____ core  
|       |       |       |       |____ runners [init point for test execution]
|       |       |       |       |____ CartBootStrap  
|       |       |       |       |____ configmanagers
|       |       |       |       |        |____ CoreConfigManager
|       |       |       |       |        |____ RunConfigManager
|       |       |       |       |        |____ AppConfigManager
|       |       |       |       |____ services [consumable libraries for testing]
|       |       |       |       |        |____ web page services and base classes to be inherited by page objects
|       |       |       |       |        |____ database services and base classes to be inherited by db objects
|       |       |       |       |        |____ etc
|       |       |       |       |____ report
|       |       |       |       |        |____ CartLogger
|       |       |       |       |        |____ CucumberHooks [initialize & teardown actions]
|       |       |       |       |____ reusablesteps...
|       |       |       |       |____ utils
|       |       |       |       |        |____ WorkspaceUtil
|       |       |       |       |        |____ TestDataFileUtil
|       |       |       |       |        |____ SecretUtil
|       |       |       |       |        |____ ExcelUtil, CSVUtil
|       |       |       |       |        |____ etc
|       |       |       |       |____ exceptions...
|       |       |       |____ pages [page objects for diagnostic tests]
|       |       |____ stepdefinitions [cucumber step definitions for diagnostic tests]
|       |____ resources
|               |____ config
|                       |____ core-config.properties
|                       |____ run-config.properties
|                       |____ log4j.xml... other config files
|____ src/test [diagnostic tests]
|       |____ features
|       |____ resources
|               |____ config
|               |        |____ app-config-<env-lowercase-shortname>.properties
|               |____ testdata [contain test data files, subcategorized by env short names]
|               |        |____ common
|               |        |____ <env-1>
|               |        |____ <env-2>
|               |____ webdrivers
|________ testout [test report and evidences]
|____ report
QA project automation library should adhere to folder structure as pictured below:

| aut-project root
|____ pom.xml
|____ src/main
|       |____ java
|       |       |____ com.eastspring.qa
|       |       |       |____ context [CartCoreConfig extended with AUT objects ]
|       |       |       |        |____ CartExtendedConfig
|       |       |       |____ <project/aut name>
|       |       |       |       |____ pages
|       |       |       |       |       |____ CartPageConfig
|       |       |       |       |       |____ <app-1>  [optional level]
|       |       |       |       |       |       |____ <page-objects>
|       |       |       |       |       |____ <app-n>  [optional level]
|       |       |       |       |       |       |____ <page-objects>
|       |       |       |       |____ databases
|       |       |       |       |       |____ CartDatabaseConfig
|       |       |       |       |       |____ <app-n>  [optional level]
|       |       |       |       |       |       |____ <database-objects>
|       |       |       |       |____ <other service/component>
|       |       |       |       |       |____ Cart{}Config
|       |       |       |       |       |____ <app-n>  [optional level]
|       |       |       |       |       |       |____ <{}-objects>
|       |       |       |       |____ resuableSteps
|       |       |       |       |       |____ CartStepConfig
|       |       |       |       |       |____ business
|       |       |       |       |       |       |____ <steps>
|       |       |       |       |       |____ common
|       |       |       |       |               |____ <steps>
|       |       |       |       |____ utils
|       |       |       |              |____ CartUtilConfig
|       |       |       |              |____ business
|       |       |       |              |       |____ <utils>
|       |       |       |              |____ common
|       |       |       |                      |____ <utils>
|       |       |____ stepdefinitions [cucumber step definitions]
|       |                 |____ CartCucumberStepConfig
|       |____ resources
|              |____ config
|                     |____ core-config.properties [optional - to override configuration in cart]
|                     |____ run-config.properties [optional - to override configuration in cart]
|____ src/test [diagnostic tests]
|       |____ features
|       |____ resources
|               |____ config
|               |        |____ app-config-<env-lowercase-shortname>.properties
|               |____ testdata [contain test data files, subcategorized by env short names]
|               |        |____ common
|               |        |____ <env-1>
|               |        |____ <env-2>
|               |____ webdrivers
|________ testout [test report and evidences]

*AUT - Application Under Test
Note:

'java' should be marked as source root.
Core framework as dependency in AUT projects
Add core framework as dependency in pom file in associated projects

<parent>
    <groupId>com.eastspring.qa</groupId>
    <artifactId>cart-lite</artifactId>
    <version>{version}</version>
</parent>

<dependencies>
    <dependency>
        <groupId>com.eastspring.qa</groupId>
        <artifactId>cart-core-lite</artifactId>
        <version>{version}</version>
    <dependency>
<dependencies>
run mvn dependency-tree command to pull all transitive dependencies

Configuration management
Config managers in cart scans for values for config parameters in the following order of precedence

system / maven property
env variables
config files in project aut
config files in cart (for core & run config)
core configuration
set of configuration parameters used by core libraries

accessed via CoreConfigManager

Properties File	parameter	dataType	mandatory	default	description
core-config	log4j.config.path	string	optional	EMPTY	custom log4j config file path; refer cart folder-structure for default location
core-config	secret.master.password	string	conditional	EMPTY	master password required by SecretUtil to encrypt or decrypt secrets. mandatory if any secrets used in project
run configuration
set of configuration parameters defining the test run
accessed via RunConfigManager
Properties File	section	parameter	dataType	mandatory	default	description
run-config	run	run.project.name	String	mandatory	EMPTY	project name
run-config	run	run.build.number	String	optional	EMPTY	build number
run-config	run	run.release.version	String	optional	EMPTY	release version
run-config	run	run.env.name	String	mandatory	EMPTY	environment name. this should mat
run-config	run	run.thread.count	Integer	optional	1	number of parallel threads
run-config	run	run.intermittent.wait.seconds	Integer	optional	5	intermittent wait time in seconds
run-config	run	run.terminate.app.before.scenario	Boolean	optional	FALSE	flag to terminate the applications before a scenario
run-config	run	run.terminate.app.on.failure	Boolean	optional	FALSE	flag to terminate the applications after a failed scenario
run-config	report	report.log.level	String	optional	INFO	cart log level determining logs added to execution log file. Allowed values: DEBUG,INFO,WARN,ERROR
run-config	report	report.screenshot.level	String	optional	ON_FAILURE	screenshot capture intervals. Allowed values: ALWAYS,NEVER,ON_FAILURE.Refer [Logging & Reports] section for more details
run-config	report	report.screenshot.format	String	optional	PNG	types of web screenshot files.Allowed values: PNG
run-config	cucumber	run.cucumber.features	String	optional	EMPTY	cucumber feature. Refer https://cucumber.io/docs/cucumber/api/?lang=java#options
run-config	cucumber	run.cucumber.glue	String	optional	EMPTY	cucumber glue. Refer https://cucumber.io/docs/cucumber/api/?lang=java#options
run-config	cucumber	run.cucumber.tags	String	optional	EMPTY	cucumber tag expression. Refer https://cucumber.io/docs/cucumber/api/?lang=java#options
run-config	web	web.browser	String	optional	CHROME	Allowed values: CHROME,IE,FIREFOX
run-config	web	web.headless	Boolean	optional	FALSE	flag to run web tests headless
run-config	web	web.driver.path	String	optional	EMPTY	path to custom webdriver file compatible with web.browser. Cart will look into default webdriver folder [Refer cart folder structure]
run-config	web	web.implicit.wait.seconds	Integer	optional	10	implicit webdriver wait in seconds
run-config	web	web.page.timeout.seconds	Integer	optional	50	page timeout in seconds
run-config	web	web.ie.ensure.clean.session	Boolean	optional	FALSE
run-config	web	web.chrome.binary.path	String	optional	EMPTY	custom path to chrome binary
run-config	web	web.proxy	String	optional	EMPTY
run-config	jira	jira.project.key	String	mandatory	EMPTY	jira project key; the jira ids are identified from scenario tags my matching it against this project key. This is mandated to enforce traceability to jira tests & stories
app configuration
set of configuration parameters specific to a given application under test in given env

the list of parameters are defined by aut project owners

AppConfigManager will dynamically load app-config-<env>.properties based in env name in run-config

can be accessed via

AutoWired instance of AppConfigManager
getAppConfigManager() in base classes
Services
Collection of key service libraries including web, db, connection & driver managers etc.
accompanied by abstract base classes for uniform implementation of components
Base classes for object-model inheritance
This framework emphasizes page object pattern for selenium/appium UI testing. Core libraries encapsulate WebTaskSvc bean that should be consumed by PageObjects via BasePage class in projects.

For example: Page-object for Google is inherited as GooglePage <- BaseWebPage <- WebTaskSvc (WebDriverManagerSvc, WebDriverSvc etc)

Similar practice is encouraged for database and api test automation via their respective base classes.

Refer coding standards to understand Dos and Donts

webdriver files
refer cart folder structure for default webdriver folder
refer run config properties to provide custom webdriver folder path
Test data
feature files
test data can be parameterized in feature files
cart recommends to
parameterize the character / behaviour of data in feature files
store actual values in a file source (db/json/csv)
For example:
feature file can parameterize valid (or) invalid login
actual id and passwords can be stored in data files
test data files
test data files must be stored in the designated folder [Refer cart folder structure]
test data files must be categorized across targeted environments in respective env folder
the name of env folder must match the env-name provided in run-config
common folder can be used to store test data files which are commonly used across environments.
Utilities
WorkspaceUtil
utility with getters for significant folder path (like execution report, test data etc.), which can be referenced by tests
cart encourages avoiding hard-coded folder path in the tests
SecretUtil
util to encrypt texts and decrypt secrets using the master password in core-config.
cart encourages using encrypted passwords only.
TestDataFileUtil
wrapper util to read test data files and reduce the complexity of locating file by name across common & env test-data folders
Other notable utilities
DateTimeUtil
File utils for csv, excel, json, xml
DataRecordCompareUtil (Compare records retrieved from sources)
ThreadUtil (Forced sleep and Synchronize)
Tags
by-type             :   @smoke, @regression, @inSprint
by-platform         :   @ui, @api, @db, @files, @e2e
by-functionality    :   <functionality-indicators>, <app indicators>
by-device/browser   :   @mobile, @browser
by-priority         :   @priorityHigh, @priorityMedium, @priorityLow
by-progress         :   @toDo, @wip, @onHold, @outdated [if not deleted]
by-env              :   @prod, @nonProd
by jira-id          :   @<project-key>-<id>
default-exclusions :   @noRun
Run
From Command line
tests are executed using exec-maven-plugin configured for test phase
go to cart-core-lite root / aut project root
run mvn test
Note: set -Dmaven.skip.exec=true to skip tests in other mvn cycles

From IDE [for developers]
option-1: create a "cucumber-java" run-configuration with
CucumberRunner from cart-core-lite as main class
default features directory as input for feature folder path
option-2: create an "Application" run-configuration with CucumberRunner from cart-core-lite as main class
Parallel execution
use run-config to specify thread count for parallel execution
Note: config parameters can be passed as environment variables

Logging and Reports
CartLogger wrapper provides one unified channel for
logging with four levels - DEBUG, INFO, WARN, ERROR
insert files as attachments
the following output files are generated and stored in a dynamic execution folder under testout->reports
default: cucumber html report
others: cucumber junit & json reports
executionSummary.csv - tabulated summary of the test run
executionLog.txt - logs adhering to input log-level from run-config
Screenshots are captured for enabled application-type (e.g, web) based on screenshot-level from run-config
ALWAYS: capture screenshot automatically after every step
ON_FAILURE: capture screenshot only after failed step or scenario
NEVER: screenshots will not be captured automatically
Note: screenshots will always be captured when capture-screenshot method is called explicitly in step-definitions