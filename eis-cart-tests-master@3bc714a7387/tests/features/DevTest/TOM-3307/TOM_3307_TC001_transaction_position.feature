#TOM-4314 : Avoid deleting all data from DWH which impacts other feature files: move test data from 2018 to 2012 and delete data from 2012 only as part of setup.

# Temporarily removed from dmp_regression. Performance issues with the transaction extract means we're likely to experience regular timeouts otherwise.
# TOM-4326 has been raised to remediate and dmp_regression can be re-instated subsequently.
#@tom_3307 @month_end_reporting @data_dumps @dmp_regression_unittest @dwh_interfaces @tom_4314

#No regression tag observed. Hence, modular tag (Ex: gc_interface or dw_interface) has not given.
@tom_3307 @tom_4314
Feature: Month-end data dumps with missing client details

  Test that transactions and positions are reported even if a portfolio is not assigned to a client

  Background:

    Given I set the DMP workflow web service endpoint to named configuration "dwh.ws.WORKFLOW"
    And I set the database connection to configuration "dmp.db.DW"

  Scenario: Cleardown any existing data

    # Some static data MDXs use a regex to extract date, thus additional numeric character (e.g. TC01) are avoided

    And I assign "tests/test-data/DevTest/TOM-3307" to variable "testdata.path"
    And I assign "ESISODP_EXR_1_20120731.out" to variable "EXR_INPUT_FILENAMED_DLY"
    And I assign "ESIPME_EXR_20120731_492608.out" to variable "EXR_INPUT_FILENAMED_MTH"
    And I assign "ESIPME_PFL_20120731_492582.out" to variable "PFL_INPUT_FILENAME"
    And I assign "ESIPME_SEC_20120731_492609.out" to variable "SEC_INPUT_FILENAME"
    And I assign "ESIPME_TRN_20120630.out" to variable "TRN_INPUT_FILENAME"
    And I assign "ESIPME_POS_20120731.out" to variable "POS_INPUT_FILENAME"
    And I assign "TOM-3307_trn_output" to variable "TRN_PUBLISHING_FILENAME"
    And I assign "TOM-3307_pos_output" to variable "POS_PUBLISHING_FILENAME"
    And I assign "/dmp/out/eis/general" to variable "PUBLISHING_DIR"

    And I execute below query to "Clear data from warehouse tables"
    """
    ${testdata.path}/sql/ClearDown.sql
    """

  Scenario: Load daily exchange rates

    Given I copy files below from local folder "${testdata.path}/testdata" to the host "dwh.ssh.inbound" folder "${dwh.ssh.inbound.path}":
      | ${EXR_INPUT_FILENAMED_DLY} |

    When I process files with below parameters and wait for the job to be completed
      | BUSINESS_FEED |                            |
      | FILE_PATTERN  | ${EXR_INPUT_FILENAMED_DLY} |
      | MESSAGE_TYPE  | EIS_MT_BNP_MOPK_SOD_FX     |

    # Validation: records in ft_t_wfxr
    Then I expect value of column "EXR_COUNT" in the below SQL query equals to "134":
    """
    SELECT count(*) AS EXR_COUNT FROM ft_t_wfxr WHERE end_of_prd_typ = 'DA' AND fx_tms < TO_DATE('20120801','yyyymmdd')
    """

  Scenario: Load monthly exchange rates

    Given I copy files below from local folder "${testdata.path}/testdata" to the host "dwh.ssh.inbound" folder "${dwh.ssh.inbound.path}":
      | ${EXR_INPUT_FILENAMED_MTH} |

    When I process files with below parameters and wait for the job to be completed
      | BUSINESS_FEED |                            |
      | FILE_PATTERN  | ${EXR_INPUT_FILENAMED_MTH} |
      | MESSAGE_TYPE  | EIS_MT_BNP_MOPK_FXR        |

  # Validation: records in ft_t_wfxr
    Then I expect value of column "EXR_COUNT" in the below SQL query equals to "134":
        """
        SELECT count(*) AS EXR_COUNT FROM ft_t_wfxr WHERE end_of_prd_typ = 'MO' AND fx_tms < TO_DATE('20120801','yyyymmdd')
        """

  Scenario: Load portfolios

    Given I copy files below from local folder "${testdata.path}/testdata" to the host "dwh.ssh.inbound" folder "${dwh.ssh.inbound.path}":
      | ${PFL_INPUT_FILENAME} |

    When I process files with below parameters and wait for the job to be completed
      | BUSINESS_FEED |                       |
      | FILE_PATTERN  | ${PFL_INPUT_FILENAME} |
      | MESSAGE_TYPE  | EIS_MT_BNP_MOPK_PFL   |

    # Validation: records in ft_t_wact
    Then I expect value of column "PFL_COUNT" in the below SQL query equals to "28":
        """
        SELECT count(*) AS PFL_COUNT FROM ft_t_wact WHERE rptg_prd_end_dte = TO_DATE('20120731','yyyymmdd')
        """

  Scenario: Load securities

    Given I copy files below from local folder "${testdata.path}/testdata" to the host "dwh.ssh.inbound" folder "${dwh.ssh.inbound.path}":
      | ${SEC_INPUT_FILENAME} |

    When I process files with below parameters and wait for the job to be completed
      | BUSINESS_FEED |                       |
      | FILE_PATTERN  | ${SEC_INPUT_FILENAME} |
      | MESSAGE_TYPE  | EIS_MT_BNP_MOPK_SEC   |

    # Validation: records in ft_t_wisu
    Then I expect value of column "SEC_COUNT" in the below SQL query equals to "821":
        """
        SELECT count(*) AS SEC_COUNT FROM ft_t_wisu WHERE rptg_prd_end_dte = TO_DATE('20120731','yyyymmdd')
        """

  Scenario: Load Positions

    Given I copy files below from local folder "${testdata.path}/testdata" to the host "dwh.ssh.inbound" folder "${dwh.ssh.inbound.path}":
      | ${POS_INPUT_FILENAME} |

    When I process files with below parameters and wait for the job to be completed
      | BUSINESS_FEED |                       |
      | FILE_PATTERN  | ${POS_INPUT_FILENAME} |
      | MESSAGE_TYPE  | EIS_MT_BNP_MOPK_POS   |

    # Validation: records in ft_t_wtrd
    Then I expect value of column "POS_COUNT" in the below SQL query equals to "5":
        """
        SELECT count(*) AS POS_COUNT FROM ft_t_wpos WHERE rptg_prd_end_dte = TO_DATE('20120731','yyyymmdd')
        """

  Scenario: Load Transactions

    Given I copy files below from local folder "${testdata.path}/testdata" to the host "dwh.ssh.inbound" folder "${dwh.ssh.inbound.path}":
      | ${TRN_INPUT_FILENAME} |

    When I process files with below parameters and wait for the job to be completed
      | BUSINESS_FEED |                       |
      | FILE_PATTERN  | ${TRN_INPUT_FILENAME} |
      | MESSAGE_TYPE  | EIS_MT_BNP_MOPK_TRN   |

    # Validation: records in ft_t_wtrd
    Then I expect value of column "TRN_COUNT" in the below SQL query equals to "6":
        """
        SELECT count(*) AS TRN_COUNT FROM ft_t_wtrd WHERE rptg_prd_end_dte = TO_DATE('20120731','yyyymmdd')
        """

  Scenario: Set max polling time variable

    #By default Publishing job polling time is 300sec. Since these are testing jobs, we don't want to wait 300sec in case of failures
    #so setting to 600sec and removing this variable at the end
    Given I assign "600" to variable "workflow.max.polling.time"

  Scenario: Publish transactions report

    Given I remove below files in the host "dmp.ssh.inbound" from folder "${PUBLISHING_DIR}" if exists:
      | ${TRN_PUBLISHING_FILENAME} |

    When I process DWH publishing wrapper with below parameters and wait for the job to be completed
      | BULK_SIZE           | 100000                                                                                                      |
      | CONVERT_TO_EXCEL    | false                                                                                                       |
      | FILE_DIRECTORY      | ${PUBLISHING_DIR}                                                                                           |
      | PUBLISHING_FILENAME | ${TRN_PUBLISHING_FILENAME}.csv                                                                              |
      | THREAD_COUNT        | 1                                                                                                           |
      | SQL_ID              | SELECT DISTINCT wtrd_sok id FROM ft_v_rpt1_meds_transactions WHERE me_date = TO_DATE('20120731','yyyymmdd') |
      | SQL_PUBLISH         | SELECT wtrd_sok id, flow_data FROM ft_v_rpt1_meds_transactions                                              |

    Then I expect below files to be present in the host "dmp.ssh.inbound" into folder "${PUBLISHING_DIR}" after processing:
      | ${TRN_PUBLISHING_FILENAME}.csv |

    Then I copy files below from remote folder "${PUBLISHING_DIR}" on host "dmp.ssh.inbound" into local folder "${testdata.path}/outfiles/runtime":
      | ${TRN_PUBLISHING_FILENAME}.csv |

  Scenario: Check the reports record count and transactions' client details

    Then I expect file "${testdata.path}/outfiles/runtime/${TRN_PUBLISHING_FILENAME}.csv" should have 7 records
    And I expect column '"BOOK_COST_USD"' value to be "10052000" where column '"BNP_DWH_TRAN_ID"' value is "297151587" in CSV file "${testdata.path}/outfiles/runtime/${TRN_PUBLISHING_FILENAME}.csv"
    And I expect column '"BOOK_COST_USD"' value to be "8033800" where column '"BNP_DWH_TRAN_ID"' value is "296058942" in CSV file "${testdata.path}/outfiles/runtime/${TRN_PUBLISHING_FILENAME}.csv"
    And I expect column '"BOOK_COST_USD"' value to be "60829500" where column '"BNP_DWH_TRAN_ID"' value is "296506425" in CSV file "${testdata.path}/outfiles/runtime/${TRN_PUBLISHING_FILENAME}.csv"
    And I expect column '"BOOK_COST_SGD"' value to be "0" where column '"BNP_DWH_TRAN_ID"' value is "297145411" in CSV file "${testdata.path}/outfiles/runtime/${TRN_PUBLISHING_FILENAME}.csv"
    And I expect column '"BOOK_COST_SGD"' value to be "0" where column '"BNP_DWH_TRAN_ID"' value is "296280909" in CSV file "${testdata.path}/outfiles/runtime/${TRN_PUBLISHING_FILENAME}.csv"
    And I expect column '"BOOK_COST_SGD"' value to be "63971200" where column '"BNP_DWH_TRAN_ID"' value is "296039731" in CSV file "${testdata.path}/outfiles/runtime/${TRN_PUBLISHING_FILENAME}.csv"

  Scenario: Publish positions report

    Given I remove below files in the host "dmp.ssh.inbound" from folder "${PUBLISHING_DIR}" if exists:
      | ${POS_PUBLISHING_FILENAME} |

    When I process DWH publishing wrapper with below parameters and wait for the job to be completed
      | BULK_SIZE           | 100000                                                                                                   |
      | CONVERT_TO_EXCEL    | false                                                                                                    |
      | FILE_DIRECTORY      | ${PUBLISHING_DIR}                                                                                        |
      | PUBLISHING_FILENAME | ${POS_PUBLISHING_FILENAME}.csv                                                                           |
      | THREAD_COUNT        | 1                                                                                                        |
      | SQL_ID              | SELECT DISTINCT posn_sok id FROM ft_v_rpt1_meds_positions WHERE me_date = TO_DATE('20120731','yyyymmdd') |
      | SQL_PUBLISH         | SELECT posn_sok id, flow_data FROM ft_v_rpt1_meds_positions                                              |

    Then I expect below files to be present in the host "dmp.ssh.inbound" into folder "${PUBLISHING_DIR}" after processing:
      | ${POS_PUBLISHING_FILENAME}.csv |

    Then I copy files below from remote folder "${PUBLISHING_DIR}" on host "dmp.ssh.inbound" into local folder "${testdata.path}/outfiles/runtime":
      | ${POS_PUBLISHING_FILENAME}.csv |

  Scenario: Check the reports record count and positions' client details

    Then I expect file "${testdata.path}/outfiles/runtime/${POS_PUBLISHING_FILENAME}.csv" should have 6 records
    And I expect column '"BOOK_COST_USD"' value to be "-17710000" where column '"INSTR_ID"' value is "MD_140815" in CSV file "${testdata.path}/outfiles/runtime/${POS_PUBLISHING_FILENAME}.csv"
    And I expect column '"BOOK_COST_USD"' value to be "50" where column '"INSTR_ID"' value is "MD_497379" in CSV file "${testdata.path}/outfiles/runtime/${POS_PUBLISHING_FILENAME}.csv"
    And I expect column '"BOOK_COST_USD"' value to be "50" where column '"INSTR_ID"' value is "MD_142206" in CSV file "${testdata.path}/outfiles/runtime/${POS_PUBLISHING_FILENAME}.csv"
    And I expect column '"BOOK_COST_SGD"' value to be "40" where column '"INSTR_ID"' value is "MD_142206" in CSV file "${testdata.path}/outfiles/runtime/${POS_PUBLISHING_FILENAME}.csv"
    And I expect column '"BOOK_COST_SGD"' value to be "23375" where column '"INSTR_ID"' value is "MD_142224" in CSV file "${testdata.path}/outfiles/runtime/${POS_PUBLISHING_FILENAME}.csv"
    And I expect column '"BOOK_COST_SGD"' value to be "12" where column '"INSTR_ID"' value is "MD_497380" in CSV file "${testdata.path}/outfiles/runtime/${POS_PUBLISHING_FILENAME}.csv"

  Scenario: Cleanup max polling time variable

    Then I remove variable "workflow.max.polling.time" from memory