# =====================================================================
# Date            JIRA        Comments
# ============    ========    ========
# 24/09/2019      TOM-5167    Initial Version
# =====================================================================
# https://jira.intranet.asia/browse/TOM-5167

@gc_interface_treasury @gc_interface_issuer @gc_interface_counterparty @gc_interface_securities @gc_interface_positions
@dmp_regression_integrationtest
@tom_5167 @treasury @emir
Feature: Load Position Inbound

  Test #1: Load Inbound Position EOD file
  Requirement is  to store Treasury EOD Positions in DMP/ GS Database to generate Group Finance Report
  Earlier it was only loading issuer,broker,securityMaster and now it was requirement that position need to be loaded in DMP.

  Scenario: Assign variables

    Given I assign "issuer.xml" to variable "INPUT_ISSUER_FILENAME"
    And I assign "broker.xml" to variable "INPUT_BROKER_FILENAME"
    And I assign "sm.xml" to variable "INPUT_SECURITY_FILENAME"
    And I assign "pos.xml" to variable "INPUT_POSITION_FILENAME"
    And I assign "PITLEOD" to variable "RQSTR_ID"

    And I assign "tests/test-data/dmp-interfaces/Treasury/EMIR_Reporting" to variable "testdata.path"

  Scenario: Prerequisites to cleardown existing data

    When I execute below query to "Clear data for the given position from balh"
    """
    ${testdata.path}/sql/0002_BalhClearDown.sql
    """

  Scenario: Load ISSUER, BROKER, SECURITY and POSITION files

    When I copy files below from local folder "${testdata.path}/infiles" to the host "dmp.ssh.inbound" folder "${dmp.ssh.inbound.path}":
      | ${INPUT_ISSUER_FILENAME}   |
      | ${INPUT_BROKER_FILENAME}   |
      | ${INPUT_SECURITY_FILENAME} |
      | ${INPUT_POSITION_FILENAME} |

    And I process files with below parameters and wait for the job to be completed
      | BUSINESS_FEED |                          |
      | FILE_PATTERN  | ${INPUT_ISSUER_FILENAME} |
      | MESSAGE_TYPE  | EIS_MT_BRS_ISSUER        |

    And I process files with below parameters and wait for the job to be completed
      | BUSINESS_FEED |                          |
      | FILE_PATTERN  | ${INPUT_BROKER_FILENAME} |
      | MESSAGE_TYPE  | EIS_MT_BRS_COUNTERPARTY  |

    And I process files with below parameters and wait for the job to be completed
      | BUSINESS_FEED |                            |
      | FILE_PATTERN  | ${INPUT_SECURITY_FILENAME} |
      | MESSAGE_TYPE  | EIS_MT_BRS_SECURITY_NEW    |

    And I process files with below parameters and wait for the job to be completed
      | BUSINESS_FEED |                                  |
      | FILE_PATTERN  | ${INPUT_POSITION_FILENAME}       |
      | MESSAGE_TYPE  | EIS_MT_BRS_EOD_POSITION_TREASURY |


    Then I extract new job id from jblg table into a variable "JOB_ID"

  #Verification of successful File load
    And I expect value of column "JBLG_ROW_COUNT" in the below SQL query equals to "1":
      """
      SELECT count(*) as JBLG_ROW_COUNT FROM FT_T_JBLG
      WHERE JOB_ID = '${JOB_ID}'
      AND JOB_STAT_TYP ='CLOSED'
      """

  Scenario:  Verification of BALH table for the positions loaded with required data from file

    Then I expect value of column "BALH_COUNT" in the below SQL query equals to "10":
      """
      SELECT COUNT(*) as BALH_COUNT
         FROM   FT_T_BALH
         WHERE RQSTR_ID = '${RQSTR_ID}'
         AND trunc(AS_OF_TMS) = '16-SEP-2019'
         AND trunc(LAST_CHG_TMS)=trunc(SYSDATE)
      """





