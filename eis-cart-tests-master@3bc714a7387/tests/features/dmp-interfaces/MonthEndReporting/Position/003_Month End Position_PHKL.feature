# =================================================================================================
# EISDEV-7062: Feature file added for existing report
# =================================================================================================

@dw_interface_positions @dw_interface_reports
@dmp_dw_regression
@eisdev_7062 @eisdev_7251

Feature: Verify month end Position file for PHKL positions

  This feature is designed to check whether the new Month End Position file for PHKL contains only positions loaded through the month end positions file

  Scenario: Assign Variables and Set up Configuration
    And I assign "tests/test-data/dmp-interfaces/MonthEndReporting/Position" to variable "TESTDATA_PATH"
    And I assign "003_ESIPME_POS.out" to variable "INPUT_FILENAME"
    And I assign "/dmp/out/eis/phkl" to variable "PUBLISHING_DIR"
    And I assign "HK_LIFE_POSITION_20200930" to variable "PUBLISHING_FILENAME"
    And I assign "HK_LIFE_POSITION_Reference.xlsx" to variable "REFERENCE_FILE_NAME"

    Given I set the DMP workflow web service endpoint to named configuration "dwh.ws.WORKFLOW"
    And I set the database connection to configuration "dmp.db.DW"

    And I execute below query to "clear the positions on 20200930"
    """
    DELETE ft_t_wpos WHERE rptg_prd_end_dte = TO_DATE('30-SEP-2020','dd-mon-yyyy');
    commit
    """

  Scenario: Loading Positions Data

    Given I set the DMP workflow web service endpoint to named configuration "dwh.ws.WORKFLOW"
    And I set the database connection to configuration "dmp.db.DW"

    And I copy files below from local folder "${TESTDATA_PATH}/testdata" to the host "dmp.ssh.inbound" folder "${dmp.ssh.inbound.path}":
      | ${INPUT_FILENAME} |

    When I process files with below parameters and wait for the job to be completed
      | BUSINESS_FEED |                     |
      | FILE_PATTERN  | ${INPUT_FILENAME}   |
      | MESSAGE_TYPE  | EIS_MT_BNP_MOPK_POS |

    When I assign "600" to variable "workflow.max.polling.time"


  Scenario: Publish PHKL Report

    Given I set the DMP workflow web service endpoint to named configuration "dwh.ws.WORKFLOW"
    And I set the database connection to configuration "dmp.db.DW"

    And I remove below files in the host "dmp.ssh.inbound" from folder "${PUBLISHING_DIR}" if exists:
      | ${PUBLISHING_FILENAME} |

    When I process DWH publishing wrapper with below parameters and wait for the job to be completed
      | BULK_SIZE           | 100000                                                                             |
      | CONVERT_TO_EXCEL    | true                                                                               |
      | FILE_DIRECTORY      | ${PUBLISHING_DIR}                                                                  |
      | PUBLISHING_FILENAME | ${PUBLISHING_FILENAME}.csv                                                         |
      | THREAD_COUNT        | 1                                                                                  |
      | SQL_ID              | SELECT DISTINCT posn_sok id FROM ft_v_rpt1_phkl_positions WHERE me_date = 20200930 |
      | SQL_PUBLISH         | SELECT posn_sok id, flow_data FROM ft_v_rpt1_phkl_positions                        |

    Then I expect below files to be present in the host "dmp.ssh.inbound" into folder "${PUBLISHING_DIR}" after processing:
      | ${PUBLISHING_FILENAME}.xlsx |

    Then I copy files below from remote folder "${PUBLISHING_DIR}" on host "dmp.ssh.inbound" into local folder "${TESTDATA_PATH}/outfiles/runtime":
      | ${PUBLISHING_FILENAME}.xlsx |

    Then I expect reconciliation should be successful between given EXCEL files
      | ExpectedFile | ${TESTDATA_PATH}/outfiles/expected/${REFERENCE_FILE_NAME}     |
      | ActualFile   | ${TESTDATA_PATH}/outfiles/runtime/${PUBLISHING_FILENAME}.xlsx |
      | SheetIndex   | 0                                                             |

  Scenario: Cleanup max polling time variable
    Then I remove variable "workflow.max.polling.time" from memory