Feature: Test CSV Processing

    This feature used in Performance tooling.

    Background:
        Given I use the named environment "TOM_DEV1"

    @func @func_performance @func_performance_tool @tool_smoke
    Scenario: CSV transform date

        When I convert the date format for CSV file "tests/test-data/tools/csv/csv-transform-01.csv" with column names "col3,col5" from format "dd-MMM-yyyy" to format "yyyy-MM-dd" to target file "testout/evidence/tools/csv/csv-transform-01-out.csv"
        When I convert the date format for CSV file "tests/test-data/tools/csv/csv-transform-02.csv" with column names "col3,col5" from format "MMM dd, yyyy" to format "dd/MM/yyyy HH:mm a" to target file "testout/evidence/tools/csv/csv-transform-02-out.csv"

