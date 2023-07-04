#https://collaborate.intranet.asia/display/TOMR4/R5.IN-CAS9+DMP-%3EBRS+Intraday+New+Cash+Transactions
#https://jira.intranet.asia/browse/TOM-3947
#TOM-3947 : New outbound created for Taiwan new cash with hedge portfolio
#TOM-4177 : Append external cash transaction ID with *_H* for hedge portfolio entries
#TOM-4223 : Add two new (fixed) columns to output

@tom_3947 @taiwan_newcash_hedge @dmp_interfaces @taiwan_dmp_interfaces @taiwan_newcash @tom_4177 @tom_4223
Feature: Outbound new cash from DMP to BRS with hedge portfolio Interface Testing (R5.IN-CAS9 DMP->BRS Intraday New Cash Transactions)

  Load the shared portfolios and attach hedge portfolios.
  The Newcash interface should extract the cash transaction of the hedged portfolios also.

  Scenario: TC1: End date test accounts from ACID, ACDE and ACCR table table and setup variables

    Given I assign "tests/test-data/dmp-interfaces/Taiwan/NewCash" to variable "testdata.path"
    And I assign "0003_portfolio_template_with_hedges.xlsx" to variable "PORTFOLIO_TEMPLATE"
    And I execute below query
        """
        ${testdata.path}/sql/0003_cleardown.sql
        """

  Scenario: TC2:Load portfolio Template with shareclass details to Setup new accounts in DMP

    Given I copy files below from local folder "${testdata.path}/testdata/infiles" to the host "dmp.ssh.inbound" folder "${dmp.ssh.inbound.path}":
      | ${PORTFOLIO_TEMPLATE} |

    When I process files with below parameters and wait for the job to be completed
      | BUSINESS_FEED |                                      |
      | FILE_PATTERN  | ${PORTFOLIO_TEMPLATE}                |
      | MESSAGE_TYPE  | EIS_MT_RDM_PORTFOLIO_MASTER_TEMPLATE |

    Then I extract new job id from jblg table into a variable "JOB_ID"

    And I expect value of column "JBLG_ROW_SUCCESS_COUNT" in the below SQL query equals to "8":
      """
      SELECT TASK_SUCCESS_CNT as JBLG_ROW_SUCCESS_COUNT FROM FT_T_JBLG WHERE JOB_ID = '${JOB_ID}'
      """

  Scenario: TC3: Clear the hedge records from ACCR and insert new hedge records for testing purpose

    Given I assign "tests/test-data/dmp-interfaces/Taiwan/NewCash" to variable "testdata.path"
    And I execute below query
    """
       ${testdata.path}/sql/0003_setup_hedge.sql
    """
    Then I expect value of column "HEDGE_ROW_COUNT" in the below SQL query equals to "1":
    """
    SELECT COUNT(*) as HEDGE_ROW_COUNT FROM FT_T_ACCR where ACCT_ID in (select ACCT_ID from ft_t_acid where ACCT_ALT_ID='XTOM3947_P1SC' AND END_TMS IS NULL) AND RL_TYP = 'HEDGE' AND END_TMS IS NULL
	"""

  Scenario: TC4: Clear the Taiwan Cash data as a Prerequisite

    Given I assign "0003_TW_newcash_inbound.csv" to variable "INPUT_FILENAME"
    # Clear Taiwan Cash data
    And I execute below query
    """
    ${testdata.path}/sql/ClearData_R5_IN_CAS1_Intraday_New_Cash.sql
    """

  Scenario: TC5: Load Taiwan New Cash File

    Given I copy files below from local folder "${testdata.path}/testdata/infiles" to the host "dmp.ssh.inbound" folder "${dmp.ssh.inbound.path}":
      | ${INPUT_FILENAME} |

    When I process files with below parameters and wait for the job to be completed
      | BUSINESS_FEED |                        |
      | FILE_PATTERN  | ${INPUT_FILENAME}      |
      | MESSAGE_TYPE  | EIS_MT_TW_FAS_NEW_CASH |

    Then I extract new job id from jblg table into a variable "JOB_ID"

    And I expect value of column "JBLG_ROW_SUCCESS_COUNT" in the below SQL query equals to "3":
      """
      SELECT TASK_SUCCESS_CNT as JBLG_ROW_SUCCESS_COUNT FROM FT_T_JBLG WHERE JOB_ID = '${JOB_ID}'
      """

  Scenario: TC6: Triggering Publishing Wrapper Event for CSV file into directory for Taiwan New Cash

    Given I assign "esi_TW_newcash_outbound" to variable "PUBLISHING_FILE_NAME"
    And I generate value with date format "YYYYMMdd" and assign to variable "VAR_SYSDATE"
    And I assign "/dmp/out/brs/intraday" to variable "PUBLISHING_DIR"

    And I remove below files in the host "dmp.ssh.inbound" from folder "${PUBLISHING_DIR}" if exists:
      | ${PUBLISHING_FILE_NAME}_${VAR_SYSDATE}_1.csv |

    When I process publishing wrapper with below parameters and wait for the job to be completed
      | PUBLISHING_FILE_NAME | ${PUBLISHING_FILE_NAME}.csv          |
      | SUBSCRIPTION_NAME    | EITW_DMP_TO_BRS_CASHTRAN_FILE367_SUB |

    Then I expect below files to be present in the host "dmp.ssh.inbound" into folder "${PUBLISHING_DIR}" after processing:
      | ${PUBLISHING_FILE_NAME}_${VAR_SYSDATE}_1.csv |

    Then I copy files below from remote folder "${PUBLISHING_DIR}" on host "dmp.ssh.inbound" into local folder "tests/test-data/dmp-interfaces/Taiwan/NewCash/testdata/outfiles/actual":
      | ${PUBLISHING_FILE_NAME}_${VAR_SYSDATE}_1.csv |

    Given I assign "0003_expected_output_with_hedge.csv" to variable "NEW_CASH_MASTER_TEMPLATE"
    And I assign "${PUBLISHING_FILE_NAME}_${VAR_SYSDATE}_1.csv" to variable "NEW_CASH_CURR_FILE"

    When I capture current time stamp into variable "recon.timestamp"
    Then I expect reconciliation between generated CSV file "${testdata.path}/testdata/outfiles/actual/${NEW_CASH_CURR_FILE}" and reference CSV file "${testdata.path}/testdata/outfiles/expected/${NEW_CASH_MASTER_TEMPLATE}" should be successful and exceptions to be written to "${testdata.path}/outfiles/exceptions_${recon.timestamp}.csv" file