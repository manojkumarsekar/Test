#https://collaborate.intranet.asia/pages/viewpage.action?pageId=45863571#MainDeck--2066775069
#https://jira.pruconnect.net/browse/EISDEV-6921

@gc_interface_securities @gc_interface_positions
@dmp_regression_integrationtest
@eisdev_6921 @001_thai_id_bcusip_publish @dmp_thailand_securities @dmp_thailand
Feature: Publish file to RIMES containing THAIID & BCUSIP

  Below Steps are followed to validate this testing

  1. Load security (F10)
  2. Load positions (F14)
  3. Publish data and check if the published file has THAIID & BCUSIP

  Scenario: TC_1: Initialize variables, fetch portfolio code and clean positions

    Given I assign "001_DMP_RIMES_ThaiID_BCusip_Publish_sm.xml" to variable "SECURITY_INPUT_TEMPLATENAME"
    And I assign "001_DMP_RIMES_ThaiID_BCusip_Publish_position_template.xml" to variable "POSITION_INPUT_TEMPLATENAME"
    And I assign "001_DMP_RIMES_ThaiID_BCusip_Publish_position.xml" to variable "POSITION_INPUT_FILENAME"
    And I assign "tests/test-data/dmp-interfaces/Thailand/Security/RIMES_ThaiID_BCusip/Outbound" to variable "testdata.path"

    And I assign "001_DMP_RIMES_ThaiID_BCusip_expected.csv" to variable "EXPECTED_PUBLISHING_FILE_NAME"
    And I assign "001_DMP_RIMES_ThaiID_BCusip_actual" to variable "ACTUAL_PUBLISHING_FILE_NAME"
    And I generate value with date format "YYYYMMdd" and assign to variable "VAR_SYSDATE"
    And I assign "/dmp/out/rimes/eod" to variable "PUBLISHING_DIR"

    And I execute below query and extract values of "PORTFOLIO_CRTS_1" into same variables
     """
     ${testdata.path}/sql/fetch_portfolio_codes.sql
     """

    # Ensure there are no future dated positions (created by other feature files, so rows should be small in number)
    And I execute below query to "clean future dated positions"
    """
    ${testdata.path}/sql/clean_future_dated_balh.sql
    """

  Scenario:TC_2: Load the security file

    When I process "${testdata.path}/inputfiles/testdata/${SECURITY_INPUT_TEMPLATENAME}" file with below parameters
      | FILE_PATTERN  | ${SECURITY_INPUT_TEMPLATENAME} |
      | MESSAGE_TYPE  | EIS_MT_BRS_SECURITY_NEW        |
      | BUSINESS_FEED |                                |

    Then I expect workflow is processed in DMP with total record count as "3"
    Then I expect workflow is processed in DMP with success record count as "3"

  Scenario: TC_3: Create Position file with POS_DATE as SYSDATE and Load into DMP

    And I create input file "${POSITION_INPUT_FILENAME}" using template "${POSITION_INPUT_TEMPLATENAME}" with below codes from location "${testdata.path}/inputfiles"
      | POS_DATE | DateTimeFormat:M/dd/YYYY |

    When I process "${testdata.path}/inputfiles/testdata/${POSITION_INPUT_FILENAME}" file with below parameters
      | FILE_PATTERN  | ${POSITION_INPUT_FILENAME}        |
      | MESSAGE_TYPE  | EIS_MT_BRS_EOD_POSITION_NON_LATAM |
      | BUSINESS_FEED |                                   |

    Then I expect workflow is processed in DMP with total record count as "3"
    Then I expect workflow is processed in DMP with success record count as "3"

  Scenario: TC_4: Triggering Publishing Wrapper Event for CSV file

    And I remove below files in the host "dmp.ssh.inbound" from folder "${PUBLISHING_DIR}" if exists:
      | ${ACTUAL_PUBLISHING_FILE_NAME}_${VAR_SYSDATE}_1.csv |

    When I process publishing wrapper with below parameters and wait for the job to be completed
      | PUBLISHING_FILE_NAME | ${ACTUAL_PUBLISHING_FILE_NAME}.csv |
      | SUBSCRIPTION_NAME    | EIS_DMP_TO_RIMES_THAIID_BCUSIP_SUB |

    Then I expect below files to be present in the host "dmp.ssh.inbound" into folder "${PUBLISHING_DIR}" after processing:
      | ${ACTUAL_PUBLISHING_FILE_NAME}_${VAR_SYSDATE}_1.csv |

    Then I copy files below from remote folder "${PUBLISHING_DIR}" on host "dmp.ssh.inbound" into local folder "${testdata.path}/outfiles/actual":
      | ${ACTUAL_PUBLISHING_FILE_NAME}_${VAR_SYSDATE}_1.csv |

  Scenario: TC_5: Check if published file contains all the records

    Given I capture current time stamp into variable "recon.timestamp"

    Then I expect all records from file1 of type CSV exists in file2
      | File1 | ${testdata.path}/outfiles/testdata/${EXPECTED_PUBLISHING_FILE_NAME}                  |
      | File2 | ${testdata.path}/outfiles/actual/${ACTUAL_PUBLISHING_FILE_NAME}_${VAR_SYSDATE}_1.csv |
