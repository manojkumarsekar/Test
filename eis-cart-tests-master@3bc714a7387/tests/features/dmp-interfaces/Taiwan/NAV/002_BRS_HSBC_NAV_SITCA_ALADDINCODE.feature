#https://jira.intranet.asia/browse/TOM-5270

@gc_interface_portfolios @gc_interface_nav @gc_interface_prices
@dmp_taiwan
@dmp_regression_integrationtest
@tom_5270 @hsbc_ssb_nav
Feature: Verify publishing of NAV file to BRS from DMP for all Bath FA Portfolio groups and verify translation of aladdin portfolio code

  Scenario1 - Test Published file for shareclass portfolio in Batch1 and having alladin portfolio code translated correctly
  Scenario2 - Test Published file for shareclass portfolio in Batch2 and having alladin portfolio code translated correctly
  Scenario3 - Test Published file for shareclass portfolio in Batch3 and having alladin portfolio code translated correctly
  Scenario4 - Test Published file for shareclass portfolio which doesnt have alladin portfolio code setup
  Scenario5 - Test Published file for shareclass portfolio which is not part of any portfolio group

  Scenario: TC_1: Publish HSBC NAV files

    Given I assign "ESI_BRS_NAV_PRICE.csv" to variable "INPUT_FILENAME"
    And I assign "BRSNAV_SCN1" to variable "PUBLISHING_FILE_NAME1"
    And I assign "BRSNAV_SCN2" to variable "PUBLISHING_FILE_NAME2"
    And I assign "BRSNAV_SCN3" to variable "PUBLISHING_FILE_NAME3"
    And I assign "BRSNAV_SCN_4" to variable "PUBLISHING_FILE_NAME_Empty_4"
    And I assign "BRSNAV_SCN_5" to variable "PUBLISHING_FILE_NAME_Empty_5"
    And I generate value with date format "YYYYMMdd" and assign to variable "VAR_SYSDATE"
    And I assign "/dmp/out/brs/eod" to variable "PUBLISHING_DIR"
    And I assign "tests/test-data/dmp-interfaces/Taiwan/NAV" to variable "testdata.path"

  Scenario: Setup new account in DMP

    Given I assign "Portfolio_template_TOM5207.xlsx" to variable "PORTFOLIO_FILENAME"
    And I copy files below from local folder "${testdata.path}/testdata" to the host "dmp.ssh.inbound" folder "${dmp.ssh.inbound.path}":
      | ${PORTFOLIO_FILENAME} |

    Then I process files with below parameters and wait for the job to be completed
      | BUSINESS_FEED |                                      |
      | FILE_PATTERN  | ${PORTFOLIO_FILENAME}                |
      | MESSAGE_TYPE  | EIS_MT_RDM_PORTFOLIO_MASTER_TEMPLATE |

    And I execute below query to "Setup portfolio and Clear ACCV"
    """
     ${testdata.path}/sql/SetupData_NAV_HSBC_BRS.sql
    """

  Scenario: TC_2: Load HSBC NAV file

    When I copy files below from local folder "${testdata.path}/testdata" to the host "dmp.ssh.inbound" folder "${dmp.ssh.inbound.path}":
      | ${INPUT_FILENAME} |

    Then I process files with below parameters and wait for the job to be completed
      | BUSINESS_FEED |                        |
      | FILE_PATTERN  | ${INPUT_FILENAME}      |
      | MESSAGE_TYPE  | EITW_MT_HSBC_NAV_PRICE |

      # Checking ACCV
    Then I expect value of column "ID_COUNT_ACCV" in the below SQL query equals to "3":
    """
    SELECT COUNT(*) AS ID_COUNT_ACCV FROM FT_T_ACCV
    WHERE ACCT_ID IN (SELECT ACCT_ID FROM FT_T_ACID WHERE ACCT_ALT_ID in ('SCN1SHRCLSS','SCN2SHRCLSS','SCN3SHRCLSS') AND END_TMS IS NULL)
    """

  #Scenario1 Test Published file for shareclass portfolio in Batch1 and having alladin portfolio code translated correctly
  Scenario: TC_3: Publish BRS NAV file for Batch1 shareclass portfolio

    And I remove below files in the host "dmp.ssh.inbound" from folder "${PUBLISHING_DIR}" if exists:
      | ${PUBLISHING_FILE_NAME1}_${VAR_SYSDATE}_*.csv |

    When I process publishing wrapper with below parameters and wait for the job to be completed
      | PUBLISHING_FILE_NAME | ${PUBLISHING_FILE_NAME1}.csv        |
      | SUBSCRIPTION_NAME    | EITW_DMP_TO_BRS_HSBC_EOD_NAV_B1_SUB |

    Then I expect below files to be present in the host "dmp.ssh.inbound" into folder "${PUBLISHING_DIR}" after processing:
      | ${PUBLISHING_FILE_NAME1}_${VAR_SYSDATE}_*.csv |

    Then I copy files below from remote folder "${PUBLISHING_DIR}" on host "dmp.ssh.inbound" into local folder "tests/test-data/dmp-interfaces/Taiwan/NAV/outfiles/runtime":
      | ${PUBLISHING_FILE_NAME1}_${VAR_SYSDATE}_*.csv |

  Scenario: TC_4: Check the published BRS NAV file for Batch1 portfolio

    And I assign "BRSNAVSCN1Expected.csv" to variable "EXPECTED_FILE"

    Then I expect reconciliation between generated CSV file "${testdata.path}/outfiles/runtime/${PUBLISHING_FILE_NAME1}_${VAR_SYSDATE}_1.csv" and reference CSV file "${testdata.path}/outfiles/template/${EXPECTED_FILE}" should be successful and exceptions to be written to "${testdata.path}/outfiles/runtime/${PUBLISHING_FILE_NAME1}_${VAR_SYSDATE}_SCN1_exceptions.csv" file

  #Scenario2 Test Published file for shareclass portfolio in Batch2 and having alladin portfolio code translated correctly
  Scenario: TC_5: Publish BRS NAV file for Batch2 shareclass portfolio

    And I remove below files in the host "dmp.ssh.inbound" from folder "${PUBLISHING_DIR}" if exists:
      | ${PUBLISHING_FILE_NAME2}_${VAR_SYSDATE}_*.csv |

    When I process publishing wrapper with below parameters and wait for the job to be completed
      | PUBLISHING_FILE_NAME | ${PUBLISHING_FILE_NAME2}.csv        |
      | SUBSCRIPTION_NAME    | EITW_DMP_TO_BRS_HSBC_EOD_NAV_B2_SUB |

    Then I expect below files to be present in the host "dmp.ssh.inbound" into folder "${PUBLISHING_DIR}" after processing:
      | ${PUBLISHING_FILE_NAME2}_${VAR_SYSDATE}_*.csv |

    Then I copy files below from remote folder "${PUBLISHING_DIR}" on host "dmp.ssh.inbound" into local folder "tests/test-data/dmp-interfaces/Taiwan/NAV/outfiles/runtime":
      | ${PUBLISHING_FILE_NAME2}_${VAR_SYSDATE}_*.csv |

  Scenario: TC_6: Check the published BRS NAV file for Batch2 portfolio

    And I assign "BRSNAVSCN2Expected.csv" to variable "EXPECTED_FILE"

    Then I expect reconciliation between generated CSV file "${testdata.path}/outfiles/runtime/${PUBLISHING_FILE_NAME2}_${VAR_SYSDATE}_1.csv" and reference CSV file "${testdata.path}/outfiles/template/${EXPECTED_FILE}" should be successful and exceptions to be written to "${testdata.path}/outfiles/runtime/${PUBLISHING_FILE_NAME2}_${VAR_SYSDATE}_SCN2_exceptions.csv" file

  #Scenario3 Test Published file for shareclass portfolio in Batch3 and having alladin portfolio code translated correctly
  Scenario: TC_7: Publish BRS NAV file for Batch3 shareclass portfolio

    And I remove below files in the host "dmp.ssh.inbound" from folder "${PUBLISHING_DIR}" if exists:
      | ${PUBLISHING_FILE_NAME3}_${VAR_SYSDATE}_*.csv |

    When I process publishing wrapper with below parameters and wait for the job to be completed
      | PUBLISHING_FILE_NAME | ${PUBLISHING_FILE_NAME3}.csv        |
      | SUBSCRIPTION_NAME    | EITW_DMP_TO_BRS_HSBC_EOD_NAV_B3_SUB |

    Then I expect below files to be present in the host "dmp.ssh.inbound" into folder "${PUBLISHING_DIR}" after processing:
      | ${PUBLISHING_FILE_NAME3}_${VAR_SYSDATE}_*.csv |

    Then I copy files below from remote folder "${PUBLISHING_DIR}" on host "dmp.ssh.inbound" into local folder "tests/test-data/dmp-interfaces/Taiwan/NAV/outfiles/runtime":
      | ${PUBLISHING_FILE_NAME3}_${VAR_SYSDATE}_*.csv |

  Scenario: TC_8: Check the published BRS NAV file for Batch1 portfolio

    And I assign "BRSNAVSCN3Expected.csv" to variable "EXPECTED_FILE"

    Then I expect reconciliation between generated CSV file "${testdata.path}/outfiles/runtime/${PUBLISHING_FILE_NAME3}_${VAR_SYSDATE}_1.csv" and reference CSV file "${testdata.path}/outfiles/template/${EXPECTED_FILE}" should be successful and exceptions to be written to "${testdata.path}/outfiles/runtime/${PUBLISHING_FILE_NAME3}_${VAR_SYSDATE}_SCN3_exceptions.csv" file

    #Scenario4 Test Published file for shareclass portfolio which doesnt have alladin portfolio code setup
  Scenario: TC_7: Publish BRS NAV file for Batch1 shareclass portfolio whose parent portfolio does not have aladdin translated code

    And I execute below query
    """
    DELETE FROM FT_T_ACID WHERE ACCT_ALT_ID = 'SCN1PARENT_USD' AND acct_id_ctxt_typ='CRTSID' AND acct_id in (SELECT ACCT_ID FROM FT_T_ACID WHERE ACCT_ALT_ID = 'SCN1SHRCLSS' AND END_TMS IS NULL)
    """

    And I remove below files in the host "dmp.ssh.inbound" from folder "${PUBLISHING_DIR}" if exists:
      | ${PUBLISHING_FILE_NAME_Empty_4}_${VAR_SYSDATE}_*.csv |

    When I process publishing wrapper with below parameters and wait for the job to be completed
      | PUBLISHING_FILE_NAME | ${PUBLISHING_FILE_NAME_Empty_4}.csv |
      | SUBSCRIPTION_NAME    | EITW_DMP_TO_BRS_HSBC_EOD_NAV_B1_SUB |

    Then I expect below files to be present in the host "dmp.ssh.inbound" into folder "${PUBLISHING_DIR}" after processing:
      | ${PUBLISHING_FILE_NAME_Empty_4}_${VAR_SYSDATE}_*.csv |

    Then I copy files below from remote folder "${PUBLISHING_DIR}" on host "dmp.ssh.inbound" into local folder "tests/test-data/dmp-interfaces/Taiwan/NAV/outfiles/runtime":
      | ${PUBLISHING_FILE_NAME_Empty_4}_${VAR_SYSDATE}_*.csv |

  Scenario: TC_8: Check the published BRS NAV file for Batch1 portfolio

    And I assign "BRSNAVSCNEmptyExpected.csv" to variable "EXPECTED_FILE"

    Then I expect reconciliation between generated CSV file "${testdata.path}/outfiles/runtime/${PUBLISHING_FILE_NAME_Empty_4}_${VAR_SYSDATE}_1.csv" and reference CSV file "${testdata.path}/outfiles/template/${EXPECTED_FILE}" should be successful and exceptions to be written to "${testdata.path}/outfiles/runtime/${PUBLISHING_FILE_NAME_Empty_4}_${VAR_SYSDATE}_SCN4_exceptions.csv" file

   # Scenario5 : Shareclass Portfolio is not part of any account group - no rows in filter query hence no file will be genrated
  Scenario: TC_7: Publish BRS NAV file for FA Batch3 shareclass portfolio whose parent portfolio does not have aladdin translated code

    And I execute below query
    """
    DELETE FROM FT_T_ACGP WHERE prnt_acct_grp_oid = (SELECT ACCT_GRP_OID FROM FT_T_ACGR WHERE ACCT_GRP_ID = 'TWFACAP3') AND acct_id IN (SELECT ACCT_ID FROM FT_T_ACID WHERE ACCT_ALT_ID = 'SCN3PARENT' AND END_TMS IS NULL) AND acct_org_id = 'EIS' AND acct_bk_id='EIS'
    """

    And I remove below files in the host "dmp.ssh.inbound" from folder "${PUBLISHING_DIR}" if exists:
      | ${PUBLISHING_FILE_NAME_Empty_5}_${VAR_SYSDATE}_*.csv |

    When I process publishing wrapper with below parameters and wait for the job to be completed
      | PUBLISHING_FILE_NAME | ${PUBLISHING_FILE_NAME_Empty_5}.csv |
      | SUBSCRIPTION_NAME    | EITW_DMP_TO_BRS_HSBC_EOD_NAV_B3_SUB |

    Then I expect below files to be present in the host "dmp.ssh.inbound" into folder "${PUBLISHING_DIR}" after processing:
      | ${PUBLISHING_FILE_NAME_Empty_5}_${VAR_SYSDATE}_*.csv |

    Then I copy files below from remote folder "${PUBLISHING_DIR}" on host "dmp.ssh.inbound" into local folder "tests/test-data/dmp-interfaces/Taiwan/NAV/outfiles/runtime":
      | ${PUBLISHING_FILE_NAME_Empty_5}_${VAR_SYSDATE}_*.csv |

  Scenario: TC_8: Check the published BRS NAV file for shareclass portfolio that doesnt belong to any FA account group

    And I assign "BRSNAVSCNEmptyExpected.csv" to variable "EXPECTED_FILE"

    Then I expect reconciliation between generated CSV file "${testdata.path}/outfiles/runtime/${PUBLISHING_FILE_NAME_Empty_5}_${VAR_SYSDATE}_1.csv" and reference CSV file "${testdata.path}/outfiles/template/${EXPECTED_FILE}" should be successful and exceptions to be written to "${testdata.path}/outfiles/runtime/${PUBLISHING_FILE_NAME_Empty_5}_${VAR_SYSDATE}_SCN4_exceptions.csv" file
