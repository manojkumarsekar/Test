Feature: Donwnload Performance L1 Book of Records (ABOR/IBOR) from BNP DNA Platform

    As a Quality Assurance Staff
    I want to be able
        - to download the Performance L1 Book of Records (ABOR/IBOR) for a given date from BNP DNA platform
    So that I would be able
        - to get the data of Performance L1 Book of Records (ABOR/IBOR) that was uploaded to BNP Middle Office Service Platform
        - and reconcile the data against the existing CPR reports

    In the R3, we are uploading the data from production legacy systems (Eagle and Sylvan) databases to produce the Performance
    L1 Report which has the reports for Book of Records (ABOR/IBOR). During the transition, both will be running in parallel
    (the existing legacy reporting system CPR, together with the BNP reporting).

    In the legacy system, CPR reports produced regularly over time, and historical CPR reports had accumulated.

    The historical data that comes from the legacy systems databases are gradually migrated (uploaded) to the Middle Office
    Service Platform (MOSP), that is run by BNP Paribas. After successful migration of the data, the TOM Project will still
    need to upload monthly the data and reconcile the CPR report with the data coming from BNP DNA platform, until the cut
    over time when the CPR report will be produced solely by the BNP DNA platform (the end goal).

    As the Target Operating Model (TOM) requires transition period between use of the legacy systems data and the new way
    of producing the CPR report, we need to get some assurance that the new system will be producing similar results to the
    existing one from legacy systems.
		

    @current @performance_l1_download
    Scenario Outline: Download Performance Report Book of Records reports

        Given I open a BNP DNA web session defined in "bnp.dna.web.hl.session"
        Then I click the web element "bnp.dna.web.hl.landing.BookOfRecords"
        Then I switch to the next browser tab
        And I pause for 50 seconds

        And I take a screenshot

        Then I click the web element "bnp.dna.web.hl.bor.DetailedData"
        And I take a screenshot
        Then I enter the text "<report-date>" into web element "bnp.dna.web.hl.bor.ReportDateSearchInput" followed by "ENTER" key
        And I pause for 2 seconds
        And I assign "<report-date>" to variable "report.date.text"
        Then I click the web element "bnp.dna.web.hl.bor.ReportDateSelection"

        Then I click the web element "bnp.dna.web.hl.bor.ContextMenu"
        Then I click the web element "bnp.dna.web.hl.common.menu.Export"
        Then I click the web element "bnp.dna.web.hl.common.menu.ExportWoValueFormatting"

        Then I create the folder "c:/tomwork/regression10/downloaded" if it does not exist
        And I export the BNP DNA Book of Records detailed data into CSV file with name "BNP_DNA_L1_<report-file-tag>.csv" into location "c:/tomwork/regression10/downloaded"

        Then I close all opened web browsers

		Examples:
            | report-file-tag | report-date     |
            | Jul2010         | July, 2010      |
            | Feb2011         | February, 2011  |
            | May2012         | May, 2012       |
            | Nov2012         | November, 2012  |
            | Aug2013         | August, 2013    |
            | Jan2014         | January, 2014   |
            | Dec2015         | December, 2015  |
            | Apr2016         | April, 2016     |
            | Sep2016         | September, 2016 |
            | Mar2017         | March, 2017     |
				

		