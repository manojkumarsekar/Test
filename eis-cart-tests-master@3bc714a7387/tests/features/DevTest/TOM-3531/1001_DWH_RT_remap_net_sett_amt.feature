#https://jira.intranet.asia/browse/TOM-3531
#https://collaborate.intranet.asia/pages/viewpage.action?pageId=45855307
#EISDEV_6621 : Add dw_status_num=1 check

@dw_interface_portfolios @dw_interface_securities @dw_interface_transactions @dw_interface_reports
@dmp_dw_regression
@tom_3531 @eisdev_6621
Feature: Month-end data dump transaction reporting

  Test that NET_SETT_AMT_L and NET_SETT_AMT_S are mapped to ft_t_wtrd.trd_net_camt and ft_t_wtrd.stl_net_camt respectively

  Background:

    Given I set the DMP workflow web service endpoint to named configuration "dwh.ws.WORKFLOW"
    And I set the database connection to configuration "dmp.db.DW"

  Scenario: TC_1: Cleardown existing data and setup test data

    # Some static data MDXs use a regex to extract date, thus additional numeric character (e.g. TC01) are avoided
    Given I assign "tests/test-data/DevTest/TOM-3531" to variable "testdata.path"
    And I execute below query
    """
    ${testdata.path}/sql/cleardown.sql
    """
    And I execute below query and extract values of "ME_START_DATE;ME_END_DATE;SETT_DATE" into same variables
    """
    SELECT TO_CHAR(LAST_DAY(SYSDATE),'YYYY-MON')||'-01' AS ME_START_DATE, TO_CHAR(LAST_DAY(SYSDATE),'YYYY-MON-DD') AS ME_END_DATE, TO_CHAR(LAST_DAY(SYSDATE) + 1,'YYYY-MON-DD') AS SETT_DATE FROM DUAL
    """
    And I modify date "${ME_END_DATE}" with "+0d" from source format "yyyy-MMM-dd" to destination format "yyyyMMdd" and assign to "ME_END_DATE_yyyymmdd"
    And I assign "EISPME_SEC_${ME_END_DATE_yyyymmdd}.out" to variable "SEC_INPUT_FILENAME"
    And I assign "EISPME_PFL_${ME_END_DATE_yyyymmdd}.out" to variable "PFL_INPUT_FILENAME"
    And I assign "EISPME_TRN_${ME_END_DATE_yyyymmdd}.out" to variable "TRN_INPUT_FILENAME"

    And I create input file "${TRN_INPUT_FILENAME}" using template "TOM_3531_TRN_Template.out" from location "${testdata.path}"
    And I create input file "${SEC_INPUT_FILENAME}" using template "TOM_3531_SEC_Template.out" from location "${testdata.path}"
    And I create input file "${PFL_INPUT_FILENAME}" using template "TOM_3531_PFL_Template.out" from location "${testdata.path}"

  Scenario: TC_2: Load portfolios

    Given I copy files below from local folder "${testdata.path}/testdata" to the host "dwh.ssh.inbound" folder "${dwh.ssh.inbound.path}":
      | ${PFL_INPUT_FILENAME} |

    When I process files with below parameters and wait for the job to be completed
      | BUSINESS_FEED |                       |
      | FILE_PATTERN  | ${PFL_INPUT_FILENAME} |
      | MESSAGE_TYPE  | EIS_MT_BNP_MOPK_PFL   |

    # Validation: records in ft_t_wact
    Then I expect value of column "PFL_COUNT" in the below SQL query equals to "1":
        """
        SELECT count(*) AS PFL_COUNT FROM ft_t_wact WHERE rptg_prd_end_dte = TRUNC(LAST_DAY(SYSDATE)) and dw_status_num =1
        """

  Scenario: TC_3: Load securities

    Given I copy files below from local folder "${testdata.path}/testdata" to the host "dwh.ssh.inbound" folder "${dwh.ssh.inbound.path}":
      | ${SEC_INPUT_FILENAME} |

    When I process files with below parameters and wait for the job to be completed
      | BUSINESS_FEED |                       |
      | FILE_PATTERN  | ${SEC_INPUT_FILENAME} |
      | MESSAGE_TYPE  | EIS_MT_BNP_MOPK_SEC   |

    # Validation: records in ft_t_wisu
    Then I expect value of column "SEC_COUNT" in the below SQL query equals to "1":
        """
        SELECT count(*) AS SEC_COUNT FROM ft_t_wisu WHERE rptg_prd_end_dte = TRUNC(LAST_DAY(SYSDATE)) and dw_status_num =1
        """

  Scenario: TC_4: Load Transactions

    Given I copy files below from local folder "${testdata.path}/testdata" to the host "dwh.ssh.inbound" folder "${dwh.ssh.inbound.path}":
      | ${TRN_INPUT_FILENAME} |

    When I process files with below parameters and wait for the job to be completed
      | BUSINESS_FEED |                       |
      | FILE_PATTERN  | ${TRN_INPUT_FILENAME} |
      | MESSAGE_TYPE  | EIS_MT_BNP_MOPK_TRN   |

    # Validation: records in ft_t_wtrd
    Then I expect value of column "TRN_COUNT" in the below SQL query equals to "1":
        """
        SELECT count(*) AS TRN_COUNT FROM ft_t_wtrd WHERE rptg_prd_end_dte = TRUNC(LAST_DAY(SYSDATE)) and dw_status_num =1
        """

  Scenario: TC_5: Check ft_t_wtrd.trd_net_camt

    Then I expect value of column "TRD_NET_CAMT" in the below SQL query equals to "628685.04":
      """
      SELECT TRD_NET_CAMT FROM ft_t_wtrd WHERE rptg_prd_end_dte = TRUNC(LAST_DAY(SYSDATE)) and dw_status_num =1
      """

  Scenario: TC_6: Check ft_t_wtrd.stl_net_camt

    Then I expect value of column "STL_NET_CAMT" in the below SQL query equals to "525150":
      """
      SELECT STL_NET_CAMT FROM ft_t_wtrd WHERE rptg_prd_end_dte = TRUNC(LAST_DAY(SYSDATE)) and dw_status_num =1
      """
