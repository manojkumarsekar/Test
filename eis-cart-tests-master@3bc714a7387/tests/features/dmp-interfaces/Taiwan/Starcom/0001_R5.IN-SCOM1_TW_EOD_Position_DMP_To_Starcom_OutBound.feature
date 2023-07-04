#https://collaborate.intranet.asia/pages/viewpage.action?pageId=50469127
#https://jira.intranet.asia/browse/TOM-3972
#TOM-3972 : DMP->Star Compliance TW EOD Positions
#https://jira.intranet.asia/browse/TOM-4638
#EISDEV-6619: Adding NPP positions to the publishing

@gc_interface_positions
@dmp_regression_integrationtest
@dmp_taiwan
@tom_3972 @taiwan_eod_pos_dmp_to_starcom  @tom_4638
@eisdev_6619
Feature: Outbound new cash from DMP to BRS Interface Testing (R5.IN-SCOM1 DMP->STARCOM TW EOD Positions)

  This testcase validate the TW EOD Position file to Starcom

  Below Steps are followed to validate this testing

  1. Load the positions(i.e 9 rows) for funds present in database using the "EIS_MT_BRS_EOD_POSITION_NON_LATAM" Messagetype
  2. Load the positons (i.e 1 row) for funds present in database using the "EIS_MT_BRS_EOD_POSITION_NPP" message type
  3. Generate Position Outbound file to Starcom
  4. Validate file generated only having Taiwan Portfolios excluding the securities with the following security type 'AUT','CFWD','CMD','CURR','FWDB','GIA','LFWD','LOAN','MMDEP','MMDEPI','SCAV','TD','TCP','TREPUR','TTD'
  The position file should include NPP positions as well.

  Scenario: TC_1: Extract Portfolio code and setup variables

    Given I assign "tests/test-data/dmp-interfaces/Taiwan/Starcom" to variable "testdata.path"
    And I assign "400" to variable "workflow.max.polling.time"

    And I execute below query and extract values of "PORTFOLIO_ID_1;PORTFOLIO_ID_2" into same variables
    """
    ${testdata.path}/sql/Select_Portfolio.sql
    """

    And I execute below query to "Clear the position data"
    """
    ${testdata.path}/sql/Clear_TW_EOD_Position_Data.sql
    """

  Scenario: TC_3: Create  Expected Output and Position file with POS_DATE as SYSDATE

    Given I assign "PositionFileLoad_template.xml" to variable "INPUT_TEMPLATENAME"
    And I assign "PositionFileLoad_NPP_template.xml" to variable "INPUT_TEMPLATENAME_NPP"
    And I assign "PositionFileLoad.xml" to variable "INPUT_FILENAME"
    And I assign "PositionFileLoad_NPP.xml" to variable "INPUT_FILENAME_NPP"

    And I create input file "${INPUT_FILENAME}" using template "${INPUT_TEMPLATENAME}" with below codes from location "${testdata.path}/position"
      | POS_DATE | DateTimeFormat:M/dd/YYYY |
    And I create input file "${INPUT_FILENAME_NPP}" using template "${INPUT_TEMPLATENAME_NPP}" with below codes from location "${testdata.path}/position"
      | POS_DATE | DateTimeFormat:M/dd/YYYY |

    And I create input file "Eastspring-COM_TWHoldings_Reference.csv" using template "ExpectedOutput_template.csv" from location "${testdata.path}/position"

  Scenario: TC_4: Load Position data in DMP

    When I process "${testdata.path}/position/testdata/${INPUT_FILENAME}" file with below parameters
      | BUSINESS_FEED |                                   |
      | FILE_PATTERN  | ${INPUT_FILENAME}                 |
      | MESSAGE_TYPE  | EIS_MT_BRS_EOD_POSITION_NON_LATAM |

    And I process "${testdata.path}/position/testdata/${INPUT_FILENAME_NPP}" file with below parameters
      | BUSINESS_FEED |                             |
      | FILE_PATTERN  | ${INPUT_FILENAME_NPP}       |
      | MESSAGE_TYPE  | EIS_MT_BRS_EOD_POSITION_NPP |

  Scenario: TC_5: Triggering Publishing Wrapper Event for CSV file into directory for Starcom Taiwan EOD Position

    Given I assign "Eastspring-COM_TWHoldings" to variable "PUBLISHING_FILE_NAME"
    And I generate value with date format "YYYYMMdd" and assign to variable "VAR_SYSDATE"
    And I assign "/dmp/out/eis/starcom" to variable "PUBLISHING_DIR"

    And I remove below files in the host "dmp.ssh.inbound" from folder "${PUBLISHING_DIR}" if exists:
      | ${PUBLISHING_FILE_NAME}_*.csv |

    When I process publishing wrapper with below parameters and wait for the job to be completed
      | PUBLISHING_FILE_NAME | ${PUBLISHING_FILE_NAME}.csv        |
      | SUBSCRIPTION_NAME    | EIS_DMP_TO_STARCOM_TW_POSITION_SUB |

    Then I expect below files to be present in the host "dmp.ssh.inbound" into folder "${PUBLISHING_DIR}" after processing:
      | ${PUBLISHING_FILE_NAME}_${VAR_SYSDATE}_1.csv |

    Then I copy files below from remote folder "${PUBLISHING_DIR}" on host "dmp.ssh.inbound" into local folder "${testdata.path}/outfiles/actual":
      | ${PUBLISHING_FILE_NAME}_${VAR_SYSDATE}_1.csv |

  Scenario: TC_6: Check if published file contains only the records which were loaded for Taiwan funds and excluding the security's holdings which is of following security type 'AUT','CFWD','CMD','CURR','FWDB','GIA','LFWD','LOAN','MMDEP','MMDEPI','SCAV','TD','TCP','TREPUR','TTD'

    Given I assign "Eastspring-COM_TWHoldings_Reference.csv" to variable "TW_HOLDINGS_MASTER_REFERENCE"
    And I assign "${PUBLISHING_FILE_NAME}_${VAR_SYSDATE}_1.csv" to variable "TW_HOLDINGS_CURR_FILE"

    When I capture current time stamp into variable "recon.timestamp"
    Then I expect each record in file "${testdata.path}/position/testdata/${TW_HOLDINGS_MASTER_REFERENCE}" should exist in file "${testdata.path}/outfiles/actual/${TW_HOLDINGS_CURR_FILE}" and exceptions to be written to "${testdata.path}/outfiles/actual/exceptions_${recon.timestamp}.csv" file
    Then I remove variable "workflow.max.polling.time" from memory


