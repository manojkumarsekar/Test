#https://jira.intranet.asia/browse/TOM-4618
#https://collaborate.intranet.asia/display/TOM/R5.IN-CASH1+OCR-DMP+EOD+Cash+Statement
#TOM-4618 : R5.IN-CashStatement -> DMP file transfer to BNP (GS)

@tom_4618 @dmp_portfolio_group
Feature: Outbound Portfolio Group Interface Testing for BNP TW

  Confirm subscription profile for BNP site fund portfolio group generates expected file.

  Scenario: TC_1: Set up test data for BNP site fund group

    Given I execute below query
    """
    UPDATE ft_t_acgr SET acct_grp_id = 'ESI_BNPX' WHERE acct_grp_id = 'ESI_BNP' AND end_tms IS NULL;

    INSERT INTO ft_t_acgr(acct_grp_oid, acct_grp_id, grp_purp_typ, start_tms, last_chg_tms, last_chg_usr_id, grp_desc, grp_nme, data_stat_typ, data_src_id)
    VALUES (NEW_OID, 'ESI_BNP', 'BRSFNDGP', SYSDATE, SYSDATE, 'TOM-4618-testing', 'Test port group participant extract', 'Test port group participant extract', 'ACTIVE', 'BRS');

    INSERT INTO ft_t_acct(org_id, bk_id, acct_id, acct_open_dte, acct_stat_typ, cross_ref_id, last_chg_tms, last_chg_usr_id, acct_nme)
    VALUES ('EIS', 'EIS', 'TOM-4618-ACC', SYSDATE, 'OPEN', NEW_OID, SYSDATE, 'TOM-4618-testing', 'Test portfolio for TOM-4618');

    INSERT INTO ft_t_acid(acid_oid, org_id, bk_id, acct_id, acct_id_ctxt_typ, acct_alt_id, start_tms, last_chg_tms, last_chg_usr_id, acct_cross_ref_id)
    SELECT NEW_OID, org_id, bk_id, acct_id, 'CRTSID', 'TOM-4618-CRTS', SYSDATE, SYSDATE, 'TOM-4618-testing', cross_ref_id
    FROM   ft_t_acct WHERE acct_id =  'TOM-4618-ACC';

    INSERT INTO ft_t_acid(acid_oid, org_id, bk_id, acct_id, acct_id_ctxt_typ, acct_alt_id, start_tms, last_chg_tms, last_chg_usr_id, acct_cross_ref_id)
    SELECT NEW_OID, org_id, bk_id, acct_id, 'SITCAFNDID', 'TOM-4618-SITCA', SYSDATE, SYSDATE, 'TOM-4618-testing', cross_ref_id
    FROM   ft_t_acct WHERE acct_id = 'TOM-4618-ACC';

    INSERT INTO ft_t_acgp(prnt_acct_grp_oid, acct_org_id, acct_bk_id, acct_id, start_tms, prt_purp_typ, last_chg_tms, last_chg_usr_id, acgp_oid)
    SELECT acct_grp_oid, 'EIS', 'EIS', 'TOM-4618-ACC', SYSDATE, 'MEMBER', SYSDATE, 'TOM-4618-testing', NEW_OID
    FROM   ft_t_acgr WHERE acct_grp_id = 'ESI_BNP' AND end_tms IS NULL;
    """

  Scenario: TC_2: Extract participants for BNP site fund portfolio group

    Given I assign "tests/test-data/dmp-interfaces/Taiwan/PortfolioGroup" to variable "testdata.path"
    And I generate value with date format "YYYYMMdd" and assign to variable "VAR_SYSDATE"
    And I assign "esi_bnp_site_funds" to variable "PUBLISHING_FILE_NAME"
    And I assign "/dmp/out/bnp" to variable "PUBLISHING_DIR"

    And I remove below files in the host "dmp.ssh.outbound" from folder "${PUBLISHING_DIR}" if exists:
      | ${PUBLISHING_FILE_NAME}_*.csv |

    When I process publishing wrapper with below parameters and wait for the job to be completed
      | PUBLISHING_FILE_NAME | ${PUBLISHING_FILE_NAME}.csv   |
      | SUBSCRIPTION_NAME    | EITW_DMP_TO_BNP_SITE_FUND_SUB |

    Then I expect below files to be present in the host "dmp.ssh.outbound" into folder "${PUBLISHING_DIR}" after processing:
      | ${PUBLISHING_FILE_NAME}_${VAR_SYSDATE}_1.csv |

  Scenario: TC_3: Reconcile port group extract with expected output

    Given I copy files below from remote folder "${PUBLISHING_DIR}" on host "dmp.ssh.outbound" into local folder "${testdata.path}/outfiles":
      | ${PUBLISHING_FILE_NAME}_${VAR_SYSDATE}_1.csv |

    Then I expect reconciliation between generated CSV file "${testdata.path}/outfiles/${PUBLISHING_FILE_NAME}_${VAR_SYSDATE}_1.csv" and reference CSV file "${testdata.path}/template/expected_esi_bnp_site_funds.csv" should be successful and exceptions to be written to "${testdata.path}/outfiles/exceptions_${recon.timestamp}.csv" file

  Scenario: TC_4: Teardown test data for BNP site fund portfolio group

    Given I execute below query
    """
    DELETE ft_t_acgp WHERE last_chg_usr_id = 'TOM-4618-testing';
    DELETE ft_t_acid WHERE last_chg_usr_id = 'TOM-4618-testing';
    DELETE ft_t_acct WHERE last_chg_usr_id = 'TOM-4618-testing';
    DELETE ft_t_acgr WHERE last_chg_usr_id = 'TOM-4618-testing';
    UPDATE ft_t_acgr SET acct_grp_id = 'ESI_BNP' WHERE acct_grp_id = 'ESI_BNPX' AND end_tms IS NULL;
    """