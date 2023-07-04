SELECT Count(1) AS ACGP_PROCESSED_ROW_COUNT
FROM   ft_t_acgp
WHERE  prnt_acct_grp_oid IN (SELECT acct_grp_oid
                             FROM   ft_t_acgr
                             WHERE  grp_nme IN( 'TestGroup1', 'TestGroup2',
                                                'TestGroup3', 'TestGroup4' )) AND end_tms is null