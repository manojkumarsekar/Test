Feature: Reconciliation on Database

  Database based reconciliation.


  @hare
  Scenario: Execute reconciliation

    Given I set the database connection to configuration "internal.db.RECON"
    Then I invoke SQL stored procedure "dbo.Compare_BOR_CPR_BNP" on named connection "internal.db.RECON" with these parameters:
      | CPR_BOR_Raw_20171030131148540 | CPRTable         |
      | BNP_BOR_Raw_20171030131148540 | BNPTable         |
      | 0.0001                        | NumericTolerance |
      | 10                            | RowReturnCount   |
      | CPR                           | SourceMoniker    |
      | BNP                           | TargetMoniker    |


		