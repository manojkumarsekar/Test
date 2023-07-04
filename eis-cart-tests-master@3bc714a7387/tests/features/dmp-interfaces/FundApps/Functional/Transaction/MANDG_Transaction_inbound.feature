#https://jira.intranet.asia/browse/TOM-4275
#https://collaborate.intranet.asia/display/FUNDAPPS/FA-IN-SMF-LBURCR-DMP-Fund-File

@tom_4275 @dmp_fundapps_functional @tom_4788
Feature: TOM-4275: Transaction RCRLBU MNG file load (Golden Source)

  1) Security & Fund creation in DMP through any feed file load from RCRLBU.
  2) As the fund file is dependant on ORG Chart for FINS data, we are loading the dependant ORG Chart data first.

  #Prerequisites
  Scenario: TC_1: Clear Trade data and load pre-requisite Org Chart data

    Given I assign "tests/test-data/dmp-interfaces/FundApps/Functional/Transaction" to variable "testdata.path"
    And I assign "MNGEISLTRANSN20190319_test.csv" to variable "INPUT_FILENAME"

    When I extract below values for row 2 from PSV file "${INPUT_FILENAME}" in local folder "${testdata.path}/inputfiles/MNG" with reference to "Security_ID" column and assign to variables:
      | Security_ID      | Security_ID |
      | Fund_ID          | FUND_ID     |
      | Transaction_ID   | TRD_ID      |
      | Transaction_Type | TRN_SUB_TYP |
      | Transaction_Date | TRD_DTE     |
      | Quantity         | TRD_CQT     |
      | Trade_Currency   | TRD_CUR_CDE |
      | Trade_Price      | TRD_PRZ     |

    And I assign "MNGCODE" to variable "ID_CTXT_TYPE"
    And I assign "CRTSID" to variable "ACCT_ID_CTXT"
    And I assign "MNGEOD" to variable "TRN_CDE"

    And I execute below query
    """
    ${testdata.path}/sql/Clear_data.sql
    """

  Scenario: TC_2: Load pre-requisite ORG Chart Data before file
    When I copy files below from local folder "${testdata.path}/inputfiles/MNG" to the host "dmp.ssh.inbound" folder "${dmp.ssh.inbound.path}":
      | MNG_ORG_Chart_template.xls |

    And I process files with below parameters and wait for the job to be completed
      | FILE_PATTERN  | MNG_ORG_Chart_template.xls |
      | MESSAGE_TYPE  | EIS_MT_ORG_CHART_EXCEL     |
      | BUSINESS_FEED |                            |

    Then I extract new job id from jblg table into a variable "JOB_ID"

    And I expect value of column "JBLG_ROW_COUNT" in the below SQL query equals to "1":
      """
      SELECT count(*) as JBLG_ROW_COUNT FROM FT_T_JBLG
      WHERE JOB_ID = '${JOB_ID}'
      AND JOB_STAT_TYP ='CLOSED'
      """

  Scenario: TC_3: File load for RCRLBU Fund for Data Source MNG

    When I copy files below from local folder "${testdata.path}/inputfiles/MNG" to the host "dmp.ssh.inbound" folder "${dmp.ssh.inbound.path}":
      | MANGEISLFUNDLE20181218_test.csv |

    And I process files with below parameters and wait for the job to be completed
      | FILE_PATTERN  | MANGEISLFUNDLE*     |
      | MESSAGE_TYPE  | EIS_MT_MNG_DMP_FUND |
      | BUSINESS_FEED |                     |

    Then I extract new job id from jblg table into a variable "JOB_ID"
    And I expect value of column "JBLG_ROW_COUNT" in the below SQL query equals to "1":
      """
      SELECT count(*) as JBLG_ROW_COUNT FROM FT_T_JBLG
      WHERE JOB_ID = '${JOB_ID}'
      AND JOB_STAT_TYP ='CLOSED'
      """

  Scenario: TC_4: Load pre-requisite Security Data before file

    When I copy files below from local folder "${testdata.path}/inputfiles/MNG" to the host "dmp.ssh.inbound" folder "${dmp.ssh.inbound.path}":
      | MANGEISLINSTMT20181218_test.csv |

    And I process files with below parameters and wait for the job to be completed
      | FILE_PATTERN  | MANGEISLINSTMT*         |
      | MESSAGE_TYPE  | EIS_MT_MNG_DMP_SECURITY |
      | BUSINESS_FEED |                         |

    Then I extract new job id from jblg table into a variable "JOB_ID"
    And I expect value of column "JBLG_ROW_COUNT" in the below SQL query equals to "1":
    """
    SELECT count(*) as JBLG_ROW_COUNT FROM FT_T_JBLG
    WHERE JOB_ID = '${JOB_ID}'
    AND JOB_STAT_TYP ='CLOSED'
    """

  Scenario: TC_5: Load Transaction Data File

    When I copy files below from local folder "${testdata.path}/inputfiles/MNG" to the host "dmp.ssh.inbound" folder "${dmp.ssh.inbound.path}":
      | MNGEISLTRANSN20190319_test.csv |

    And I process files with below parameters and wait for the job to be completed
      | FILE_PATTERN  | MNGEISLTRANSN*     |
      | MESSAGE_TYPE  | EIS_MT_MNG_DMP_TXN |
      | BUSINESS_FEED |                    |

    Then I extract new job id from jblg table into a variable "JOB_ID"
    And I expect value of column "JBLG_ROW_COUNT" in the below SQL query equals to "1":
    """
    SELECT count(*) as JBLG_ROW_COUNT FROM FT_T_JBLG
    WHERE JOB_ID = '${JOB_ID}'
    AND JOB_STAT_TYP ='CLOSED'
    """

  Scenario: TC_3: Verification of EXTR For  Transaction Data from  File

    Then I expect value of column "VERIFY_EXECTRD" in the below SQL query equals to "1":
    """
	${testdata.path}/sql/VERIFY_EXTR_CHECK.sql
    """


  Scenario: TC_7: Verification of ETCL For  Transaction_type

    Then I expect value of column "VERIFY_TRAB_TYPE" in the below SQL query equals to "1":
    """
    select count(*) as VERIFY_TRAB_TYPE
    from fT_T_etcl
    where cl_value='S'
    and indus_cl_set_id='TRANTYPE'
    and exec_trd_id in
                      (
                          select exec_trd_id from fT_T_extr  where trd_id='${TRD_ID}'
                       )
    """

  Scenario: TC_8: Verification of ACCT_ORG_ID and ACCT_BK_ID For  Trade

    Then I expect value of column "VERIFY_ORG_BK" in the below SQL query equals to "1":
    """
	${testdata.path}/sql/VERIFY_ORG_BK_ID_CHECK.sql
    """
