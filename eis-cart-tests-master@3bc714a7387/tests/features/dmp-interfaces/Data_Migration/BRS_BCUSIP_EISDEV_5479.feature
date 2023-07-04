#eisdev_5479 : New feature file created

@dmp_migration @eisdev_5479
Feature: 001 | Data Migration | BRS BCUSIP
  BALH with Single Record : update_bcusip_balh('ALAHYB', 'BPM2MFTG2', 'BPM2MFUE5');
  BALH with Multiple Record : update_bcusip_balh('PRU_FM_FI_PIF-HIG', '594918CB8', 'BPM16SJS9');
  BALH with No Rows : update_bcusip_balh('PRU_FM_FI_PIF-HIG', '9128284T4', 'INVBCUSIP');
  BALH without portfolio : update_bcusip_balh('', 'BPM33UVG5', 'BPM1AB57P');

  Scenario: Mock up BALH records

    Given I execute below query to "Mock up for BALH with Single Record"
    """
    update ft_t_balh set acct_id = 'GS0000000656', instr_id = '(uB~36R*81', isid_oid = '(uB046R*81' where balh_oid = 'tFDGE6R*81';
    delete ft_t_balh where acct_id = 'GS0000000656' and instr_id = '(uBO48R*81' and isid_oid = '(uBS48R*81';
    COMMIT
    """

    Given I execute below query to "Mock up for BALH with Multiple Record"
    """
    update ft_t_balh set acct_id = 'GS0000000597',instr_id = '3fvVm<nGG2',isid_oid = 'k&3aC3>Dm1' where balh_oid in ('q~3P47>Dm1','7)3fA5NFm1','o(3D97lGm1','i(3)96)Hm1');
    delete ft_t_balh where acct_id = 'GS0000000597' and instr_id = 'aix@n.Mj81' and isid_oid = 'aix.n.Mj81';
    COMMIT
    """

    Given I execute below query to "Mock up for BALH with no rows"
    """
    update ft_t_balh set acct_id = 'GS0000000597',instr_id = 'G(31C2-OO1',isid_oid = 'G(35C2-OO1' where balh_oid in ('(&pgv*%SO1','f-pdv*BUO1');
    COMMIT
    """

    Given I execute below query to "Mock up for BALH with no rows"
    """
    update ft_t_balh set acct_id = 'GS0000000597',instr_id = '$&pHo?%1e1', isid_oid = '$&pLo?%1e1' where balh_oid = '.44I73%1e1';
    update ft_t_balh set acct_id = 'GS0000000738',instr_id = '$&pHo?%1e1', isid_oid = '$&pLo?%1e1' where balh_oid = ')G4k15x5e1';
    COMMIT
    """

  Scenario: Verify BALH with Single Record - Before Migration

    Given I expect value of column "BALH_BPM2MFTG2_BEFORE" in the below SQL query equals to "1":
    """
    select count(*) as BALH_BPM2MFTG2_BEFORE from ft_t_balh balh, ft_t_isid isid, ft_t_acid acid where
    isid.instr_id = balh.instr_id
    and acid.acct_id = balh.acct_id
    and acid.bk_id = balh.bk_id
    and acid.org_id = balh.org_id
    and isid.end_tms is null
    and acid.end_tms is null
    and isid.iss_id = 'BPM2MFTG2'
    and isid.id_ctxt_typ = 'BCUSIP'
    and acid.acct_alt_id = 'ALAHYB'
    and acid.ACCT_ID_CTXT_TYP = 'CRTSID'
    """

    And I expect value of column "BALH_BPM2MFUE5_BEFORE" in the below SQL query equals to "0":
    """
    select count(*) as BALH_BPM2MFUE5_BEFORE from ft_t_balh balh, ft_t_isid isid, ft_t_acid acid where
    isid.instr_id = balh.instr_id
    and acid.acct_id = balh.acct_id
    and acid.bk_id = balh.bk_id
    and acid.org_id = balh.org_id
    and isid.end_tms is null
    and acid.end_tms is null
    and isid.iss_id = 'BPM2MFUE5'
    and isid.id_ctxt_typ = 'BCUSIP'
    and acid.acct_alt_id = 'ALAHYB'
    and acid.ACCT_ID_CTXT_TYP = 'CRTSID'
    """

  Scenario: Verify BALH with Multiple Record - Before Migration

    Given I expect value of column "BALH_594918CB8_BEFORE" in the below SQL query equals to "4":
    """
    select count(*) as BALH_594918CB8_BEFORE from ft_t_balh balh, ft_t_isid isid, ft_t_acid acid where
    isid.instr_id = balh.instr_id
    and acid.acct_id = balh.acct_id
    and acid.bk_id = balh.bk_id
    and acid.org_id = balh.org_id
    and isid.end_tms is null
    and acid.end_tms is null
    and isid.iss_id = '594918CB8'
    and isid.id_ctxt_typ = 'BCUSIP'
    and acid.acct_alt_id = 'PRU_FM_FI_PIF-HIG'
    and acid.ACCT_ID_CTXT_TYP = 'CRTSID'
    """

    And I expect value of column "BALH_BPM16SJS9_BEFORE" in the below SQL query equals to "0":
    """
    select count(*) as BALH_BPM16SJS9_BEFORE from ft_t_balh balh, ft_t_isid isid, ft_t_acid acid where
    isid.instr_id = balh.instr_id
    and acid.acct_id = balh.acct_id
    and acid.bk_id = balh.bk_id
    and acid.org_id = balh.org_id
    and isid.end_tms is null
    and acid.end_tms is null
    and isid.iss_id = 'BPM16SJS9'
    and isid.id_ctxt_typ = 'BCUSIP'
    and acid.acct_alt_id = 'PRU_FM_FI_PIF-HIG'
    and acid.ACCT_ID_CTXT_TYP = 'CRTSID'
    """

  Scenario: Verify BALH with No Rows - Before Migration

    Given I expect value of column "BALH_9128284T4_BEFORE" in the below SQL query equals to "2":
    """
    select count(*) as BALH_9128284T4_BEFORE from ft_t_balh balh, ft_t_isid isid, ft_t_acid acid where
    isid.instr_id = balh.instr_id
    and acid.acct_id = balh.acct_id
    and acid.bk_id = balh.bk_id
    and acid.org_id = balh.org_id
    and isid.end_tms is null
    and acid.end_tms is null
    and isid.iss_id = '9128284T4'
    and isid.id_ctxt_typ = 'BCUSIP'
    and acid.acct_alt_id = 'PRU_FM_FI_PIF-HIG'
    and acid.ACCT_ID_CTXT_TYP = 'CRTSID'
    """

  Scenario: Verify BALH without portfolio

    Given I expect value of column "BALH_BPM33UVG5_BEFORE" in the below SQL query equals to "2":
    """
    select count(*) as BALH_BPM33UVG5_BEFORE from ft_t_balh balh, ft_t_isid isid where
    isid.instr_id = balh.instr_id
    and isid.end_tms is null
    and isid.iss_id = 'BPM33UVG5'
    and isid.id_ctxt_typ = 'BCUSIP'
    """

    And I expect value of column "BALH_BPM1AB57P_BEFORE" in the below SQL query equals to "0":
    """
    select count(*) as BALH_BPM1AB57P_BEFORE from ft_t_balh balh, ft_t_isid isid where
    isid.instr_id = balh.instr_id
    and isid.end_tms is null
    and isid.iss_id = 'BPM1AB57P'
    and isid.id_ctxt_typ = 'BCUSIP'
    """

  Scenario: Execute Migration Script

    Given I execute below queries which are separated by "##"
      | tests/test-data/dmp-interfaces/Data_Migration/BRSBCUSIP_Migration.sql |

  Scenario: Verify BALH with Single Record - After Migration

    Given I expect value of column "BALH_BPM2MFTG2_AFTER" in the below SQL query equals to "0":
    """
    select count(*) as BALH_BPM2MFTG2_AFTER from ft_t_balh balh, ft_t_isid isid, ft_t_acid acid where
    isid.instr_id = balh.instr_id
    and acid.acct_id = balh.acct_id
    and acid.bk_id = balh.bk_id
    and acid.org_id = balh.org_id
    and isid.end_tms is null
    and acid.end_tms is null
    and isid.iss_id = 'BPM2MFTG2'
    and isid.id_ctxt_typ = 'BCUSIP'
    and acid.acct_alt_id = 'ALAHYB'
    and acid.ACCT_ID_CTXT_TYP = 'CRTSID'
    """

    And I expect value of column "BALH_BPM2MFUE5_AFTER" in the below SQL query equals to "1":
    """
    select count(*) as BALH_BPM2MFUE5_AFTER from ft_t_balh balh, ft_t_isid isid, ft_t_acid acid where
    isid.instr_id = balh.instr_id
    and acid.acct_id = balh.acct_id
    and acid.bk_id = balh.bk_id
    and acid.org_id = balh.org_id
    and isid.end_tms is null
    and acid.end_tms is null
    and isid.iss_id = 'BPM2MFUE5'
    and isid.id_ctxt_typ = 'BCUSIP'
    and acid.acct_alt_id = 'ALAHYB'
    and acid.ACCT_ID_CTXT_TYP = 'CRTSID'
    """

  Scenario: Verify BALH with Multiple Record - After Migration

    Given I expect value of column "BALH_594918CB8_AFTER" in the below SQL query equals to "0":
    """
    select count(*) as BALH_594918CB8_AFTER from ft_t_balh balh, ft_t_isid isid, ft_t_acid acid where
    isid.instr_id = balh.instr_id
    and acid.acct_id = balh.acct_id
    and acid.bk_id = balh.bk_id
    and acid.org_id = balh.org_id
    and isid.end_tms is null
    and acid.end_tms is null
    and isid.iss_id = '594918CB8'
    and isid.id_ctxt_typ = 'BCUSIP'
    and acid.acct_alt_id = 'PRU_FM_FI_PIF-HIG'
    and acid.ACCT_ID_CTXT_TYP = 'CRTSID'
    """

    And I expect value of column "BALH_BPM16SJS9_AFTER" in the below SQL query equals to "4":
    """
    select count(*) as BALH_BPM16SJS9_AFTER from ft_t_balh balh, ft_t_isid isid, ft_t_acid acid where
    isid.instr_id = balh.instr_id
    and acid.acct_id = balh.acct_id
    and acid.bk_id = balh.bk_id
    and acid.org_id = balh.org_id
    and isid.end_tms is null
    and acid.end_tms is null
    and isid.iss_id = 'BPM16SJS9'
    and isid.id_ctxt_typ = 'BCUSIP'
    and acid.acct_alt_id = 'PRU_FM_FI_PIF-HIG'
    and acid.ACCT_ID_CTXT_TYP = 'CRTSID'
    """

  Scenario: Verify BALH with No Rows - After Migration

    Given I expect value of column "BALH_9128284T4_AFTER" in the below SQL query equals to "2":
    """
    select count(*) as BALH_9128284T4_AFTER from ft_t_balh balh, ft_t_isid isid, ft_t_acid acid where
    isid.instr_id = balh.instr_id
    and acid.acct_id = balh.acct_id
    and acid.bk_id = balh.bk_id
    and acid.org_id = balh.org_id
    and isid.end_tms is null
    and acid.end_tms is null
    and isid.iss_id = '9128284T4'
    and isid.id_ctxt_typ = 'BCUSIP'
    and acid.acct_alt_id = 'PRU_FM_FI_PIF-HIG'
    and acid.ACCT_ID_CTXT_TYP = 'CRTSID'
    """

  Scenario: Verify BALH without portfolio - After Migration

    Given I expect value of column "BALH_BPM33UVG5_AFTER" in the below SQL query equals to "0":
    """
    select count(*) as BALH_BPM33UVG5_AFTER from ft_t_balh balh, ft_t_isid isid where
    isid.instr_id = balh.instr_id
    and isid.end_tms is null
    and isid.iss_id = 'BPM33UVG5'
    and isid.id_ctxt_typ = 'BCUSIP'
    """

    And I expect value of column "BALH_BPM1AB57P_AFTER" in the below SQL query equals to "2":
    """
    select count(*) as BALH_BPM1AB57P_AFTER from ft_t_balh balh, ft_t_isid isid where
    isid.instr_id = balh.instr_id
    and isid.end_tms is null
    and isid.iss_id = 'BPM1AB57P'
    and isid.id_ctxt_typ = 'BCUSIP'
    """
