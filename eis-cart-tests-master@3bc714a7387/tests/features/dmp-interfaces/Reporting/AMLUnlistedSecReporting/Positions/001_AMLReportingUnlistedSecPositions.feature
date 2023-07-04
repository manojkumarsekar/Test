#https://jira.pruconnect.net/browse/EISDEV-6387
#https://jira.pruconnect.net/browse/EISDEV-6771, to in include FUND  | OPEN_END in the security exclusion list

@dmp_regression_integrationtest
@reporting_dmp_interfaces  @eisdev_6387 @eisdev_6771 @eisdev_6904
Feature: This feature is to test the Unlisted securities AML and sanctions screening report

  The purpose of this feature file is to load position data from BRS and generate the AML report with list of issuers.
  Only unlisted security positions should be considered for report generation.
  Security group and type combination to be excluded,
  CASH  | CASH,FXSPOT,FXFWRD,TD,TBILL,COLLATERAL,FXCUROTC,CD,FUTURE,SWAP,CSWAP,CNV_BND,OPTION,CDSWAP
  FUTURE| INDEX,FIN,GENERIC
  SWAP  | CDSWAP,SWAP
  SYNTH | CAP
  FUND  | OPEN_END

  Scenario: TC_1: Create Position file with POS_DATE as SYSDATE and load into DMP

    Given I assign "tests/test-data/dmp-interfaces/Reporting/AMLUnlistedSecReporting" to variable "testdata.path"
    And I assign "PositionFile.xml" to variable "POSITIONS_FILE"
    And I assign "PositionFileTemplate.xml" to variable "POSITIONS_TEMPLATE_FILE"

    And I create input file "${POSITIONS_FILE}" using template "${POSITIONS_TEMPLATE_FILE}" with below codes from location "${testdata.path}/infiles"
      | POS_DATE | DateTimeFormat:M/dd/YYYY |

    And I execute below query to "Clear existing positions and remove funds from ESI-ALL portfolio group"
     """
     ${testdata.path}/sql/SetupData.sql
     """

    When I process "${testdata.path}/infiles/testdata/${POSITIONS_FILE}" file with below parameters
      | BUSINESS_FEED |                               |
      | FILE_PATTERN  | ${POSITIONS_FILE}             |
      | MESSAGE_TYPE  | EIS_MT_BRS_EOD_POSITION_LATAM |

     #This check to verify BALH table MAX(AS_OF_TMS) rowcount with PositionFileLoad.xml file rowcount
    Then I expect value of column "BALH_COUNT" in the below SQL query equals to "14":
     """
     ${testdata.path}/sql/CheckPositionsCount.sql
     """

  Scenario: TC_2: Publish AML report
    Given I assign "WLF_DAILY_ESSG_DMP" to variable "PUBLISHING_FILENAME"
    And I assign "WLF_DAILY_ESSG_DMP" to variable "EXPECTED_FILENAME"
    And I assign "/dmp/out/eis/edm" to variable "PUBLISHING_DIR"
    And I generate value with date format "YYYYMMdd" and assign to variable "VAR_SYSDATE"

    And I remove below files with pattern in the host "dmp.ssh.outbound" from folder "${PUBLISHING_DIR}" if exists:
      | ${PUBLISHING_FILENAME}_*.txt |

    When I process publishing wrapper with below parameters and wait for the job to be completed
      | PUBLISHING_FILE_NAME | ${PUBLISHING_FILENAME}.txt    |
      | SUBSCRIPTION_NAME    | EIS_DMP_TO_EIS_AML_REPORT_SUB |

    Then I expect below files to be present in the host "dmp.ssh.outbound" into folder "${PUBLISHING_DIR}" after processing:
      | ${PUBLISHING_FILENAME}_${VAR_SYSDATE}_1.txt |

    Then I copy files below from remote folder "${PUBLISHING_DIR}" on host "dmp.ssh.outbound" into local folder "${testdata.path}/outfiles/runtime":
      | ${PUBLISHING_FILENAME}_${VAR_SYSDATE}_1.txt |


  Scenario: TC_3: Reconcile generated AML report with expected

    Given I create input file "WLF_DAILY_ESSG_DMP_reference.txt" using template "WLF_DAILY_ESSG_DMP_template.txt" from location "${testdata.path}/outfiles"

    Then I expect reconciliation should be successful between given CSV files including order
      | ActualFile   | ${testdata.path}/outfiles/runtime/${PUBLISHING_FILENAME}_${VAR_SYSDATE}_1.txt |
      | ExpectedFile | ${testdata.path}/outfiles/testdata/WLF_DAILY_ESSG_DMP_reference.txt           |

