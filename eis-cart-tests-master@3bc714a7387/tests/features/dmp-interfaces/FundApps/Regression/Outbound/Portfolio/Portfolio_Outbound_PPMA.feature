#https://jira.intranet.asia/browse/TOM-4546
#https://collaborate.intranet.asia/pages/viewpage.action?spaceKey=FUNDAPPS&title=25.+Outbound+Ptf+to+PPMA
#EISDEV-6547: Change in data for securities and fund to avoid clash during regression

@gc_interface_securities @gc_interface_reuters @gc_interface_funds @gc_interface_positions
@dmp_regression_integrationtest
@tom_4546 @dmp_fundapps_functional @fund_apps_portfolio_outbound_ppma @tom_4779 @tom_4787
@tom_4798 @tom_4810 @tom_4823 @dmp_fundapps_regression @eisdev_6547 @eisdev_6913
Feature: TOM-4546: Outbound Portfolio file for Fundapps to PPMA (Golden Source)

  The feature file for outbound funds for PPMA with below format.
  Portfolio: I02|TMB Emerging Markets Equity Index|UNIT TRUST|External|EXTERNAL|409|TMB ASSET MANAGEMENT CO., LTD.|Sole|Sole|||||||||

  Scenario: TC_1: Load pre-requisite Instrument Data before file

    Given I assign "tests/test-data/dmp-interfaces/FundApps/Regression/Outbound/Outbound_RCR_Fund" to variable "testdata.path"
    When I copy files below from local folder "${testdata.path}/inputfiles" to the host "dmp.ssh.inbound" folder "${dmp.ssh.inbound.path}":
      | BRS_Security_For_TMBAM.xml |

    And I process files with below parameters and wait for the job to be completed
      | FILE_PATTERN  | BRS_Security_For_TMBAM.xml |
      | MESSAGE_TYPE  | EIS_MT_BRS_SECURITY_NEW    |
      | BUSINESS_FEED |                            |

    Then I extract new job id from jblg table into a variable "JOB_ID"
    And I expect value of column "JBLG_ROW_COUNT" in the below SQL query equals to "1":
      """
      SELECT count(*) as JBLG_ROW_COUNT FROM FT_T_JBLG
      WHERE JOB_ID = '${JOB_ID}'
      AND JOB_STAT_TYP ='CLOSED'
      """

    When I copy files below from local folder "${testdata.path}/inputfiles" to the host "dmp.ssh.inbound" folder "${dmp.ssh.inbound.path}":
      | gs_tc.csv |

    And I process files with below parameters and wait for the job to be completed
      | FILE_PATTERN  | gs_tc.csv                     |
      | MESSAGE_TYPE  | ReutersDSS_TermsandConditions |
      | BUSINESS_FEED |                               |

    Then I extract new job id from jblg table into a variable "JOB_ID"
    And I expect value of column "JBLG_ROW_COUNT" in the below SQL query equals to "1":
      """
      SELECT count(*) as JBLG_ROW_COUNT FROM FT_T_JBLG
      WHERE JOB_ID = '${JOB_ID}'
      AND JOB_STAT_TYP ='CLOSED'
      """

    And I expect value of column "USLST_COUNT" in the below SQL query equals to "4":
      """
      SELECT count(*) as USLST_COUNT FROM FT_T_ISST
      WHERE STAT_DEF_ID='USLST'
      AND STAT_CHAR_VAL_TXT='Y'
      AND INSTR_ID in (select INSTR_ID from ft_t_isid where iss_id in ('2593025','2582409','B1FW3W0','B046RT1','BZ03T51') and id_ctxt_typ='SEDOL' and end_tms is null)
      """

  Scenario: TC_2: Load pre-requisite Fund Data before file

    Given I assign "001_Th.Aldn-24_BRS_DMP_R3_PortfolioMasteringTemplate_Final_4.11.xlsx" to variable "INPUT_PROTFOLIO_FILENAME"

    When I copy files below from local folder "${testdata.path}/inputfiles" to the host "dmp.ssh.inbound" folder "${dmp.ssh.inbound.path}":
      | ${INPUT_PROTFOLIO_FILENAME} |

    And I process files with below parameters and wait for the job to be completed
      | FILE_PATTERN  | ${INPUT_PROTFOLIO_FILENAME}          |
      | MESSAGE_TYPE  | EIS_MT_RDM_PORTFOLIO_MASTER_TEMPLATE |
      | BUSINESS_FEED |                                      |

    Then I extract new job id from jblg table into a variable "JOB_ID"
    And I expect value of column "JBLG_ROW_COUNT" in the below SQL query equals to "1":
      """
      SELECT count(*) as JBLG_ROW_COUNT FROM FT_T_JBLG
      WHERE JOB_ID = '${JOB_ID}'
      AND JOB_STAT_TYP ='CLOSED'
      """

    And I expect value of column "PPMASSH_COUNT" in the below SQL query equals to "8":
      """
      SELECT count(*) as PPMASSH_COUNT FROM FT_T_ACST
      WHERE STAT_DEF_ID in ('SSHFLAG','PPMFLAG')
      AND STAT_CHAR_VAL_TXT='Y'
      AND ACCT_ID in (select ACCT_ID from ft_t_acid where acct_alt_id in ('I02PPMATEST','I05PPMATEST','I07PPMATEST','I10PPMATEST') and acct_id_ctxt_typ='CRTSID' and end_tms is null)
      """

  Scenario: TC_3: Load pre-requisite Position Data before file

    Given I execute below query
    """
    tests/test-data/dmp-interfaces/FundApps/Functional/Outbound/sql/Clear_balh.sql
    """

    Given I assign "TBAMEISLPOSITN_INPUT.xml" to variable "INPUT_FILENAME"
    And I assign "001_BRS_DMP_F14_TBAMEISLPOSITN_Template.xml" to variable "INPUT_TEMPLATENAME"
    And I generate value with date format "ddMMYYYY" and assign to variable "VAR_SYSDATE"
    And I modify date "${VAR_SYSDATE}" with "-0d" from source format "ddMMYYYY" to destination format "dd/MM/YYYY" and assign to "DYNAMIC_DATE"
    And I modify date "${VAR_SYSDATE}" with "-0d" from source format "ddMMYYYY" to destination format "MM/dd/YYYY" and assign to "BRS_DYNAMIC_DATE"
    And I create input file "${INPUT_FILENAME}" using template "${INPUT_TEMPLATENAME}" with below codes from location "${testdata.path}/inputfiles"
      |  |  |

    When I copy files below from local folder "${testdata.path}/inputfiles/testdata" to the host "dmp.ssh.inbound" folder "${dmp.ssh.inbound.path}":
      | TBAMEISLPOSITN_INPUT.xml |

    And I process files with below parameters and wait for the job to be completed
      | FILE_PATTERN  | TBAMEISLPOSITN_INPUT.xml          |
      | MESSAGE_TYPE  | EIS_MT_BRS_EOD_POSITION_NON_LATAM |
      | BUSINESS_FEED |                                   |

    Then I extract new job id from jblg table into a variable "JOB_ID"
    And I expect value of column "JBLG_ROW_COUNT" in the below SQL query equals to "1":
      """
      SELECT count(*) as JBLG_ROW_COUNT FROM FT_T_JBLG
      WHERE JOB_ID = '${JOB_ID}'
      AND JOB_STAT_TYP ='CLOSED'
      """

  Scenario: TC_4: Publish outbound portfolio file to PPMA

    Given I assign "OUTBOUND_PPMA_PORTFOLIO" to variable "PUBLISHING_FILE_NAME"
    And I generate value with date format "YYYYMMdd" and assign to variable "VAR_SYSDATE"
    And I assign "/dmp/out/fundapps" to variable "PUBLISHING_DIR"

    And I remove below files with pattern in the host "dmp.ssh.inbound" from folder "${PUBLISHING_DIR}" if exists:
      | ${PUBLISHING_FILE_NAME}_*_1.csv |

    When I process publishing wrapper with below parameters and wait for the job to be completed
      | PUBLISHING_FILE_NAME | ${PUBLISHING_FILE_NAME}.csv |
      | SUBSCRIPTION_NAME    | EIS_DMP_TO_PPM_FUND_SUB     |
      | FOOTER_COUNT         | 1                           |

    Then I expect below files to be present in the host "dmp.ssh.inbound" into folder "${PUBLISHING_DIR}" after processing:
      | ${PUBLISHING_FILE_NAME}_${VAR_SYSDATE}_1.csv |

    Then I copy files below from remote folder "${PUBLISHING_DIR}" on host "dmp.ssh.inbound" into local folder "${testdata.path}/outfiles/runtime":
      | ${PUBLISHING_FILE_NAME}_${VAR_SYSDATE}_1.csv |

  Scenario: TC_5: Check if published file contains all the records which were loaded for Fundapps Portfolio data

    Given I assign "OUTBOUND_PPMA_PORTFOLIO_SAMPLE.csv" to variable "MASTER_FILE"
    And I assign "${PUBLISHING_FILE_NAME}_${VAR_SYSDATE}_1.csv" to variable "OUTPUT_FILE"

    When I capture current time stamp into variable "recon.timestamp"
    Then I expect each record in file "${testdata.path}/outfiles/expected/${MASTER_FILE}" should exist in file "${testdata.path}/outfiles/runtime/${OUTPUT_FILE}" and exceptions to be written to "${testdata.path}/outfiles/runtime/exceptions_${recon.timestamp}.csv" file