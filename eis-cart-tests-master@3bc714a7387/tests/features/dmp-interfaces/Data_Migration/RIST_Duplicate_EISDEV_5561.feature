#eisdev_5561 : https://jira.pruconnect.net/browse/EISDEV-5561

@dmp_migration @eisdev_5561
Feature: 001 | Data Migration | Duplicate RIST
  Verify there are no duplicate records in RIST for one INSTR_ID

  Scenario: Verify duplicate RIST are 0 in GC Schema

    Given I expect value of column "RIST_DUPLICATE" in the below SQL query equals to "0":
    """
    SELECT COUNT(*) AS RIST_DUPLICATE FROM
    (SELECT RIST_OID, INSTR_ID, ROW_NUMBER() OVER (PARTITION BY INSTR_ID ORDER BY STATS_EFF_TMS ASC) AS RECORD_ORDER
    FROM FT_T_RIST) WHERE RECORD_ORDER > 1
    """

  Scenario: Verify duplicate ISGU are 0 in VD Schema

    Given I set the database connection to configuration "dmp.db.VD"

    Given I expect value of column "RIST_DUPLICATE" in the below SQL query equals to "0":
    """
    SELECT COUNT(*) AS RIST_DUPLICATE FROM
    (SELECT RIST_OID, INSTR_ID, ROW_NUMBER() OVER (PARTITION BY INSTR_ID ORDER BY STATS_EFF_TMS ASC) AS RECORD_ORDER
    FROM FT_T_RIST) WHERE RECORD_ORDER > 1
    """