#https://jira.pruconnect.net/browse/EISDEV-7082
#Functional specification : https://collaborate.pruconnect.net/pages/viewpage.action?spaceKey=EISTT&title=SET+EQ+Sector+Classification%2CTBMA+Upload+and+Publish+FI+Prices%2CRatings%7CRIMES%3EDMP%3EBRS%7CPassthrough#businessRequirements-1989358494

#EISDEV-7352: removed suffix

@gc_interface_rating
@dmp_regression_integrationtest
@eisdev_7082 @002_tmbam_rating_publish @dmp_thailand_rating @dmp_thailand @eisdev_7352

Feature: TMBAM Rimes Rating Publish for Thailand

  The purpose of this interface is to load Publish Rating from DMP.
  It was a pass-through file from RIMES but is getting loaded to handle the change in Rating effective date
  Rimes default the Rating effective date to sysdate which creates duplicate in Aladdin.
  As part of this interface we will handle the above scenario and change the rating effective only when rating changes
  Only new ratings or changed ratings will be published

  Scenario: TC1: Initialize variables and clean price table

    Given I assign "tests/test-data/dmp-interfaces/Thailand/Rating/Outbound" to variable "testdata.path"
    And I assign "002_Th.Aldn-13_TMBAM_DMP_Rimes_Rating_New.csv" to variable "RATING_INPUT_FILENAME_NEW"
    And I assign "002_Th.Aldn-13_TMBAM_DMP_Rimes_Rating_Update.csv" to variable "RATING_INPUT_FILENAME_UPDATE"
    And I assign "/dmp/out/brs/eod" to variable "PUBLISHING_DIRECTORY"
    And I assign "002_Th_Aldn-13_TMBAM_DMP_Rimes_Rating_Actual_1" to variable "ACTUAL_PUBLISH_FILENAME_1"
    And I assign "002_Th_Aldn-13_TMBAM_DMP_Rimes_Rating_Expected_1" to variable "EXPECTED_PUBLISH_FILENAME_1"
    And I assign "002_Th_Aldn-13_TMBAM_DMP_Rimes_Rating_Actual_2" to variable "ACTUAL_PUBLISH_FILENAME_2"
    And I assign "002_Th_Aldn-13_TMBAM_DMP_Rimes_Rating_Expected_2" to variable "EXPECTED_PUBLISH_FILENAME_2"
    And I generate value with date format "YYYYMMdd" and assign to variable "VAR_SYSDATE"

    #Delete old data
    And I execute below query to "delete existing price"
    """
      DELETE FT_T_RTG2 WHERE EXT_ISIN = 'TEST74033501' OR EXT_CLIENT_ID = 'TEST7082' OR EXT_CLIENT_ID LIKE 'TEST7352%';
    """

  Scenario:TC2: Load TMBAM Rimes rating file to create new ratings

    Given I process "${testdata.path}/testdata/${RATING_INPUT_FILENAME_NEW}" file with below parameters
      | FILE_PATTERN  | ${RATING_INPUT_FILENAME_NEW} |
      | MESSAGE_TYPE  | EITH_MT_RIMES_DMP_BRS_RATING |
      | BUSINESS_FEED |                              |

    Then I expect workflow is processed in DMP with total record count as "9"

  Scenario:TC3: Trigger Ratings publishing file 1 for new ratings

    Given I remove below files in the host "dmp.ssh.inbound" from folder "${PUBLISHING_DIRECTORY}" if exists:
      | ${ACTUAL_PUBLISH_FILENAME_1}*.csv |

    When I process publishing wrapper with below parameters and wait for the job to be completed
      | PUBLISHING_FILE_NAME | ${ACTUAL_PUBLISH_FILENAME_1}.csv       |
      | SUBSCRIPTION_NAME    | EITH_DMP_TO_BRS_TMBAM_RIMES_RATING_SUB |

    Then I expect below files to be present in the host "dmp.ssh.inbound" into folder "${PUBLISHING_DIRECTORY}" after processing:
      | ${ACTUAL_PUBLISH_FILENAME_1}_${VAR_SYSDATE}_1.csv |

    Then I copy files below from remote folder "${PUBLISHING_DIRECTORY}" on host "dmp.ssh.inbound" into local folder "${testdata.path}/outfiles/actual":
      | ${ACTUAL_PUBLISH_FILENAME_1}_${VAR_SYSDATE}_1.csv |

    And I remove below files in the host "dmp.ssh.inbound" from folder "${PUBLISHING_DIRECTORY}" if exists:
      | ${ACTUAL_PUBLISH_FILENAME_1}_${VAR_SYSDATE}_1.csv |

  Scenario:TC4: Recon the EOD Price published file against the expected file

    Then I expect all records from file1 of type CSV exists in file2
      | File1 | ${testdata.path}/outfiles/expected/${EXPECTED_PUBLISH_FILENAME_1}.csv              |
      | File2 | ${testdata.path}/outfiles/actual/${ACTUAL_PUBLISH_FILENAME_1}_${VAR_SYSDATE}_1.csv |

  Scenario:TC5: Load TMBAM Rimes rating file to update ratings

    Given I process "${testdata.path}/testdata/${RATING_INPUT_FILENAME_UPDATE}" file with below parameters
      | FILE_PATTERN  | ${RATING_INPUT_FILENAME_UPDATE} |
      | MESSAGE_TYPE  | EITH_MT_RIMES_DMP_BRS_RATING    |
      | BUSINESS_FEED |                                 |

    Then I expect workflow is processed in DMP with total record count as "2"

  Scenario:TC6: Trigger Ratings publishing file 1 for update on ratings

    Given I remove below files in the host "dmp.ssh.inbound" from folder "${PUBLISHING_DIRECTORY}" if exists:
      | ${ACTUAL_PUBLISH_FILENAME_2}*.csv |

    When I process publishing wrapper with below parameters and wait for the job to be completed
      | PUBLISHING_FILE_NAME | ${ACTUAL_PUBLISH_FILENAME_2}.csv       |
      | SUBSCRIPTION_NAME    | EITH_DMP_TO_BRS_TMBAM_RIMES_RATING_SUB |

    Then I expect below files to be present in the host "dmp.ssh.inbound" into folder "${PUBLISHING_DIRECTORY}" after processing:
      | ${ACTUAL_PUBLISH_FILENAME_2}_${VAR_SYSDATE}_1.csv |

    Then I copy files below from remote folder "${PUBLISHING_DIRECTORY}" on host "dmp.ssh.inbound" into local folder "${testdata.path}/outfiles/actual":
      | ${ACTUAL_PUBLISH_FILENAME_2}_${VAR_SYSDATE}_1.csv |

    And I remove below files in the host "dmp.ssh.inbound" from folder "${PUBLISHING_DIRECTORY}" if exists:
      | ${ACTUAL_PUBLISH_FILENAME_2}_${VAR_SYSDATE}_1.csv |

  Scenario:TC7: Recon the EOD Price published file against the expected file

    Then I expect all records from file1 of type CSV exists in file2
      | File1 | ${testdata.path}/outfiles/expected/${EXPECTED_PUBLISH_FILENAME_2}.csv              |
      | File2 | ${testdata.path}/outfiles/actual/${ACTUAL_PUBLISH_FILENAME_2}_${VAR_SYSDATE}_1.csv |
