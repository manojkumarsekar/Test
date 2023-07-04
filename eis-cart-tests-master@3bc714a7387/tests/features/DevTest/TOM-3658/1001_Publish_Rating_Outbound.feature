#https://jira.intranet.asia/browse/TOM-3658

@gc_interface_ratings
@dmp_regression_unittest
@tom_3948 @tom_3658 @rating_publish
Feature: Publish the BBG Rating file to BRS and rows should not have duplicate

  Duplicate rows in the Ratings interface file to BRS, There are 2 reason
  1. There are more then EISLSTID id on few of the securities. The solution is remove the looping on listing and remove the junk data
  2. SecurityFRIP contains BBGISSR, RDMISSR,BRSISSR. The solution is add the filter BBGISSR on MDX level

  Below Scenarios are handled as part of this feature
  1. Publish the BBG Rating CSV file into directory
  2. Check the file format
  3. Output files should not have duplicate any duplicate rows

  Scenario: TC_1: Publish the BBG Rating file into directory

    Given I assign "esi_brs_p_ratings" to variable "PUBLISHING_FILE_NAME"
    And I generate value with date format "YYYYMMdd" and assign to variable "VAR_SYSDATE"
    And I assign "/dmp/out/brs/1a_security" to variable "PUBLISHING_DIR"
    And I assign "tests/test-data/DevTest/TOM-3658" to variable "testdata.path"

    And I remove below files in the host "dmp.ssh.inbound" from folder "${PUBLISHING_DIR}" if exists:
      | ${PUBLISHING_FILE_NAME}_${VAR_SYSDATE}_1.csv |

    When I process publishing wrapper with below parameters and wait for the job to be completed
      | PUBLISHING_FILE_NAME | ${PUBLISHING_FILE_NAME}.csv   |
      | SUBSCRIPTION_NAME    | EIS_DMP_TO_BRS_BBGRATINGS_SUB |

    Then I expect below files to be present in the host "dmp.ssh.inbound" into folder "${PUBLISHING_DIR}" after processing:
      | ${PUBLISHING_FILE_NAME}_${VAR_SYSDATE}_1.csv |

    And I copy files below from remote folder "${PUBLISHING_DIR}" on host "dmp.ssh.inbound" into local folder "${testdata.path}/outfiles/actual":
      | ${PUBLISHING_FILE_NAME}_${VAR_SYSDATE}_1.csv |

  Scenario: TC_2: Check the file format
    Then I expect file "${testdata.path}/outfiles/actual/${PUBLISHING_FILE_NAME}_${VAR_SYSDATE}_1.csv" should have below columns
      | ISSUER_FLAG,CUSIP,CLIENT_ID,ISIN,SEDOL,AGY,DATE,VALUE |

  Scenario: TC_3: Output files should not have duplicate any duplicate rows
    Then I expect duplicate records not found in the file "${testdata.path}/outfiles/actual/${PUBLISHING_FILE_NAME}_${VAR_SYSDATE}_1.csv"