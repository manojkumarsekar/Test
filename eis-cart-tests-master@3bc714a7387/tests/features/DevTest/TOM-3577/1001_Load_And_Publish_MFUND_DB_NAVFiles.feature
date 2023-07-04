#https://collaborate.intranet.asia/pages/viewpage.action?pageId=45848763
#https://jira.intranet.asia/browse/TOM-3345 - Initial ticket to load the MFUND and DB NAV files and one publishing profile
#                                             Remarks : This jira is not required because this testcase covered as part of TOM-3577 so that i deleted
#https://jira.intranet.asia/browse/TOM-3577 - Modified to two publishing profile(i.e 1 for Mfund, other for DB)
#                                             Remarks :
#https://jira.intranet.asia/browse/TOM-3613 - Interchage the date and as_of_date column, No Feature file for TOM-3613
#                                             Remarks : This ticket for enhancement from TOM-3577 so that i am using that feature testcase
#https://jira.intranet.asia/browse/TOM-3622 - ABOR NAV TO Aladdin -  NAV's To Be Aggregated (MALAYSIA LBU)
#                                             Remarks : This is an enhancement for MFUND

@gc_interface_nav
@dmp_regression_integrationtest
@tom_3622 @tom_3577 @tom_3345 @tom_3613 @nav_abor
Feature: Loading NAV files from MFUND and DB and publish to BRS separately

  For this testcase we are trying to load NAV in FT_T_ACCV table and publish the same NAV.ABOR NAV to be stored in Aladdin from mFund and DB sources

  Scenario: TC_1: Load files

    Given I assign "DB_20180730.csv" to variable "INPUT_FILENAME_1"
    And I assign "tests/test-data/DevTest/TOM-3577" to variable "testdata.path"

    Given I assign "MFUND.csv" to variable "INPUT_FILENAME_2"

    # Clear data for the given NAV for FT_T_ACCV Table
    And I execute below query
    """
    ${testdata.path}/sql/ClearData_NAV_DB_MFUND.sql
    """

    When I copy files below from local folder "${testdata.path}/testdata" to the host "dmp.ssh.inbound" folder "${dmp.ssh.inbound.path}":
      | ${INPUT_FILENAME_1} |
      | ${INPUT_FILENAME_2} |

    Given I process files with below parameters and wait for the job to be completed
      | BUSINESS_FEED |                     |
      | FILE_PATTERN  | ${INPUT_FILENAME_1} |
      | MESSAGE_TYPE  | EIM_MT_DB_NAV_ABOR  |

    Given I process files with below parameters and wait for the job to be completed
      | BUSINESS_FEED |                       |
      | FILE_PATTERN  | ${INPUT_FILENAME_2}   |
      | MESSAGE_TYPE  | EIM_MT_MFUND_NAV_ABOR |

    # Checking NAV to be aggregate when duplicate portfolio's are present in the file
    Then I expect value of column "ID_COUNT_NAV" in the below SQL query equals to "1":
      """
     SELECT COUNT(*) AS ID_COUNT_NAV
     FROM FT_T_ACCV
     WHERE ACCT_ID IN
     (SELECT ACCT_ID FROM FT_T_ACID WHERE ACCT_ALT_ID='MLSHLEQ' AND END_TMS IS NULL)
     AND VALU_VAL_CAMT='10'
     AND DATA_SRC_ID  ='MFUND'
      """

    Given I assign "esi_mfund_nav_abor" to variable "PUBLISHING_FILE_NAME_1"
    And I generate value with date format "YYYYMMdd" and assign to variable "VAR_SYSDATE"
    And I assign "/dmp/out/brs/eod" to variable "PUBLISHING_DIR"
    And I remove below files in the host "dmp.ssh.inbound" from folder "${PUBLISHING_DIR}" if exists:
      | ${PUBLISHING_FILE_NAME_1}_${VAR_SYSDATE}_1.csv |

    Given I assign "esi_db_nav_abor" to variable "PUBLISHING_FILE_NAME_2"
    And I remove below files in the host "dmp.ssh.inbound" from folder "${PUBLISHING_DIR}" if exists:
      | ${PUBLISHING_FILE_NAME_2}_${VAR_SYSDATE}_1.csv |

  Scenario: TC_2: Publish MFUND NAV file

    Given I process publishing wrapper with below parameters and wait for the job to be completed
      | PUBLISHING_FILE_NAME | ${PUBLISHING_FILE_NAME_1}.csv                                                                                 |
      | SUBSCRIPTION_NAME    | EIM_DMP_TO_BRS_MFUND_NAV_ABOR_SUB                                                                             |
      | SQL                  | &lt;sql&gt; acct_id in (select acct_id from fT_T_acid where acct_alt_id in ('MLTDED','MLSHLEQ')) &lt;/sql&gt; |

    Then I expect below files to be present in the host "dmp.ssh.inbound" into folder "${PUBLISHING_DIR}" after processing:
      | ${PUBLISHING_FILE_NAME_1}_${VAR_SYSDATE}_1.csv |

    Then I copy files below from remote folder "${PUBLISHING_DIR}" on host "dmp.ssh.inbound" into local folder "${testdata.path}/outfiles":
      | ${PUBLISHING_FILE_NAME_1}_${VAR_SYSDATE}_1.csv |

  Scenario: Check the price for PORTFOLIO in MFUND NAV outbound file

    Given I assign "${testdata.path}/outfiles/${PUBLISHING_FILE_NAME_1}_${VAR_SYSDATE}_1.csv" to variable "CSV_FILE"

    #Check if PORTFOLIO MLTDED has value 53893483.99 in the outbound
    Given I expect column "VALUE" value to be "53893483.99" where columns values are as below in CSV file "${CSV_FILE}"
      | PORTFOLIO      | MLTDED         |
      | DATA_SOURCE    | MFUND          |
      | DATA_ASOF_DATE | ${VAR_SYSDATE} |
      | CURRENCY       | MYR            |

    #Check if PORTFOLIO MLSHLEQ has value 10 in the outbound

    Then I expect column "VALUE" value to be "10" where columns values are as below in CSV file "${CSV_FILE}"
      | PORTFOLIO      | MLSHLEQ        |
      | DATA_SOURCE    | MFUND          |
      | DATA_ASOF_DATE | ${VAR_SYSDATE} |
      | CURRENCY       | MYR            |

  Scenario: TC_3: Publish DB NAV file

    Given I process publishing wrapper with below parameters and wait for the job to be completed
      | PUBLISHING_FILE_NAME | ${PUBLISHING_FILE_NAME_2}.csv                                                                         |
      | SUBSCRIPTION_NAME    | EIM_DMP_TO_BRS_DB_NAV_ABOR_SUB                                                                        |
      | SQL                  | &lt;sql&gt; acct_id in (select acct_id from fT_T_acid where acct_alt_id in ('MFPM0002')) &lt;/sql&gt; |

    Then I expect below files to be present in the host "dmp.ssh.inbound" into folder "${PUBLISHING_DIR}" after processing:
      | ${PUBLISHING_FILE_NAME_2}_${VAR_SYSDATE}_1.csv |

    Then I copy files below from remote folder "${PUBLISHING_DIR}" on host "dmp.ssh.inbound" into local folder "${testdata.path}/outfiles":
      | ${PUBLISHING_FILE_NAME_2}_${VAR_SYSDATE}_1.csv |

  Scenario: TC_4: Check the price for PORTFOLIO in DB NAV outbound file

    Given I assign "${testdata.path}/outfiles/${PUBLISHING_FILE_NAME_2}_${VAR_SYSDATE}_1.csv" to variable "CSV_FILE"

    #Check if PORTFOLIO MFPM0002 has value 8625468.89 in the outbound

    Given I expect column "VALUE" value to be "8625468.89" where columns values are as below in CSV file "${CSV_FILE}"
      | PORTFOLIO      | MFPM0002       |
      | DATA_SOURCE    | DB             |
      | DATA_ASOF_DATE | ${VAR_SYSDATE} |
      | CURRENCY       | MYR            |
