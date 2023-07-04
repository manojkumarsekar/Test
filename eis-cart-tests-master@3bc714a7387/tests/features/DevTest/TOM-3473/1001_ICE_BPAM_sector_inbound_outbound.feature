#https://collaborate.intranet.asia/pages/viewpage.action?pageId=45850487#Test-logicalMapping
#https://jira.intranet.asia/browse/TOM-3473

@gc_interface_ice @gc_interface_cdf @ignore @to_be_fixed_eisdev_7581

@dmp_regression_integrationtest
@tom_3473 @dmp_ice_bpam_sector @1001_ice_bpam_sector_inbound_outbound @brs_cdf
Feature: To load response file from ICE BPAM, publish CDF file and check if ESI_MY_BPAM_SECTOR is getting published in the output file

  To obtain sector classification from BPAM, at security level, for all Malaysia bonds.
  Requested by ESMY FI team. BPAM sector is required for Malaysia local bonds.
  Current Sectors provided by BRS is not complete for Malaysia Bond universe.
  Hence, causing issues for Investment Management activities.
  BPAM is official source for Malaysia Bonds which has full coverage for MY issued bonds

  Scenario: TC_1: Load ICE Response File

    Given I assign "ICEBPAM_ESI_PRICE_REF.csv" to variable "INPUT_FILENAME"
    And I assign "tests/test-data/DevTest/TOM-3473" to variable "testdata.path"

    Given I copy files below from local folder "${testdata.path}/infiles" to the host "dmp.ssh.inbound" folder "${dmp.ssh.inbound.path}":
      | ${INPUT_FILENAME} |

    When I process files with below parameters and wait for the job to be completed
      | BUSINESS_FEED |                    |
      | FILE_PATTERN  | ${INPUT_FILENAME}  |
      | MESSAGE_TYPE  | EIM_MT_ICE_REFDATA |

    Then I expect value of column "ISCL_COUNT_CHECK" in the below SQL query equals to "PASS":
     """
     SELECT CASE WHEN COUNT(1)>=315 THEN 'PASS' ELSE 'FAIL' END AS ISCL_COUNT_CHECK FROM FT_T_ISCL
     WHERE INDUS_CL_SET_ID = 'BPAMSCTR'
     AND END_TMS IS NULL
     """

  Scenario: TC_2: Triggering Publishing Wrapper Event for CSV file into directory for BPAM Sector

    Given I assign "esi_brs_p_sector" to variable "PUBLISHING_FILE_NAME"
    And I generate value with date format "YYYYMMdd" and assign to variable "VAR_SYSDATE"
    And I assign "/dmp/out/brs/1a_security" to variable "PUBLISHING_DIR"

    And I remove below files in the host "dmp.ssh.inbound" from folder "${PUBLISHING_DIR}" if exists:
      | ${PUBLISHING_FILE_NAME}_${VAR_SYSDATE}_1.csv |

    When I process publishing wrapper with below parameters and wait for the job to be completed
      | PUBLISHING_FILE_NAME | ${PUBLISHING_FILE_NAME}.csv |
      | SUBSCRIPTION_NAME    | EIS_DMP_TO_BRS_CDF_SUB      |

    Then I expect below files to be present in the host "dmp.ssh.inbound" into folder "${PUBLISHING_DIR}" after processing:
      | ${PUBLISHING_FILE_NAME}_${VAR_SYSDATE}_1.csv |

    Then I copy files below from remote folder "${PUBLISHING_DIR}" on host "dmp.ssh.inbound" into local folder "${testdata.path}/outfiles/actual":
      | ${PUBLISHING_FILE_NAME}_${VAR_SYSDATE}_1.csv |

  Scenario: TC_3: Check if published file contains all the records which were loaded for BPAM Sector

    Given I assign "ICE_BPAM_SECTOR_MASTER_TEMPLATE.csv" to variable "SECTOR_MASTER_TEMPLATE"
    And I assign "${PUBLISHING_FILE_NAME}_${VAR_SYSDATE}_1.csv" to variable "SECTOR_CURR_FILE"

    When I capture current time stamp into variable "recon.timestamp"
    Then I expect each record in file "${testdata.path}/outfiles/expected/${SECTOR_MASTER_TEMPLATE}" should exist in file "${testdata.path}/outfiles/actual/${SECTOR_CURR_FILE}" and exceptions to be written to "${testdata.path}/outfiles/actual/exceptions_${recon.timestamp}.csv" file
