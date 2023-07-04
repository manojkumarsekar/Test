#https://jira.intranet.asia/browse/TOM-3501  (Initial ticket)
#https://jira.intranet.asia/browse/TOM-3675  (Enhancement)
#https://jira.intranet.asia/browse/TOM-3739  (CITI NAV file changes)

@gc_interface_nav
@dmp_regression_integrationtest
@tom_3501 @tom_3675 @TOM-3739
Feature: Loading NAV file to populate FT_T_ACCV table

  TOM-3501 (Initial ticket)
  NAV file from CITI needs to be formatted in Aladdin format within DMP and send it to Aladdin.

  For this testcase we are trying to load NAV in FT_T_ACCV table and publish the same NAV.
  NAV to be stored in Aladdin from CITI source

  TOM-3675 (Enhancement)
  DATE format is changed from ddmmyyyy to yyyyddmm. And, a new header DATATYPE is added in the published file.

  Scenario: TC_1: Load NAV CITI file

    Given I assign "NAV_CITI.csv" to variable "INPUT_FILENAME"
    And I assign "tests/test-data/DevTest/TOM-3501" to variable "testdata.path"

    And I execute below query to "Clear data for the given NAV for FT_T_ACCV Table"
    """
    ${testdata.path}/sql/ClearData_NAV_CITI.sql
    """

    When I copy files below from local folder "${testdata.path}/testdata" to the host "dmp.ssh.inbound" folder "${dmp.ssh.inbound.path}":
      | ${INPUT_FILENAME} |

    Given I process files with below parameters and wait for the job to be completed
      | BUSINESS_FEED |                      |
      | FILE_PATTERN  | ${INPUT_FILENAME}    |
      | MESSAGE_TYPE  | ESII_MT_CITI_DMP_NAV |

  Scenario: TC_2: Publish NAV files

    Given I assign "esi_nav_citi" to variable "PUBLISHING_FILE_NAME"
    And I generate value with date format "YYYYMMdd" and assign to variable "VAR_SYSDATE"
    And I assign "/dmp/out/brs/eod" to variable "PUBLISHING_DIR"

    And I remove below files in the host "dmp.ssh.inbound" from folder "${PUBLISHING_DIR}" if exists:
      | ${PUBLISHING_FILE_NAME}_${VAR_SYSDATE}_1.csv |

    When I process publishing wrapper with below parameters and wait for the job to be completed
      | PUBLISHING_FILE_NAME | ${PUBLISHING_FILE_NAME}.csv                                                                         |
      | SUBSCRIPTION_NAME    | ESII_DMP_TO_BRS_NAV_CITI_SUB                                                                        |
      | SQL                  | &lt;sql&gt; acct_id in (select acct_id from fT_T_acid where acct_alt_id in ('NDRIFN')) &lt;/sql&gt; |

    Then I expect below files to be present in the host "dmp.ssh.inbound" into folder "${PUBLISHING_DIR}" after processing:
      | ${PUBLISHING_FILE_NAME}_${VAR_SYSDATE}_1.csv |

    Then I copy files below from remote folder "${PUBLISHING_DIR}" on host "dmp.ssh.inbound" into local folder "tests/test-data/DevTest/TOM-3501/outfiles":
      | ${PUBLISHING_FILE_NAME}_${VAR_SYSDATE}_1.csv |

  Scenario: TC_3: Check the price for PORTFOLIO in NAV outbound file

    Given I assign "${testdata.path}/outfiles/${PUBLISHING_FILE_NAME}_${VAR_SYSDATE}_1.csv" to variable "CSV_FILE"

    #Check if PORTFOLIO MLTDED has value 220148267315.27 in the outbound
    Given I expect column "VALUE" value to be "220148267315.27" where columns values are as below in CSV file "${CSV_FILE}"
      | DATE        | 20180711   |
      | PORTFOLIO   | NDRIFN     |
      | CURRENCY    | IDR        |
      | DATA_SOURCE | CITI       |
      | DATATYPE    | ABOR_COMPL |
