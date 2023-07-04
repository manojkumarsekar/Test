#Subscription and Redemption flow - analysis code mapping for Taiwan
#https://jira.intranet.asia/browse/TOM-4327
#https://collaborate.intranet.asia/display/TOMVN/TW++R5+-+Subscription+and+Redemption+flow+-+analysis+code+mapping+for+Taiwan
# https://collaborate.intranet.asia/pages/viewpage.action?spaceKey=TOMTN&title=New+Cash+Notifications+to+BNP+-+GFCash

@gc_interface_cash
@dmp_regression_integrationtest
@dmp_taiwan
@tom_4327 @tom_5057 @file96bnp
Feature: Subscription and Redemption made by Investors into the TW Funds managed in Aladdin are transmitted to BNP

  For File 96, Value in field "CASH_TYPE" received from BRS is mapped to the field "PaymentType" sent to BNP
  For TW Funds, BRS codes needs to be translated
  Below table depicts the expected translation
  Fund         | CASH_TYPE(BRS) | Reason (BRS)    | AMOUNT (BRS) | PaymentType (BNP) | Value (BNP)
  TW           | CASHIN         | FX_HEDGE        | 1000000      | FXPROF            | 1000000
  TW           | CASHOUT        | FX_HEDGE        | -1000000     | FXLOSS            | 1000000
  TW           | CASHIN         | not FX_HEDGE    | 1000000      | SGINFL            | 1000000
  TW           | CASHOUT        | not FX_HEDGE    | -1000000     | SGOUFL            | 1000000

  Below Scenarios are handled as part of this feature
  1. Subscription for Taiwan Fund
  2. Redemption for Taiwan Fund

  Scenario: TC_1: Test Subscription and Redemption for Taiwan Fund

    Given I assign "tests/test-data/dmp-interfaces/Taiwan/CASH_FILE96" to variable "testdata.path"
    And I assign "File96_TW_Sub" to variable "PUBLISHING_FILE_NAME"
    And I assign "esi_newcash_subs_TW.xml" to variable "LOAD_SUBS_FILE_NAME"
    And I assign "esi_newcash_reds_TW.xml" to variable "LOAD_REDS_FILE_NAME"
    And I assign "esi_newcash_reds_TW_FX_HEDGE.xml" to variable "LOAD_REDS_FXHEDGE_FILE_NAME"
    And I assign "esi_newcash_subs_TW_FX_HEDGE.xml" to variable "LOAD_SUBS_FXHEDGE_FILE_NAME"
    And I generate value with date format "YYYYMMdd" and assign to variable "VAR_SYSDATE"

    And I execute below query to "Clear the old data"
    """
    ${testdata.path}/sql/cleardown_TW_testdata.sql
    """

    When I extract value from the xml file "${testdata.path}/testdata/${LOAD_SUBS_FILE_NAME}" with tagName "PORTFOLIOS_PORTFOLIO_NAME" to variable "PORTFOLIO"
    And I extract value from the xml file "${testdata.path}/testdata/${LOAD_SUBS_FILE_NAME}" with tagName "SETTLE_DATE" to variable "SUBS_SETT_DATE_TEMP"
    And I extract value from the xml file "${testdata.path}/testdata/${LOAD_REDS_FILE_NAME}" with tagName "SETTLE_DATE" to variable "REDS_SETT_DATE_TEMP"
    And I extract value from the xml file "${testdata.path}/testdata/${LOAD_SUBS_FXHEDGE_FILE_NAME}" with tagName "SETTLE_DATE" to variable "SUBS_FXHEDGE_SETT_DATE_TEMP"
    And I extract value from the xml file "${testdata.path}/testdata/${LOAD_REDS_FXHEDGE_FILE_NAME}" with tagName "SETTLE_DATE" to variable "REDS_FXHEDGE_SETT_DATE_TEMP"

    And I modify date "${SUBS_SETT_DATE_TEMP}" with "+0d" from source format "M/dd/yyyy" to destination format "dd/MM/yyyy" and assign to "SUBS_SETT_DATE"
    And I modify date "${REDS_SETT_DATE_TEMP}" with "+0d" from source format "M/dd/yyyy" to destination format "dd/MM/yyyy" and assign to "REDS_SETT_DATE"
    And I modify date "${SUBS_FXHEDGE_SETT_DATE_TEMP}" with "+0d" from source format "M/dd/yyyy" to destination format "dd/MM/yyyy" and assign to "SUBS_FXHEDGE_SETT_DATE"
    And I modify date "${REDS_FXHEDGE_SETT_DATE_TEMP}" with "+0d" from source format "M/dd/yyyy" to destination format "dd/MM/yyyy" and assign to "REDS_FXHEDGE_SETT_DATE"

    When I copy files below from local folder "${testdata.path}/testdata" to the host "dmp.ssh.inbound" folder "${dmp.ssh.inbound.path}":
      | ${LOAD_SUBS_FILE_NAME}         |
      | ${LOAD_REDS_FILE_NAME}         |
      | ${LOAD_SUBS_FXHEDGE_FILE_NAME} |
      | ${LOAD_REDS_FXHEDGE_FILE_NAME} |

    And I process files with below parameters and wait for the job to be completed
      | BUSINESS_FEED |                             |
      | FILE_PATTERN  | esi_newcash*.xml            |
      | MESSAGE_TYPE  | EIS_MT_BRS_CASHALLOC_FILE96 |

    Then I expect value of column "GU_ID" in the below SQL query equals to "TW":
    """
      select GU_ID from ft_t_acgu where
      ACCT_ID in (select ACCT_ID from ft_t_acid where ACCT_ALT_ID ='${PORTFOLIO}')
      and ACCT_GU_PURP_TYP ='INVLOCTN'
      """

        #Check if EXST is created with genreasontype populated
    And I expect value of column "EXST_PROCESSED_ROW_COUNT" in the below SQL query equals to "2":
      """
      SELECT COUNT(*) AS EXST_PROCESSED_ROW_COUNT FROM FT_T_EXST EXST
      WHERE EXST.EXEC_TRD_STAT_TYP = 'NEWM'
      AND EXST.GEN_CNT = (SELECT MAX (GEN_CNT) FROM FT_T_EXST EXST1 WHERE EXST1.EXEC_TRD_ID = EXST.EXEC_TRD_ID AND EXST1.DATA_SRC_ID= 'BRS')
      AND EXST.DATA_SRC_ID = 'BRS'
      AND GEN_REAS_TXT <> 'FX_HEDGE'
      AND EXST.EXEC_TRD_ID IN ( SELECT EXEC_TRD_ID FROM FT_T_EXTR
      WHERE TRD_ID = '58531' AND  END_TMS IS NULL
      )
      """

     #Check if EXST is created with genreasontype populated
    And I expect value of column "EXST_PROCESSED_ROW_COUNT" in the below SQL query equals to "2":
      """
      SELECT COUNT(*) AS EXST_PROCESSED_ROW_COUNT FROM FT_T_EXST EXST
      WHERE EXST.EXEC_TRD_STAT_TYP = 'NEWM'
      AND EXST.GEN_CNT = (SELECT MAX (GEN_CNT) FROM FT_T_EXST EXST1 WHERE EXST1.EXEC_TRD_ID = EXST.EXEC_TRD_ID AND EXST1.DATA_SRC_ID= 'BRS')
      AND EXST.DATA_SRC_ID = 'BRS'
      AND GEN_REAS_TXT = 'FX_HEDGE'
      AND EXST.EXEC_TRD_ID IN ( SELECT EXEC_TRD_ID FROM FT_T_EXTR
      WHERE TRD_ID = '58531' AND  END_TMS IS NULL
      )
      """

    And I remove below files in the host "dmp.ssh.inbound" from folder "/dmp/out/bnp/intraday" if exists:
      | ${PUBLISHING_FILE_NAME}_${VAR_SYSDATE}_1.xml |

    And I process publishing wrapper with below parameters and wait for the job to be completed
      | PUBLISHING_FILE_NAME | ${PUBLISHING_FILE_NAME}.xml              |
      | SUBSCRIPTION_NAME    | EIS_DMP_TO_BNP_CASHALLOCATION_FILE96_SUB |

    Then I expect below files to be present in the host "dmp.ssh.outbound" into folder "/dmp/out/bnp/intraday" after processing:
      | ${PUBLISHING_FILE_NAME}_${VAR_SYSDATE}_1.xml |

    And I copy files below from remote folder "/dmp/out/bnp/intraday" on host "dmp.ssh.outbound" into local folder "${testdata.path}/outbound":
      | ${PUBLISHING_FILE_NAME}_${VAR_SYSDATE}_1.xml |

    And I expect value from xml file "${testdata.path}/outbound/${PUBLISHING_FILE_NAME}_${VAR_SYSDATE}_1.xml" with xpath "//FundID[text()='${PORTFOLIO}']/../ValueDate[text()='${SUBS_SETT_DATE}']/../PaymentType" should be "SGINFL"
    And I expect value from xml file "${testdata.path}/outbound/${PUBLISHING_FILE_NAME}_${VAR_SYSDATE}_1.xml" with xpath "//FundID[text()='${PORTFOLIO}']/../ValueDate[text()='${REDS_SETT_DATE}']/../PaymentType" should be "SGOUFL"
    And I expect value from xml file "${testdata.path}/outbound/${PUBLISHING_FILE_NAME}_${VAR_SYSDATE}_1.xml" with xpath "//FundID[text()='${PORTFOLIO}']/../ValueDate[text()='${SUBS_FXHEDGE_SETT_DATE}']/../PaymentType" should be "FXPROF"
    And I expect value from xml file "${testdata.path}/outbound/${PUBLISHING_FILE_NAME}_${VAR_SYSDATE}_1.xml" with xpath "//FundID[text()='${PORTFOLIO}']/../ValueDate[text()='${REDS_FXHEDGE_SETT_DATE}']/../PaymentType" should be "FXLOSS"
    And I expect value from xml file "${testdata.path}/outbound/${PUBLISHING_FILE_NAME}_${VAR_SYSDATE}_1.xml" with xpath "//FundID[text()='${PORTFOLIO}']/../ValueDate[text()='${SUBS_SETT_DATE}']/../Value" should be "1000000"
    And I expect value from xml file "${testdata.path}/outbound/${PUBLISHING_FILE_NAME}_${VAR_SYSDATE}_1.xml" with xpath "//FundID[text()='${PORTFOLIO}']/../ValueDate[text()='${REDS_SETT_DATE}']/../Value" should be "1000000"
    And I expect value from xml file "${testdata.path}/outbound/${PUBLISHING_FILE_NAME}_${VAR_SYSDATE}_1.xml" with xpath "//FundID[text()='${PORTFOLIO}']/../ValueDate[text()='${SUBS_FXHEDGE_SETT_DATE}']/../Value" should be "1000000"
    And I expect value from xml file "${testdata.path}/outbound/${PUBLISHING_FILE_NAME}_${VAR_SYSDATE}_1.xml" with xpath "//FundID[text()='${PORTFOLIO}']/../ValueDate[text()='${REDS_FXHEDGE_SETT_DATE}']/../Value" should be "1000000"

    And I remove below files with pattern in the host "dmp.ssh.inbound" from folder "/dmp/out/bnp/intraday" if exists:
      | ${PUBLISHING_FILE_NAME}_*.xml |