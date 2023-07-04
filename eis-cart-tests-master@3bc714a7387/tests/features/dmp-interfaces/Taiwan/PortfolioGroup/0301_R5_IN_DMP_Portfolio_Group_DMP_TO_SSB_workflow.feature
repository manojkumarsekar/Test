#https://jira.intranet.asia/browse/TOM-3977
#https://collaborate.intranet.asia/display/TOMTN/Taiwan+New+Cash
#TOM-3977 : R5.IN-CAS14 FAS->DMP New Cash to HSBC FA

#Commented out dmp_regression for now as any test environment is reliant on control-M repo changes to directories.yml being on master.
#@tom_3977 @dmp_portfolio_group @dmp_regression_integrationtest
#EISDEV_4834 : Utility to generate trade file by Fund for Exception Handling Adhoc publishing profile created

@dmp_regression_integrationtest
@tom_3977 @dmp_portfolio_group @eisdev_4834

Feature: Outbound Portfolio Group Interface Testing for SSB TW (R5.IN-CAS14)

  Files to fund administrators (FA) are sent by portfolio. So DMP extracts need to be split by whichever attribute denotes the portfolio for the FA, and the files named accordingly.

  For TW the set of portfolios relevant to a particular FA and batch are determined by a BRS port group. This interface generates a flat file listing portfolios for a port group, to enable that splitting.

  Bear in mind that some FAs will want an empty file for a portfolio if there are no positions/trade/entities for the period being reported; so it can't be driven by the extract itself.

  This and the equivalent HSBC feature file also demonstrate that the subsscription profiles have been configured correctly.

  Scenario: TC_1: Set up test data for domestic fund group

    Given I execute below query
    """
    UPDATE ft_t_acgr SET acct_grp_id = 'TWFACAP1X' WHERE acct_grp_id = 'TWFACAP1' AND end_tms IS NULL;
    UPDATE ft_t_acgr SET acct_grp_id = 'TWFACAP2X' WHERE acct_grp_id = 'TWFACAP2' AND end_tms IS NULL;
    UPDATE ft_t_acgr SET acct_grp_id = 'TWFACAP3X' WHERE acct_grp_id = 'TWFACAP3' AND end_tms IS NULL;

    INSERT INTO ft_t_acgr(acct_grp_oid, acct_grp_id, grp_purp_typ, start_tms, last_chg_tms, last_chg_usr_id, grp_desc, grp_nme, data_stat_typ, data_src_id)
    VALUES (NEW_OID, 'TWFACAP1', 'BRSFNDGP', SYSDATE, SYSDATE, 'TOM-3977-testing', 'Test port group participant extract', 'Test port group participant extract', 'ACTIVE', 'BRS');

    INSERT INTO ft_t_acgr(acct_grp_oid, acct_grp_id, grp_purp_typ, start_tms, last_chg_tms, last_chg_usr_id, grp_desc, grp_nme, data_stat_typ, data_src_id)
    VALUES (NEW_OID, 'TWFACAP3', 'BRSFNDGP', SYSDATE, SYSDATE, 'TOM-3977-testing', 'Test port group participant extract3', 'Test port group participant extract3', 'ACTIVE', 'BRS');

    INSERT INTO ft_t_acct(org_id, bk_id, acct_id, acct_open_dte, acct_stat_typ, cross_ref_id, last_chg_tms, last_chg_usr_id, acct_nme)
    VALUES ('EIS', 'EIS', 'TOM-3977-ACC', SYSDATE, 'OPEN', NEW_OID, SYSDATE, 'TOM-3977-testing', 'Test portfolio for TOM-3977');

    INSERT INTO ft_t_acid(acid_oid, org_id, bk_id, acct_id, acct_id_ctxt_typ, acct_alt_id, start_tms, last_chg_tms, last_chg_usr_id, acct_cross_ref_id)
    SELECT NEW_OID, org_id, bk_id, acct_id, 'CRTSID', 'TOM-3977-CRTS', SYSDATE, SYSDATE, 'TOM-3977-testing', cross_ref_id
    FROM   ft_t_acct WHERE acct_id =  'TOM-3977-ACC';

    INSERT INTO ft_t_acid(acid_oid, org_id, bk_id, acct_id, acct_id_ctxt_typ, acct_alt_id, start_tms, last_chg_tms, last_chg_usr_id, acct_cross_ref_id)
    SELECT NEW_OID, org_id, bk_id, acct_id, 'SITCAFNDID', 'TOM-3977-SITCA', SYSDATE, SYSDATE, 'TOM-3977-testing', cross_ref_id
    FROM   ft_t_acct WHERE acct_id = 'TOM-3977-ACC';

    INSERT INTO ft_t_acgp(prnt_acct_grp_oid, acct_org_id, acct_bk_id, acct_id, start_tms, prt_purp_typ, last_chg_tms, last_chg_usr_id, acgp_oid)
    SELECT acct_grp_oid, 'EIS', 'EIS', 'TOM-3977-ACC', SYSDATE, 'MEMBER', SYSDATE, 'TOM-3977-testing', NEW_OID
    FROM   ft_t_acgr WHERE acct_grp_id = 'TWFACAP1' AND end_tms IS NULL;

    INSERT INTO ft_t_acgp(prnt_acct_grp_oid, acct_org_id, acct_bk_id, acct_id, start_tms, prt_purp_typ, last_chg_tms, last_chg_usr_id, acgp_oid)
    SELECT acct_grp_oid, 'EIS', 'EIS', (select acct_id from ft_t_acid where acct_alt_id = 'TD00107_S' and ACCT_ID_CTXT_TYP = 'CRTSID' and end_tms is null), SYSDATE, 'MEMBER', SYSDATE, 'TOM-3977-testing', NEW_OID
    FROM   ft_t_acgr WHERE acct_grp_id = 'TWFACAP1' AND end_tms IS NULL;

    INSERT INTO ft_t_acgp(prnt_acct_grp_oid, acct_org_id, acct_bk_id, acct_id, start_tms, prt_purp_typ, last_chg_tms, last_chg_usr_id, acgp_oid)
    SELECT acct_grp_oid, 'EIS', 'EIS', 'TOM-3977-ACC', SYSDATE, 'MEMBER', SYSDATE, 'TOM-3977-testing', NEW_OID
    FROM   ft_t_acgr WHERE acct_grp_id = 'TWFACAP3' AND end_tms IS NULL;

    INSERT INTO ft_t_acgp(prnt_acct_grp_oid, acct_org_id, acct_bk_id, acct_id, start_tms, prt_purp_typ, last_chg_tms, last_chg_usr_id, acgp_oid)
    SELECT acct_grp_oid, 'EIS', 'EIS', (select acct_id from ft_t_acid where acct_alt_id = 'TD00107_S' and ACCT_ID_CTXT_TYP = 'CRTSID' and end_tms is null), SYSDATE, 'MEMBER', SYSDATE, 'TOM-3977-testing', NEW_OID
    FROM   ft_t_acgr WHERE acct_grp_id = 'TWFACAP3' AND end_tms IS NULL;

    INSERT INTO ft_t_frap(frap_oid, inst_mnem, org_id, bk_id, acct_id, start_tms, last_chg_tms, last_chg_usr_id, finsrl_typ)
    SELECT NEW_OID, fiid.inst_mnem, 'EIS', 'EIS', 'TOM-3977-ACC', SYSDATE, SYSDATE, 'TOM-3977-testing', 'FUNDADM'
    FROM   ft_t_fiid fiid
    WHERE  fiid.fins_id = 'SSB TW'
    AND    fiid.end_tms IS NULL;

    INSERT INTO ft_t_frap(frap_oid, inst_mnem, org_id, bk_id, acct_id, start_tms, last_chg_tms, last_chg_usr_id, finsrl_typ)
    SELECT NEW_OID, fiid.inst_mnem, 'EIS', 'EIS', (select acct_id from ft_t_acid where acct_alt_id = 'TD00107_S' and ACCT_ID_CTXT_TYP = 'CRTSID' and end_tms is null), SYSDATE, SYSDATE, 'TOM-3977-testing', 'FUNDADM'
    FROM   ft_t_fiid fiid
    WHERE  fiid.fins_id = 'HSBC TW'
    AND    fiid.end_tms IS NULL;
    """

  Scenario: TC_2: Extract port group participants for domestic fund group

    Given I assign "tests/test-data/dmp-interfaces/Taiwan/PortfolioGroup" to variable "testdata.path"
    And I generate value with date format "YYYYMMdd" and assign to variable "VAR_SYSDATE"
    And I assign "domestic_port_group_participants" to variable "PUBLISHING_FILE_NAME"
    And I assign "/dmp/out/ssb" to variable "PUBLISHING_DIR"

    And I remove below files in the host "dmp.ssh.outbound" from folder "${PUBLISHING_DIR}" if exists:
      | ${PUBLISHING_FILE_NAME}_*.csv |

    When I process publishing wrapper with below parameters and wait for the job to be completed
      | PUBLISHING_FILE_NAME | ${PUBLISHING_FILE_NAME}.csv       |
      | SUBSCRIPTION_NAME    | EITW_DMP_TO_SSB_DOMESTIC_PORT_SUB |

    Then I expect below files to be present in the host "dmp.ssh.outbound" into folder "${PUBLISHING_DIR}" after processing:
      | ${PUBLISHING_FILE_NAME}_${VAR_SYSDATE}_1.csv |

  Scenario: TC_3: Reconcile port group extract with expected output

    Given I copy files below from remote folder "${PUBLISHING_DIR}" on host "dmp.ssh.outbound" into local folder "${testdata.path}/outfiles":
      | ${PUBLISHING_FILE_NAME}_${VAR_SYSDATE}_1.csv |

    Then I expect reconciliation should be successful between given CSV files
      | ActualFile   | ${testdata.path}/outfiles/${PUBLISHING_FILE_NAME}_${VAR_SYSDATE}_1.csv |
      | ExpectedFile | ${testdata.path}/template/expected_port_group_participants.csv         |

  Scenario: TC_4: Extract port group participants for overseas fund group

    Given I assign "tests/test-data/dmp-interfaces/Taiwan/PortfolioGroup" to variable "testdata.path"
    And I generate value with date format "YYYYMMdd" and assign to variable "VAR_SYSDATE"
    And I assign "overseas_port_group_participants" to variable "PUBLISHING_FILE_NAME"
    And I assign "/dmp/out/ssb" to variable "PUBLISHING_DIR"

    And I remove below files in the host "dmp.ssh.outbound" from folder "${PUBLISHING_DIR}" if exists:
      | ${PUBLISHING_FILE_NAME}_*.csv |

    When I process publishing wrapper with below parameters and wait for the job to be completed
      | PUBLISHING_FILE_NAME | ${PUBLISHING_FILE_NAME}.csv       |
      | SUBSCRIPTION_NAME    | EITW_DMP_TO_SSB_OVERSEAS_PORT_SUB |

    Then I expect below files to be present in the host "dmp.ssh.outbound" into folder "${PUBLISHING_DIR}" after processing:
      | ${PUBLISHING_FILE_NAME}_${VAR_SYSDATE}_1.csv |

  Scenario: TC_5: Reconcile port group extract with expected output

    Given I copy files below from remote folder "${PUBLISHING_DIR}" on host "dmp.ssh.outbound" into local folder "${testdata.path}/outfiles":
      | ${PUBLISHING_FILE_NAME}_${VAR_SYSDATE}_1.csv |

    Then I expect reconciliation should be successful between given CSV files
      | ActualFile   | ${testdata.path}/outfiles/${PUBLISHING_FILE_NAME}_${VAR_SYSDATE}_1.csv |
      | ExpectedFile | ${testdata.path}/template/expected_port_group_participants.csv         |

  Scenario: TC_6: Extract port group participants for Adhoc publishing job

    Given I assign "adhoc_port_group_participants" to variable "PUBLISHING_ADHOC_FILE_NAME"

    And I remove below files in the host "dmp.ssh.outbound" from folder "${PUBLISHING_DIR}" if exists:
      | ${PUBLISHING_ADHOC_FILE_NAME}_*.csv |

    When I process publishing wrapper with below parameters and wait for the job to be completed
      | PUBLISHING_FILE_NAME | ${PUBLISHING_ADHOC_FILE_NAME}.csv |
      | SUBSCRIPTION_NAME    | EITW_DMP_TO_SSB_PORT_ADHOC_SUB    |
      | RUNTIME_CHAR_VAL_TXT | TOM-3977-CRTS                     |

    Then I expect below files to be present in the host "dmp.ssh.outbound" into folder "${PUBLISHING_DIR}" after processing:
      | ${PUBLISHING_ADHOC_FILE_NAME}_${VAR_SYSDATE}_1.csv |

  Scenario: TC_7: Reconcile port group extract with expected output

    Given I copy files below from remote folder "${PUBLISHING_DIR}" on host "dmp.ssh.outbound" into local folder "${testdata.path}/outfiles":
      | ${PUBLISHING_ADHOC_FILE_NAME}_${VAR_SYSDATE}_1.csv |

    Then I expect reconciliation should be successful between given CSV files
      | ActualFile   | ${testdata.path}/outfiles/${PUBLISHING_ADHOC_FILE_NAME}_${VAR_SYSDATE}_1.csv |
      | ExpectedFile | ${testdata.path}/template/expected_adhoc_port_group_participants.csv         |

  Scenario: TC_6: Teardown test data for overseas fund group

    Given I execute below query
    """
    DELETE ft_t_frap WHERE last_chg_usr_id = 'TOM-3977-testing';
    DELETE ft_t_acgp WHERE last_chg_usr_id = 'TOM-3977-testing';
    DELETE ft_t_acid WHERE last_chg_usr_id = 'TOM-3977-testing';
    DELETE ft_t_acct WHERE last_chg_usr_id = 'TOM-3977-testing';
    DELETE ft_t_acgr WHERE last_chg_usr_id = 'TOM-3977-testing';
    UPDATE ft_t_acgr SET acct_grp_id = 'TWFACAP1' WHERE acct_grp_id = 'TWFACAP1X' AND end_tms IS NULL;
    UPDATE ft_t_acgr SET acct_grp_id = 'TWFACAP2' WHERE acct_grp_id = 'TWFACAP2X' AND end_tms IS NULL;
    UPDATE ft_t_acgr SET acct_grp_id = 'TWFACAP3' WHERE acct_grp_id = 'TWFACAP3X' AND end_tms IS NULL;
    """