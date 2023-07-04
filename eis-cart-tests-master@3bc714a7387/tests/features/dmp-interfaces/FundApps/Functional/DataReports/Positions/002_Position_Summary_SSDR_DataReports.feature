@tom_4542_sum @postn_datareports @tom_5000
  #https://jira.intranet.asia/browse/TOM-4542
  #Position Data report required for SSDR team

Feature: 002 | FundApps | Data Report | Verify Positions Summary Data Report

  The feature file is a basic file to check if the position summary data report is getting generated for SSDR team and therefore this file will not have a reconcilatiaon task

  Scenario: Assign Variables

    Given I assign "tests/test-data/dmp-interfaces/FundApps/Functional/Outbound/DataReports_Positions" to variable "testdata.path"
    And I assign "600" to variable "workflow.max.polling.time"
    And I assign " /dmp/out/eis/datareports" to variable "PUBLISHING_DIRECTORY"
    And I assign "SSDR_Positions_Summary_Report" to variable "PUBLISHING_FILE_NAME"
    And I generate value with date format "YYYYMMdd" and assign to variable "VAR_SYSDATE"
    And I modify date "${VAR_SYSDATE}" with "-1d" from source format "YYYYMMdd" to destination format "dd/MM/YYYY" and assign to "CURR_DATE"
    And I assign "${PUBLISHING_FILE_NAME}*_1.csv" to variable "PUBLISHING_FILE_FULL_NAME"


  Scenario:  Load pre-requisite Fund Data before file


    When I copy files below from local folder "${testdata.path}/inputfiles" to the host "dmp.ssh.inbound" folder "${dmp.ssh.inbound.path}":
      | ESGA-FUND.csv |

    And I process files with below parameters and wait for the job to be completed
      | FILE_PATTERN  | ESGA-FUND.csv        |
      | MESSAGE_TYPE  | EIS_MT_ESGA_DMP_FUND |
      | BUSINESS_FEED |                      |

    Then I extract new job id from jblg table into a variable "JOB_ID"
    And I expect value of column "JBLG_ROW_COUNT" in the below SQL query equals to "1":
      """
      SELECT count(*) as JBLG_ROW_COUNT FROM FT_T_JBLG
      WHERE JOB_ID = '${JOB_ID}'
      AND JOB_STAT_TYP ='CLOSED'
      """

    And I expect value of column "SSH_COUNT" in the below SQL query equals to "2":
      """
      SELECT count(*) as SSH_COUNT FROM FT_T_ACST
      WHERE STAT_DEF_ID in ('SSHFLAG')
      AND STAT_CHAR_VAL_TXT='Y'
      AND ACCT_ID in (select ACCT_ID from ft_t_acid where acct_alt_id in ('300070','600355') and acct_id_ctxt_typ='CRTSID' and end_tms is null)
      """

  Scenario: Load pre-requisite Security Data before file

    When I copy files below from local folder "${testdata.path}/inputfiles" to the host "dmp.ssh.inbound" folder "${dmp.ssh.inbound.path}":

      | ESGA-SECURITY.csv |

    And I process files with below parameters and wait for the job to be completed

      | FILE_PATTERN  | ESGA-SECURITY.csv        |
      | MESSAGE_TYPE  | EIS_MT_ESGA_DMP_SECURITY |
      | BUSINESS_FEED |                          |

    Then I extract new job id from jblg table into a variable "JOB_ID"
    And I expect value of column "JBLG_ROW_COUNT" in the below SQL query equals to "1":
      """
      SELECT count(*) as JBLG_ROW_COUNT FROM FT_T_JBLG
      WHERE JOB_ID = '${JOB_ID}'
      AND JOB_STAT_TYP ='CLOSED'
      """

  Scenario: Create Position file with Position Date as SYSDATE and Load into DMP

    Given I assign "ESGA-POSITION.csv" to variable "INPUT_FILENAME"
    And I assign "ESGA-POSITION_Template.csv" to variable "INPUT_TEMPLATENAME"
    And I create input file "${INPUT_FILENAME}" using template "${INPUT_TEMPLATENAME}" with below codes from location "${testdata.path}/inputfiles"
      |  |  |

  Scenario: TC_8: Load position file

    Given  I copy files below from local folder "${testdata.path}/inputfiles/testdata" to the host "dmp.ssh.inbound" folder "${dmp.ssh.inbound.path}":
      | ${INPUT_FILENAME} |

    When I process files with below parameters and wait for the job to be completed
      | BUSINESS_FEED |                          |
      | FILE_PATTERN  | ESGA-POSITION.csv        |
      | MESSAGE_TYPE  | EIS_MT_ESGA_DMP_POSITION |

  Scenario: TC_9: Triggering Publishing Wrapper Event for CSV file

    Given I remove below files with pattern in the host "dmp.ssh.inbound" from folder "${PUBLISHING_DIRECTORY}" if exists:
      | ${PUBLISHING_FILE_NAME}_*.csv |

    When I process publishing wrapper with below parameters and wait for the job to be completed
      | PUBLISHING_FILE_NAME | ${PUBLISHING_FILE_NAME}.csv            |
      | SUBSCRIPTION_NAME    | EIS_DMP_TO_EIS_POSNSUMMARY_REPORTS_SUB |
      | COLUMN_SEPARATOR     | ,                                      |
      | COLUMN_TO_SORT       | 3                                      |

    Then I expect below files to be present in the host "dmp.ssh.inbound" into folder "${PUBLISHING_DIRECTORY}" after processing:
      | ${PUBLISHING_FILE_FULL_NAME} |

    Then I copy files below from remote folder "${PUBLISHING_DIRECTORY}" on host "dmp.ssh.inbound" into local folder "${testdata.path}/outfiles/runtime":
      | ${PUBLISHING_FILE_FULL_NAME} |


  Scenario: Cleanup max polling time variable
    Then I remove variable "workflow.max.polling.time" from memory