UPDATE
    FT_T_EXTR
SET
    TRD_ID = NEW_OID,
    end_tms = sysdate
where
    TRD_ID in (
        '16290-100001',
        '16290-100002',
        '217-100003',
        '217-100004',
        'TF235-100005',
        'TF235-100006',
        'TF200-100007',
        'TF200-100008'
    );