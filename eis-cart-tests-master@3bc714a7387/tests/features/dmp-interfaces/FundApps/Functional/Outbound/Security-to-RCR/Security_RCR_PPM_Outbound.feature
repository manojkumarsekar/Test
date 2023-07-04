#https://jira.intranet.asia/browse/TOM-4129
#This is a basic test case for outbound security to PPM from DMP
@tom_4129_PPM @tom_4129_outboundrcr @dmp_fundapps_functional @dmp_fundapps_regression @tom_4823
Feature: 002 | FundApps | Verify Outbound Securities to PPM

  Scenario: Assign Variables
    Given I assign "tests/test-data/dmp-interfaces/FundApps/Functional/Outbound/Outbound-Security" to variable "TESTDATA_PATH"
    And I generate value with date format "YYYYMMdd" and assign to variable "VAR_SYSDATE"
    And I assign "/dmp/out/fundapps" to variable "PUBLISHING_DIRECTORY"
    And I assign "600" to variable "workflow.max.polling.time"
    And I assign "EISPPMINSTMT" to variable "PPM_PUBLISHING_FILE_NAME"
    And I generate value with date format "YYYYMMdd" and assign to variable "VAR_SYSDATE"

  Scenario: Load pre-requisite BOCI Fund Data before BOCI Security file

    When I copy files below from local folder "${TESTDATA_PATH}/inputfiles/PPM" to the host "dmp.ssh.inbound" folder "${dmp.ssh.inbound.path}":
      | BOCI-FUND.csv |

    And I process files with below parameters and wait for the job to be completed
      | FILE_PATTERN  | BOCI-FUND.csv        |
      | MESSAGE_TYPE  | EIS_MT_BOCI_DMP_FUND |
      | BUSINESS_FEED |                      |

    Then I extract new job id from jblg table into a variable "JOB_ID"

    #Verification of successful File load
    And I expect value of column "JBLG_ROW_COUNT" in the below SQL query equals to "1":
      """
      SELECT count(*) as JBLG_ROW_COUNT FROM FT_T_JBLG
      WHERE JOB_ID = '${JOB_ID}'
      AND JOB_STAT_TYP ='CLOSED'
      """
    And I expect value of column "MNGSSH_COUNT" in the below SQL query equals to "2":
      """
      SELECT count(*) as MNGSSH_COUNT FROM FT_T_ACST
      WHERE STAT_DEF_ID in ('SSHFLAG','MNGFLAG')
      AND STAT_CHAR_VAL_TXT='Y'
      AND ACCT_ID in (select ACCT_ID from ft_t_acid where acct_alt_id in ('PACEQ') and acct_id_ctxt_typ='CRTSID' and end_tms is null)
      """

  Scenario: Load pre-requisite ESGA Fund Data before ESGA Security file

    When I copy files below from local folder "${TESTDATA_PATH}/inputfiles/PPM" to the host "dmp.ssh.inbound" folder "${dmp.ssh.inbound.path}":
      | SSGA-FUND.csv |

    And I process files with below parameters and wait for the job to be completed
      | FILE_PATTERN  | SSGA-FUND.csv        |
      | MESSAGE_TYPE  | EIS_MT_ESGA_DMP_FUND |
      | BUSINESS_FEED |                      |

    Then I extract new job id from jblg table into a variable "JOB_ID"

      #Verification of successful File load
    And I expect value of column "JBLG_ROW_COUNT" in the below SQL query equals to "1":
      """
      SELECT count(*) as JBLG_ROW_COUNT FROM FT_T_JBLG
      WHERE JOB_ID = '${JOB_ID}'
      AND JOB_STAT_TYP ='CLOSED'
      """
    And I expect value of column "PPMSSH_COUNT" in the below SQL query equals to "4":
      """
      SELECT count(*) as PPMSSH_COUNT FROM FT_T_ACST
      WHERE STAT_DEF_ID in ('SSHFLAG','PPMFLAG')
      AND STAT_CHAR_VAL_TXT='Y'
      AND ACCT_ID in (select ACCT_ID from ft_t_acid where acct_alt_id in ('300070','600355') and acct_id_ctxt_typ='CRTSID' and end_tms is null)
      """


  Scenario: Load ESGA Security File

    When I copy files below from local folder "${TESTDATA_PATH}/inputfiles/PPM" to the host "dmp.ssh.inbound" folder "${dmp.ssh.inbound.path}":
      | SSGA-PPM-SECURITY.csv |

    And I process files with below parameters and wait for the job to be completed
      | FILE_PATTERN  | SSGA-PPM-SECURITY.csv    |
      | MESSAGE_TYPE  | EIS_MT_ESGA_DMP_SECURITY |
      | BUSINESS_FEED |                          |

    Then I extract new job id from jblg table into a variable "JOB_ID"

    And I expect value of column "JBLG_ROW_COUNT" in the below SQL query equals to "1":
    """
    SELECT count(*) as JBLG_ROW_COUNT FROM FT_T_JBLG
    WHERE JOB_ID = '${JOB_ID}'
    AND JOB_STAT_TYP ='CLOSED'
    """

  Scenario: Load BOCI Security File

    When I copy files below from local folder "${TESTDATA_PATH}/inputfiles/PPM" to the host "dmp.ssh.inbound" folder "${dmp.ssh.inbound.path}":
      | BOCI-PPM-SECURITY.csv |

    And I process files with below parameters and wait for the job to be completed
      | FILE_PATTERN  | BOCI-PPM-SECURITY.csv    |
      | MESSAGE_TYPE  | EIS_MT_BOCI_DMP_SECURITY |
      | BUSINESS_FEED |                          |

    Then I extract new job id from jblg table into a variable "JOB_ID"

    And I expect value of column "JBLG_ROW_COUNT" in the below SQL query equals to "1":
    """
    SELECT count(*) as JBLG_ROW_COUNT FROM FT_T_JBLG
    WHERE JOB_ID = '${JOB_ID}'
    AND JOB_STAT_TYP ='CLOSED'
    """

  Scenario: Load TR DSS TNC

    When I copy files below from local folder "${TESTDATA_PATH}/inputfiles/PPM" to the host "dmp.ssh.inbound" folder "${dmp.ssh.inbound.path}":
      | REUTERS-TNC-SECURITY-PPM.csv |

    And I process files with below parameters and wait for the job to be completed
      | FILE_PATTERN  | REUTERS-TNC-SECURITY-PPM.csv  |
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

    When I copy files below from local folder "${TESTDATA_PATH}/inputfiles/PPM" to the host "dmp.ssh.inbound" folder "${dmp.ssh.inbound.path}":
      | REUTERS-COMP-SECURITY-PPM.csv |

    And I process files with below parameters and wait for the job to be completed
      | FILE_PATTERN  | REUTERS-COMP-SECURITY-PPM.csv |
      | MESSAGE_TYPE  | EIS_MT_REUTERS_COMPOSITE      |
      | BUSINESS_FEED |                               |

    Then I extract new job id from jblg table into a variable "JOB_ID"

    And I expect value of column "JBLG_ROW_COUNT" in the below SQL query equals to "1":
      """
      SELECT count(*) as JBLG_ROW_COUNT FROM FT_T_JBLG
      WHERE JOB_ID = '${JOB_ID}'
      AND JOB_STAT_TYP ='CLOSED'
      """

    And I expect value of column "USLST_COUNT" in the below SQL query equals to "2":
      """
      SELECT count(*) as USLST_COUNT FROM FT_T_ISST
      WHERE STAT_DEF_ID='USLST'
      AND STAT_CHAR_VAL_TXT='Y'
      AND INSTR_ID in (select INSTR_ID from ft_t_isid where iss_id in ('US40415F1012','US4567881085') and id_ctxt_typ='ISIN' and end_tms is null)
      """
  Scenario: Load pre-requisite BOCI and SSGA Position Data before file

    Given I execute below query
    """
    tests/test-data/dmp-interfaces/FundApps/Functional/Outbound/sql/Clear_balh.sql
    """

    Given I assign "BOCI-POSN.csv" to variable "INPUT_FILENAME"
    And I assign "BOCI-POSN_TEMPLATE.csv" to variable "INPUT_TEMPLATENAME"
    And I generate value with date format "ddMMYYYY" and assign to variable "VAR_SYSDATE"
    And I modify date "${VAR_SYSDATE}" with "-0d" from source format "ddMMYYYY" to destination format "dd/MM/YYYY" and assign to "DYNAMIC_DATE"
    And I create input file "${INPUT_FILENAME}" using template "${INPUT_TEMPLATENAME}" with below codes from location "${TESTDATA_PATH}/inputfiles/PPM"
      |  |  |

    When I copy files below from local folder "${TESTDATA_PATH}/inputfiles/PPM/testdata" to the host "dmp.ssh.inbound" folder "${dmp.ssh.inbound.path}":
      | BOCI-POSN.csv |

    And I process files with below parameters and wait for the job to be completed
      | FILE_PATTERN  | BOCI-POSN.csv  |
      | MESSAGE_TYPE  | EIS_MT_BOCI_DMP_POSITION |
      | BUSINESS_FEED |                           |

    Then I extract new job id from jblg table into a variable "JOB_ID"
    And I expect value of column "JBLG_ROW_COUNT" in the below SQL query equals to "1":
      """
      SELECT count(*) as JBLG_ROW_COUNT FROM FT_T_JBLG
      WHERE JOB_ID = '${JOB_ID}'
      AND JOB_STAT_TYP ='CLOSED'
      """

    Given I assign "SSGA-POSN.csv" to variable "INPUT_FILENAME"
    And I assign "SSGA-POSN_TEMPLATE.csv" to variable "INPUT_TEMPLATENAME"
    And I generate value with date format "ddMMYYYY" and assign to variable "VAR_SYSDATE"
    And I modify date "${VAR_SYSDATE}" with "-0d" from source format "ddMMYYYY" to destination format "dd/MM/YYYY" and assign to "DYNAMIC_DATE"
    And I create input file "${INPUT_FILENAME}" using template "${INPUT_TEMPLATENAME}" with below codes from location "${TESTDATA_PATH}/inputfiles/PPM"
      |  |  |

    When I copy files below from local folder "${TESTDATA_PATH}/inputfiles/PPM/testdata" to the host "dmp.ssh.inbound" folder "${dmp.ssh.inbound.path}":
      | SSGA-POSN.csv |

    And I process files with below parameters and wait for the job to be completed
      | FILE_PATTERN  | SSGA-POSN.csv  |
      | MESSAGE_TYPE  | EIS_MT_ESGA_DMP_POSITION |
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
      | ${PPM_PUBLISHING_FILE_NAME}_${VAR_SYSDATE}_1.csv |

    When I process publishing wrapper with below parameters and wait for the job to be completed
      | PUBLISHING_FILE_NAME | ${PPM_PUBLISHING_FILE_NAME}.csv |
      | SUBSCRIPTION_NAME    | EIS_DMP_TO_PPM_SECURITY_SUB     |
      | FOOTER_COUNT         | 1                               |

    Then I expect below files to be present in the host "dmp.ssh.inbound" into folder "${PUBLISHING_DIRECTORY}" after processing:
      | ${PPM_PUBLISHING_FILE_NAME}_${VAR_SYSDATE}_1.csv |

    Then I copy files below from remote folder "${PUBLISHING_DIRECTORY}" on host "dmp.ssh.inbound" into local folder "${TESTDATA_PATH}/outfiles/runtime":
      | ${PPM_PUBLISHING_FILE_NAME}_${VAR_SYSDATE}_1.csv |

    And I remove below files in the host "dmp.ssh.inbound" from folder "${PUBLISHING_DIRECTORY}" if exists:
      | ${PPM_PUBLISHING_FILE_NAME}_${VAR_SYSDATE}_1.csv |

  Scenario: Check if published file contains all the records which were loaded for Taiwan Classification data

    Given I assign "EISPPMINSTMT_expected.csv" to variable "MASTER_FILE"
    And I assign "${PPM_PUBLISHING_FILE_NAME}_${VAR_SYSDATE}_1.csv" to variable "OUTPUT_FILE"

    When I capture current time stamp into variable "recon.timestamp"
    Then I expect each record in file "${TESTDATA_PATH}/outfiles/expected/${MASTER_FILE}" should exist in file "${TESTDATA_PATH}/outfiles/runtime/${OUTPUT_FILE}" and exceptions to be written to "${TESTDATA_PATH}/outfiles/runtime/exceptions_${recon.timestamp}.csv" file

  Scenario: Cleanup max polling time variable
    Then I remove variable "workflow.max.polling.time" from memory