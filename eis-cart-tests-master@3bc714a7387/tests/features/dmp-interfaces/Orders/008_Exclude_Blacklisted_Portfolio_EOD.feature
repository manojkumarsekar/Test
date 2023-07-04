#history
#tom_3620 : New feature file created
#tom_4090 : Updated template as per TOM-3593 mapping change
#tom_3795 : Remove T-1 intraday order publishing from EOD Orders

@gc_interface_orders
@dmp_regression_integrationtest
@tom_3620 @esi_orders_exclude_black_listed_portfolio_eod @tom_4090 @tom_3795
Feature: 008 | Orders | Exclude Blacklisted Portfolios EOD

  =============================================================================================================================================
  FUND   | BCUSIP	   | ORDER ENTRY TIME	  | ORDER ID | TRN_TYP | QUANTITY
  ALALBF | BRSE1FYJ7 | 9/6/2018 1:05:32.656 | A1454804 | BUY    | 90280000000
  ALINDF | S61396966 | 9/6/2018 4:54:22.036 | A1358506 | BUY    | 925
  AIIEQP | S61396966 | 9/6/2018 4:54:22.036 | A1358506 | BUY    | 34116
  ALINDF | BRSE1FYJ7 | 9/6/2018 4:54:22.036 | AA154100 | BUY    | 90280000000
  =============================================================================================================================================
  Expected Output :
  A1454804 : Fund ALALBF is not part of exclusion list - Order should be published
  A1358506 : Fund  AIIEQP is not part of exclusion list and ALINDF is part of exclusion list - Order should be published
  AA154100 : Fund ALINDF is part of exclusion list - Order should NOT be published
  =============================================================================================================================================

  Scenario: Orders related to excluded portfolios should not be sent to STARCOM in EOD Processing. Configure portfolio ALINDF to the STARPRDEXCLPORT group
  Expected Output :  Orders related to excluded portfolio ALINDF should not be sent to STARCOM

  #Assign Variables
    Given I assign "/dmp/out/eis/starcom" to variable "PUBLISHING_DIRECTORY"
    And I generate value with date format "YYYYMMdd" and assign to variable "VAR_SYSDATE"
    And I assign "tests/test-data/dmp-interfaces/Orders" to variable "TESTDATA_PATH"
    And I assign "008_ESI_Orders_Non_Blacklisted_Portfolios_EOD_PROD" to variable "PUBLISHING_FILE_NAME"
    And I assign "008_ESI_Orders_Blacklisted_Portfolios_EOD_UAT" to variable "PUBLISHING_FILE_NAME_U"
    And I assign "007_008_ESI_Orders_Non_Blacklisted_Portfolios_Master_Template.csv" to variable "EOD_INP_TEMPLATE"
    And I assign "008_ESI_Orders_Blacklisted_Portfolios_Master_Template.csv" to variable "EOD_EXP_TEMPLATE"
    And I assign "008_ESI_Orders_Non_Blacklisted_Portfolios_Master.csv" to variable "EOD_INP"
    And I assign "008_ESI_Orders_Blacklisted_Portfolios_Master.csv" to variable "EOD_EXP"

  #Extract Data
    Given I remove below files in the host "dmp.ssh.inbound" from folder "${PUBLISHING_DIRECTORY}" if exists:
      | ${PUBLISHING_FILE_NAME}_${VAR_SYSDATE}_1.csv |

    When I process publishing wrapper with below parameters and wait for the job to be completed
      | PUBLISHING_FILE_NAME | ${PUBLISHING_FILE_NAME}.csv           |
      | SUBSCRIPTION_NAME    | EIS_DMP_TO_EIS_STARCOM_EOD_ORDERS_SUB |

    Then I expect below files to be present in the host "dmp.ssh.inbound" into folder "${PUBLISHING_DIRECTORY}" after processing:
      | ${PUBLISHING_FILE_NAME}_${VAR_SYSDATE}_1.csv |

    Then I copy files below from remote folder "${PUBLISHING_DIRECTORY}" on host "dmp.ssh.inbound" into local folder "${TESTDATA_PATH}/outfiles/runtime":
      | ${PUBLISHING_FILE_NAME}_${VAR_SYSDATE}_1.csv |

    And I remove below files in the host "dmp.ssh.inbound" from folder "${PUBLISHING_DIRECTORY}" if exists:
      | ${PUBLISHING_FILE_NAME}_${VAR_SYSDATE}_1.csv |

  #Reconcile Data
    And I create input file "${EOD_INP}" using template "${EOD_INP_TEMPLATE}" with below codes from location "${TESTDATA_PATH}/outfiles"
      | CURR_DATE | DateTimeFormat:YYYY-MM-dd |

    And I create input file "${EOD_EXP}" using template "${EOD_EXP_TEMPLATE}" with below codes from location "${TESTDATA_PATH}/outfiles"
      | CURR_DATE | DateTimeFormat:YYYY-MM-dd |

    Then I expect all records from file1 of type CSV exists in file2
      | File1 | ${TESTDATA_PATH}/outfiles/testdata/${EOD_INP}                                  |
      | File2 | ${TESTDATA_PATH}/outfiles/runtime/${PUBLISHING_FILE_NAME}_${VAR_SYSDATE}_1.csv |

    Then I expect none of the records from file1 of type CSV exists in file2
      | File1 | ${TESTDATA_PATH}/outfiles/testdata/${EOD_EXP}                                  |
      | File2 | ${TESTDATA_PATH}/outfiles/runtime/${PUBLISHING_FILE_NAME}_${VAR_SYSDATE}_1.csv |


  Scenario: Orders related to excluded portfolios should be sent to STARCOM UAT in EOD Processing. Configure portfolio ALINDF to the STARPRDEXCLPORT group
  Expected Output: Orders related to excluded portfolio ALINDF should be sent to STARCOM UAT

  #Extract Data
    Given I remove below files in the host "dmp.ssh.inbound" from folder "${PUBLISHING_DIRECTORY}" if exists:
      | ${PUBLISHING_FILE_NAME_U}_${VAR_SYSDATE}_1.csv |

    When I process publishing wrapper with below parameters and wait for the job to be completed
      | PUBLISHING_FILE_NAME | ${PUBLISHING_FILE_NAME_U}.csv           |
      | SUBSCRIPTION_NAME    | EIS_DMP_TO_EIS_STARCOM_EOD_ORDERS_U_SUB |

    Then I expect below files to be present in the host "dmp.ssh.inbound" into folder "${PUBLISHING_DIRECTORY}" after processing:
      | ${PUBLISHING_FILE_NAME_U}_${VAR_SYSDATE}_1.csv |

    Then I copy files below from remote folder "${PUBLISHING_DIRECTORY}" on host "dmp.ssh.inbound" into local folder "${TESTDATA_PATH}/outfiles/runtime":
      | ${PUBLISHING_FILE_NAME_U}_${VAR_SYSDATE}_1.csv |

    And I remove below files in the host "dmp.ssh.inbound" from folder "${PUBLISHING_DIRECTORY}" if exists:
      | ${PUBLISHING_FILE_NAME_U}_${VAR_SYSDATE}_1.csv |


    Then I expect all records from file1 of type CSV exists in file2
      | File1 | ${TESTDATA_PATH}/outfiles/testdata/${EOD_INP}                                    |
      | File2 | ${TESTDATA_PATH}/outfiles/runtime/${PUBLISHING_FILE_NAME_U}_${VAR_SYSDATE}_1.csv |

    Then I expect all records from file1 of type CSV exists in file2
      | File1 | ${TESTDATA_PATH}/outfiles/testdata/${EOD_EXP}                                    |
      | File2 | ${TESTDATA_PATH}/outfiles/runtime/${PUBLISHING_FILE_NAME_U}_${VAR_SYSDATE}_1.csv |


  Scenario: Delete Configuration

    Given I execute below query to "clear down data"
	"""
    DELETE FROM FT_T_ACGP ACGP WHERE ACGP.PRNT_ACCT_GRP_OID =
    (
      SELECT ACCT_GRP_OID FROM FT_T_ACGR WHERE ACCT_GRP_ID = 'STARPRDEXCLPORT'
      AND ORG_ID IS NULL
      AND SUBDIV_ID IS NULL
      AND SUBD_ORG_ID IS NULL
    )
    AND ACGP.ACCT_ID IN (SELECT ACCT_ID FROM FT_T_ACID WHERE ACCT_ALT_ID = 'ALINDF' AND ACCT_ID_CTXT_TYP = 'CRTSID' AND END_TMS IS NULL);
    COMMIT
    """

    Then I expect value of column "RECORD_COUNT" in the below SQL query equals to "0":
    """
    SELECT COUNT(*) AS RECORD_COUNT FROM FT_T_ACGP ACGP WHERE ACGP.PRNT_ACCT_GRP_OID =
    (
      SELECT ACCT_GRP_OID FROM FT_T_ACGR WHERE ACCT_GRP_ID = 'STARPRDEXCLPORT'
      AND ORG_ID IS NULL
      AND SUBDIV_ID IS NULL
      AND SUBD_ORG_ID IS NULL
    )
    AND ACGP.ACCT_ID IN (SELECT ACCT_ID FROM FT_T_ACID WHERE ACCT_ALT_ID = 'ALINDF' AND ACCT_ID_CTXT_TYP = 'CRTSID' AND END_TMS IS NULL)
    """