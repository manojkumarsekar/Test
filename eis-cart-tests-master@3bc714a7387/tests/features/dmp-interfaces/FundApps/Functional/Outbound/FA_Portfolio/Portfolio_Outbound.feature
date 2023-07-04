#https://jira.intranet.asia/browse/TOM-4249
#https://collaborate.intranet.asia/display/FUNDAPPS/23.+Outbound+FundApps+Portfolio+File

#EISDEV-7295 : Addition of fields
#EISDEV-7300 : FileNumber Fix
#EISDEV-7337 : Logic change for InvestmentManager13FAffiliation
#EISDEV-7449 : Logic change for InvestmentManager13F

@tom_4249 @tom_5022 @eisdev_7295 @eisdev_7330 @eisdev_7337 @eisdev_7449
Feature: TOM-4249: Outbound Portfolio file for Fundapps (Golden Source)

  The feature file for outbound funds for fundapps with below format.
  Portfolio: E17822,E17822,KRW,Portfolio,Prudential,E.50,E.50,E.50,,,E.50,E.50,E.50,"Disclosure,Validation,Validation Disclosure",,,,"NotZA, UKIM, CA-AMRS, ITFM, US-QII, US16AExempt",,,KR,FALSE,Recommended,Recommended,Recommended
  Institution: E.50,EASTSPRING ASSET MANAGEMENT KOREA CO. LTD.,USD,Entity,Prudential,E.32,E.32,E.32,E.32,,E.32,E.32,E.32,"Disclosure,Validation,Validation Disclosure","15,LastDay",Shinhan Investment Tower,110111-2160276,"UKIM, CA-AMRS, ITFM, US-QII, US16AExempt",,,KR,FALSE,Recommended,Recommended,Recommended

  Scenario: TC_1: Load pre-requisite ORG Chart Data before file

    Given I assign "tests/test-data/dmp-interfaces/FundApps/Functional/Outbound" to variable "testdata.path"
    And I assign "400" to variable "workflow.max.polling.time"
    When I copy files below from local folder "${testdata.path}/inputfiles" to the host "dmp.ssh.inbound" folder "${dmp.ssh.inbound.path}":
      | EIMK_ORG_Chart_template_outbound.xls |

    And I process files with below parameters and wait for the job to be completed
      | FILE_PATTERN  | EIMK_ORG_Chart_template_outbound.xls |
      | MESSAGE_TYPE  | EIS_MT_ORG_CHART_EXCEL               |
      | BUSINESS_FEED |                                      |

    Then I extract new job id from jblg table into a variable "JOB_ID"
    And I expect value of column "JBLG_ROW_COUNT" in the below SQL query equals to "1":
      """
      SELECT count(*) as JBLG_ROW_COUNT FROM FT_T_JBLG
      WHERE JOB_ID = '${JOB_ID}'
      AND JOB_STAT_TYP ='CLOSED'
      """

    And I execute below query to "Adding Portfolio E35100 to FAAIF Portfolio Group"
    """
    ${testdata.path}/sql/Setup_static_data.sql
    """

  Scenario: TC_2: Load pre-requisite Fund Data before file

    When I copy files below from local folder "${testdata.path}/inputfiles" to the host "dmp.ssh.inbound" folder "${dmp.ssh.inbound.path}":
      | EIMKEISLFUNDLE20190326_outbound.csv |

    And I process files with below parameters and wait for the job to be completed
      | FILE_PATTERN  | EIMKEISLFUNDLE20190326_outbound.csv |
      | MESSAGE_TYPE  | EIS_MT_EIMK_DMP_FUND                |
      | BUSINESS_FEED |                                     |

    Then I extract new job id from jblg table into a variable "JOB_ID"
    And I expect value of column "JBLG_ROW_COUNT" in the below SQL query equals to "1":
      """
      SELECT count(*) as JBLG_ROW_COUNT FROM FT_T_JBLG
      WHERE JOB_ID = '${JOB_ID}'
      AND JOB_STAT_TYP ='CLOSED'
      """

    When I copy files below from local folder "${testdata.path}/inputfiles" to the host "dmp.ssh.inbound" folder "${dmp.ssh.inbound.path}":
      | MANDGEISLFUNDLE20190326_outbound.csv |

    And I process files with below parameters and wait for the job to be completed
      | FILE_PATTERN  | MANDGEISLFUNDLE20190326_outbound.csv |
      | MESSAGE_TYPE  | EIS_MT_MNG_DMP_FUND                  |
      | BUSINESS_FEED |                                      |

    Then I extract new job id from jblg table into a variable "JOB_ID"
    And I expect value of column "JBLG_ROW_COUNT" in the below SQL query equals to "1":
      """
      SELECT count(*) as JBLG_ROW_COUNT FROM FT_T_JBLG
      WHERE JOB_ID = '${JOB_ID}'
      AND JOB_STAT_TYP ='CLOSED'
      """

  Scenario: TC_3: Publish outbound portfolio file

    Given I assign "OUTBOUND_PORTFOLIO" to variable "PUBLISHING_FILE_NAME"
    And I generate value with date format "YYYYMMdd" and assign to variable "VAR_SYSDATE"
    And I assign "/dmp/out/fundapps" to variable "PUBLISHING_DIR"

    And I remove below files with pattern in the host "dmp.ssh.inbound" from folder "${PUBLISHING_DIR}" if exists:
      | ${PUBLISHING_FILE_NAME}_*_1.csv |

    When I process publishing wrapper with below parameters and wait for the job to be completed
      | PUBLISHING_FILE_NAME        | ${PUBLISHING_FILE_NAME}.csv  |
      | SUBSCRIPTION_NAME           | EIS_DMP_TO_FUNDAPPS_FUND_SUB |
      | EXTRACT_STREETREF_TO_SUBMIT | true                         |

    Then I expect below files to be present in the host "dmp.ssh.inbound" into folder "${PUBLISHING_DIR}" after processing:
      | ${PUBLISHING_FILE_NAME}_${VAR_SYSDATE}_1.csv |

    Then I copy files below from remote folder "${PUBLISHING_DIR}" on host "dmp.ssh.inbound" into local folder "${testdata.path}/outfiles/runtime":
      | ${PUBLISHING_FILE_NAME}_${VAR_SYSDATE}_1.csv |

  Scenario: TC_4: Check if published file contains all the records which were loaded for Fundapps Portfolio data

    Given I assign "OUTBOUND_PORTFOLIO_SAMPLE.csv" to variable "MASTER_FILE"
    And I assign "${PUBLISHING_FILE_NAME}_${VAR_SYSDATE}_1.csv" to variable "OUTPUT_FILE"

    When I capture current time stamp into variable "recon.timestamp"
    Then I expect each record in file "${testdata.path}/outfiles/expected/${MASTER_FILE}" should exist in file "${testdata.path}/outfiles/runtime/${OUTPUT_FILE}" and exceptions to be written to "${testdata.path}/outfiles/runtime/exceptions_${recon.timestamp}.csv" file

  Scenario: Cleanup max polling time variable
    Then I remove variable "workflow.max.polling.time" from memory
