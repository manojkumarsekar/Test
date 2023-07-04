#https://jira.pruconnect.net/browse/EISDEV-5386
#Position Validation or comparison Data report required for SSDR team

#EISDEV-7522: performance tuning

@gc_interface_securities @gc_interface_portfolios @gc_interface_portfolios @eisdev_5386
@dmp_regression_integrationtest
@postn_datareports @dmp_fundapps_functional @dmp_fundapps_regression @eisdev_7522
Feature: 001 | FundApps | Position Validation or comparison (T with T-1) Data report

  The feature file is to compare position between T with T-1 date generate Addition and missing position status.
  Addition : T date has position, T-1 does not have position.
  Missing :  T date does not have position, T-1 has position. Missing Position looks for T date transactions, if it is not available then look for T-1 transaction for Sell Quantity to display  in Transaction Sell

  T-1 Date position file
  Position Date|Security ID   |Fund ID  | Quantity
  T-1          |US29444U7000  |300070   |500          - It should not publish because it fall under Change status as per requirement, we should display only Addition and missing
  T-1          |NL0000009165  |600355   |600          - It should display in Missing status, It helps to validate T-1 position to T date transaction to fetch the Quantity
  T-1          |FR0000130650  |300070   |800          - It should display in Missing status, It helps to validate T-1 position to T-1 date transaction to fetch the Quantity

  T Date position file
  Position Date|Security ID   |Fund ID  | Quantity
  T            |US29444U7000  |300070   |450        - It should not publish because it fall under Change status as per requirement, we should display only Addition and missing
  T            |ZAE000070660  |600355   |700        - It should display in Addition status, It helps to validate one row of T date transaction to fetch the Quantity
  T            |US70450Y1038  |600355   |100        - It should display in Addition status, It helps to validate more then one row of T date transaction to fetch the Quantity
  T            |US98138H1014  |600355   |3712       - It should display in Addition status, It helps to validate no row of T date transaction

  Scenario: Assign Variables and pre-requisites

    Given I assign "tests/test-data/dmp-interfaces/FundApps/Functional/Outbound/DataReport_Position_Validation" to variable "testdata.path"
    And I assign " /dmp/out/eis/datareports" to variable "PUBLISHING_DIRECTORY"

    #Publish filname details
    And I assign "001_SSDR_POSITION_COMPARISON_REPORT" to variable "PUBLISHING_VALIDATION_FILE_NAME"
    And I assign "${PUBLISHING_VALIDATION_FILE_NAME}*_1.csv" to variable "PUBLISHING_VALIDATION_FILE_FULL_NAME"

    #ESGA LBU File
    And I assign "001_ESGA-POSITION_PREVIOUS_DAY.csv" to variable "ESGA_PREV_POS_INPUT_FILENAME"
    And I assign "001_ESGA-POSITION_CURRENT_DAY.csv" to variable "ESGA_CURR_POS_INPUT_FILENAME"
    And I assign "001_ESGA-TRANSACTION_PREVIOUS_DAY_TEMPLATE.csv" to variable "ESGA_PREV_TRANS_INPUT_FILENAME"
    And I assign "001_ESGA-TRANSACTION_CURRENT_DAY_TEMPLATE.csv" to variable "ESGA_CURR_TRANS_INPUT_FILENAME"

    #Generate date
    And I generate value with date format "YYYYMMdd" and assign to variable "VAR_SYSDATE"
    And I modify date "${VAR_SYSDATE}" with "+0d" from source format "YYYYMMdd" to destination format "dd/MM/YYYY" and assign to "CURR_DATE_ESGA_LBU"
    And I modify date "${VAR_SYSDATE}" with "-1d" from source format "YYYYMMdd" to destination format "dd/MM/YYYY" and assign to "PREV_DATE_ESGA_LBU"

    And I execute below query and extract values of "DYNAMIC_DATE" into same variables
     """
     select to_char(max(GREG_DTE),'DD/MM/YYYY') as DYNAMIC_DATE from ft_t_cadp where cal_id = 'PRPTUAL' and GREG_DTE < trunc(sysdate) and BUS_DTE_IND = 'Y' and END_TMS IS NULL
     """

    And I execute below query to clear the Balance history
    """
    ${testdata.path}/sql/Clear_balh.sql
    """

  Scenario: Load ESGA LBU T-1 position file

    Given I create input file "${ESGA_PREV_POS_INPUT_FILENAME}_${VAR_SYSDATE}.csv" using template "001_ESGA-POSITION_PREVIOUS_DAY_TEMPLATE.csv" from location "${testdata.path}/inputfiles"

    When I process "${testdata.path}/inputfiles/testdata/${ESGA_PREV_POS_INPUT_FILENAME}_${VAR_SYSDATE}.csv" file with below parameters
      | FILE_PATTERN  | ${ESGA_PREV_POS_INPUT_FILENAME}_${VAR_SYSDATE}.csv |
      | MESSAGE_TYPE  | EIS_MT_ESGA_DMP_POSITION                           |
      | BUSINESS_FEED |                                                    |

  Scenario: Load ESGA LBU T-1 Transaction file

    Given I create input file "${ESGA_PREV_TRANS_INPUT_FILENAME}_${VAR_SYSDATE}.csv" using template "001_ESGA-TRANSACTION_PREVIOUS_DAY_TEMPLATE.csv" from location "${testdata.path}/inputfiles"

    When I process "${testdata.path}/inputfiles/testdata/${ESGA_PREV_TRANS_INPUT_FILENAME}_${VAR_SYSDATE}.csv" file with below parameters
      | FILE_PATTERN  | ${ESGA_PREV_TRANS_INPUT_FILENAME}_${VAR_SYSDATE}.csv |
      | MESSAGE_TYPE  | EIS_MT_ESGA_DMP_TXN                                  |
      | BUSINESS_FEED |                                                      |

  Scenario: Load ESGA LBU T date position file

    Given I create input file "${ESGA_CURR_POS_INPUT_FILENAME}_${VAR_SYSDATE}.csv" using template "001_ESGA-POSITION_CURRENT_DAY_TEMPLATE.csv" from location "${testdata.path}/inputfiles"

    When I process "${testdata.path}/inputfiles/testdata/${ESGA_CURR_POS_INPUT_FILENAME}_${VAR_SYSDATE}.csv" file with below parameters
      | FILE_PATTERN  | ${ESGA_CURR_POS_INPUT_FILENAME}_${VAR_SYSDATE}.csv |
      | MESSAGE_TYPE  | EIS_MT_ESGA_DMP_POSITION                           |
      | BUSINESS_FEED |                                                    |

  Scenario: Load ESGA LBU T Transaction file

    Given I create input file "${ESGA_CURR_TRANS_INPUT_FILENAME}_${VAR_SYSDATE}.csv" using template "001_ESGA-TRANSACTION_CURRENT_DAY_TEMPLATE.csv" from location "${testdata.path}/inputfiles"

    When I process "${testdata.path}/inputfiles/testdata/${ESGA_CURR_TRANS_INPUT_FILENAME}_${VAR_SYSDATE}.csv" file with below parameters
      | FILE_PATTERN  | ${ESGA_CURR_TRANS_INPUT_FILENAME}_${VAR_SYSDATE}.csv |
      | MESSAGE_TYPE  | EIS_MT_ESGA_DMP_TXN                                  |
      | BUSINESS_FEED |                                                      |

  Scenario: Triggering Publishing for Position Validation or comparison DataReport

    Given I remove below files with pattern in the host "dmp.ssh.inbound" from folder "${PUBLISHING_DIRECTORY}" if exists:
      | ${PUBLISHING_VALIDATION_FILE_NAME}*.csv |

    When I process publishing wrapper with below parameters and wait for the job to be completed
      | PUBLISHING_FILE_NAME | ${PUBLISHING_VALIDATION_FILE_NAME}.csv  |
      | SUBSCRIPTION_NAME    | EIS_DMP_TO_EIS_POS_VALIDATE_DREPORT_SUB |
      | COLUMN_SEPARATOR     | ,                                       |
      | COLUMN_TO_SORT       | 9                                       |
      | PUBLISHING_BULK_SIZE | 2000                                    |

    Then I expect below files to be present in the host "dmp.ssh.inbound" into folder "${PUBLISHING_DIRECTORY}" after processing:
      | ${PUBLISHING_VALIDATION_FILE_FULL_NAME} |

    Then I copy files below from remote folder "${PUBLISHING_DIRECTORY}" on host "dmp.ssh.inbound" into local folder "${testdata.path}/outfiles/runtime":
      | ${PUBLISHING_VALIDATION_FILE_FULL_NAME} |

  Scenario: Reconciling files for Position DataReport Details

    Given I assign "001_SSDR_POSITION_COMPARISON_REPORT_TEMPLATE.csv" to variable "MASTER_FILE"

    Then I expect all records from file1 of type CSV exists in file2
      | File1 | ${testdata.path}/outfiles/${MASTER_FILE}                                                  |
      | File2 | ${testdata.path}/outfiles/runtime/${PUBLISHING_VALIDATION_FILE_NAME}_${VAR_SYSDATE}_1.csv |