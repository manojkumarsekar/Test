# =====================================================================
# Date            JIRA        Comments
# ============    ========    ========
# 14/08/2018      TOM-3497    Filter BNP poistion fx / non fx file based on latam / non latam
# =====================================================================

@gc_interface_positions
@dmp_regression_integrationtest
@tom_3497 @1001_esi_bnp_positions_load
Feature: ESI BNP positions data load

  1.	Load the Sample “SDP_3” file using EIS_MT_BNP_SOD_POSITIONNONFX_NONLATAM message type , all the records should be filtered out.
  2.	Load the Sample “SDP_3” file using EIS_MT_BNP_SOD_POSITIONNONFX_LATAM  message type , all the STOCK records should be loaded.
  3.	Load the Sample “POS_3” file using EIS_MT_BNP_SOD_POSITIONFX_NONLATAM message type , all the records should be filtered out.
  4.	Load the Sample “POS_3” file using EIS_MT_BNP_SOD_POSITIONFX_LATAM message type , all the FX and ACCOUNT records should be loaded.
  5.	Load the Sample “SDP_1” file using EIS_MT_BNP_SOD_POSITIONNONFX_LATAM message type , all the records should be filtered out.
  6.	Load the Sample “SDP_1” file using EIS_MT_BNP_SOD_POSITIONNONFX_NONLATAM message type , all the STOCK records should be loaded.
  7.	Load the Sample “POS_1” file using EIS_MT_BNP_SOD_POSITIONFX_LATAM message type , all the records should be filtered out.
  8.	Load the Sample “POS_1” file using EIS_MT_BNP_SOD_POSITIONFX_NONLATAM message type ,all the FX and ACCOUNT records should be loaded.
  9.	Load the Sample ESISODP_SDP_MISSING_PORTFOLIO.out ( STOCK asset type ) file using EIS_MT_BNP_SOD_POSITIONNONFX_LATAM message type , the missing portfolio should error out.
  10.	Load the Sample ESISODP_SDP_MISSING_PORTFOLIO.out ( STOCK asset type )file using EIS_MT_BNP_SOD_POSITIONNONFX_NONLATAM message type , the missing portfolio should error out.
  11.	Load the Sample ESISODP_SDP_MISSING_FLAG.out ( STOCK asset type )file using EIS_MT_BNP_SOD_POSITIONNONFX_NONLATAM message type , the missing flag should warning should be thrown.


  Scenario: TC_1: Assign the values

    Given I assign "ESISODP_SDP_3.out" to variable "INPUT_FILENAME_SDP_3"
    And I assign "ESISODP_POS_3.out" to variable "INPUT_FILENAME_POS_3"
    And I assign "ESISODP_SDP_1.out" to variable "INPUT_FILENAME_SDP_1"
    And I assign "ESISODP_POS_1.out" to variable "INPUT_FILENAME_POS_1"
    And I assign "ESISODP_SDP_MISSING_PORTFOLIO.out" to variable "INPUT_FILENAME_ERR"
    And I assign "ESISODP_SDP_MISSING_FLAG.out" to variable "INPUT_FILENAME_MISFLG"
    And I assign "tests/test-data/DevTest/TOM-3497" to variable "testdata.path"

  Scenario: TC_2: Load BNP SDP_3  File using message type EIS_MT_BNP_SOD_POSITIONNONFX_NONLATAM and verify records in DMP

    Given I copy files below from local folder "${testdata.path}/testdata" to the host "dmp.ssh.inbound" folder "${dmp.ssh.inbound.path}":
      | ${INPUT_FILENAME_SDP_3} |

    When I process files with below parameters and wait for the job to be completed
      | BUSINESS_FEED |                                       |
      | FILE_PATTERN  | ${INPUT_FILENAME_SDP_3}               |
      | MESSAGE_TYPE  | EIS_MT_BNP_SOD_POSITIONNONFX_NONLATAM |

    Then I extract new job id from jblg table into a variable "JOB_ID"

    # Validation: All the records should be filtered
    Then I expect value of column "FLAG" in the below SQL query equals to "true":
        """
		select 'true' FLAG  From gs_Gc.ft_t_jblg where job_id = '${JOB_ID}' and TASK_TOT_CNT = TASK_FILTERED_CNT
        """

  Scenario: TC_3: Load BNP SDP_3  File using message type EIS_MT_BNP_SOD_POSITIONNONFX_LATAM and verify records in DMP

    Given I copy files below from local folder "${testdata.path}/testdata" to the host "dmp.ssh.inbound" folder "${dmp.ssh.inbound.path}":
      | ${INPUT_FILENAME_SDP_3} |

    When I process files with below parameters and wait for the job to be completed
      | BUSINESS_FEED |                                    |
      | FILE_PATTERN  | ${INPUT_FILENAME_SDP_3}            |
      | MESSAGE_TYPE  | EIS_MT_BNP_SOD_POSITIONNONFX_LATAM |

    Then I extract new job id from jblg table into a variable "JOB_ID"

    # Validation: All the records should be loaded
    Then I expect value of column "FLAG" in the below SQL query equals to "true":
        """
		select 'true' FLAG  From gs_Gc.ft_t_jblg where job_id = '${JOB_ID}' and TASK_TOT_CNT = TASK_SUCCESS_CNT + TASK_FAILED_CNT + TASK_PARTIAL_CNT + TASK_FILTERED_CNT
        """

  Scenario: TC_4: Load BNP POS_3  File using message type EIS_MT_BNP_SOD_POSITIONFX_NONLATAM and verify records in DMP

    Given I copy files below from local folder "${testdata.path}/testdata" to the host "dmp.ssh.inbound" folder "${dmp.ssh.inbound.path}":
      | ${INPUT_FILENAME_POS_3} |

    When I process files with below parameters and wait for the job to be completed
      | BUSINESS_FEED |                                    |
      | FILE_PATTERN  | ${INPUT_FILENAME_POS_3}            |
      | MESSAGE_TYPE  | EIS_MT_BNP_SOD_POSITIONFX_NONLATAM |

    Then I extract new job id from jblg table into a variable "JOB_ID"

    # Validation: All the records should be filtered
    Then I expect value of column "FLAG" in the below SQL query equals to "true":
        """
		select 'true' FLAG  From gs_Gc.ft_t_jblg where job_id = '${JOB_ID}' and TASK_TOT_CNT = TASK_FILTERED_CNT
        """

  Scenario: TC_5: Load BNP POS_3 File using message type EIS_MT_BNP_SOD_POSITIONFX_LATAM and verify records in DMP

    Given I copy files below from local folder "${testdata.path}/testdata" to the host "dmp.ssh.inbound" folder "${dmp.ssh.inbound.path}":
      | ${INPUT_FILENAME_POS_3} |

    When I process files with below parameters and wait for the job to be completed
      | BUSINESS_FEED |                                 |
      | FILE_PATTERN  | ${INPUT_FILENAME_POS_3}         |
      | MESSAGE_TYPE  | EIS_MT_BNP_SOD_POSITIONFX_LATAM |

    Then I extract new job id from jblg table into a variable "JOB_ID"

    # Validation: All the FX records should be loaded and 10 NON FX records should be filtered.
    Then I expect value of column "FLAG" in the below SQL query equals to "true":
        """
		select 'true' FLAG  From gs_Gc.ft_t_jblg where job_id = '${JOB_ID}' and TASK_TOT_CNT = TASK_SUCCESS_CNT + TASK_FAILED_CNT + TASK_PARTIAL_CNT + TASK_FILTERED_CNT and TASK_FILTERED_CNT = 10
        """

  Scenario: TC_6: Load BNP SDP_1 File using message type EIS_MT_BNP_SOD_POSITIONNONFX_LATAM and verify records in DMP

    Given I copy files below from local folder "${testdata.path}/testdata" to the host "dmp.ssh.inbound" folder "${dmp.ssh.inbound.path}":
      | ${INPUT_FILENAME_SDP_1} |

    When I process files with below parameters and wait for the job to be completed
      | BUSINESS_FEED |                                    |
      | FILE_PATTERN  | ${INPUT_FILENAME_SDP_1}            |
      | MESSAGE_TYPE  | EIS_MT_BNP_SOD_POSITIONNONFX_LATAM |

    Then I extract new job id from jblg table into a variable "JOB_ID"

    # Validation: All the records should be filtered
    Then I expect value of column "FLAG" in the below SQL query equals to "true":
        """
		select 'true' FLAG  From gs_Gc.ft_t_jblg where job_id = '${JOB_ID}' and TASK_TOT_CNT = TASK_FILTERED_CNT
        """

  Scenario: TC_7: Load BNP SDP_1 File using message type EIS_MT_BNP_SOD_POSITIONNONFX_NONLATAM and verify records in DMP

    Given I copy files below from local folder "${testdata.path}/testdata" to the host "dmp.ssh.inbound" folder "${dmp.ssh.inbound.path}":
      | ${INPUT_FILENAME_SDP_1} |

    When I process files with below parameters and wait for the job to be completed
      | BUSINESS_FEED |                                       |
      | FILE_PATTERN  | ${INPUT_FILENAME_SDP_1}               |
      | MESSAGE_TYPE  | EIS_MT_BNP_SOD_POSITIONNONFX_NONLATAM |

    Then I extract new job id from jblg table into a variable "JOB_ID"

    # Validation: All the records should be loaded
    Then I expect value of column "FLAG" in the below SQL query equals to "true":
        """
		select 'true' FLAG  From gs_Gc.ft_t_jblg where job_id = '${JOB_ID}' and TASK_TOT_CNT = TASK_SUCCESS_CNT + TASK_FAILED_CNT + TASK_PARTIAL_CNT + TASK_FILTERED_CNT
        """

  Scenario: TC_8: Load BNP POS_1 File using message type EIS_MT_BNP_SOD_POSITIONFX_LATAM and verify records in DMP

    Given I copy files below from local folder "${testdata.path}/testdata" to the host "dmp.ssh.inbound" folder "${dmp.ssh.inbound.path}":
      | ${INPUT_FILENAME_POS_1} |

    When I process files with below parameters and wait for the job to be completed
      | BUSINESS_FEED |                                 |
      | FILE_PATTERN  | ${INPUT_FILENAME_POS_1}         |
      | MESSAGE_TYPE  | EIS_MT_BNP_SOD_POSITIONFX_LATAM |

    Then I extract new job id from jblg table into a variable "JOB_ID"

    # Validation: All the records should be filtered
    Then I expect value of column "FLAG" in the below SQL query equals to "true":
        """
		select 'true' FLAG  From gs_Gc.ft_t_jblg where job_id = '${JOB_ID}' and TASK_TOT_CNT = TASK_FILTERED_CNT
        """

  Scenario: TC_9: Load BNP POS_1 File using message type EIS_MT_BNP_SOD_POSITIONFX_NONLATAM and verify records in DMP

    Given I copy files below from local folder "${testdata.path}/testdata" to the host "dmp.ssh.inbound" folder "${dmp.ssh.inbound.path}":
      | ${INPUT_FILENAME_POS_1} |

    When I process files with below parameters and wait for the job to be completed
      | BUSINESS_FEED |                                    |
      | FILE_PATTERN  | ${INPUT_FILENAME_POS_1}            |
      | MESSAGE_TYPE  | EIS_MT_BNP_SOD_POSITIONFX_NONLATAM |

    Then I extract new job id from jblg table into a variable "JOB_ID"

    # Validation: All the FX records should be loaded and 10 NON FX records should be filtered.
    Then I expect value of column "FLAG" in the below SQL query equals to "true":
        """
		select 'true' FLAG  From gs_Gc.ft_t_jblg where job_id = '${JOB_ID}' and TASK_TOT_CNT = TASK_SUCCESS_CNT + TASK_FAILED_CNT + TASK_PARTIAL_CNT + TASK_FILTERED_CNT and TASK_FILTERED_CNT = 10
        """

  Scenario: TC_10: Load the Sample ESISODP_SDP_MISSING_PORTFOLIO.out file using EIS_MT_BNP_SOD_POSITIONNONFX_NONLATAM message type , the missing portfolio should error out.

    Given I copy files below from local folder "${testdata.path}/testdata" to the host "dmp.ssh.inbound" folder "${dmp.ssh.inbound.path}":
      | ${INPUT_FILENAME_ERR} |

    When I process files with below parameters and wait for the job to be completed
      | BUSINESS_FEED |                                       |
      | FILE_PATTERN  | ${INPUT_FILENAME_ERR}                 |
      | MESSAGE_TYPE  | EIS_MT_BNP_SOD_POSITIONNONFX_NONLATAM |

    Then I extract new job id from jblg table into a variable "JOB_ID"

    # Validation:  Check record should fail since portfolio is missing in the database.
    Then I expect value of column "FLAG" in the below SQL query equals to "true":
        """
		select 'true' FLAG  From gs_gc.ft_t_jblg j , gs_gc.ft_t_trid t , gs_gc.ft_t_ntel n where j.job_id = '${JOB_ID}' and t.job_id = j.job_id and n.last_chg_trn_id = t.trn_id and PARM_VAL_TXT = 'BNPPRTID TEST-3497 BNP AccountAlternateIdentifier'
        """

  Scenario: TC_11: Load the Sample ESISODP_SDP_MISSING_PORTFOLIO.out file using EIS_MT_BNP_SOD_POSITIONNONFX_LATAM message type , the missing portfolio should error out.

    Given I copy files below from local folder "${testdata.path}/testdata" to the host "dmp.ssh.inbound" folder "${dmp.ssh.inbound.path}":
      | ${INPUT_FILENAME_ERR} |

    When I process files with below parameters and wait for the job to be completed
      | BUSINESS_FEED |                                    |
      | FILE_PATTERN  | ${INPUT_FILENAME_ERR}              |
      | MESSAGE_TYPE  | EIS_MT_BNP_SOD_POSITIONNONFX_LATAM |

    Then I extract new job id from jblg table into a variable "JOB_ID"

    # Validation:  Check record should fail since portfolio is missing in the database.
    Then I expect value of column "FLAG" in the below SQL query equals to "true":
        """
		select 'true' FLAG  From gs_gc.ft_t_jblg j , gs_gc.ft_t_trid t , gs_gc.ft_t_ntel n where j.job_id = '${JOB_ID}' and t.job_id = j.job_id and n.last_chg_trn_id = t.trn_id and PARM_VAL_TXT = 'BNPPRTID TEST-3497 BNP AccountAlternateIdentifier'
        """

  Scenario: TC_11: Load the Sample ESISODP_SDP_MISSING_FLAG.out file using EIS_MT_BNP_SOD_POSITIONNONFX_LATAM message type , the missing flag warning should shown..

    #Pre-requisite : Delete configuration
    Given I execute below query
	"""
    DELETE FT_T_ACGU WHERE ACCT_ID IN (SELECT ACCT_ID FROM FT_T_ACID WHERE ACCT_ALT_ID = 'ALAIGB') AND ACCT_GU_PURP_TYP = 'POS_SEGR';
    COMMIT
    """

    Given I copy files below from local folder "${testdata.path}/testdata" to the host "dmp.ssh.inbound" folder "${dmp.ssh.inbound.path}":
      | ${INPUT_FILENAME_MISFLG} |

    When I process files with below parameters and wait for the job to be completed
      | BUSINESS_FEED |                                    |
      | FILE_PATTERN  | ${INPUT_FILENAME_MISFLG}           |
      | MESSAGE_TYPE  | EIS_MT_BNP_SOD_POSITIONNONFX_LATAM |

    Then I extract new job id from jblg table into a variable "JOB_ID"

    # Validation:  Check record should fail since portfolio is missing in the database.
    Then I expect value of column "FLAG" in the below SQL query equals to "true":
        """
		select 'true' FLAG  From gs_gc.ft_t_jblg j , gs_gc.ft_t_trid t , gs_gc.ft_t_ntel n where j.job_id = '${JOB_ID}' and t.job_id = j.job_id and n.last_chg_trn_id = t.trn_id and PARM_VAL_TXT =  'User defined Error thrown! . LATAM NONLATAM FLAG missing for the portfolio ALAIGB' and MSG_SEVERITY_CDE = 30
        """
																																																																		