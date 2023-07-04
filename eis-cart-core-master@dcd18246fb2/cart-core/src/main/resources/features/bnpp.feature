Feature: BNP Reconciliation

    Scenario: Reconcile BNP CSV against GS table
        Given I have CSV file "testDataSet/BNP/01380.csv"
        When I upload the CSV file to Golden Source
        Then I expect to see the reconciliation


