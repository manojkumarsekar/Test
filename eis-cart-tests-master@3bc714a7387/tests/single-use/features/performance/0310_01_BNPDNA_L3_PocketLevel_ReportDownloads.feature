Feature: BNP DNA Performance L3 Attribution Pocket Level Historical Report Downloads


@reconciliation @performance @performance_l3 @performance_l3_pocket_bnpdna
Scenario: Download BNP DNA Performance L3 Performance Attribution (Pocket Level) raw data

	Given I open a BNP DNA web session
	Then I download the Performance L3 Pocket Level raw data from menu item "FarEast - Equity Attribution" of BNP DNA
	And I pause for 400 seconds
	Then I save the downloaded Performance L3 raw data file to location "c:/tomwork/performance-l3/02-downloaded/DNA_L3_PocketLevel.csv"
	And I load the BNP DNA Performance L3 Pocket Level raw data from file "c:/tomwork/performance-l3/02-downloaded/DNA_L3_PocketLevel.csv"	