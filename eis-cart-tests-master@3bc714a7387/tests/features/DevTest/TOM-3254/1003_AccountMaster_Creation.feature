#https://jira.intranet.asia/browse/TOM-3254
#https://collaborate.intranet.asia/pages/viewpage.action?pageId=24943456

@tom_3254 @gs_ui_portfolio @gs_ui_portfolio_1003
Feature: This feature is to test the new field IRP Code through Account template file load

  Currently the "Fund Code" in the GAA Drifted Benchmark Interface file is being sourced from the identifier "CRTS Code" in Golden Source application.
  However BNP requires a fund code with "_M" at the end for all merged portfolios for Performance & Attribution reporting purpose which is currently unavailable in CRTS code.

  This feature file is to test the update of new fields "IRP Code" and "Fund Region" of Account in UI using maker checker event.

  Scenario: TC_1: Create Account through template file load

    Given I assign "PORTFOLIO_TEMPLATE_TC3.xlsx" to variable "INPUT_FILENAME"
    And I assign "tests/test-data/DevTest/TOM-3254" to variable "testdata.path"
    When I copy files below from local folder "${testdata.path}" to the host "dmp.ssh.inbound" folder "${dmp.ssh.inbound.path}":
      | ${INPUT_FILENAME} |

    Given I extract below values for row 2 from EXCEL file "${INPUT_FILENAME}" in local folder "${testdata.path}" and assign to variables:
      | PORTFOLIO_NAME | VAR_ACCTNAME |
      | CRTS_ID        | VAR_CRTSID   |
      | IRP_ID         | VAR_IRPID    |

    And I execute below query
    """
    UPDATE ft_T_acid SET end_tms = sysdate
    WHERE acct_id IN (SELECT ACCT_ID FROM FT_T_ACCT WHERE ACCT_NME = '${VAR_ACCTNAME}')
    """

    And I process files with below parameters and wait for the job to be completed
      | FILE_PATTERN  | ${INPUT_FILENAME}                    |
      | MESSAGE_TYPE  | EIS_MT_RDM_PORTFOLIO_MASTER_TEMPLATE |
      | BUSINESS_FEED |                                      |

    Then I expect value of column "IRP_ACID_COUNT" in the below SQL query equals to "1":
    """
    SELECT COUNT(*) AS IRP_ACID_COUNT FROM FT_T_ACID
    WHERE ACCT_ID IN (SELECT ACCT_ID FROM FT_T_ACCT WHERE ACCT_NME = '${VAR_ACCTNAME}')
    AND TRUNC(LAST_CHG_TMS) = TRUNC(SYSDATE)
    AND ACCT_ID_CTXT_TYP    = 'IRPID'
    AND DATA_SRC_ID         = 'EIS'
    AND LAST_CHG_USR_ID     = 'EIS_RDM_DMP_PORTFOLIO_MASTER'
    AND END_TMS IS NULL
    """
