#Subscription and Redemption flow - analysis code mapping for Vietnam
#https://jira.intranet.asia/browse/TOM-3437
#https://collaborate.intranet.asia/display/TOMVN/VN+00.2.3+R4+-+Subscription+and+Redemption+flow+-+analysis+code+mapping+for+Vietnam

#Subscription and Redemption flow - analysis code mapping for Malaysia
#https://jira.intranet.asia/browse/TOM-3661 - It is additional test condition for existing(TOM-3437) feature so using the same file
#https://collaborate.intranet.asia/pages/viewpage.action?spaceKey=TOMMY&title=MY_11+-+Cash+Processing

# https://jira.intranet.asia/browse/TOM-4327 : feature file for this is added under Taiwan folder as same MDX is getting enhanced with TW changes

@gc_interface_cash
@dmp_regression_integrationtest
@tom_3661 @tom_3437 @tom_4327 @tom_4170 @file96bnp
Feature: Subscription and Redemption made by Investors into the Funds managed in Aladdin are transmitted to BNP

  For File 96, Value in field "CASH_TYPE" received from BRS is mapped to the field "PaymentType" sent to BNP
  For Non VN or MY Funds, codes are sent without translation
  For VN or MY Funds, BRS codes needs to be translated
  Below table depicts the expected translation

  Fund               | CASH_TYPE(BRS) | PaymentType (BNP)
  NONVN or NONMY     | CASHIN         | CASHIN
  NONVN or NONMY     | CASHOUT        | CASHOUT
  VN                 | CASHIN         | SGINFL
  VN                 | CASHOUT        | SGOUFL
  MY                 | CASHIN         | RECEIPT
  MY                 | CASHOUT        | PAYMENT

  Below Scenarios are handled as part of this feature
  1. Subscription for Vietnam Fund
  2. Redemption for Vietnam Fund
  3. Subscription for Non-Vietnam or Non- Malaysia Fund
  4. Redemption for Non-Vietnam or Non- Malaysia Fund
  5. Subscription for Malaysia Fund
  6. Redemption for Malaysia Fund

  Scenario: TC_1: Test Subscription and Redemption for Vietnam Fund

    Given I assign "tests/test-data/DevTest/TOM-3437" to variable "testdata.path"
    And I assign "File96_VN_Sub" to variable "PUBLISHING_FILE_NAME"
    And I assign "esi_newcash_subs_VN.xml" to variable "LOAD_SUBS_FILE_NAME"
    And I assign "esi_newcash_reds_VN.xml" to variable "LOAD_REDS_FILE_NAME"
    And I generate value with date format "YYYYMMdd" and assign to variable "VAR_SYSDATE"

    And I execute below query to "Clear the old data"
    """
    ${testdata.path}/sql/cleardown_VN_testdata.sql
    """

    When I extract value from the xml file "${testdata.path}/testdata/${LOAD_SUBS_FILE_NAME}" with tagName "PORTFOLIOS_PORTFOLIO_NAME" to variable "PORTFOLIO"
    And I extract value from the xml file "${testdata.path}/testdata/${LOAD_SUBS_FILE_NAME}" with tagName "SETTLE_DATE" to variable "SUBS_SETT_DATE_TEMP"
    And I extract value from the xml file "${testdata.path}/testdata/${LOAD_REDS_FILE_NAME}" with tagName "SETTLE_DATE" to variable "REDS_SETT_DATE_TEMP"
    And I modify date "${SUBS_SETT_DATE_TEMP}" with "+0d" from source format "M/dd/yyyy" to destination format "dd/MM/yyyy" and assign to "SUBS_SETT_DATE"
    And I modify date "${REDS_SETT_DATE_TEMP}" with "+0d" from source format "M/dd/yyyy" to destination format "dd/MM/yyyy" and assign to "REDS_SETT_DATE"

    When I copy files below from local folder "${testdata.path}/testdata" to the host "dmp.ssh.inbound" folder "${dmp.ssh.inbound.path}":
      | ${LOAD_SUBS_FILE_NAME} |
      | ${LOAD_REDS_FILE_NAME} |

    And I process files with below parameters and wait for the job to be completed
      | BUSINESS_FEED |                             |
      | FILE_PATTERN  | esi_newcash*.xml            |
      | MESSAGE_TYPE  | EIS_MT_BRS_CASHALLOC_FILE96 |

    And I remove below files in the host "dmp.ssh.inbound" from folder "/dmp/out/bnp/intraday" if exists:
      | ${PUBLISHING_FILE_NAME}_${VAR_SYSDATE}_1.xml |

    And I process publishing wrapper with below parameters and wait for the job to be completed
      | PUBLISHING_FILE_NAME | ${PUBLISHING_FILE_NAME}.xml              |
      | SUBSCRIPTION_NAME    | EIS_DMP_TO_BNP_CASHALLOCATION_FILE96_SUB |

    Then I expect below files to be present in the host "dmp.ssh.outbound" into folder "/dmp/out/bnp/intraday" after processing:
      | ${PUBLISHING_FILE_NAME}_${VAR_SYSDATE}_1.xml |

    And I copy files below from remote folder "/dmp/out/bnp/intraday" on host "dmp.ssh.outbound" into local folder "${testdata.path}/outbound":
      | ${PUBLISHING_FILE_NAME}_${VAR_SYSDATE}_1.xml |

    Then I expect value of column "GU_ID" in the below SQL query equals to "VN":
    """
      select GU_ID from ft_t_acgu where
      ACCT_ID in (select ACCT_ID from ft_t_acid where ACCT_ALT_ID ='${PORTFOLIO}')
      and ACCT_GU_PURP_TYP ='INVLOCTN'
      """

    And I expect value from xml file "${testdata.path}/outbound/${PUBLISHING_FILE_NAME}_${VAR_SYSDATE}_1.xml" with xpath "//FundID[text()='${PORTFOLIO}']/../ValueDate[text()='${SUBS_SETT_DATE}']/../PaymentType" should be "SGINFL"
    And I expect value from xml file "${testdata.path}/outbound/${PUBLISHING_FILE_NAME}_${VAR_SYSDATE}_1.xml" with xpath "//FundID[text()='${PORTFOLIO}']/../ValueDate[text()='${REDS_SETT_DATE}']/../PaymentType" should be "SGOUFL"

  Scenario: TC_2: Test Subscription And Redemption for Non-Vietnam or Non-Malaysia Fund

    Given I assign "tests/test-data/DevTest/TOM-3437" to variable "testdata.path"
    And I assign "File96_Non_VN_Non_MY_Sub" to variable "PUBLISHING_FILE_NAME"
    And I assign "esi_newcash_subs_Non-VN_Non-MY.xml" to variable "LOAD_SUBS_FILE_NAME"
    And I assign "esi_newcash_reds_Non-VN_Non-MY.xml" to variable "LOAD_REDS_FILE_NAME"
    And I generate value with date format "YYYYMMdd" and assign to variable "VAR_SYSDATE"

    When I extract value from the xml file "${testdata.path}/testdata/${LOAD_SUBS_FILE_NAME}" with tagName "PORTFOLIOS_PORTFOLIO_NAME" to variable "PORTFOLIO"
    And I extract value from the xml file "${testdata.path}/testdata/${LOAD_SUBS_FILE_NAME}" with tagName "SETTLE_DATE" to variable "SUBS_SETT_DATE_TMP"
    And I extract value from the xml file "${testdata.path}/testdata/${LOAD_REDS_FILE_NAME}" with tagName "SETTLE_DATE" to variable "REDS_SETT_DATE_TMP"
    And I modify date "${SUBS_SETT_DATE_TMP}" with "+0d" from source format "M/dd/yyyy" to destination format "dd/MM/yyyy" and assign to "SUBS_SETT_DATE"
    And I modify date "${REDS_SETT_DATE_TMP}" with "+0d" from source format "M/dd/yyyy" to destination format "dd/MM/yyyy" and assign to "REDS_SETT_DATE"


    And I execute below query to "Clear the old data"
    """
    ${testdata.path}/sql/cleardown_Non-VN_Non-MY-testdata.sql
    """

    When I copy files below from local folder "${testdata.path}/testdata" to the host "dmp.ssh.inbound" folder "${dmp.ssh.inbound.path}":
      | ${LOAD_SUBS_FILE_NAME} |
      | ${LOAD_REDS_FILE_NAME} |

    And I process files with below parameters and wait for the job to be completed
      | BUSINESS_FEED |                             |
      | FILE_PATTERN  | esi_newcash*.xml            |
      | MESSAGE_TYPE  | EIS_MT_BRS_CASHALLOC_FILE96 |

    And I remove below files in the host "dmp.ssh.inbound" from folder "/dmp/out/bnp/intraday" if exists:
      | ${PUBLISHING_FILE_NAME}_${VAR_SYSDATE}_1.xml |

    And I process publishing wrapper with below parameters and wait for the job to be completed
      | PUBLISHING_FILE_NAME | ${PUBLISHING_FILE_NAME}.xml              |
      | SUBSCRIPTION_NAME    | EIS_DMP_TO_BNP_CASHALLOCATION_FILE96_SUB |

    Then I expect below files to be present in the host "dmp.ssh.outbound" into folder "/dmp/out/bnp/intraday" after processing:
      | ${PUBLISHING_FILE_NAME}_${VAR_SYSDATE}_1.xml |

    Then I copy files below from remote folder "/dmp/out/bnp/intraday" on host "dmp.ssh.outbound" into local folder "${testdata.path}/outbound":
      | ${PUBLISHING_FILE_NAME}_${VAR_SYSDATE}_1.xml |

    Then I expect value of column "GU_ID" in the below SQL query equals to "0":
    """
      select COUNT(*) AS GU_ID from ft_t_acgu where
      ACCT_ID in (select ACCT_ID from ft_t_acid where ACCT_ALT_ID ='${PORTFOLIO}')
      and ACCT_GU_PURP_TYP ='INVLOCTN' and GU_ID='VN'
      """

    Then I expect value from xml file "${testdata.path}/outbound/${PUBLISHING_FILE_NAME}_${VAR_SYSDATE}_1.xml" with xpath "//FundID[text()='${PORTFOLIO}']/../ValueDate[text()='${SUBS_SETT_DATE}']/../PaymentType" should be "CASHIN"
    Then I expect value from xml file "${testdata.path}/outbound/${PUBLISHING_FILE_NAME}_${VAR_SYSDATE}_1.xml" with xpath "//FundID[text()='${PORTFOLIO}']/../ValueDate[text()='${REDS_SETT_DATE}']/../PaymentType" should be "CASHOUT"

  Scenario: TC_3: Test Subscription and Redemption for Malaysia Fund

    Given I assign "tests/test-data/DevTest/TOM-3437" to variable "testdata.path"
    And I assign "File96_MY_Sub" to variable "PUBLISHING_FILE_NAME"
    And I assign "esi_newcash_subs_MY.xml" to variable "LOAD_SUBS_FILE_NAME"
    And I assign "esi_newcash_reds_MY.xml" to variable "LOAD_REDS_FILE_NAME"
    And I generate value with date format "YYYYMMdd" and assign to variable "VAR_SYSDATE"

    When I extract value from the xml file "${testdata.path}/testdata/${LOAD_SUBS_FILE_NAME}" with tagName "PORTFOLIOS_PORTFOLIO_NAME" to variable "PORTFOLIO"
    And I extract value from the xml file "${testdata.path}/testdata/${LOAD_SUBS_FILE_NAME}" with tagName "SETTLE_DATE" to variable "SUBS_SETT_DATE_TMP"
    And I extract value from the xml file "${testdata.path}/testdata/${LOAD_REDS_FILE_NAME}" with tagName "SETTLE_DATE" to variable "REDS_SETT_DATE_TMP"
    And I modify date "${SUBS_SETT_DATE_TMP}" with "+0d" from source format "M/dd/yyyy" to destination format "dd/MM/yyyy" and assign to "SUBS_SETT_DATE"
    And I modify date "${REDS_SETT_DATE_TMP}" with "+0d" from source format "M/dd/yyyy" to destination format "dd/MM/yyyy" and assign to "REDS_SETT_DATE"

    And I execute below query to "Clear the old data"
    """
    ${testdata.path}/sql/cleardown_MY_testdata.sql
    """

    When I copy files below from local folder "${testdata.path}/testdata" to the host "dmp.ssh.inbound" folder "${dmp.ssh.inbound.path}":
      | ${LOAD_SUBS_FILE_NAME} |
      | ${LOAD_REDS_FILE_NAME} |

    And I process files with below parameters and wait for the job to be completed
      | BUSINESS_FEED |                             |
      | FILE_PATTERN  | esi_newcash*.xml            |
      | MESSAGE_TYPE  | EIS_MT_BRS_CASHALLOC_FILE96 |

    And I remove below files in the host "dmp.ssh.inbound" from folder "/dmp/out/bnp/intraday" if exists:
      | ${PUBLISHING_FILE_NAME}_${VAR_SYSDATE}_1.xml |

    And I process publishing wrapper with below parameters and wait for the job to be completed
      | PUBLISHING_FILE_NAME | ${PUBLISHING_FILE_NAME}.xml              |
      | SUBSCRIPTION_NAME    | EIS_DMP_TO_BNP_CASHALLOCATION_FILE96_SUB |

    Then I expect below files to be present in the host "dmp.ssh.outbound" into folder "/dmp/out/bnp/intraday" after processing:
      | ${PUBLISHING_FILE_NAME}_${VAR_SYSDATE}_1.xml |

    And I copy files below from remote folder "/dmp/out/bnp/intraday" on host "dmp.ssh.outbound" into local folder "${testdata.path}/outbound":
      | ${PUBLISHING_FILE_NAME}_${VAR_SYSDATE}_1.xml |

    Then I expect value of column "GU_ID" in the below SQL query equals to "MY":
    """
      select GU_ID from ft_t_acgu where
      ACCT_ID in (select ACCT_ID from ft_t_acid where ACCT_ALT_ID ='${PORTFOLIO}')
      and ACCT_GU_PURP_TYP ='INVLOCTN'
      """

    And I expect value from xml file "${testdata.path}/outbound/${PUBLISHING_FILE_NAME}_${VAR_SYSDATE}_1.xml" with xpath "//FundID[text()='${PORTFOLIO}']/../ValueDate[text()='${SUBS_SETT_DATE}']/../PaymentType" should be "RECEIPT"
    And I expect value from xml file "${testdata.path}/outbound/${PUBLISHING_FILE_NAME}_${VAR_SYSDATE}_1.xml" with xpath "//FundID[text()='${PORTFOLIO}']/../ValueDate[text()='${REDS_SETT_DATE}']/../PaymentType" should be "PAYMENT"

    And I remove below files with pattern in the host "dmp.ssh.inbound" from folder "/dmp/out/bnp/intraday" if exists:
      | File96*.xml |