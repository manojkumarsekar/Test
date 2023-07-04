#https://collaborate.intranet.asia/pages/viewpage.action?spaceKey=TOMTN&title=Cmoney+Security+Static+in+DMP+and+CDF+to+BRS#businessRequirements-700165352
#https://jira.intranet.asia/browse/TOM-3970
#eisdev_6554: updated recon file

@gc_interface_securities @gc_interface_cdf
@dmp_regression_integrationtest
@dmp_taiwan
@tom_3970 @eisdev_6554 @brs_cdf
Feature: To load CMoney data to dmp to set up ISMC with value of Fund Share outstanding
  publish CDF file and check if Fund Share outstanding is getting published in the output file

  Scenario: TC_1: Clear old test data and setup variables

    Given I assign "tests/test-data/dmp-interfaces/Taiwan/CMoney" to variable "testdata.path"
    And I assign "001_New_Security.csv" to variable "INPUT_FILENAME"

    And I execute below query to clear and Setup new dummy security in DMP
    """
    ${testdata.path}/sql/CLEAR_DUMMY_DATA_1.sql;
    ${testdata.path}/sql/DUMMY_ISSU_ISID_SETUP.sql
    """

  Scenario: TC_2: Verify ISMC data set up for value of field - Fund Share Outstanding

    Given I assign "002_New_Security.csv" to variable "INPUT_FILENAME"

    And I copy files below from local folder "${testdata.path}/infiles" to the host "dmp.ssh.inbound" folder "${dmp.ssh.inbound.path}":
      | ${INPUT_FILENAME} |

    And I process files with below parameters and wait for the job to be completed
      | BUSINESS_FEED |                             |
      | FILE_PATTERN  | ${INPUT_FILENAME}           |
      | MESSAGE_TYPE  | EITW_MT_CMONEY_DMP_SECURITY |

    Then I extract new job id from jblg table into a variable "JOB_ID"

    And I expect value of column "JBLG_ROW_COUNT" in the below SQL query equals to "1":
      """
      SELECT count(*) as JBLG_ROW_COUNT FROM FT_T_JBLG WHERE JOB_ID = '${JOB_ID}'
      AND TASK_SUCCESS_CNT ='0'
      AND TASK_PARTIAL_CNT ='1'
      AND TASK_FAILED_CNT = '0'
      """

    And I expect value of column "ISMC_COUNT" in the below SQL query equals to "1":
      """
      SELECT COUNT(*) AS ISMC_COUNT FROM FT_T_ISMC
        WHERE CAPITAL_TYP = 'CMFSO'
        AND CAP_SEC_CQTY = '15099929.547'
        AND DATA_SRC_ID = 'CMONEY'
        AND END_TMS IS NULL
        AND INSTR_ID IN (SELECT INSTR_ID FROM FT_T_ISID WHERE ISS_ID = 'TS3970000005' AND ID_CTXT_TYP = 'ISIN'
        AND END_TMS IS NULL)
      """

  Scenario: TC_3: Triggering Publishing Wrapper Event for CSV file into directory for CMoney data

    Given I assign "esi_brs_sec_cdf" to variable "PUBLISHING_FILE_NAME"
    And I generate value with date format "YYYYMMdd" and assign to variable "VAR_SYSDATE"
    And I assign "/dmp/out/brs/1a_security" to variable "PUBLISHING_DIR"

    And I remove below files with pattern in the host "dmp.ssh.inbound" from folder "${PUBLISHING_DIR}" if exists:
      | ${PUBLISHING_FILE_NAME}_*.csv |

    When I process publishing wrapper with below parameters and wait for the job to be completed
      | PUBLISHING_FILE_NAME | ${PUBLISHING_FILE_NAME}.csv |
      | SUBSCRIPTION_NAME    | EIS_DMP_TO_BRS_CDF_SUB      |

    Then I expect below files to be present in the host "dmp.ssh.inbound" into folder "${PUBLISHING_DIR}" after processing:
      | ${PUBLISHING_FILE_NAME}_${VAR_SYSDATE}_1.csv |

    Then I copy files below from remote folder "${PUBLISHING_DIR}" on host "dmp.ssh.inbound" into local folder "${testdata.path}/outfiles/actual":
      | ${PUBLISHING_FILE_NAME}_${VAR_SYSDATE}_1.csv |

  Scenario: TC_3: Check if published file contains Fund Share Outstanding value which were loaded for CMoney Security

    Given I assign "esi_brs_sec_cdf_expected.csv" to variable "CMONEY_CDF_EXPECTED"
    And I assign "${PUBLISHING_FILE_NAME}_${VAR_SYSDATE}_1.csv" to variable "CMONEY_CDF_CURR_FILE"

    When I capture current time stamp into variable "recon.timestamp"
    Then I expect each record in file "${testdata.path}/outfiles/expected/${CMONEY_CDF_EXPECTED}" should exist in file "${testdata.path}/outfiles/actual/${CMONEY_CDF_CURR_FILE}" and exceptions to be written to "${testdata.path}/outfiles/actual/exceptions_${recon.timestamp}.csv" file