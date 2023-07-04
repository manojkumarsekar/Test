@dmp_regression_unittest @dmp_regression_integrationtest @disable_constraints
Feature: This feature is to run disable constraints scripts before starting the regression execution

  This feature runs for both unit and integration tests.

  Scenario: Execute Disable Constraints scripts

    * I reset the database connection with configuration "dmp.db.GC"
    * I assign "GS_GC" to variable "dmp.db.GC.jdbc.user"
    * I set the database connection to configuration "dmp.db.GC"

    Given I execute below queries to "disable constraints"
    """
    ALTER TABLE FT_T_ISPC DISABLE CONSTRAINT ISPCF005;
    ALTER TABLE FT_T_ISPC DISABLE CONSTRAINT ISPCF003;
    ALTER TABLE FT_T_ISPC DISABLE CONSTRAINT ISPCF010;
    ALTER TABLE FT_T_ISPC DISABLE CONSTRAINT ISPCF002;
    ALTER TABLE FT_T_ISPC DISABLE CONSTRAINT ISPCF009;
    ALTER TABLE FT_T_ISPC DISABLE CONSTRAINT ISPCF008;
    ALTER TABLE FT_T_ISPC DISABLE CONSTRAINT ISPCF001;
    ALTER TABLE FT_T_ISPC DISABLE CONSTRAINT ISPCF001;
    ALTER TABLE FT_T_POSV DISABLE CONSTRAINT POSVF001;
    ALTER TABLE FT_T_ISPS DISABLE CONSTRAINT ISPSF001;
    ALTER TABLE FT_T_ISPS DISABLE CONSTRAINT ISPSF002;
    ALTER TABLE FT_T_PCST DISABLE CONSTRAINT PCSTF001;
    ALTER TABLE FT_T_LOTV DISABLE CONSTRAINT LOTVF001;
    ALTER TABLE FT_T_MPPT DISABLE CONSTRAINT MPPTF002;
    ALTER TABLE FT_T_GPCS DISABLE CONSTRAINT GPCSF006;
    ALTER TABLE FT_T_GPCS DISABLE CONSTRAINT GPCSF007;
    ALTER TABLE FT_T_GPCS DISABLE CONSTRAINT GPCSF003;
    ALTER TABLE FT_T_GPRC DISABLE CONSTRAINT GPRCF001;
    ALTER TABLE FT_T_HOLV DISABLE CONSTRAINT HOLVF001;
    ALTER TABLE FT_T_PCCM DISABLE CONSTRAINT PCCMF001;
    ALTER TABLE FT_T_BNVL DISABLE CONSTRAINT BNVLF003;
    ALTER TABLE FT_T_EOPB DISABLE CONSTRAINT EOPBF019;
    ALTER TABLE FT_T_EOPB DISABLE CONSTRAINT EOPBF018;
    ALTER TABLE FT_O_PRJB DISABLE CONSTRAINT PRJBF001;
    ALTER TABLE FT_T_RQEV DISABLE CONSTRAINT RQEVF003;
    ALTER TABLE FT_T_SPRD DISABLE CONSTRAINT SPRDF001;
    """

  Scenario: Setting back GC_GC_APP user to dmp.db.GC.jdbc.user property and reset the DB connection

    * I assign "GS_GC_APP" to variable "dmp.db.GC.jdbc.user"
    * I reset the database connection with configuration "dmp.db.GC"