SELECT
    COUNT(*) AS RECORD_COUNT
FROM
    (
        SELECT
            instance_id
        FROM
            (
                SELECT
                    instance_id
                FROM
                    (
                        SELECT
                            wfri.instance_id,
                            tokn1.instance_id prnt_instance_id
                        FROM
                            ft_wf_wfri wfri
                            LEFT JOIN ft_wf_tokn tokn1 ON ( wfri.prnt_token_id = tokn1.token_id )
                            JOIN ft_wf_wfdf wfdf USING ( workflow_id )
                    ) iview
                CONNECT BY
                    PRIOR instance_id = prnt_instance_id
                START WITH prnt_instance_id = '${flowResultId}'
                UNION
                SELECT
                    instance_id
                FROM
                    ft_wf_wfri wfri
                WHERE
                    wfri.instance_id = '${flowResultId}'
            )
    ) instance_id,
    ft_wf_wfri wfri,
    ft_wf_wfdf wfdf
WHERE
    instance_id.instance_id = wfri.instance_id
    AND   wfri.workflow_id = wfdf.workflow_id
    AND   wfdf.workflow_nme IN (
        'Request Reply',
        'Split Requests',
        'BloombergProcessFiles',
        'BloombergUpDownloadRequestReplySFTP',
        'EIS_BBPerSecurity'
    )
    AND   wfri.wf_runtime_stat_typ = 'DONE'
            
            