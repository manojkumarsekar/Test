@before_rerun @ignore_hooks
Feature: This feature is to clear down Goldensource database logs and workflows

  This feature basically clear down all the logs and workflow data to prepare state for clean run.
  It has to be run only with GS_GC user. Hence explicitly defining the db connection params.
  Before rerunning failed tests, it would be better if we can execute this scripts.

  Scenario: Cleardown Log tables and Workflow data

    * I reset the database connection with configuration "dmp.db.GC"
    * I assign "GS_GC" to variable "dmp.db.GC.jdbc.user"
    * I set the database connection to configuration "dmp.db.GC"

    * I execute below queries to "cleardown logs and workflow data"
    """
    TRUNCATE TABLE ft_log_logm;
    TRUNCATE TABLE ft_log_lgpd;

    ALTER TABLE ft_log_lgpd DISABLE CONSTRAINT lgpdf001;
    ALTER TABLE ft_log_logm DISABLE CONSTRAINT logmf001;
    ALTER TABLE ft_log_loge DISABLE CONSTRAINT logef001;

    TRUNCATE TABLE ft_log_loge;
    TRUNCATE TABLE ft_log_logf;

    ALTER TABLE ft_log_logm ENABLE CONSTRAINT logmf001;
    ALTER TABLE ft_log_lgpd ENABLE CONSTRAINT lgpdf001;
    ALTER TABLE ft_log_loge ENABLE CONSTRAINT logef001;

    ALTER TABLE ft_wf_tktn DISABLE CONSTRAINT tktnf001;
    ALTER TABLE ft_wf_tktn DISABLE CONSTRAINT tktnf002;
    ALTER TABLE ft_wf_tktn DISABLE CONSTRAINT tktnf003;
    ALTER TABLE ft_wf_tktn DISABLE CONSTRAINT tktnf004;
    ALTER TABLE ft_wf_tktj DISABLE CONSTRAINT tktjf001;
    ALTER TABLE ft_wf_tktj DISABLE CONSTRAINT tktjf002;
    ALTER TABLE ft_wf_tktn DISABLE CONSTRAINT tktnf001;
    ALTER TABLE ft_wf_tktn DISABLE CONSTRAINT tktnf002;
    ALTER TABLE ft_wf_tokn DISABLE CONSTRAINT toknf003;
    ALTER TABLE ft_wf_tokn DISABLE CONSTRAINT toknf004;
    ALTER TABLE ft_wf_wfri DISABLE CONSTRAINT wfrif002;
    ALTER TABLE ft_wf_wfti DISABLE CONSTRAINT wftif001;
    ALTER TABLE ft_wf_tokn DISABLE CONSTRAINT toknf001;
    ALTER TABLE ft_wf_uiwa DISABLE CONSTRAINT uiwaf001;
    ALTER TABLE ft_wf_uiwa DISABLE CONSTRAINT uiwaf002;
    ALTER TABLE ft_wf_wfdv DISABLE CONSTRAINT wfdvf001;

    TRUNCATE TABLE ft_wf_uiwa;
    TRUNCATE TABLE ft_wf_wfdv;
    TRUNCATE TABLE ft_wf_tktj;
    TRUNCATE TABLE ft_wf_tktn;
    TRUNCATE TABLE ft_wf_wfti;
    TRUNCATE TABLE ft_wf_tokn;
    TRUNCATE TABLE ft_wf_wfrv;
    TRUNCATE TABLE ft_wf_wfri;

    ALTER TABLE ft_wf_tktn ENABLE CONSTRAINT tktnf001;
    ALTER TABLE ft_wf_tktn ENABLE CONSTRAINT tktnf002;
    ALTER TABLE ft_wf_tktn ENABLE CONSTRAINT tktnf003;
    ALTER TABLE ft_wf_tktn ENABLE CONSTRAINT tktnf004;
    ALTER TABLE ft_wf_tktj ENABLE CONSTRAINT TKTJF001;
    ALTER TABLE ft_wf_tktn ENABLE CONSTRAINT TKTNF001;
    ALTER TABLE ft_wf_tktn ENABLE CONSTRAINT TKTNF002;
    ALTER TABLE ft_wf_tokn ENABLE CONSTRAINT TOKNF003;
    ALTER TABLE ft_wf_tokn ENABLE CONSTRAINT TOKNF004;
    ALTER TABLE ft_wf_wfri ENABLE CONSTRAINT WFRIF002;
    ALTER TABLE ft_wf_wfti ENABLE CONSTRAINT WFTIF001;
    ALTER TABLE ft_wf_tokn ENABLE CONSTRAINT TOKNF001;
    ALTER TABLE ft_wf_tktj ENABLE CONSTRAINT TKTJF002;
    ALTER TABLE ft_wf_uiwa ENABLE CONSTRAINT UIWAF001;
    ALTER TABLE ft_wf_uiwa ENABLE CONSTRAINT UIWAF002;
    ALTER TABLE ft_wf_wfdv ENABLE CONSTRAINT WFDVF001;
    """

  Scenario: Setting back GC_GC_APP user to dmp.db.GC.jdbc.user property and reset the DB connection

    * I assign "GS_GC_APP" to variable "dmp.db.GC.jdbc.user"
    * I reset the database connection with configuration "dmp.db.GC"