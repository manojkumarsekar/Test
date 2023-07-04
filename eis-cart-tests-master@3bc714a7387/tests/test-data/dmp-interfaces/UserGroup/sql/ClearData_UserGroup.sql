DELETE ft_t_fpid
WHERE
    fpro_oid IN (
        SELECT
            fpro_oid
        FROM
            ft_t_fpro
        WHERE
            fins_pro_id_ctxt_typ = 'INTERNAL' and fins_pro_id in('test3.user3@eastspring.com','test4.user4@eastspring.com','test5.user5@eastspring.com')
    );

DELETE ft_t_fpgu
WHERE
    fpro_oid IN (
        SELECT
            fpro_oid
        FROM
            ft_t_fpro
        WHERE
            fins_pro_id_ctxt_typ = 'INTERNAL' and fins_pro_id in('test3.user3@eastspring.com','test4.user4@eastspring.com','test5.user5@eastspring.com')
    );

DELETE ft_t_adtp
WHERE
    fpro_oid IN (
        SELECT
            fpro_oid
        FROM
            ft_t_fpro
        WHERE
            fins_pro_id_ctxt_typ = 'INTERNAL' and fins_pro_id in('test3.user3@eastspring.com','test4.user4@eastspring.com','test5.user5@eastspring.com')
    );

DELETE ft_t_acta
WHERE
    fpro_oid IN (
        SELECT
            fpro_oid
        FROM
            ft_t_fpro
        WHERE
            fins_pro_id_ctxt_typ = 'INTERNAL' and fins_pro_id in('test3.user3@eastspring.com','test4.user4@eastspring.com','test5.user5@eastspring.com')
    );

DELETE ft_t_aopt
WHERE
    fpro_oid IN (
        SELECT
            fpro_oid
        FROM
            ft_t_fpro
        WHERE
            fins_pro_id_ctxt_typ = 'INTERNAL' and fins_pro_id in('test3.user3@eastspring.com','test4.user4@eastspring.com','test5.user5@eastspring.com')
    );

DELETE ft_t_fptr
WHERE
    fpro_oid IN (
        SELECT
            fpro_oid
        FROM
            ft_t_fpro
        WHERE
            fins_pro_id_ctxt_typ = 'INTERNAL' and fins_pro_id in('test3.user3@eastspring.com','test4.user4@eastspring.com','test5.user5@eastspring.com')
    );

DELETE ft_t_fpro WHERE
    fins_pro_id_ctxt_typ = 'INTERNAL' and fins_pro_id in('test3.user3@eastspring.com','test4.user4@eastspring.com','test5.user5@eastspring.com');

COMMIT;