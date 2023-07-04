#https://collaborate.pruconnect.net/display/EISTOMR4/Taiwan+Portfolio-Security-Broker+Mapping
#https://collaborate.pruconnect.net/display/EISTOMR3/Taiwan+Portfolio-Security-Broker+Mapping+Templates
#https://jira.pruconnect.net/browse/EISDEV-5517

@gc_interface_broker
@dmp_regression_unittest
@dmp_taiwan
@esidev_5517 @dmp_pf_sec_broker_mapping_verify_dataexception
Feature: 002 | Portfolio Security Broker Mapping | Verify Data Exceptions

  We are mapping below fields in DMP. This feature files is to verify exceptions are generated if mandatory fields are missing
  Data Sample
  1. Loading Data with CRTSID = ACCTID1 and EIS_TW_BRS_BROKER_CODE = BROKERID1 with no security identifier
  2. Loading Data with BCUSIP = SECID1 and EIS_TW_BRS_BROKER_CODE = BROKERID1 with no portfolio identifier
  3. Loading Data with CRTSID = ACCTID2 and BCUSIP = SECID2 with no broker code identifier

  Scenario: Loading Data using Portfolio Security Broker Mapping Uploader

    Given I generate value with date format "YYYYMMdd" and assign to variable "VAR_SYSDATE"
    And I assign "tests/test-data/dmp-interfaces/Taiwan/Portfolio_Security_Broker_Mapping" to variable "TESTDATA_PATH"
    And I assign "DMP_PortfolioSecurityBrokerMappingTemplate_Exceptions.xlsx" to variable "INPUT_FILENAME"

    Given I copy files below from local folder "${TESTDATA_PATH}/inputfiles/testdata" to the host "dmp.ssh.inbound" folder "${dmp.ssh.inbound.path}":
      | ${INPUT_FILENAME} |

    When I process files with below parameters and wait for the job to be completed
      | BUSINESS_FEED |                                     |
      | FILE_PATTERN  | ${INPUT_FILENAME}                   |
      | MESSAGE_TYPE  | EIS_MT_DMP_TW_PF_SEC_BROKER_MAPPING |

    Then I expect workflow is processed in DMP with success record count as "0"

  Scenario: Exception Verification for Missing Security Data
  Expect NTEL is created with an error

    Then I expect an exception is captured with the following criteria
      | TRID.RECORD_SEQ_NUM | 1                                                                                                                    |
      | PARM_VAL_TXT        | User defined Error thrown! . Cannot process record as none of the security identifiers are available in input record |

  Scenario: Exception Verification for Missing Portfolio Data
  Expect NTEL is created with an error

    Then I expect an exception is captured with the following criteria
      | TRID.RECORD_SEQ_NUM | 2                                                                                                                     |
      | PARM_VAL_TXT        | User defined Error thrown! . Cannot process record as none of the portfolio identifiers are available in input record |


  Scenario: Exception Verification for Missing Portfolio Data
  Expect NTEL is created with an error

    Then I expect an exception is captured with the following criteria
      | TRID.RECORD_SEQ_NUM | 3                                                                                                             |
      | PARM_VAL_TXT        | User defined Error thrown! . Cannot process record as EIS_TW_BRS_BROKER_CODE is not available in input record |
