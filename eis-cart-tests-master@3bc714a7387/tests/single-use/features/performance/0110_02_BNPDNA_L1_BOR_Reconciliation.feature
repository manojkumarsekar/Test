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


    @reconciliation @performance @performance_l1_reconciliation @internaldb
    Scenario Outline: Perform the reconciliation

        Given I set the database connection to configuration "internal.db.RECON"
        And I prepare the reconciliation engine

        When I capture current time stamp into variable "recon.timestamp"

        When I convert the date format for CSV file "c:/tomwork/csv-l1/cpr-02-csv/CPR_<signature>.csv" with column names "Inception Date" from format "MMM dd, yyyy" to format "yyyy-MM-dd" to target file "c:/tomwork/csv-l1/cpr-03-csv-normalized/CPR_n01_<signature>.csv"
        And I remove the string ":00 AM" when it occurs at the end of the string for CSV file "c:/tomwork/csv-l1/cpr-02-csv/BNP_<signature>.csv" with column names "SI Date" and write it to the target file "c:/tomwork/csv-l1/cpr-03-csv-normalized/BNP_n01_<signature>.csv"
        And I convert the date format for CSV file "c:/tomwork/csv-l1/cpr-03-csv-normalized/BNP_n01_<signature>.csv" with column names "SI Date" from format "d/M/yyyy H:m" to format "yyyy-MM-dd" to target file "c:/tomwork/csv-l1/cpr-03-csv-normalized/BNP_n02_<signature>.csv"
        And I convert the numeric decimal precision for CSV file "c:/tomwork/csv-l1/cpr-03-csv-normalized/BNP_n02_<signature>.csv" with column names "ShareClass AUM (M.),SI Fund Gross Return (Ann.),SI Fund Pri. Benchmark Return (Ann.),SI Fund Net Relative Return (Ann.),SI Fund Gross Relative Return (Ann.),SI Fund Net Return (Ann.)" to "2" decimal point and write it to the target file "c:/tomwork/csv-l1/cpr-03-csv-normalized/BNP_n03_<signature>.csv"

        When I reconcile from folder "/tomwork/csv-l1/cpr-03-csv-normalized" the source CSV file "CPR_n01_<signature>.csv" into "CPRTable_${recon.timestamp}" with encoding of "UTF-8" and the target CSV file "BNP_n03_<signature>.csv" into "BNPTable_${recon.timestamp}" with encoding of "UTF-8"
        Given I generate the reconciliation summary report to file "/tomwork/csv-l1/cpr-04-result/<signature>_Summary.html" using template file "BNP_CPR_BOR_Recon.xml" at template location "performance/L1"
        When I export comparison the match results to CSV file "/tomwork/csv-l1/cpr-04-result/<signature>_MatchRows.csv" and the mismatch results to CSV file "/tomwork/csv-l1/cpr-04-result/<signature>_MismatchRows.csv" and the source surplus rows to CSV file "/tomwork/csv-l1/cpr-04-result/<signature>_CPRSurplus.csv" and the target surplus rows to CSV file "/tomwork/csv-l1/cpr-04-result/<signature>_BNPSurplus.csv"
        Then I produce a highlighted mismatch report in Excel file "/tomwork/csv-l1/cpr-04-result/<signature>_HighlightedComparison.xls" from CSV file "/tomwork/csv-l1/cpr-04-result/<signature>_MismatchRows.csv"

        Examples:
            | signature |
            | Sep2017   |
            | Apr2017   |
#            | Jul2017   |
#            | Aug2017   |

