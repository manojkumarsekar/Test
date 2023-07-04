# =================================================================================================
# Date            JIRA        Comments
# ============    ========    ========
# 01/12/2018      TOM-3665    First Version
# 17/12/2018      TOM-3995    Added support for publishing groups
# 21/12/2018      TOM-3995    Minor changes to feature file
# 28/12/2018      TOM-3997    R3.RPT-RBC Seed Capital Data Report-Amount Outstanding and Market Cap
# 10/01/2019      TOM-4104    Remove @dmp_regression_integrationtest tag (until pipeline deploys latest DWH package to regression env)
# 18/12/2019      EISDEV-4188 Rewrite feature file as FT_W_POSN is trucated as part of databse refresh
# =================================================================================================

#No regression tag observed. Hence, modular tag (Ex: gc_interface or dw_interface) has not given.
@tom_3997 @tom_3995 @tom_3665 @rbc @month_end_reporting @data_dumps @dwh_interfaces @tom_4104 @eisdev_4188
Feature: Risk Based Capital (RBC) - Month-end Seed Capital Report

  Use Case : Extract data related to configured Portfolios ('ASUMIP', 'NDHGFF') in "RBCINCLPORTSG" Group
  Published SG report should contain only ASUMIP and NDHGFF. Data for ASUAHY should not be extracted.
  Change the start_tms for BCUSIP BES2RKG12 to 20191130 8:30:25. BCUSIP should be extracted

  Scenario: Assign Variables and Set up Configuration
    And I assign "tests/test-data/dmp-interfaces/MonthEndReporting/RBCReport" to variable "testdata.path"
    And I assign "ESIPME_POS_20191130_1.out" to variable "INPUT_FILENAME"
    And I assign "/dmp/out/eis/rbc" to variable "PUBLISHING_DIR"
    And I assign "fi_rbc_seed_capital_group" to variable "PUBLISHING_FILENAME"
    And I assign "fi_rbc_seed_capital_group_template" to variable "TEMPLATE_NAME"

    And I execute below query
    """
    update ft_t_isid set start_tms = TO_DATE('20191130 8:30:25','yyyymmdd HH:MI:SS') where iss_id = 'BES2RKG12';
    update ft_t_acgp set end_tms = sysdate where PRNT_ACCT_GRP_OID in (
    select ACCT_GRP_OID from ft_t_acgr where acct_grp_id LIKE 'RBCINCLPORT%')
    and acct_id not in (select acct_id from ft_t_acid where acct_alt_id in('ASUMIP','NDHGFF'));
    commit
    """

    Given I set the DMP workflow web service endpoint to named configuration "dwh.ws.WORKFLOW"
    And I set the database connection to configuration "dmp.db.DW"

    And I execute below query
    """
    delete from FT_W_POSN where trunc(as_of_tms) = trunc(TO_DATE('20191130','yyyymmdd'));
    commit
    """

  Scenario: Load Positions Data

    Given I set the DMP workflow web service endpoint to named configuration "dwh.ws.WORKFLOW"
    And I set the database connection to configuration "dmp.db.DW"

    And I copy files below from local folder "${testdata.path}/testdata" to the host "dmp.ssh.inbound" folder "${dmp.ssh.inbound.path}":
      | ${INPUT_FILENAME} |

    When I process files with below parameters and wait for the job to be completed
      | BUSINESS_FEED |                                |
      | FILE_PATTERN  | ${INPUT_FILENAME}              |
      | MESSAGE_TYPE  | EIS_MT_BNP_MOPK_POS            |

    Then I expect value of column "record_count" in the below SQL query equals to "6":
    """
    SELECT count(*) as record_count FROM ft_v_rpt1_rbc_seed_capital WHERE me_date = TO_DATE('20191130','yyyymmdd')
    """

  Scenario: Publish RBC Report

    Given I set the DMP workflow web service endpoint to named configuration "dwh.ws.WORKFLOW"
    And I set the database connection to configuration "dmp.db.DW"

    And I remove below files in the host "dmp.ssh.inbound" from folder "${PUBLISHING_DIR}" if exists:
      | ${PUBLISHING_FILENAME} |

    When I process DWH publishing wrapper with below parameters and wait for the job to be completed
      | BULK_SIZE           | 100000                                                                                                                                              |
      | CONVERT_TO_EXCEL    | false                                                                                                                                               |
      | FILE_DIRECTORY      | ${PUBLISHING_DIR}                                                                                                                                   |
      | PUBLISHING_FILENAME | ${PUBLISHING_FILENAME}.csv                                                                                                        |
      | THREAD_COUNT        | 1                                                                                                                                                   |
      | SQL_ID              | SELECT DISTINCT posn_sok id FROM ft_v_rpt1_rbc_seed_capital WHERE me_date = TO_DATE('20191130','yyyymmdd') AND rbc_group_id = 'RBCINCLPORTSG'       |
      | SQL_PUBLISH         | SELECT posn_sok id, flow_data FROM ft_v_rpt1_rbc_seed_capital WHERE NVL(rbc_group_id, 'RBCINCLPORTSG') = 'RBCINCLPORTSG' ORDER BY acct_id, sec_name |

    Then I expect below files to be present in the host "dmp.ssh.inbound" into folder "${PUBLISHING_DIR}" after processing:
      | ${PUBLISHING_FILENAME}.csv |

    Then I copy files below from remote folder "${PUBLISHING_DIR}" on host "dmp.ssh.inbound" into local folder "${testdata.path}/outfiles/runtime":
      | ${PUBLISHING_FILENAME}.csv |

    # Validation: Reconcile Data with template
    And I expect reconciliation between generated CSV file "${testdata.path}/outfiles/runtime/${PUBLISHING_FILENAME}.csv" and reference CSV file "${testdata.path}/outfiles/expected/${TEMPLATE_NAME}.csv" should be successful and exceptions to be written to "${testdata.path}/outfiles/exceptions_${recon.timestamp}.csv" file