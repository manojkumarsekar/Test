Feature: Performance L3 Attribution Pocket Level Historical Data Reconciliation: Import Legacy K: drive Excel files
				
	
    Background:
        Given I prepare the reconciliation engine
	
    @reconciliation @performance @performance_l3 @performance_l3_pocket_kdrive
    Scenario: Import legacy K: drive Excel files into reconciliation engine

        Given I load the Legacy Pocket Level K: drive data from location "c:/tomwork/performance-l3/03-kdrive" with ignore list "AAAAAAAA"

# NOTE:
# some period needs this, as the ALTHEF_ATT has been manually edited and has different structure in the Excel file
# "ALTHEF_ATT|ASMAEQ_ASMAEQ CS-2"
		