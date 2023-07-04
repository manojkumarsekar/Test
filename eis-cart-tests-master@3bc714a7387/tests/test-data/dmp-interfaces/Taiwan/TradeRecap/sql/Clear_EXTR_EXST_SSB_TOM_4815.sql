UPDATE ft_t_etid
    SET
        end_tms = SYSDATE
WHERE
    exec_trn_id IN (
        '4815-4815',
        '4815-4815_TD',
        '4815-4815_REPO',
        '4815-4815_COLL',
        '4815-4815_FX'
    )
    AND   exec_trn_id_ctxt_typ IN (
        'BRSTRNID'
    )
    AND   end_tms IS NULL;


DELETE ft_t_etid
WHERE
    etid_oid IN (
        SELECT
            trdnum.etid_oid
        FROM
            ft_t_etid trdnum,
            ft_t_etid brsnum
        WHERE
            trdnum.exec_trn_id IN (
                '4815','1983'
            )
            AND   trdnum.exec_trn_id_ctxt_typ = 'BRSTRADENUM'
            AND   trdnum.exec_trd_id = brsnum.exec_trd_id
            AND   brsnum.exec_trn_id IN (
                '4815-4815',
                '4815-4815_TD',
                '4815-4815_REPO',
                '4815-4815_COLL',
                '4815-4815_FX'
            )
            AND   brsnum.exec_trn_id_ctxt_typ = 'BRSTRNID'
    );

UPDATE ft_t_extr
    SET
        end_tms = SYSDATE
WHERE
    trd_id IN (
        '4815-4815',
        '4815-4815_TD',
                                      '4815-4815_REPO',
                                      '4815-4815_COLL',
                                      '4815-4815_FX'
    )
    AND   end_tms IS NULL;

UPDATE FT_T_ACID SET END_TMS = SYSDATE WHERE ACCT_ID IN (SELECT ACCT_ID FROM FT_T_ACID WHERE ACCT_ALT_ID in ( 'TW-MAIN-SITCA-1-4815') and end_tms is null);
UPDATE ft_t_acgp
    SET
        end_tms = SYSDATE
WHERE
    acct_id IN (
        SELECT
            acct_id
        FROM
            ft_t_acid
        WHERE
            acct_id_ctxt_typ = 'CRTSID'
            AND   acct_alt_id = 'Test4815'
            AND   end_tms IS NULL
    )
    AND   prnt_acct_grp_oid IN (
        SELECT
            acct_grp_oid
        FROM
            ft_t_acgr
        WHERE
            grp_nme IN (
                'TWFACAP1',
                'TWFACAP2',
                'TWFACAP3'
            )
            AND   grp_purp_typ = 'UNIVERSE'
            AND   acct_grp_id IN (
                'TWFACAP1',
                'TWFACAP2',
                'TWFACAP3'
            )
    )
    AND   end_tms IS NULL;
    COMMIT;