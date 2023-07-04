Feature: Database Verification

    Scenario: Open database connection to GS database
        Given I define JDBC connection driver class ""
        And I define JDBC connection URL "" with username "" and password ""
        When I execute SQL query below:
        """
        SELECT 1 FROM DUAL
        """
        Then I should get the result below:
        """
        1
        """
