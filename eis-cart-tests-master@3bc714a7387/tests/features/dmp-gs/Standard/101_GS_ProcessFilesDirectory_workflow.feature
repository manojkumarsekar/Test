#Feature History
#TOM-3768: Moved the feature file from as per new folder structure. Added test case for .XLSX and .OUT File types in addition to .CSV File

@dmp_smoke @process_files_wf @tom_3768 @tom_3749
Feature: GC Smoke | Orchestrator | GS | Standard OOB | Process Files in Directory

  Scenario: Verify Execution of Workflow with CSV

    Given I assign "tests/test-data/dmp-gs/gswf" to variable "TESTDATA_PATH"
    And I assign "ESI_BRS_SECURITY_20170912-1849.csv" to variable "INPUT_FILENAME_CSV"
    And I assign "eis_dmp_price_manovrd.xlsx" to variable "INPUT_FILENAME_XLSX"
    And I assign "ESISODP_SEC_3_20180423_3972790.out" to variable "INPUT_FILENAME_BNP"

  #Load Data
    Given I copy files below from local folder "${TESTDATA_PATH}/ProcessFilesInDirectory" to the host "dmp.ssh.inbound" folder "${dmp.ssh.inbound.path}":
      | ${INPUT_FILENAME_CSV} |

    When I process files with below parameters and wait for the job to be completed
      | BUSINESS_FEED | EIS_BF_RDM            |
      | FILE_PATTERN  | ${INPUT_FILENAME_CSV} |
      | MESSAGE_TYPE  |                       |

    Then I extract new job id from jblg table into a variable "JOB_ID1"

    Then I poll for maximum 20 seconds and expect the result of the SQL query below equals to "CLOSED":
      """
      SELECT JOB_STAT_TYP FROM FT_T_JBLG WHERE JOB_ID='${JOB_ID1}'
      """

  Scenario: Verify Execution of Workflow with XLSX

  #Load Data
    Given I copy files below from local folder "${TESTDATA_PATH}/ProcessFilesInDirectory" to the host "dmp.ssh.inbound" folder "${dmp.ssh.inbound.path}":
      | ${INPUT_FILENAME_XLSX} |

    When I process files with below parameters and wait for the job to be completed
      | BUSINESS_FEED |                                      |
      | FILE_PATTERN  | ${INPUT_FILENAME_XLSX}               |
      | MESSAGE_TYPE  | EIS_MT_RDM_PORTFOLIO_MASTER_TEMPLATE |

    Then I extract new job id from jblg table into a variable "JOB_ID"

    Then I poll for maximum 20 seconds and expect the result of the SQL query below equals to "CLOSED":
      """
      SELECT JOB_STAT_TYP FROM FT_T_JBLG WHERE JOB_ID='${JOB_ID}'
      """

  Scenario: Verify Execution of Workflow with OUT

    When I copy files below from local folder "${TESTDATA_PATH}/ProcessFilesInDirectory" to the host "dmp.ssh.inbound" folder "${dmp.ssh.inbound.path}":
      | ${INPUT_FILENAME_BNP} |

    Then I process files with below parameters and wait for the job to be completed
      | FILE_PATTERN  | ${INPUT_FILENAME_BNP} |
      | MESSAGE_TYPE  | EIS_MT_BNP_SECURITY   |
      | BUSINESS_FEED |                       |

    Then I expect value of column "RIDF_RECORD_COUNT" in the below SQL query equals to "1":
    """
    SELECT COUNT(*) AS RIDF_RECORD_COUNT FROM FT_T_RIDF WHERE INSTR_ID
    IN (SELECT INSTR_ID FROM FT_T_ISID
    WHERE ISS_ID IN ('MD_533989','MD_533990') AND END_TMS IS NULL) AND REL_TYP = 'SWAP'
    AND END_TMS IS NULL
    """