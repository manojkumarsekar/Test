@ignore
Feature: Security master:Issue:UI Verification for Proxy in BRS control

	This testcase validate the Security master:ISSUE Screen "PROXY in BRS" dropdown.

	Scenario: Security master:Issue UI Verification - Proxy in BRS dropdown exist with below value
	
		Given I open GS UI application with "administrators" role
		When I navigate to "Security Master:Issue"
		And I click "Setup"
		And I click "Create New"
		Then I expect "Proxy in BRS" element exist with values:
		|Yes|
		|No|
		
	
	