# =====================================================================
# Date            JIRA        Comments
# ============    ========    ========
# 23/01/2020      EISDEV-4501    Initial Version
# =====================================================================
# https://jira.pruconnect.net/browse/EISDEV-4501

@gc_interface_trades @gc_interface_orders
@dmp_regression_integrationtest
@eisdev_4501
Feature: SSDR : DaaS analysis: Action on impacted fields

  Domains received from product , following fields are impacted and the entries from DaaS need to be removed for these
  affected fields -  ORDER_PART_RL_TYP , TRN_PAY_CALC_TYP and REG_TYP

  Test #1: Load Trade and Order file
  Domains received from product , following fields are impacted and the entries from DaaS need to be removed for these
  affected fields -  ORDER_PART_RL_TYP , TRN_PAY_CALC_TYP and REG_TYP

  Scenario: Assign variables

    Given I assign "trade.xml" to variable "INPUT_TRADE_FILENAME"
    And I assign "order.xml" to variable "INPUT_ORDER_FILENAME"
    And I assign "tests/test-data/DevTest/EISDEV-4501" to variable "testdata.path"

  Scenario: Load TRADE and ORDER files to check file load not failing for domain failure.

    When I copy files below from local folder "${testdata.path}/infiles" to the host "dmp.ssh.inbound" folder "${dmp.ssh.inbound.path}":
      | ${INPUT_TRADE_FILENAME} |
      | ${INPUT_ORDER_FILENAME} |

    And I process files with below parameters and wait for the job to be completed
      | BUSINESS_FEED |                                     |
      | FILE_PATTERN  | ${INPUT_TRADE_FILENAME}             |
      | MESSAGE_TYPE  | EIS_MT_BRS_INTRADAY_TRANSACTION     |

  #Verification of successful File load INPUT_TRADE_FILENAME
    Then I expect workflow is processed in DMP with total record count as "1"
    And completed record count as "1"

    And I process files with below parameters and wait for the job to be completed
      | BUSINESS_FEED |                           |
      | FILE_PATTERN  | ${INPUT_ORDER_FILENAME}   |
      | MESSAGE_TYPE  | EIS_MT_BRS_ORDERS         |

  #Verification of successful File load INPUT_ORDER_FILENAME
    Then I expect workflow is processed in DMP with total record count as "29"
    And completed record count as "29"




