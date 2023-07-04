#base jira : https://jira.pruconnect.net/browse/EISDEV-6736
#EISDEV-6736: Transactions are unable to match previous transaction due to multiple rows(Inv_num and Trn_code)

@gc_interface_transactions
@dmp_regression_unittest
@eisdev_6736
Feature: EXTR Should not create multiple EXEC_TRD_ID for same TRD_ID,TRN_CDE

  Should not create multiple EXEC_TRD_ID for same TRD_ID,TRN_CDE because in case MAT or SWAP, BRS send parent trade
  information in this tag TRDREL_INVNUM1

  If there are multiple rows then dmp can not identify the correct parent.

  Scenario:Initialize variables used across the feature file

    Given I assign "tests/test-data/dmp-interfaces/Exception_Management/BRS_EOD_Transactions/inputfiles" to variable "testdata.path"
    And I assign "003_1_BRS_Transaction_Parent" to variable "INPUT_FILENAME_BRS_PARENT_TRADE"
    And I assign "003_2_BRS_Transaction_Parent_UpdateTradedate" to variable "INPUT_FILENAME_BRS_PARENT_TRADEDATE_UPDATE"
    And I assign "003_3_BRS_Transaction_MAT_LinktoParent" to variable "INPUT_FILENAME_BRS_MAT_LINK_TO_PARENT"

    And I execute below query and extract values of "TRD_VAR_NUM_1" into same variables
     """
     SELECT LPAD(VREQ_FILE_SEQ.NEXTVAL+1,8,'0') AS TRD_VAR_NUM_1 FROM DUAL
     """

    And I generate value with date format "YYYYMMdd" and assign to variable "VAR_SYSDATE"

  Scenario:Load BRS Transaction for ParentTrade

    Given I create input file "${INPUT_FILENAME_BRS_PARENT_TRADE}_${VAR_SYSDATE}.xml" using template "003_1_BRS_Transaction_Parent_template.xml" from location "${testdata.path}"

    When I process "${testdata.path}/testdata/${INPUT_FILENAME_BRS_PARENT_TRADE}_${VAR_SYSDATE}.xml" file with below parameters
      | BUSINESS_FEED |                                                       |
      | FILE_PATTERN  | ${INPUT_FILENAME_BRS_PARENT_TRADE}_${VAR_SYSDATE}.xml |
      | MESSAGE_TYPE  | EIS_MT_BRS_EOD_TRANSACTION_LATAM                      |

    Then I expect workflow is processed in DMP with total record count as "1"
    Then I expect workflow is processed in DMP with success record count as "1"

  Scenario:Load BRS Transaction for ParentTrade with TradeDate update

    Given I create input file "${INPUT_FILENAME_BRS_PARENT_TRADEDATE_UPDATE}_${VAR_SYSDATE}.xml" using template "003_2_BRS_Transaction_Parent_UpdateTradedate_template.xml" from location "${testdata.path}"

    When I process "${testdata.path}/testdata/${INPUT_FILENAME_BRS_PARENT_TRADEDATE_UPDATE}_${VAR_SYSDATE}.xml" file with below parameters
      | BUSINESS_FEED |                                                                  |
      | FILE_PATTERN  | ${INPUT_FILENAME_BRS_PARENT_TRADEDATE_UPDATE}_${VAR_SYSDATE}.xml |
      | MESSAGE_TYPE  | EIS_MT_BRS_EOD_TRANSACTION_LATAM                                 |

    Then I expect workflow is processed in DMP with total record count as "1"
    Then I expect workflow is processed in DMP with success record count as "1"

    Then I expect value of column "EXTR_COUNT" in the below SQL query equals to "1":
      """
      select COUNT(*) AS EXTR_COUNT from ft_t_extr where trd_id='3502-94859${TRD_VAR_NUM_1}' and TRN_CDE='BRSEOD'
      """

  Scenario: Load BRS Transaction for Maturity trade to link to parent trade

    Given I create input file "${INPUT_FILENAME_BRS_MAT_LINK_TO_PARENT}_${VAR_SYSDATE}.xml" using template "003_3_BRS_Transaction_MAT_LinktoParent_template.xml" from location "${testdata.path}"

    When I process "${testdata.path}/testdata/${INPUT_FILENAME_BRS_MAT_LINK_TO_PARENT}_${VAR_SYSDATE}.xml" file with below parameters
      | BUSINESS_FEED |                                                             |
      | FILE_PATTERN  | ${INPUT_FILENAME_BRS_MAT_LINK_TO_PARENT}_${VAR_SYSDATE}.xml |
      | MESSAGE_TYPE  | EIS_MT_BRS_EOD_TRANSACTION_LATAM                            |

    Then I expect workflow is processed in DMP with total record count as "1"
    Then I expect workflow is processed in DMP with success record count as "1"

