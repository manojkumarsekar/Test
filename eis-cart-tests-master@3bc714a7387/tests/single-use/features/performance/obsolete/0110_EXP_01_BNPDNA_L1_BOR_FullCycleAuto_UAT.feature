Feature: Reconcile Performance L1 Book of Records (ABOR/IBOR): BNP DNA Platform data vs CPR Reports data

  As a Quality Assurance Staff
  I want to be able
  - to reconcile the Performance L1 Book of Records (ABOR/IBOR) for a given date from BNP DNA platform against CPR reports
  produced by the legacy systems
  So that I would be able
  - to asses the quality of the new system produced by TOM Project R3
  - to identify potential issues and discrepancies produced by the Middle Office Service Platform (BNP's system)

  Currently we have production data from the legacy systems (Eagle and Sylvan) databases.
  CPR reports are produced regularly over time, and historical CPR reports have accumulated over time.

  The historical data that comes from the legacy systems databases are gradually transferred (uploaded) to the Middle Office
  Service Platform (MOSP), that is run by BNP Paribas. After successful migration of the data, the TOM Project will still
  need to upload monthly the data and reconcile the CPR report with the data coming from BNP DNA platform, until the cut
  over time when the CPR report will be produced solely by the BNP DNA platform (the end goal).

  As the Target Operating Model (TOM) requires transition period between use of the legacy systems data and the new way
  of producing the CPR report, we need to get some assurance that the new system will be producing similar results to the
  existing one from legacy systems.

  The reconciliation process will produce information needed in a user friendly format for further eye-ball check.


  @workingon @performance_l1_reconciliation_new
  Scenario Outline: Perform the reconciliation

    Given I set the database connection to configuration "internal.db.RECON"
    And I prepare the reconciliation engine
    When I set the global numerical match tolerance to "0.0001"

    When I capture current time stamp into variable "recon.timestamp"

    # prepare and copy the CPR report ZIP files from folder "cpr-01-copied" (from K: drive) and unzip them
    When I create the folder "c:/tomwork/regression10/cpr-02-unzipped" if it does not exist
    And I unzip the file from folder "/tomwork/regression10/cpr-01-copied" that contains signature string "<cpr-file-signature>" and put the results into folder "/tomwork/regression10/cpr-02-unzipped"
    And I assign the name of the file in folder "/tomwork/regression10/cpr-02-unzipped" that matches the pattern "CPR2*" and contains the signature string "<cpr-file-signature>" to variable "recon.cpr.excel.file"
    When I create the folder "c:/tomwork/regression10/cpr-03-csv" if it does not exist
    And I assign the filename part of the filename "${recon.cpr.excel.file}" to variable "recon.cpr.excel.file.name"
    And I assign the extension part of the filename "${recon.cpr.excel.file}" to variable "recon.cpr.excel.file.ext"
    And I assign "${recon.cpr.excel.file.name}.csv" to variable "recon.cpr.csv.file"
    Then I convert Excel file "${recon.cpr.excel.file}" into CSV file "${recon.cpr.csv.file}" with encoding of "UTF-8"

    # prepare the files downloaded from BNP DNA
    And I assign the name of the file in folder "/tomwork/regression10/files" that matches the pattern "BNP_DNA_L1_*" and contains the signature string "<bnpdna-file-signature>" to variable "recon.bnpdna.file"

    When I reconcile from folder "/tomwork/regression10/files" the source CSV file "${recon.cpr.csv.file}" into "CPRTable_${recon.timestamp}" with encoding of "UTF-8" and the target TSV file "${recon.bnpdna.file}" into "BNPTable_${recon.timestamp}" with encoding of "UTF-16"
    Given I generate the reconciliation summary report to file "/tomwork/regression10/testout/summary.html" using template file "BNP_CPR_BOR_Recon.xml" at template location "/tomwork/regression10/testdata/report-templates"
    When I export comparison the match results to CSV file "/tomwork/regression10/testout/matchRows.csv" and the mismatch results to CSV file "/tomwork/regression10/testout/mismatchRows.csv"
    Then I produce a highlighted mismatch report in Excel file "/tomwork/regression10/testout/highlightedMismatchRows.xls" from CSV file "/tomwork/regression10/testout/mismatchRows.csv"

    Examples:
      | bnp-dna-file-signature | cpr-file-signature |
      | Jul2010                | (JUL 2010)         |
      | Feb2011                | (FEB 2011)         |
      | May2012                | (MAY 2012)         |
      | Nov2012                | (NOV 2012)         |
      | Aug2013                | (AUG 2013)         |
      | Jan2014                | (JAN 2014)         |
      | Dec2015                | (DEC 2015)         |
      | Apr2016                | (APR 2016)         |
      | Sep2016                | (SEP 2016)         |
      | Mar2017                | (MAR 2017)         |
