#eisdev_5451 : New feature file created

@dmp_migration @eisdev_5451
Feature: 001 | Data Migration | Duplicate ISGU
  Verify there are no duplicate records in ISGU with ISS_GU_PURP_TYP = 'ISSUANCE'

  Scenario: Verify duplicate ISGU are 0 in GC Schema

    Given I expect value of column "ISGU_DUPLICATE" in the below SQL query equals to "0":
    """
    SELECT COUNT(ISGU_OID) AS ISGU_DUPLICATE FROM
    (SELECT ISGU_OID, INSTR_ID, ROW_NUMBER() OVER (PARTITION BY INSTR_ID,GU_TYP ORDER BY LAST_CHG_TMS DESC) AS RECORD_ORDER
    FROM FT_T_ISGU WHERE ISS_GU_PURP_TYP = 'ISSUANCE' AND END_TMS IS NULL) WHERE RECORD_ORDER > 1
    """

  Scenario: Verify duplicate ISGU are 0 in VD Schema

    Given I set the database connection to configuration "dmp.db.VD"

    Given I expect value of column "ISGU_DUPLICATE" in the below SQL query equals to "0":
    """
    SELECT COUNT(ISGU_OID) AS ISGU_DUPLICATE FROM
    (SELECT ISGU_OID, INSTR_ID, ROW_NUMBER() OVER (PARTITION BY INSTR_ID,GU_TYP ORDER BY LAST_CHG_TMS DESC) AS RECORD_ORDER
    FROM FT_T_ISGU WHERE ISS_GU_PURP_TYP = 'ISSUANCE' AND END_TMS IS NULL) WHERE RECORD_ORDER > 1
    """