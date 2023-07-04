#https://collaborate.intranet.asia/pages/viewpage.action?pageId=45845598
#https://jira.intranet.asia/browse/TOM-3525

@gc_interface_ice @gc_interface_ratings
@dmp_regression_integrationtest
@tom_3525 @r4_in_my_ice_bpam_ratings_outbound_scenarios
Feature: Outbound ICE-BPAM Malaysia ratings from DMP to BRS Interface Testing

  Load new ratings response file with below records (details below), all containing CLIENT_ID, MARC_LT_RATING, MARC_LT_RAT_EFF_DATE, RAM_LT_RATING, RAM_LT_RAT_EFF_DATE
  as mandatory fields and MARC_ST_RATING, RAM_ST_RATING as optional field

  CLIENT_ID,ISIN,PRICE_DATE,CURRENCY,PRICE,PRICE_PURPOSE,PRICE_SOURCE,SECTOR,RAM_LT_RATING,RAM_LT_RAT_EFF_DATE,RAM_ST_RATING,RAM_ST_RAT_EFF_DATE,MARC_LT_RATING,MARC_LT_RAT_EFF_DATE,MARC_ST_RATING,MARC_ST_RAT_EFF_DATE
  ESL7418182,MYBUN1701456,20180723,MYR,100.38,ESIMYS,ESIMY,FINANCIAL SERVICES,A1,20180815,,,A,20180815,,
  ESL4608988,MYBUN1700185,20180723,MYR,101.813,ESIMYS,ESIMY,FINANCIAL SERVICES,A2,20180815,,,AA-IS,20180815,,
  ESL2741151,MYBUN1500908,20180723,MYR,101.857,ESIMYS,ESIMY,FINANCIAL SERVICES,A3,20180815,,,AAA,20180815,,
  ESL5631554,MYBVK1104002,20180723,MYR,99.998,ESIMYS,ESIMY,PROPERTY AND REAL ESTATE,,,,,,,,

  Reload ratings response file

  CLIENT_ID,ISIN,PRICE_DATE,CURRENCY,PRICE,PRICE_PURPOSE,PRICE_SOURCE,SECTOR,RAM_LT_RATING,RAM_LT_RAT_EFF_DATE,RAM_ST_RATING,RAM_ST_RAT_EFF_DATE,MARC_LT_RATING,MARC_LT_RAT_EFF_DATE,MARC_ST_RATING,MARC_ST_RAT_EFF_DATE
  ESL7418182,MYBUN1701456,20180723,MYR,100.38,ESIMYS,ESIMY,FINANCIAL SERVICES,A1,20180815,,,A,20180815,,
  ESL4608988,MYBUN1700185,20180723,MYR,101.813,ESIMYS,ESIMY,FINANCIAL SERVICES,A2,20180815,,,AA-IS,20180815,,
  ESL2741151,MYBUN1500908,20180723,MYR,101.857,ESIMYS,ESIMY,FINANCIAL SERVICES,A3,20180815,,,AAA,20180815,,
  ESL5631554,MYBVK1104002,20180723,MYR,99.998,ESIMYS,ESIMY,PROPERTY AND REAL ESTATE,,,,,,,,

  Below records should be present in the outbound

  EXTERN_NEWCASH_ID1,PORTFOLIO,AMOUNT,CURRENCY,CASH_TYPE,SETTLE_DATE,TRADE_DATE,AUTHORIZED_BY,CASH_REASON,COMMENTS,CONFIRMED_BY,ESTIMATED,SOURCE
  123,NDSICF,2300000,IDR,CASHIN,20180628,20180625,ID-TA,CCRE,NewCash for NDSICF,ID-TA,F,X
  456,ADPSEF,456789.67,IDR,CASHOUT,20180628,20180622,ID-TA,,,ID-TA,F,X

  Scenario: TC_1: Clear the data as a Prerequisite

    Given I assign "R4_IN_MY_ICE_BPAM_Ratings_Test_File_For_Verification.csv" to variable "INPUT_FILENAME"
    And I assign "tests/test-data/DevTest/TOM-3525" to variable "testdata.path"

    And I execute below query to "Clear data"
    """
    ${testdata.path}/sql/ClearData_R4_IN_MY_ICE_BPAM_Ratings.sql
    """

  Scenario: TC_2: Load ICE Response File

    Given I copy files below from local folder "${testdata.path}/infiles" to the host "dmp.ssh.inbound" folder "${dmp.ssh.inbound.path}":
      | ${INPUT_FILENAME} |

    When I process files with below parameters and wait for the job to be completed
      | BUSINESS_FEED |                    |
      | FILE_PATTERN  | ${INPUT_FILENAME}  |
      | MESSAGE_TYPE  | EIM_MT_ICE_REFDATA |

  Scenario: TC_3: Reload ICE Response File

    Given I assign "R4_IN_MY_ICE_BPAM_Ratings_Test_File_For_Reload_Verification.csv" to variable "INPUT_FILENAME"
    And I assign "tests/test-data/DevTest/TOM-3525" to variable "testdata.path"

    When I copy files below from local folder "${testdata.path}/infiles" to the host "dmp.ssh.inbound" folder "${dmp.ssh.inbound.path}":
      | ${INPUT_FILENAME} |

    Then I process files with below parameters and wait for the job to be completed
      | BUSINESS_FEED |                    |
      | FILE_PATTERN  | ${INPUT_FILENAME}  |
      | MESSAGE_TYPE  | EIM_MT_ICE_REFDATA |

  Scenario: TC_4: Triggering Publishing Wrapper Event for CSV file into directory for Malaysia Ratings

    Given I assign "esi_brs_p_ratings" to variable "PUBLISHING_FILE_NAME"
    And I generate value with date format "YYYYMMdd" and assign to variable "VAR_SYSDATE"
    And I assign "/dmp/out/brs/1a_security" to variable "PUBLISHING_DIR"

    And I remove below files with pattern in the host "dmp.ssh.inbound" from folder "${PUBLISHING_DIR}" if exists:
      | ${PUBLISHING_FILE_NAME}_*_1.csv |

      When I process publishing wrapper with below parameters and wait for the job to be completed
      | PUBLISHING_FILE_NAME | ${PUBLISHING_FILE_NAME}.csv   |
      | SUBSCRIPTION_NAME    | EIS_DMP_TO_BRS_BBGRATINGS_SUB |

    Then I expect below files to be present in the host "dmp.ssh.inbound" into folder "${PUBLISHING_DIR}" after processing:
      | ${PUBLISHING_FILE_NAME}_${VAR_SYSDATE}_1.csv |

    And I copy files below from remote folder "${PUBLISHING_DIR}" on host "dmp.ssh.inbound" into local folder "tests/test-data/DevTest/TOM-3525/outfiles/actual":
      | ${PUBLISHING_FILE_NAME}_${VAR_SYSDATE}_1.csv |

  Scenario: TC_5: Check the attributes in the outbound file for Malaysia Ratings

    Given I assign "ICE_BPAM_RATINGS_MASTER_TEMPLATE.csv" to variable "RATINGS_MASTER_TEMPLATE"
    And I assign "${PUBLISHING_FILE_NAME}_${VAR_SYSDATE}_1.csv" to variable "RATINGS_CURR_FILE"

    When I capture current time stamp into variable "recon.timestamp"
    Then I expect each record in file "${testdata.path}/outfiles/expected/${RATINGS_MASTER_TEMPLATE}" should exist in file "${testdata.path}/outfiles/actual/${RATINGS_CURR_FILE}" and exceptions to be written to "${testdata.path}/outfiles/exceptions_${recon.timestamp}.csv" file