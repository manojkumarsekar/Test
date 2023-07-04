package com.eastspring.tom.cart.dmp.mdl;

public final class WorkflowSpec {

    private WorkflowSpec() {

    }

    public static final String WORKFLOW_CHECK_SQL = "SELECT\n" +
            "        CASE\n" +
            "            WHEN count >= 1 THEN 'FAILED'\n" +
            "            WHEN count = 0  THEN (\n" +
            "                SELECT\n" +
            "                    WF_RUNTIME_STAT_TYP\n" +
            "                FROM\n" +
            "                    ft_wf_wfri\n" +
            "                WHERE\n" +
            "                    instance_id = '${flowResultId}'\n" +
            "            )\n" +
            "        END\n" +
            "    WF_RUNTIME_STAT_TYP\n" +
            "FROM\n" +
            "    (\n" +
            "        SELECT\n" +
            "            COUNT(*) count\n" +
            "        FROM\n" +
            "            (\n" +
            "                SELECT\n" +
            "                    instance_id\n" +
            "                FROM\n" +
            "                    (\n" +
            "                        SELECT\n" +
            "                            instance_id\n" +
            "                        FROM\n" +
            "                            (\n" +
            "                                SELECT\n" +
            "                                    wfri.instance_id,\n" +
            "                                    tokn1.instance_id prnt_instance_id\n" +
            "                                FROM\n" +
            "                                    ft_wf_wfri wfri\n" +
            "                                    LEFT JOIN ft_wf_tokn tokn1 ON ( wfri.prnt_token_id = tokn1.token_id )\n" +
            "                                    JOIN ft_wf_wfdf wfdf USING ( workflow_id )\n" +
            "                            ) iview\n" +
            "                        CONNECT BY\n" +
            "                            PRIOR instance_id = prnt_instance_id\n" +
            "                        START WITH prnt_instance_id = '${flowResultId}'\n" +
            "                        UNION\n" +
            "                        SELECT\n" +
            "                            instance_id\n" +
            "                        FROM\n" +
            "                            ft_wf_wfri wfri\n" +
            "                        WHERE\n" +
            "                            wfri.instance_id = '${flowResultId}'\n" +
            "                    )\n" +
            "            ) instance_id,\n" +
            "            ft_wf_wfri wfri, ft_wf_tokn tokn\n" +
            "            WHERE tokn.instance_id = wfri.instance_id\n" +
            "            AND instance_id.instance_id = wfri.instance_id\n" +
            "            AND TOKEN_STAT_TYP = 'FAILED'\n" +
            "    )";
}
