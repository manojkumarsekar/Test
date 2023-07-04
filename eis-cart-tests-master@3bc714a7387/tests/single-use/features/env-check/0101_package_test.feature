Feature: This Feature is to test GS Auto Deployment to production pipeline

  @tom-3732
  Scenario: Verify Package status

    Then I expect value of column "job_stat_typ" in the below SQL query equals to "CLOSED":
      """
      SELECT job_stat_typ FROM ft_t_jblg WHERE job_id = '++DUMMY++'
      """
