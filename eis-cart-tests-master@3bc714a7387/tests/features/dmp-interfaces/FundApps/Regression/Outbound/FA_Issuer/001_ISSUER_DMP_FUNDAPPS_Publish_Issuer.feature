#https://collaborate.intranet.asia/pages/viewpage.action?pageId=60786075#MainDeck--1455554384
#1 : https://jira.pruconnect.net/browse/EISDEV-5028 - new feature

 # This outbound file is sent to FundApps having Reuters Issuer information.
 # The extract criteria of this file is those Reuters issuers which are related to the instruments for the positions of that day

@gc_interface_funds @gc_interface_reuters @gc_interface_securities @gc_interface_positions @gc_interface_issuer
@dmp_regression_integrationtest
@eisdev_5028 @fa_outbound @dmp_fundapps_regression @eisdev_7453
Feature: 001_ISSUER_DMP_FUNDAPPS Verify Outbound Issuers for FundApps
  As a user, I should be able to publish Issuer file into FUNDAPPS from DMP and I expect valid data is published successfully.

  Prerequisites:
  Before Publishing Issuer file, As a user I must ensure below static data is created or loaded.
  1. FUND file
  2. Security File
  3. Position data
  4. Thomson Reuters TR Files

  Scenario: Assign Variables

    Given I assign "tests/test-data/dmp-interfaces/FundApps/Regression/Outbound/Issuer" to variable "TESTDATA_PATH"
    And I generate value with date format "YYYYMMdd" and assign to variable "VAR_SYSDATE"
    And I assign "/dmp/out/fundapps" to variable "PUBLISHING_DIRECTORY"
    And I assign "120" to variable "workflow.max.polling.time"
    And I assign "FA_ISSR" to variable "FAISSR_PUBLISHING_FILE_NAME"
    And I generate value with date format "YYYYMMdd" and assign to variable "VAR_SYSDATE"

  Scenario: Load pre-requisite BOCI Fund Data before BOCI Security file
  verify fund file loaded successfully.

    When I copy files below from local folder "${TESTDATA_PATH}/inputfiles/BOCI" to the host "dmp.ssh.inbound" folder "${dmp.ssh.inbound.path}":
      | BOCI-FUND.csv |

    And I process files with below parameters and wait for the job to be completed
      | FILE_PATTERN  | BOCI-FUND.csv        |
      | MESSAGE_TYPE  | EIS_MT_BOCI_DMP_FUND |
      | BUSINESS_FEED |                       |

    Then I expect workflow is processed in DMP with success record count as "1"

    And I expect value of column "BOCISSH_COUNT" in the below SQL query equals to "1":
      """
      SELECT count(*) as BOCISSH_COUNT FROM FT_T_ACST
      WHERE STAT_DEF_ID in ('SSHFLAG')
      AND STAT_CHAR_VAL_TXT='Y'
      AND ACCT_ID in (select ACCT_ID from ft_t_acid where acct_alt_id in ('D25') and acct_id_ctxt_typ='CRTSID' and end_tms is null)
      """

  Scenario: Load BOCI Security File
  verify security file loaded successfully.

    When I copy files below from local folder "${TESTDATA_PATH}/inputfiles/BOCI" to the host "dmp.ssh.inbound" folder "${dmp.ssh.inbound.path}":
      | BOCI-SECURITY.csv |

    And I process files with below parameters and wait for the job to be completed
      | FILE_PATTERN  | BOCI-SECURITY.csv        |
      | MESSAGE_TYPE  | EIS_MT_BOCI_DMP_SECURITY |
      | BUSINESS_FEED |                           |

    Then I expect workflow is processed in DMP with completed record count as "3"


  Scenario: Load BOCI Position Data
  verify position file loaded successfully.

    Given I execute below query to "Clear the BALH"
    """
    tests/test-data/dmp-interfaces/FundApps/Functional/Outbound/sql/Clear_balh.sql
    """

    And I assign "BOCI-POSN.csv" to variable "INPUT_FILENAME"
    And I assign "BOCI-POSN_TEMPLATE.csv" to variable "INPUT_TEMPLATENAME"
    And I generate value with date format "ddMMYYYY" and assign to variable "VAR_SYSDATE"
    And I modify date "${VAR_SYSDATE}" with "-0d" from source format "ddMMYYYY" to destination format "dd/MM/YYYY" and assign to "DYNAMIC_DATE"
    And I create input file "${INPUT_FILENAME}" using template "${INPUT_TEMPLATENAME}" from location "${TESTDATA_PATH}/inputfiles/BOCI"

    When I copy files below from local folder "${TESTDATA_PATH}/inputfiles/BOCI/testdata" to the host "dmp.ssh.inbound" folder "${dmp.ssh.inbound.path}":
      | BOCI-POSN.csv |

    And I process files with below parameters and wait for the job to be completed
      | FILE_PATTERN  | BOCI-POSN.csv            |
      | MESSAGE_TYPE  | EIS_MT_BOCI_DMP_POSITION |
      | BUSINESS_FEED |                           |

    Then I expect workflow is processed in DMP with total record count as "6"


  Scenario: Load Thomson Reuters Terms and conditions data
  verify Thomson Reuters Terms and conditions file loaded successfully.

    When I copy files below from local folder "${TESTDATA_PATH}/inputfiles/BOCI" to the host "dmp.ssh.inbound" folder "${dmp.ssh.inbound.path}":
      | RTISSR-TNC-SECURITY.csv |

    And I process files with below parameters and wait for the job to be completed
      | FILE_PATTERN  | RTISSR-TNC-SECURITY.csv       |
      | MESSAGE_TYPE  | ReutersDSS_TermsandConditions |
      | BUSINESS_FEED |                               |

    Then I expect workflow is processed in DMP with completed record count as "3"


  Scenario: Load Thomson Reuters Composite data
  verify Thomson Reuters Composite file loaded successfully.

    Given I copy files below from local folder "${TESTDATA_PATH}/inputfiles/BOCI" to the host "dmp.ssh.inbound" folder "${dmp.ssh.inbound.path}":
      | RTISSR-COMP-SECURITY.csv |

    When I process files with below parameters and wait for the job to be completed
      | FILE_PATTERN  | RTISSR-COMP-SECURITY.csv |
      | MESSAGE_TYPE  | EIS_MT_REUTERS_COMPOSITE |
      | BUSINESS_FEED |                          |

    Then I expect workflow is processed in DMP with completed record count as "3"


  Scenario: Publish Issuer File to fundapps from dmp
  verify Issuer File file published successfully.

    Given I generate value with date format "YYYYMMdd" and assign to variable "VAR_SYSDATE"
    And I remove below files with pattern in the host "dmp.ssh.inbound" from folder "${PUBLISHING_DIRECTORY}" if exists:
      | ${FAISSR_PUBLISHING_FILE_NAME}_*.csv |

    When I process publishing wrapper with below parameters and wait for the job to be completed
      | PUBLISHING_FILE_NAME | ${FAISSR_PUBLISHING_FILE_NAME}.csv |
      | SUBSCRIPTION_NAME    | EIS_DMP_TO_FUNDAPPS_ISSUER_SUB     |

    Then I expect below files to be present in the host "dmp.ssh.inbound" into folder "${PUBLISHING_DIRECTORY}" after processing:
      | ${FAISSR_PUBLISHING_FILE_NAME}_${VAR_SYSDATE}_1.csv |

    And I copy files below from remote folder "${PUBLISHING_DIRECTORY}" on host "dmp.ssh.inbound" into local folder "${TESTDATA_PATH}/outfiles/runtime":
      | ${FAISSR_PUBLISHING_FILE_NAME}_${VAR_SYSDATE}_1.csv |

    And I remove below files with pattern in the host "dmp.ssh.inbound" from folder "${PUBLISHING_DIRECTORY}" if exists:
      | ${FAISSR_PUBLISHING_FILE_NAME}_*.csv |


  Scenario: Check if published file contains all the records which were loaded for FundApps Issuer data

    Given I assign "FAISSR_expected.csv" to variable "MASTER_FILE"
    And I assign "${FAISSR_PUBLISHING_FILE_NAME}_${VAR_SYSDATE}_1.csv" to variable "OUTPUT_FILE"

    When I capture current time stamp into variable "recon.timestamp"
    Then I expect each record in file "${TESTDATA_PATH}/outfiles/expected/${MASTER_FILE}" should exist in file "${TESTDATA_PATH}/outfiles/runtime/${OUTPUT_FILE}" and exceptions to be written to "${TESTDATA_PATH}/outfiles/runtime/exceptions_${recon.timestamp}.csv" file

  Scenario: Cleanup max polling time variable
    Then I remove variable "workflow.max.polling.time" from memory