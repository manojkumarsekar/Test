Feature: BRS UI Test

    Scenario: Verify the GICS Sector for China India NAV (USD) value on 11-SEP-2017

        Given I set the web configuration of "Blackrock Solutions Web" from properties with prefix "brs.web"
        When I open a web session from web configuration "Blackrock Solutions Web"
        Then I click on the named web element "brs.web.greenpackage.button"

        And I select the Green Package left menu item "Eastspring Investments::Singapore::Equity::China India"
        Then I click on the named web element "brs.web.greenpackage.chinaindia.sector.sector_summary.link"
        Then I expect to see the left title to be "GICS Sector to Sub Industry Breakdown Summary Report"
        Then I take a screenshot
        And I pause for 5 seconds
        And I take a screenshot

#        Then I expand the "Core Value" portfolio group

#        And I expect to see the column with title "NAV (USD) (m)" for portfolio "ALDPEF" to exactly equals to "155,661"
#        And I take a screenshot
#        And I expect to see the column with title "NAV (USD) (m)" for portfolio "ASUDPF" to exactly equals to "804,955"
#        And I expect to see the column with title "NAV (Base CCY) (m)" for portfolio "ASUDPF" to be numerically equals to "1,093,900" with relative tolerance of "0.000000001"
        And I expect to see the column with title "NAV (Base CCY) (m)" for portfolio "ASUDPF" to be numerically equals to "1,093,900" with relative tolerance of "0.1"
        And I take a screenshot
#        And I expect to see the column with title "Consumer Staples" for portfolio "ASUDPF" to exactly equals to "3.35"
#        And I take a screenshot

      Then I close all opened web browsers


#				And I select the Green Package left menu item "myAladdin"
#				And I select the Green Package left menu item "Group Head Office"
#				And I select the Green Package left menu item "Eastspring Investments::Singapore"
#				And I select the Green Package left menu item "Eastspring Investments::Singapore::Equity"
#				And I select the Green Package left menu item "Eastspring Investments::Singapore::Equity::ASEAN"
#				And I select the Green Package left menu item "Eastspring Investments::Singapore::Equity::China India"
#				And I select the Green Package left menu item "Eastspring Investments::Singapore::Equity::Greater China"
#				And I select the Green Package left menu item "Eastspring Investments::Singapore::Equity::India"
#				And I select the Green Package left menu item "Eastspring Investments::Singapore::Equity::Infrastructure"
#				And I select the Green Package left menu item "Eastspring Investments::Singapore::Equity::Property"
#				And I select the Green Package left menu item "Eastspring Investments::Singapore::Equity::Regional Asia"
#				And I select the Green Package left menu item "Eastspring Investments::Singapore::Equity::GEM"
#				And I select the Green Package left menu item "Eastspring Investments::Singapore::Equity::ICICI"
#				And I select the Green Package left menu item "Eastspring Investments::Singapore::Equity::Sub Advised"
#				And I select the Green Package left menu item "Eastspring Investments::Singapore::QIS"
#				And I select the Green Package left menu item "Eastspring Investments::Singapore::Alternatives"
#				And I select the Green Package left menu item "Eastspring Investments::Singapore::Alternatives::Private Equity"
#				And I select the Green Package left menu item "Eastspring Investments::Singapore::Feeder"
#				And I select the Green Package left menu item "Eastspring Investments::Singapore::Non-Processing"
#				And I select the Green Package left menu item "Eastspring Investments::Hong Kong"
#				And I select the Green Package left menu item "Eastspring Investments::Indonesia"
#				And I select the Green Package left menu item "Eastspring Investments::Malaysia::Insurance::PAMB"
#				And I select the Green Package left menu item "Eastspring Investments::Malaysia::Insurance::PBTB"
#				And I select the Green Package left menu item "Eastspring Investments::Malaysia::Non-Insurance::Domestic"
#				And I select the Green Package left menu item "Eastspring Investments::Malaysia::Non-Insurance::Regional"
#				And I select the Green Package left menu item "Eastspring Investments::Malaysia::Al Wara"


#				And I expect to see the report value date to be "19-SEP-2017"
#				And I expect to see the right title to be "Equity - China India"
