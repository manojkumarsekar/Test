#Feature History
#TOM-4091 : Initial Feature File
#EISDEV-6943 : Use data driven test files, to avoid risk of failure due to production data changes

@gc_interface_securities
@dmp_regression_unittest
@tom_4091
Feature: BRS-DMP | F10 | TOM-4091 | Verify ASSET_STATUS_TYPE Update in ISTA table

  Scenario: Validate Update functionality for ASSET_STATUS_TYPE received as part of F10 in ISTA.ISS_STAT_TYP

  #Assign Variables
    And I assign "tests/test-data/DevTest/TOM-4091" to variable "TESTDATA_PATH"
    And I assign "sm_load1.xml" to variable "INPUT_FILENAME_1"
    And I assign "sm_load2.xml" to variable "INPUT_FILENAME_2"
    And I execute query "${TESTDATA_PATH}/sql/fetch_test_instrument.sql" and extract values of "INSTR_ID;ISIN;SEDOL;BCUSIP;EISLSTID;RIC" into same variables
    And I create input file "${INPUT_FILENAME_1}" using template "sm_load1_template.xml" from location "${TESTDATA_PATH}"
    And I create input file "${INPUT_FILENAME_2}" using template "sm_load2_template.xml" from location "${TESTDATA_PATH}"

  #Load Data
    Given I copy files below from local folder "${TESTDATA_PATH}/testdata" to the host "dmp.ssh.inbound" folder "${dmp.ssh.inbound.path}":
      | ${INPUT_FILENAME_1} |

    Given I process files with below parameters and wait for the job to be completed
      | BUSINESS_FEED |                         |
      | FILE_PATTERN  | ${INPUT_FILENAME_1}     |
      | MESSAGE_TYPE  | EIS_MT_BRS_SECURITY_NEW |

    Then I extract new job id from jblg table into a variable "JOB_ID1"

    Then I poll for maximum 20 seconds and expect the result of the SQL query below equals to "CLOSED":
      """
      SELECT JOB_STAT_TYP FROM FT_T_JBLG WHERE JOB_ID='${JOB_ID1}'
      """

    Then I expect value of column "ISTA_ISS_STAT_TYP_DEL" in the below SQL query equals to "1":
    """
    SELECT COUNT(*) AS ISTA_ISS_STAT_TYP_DEL FROM FT_T_ISTA WHERE INSTR_ID = '${INSTR_ID}' AND ISS_STAT_TYP = 'DEL'
    """

    #Load Data
    Given I copy files below from local folder "${TESTDATA_PATH}/testdata" to the host "dmp.ssh.inbound" folder "${dmp.ssh.inbound.path}":
      | ${INPUT_FILENAME_2} |

    Given I process files with below parameters and wait for the job to be completed
      | BUSINESS_FEED |                         |
      | FILE_PATTERN  | ${INPUT_FILENAME_2}     |
      | MESSAGE_TYPE  | EIS_MT_BRS_SECURITY_NEW |

    Then I extract new job id from jblg table into a variable "JOB_ID1"

    Then I poll for maximum 20 seconds and expect the result of the SQL query below equals to "CLOSED":
      """
      SELECT JOB_STAT_TYP FROM FT_T_JBLG WHERE JOB_ID='${JOB_ID1}'
      """

    Then I expect value of column "ISTA_ISS_STAT_TYP_EXC" in the below SQL query equals to "1":
    """
    SELECT COUNT(*) AS ISTA_ISS_STAT_TYP_EXC FROM FT_T_ISTA WHERE INSTR_ID = '${INSTR_ID}' AND ISS_STAT_TYP = 'EXC'
    """