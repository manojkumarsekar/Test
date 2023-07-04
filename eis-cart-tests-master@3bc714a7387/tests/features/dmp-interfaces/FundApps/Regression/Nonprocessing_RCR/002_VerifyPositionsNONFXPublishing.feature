@gc_interface_positions
@dmp_regression_unittest
@dmp_fundapps_functional @dmp_rcr @tom_4318 @esi_publish_positionsrcr @dmp_fundapps_regression
Feature: 002 | Non-Processing Positions NONFX RCR | Publish Positions NONFX

  Scenario: Publish Non-Processing Positions NONFX in RCR Format

  #Assign Variables
    Given I assign "/dmp/out/eis/fundapps" to variable "PUBLISHING_DIRECTORY"
    And I assign "LEGAEISLPOSITN" to variable "PUBLISHING_FILE_NAME"
    And I generate value with date format "YYYYMMdd" and assign to variable "VAR_SYSDATE"
    And I assign "tests/test-data/dmp-interfaces/FundApps/Functional/Nonprocessing_RCR" to variable "TESTDATA_PATH"
    And I assign "002_LEGAEISLPOSITN_TEMPLATE.csv" to variable "POS_TEMPLATE"

  #Extract Data
    Given I remove below files with pattern in the host "dmp.ssh.inbound" from folder "${PUBLISHING_DIR}" if exists:
      | *${PUBLISHING_FILE_NAME}* |

    When I process publishing wrapper with below parameters and wait for the job to be completed
      | PUBLISHING_FILE_NAME | ${PUBLISHING_FILE_NAME}.csv       |
      | SUBSCRIPTION_NAME    | EIS_DMP_TO_RCR_POSITIONSNONFX_SUB |

    Then I expect below files to be present in the host "dmp.ssh.inbound" into folder "${PUBLISHING_DIRECTORY}" after processing:
      | ${PUBLISHING_FILE_NAME}_${VAR_SYSDATE}_1.csv |

    Then I copy files below from remote folder "${PUBLISHING_DIRECTORY}" on host "dmp.ssh.inbound" into local folder "${TESTDATA_PATH}/outfiles/runtime":
      | ${PUBLISHING_FILE_NAME}_${VAR_SYSDATE}_1.csv |

    And I remove below files in the host "dmp.ssh.inbound" from folder "${PUBLISHING_DIRECTORY}" if exists:
      | ${PUBLISHING_FILE_NAME}_${VAR_SYSDATE}_1.csv |

    Then I expect each record in file "${TESTDATA_PATH}/outfiles/testdata/${POS_TEMPLATE}" should exist in file "${TESTDATA_PATH}/outfiles/runtime/${PUBLISHING_FILE_NAME}_${VAR_SYSDATE}_1.csv" and exceptions to be written to "${TESTDATA_PATH}/outfiles/exceptions_${recon.timestamp}.csv" file