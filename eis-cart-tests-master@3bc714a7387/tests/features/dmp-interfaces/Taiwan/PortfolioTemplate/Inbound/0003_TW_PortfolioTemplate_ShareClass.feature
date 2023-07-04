#https://collaborate.intranet.asia/display/TOMR4/TW+-+GS+portfolio+and+share+class+attibutes+%3A+Add+attributes+in+the+Portfolio+template
# https://jira.intranet.asia/browse/TOM-3686
# TOM-3686 : Adding new attributes for Taiwan LBU in the portfolio template
# https://jira.intranet.asia/browse/TOM-4139

@gc_interface_portfolios
@dmp_regression_unittest
@dmp_taiwan
@tom_4139 @tom_3686 @taiwan_new_port_attrb @taiwan_new_shareclass_attrb
Feature: This feature is to test the 4 new fields added for Taiwan LBU in the portfolio template for Shareclass worksheet(2-Share Class).

  Different permutation of data has been tested against the 4 fields TW_FND_UNIFORM_NUM, TW_SITCA_FND_ID, TRD_CHINESE_LONG_PORT_FUND_NME, TRD_CHINESE_SHRT_PORT_FUND_NME

  TW_FND_UNIFORM_NUM |TW_SITCA_FND_ID |TRD_CHINESE_LONG_PORT_FUND_NME |TRD_CHINESE_SHRT_PORT_FUND_NME|Expected Result|
  Value              |Value           |Value                          |Value                         |RDMID,UNIBUSNUM,SITCAFNDID get loaded in ACID and long name in ACDE|
  Blank              |Blank           |Value                          |Value                         |RDMID get loaded in ACID and long name in ACDE|
  Blank              |Value           |Value                          |Value                         |RDMID,SITCAFNDID get loaded in ACID and long name in ACDE|
  Value              |Blank           |Value                          |Value                         |RDMID,UNIBUSNUM get loaded in ACID and long name in ACDE|
  Value              |Value           |Blank                          |Blank                         |RDMID,UNIBUSNUM, SITCAFNDID get loaded in ACID and no entry in ACDE|
  Value              |Value           |Value                          |Blank                         |RDMID,UNIBUSNUM, SITCAFNDID get loaded in ACID and TRD_CHINESE_LONG_PORT_FUND_NME has value and TRD_CHINESE_SHRT_PORT_FUND_NME is blank in ACDE|

  TW_FND_UNIFORM_NUM |TW_SITCA_FND_ID |TRD_CHINESE_LONG_PORT_FUND_NME |TRD_CHINESE_SHRT_PORT_FUND_NME|Expected Result|
  Value              |Value           |Value                          |Value                         |RDMID,UNIBUSNUM,SITCAFNDID get loaded in ACID and long name in ACDE|
  Blank              |Blank           |Value                          |Value                         |RDMID get loaded in ACID and long name in ACDE|
  Blank              |Value           |Value                          |Value                         |RDMID,SITCAFNDID get loaded in ACID and long name in ACDE|
  Value              |Blank           |Value                          |Value                         |RDMID,UNIBUSNUM get loaded in ACID and long name in ACDE|
  Value              |Value           |Blank                          |Blank                         |RDMID,UNIBUSNUM, SITCAFNDID get loaded in ACID and no entry in ACDE|
  Value              |Value           |Value                          |Blank                         |RDMID,UNIBUSNUM, SITCAFNDID get loaded in ACID and TRD_CHINESE_LONG_PORT_FUND_NME has value and TRD_CHINESE_SHRT_PORT_FUND_NME is blank in ACDE|
  Value              |Value           |Blank                          |Value                         |RDMID,UNIBUSNUM, SITCAFNDID get loaded in ACID and TRD_CHINESE_LONG_PORT_FUND_NME has blank and TRD_CHINESE_SHRT_PORT_FUND_NME has value in ACDE|
  Blank              |Blank           |Blank                          |Blank                         |RDMID get loaded in ACID and no entry in ACDE|


  Scenario: TC1: End date test accounts from ACID, ACDE and ACCR table table and setup variables

    Given I assign "tests/test-data/dmp-interfaces/Taiwan/PortfolioTemplate" to variable "testdata.path"
    And I assign "eis_dmp_ShareClass_TW_UAT.xlsx" to variable "PORTFOLIO_TEMPLATE"
    And I execute below query
    """
    ${testdata.path}/sql/Acid_enddate.sql
    """

  Scenario: TC2:Load portfolio Template with shareclass details to Setup new accounts in DMP

    Given I copy files below from local folder "${testdata.path}/testdata/infiles" to the host "dmp.ssh.inbound" folder "${dmp.ssh.inbound.path}":
      | ${PORTFOLIO_TEMPLATE} |
    And I assign "300" to variable "workflow.max.polling.time"

    When I process files with below parameters and wait for the job to be completed
      | BUSINESS_FEED |                                      |
      | FILE_PATTERN  | ${PORTFOLIO_TEMPLATE}                |
      | MESSAGE_TYPE  | EIS_MT_RDM_PORTFOLIO_MASTER_TEMPLATE |

    Then I extract new job id from jblg table into a variable "JOB_ID"

    And I expect value of column "JBLG_ROW_COUNT" in the below SQL query equals to "1":
      """
      SELECT count(*) as JBLG_ROW_COUNT FROM FT_T_JBLG WHERE JOB_ID = '${JOB_ID}'
      """

  Scenario: TC3: Verify TW_FND_UNIFORM_NUM, TW_SITCA_FND_ID,TRD_CHINESE_LONG_PORT_FUND_NME, TRD_CHINESE_SHRT_PORT_FUND_NME fields loaded into ACID,ACCT,ACDE tables for CRTSID TT56_TWDA

    Given I extract below values for row 2 from EXCEL file "${PORTFOLIO_TEMPLATE}" in local folder "${testdata.path}/testdata/infiles" and assign to variables:
      | PORTFOLIO_NAME                 | VAR_ACCTNAME  |
      | RDM_ID                         | VAR_RDMID     |
      | TW_FND_UNIFORM_NUM             | VAR_UNFID     |
      | TW_SITCA_FND_ID                | VAR_SITCAID   |
      | TRD_CHINESE_LONG_PORT_FUND_NME | VAR_LONGNAME  |
      | TRD_CHINESE_SHRT_PORT_FUND_NME | VAR_SHORTNAME |

    And I expect value of column "RDMID" in the below SQL query equals to "${VAR_RDMID}":
      """
      SELECT ACCT_ALT_ID as RDMID FROM FT_T_ACID
      WHERE ACCT_ID IN
      (
        SELECT ACCT_ID FROM FT_T_ACID
        WHERE ACCT_ALT_ID = '${VAR_RDMID}'
        AND end_tms IS NULL
      )
      AND ACCT_ID_CTXT_TYP IN ('RDMID')
      """

    And I expect value of column "SCUNIBUSNUM" in the below SQL query equals to "${VAR_UNFID}":
      """
      SELECT ACCT_ALT_ID as SCUNIBUSNUM FROM FT_T_ACID
      WHERE ACCT_ID IN
      (
        SELECT ACCT_ID FROM FT_T_ACID
        WHERE ACCT_ALT_ID = '${VAR_RDMID}'
        AND end_tms IS NULL
      )
      AND ACCT_ID_CTXT_TYP IN ('SCUNIBUSNUM')
      """

    And I expect value of column "SITCAFNDID" in the below SQL query equals to "${VAR_SITCAID}":
      """
      SELECT ACCT_ALT_ID as SITCAFNDID FROM FT_T_ACID
      WHERE ACCT_ID IN
      (
        SELECT ACCT_ID FROM FT_T_ACID
        WHERE ACCT_ALT_ID = '${VAR_RDMID}'
        AND end_tms IS NULL
      )
      AND ACCT_ID_CTXT_TYP IN ('SCSITCAFNDID')
      """

    And I expect value of column "PORT_NAME" in the below SQL query equals to "${VAR_ACCTNAME}":
      """
      SELECT ACCT_DESC as  PORT_NAME FROM FT_T_ACCT
      WHERE ACCT_ID IN
      (
        SELECT ACCT_ID FROM FT_T_ACID
        WHERE ACCT_ALT_ID = '${VAR_RDMID}'
        AND end_tms IS NULL
      )
      """

    And I expect value of column "SHORT_NAME" in the below SQL query equals to "${VAR_SHORTNAME}":
      """
      SELECT ACCT_NME AS SHORT_NAME FROM FT_T_ACDE
      WHERE ACCT_ID IN
      (
        SELECT ACCT_ID FROM FT_T_ACID
        WHERE ACCT_ALT_ID = '${VAR_RDMID}'
        AND end_tms IS NULL
      )
      """

    And I expect value of column "LONG_NAME" in the below SQL query equals to "${VAR_LONGNAME}":
      """
      SELECT ACCT_DESC AS LONG_NAME FROM FT_T_ACDE
      WHERE ACCT_ID IN
      (
        SELECT ACCT_ID FROM FT_T_ACID
        WHERE ACCT_ALT_ID = '${VAR_RDMID}'
        AND end_tms IS NULL
      )
      """

    And I expect value of column "ACID_ROW_COUNT" in the below SQL query equals to "3":
      """
      SELECT COUNT(*) AS ACID_ROW_COUNT FROM FT_T_ACID
      WHERE ACCT_ID IN
      (
        SELECT ACCT_ID FROM FT_T_ACID
        WHERE ACCT_ALT_ID = '${VAR_RDMID}'
        AND end_tms IS NULL
       )
       AND ACCT_ID_CTXT_TYP IN ('RDMID','SCUNIBUSNUM','SCSITCAFNDID')
      """

    And I expect value of column "ACCT_ROW_COUNT" in the below SQL query equals to "1":
      """
      SELECT COUNT(*) AS ACCT_ROW_COUNT FROM FT_T_ACCT
      WHERE ACCT_ID IN
      (
        SELECT ACCT_ID FROM FT_T_ACID
        WHERE ACCT_ALT_ID = '${VAR_RDMID}'
        AND end_tms IS NULL
      )
      """

    And I expect value of column "ACDE_ROW_COUNT" in the below SQL query equals to "1":
      """
      SELECT COUNT(*) AS ACDE_ROW_COUNT  FROM FT_T_ACDE
      WHERE ACCT_ID IN
      (
        SELECT ACCT_ID FROM FT_T_ACID
        WHERE ACCT_ALT_ID = '${VAR_RDMID}'
        AND end_tms IS NULL
      )
      """

  Scenario: TC4: Verify TW_FND_UNIFORM_NUM, TW_SITCA_FND_ID are not loaded in ACID table and TRD_CHINESE_LONG_PORT_FUND_NME, TRD_CHINESE_SHRT_PORT_FUND_NME fields loaded into ACDE tables for CRTSID TT56_TWDB

    Given I extract below values for row 3 from EXCEL file "${PORTFOLIO_TEMPLATE}" in local folder "${testdata.path}/testdata/infiles" and assign to variables:
      | PORTFOLIO_NAME                 | VAR_ACCTNAME  |
      | RDM_ID                         | VAR_RDMID     |
      | TRD_CHINESE_LONG_PORT_FUND_NME | VAR_LONGNAME  |
      | TRD_CHINESE_SHRT_PORT_FUND_NME | VAR_SHORTNAME |

    And I expect value of column "PORT_NAME" in the below SQL query equals to "${VAR_ACCTNAME}":
      """
      SELECT ACCT_DESC as  PORT_NAME FROM FT_T_ACCT
      WHERE ACCT_ID IN
      (
        SELECT ACCT_ID FROM FT_T_ACID
        WHERE ACCT_ALT_ID = '${VAR_RDMID}'
        AND end_tms IS NULL
      )
      """

    And I expect value of column "SHORT_NAME" in the below SQL query equals to "${VAR_SHORTNAME}":
      """
      SELECT ACCT_NME AS SHORT_NAME FROM FT_T_ACDE
      WHERE ACCT_ID IN
      (
        SELECT ACCT_ID FROM FT_T_ACID
        WHERE ACCT_ALT_ID = '${VAR_RDMID}'
        AND end_tms IS NULL
      )
      """

    And I expect value of column "LONG_NAME" in the below SQL query equals to "${VAR_LONGNAME}":
      """
      SELECT ACCT_DESC AS LONG_NAME FROM FT_T_ACDE
      WHERE ACCT_ID IN
      (
        SELECT ACCT_ID FROM FT_T_ACID
        WHERE ACCT_ALT_ID = '${VAR_RDMID}'
        AND end_tms IS NULL
      )
      """

    And I expect value of column "ACID_ROW_COUNT" in the below SQL query equals to "1":
      """
      SELECT COUNT(*) AS ACID_ROW_COUNT FROM FT_T_ACID
      WHERE ACCT_ID IN
      (
        SELECT ACCT_ID FROM FT_T_ACID
        WHERE ACCT_ALT_ID = '${VAR_RDMID}'
        AND end_tms IS NULL
       )
       AND ACCT_ID_CTXT_TYP IN ('RDMID')
      """

    And I expect value of column "ACID_ROW_COUNT" in the below SQL query equals to "0":
      """
      SELECT COUNT(*) AS ACID_ROW_COUNT FROM FT_T_ACID
      WHERE ACCT_ID IN
      (
        SELECT ACCT_ID FROM FT_T_ACID
        WHERE ACCT_ALT_ID = '${VAR_RDMID}'
        AND end_tms IS NULL
       )
       AND ACCT_ID_CTXT_TYP IN ('UNIBUSNUM','SITCAFNDID')
      """

    And I expect value of column "ACCT_ROW_COUNT" in the below SQL query equals to "1":
      """
      SELECT COUNT(*) AS ACCT_ROW_COUNT FROM FT_T_ACCT
      WHERE ACCT_ID IN
      (
        SELECT ACCT_ID FROM FT_T_ACID
        WHERE ACCT_ALT_ID = '${VAR_RDMID}'
        AND end_tms IS NULL
      )
      """

    And I expect value of column "ACDE_ROW_COUNT" in the below SQL query equals to "1":
      """
      SELECT COUNT(*) AS ACDE_ROW_COUNT  FROM FT_T_ACDE
      WHERE ACCT_ID IN
      (
        SELECT ACCT_ID FROM FT_T_ACID
        WHERE ACCT_ALT_ID = '${VAR_RDMID}'
        AND end_tms IS NULL
      )
      """

  Scenario: TC5: Verify TW_FND_UNIFORM_NUM is not loaded in ACID table and TRD_CHINESE_LONG_PORT_FUND_NME, TRD_CHINESE_SHRT_PORT_FUND_NME fields loaded into ACDE tables for CRTSID TT56_USDB

    Given I extract below values for row 5 from EXCEL file "${PORTFOLIO_TEMPLATE}" in local folder "${testdata.path}/testdata/infiles" and assign to variables:
      | PORTFOLIO_NAME                 | VAR_ACCTNAME  |
      | RDM_ID                         | VAR_RDMID     |
      | TRD_CHINESE_LONG_PORT_FUND_NME | VAR_LONGNAME  |
      | TRD_CHINESE_SHRT_PORT_FUND_NME | VAR_SHORTNAME |


    And I expect value of column "PORT_NAME" in the below SQL query equals to "${VAR_ACCTNAME}":
      """
      SELECT ACCT_DESC as  PORT_NAME FROM FT_T_ACCT
      WHERE ACCT_ID IN
      (
        SELECT ACCT_ID FROM FT_T_ACID
        WHERE ACCT_ALT_ID = '${VAR_RDMID}'
        AND end_tms IS NULL
      )
      """

    And I expect value of column "SHORT_NAME" in the below SQL query equals to "${VAR_SHORTNAME}":
      """
      SELECT ACCT_NME AS SHORT_NAME FROM FT_T_ACDE
      WHERE ACCT_ID IN
      (
        SELECT ACCT_ID FROM FT_T_ACID
        WHERE ACCT_ALT_ID = '${VAR_RDMID}'
        AND end_tms IS NULL
      )
      """

    And I expect value of column "LONG_NAME" in the below SQL query equals to "${VAR_LONGNAME}":
      """
      SELECT ACCT_DESC AS LONG_NAME FROM FT_T_ACDE
      WHERE ACCT_ID IN
      (
        SELECT ACCT_ID FROM FT_T_ACID
        WHERE ACCT_ALT_ID = '${VAR_RDMID}'
        AND end_tms IS NULL
      )
      """

    And I expect value of column "ACID_ROW_COUNT" in the below SQL query equals to "2":
      """
      SELECT COUNT(*) AS ACID_ROW_COUNT FROM FT_T_ACID
      WHERE ACCT_ID IN
      (
        SELECT ACCT_ID FROM FT_T_ACID
        WHERE ACCT_ALT_ID = '${VAR_RDMID}'
        AND end_tms IS NULL
       )
       AND ACCT_ID_CTXT_TYP IN ('RDMID','SITCAFNDID','SCSITCAFNDID')
      """

    And I expect value of column "ACID_ROW_COUNT" in the below SQL query equals to "0":
      """
      SELECT COUNT(*) AS ACID_ROW_COUNT FROM FT_T_ACID
      WHERE ACCT_ID IN
      (
        SELECT ACCT_ID FROM FT_T_ACID
        WHERE ACCT_ALT_ID = '${VAR_RDMID}'
        AND end_tms IS NULL
       )
       AND ACCT_ID_CTXT_TYP IN ('UNIBUSNUM')
      """

    And I expect value of column "ACCT_ROW_COUNT" in the below SQL query equals to "1":
      """
      SELECT COUNT(*) AS ACCT_ROW_COUNT FROM FT_T_ACCT
      WHERE ACCT_ID IN
      (
        SELECT ACCT_ID FROM FT_T_ACID
        WHERE ACCT_ALT_ID = '${VAR_RDMID}'
        AND end_tms IS NULL
      )
      """

    And I expect value of column "ACDE_ROW_COUNT" in the below SQL query equals to "1":
      """
      SELECT COUNT(*) AS ACDE_ROW_COUNT  FROM FT_T_ACDE
      WHERE ACCT_ID IN
      (
        SELECT ACCT_ID FROM FT_T_ACID
        WHERE ACCT_ALT_ID = '${VAR_RDMID}'
        AND end_tms IS NULL
      )
      """

  Scenario: TC6: Verify TW_SITCA_FND_ID is not loaded in ACID table and TRD_CHINESE_LONG_PORT_FUND_NME, TRD_CHINESE_SHRT_PORT_FUND_NME fields loaded into ACDE tables for CRTSID TT56_USDA

    Given I extract below values for row 4 from EXCEL file "${PORTFOLIO_TEMPLATE}" in local folder "${testdata.path}/testdata/infiles" and assign to variables:
      | PORTFOLIO_NAME                 | VAR_ACCTNAME  |
      | RDM_ID                         | VAR_RDMID     |
      | TRD_CHINESE_LONG_PORT_FUND_NME | VAR_LONGNAME  |
      | TRD_CHINESE_SHRT_PORT_FUND_NME | VAR_SHORTNAME |

    And I expect value of column "PORT_NAME" in the below SQL query equals to "${VAR_ACCTNAME}":
      """
      SELECT ACCT_DESC as  PORT_NAME FROM FT_T_ACCT
      WHERE ACCT_ID IN
      (
        SELECT ACCT_ID FROM FT_T_ACID
        WHERE ACCT_ALT_ID = '${VAR_RDMID}'
        AND end_tms IS NULL
      )
      """

    And I expect value of column "SHORT_NAME" in the below SQL query equals to "${VAR_SHORTNAME}":
      """
      SELECT ACCT_NME AS SHORT_NAME FROM FT_T_ACDE
      WHERE ACCT_ID IN
      (
        SELECT ACCT_ID FROM FT_T_ACID
        WHERE ACCT_ALT_ID = '${VAR_RDMID}'
        AND end_tms IS NULL
      )
      """

    And I expect value of column "LONG_NAME" in the below SQL query equals to "${VAR_LONGNAME}":
      """
      SELECT ACCT_DESC AS LONG_NAME FROM FT_T_ACDE
      WHERE ACCT_ID IN
      (
        SELECT ACCT_ID FROM FT_T_ACID
        WHERE ACCT_ALT_ID = '${VAR_RDMID}'
        AND end_tms IS NULL
      )
      """

    And I expect value of column "ACID_ROW_COUNT" in the below SQL query equals to "2":
      """
      SELECT COUNT(*) AS ACID_ROW_COUNT FROM FT_T_ACID
      WHERE ACCT_ID IN
      (
        SELECT ACCT_ID FROM FT_T_ACID
        WHERE ACCT_ALT_ID = '${VAR_RDMID}'
        AND end_tms IS NULL
       )
       AND ACCT_ID_CTXT_TYP IN ('RDMID','SCUNIBUSNUM')
      """

    And I expect value of column "ACID_ROW_COUNT" in the below SQL query equals to "0":
      """
      SELECT COUNT(*) AS ACID_ROW_COUNT FROM FT_T_ACID
      WHERE ACCT_ID IN
      (
        SELECT ACCT_ID FROM FT_T_ACID
        WHERE ACCT_ALT_ID = '${VAR_RDMID}'
        AND end_tms IS NULL
       )
       AND ACCT_ID_CTXT_TYP IN ('SITCAFNDID')
      """

    And I expect value of column "ACCT_ROW_COUNT" in the below SQL query equals to "1":
      """
      SELECT COUNT(*) AS ACCT_ROW_COUNT FROM FT_T_ACCT
      WHERE ACCT_ID IN
      (
        SELECT ACCT_ID FROM FT_T_ACID
        WHERE ACCT_ALT_ID = '${VAR_RDMID}'
        AND end_tms IS NULL
      )
      """

    And I expect value of column "ACDE_ROW_COUNT" in the below SQL query equals to "1":
      """
      SELECT COUNT(*) AS ACDE_ROW_COUNT  FROM FT_T_ACDE
      WHERE ACCT_ID IN
      (
        SELECT ACCT_ID FROM FT_T_ACID
        WHERE ACCT_ALT_ID = '${VAR_RDMID}'
        AND end_tms IS NULL
      )
      """

  Scenario: TC7: Verify TW_FND_UNIFORM_NUM, TW_SITCA_FND_ID is loaded in ACID table and TRD_CHINESE_LONG_PORT_FUND_NME, TRD_CHINESE_SHRT_PORT_FUND_NME fields are not loaded into ACDE tables for CRTSID TT56_AUDA

    Given I extract below values for row 6 from EXCEL file "${PORTFOLIO_TEMPLATE}" in local folder "${testdata.path}/testdata/infiles" and assign to variables:
      | PORTFOLIO_NAME | VAR_ACCTNAME |
      | RDM_ID         | VAR_RDMID    |

    And I expect value of column "PORT_NAME" in the below SQL query equals to "${VAR_ACCTNAME}":
      """
      SELECT ACCT_DESC as  PORT_NAME FROM FT_T_ACCT
      WHERE ACCT_ID IN
      (
        SELECT ACCT_ID FROM FT_T_ACID
        WHERE ACCT_ALT_ID = '${VAR_RDMID}'
        AND end_tms IS NULL
      )
      """

    And I expect value of column "ACID_ROW_COUNT" in the below SQL query equals to "3":
      """
      SELECT COUNT(*) AS ACID_ROW_COUNT FROM FT_T_ACID
      WHERE ACCT_ID IN
      (
        SELECT ACCT_ID FROM FT_T_ACID
        WHERE ACCT_ALT_ID = '${VAR_RDMID}'
        AND end_tms IS NULL
       )
       AND ACCT_ID_CTXT_TYP IN ('RDMID','SCUNIBUSNUM','SCSITCAFNDID')
      """


    And I expect value of column "ACCT_ROW_COUNT" in the below SQL query equals to "1":
      """
      SELECT COUNT(*) AS ACCT_ROW_COUNT FROM FT_T_ACCT
      WHERE ACCT_ID IN
      (
        SELECT ACCT_ID FROM FT_T_ACID
        WHERE ACCT_ALT_ID = '${VAR_RDMID}'
        AND end_tms IS NULL
      )
      """

    And I expect value of column "ACDE_ROW_COUNT" in the below SQL query equals to "0":
      """
      SELECT COUNT(*) AS ACDE_ROW_COUNT  FROM FT_T_ACDE
      WHERE ACCT_ID IN
      (
        SELECT ACCT_ID FROM FT_T_ACID
        WHERE ACCT_ALT_ID = '${VAR_RDMID}'
        AND end_tms IS NULL
      )
      """

  Scenario: TC8: Verify TW_FND_UNIFORM_NUM, TW_SITCA_FND_ID is loaded in ACID table and TRD_CHINESE_SHRT_PORT_FUND_NME fields are not loaded into ACDE tables for CRTSID TT56_ZARA

    Given I extract below values for row 8 from EXCEL file "${PORTFOLIO_TEMPLATE}" in local folder "${testdata.path}/testdata/infiles" and assign to variables:
      | PORTFOLIO_NAME                 | VAR_ACCTNAME  |
      | RDM_ID                         | VAR_RDMID     |
      | TRD_CHINESE_LONG_PORT_FUND_NME | VAR_LONGNAME  |
      | TRD_CHINESE_SHRT_PORT_FUND_NME | VAR_SHORTNAME |

    And I expect value of column "PORT_NAME" in the below SQL query equals to "${VAR_ACCTNAME}":
      """
      SELECT ACCT_DESC as  PORT_NAME FROM FT_T_ACCT
      WHERE ACCT_ID IN
      (
        SELECT ACCT_ID FROM FT_T_ACID
        WHERE ACCT_ALT_ID = '${VAR_RDMID}'
        AND end_tms IS NULL
      )
      """

    And I expect value of column "ACID_ROW_COUNT" in the below SQL query equals to "3":
      """
      SELECT COUNT(*) AS ACID_ROW_COUNT FROM FT_T_ACID
      WHERE ACCT_ID IN
      (
        SELECT ACCT_ID FROM FT_T_ACID
        WHERE ACCT_ALT_ID = '${VAR_RDMID}'
        AND end_tms IS NULL
       )
       AND ACCT_ID_CTXT_TYP IN ('RDMID','SCUNIBUSNUM','SCSITCAFNDID')
      """


    And I expect value of column "ACCT_ROW_COUNT" in the below SQL query equals to "1":
      """
      SELECT COUNT(*) AS ACCT_ROW_COUNT FROM FT_T_ACCT
      WHERE ACCT_ID IN
      (
        SELECT ACCT_ID FROM FT_T_ACID
        WHERE ACCT_ALT_ID = '${VAR_RDMID}'
        AND end_tms IS NULL
      )
      """

    And I expect value of column "ACDE_ROW_COUNT" in the below SQL query equals to "1":
      """
      SELECT COUNT(*) AS ACDE_ROW_COUNT  FROM FT_T_ACDE
      WHERE ACCT_ID IN
      (
        SELECT ACCT_ID FROM FT_T_ACID
        WHERE ACCT_ALT_ID = '${VAR_RDMID}'
        AND end_tms IS NULL
      )
      """

  Scenario: TC9: Verify TW_FND_UNIFORM_NUM, TW_SITCA_FND_ID is loaded in ACID table and TRD_CHINESE_LONG_PORT_FUND_NME fields are not loaded into ACDE tables for CRTSID TT56_AUDB

    Given I extract below values for row 7 from EXCEL file "${PORTFOLIO_TEMPLATE}" in local folder "${testdata.path}/testdata/infiles" and assign to variables:
      | PORTFOLIO_NAME                 | VAR_ACCTNAME  |
      | RDM_ID                         | VAR_RDMID     |
      | TRD_CHINESE_SHRT_PORT_FUND_NME | VAR_SHORTNAME |

    And I expect value of column "PORT_NAME" in the below SQL query equals to "${VAR_ACCTNAME}":
      """
      SELECT ACCT_DESC as  PORT_NAME FROM FT_T_ACCT
      WHERE ACCT_ID IN
      (
        SELECT ACCT_ID FROM FT_T_ACID
        WHERE ACCT_ALT_ID = '${VAR_RDMID}'
        AND end_tms IS NULL
      )
      """

    And I expect value of column "ACID_ROW_COUNT" in the below SQL query equals to "3":
      """
      SELECT COUNT(*) AS ACID_ROW_COUNT FROM FT_T_ACID
      WHERE ACCT_ID IN
      (
        SELECT ACCT_ID FROM FT_T_ACID
        WHERE ACCT_ALT_ID = '${VAR_RDMID}'
        AND end_tms IS NULL
       )
       AND ACCT_ID_CTXT_TYP IN ('RDMID','SCUNIBUSNUM','SCSITCAFNDID')
      """


    And I expect value of column "ACCT_ROW_COUNT" in the below SQL query equals to "1":
      """
      SELECT COUNT(*) AS ACCT_ROW_COUNT FROM FT_T_ACCT
      WHERE ACCT_ID IN
      (
        SELECT ACCT_ID FROM FT_T_ACID
        WHERE ACCT_ALT_ID = '${VAR_RDMID}'
        AND end_tms IS NULL
      )
      """

    And I expect value of column "ACDE_ROW_COUNT" in the below SQL query equals to "1":
      """
      SELECT COUNT(*) AS ACDE_ROW_COUNT  FROM FT_T_ACDE
      WHERE ACCT_ID IN
      (
        SELECT ACCT_ID FROM FT_T_ACID
        WHERE ACCT_ALT_ID = '${VAR_RDMID}'
        AND end_tms IS NULL
      )
      """

    And I expect value of column "SHORT_NAME" in the below SQL query equals to "${VAR_SHORTNAME}":
      """
      SELECT ACCT_NME AS SHORT_NAME FROM FT_T_ACDE
      WHERE ACCT_ID IN
      (
        SELECT ACCT_ID FROM FT_T_ACID
        WHERE ACCT_ALT_ID = '${VAR_RDMID}'
        AND end_tms IS NULL
      )
      """

    And I expect value of column "LONG_NAME_COUNT" in the below SQL query equals to "1":
      """
      SELECT COUNT(*) AS LONG_NAME_COUNT FROM FT_T_ACDE
      WHERE ACCT_ID IN
      (
        SELECT ACCT_ID FROM FT_T_ACID
        WHERE ACCT_ALT_ID = '${VAR_RDMID}'
        AND end_tms IS NULL
      )
      """

  Scenario: TC10: Verify TW_FND_UNIFORM_NUM, TW_SITCA_FND_ID is not loaded in ACID table and TRD_CHINESE_LONG_PORT_FUND_NME and TRD_CHINESE_SHRT_PORT_FUND_NME fields are not loaded into ACDE tables for CRTSID TT56_ZAR_B

    Given I extract below values for row 9 from EXCEL file "${PORTFOLIO_TEMPLATE}" in local folder "${testdata.path}/testdata/infiles" and assign to variables:
      | PORTFOLIO_NAME                 | VAR_ACCTNAME  |
      | RDM_ID                         | VAR_RDMID     |
      | TRD_CHINESE_LONG_PORT_FUND_NME | VAR_LONGNAME  |
      | TRD_CHINESE_SHRT_PORT_FUND_NME | VAR_SHORTNAME |

    And I expect value of column "PORT_NAME" in the below SQL query equals to "${VAR_ACCTNAME}":
      """
      SELECT ACCT_DESC as  PORT_NAME FROM FT_T_ACCT
      WHERE ACCT_ID IN
      (
        SELECT ACCT_ID FROM FT_T_ACID
        WHERE ACCT_ALT_ID = '${VAR_RDMID}'
        AND end_tms IS NULL
      )
      """

    And I expect value of column "ACID_ROW_COUNT" in the below SQL query equals to "1":
      """
      SELECT COUNT(*) AS ACID_ROW_COUNT FROM FT_T_ACID
      WHERE ACCT_ID IN
      (
        SELECT ACCT_ID FROM FT_T_ACID
        WHERE ACCT_ALT_ID = '${VAR_RDMID}'
        AND end_tms IS NULL
       )
       AND ACCT_ID_CTXT_TYP IN ('RDMID')
      """

    And I expect value of column "ACID_ROW_COUNT" in the below SQL query equals to "0":
      """
      SELECT COUNT(*) AS ACID_ROW_COUNT FROM FT_T_ACID
      WHERE ACCT_ID IN
      (
        SELECT ACCT_ID FROM FT_T_ACID
        WHERE ACCT_ALT_ID = '${VAR_RDMID}'
        AND end_tms IS NULL
       )
       AND ACCT_ID_CTXT_TYP IN ('UNIBUSNUM','SITCAFNDID')
      """

    And I expect value of column "ACCT_ROW_COUNT" in the below SQL query equals to "1":
      """
      SELECT COUNT(*) AS ACCT_ROW_COUNT FROM FT_T_ACCT
      WHERE ACCT_ID IN
      (
        SELECT ACCT_ID FROM FT_T_ACID
        WHERE ACCT_ALT_ID = '${VAR_RDMID}'
        AND end_tms IS NULL
      )
      """

    And I expect value of column "ACDE_ROW_COUNT" in the below SQL query equals to "0":
      """
      SELECT COUNT(*) AS ACDE_ROW_COUNT  FROM FT_T_ACDE
      WHERE ACCT_ID IN
      (
        SELECT ACCT_ID FROM FT_T_ACID
        WHERE ACCT_ALT_ID = '${VAR_RDMID}'
        AND end_tms IS NULL
      )
      """
