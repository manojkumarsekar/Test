#https://jira.intranet.asia/browse/TOM-4128
#https://collaborate.intranet.asia/display/FUNDAPPS/SSDR-OUTBOUND-RCRLBU-POSITION-file

#https://jira.pruconnect.net/browse/EISDEV-6728
#FundApps PPMA publishing logic to exclude positions configured for PR6OD exclusion account group FAPRDEXCLPORT and IDMV datasouce FAPSNPRD
#Removed the step related to Prod exclusion since this is not valid after Thailand Go Live

@gc_interface_funds @gc_interface_securities @gc_interface_reuters @gc_interface_positions @gc_interface_portfolios
@dmp_regression_integrationtest
@tom_4128 @dmp_rcrlbu_ppma_positions @dmp_fundapps_functional @fund_apps_positions @tom_4779 @tom_4823 @dmp_fundapps_regression
@eisdev_6728 @eisdev_6913
Feature: TOM-4128: Positions RCRLBU PPMA file load (Golden Source)

  1) Positions related to a Security which is listed in an Exchange that is under a jurisdiction of recipient’s coverage and this should cover also when underlying security of a derivative product is concerned
  2) Positions of a Asian listed security which is identified as multi-listing security and having at least 1 listing falls under responsible jurisdiction of recipient RCR.

  As part of EISDEV-6728 Load 1 record for BRS position and based on PROD exclusion account group FAPRDEXCLPORT and IDMV datasouce FAPSNPRD this row should exclude from Publish.
  Fund id : 6728_BRS_POS_I02

  Scenario: TC_0: Assign Variables
    Given I assign "tests/test-data/dmp-interfaces/FundApps/Functional/Outbound/Outbound_RCR_position" to variable "testdata.path"

     # Portfolio File54 variable
    And I assign "BRS_DMP_F54_esi_portfolio.xml" to variable "INPUT_F54_FILENAME"
    And I assign "BRS_DMP_F54_esi_portfolio_Template.xml" to variable "INPUT_F54_TEMPLATENAME"

    # Portfolio group variable
    And I assign "BRS_DMP_esi_port_group.xml" to variable "INPUT_PROTGROUP_FILENAME"
    And I assign "BRS_DMP_esi_port_group_Template.xml" to variable "INPUT_PORTGROUP_TEMPLATENAME"

    And I assign "BRS_DMP_F14_Position.xml" to variable "INPUT_BRS_POSITION_FILENAME"
    And I assign "BRS_DMP_F14_Position_Template.xml" to variable "INPUT_BRS_POSITION_TEMPLATENAME"

    And I assign "SSDR_PPMA_Excluded_Position_Template.csv" to variable "MASTER_FILE_POSITION_EXCLUDE_TEMPLATE"
    And I assign "SSDR_PPMA_Excluded_Position.csv" to variable "MASTER_FILE_POSITION_EXCLUDE"

    And I assign "BRS_DMP_R3_PortfolioMasteringTemplate_Final_4.11.xlsx" to variable "INPUT_PROTFOLIO_FILENAME"
    And I execute below query and extract values of "CURR_DATE_2" into same variables
     """
     select TO_CHAR(sysdate, 'MM/DD/YYYY') AS CURR_DATE_2 from dual
     """

  Scenario: TC_1:  Load pre-requisite Fund Data before file

    When I process "${testdata.path}/inputfiles/PPMA/EIMKEISLFUNDLE20190706.csv" file with below parameters
      | FILE_PATTERN  | EIMKEISLFUNDL*       |
      | MESSAGE_TYPE  | EIS_MT_EIMK_DMP_FUND |
      | BUSINESS_FEED |                      |

    Then I expect workflow is processed in DMP with success record count as "1"

    And I expect value of column "PPMSSH_COUNT" in the below SQL query equals to "2":
      """
      SELECT count(*) as PPMSSH_COUNT FROM FT_T_ACST
      WHERE STAT_DEF_ID in ('SSHFLAG','PPMFLAG')
      AND STAT_CHAR_VAL_TXT='Y'
      AND ACCT_ID in (select ACCT_ID from ft_t_acid where acct_alt_id in ('E92003') and acct_id_ctxt_typ='CRTSID' and end_tms is null)
      """

  Scenario: TC_3: Load pre-requisite Security Data before file

    When I process "${testdata.path}/inputfiles/PPMA/EIMKEISLFUNDLE20190706.csv" file with below parameters
      | FILE_PATTERN  | EIMKEISLINSTMT*          |
      | MESSAGE_TYPE  | EIS_MT_EIMK_DMP_SECURITY |
      | BUSINESS_FEED |                          |

  Scenario:TC_4:Load pre-requisite Reuters Data before file

    When I process "${testdata.path}/inputfiles/PPMA/gs_tc_ppma0042.csv" file with below parameters
      | FILE_PATTERN  | gs_tc_ppma0042*               |
      | MESSAGE_TYPE  | ReutersDSS_TermsandConditions |
      | BUSINESS_FEED |                               |

    Then I expect workflow is processed in DMP with success record count as "1"

    And I expect value of column "USLST_COUNT" in the below SQL query equals to "1":
      """
      SELECT count(*) as USLST_COUNT FROM FT_T_ISST
      WHERE STAT_DEF_ID='USLST'
      AND STAT_CHAR_VAL_TXT='Y'
      AND INSTR_ID in (select INSTR_ID from ft_t_isid where iss_id in ('BF5MLP7') and id_ctxt_typ='SEDOL' and end_tms is null)
      """

  Scenario:TC_5: clear data

    Given I execute below query
    """
    tests/test-data/dmp-interfaces/FundApps/Functional/Outbound/sql/Clear_balh.sql
    """

  Scenario: TC_6: Create Position file with Position Date as SYSDATE and Load into DMP

    Given I assign "EIMKEISLPOSITN20181218_test.csv" to variable "INPUT_FILENAME"
    And I assign "EIMKPosition_template.csv" to variable "INPUT_TEMPLATENAME"

    And I assign "PPMA_DATA" to variable "PUBLISHING_FILE_NAME"
    And I assign "PPMA_DATA_template.csv" to variable "PUBLISHING_TEMPLATENAME"


    And I generate value with date format "ddMMYYYY" and assign to variable "VAR_SYSDATE"
    And I generate value with date format "YYYYMMdd" and assign to variable "VAR_SYSDATE2"
    And I assign "${PUBLISHING_FILE_NAME}*_1.csv" to variable "PUBLISHING_FILE_FULL_NAME"
    And I assign "/dmp/out/fundapps" to variable "PUBLISHING_DIR"
    And I assign "PPMA_DATA.csv" to variable "MASTER_FILE"

    And I remove below files with pattern in the host "dmp.ssh.inbound" from folder "${PUBLISHING_DIR}" if exists:
      | ${PUBLISHING_FILE_FULL_NAME} |

    And I modify date "${VAR_SYSDATE}" with "-0d" from source format "ddMMYYYY" to destination format "dd/MM/YYYY" and assign to "DYNAMIC_DATE"

    And I create input file "${INPUT_FILENAME}" using template "${INPUT_TEMPLATENAME}" from location "${testdata.path}/inputfiles/PPMA"

  Scenario: TC_8: Load position file

    When I process "${testdata.path}/inputfiles/PPMA/testdata/${INPUT_FILENAME}" file with below parameters
      | BUSINESS_FEED |                          |
      | FILE_PATTERN  | ${INPUT_FILENAME}        |
      | MESSAGE_TYPE  | EIS_MT_EIMK_DMP_POSITION |

  Scenario: TC_9: Create portfolio for BRS Position Load

    Given I process "${testdata.path}/inputfiles/PPMA/testdata/${INPUT_PROTFOLIO_FILENAME}" file with below parameters
      | FILE_PATTERN  | ${INPUT_PROTFOLIO_FILENAME}          |
      | MESSAGE_TYPE  | EIS_MT_RDM_PORTFOLIO_MASTER_TEMPLATE |
      | BUSINESS_FEED |                                      |

    When I expect workflow is processed in DMP with total record count as "1"

  Scenario: TC_10: Creates BRSFundID as Context type using File54 for BRS position Load

    Given I create input file "${INPUT_F54_FILENAME}" using template "${INPUT_F54_TEMPLATENAME}" from location "${testdata.path}/inputfiles/PPMA"

    When I process "${testdata.path}/inputfiles/PPMA/testdata/${INPUT_F54_FILENAME}" file with below parameters
      | BUSINESS_FEED |                       |
      | FILE_PATTERN  | ${INPUT_F54_FILENAME} |
      | MESSAGE_TYPE  | EIS_MT_BRS_PORTFOLIO  |

    Then I expect workflow is processed in DMP with total record count as "1"

  Scenario: TC_11: Load portfolio group file from BRS to DMP for create TBMAM group and participants to BRS Position

    Given I create input file "${INPUT_PROTGROUP_FILENAME}" using template "${INPUT_PORTGROUP_TEMPLATENAME}" from location "${testdata.path}/inputfiles/PPMA"

    When I process "${testdata.path}/inputfiles/PPMA/testdata/${INPUT_PROTGROUP_FILENAME}" file with below parameters
      | BUSINESS_FEED |                             |
      | FILE_PATTERN  | ${INPUT_PROTGROUP_FILENAME} |
      | MESSAGE_TYPE  | EIS_MT_BRS_PORTFOLIO_GROUP  |

    Then I expect workflow is processed in DMP with total record count as "2"

  Scenario: TC_12: Load ADX Position File using EOD

    Given I create input file "${INPUT_BRS_POSITION_FILENAME}" using template "${INPUT_BRS_POSITION_TEMPLATENAME}" from location "${testdata.path}/inputfiles/PPMA"

    And I process "${testdata.path}/inputfiles/PPMA/testdata/${INPUT_BRS_POSITION_FILENAME}" file with below parameters
      | FILE_PATTERN  | ${INPUT_BRS_POSITION_FILENAME}    |
      | MESSAGE_TYPE  | EIS_MT_BRS_EOD_POSITION_NON_LATAM |
      | BUSINESS_FEED |                                   |

    When I expect workflow is processed in DMP with total record count as "1"

  Scenario: TC_13: Triggering Publishing Wrapper Event for CSV file

    When I process publishing wrapper with below parameters and wait for the job to be completed
      | PUBLISHING_FILE_NAME | ${PUBLISHING_FILE_NAME}.csv |
      | SUBSCRIPTION_NAME    | EIS_DMP_TO_PPM_POSITION_SUB |
      | FOOTER_COUNT         | 1                           |

    Then I expect below files to be present in the host "dmp.ssh.inbound" into folder "${PUBLISHING_DIR}" after processing:
      | ${PUBLISHING_FILE_FULL_NAME} |

    Then I copy files below from remote folder "${PUBLISHING_DIR}" on host "dmp.ssh.inbound" into local folder "${testdata.path}/outfiles/runtime":
      | ${PUBLISHING_FILE_FULL_NAME} |

  Scenario: TC_14: Check if published file contains all the records which were loaded for Position file

    Given I assign "PPMA_DATA.csv" to variable "MASTER_FILE"
    And I assign "${PUBLISHING_FILE_NAME}_${VAR_SYSDATE2}_1.csv" to variable "OUTPUT_FILE"
    And I assign "ExpectedEIMK_template.csv" to variable "INPUT_TEMPLATENAME"

    And I create input file "${MASTER_FILE}" using template "${INPUT_TEMPLATENAME}" from location "${testdata.path}/outfiles/expected"

    Then I expect all records from file1 of type CSV exists in file2
      | File1 | ${testdata.path}/outfiles/expected/testdata/${MASTER_FILE} |
      | File2 | ${testdata.path}/outfiles/runtime/${OUTPUT_FILE}           |

#  Scenario: TC_15: Excluded portfolio and datasource should not Published in PPMA Position file
#
#    And I create input file "${MASTER_FILE_POSITION_EXCLUDE}" using template "${MASTER_FILE_POSITION_EXCLUDE_TEMPLATE}" from location "${testdata.path}/outfiles/expected"
#
#    Then I expect none of the records from file1 of type CSV exists in file2
#      | File1 | ${testdata.path}/outfiles/expected/testdata/${MASTER_FILE_POSITION_EXCLUDE} |
#      | File2 | ${testdata.path}/outfiles/runtime/${OUTPUT_FILE}                            |

  Scenario: Cleanup max polling time variable
    Then I remove variable "workflow.max.polling.time" from memory

