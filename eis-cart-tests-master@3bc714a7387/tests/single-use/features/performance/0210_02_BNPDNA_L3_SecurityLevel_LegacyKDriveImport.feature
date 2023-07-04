Feature: Performance L3 Attribution Security Level Historical Data Reconciliation: Legacy vs BNP DNA Platform

    Background:
        Given I prepare the reconciliation engine
	
    @reconciliation @performance @performance_l3 @performance_l3_security_kdrive
    Scenario: Import legacy K: drive Excel files into reconciliation engine

        Given I load the Legacy Security Level K: drive data from location "c:/tomwork/performance-l3/03-kdrive" with ignore list "-------" with debug enabled

