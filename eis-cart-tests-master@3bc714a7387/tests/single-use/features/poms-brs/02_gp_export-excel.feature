Feature: BRS UI Test

		@hare @step01
    Scenario: Download today's GICS Sector for China India NAV (USD) value

    		Given I set the web configuration of "Blackrock Solutions Web" from properties with prefix "brs.web"
    		When I open a web session from web configuration "Blackrock Solutions Web"
        Then I click on the named web element "brs.web.greenpackage.button"

				And I select the Green Package left menu item "Eastspring Investments::Singapore::Equity::China India"
				Then I click on the named web element "brs.web.greenpackage.chinaindia.sector.sector_summary.link"
				Then I take a screenshot
				And I pause for 5 seconds
				
				Then I click the web element with id "excel_rbb"
				
				And I click the web element with xpath "//div[@id='exportMenuPopup']/div[text() = 'Export']"
				And I pause for 5 seconds
				Then I move the downloaded file with name "SGBEQCHIN.gp_eq_pcts.1.GICS_ALL.xls" to test evidence folder "POMS/GP"
				Then I click the web element with xpath "//input[@type='button' and @class='closeButton' and @value='Close']" on browser window that has web element with xpath "//span[contains(text(), 'Please close this window')]"

				And I pause for 3 seconds
				Then I switch to the next browser tab
				
				And I click the web element with xpath "(//tr[@port='ALDPEF']/td)[1]/span/a"

				Then I click the web element with id "excel_rbb"
				And I click the web element with xpath "//div[@id='exportMenuPopup']/div[text() = 'Export']"

				And I pause for 5 seconds

				Then I move the downloaded file with name "ALDPEF.gp_eq_multi_ccy.1.GICS_ALL.xls" to test evidence folder "POMS/GP"
				Then I click the web element with xpath "//input[@type='button' and @class='closeButton' and @value='Close']" on browser window that has web element with xpath "//span[contains(text(), 'Please close this window')]"
				
				Then I pause for 10 seconds
				
				Then I close all opened web browsers