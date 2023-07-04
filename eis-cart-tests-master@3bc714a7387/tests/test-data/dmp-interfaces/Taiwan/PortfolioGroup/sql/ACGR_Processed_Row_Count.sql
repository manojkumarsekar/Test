SELECT Count(1) AS ACGR_PROCESSED_ROW_COUNT
FROM   ft_t_acgr
WHERE  grp_nme IN( 'TestGroup1', 'TestGroup2', 'TestGroup3', 'TestGroup4' ) AND end_tms is null