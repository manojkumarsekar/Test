#https://jira.pruconnect.net/browse/EISDEV-6528
#Architectue Requirement: https://collaborate.pruconnect.net/pages/viewpage.action?spaceKey=EISTOMR3&title=Solution+Area+-+Price+R3
#Functional specification : https://collaborate.pruconnect.net/display/EISTT/BM+Rates%7CBberg%7COn+Demand+Request%7CPublish+price+to+BRS
# EISDEV-7037: Wrapper class created for BB request and replay

@gc_interface_request_reply @gc_interface_prices @eisdev_7037
@dmp_regression_integrationtest
@eisdev_6528 @001_price_6528 @001_th_bloomberg_price @bbpersecurity @dmp_thailand_price @dmp_thailand @dmp_gs_upgrade
Feature: Thailand BM Price to BRS | Bloomberg Request and Reply

  This feature covers the request to Bloomberg for Thailand BM Rate and creating the outbound price file to BRS:
  Create a request file based on ESI_TH_BBG_RATES SOI and publish PX_LAST price to BRS.

  1. Publish outbound file to Bloomberg as Request file, once response file received it loads into DMP.
  2. Publish outbound file to BRS
  3. Recon expected an actual file

  Scenario: TC_1:Initialize all the variables

    Given I assign "tests/test-data/dmp-interfaces/Thailand/Price/Outbound" to variable "testdata.path"
    And I assign "/dmp/in/bloomberg" to variable "BB_DOWNLOAD_DIR"
    And I assign "/dmp/out/bloomberg" to variable "BB_UPLOAD_DIR"
    And I assign "004_gs_thbmprice_template.out" to variable "RESPONSE_TEMPLATENAME"
    And I assign "/dmp/out/brs/eod" to variable "PUBLISHING_DIRECTORY"
    And I assign "004_EOD_Price_actual" to variable "ACTUAL_PUBLISHED_FILENAME"
    And I assign "004_EOD_Price_expected" to variable "PUBLISH_FILE_EXPECTED"
    And I assign "004_EOD_Price_expected_template.csv" to variable "PUBLISH_FILE_TEMPLATE"
    And I generate value with date format "YYYYMMdd" and assign to variable "VAR_SYSDATE"

  Scenario: TC_2: Bloomberg request and reply for Thailand BM Price

    And I assign "004_gs_thbmprice_template.out" to variable "RESPONSE_TEMPLATENAME"


    Given Setup BB request reply prerequisites with following details
      | VND_RQST_TYP            | EITH_BM_Price                                                           |
      | RESPONSE_TEMPLATE_PATH  | tests/test-data/dmp-interfaces/Thailand/Price/Outbound/infiles/template |
      | RESPONSE_TEMPLATE_FILES | ${RESPONSE_TEMPLATENAME}                                                |
      | BB_PATH                 | ${BB_DOWNLOAD_DIR}                                                      |


    Given I assign "tests/test-data/intf-specs/gswf/template/EIS_BBPerSecurity/request.xmlt" to variable "BB_PER_SECURITY"

    And I process the workflow template file "${BB_PER_SECURITY}" with below parameters and wait for the job to be completed
      | BB_DOWNLOAD_DIR    | ${BB_DOWNLOAD_DIR} |
      | BB_UPLOAD_DIR      | ${BB_UPLOAD_DIR}   |
      | FIRM_NAME          | dl790188           |
      | GROUP_NAME         | ESI_TH_BBG_RATES   |
      | PRICE_POINT_DEF_ID | ESIPRPTEOD         |
      | REQUEST_TYPE       | EITH_BM_Price      |
      | SN                 | 191305             |
      | USER_NUMBER        | 30350268           |
      | WORK_STATION       | 0                  |

    Then I expect below files to be present in the host "dmp.ssh.inbound" into folder "${BB_UPLOAD_DIR}" after processing:
      | gs_thbmprice${LATEST_SEQ}.req |

    Then I expect workflow is processed in DMP with total record count as "2"

    And I expect value of column "RECORD_COUNT" in the below SQL query equals to "5":
      """
      ${testdata.path}/sql/BBPerSec_VerifyAllWorkflowStatus_DONE.sql
      """

  Scenario: TC_3: Trigger Price publishing for CSV file into directory for Thailand BM Rate Validate

    Given I remove below files in the host "dmp.ssh.inbound" from folder "${PUBLISHING_DIRECTORY}" if exists:
      | ${ACTUAL_PUBLISHED_FILENAME}*.csv |

    When I process publishing wrapper with below parameters and wait for the job to be completed
      | PUBLISHING_FILE_NAME | ${ACTUAL_PUBLISHED_FILENAME}.csv                                                                     |
      | SUBSCRIPTION_NAME    | EIS_DMP_TO_BRS_PRICE_VIEW_SUB                                                                        |
      | SQL                  | <![CDATA[<sql>TRUNC(PRC1_ADJST_TMS) = TRUNC(sysdate) and PRC1_GRP_NME = 'ESI_TH_BBG_RATES' </sql>]]> |

    Then I expect below files to be present in the host "dmp.ssh.inbound" into folder "${PUBLISHING_DIRECTORY}" after processing:
      | ${ACTUAL_PUBLISHED_FILENAME}_${VAR_SYSDATE}_1.csv |

    Then I copy files below from remote folder "${PUBLISHING_DIRECTORY}" on host "dmp.ssh.inbound" into local folder "${testdata.path}/outfiles/actual":
      | ${ACTUAL_PUBLISHED_FILENAME}_${VAR_SYSDATE}_1.csv |

    And I remove below files in the host "dmp.ssh.inbound" from folder "${PUBLISHING_DIRECTORY}" if exists:
      | ${ACTUAL_PUBLISHED_FILENAME}_${VAR_SYSDATE}_1.csv |

  Scenario: TC_46: Recon the EOD Price published file against the expected file

    Given I capture current time stamp into variable "recon.timestamp"

    And I create input file "${PUBLISH_FILE_EXPECTED}_${VAR_SYSDATE}.csv" using template "${PUBLISH_FILE_TEMPLATE}" from location "${testdata.path}/outfiles"

    Then I expect all records from file1 of type CSV exists in file2
      | File1 | ${testdata.path}/outfiles/testdata/${PUBLISH_FILE_EXPECTED}_${VAR_SYSDATE}.csv     |
      | File2 | ${testdata.path}/outfiles/actual/${ACTUAL_PUBLISHED_FILENAME}_${VAR_SYSDATE}_1.csv |