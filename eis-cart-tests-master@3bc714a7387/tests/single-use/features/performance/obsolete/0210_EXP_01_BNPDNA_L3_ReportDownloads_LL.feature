Feature: BNP DNA L3 Equity Report Downloads (Low Level)

		This feature file demonstrate the downloading of L3 Report specified in low level Gherkin statements.

		@hare @performance @lowlevel
    Scenario Outline: Download reports

        Given I open a web session from URL "${bnp.dna.web.url}"
        Then I pause for 2 seconds
        Then I click the web element with xpath "//button[@title='Select an option']"
        Then I click the web element with xpath "//span[text()='Standard']"


        When I enter the text "${bnp.dna.web.user}" into web element with id "userId"
        And I enter the text "${bnp.dna.web.pass}" into web element with id "password"
        Then I click the web element with id "login"

				Then I click the web element "bnp.dna.web.perfrisk.icon.equity.l3.histo"

				Then I switch to the next browser tab
				Then I click the web element "bnp.dna.web.tab.dashboard"

				Then I perform selection of the visible value "SGIF" on web element "bnp.dna.web.dashboard.portfolioselection.portfolio"
				Then I perform selection of the visible value "1/31/2017" on web element "bnp.dna.web.dashboard.portfolioselection.date"
				
				Then I click the web element "bnp.dna.web.dashboard.portfolioselection.sector"
				Then I click the web element "bnp.dna.web.dashboard.grid.pocketlevel"
				Then I click the web element "bnp.dna.web.dashboard.menu.upperright.btn"
				Then I click the web element "bnp.dna.web.hl.common.menu.Export"			
				Then I click the web element "bnp.dna.web.hl.common.menu.ExportWoValueFormatting"
		
		Examples:
				| fund-id |                       fund-name                   | type           |
				|    0    | ASIA REIT MASTER FUND SERIES IX OF KOKUSAI TRUST  | SECTOR_COUNTRY |
#				|    1    | EASTSPRING INVESTMENTS - ASIA PACIFIC EQUITY FUND | SECTOR_ONLY    |
#				|    2    | INDIA EQUITY PORTFOLIO - FUND 225                 | SECTOR_ONLY    |
#				|    3    | SGIF                                              | SECTOR_COUNTRY |
		