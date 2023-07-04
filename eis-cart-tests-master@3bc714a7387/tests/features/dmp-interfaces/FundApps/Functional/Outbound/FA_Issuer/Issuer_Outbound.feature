#https://jira.intranet.asia/browse/TOM-4955
#This outbound file is sent to FundApps having Reuters Issuer information.
# The extract criteria of this file is those Reuters issuers which are related to the instruments for the positions of that day

@tom_4955

Feature: 001 | FundApps | Verify Outbound Issuers for FundApps

  Scenario: Assign Variables
    Given I assign "tests/test-data/dmp-interfaces/FundApps/Functional/Issuer" to variable "TESTDATA_PATH"
    And I generate value with date format "YYYYMMdd" and assign to variable "VAR_SYSDATE"
    And I assign "/dmp/out/fundapps" to variable "PUBLISHING_DIRECTORY"
    And I assign "300" to variable "workflow.max.polling.time"
    And I assign "FA_ISSR" to variable "FAISSR_PUBLISHING_FILE_NAME"
    And I generate value with date format "YYYYMMdd" and assign to variable "VAR_SYSDATE"

  Scenario: Load pre-requisite TMBAM Fund Data before TMBAM Security file

    When I copy files below from local folder "${TESTDATA_PATH}/inputfiles/TMBAM" to the host "dmp.ssh.inbound" folder "${dmp.ssh.inbound.path}":
      | TMBAM-FUND.csv |

    And I process files with below parameters and wait for the job to be completed
      | FILE_PATTERN  | TMBAM-FUND.csv        |
      | MESSAGE_TYPE  | EIS_MT_TMBAM_DMP_FUND |
      | BUSINESS_FEED |                       |

    Then I extract new job id from jblg table into a variable "JOB_ID"

  #Verification of successful File load
    And I expect value of column "JBLG_ROW_COUNT" in the below SQL query equals to "1":
      """
      SELECT count(*) as JBLG_ROW_COUNT FROM FT_T_JBLG
      WHERE JOB_ID = '${JOB_ID}'
      AND JOB_STAT_TYP ='CLOSED'
      """
    And I expect value of column "TMBAMSSH_COUNT" in the below SQL query equals to "1":
      """
      SELECT count(*) as TMBAMSSH_COUNT FROM FT_T_ACST
      WHERE STAT_DEF_ID in ('SSHFLAG')
      AND STAT_CHAR_VAL_TXT='Y'
      AND ACCT_ID in (select ACCT_ID from ft_t_acid where acct_alt_id in ('D25') and acct_id_ctxt_typ='CRTSID' and end_tms is null)
      """

  Scenario: Load TMBAM Security File

    When I copy files below from local folder "${TESTDATA_PATH}/inputfiles/TMBAM" to the host "dmp.ssh.inbound" folder "${dmp.ssh.inbound.path}":
      | TMBAM-SECURITY.csv |

    And I process files with below parameters and wait for the job to be completed
      | FILE_PATTERN  | TMBAM-SECURITY.csv        |
      | MESSAGE_TYPE  | EIS_MT_TMBAM_DMP_SECURITY |
      | BUSINESS_FEED |                           |

    Then I extract new job id from jblg table into a variable "JOB_ID"

    And I expect value of column "JBLG_ROW_COUNT" in the below SQL query equals to "1":
    """
    SELECT count(*) as JBLG_ROW_COUNT FROM FT_T_JBLG
    WHERE JOB_ID = '${JOB_ID}'
    AND JOB_STAT_TYP ='CLOSED'
    """

  Scenario: Load TR DSS TNC

    When I copy files below from local folder "${TESTDATA_PATH}/inputfiles/TMBAM" to the host "dmp.ssh.inbound" folder "${dmp.ssh.inbound.path}":
      | RTISSR-TNC-SECURITY.csv |

    And I process files with below parameters and wait for the job to be completed
      | FILE_PATTERN  | RTISSR-TNC-SECURITY.csv       |
      | MESSAGE_TYPE  | ReutersDSS_TermsandConditions |
      | BUSINESS_FEED |                               |

    Then I extract new job id from jblg table into a variable "JOB_ID"

    And I expect value of column "JBLG_ROW_COUNT" in the below SQL query equals to "1":
      """
      SELECT count(*) as JBLG_ROW_COUNT FROM FT_T_JBLG
      WHERE JOB_ID = '${JOB_ID}'
      AND JOB_STAT_TYP ='CLOSED'
      """

  Scenario: Load TR DSS COMP

    When I copy files below from local folder "${TESTDATA_PATH}/inputfiles/TMBAM" to the host "dmp.ssh.inbound" folder "${dmp.ssh.inbound.path}":
      | RTISSR-COMP-SECURITY.csv |

    And I process files with below parameters and wait for the job to be completed
      | FILE_PATTERN  | RTISSR-COMP-SECURITY.csv |
      | MESSAGE_TYPE  | EIS_MT_REUTERS_COMPOSITE |
      | BUSINESS_FEED |                          |

    Then I extract new job id from jblg table into a variable "JOB_ID"

    And I expect value of column "JBLG_ROW_COUNT" in the below SQL query equals to "1":
      """
      SELECT count(*) as JBLG_ROW_COUNT FROM FT_T_JBLG
      WHERE JOB_ID = '${JOB_ID}'
      AND JOB_STAT_TYP ='CLOSED'
      """

  Scenario: Load TMBAM Position Data

    Given I execute below query
    """
    tests/test-data/dmp-interfaces/FundApps/Functional/Outbound/sql/Clear_balh.sql
    """

    Given I assign "TMBAM-POSN.csv" to variable "INPUT_FILENAME"
    And I assign "TMBAM-POSN_TEMPLATE.csv" to variable "INPUT_TEMPLATENAME"
    And I generate value with date format "ddMMYYYY" and assign to variable "VAR_SYSDATE"
    And I modify date "${VAR_SYSDATE}" with "-0d" from source format "ddMMYYYY" to destination format "dd/MM/YYYY" and assign to "DYNAMIC_DATE"
    And I create input file "${INPUT_FILENAME}" using template "${INPUT_TEMPLATENAME}" from location "${TESTDATA_PATH}/inputfiles/TMBAM"

    When I copy files below from local folder "${TESTDATA_PATH}/inputfiles/TMBAM/testdata" to the host "dmp.ssh.inbound" folder "${dmp.ssh.inbound.path}":
      | TMBAM-POSN.csv |

    And I process files with below parameters and wait for the job to be completed
      | FILE_PATTERN  | TMBAM-POSN.csv            |
      | MESSAGE_TYPE  | EIS_MT_TMBAM_DMP_POSITION |
      | BUSINESS_FEED |                           |

    Then I extract new job id from jblg table into a variable "JOB_ID"
    And I expect value of column "JBLG_ROW_COUNT" in the below SQL query equals to "1":
      """
      SELECT count(*) as JBLG_ROW_COUNT FROM FT_T_JBLG
      WHERE JOB_ID = '${JOB_ID}'
      AND JOB_STAT_TYP ='CLOSED'
      """

  Scenario: Publish File

    And I generate value with date format "YYYYMMdd" and assign to variable "VAR_SYSDATE"
#Extract Data
    Given I remove below files in the host "dmp.ssh.inbound" from folder "${PUBLISHING_DIRECTORY}" if exists:
      | ${FAISSR_PUBLISHING_FILE_NAME}_${VAR_SYSDATE}_1.csv |

    When I process publishing wrapper with below parameters and wait for the job to be completed
      | PUBLISHING_FILE_NAME | ${FAISSR_PUBLISHING_FILE_NAME}.csv |
      | SUBSCRIPTION_NAME    | EIS_DMP_TO_FUNDAPPS_ISSUER_SUB     |


    Then I expect below files to be present in the host "dmp.ssh.inbound" into folder "${PUBLISHING_DIRECTORY}" after processing:
      | ${FAISSR_PUBLISHING_FILE_NAME}_${VAR_SYSDATE}_1.csv |

    Then I copy files below from remote folder "${PUBLISHING_DIRECTORY}" on host "dmp.ssh.inbound" into local folder "${TESTDATA_PATH}/outfiles/runtime":
      | ${FAISSR_PUBLISHING_FILE_NAME}_${VAR_SYSDATE}_1.csv |

    And I remove below files in the host "dmp.ssh.inbound" from folder "${PUBLISHING_DIRECTORY}" if exists:
      | ${FAISSR_PUBLISHING_FILE_NAME}_${VAR_SYSDATE}_1.csv |


  Scenario: Check if published file contains all the records which were loaded for FundApps Issuer data

    Given I assign "FAISSR_expected.csv" to variable "MASTER_FILE"
    And I assign "${FAISSR_PUBLISHING_FILE_NAME}_${VAR_SYSDATE}_1.csv" to variable "OUTPUT_FILE"

    When I capture current time stamp into variable "recon.timestamp"
    Then I expect each record in file "${TESTDATA_PATH}/outfiles/expected/${MASTER_FILE}" should exist in file "${TESTDATA_PATH}/outfiles/runtime/${OUTPUT_FILE}" and exceptions to be written to "${TESTDATA_PATH}/outfiles/runtime/exceptions_${recon.timestamp}.csv" file

  Scenario: Cleanup max polling time variable
    Then I remove variable "workflow.max.polling.time" from memory