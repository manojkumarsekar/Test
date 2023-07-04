#https://jira.intranet.asia/browse/EISDEV-6419

# ===================================================================================================================================================================================
# Test Scenarios
# ===================================================================================================================================================================================
# CURRENT VALUATION DATE | CURRENT NAV  | Fund Code         | Use Case               | Translation                      | Load                           | Publish
# ===================================================================================================================================================================================
# 17/8/2020     | 1.14918  | PPDI    | record should publish successfully           | Record should be translated      | No error     | Record should be published
# 17/8/2020     | 1.04996  |         | Missing Fund code                            | Record should not be translated  | Exception Should be Thrown     | Record should not be published
# 17/8/2020     |          | PJVE    | Missing nav                                  | Record should be translated      | Exception Should be Thrown     | Record should not be published
# 17/8/2020     | 1.24589  | PRACTEST| record should not publish                    | Record should be translated      | Exception Should be Thrown     | Record should not be published
# Feature file to test to load data from CITI IF Price and publish data from DMP to BRS.
#https://jira.pruconnect.net/browse/EISDEV-7170
#EXM Rel 6 - Removing scenarios for exception validations with Blank CLIENT_ID

@eisdev_6419 @dmp_interfaces @dmp_regression_integrationtest @dmp_prices @gc_interface_excel2csv @citi_price_internal_fund @manual_uploader @eisdev_7170
Feature: 003 | Price | CITI Broker Price INTERNAL FUNDS | Verify Price Load/Publish

  Scenario: Transform CITI SG broker price file to XML format

    Given I assign "tests/test-data/dmp-interfaces/Prices/CITI_NAV_Broker_Price" to variable "testdata.path"
    And I assign "CITI_IF.xls" to variable "INPUT_FILENAME"
    And I assign "esisg_dmp_citi_broker_price_internalfunds" to variable "TRANSFORMED_FILE_NAME"
    And I generate value with date format "YYYYMMdd" and assign to variable "VAR_SYSDATE"
    And I assign "120" to variable "workflow.max.polling.time"
    And I assign "/dmp/out/eis/edm" to variable "PUBLISHING_DIR"
    And I assign "esi_brs_citi_int_price_if_template.csv" to variable "TEMPLATE_FILENAME"

    # Delete the output file if it exist
    Given I remove below files in the host "dmp.ssh.inbound" from folder "${PUBLISHING_DIR}" if exists:
      | ${TRANSFORMED_FILE_NAME}_*.xml |

    When I copy files below from local folder "${testdata.path}/testdata" to the host "dmp.ssh.inbound" folder "${dmp.ssh.inbound.path}/citi":
      | ${INPUT_FILENAME} |

    Given I assign "tests/test-data/intf-specs/gswf/template/EIS_ConvertXLSXtoCSVandLoad/request.xmlt" to variable "XLSX_TO_CSV_WF"
    And I process the workflow template file "${XLSX_TO_CSV_WF}" with below parameters and wait for the job to be completed
      | MESSAGE_TYPE    | EIS_MT_CITI_BROKER_PRICE_INTERNAL_FUNDS |
      | INPUT_DATA_DIR  | ${dmp.ssh.inbound.path}/citi            |
      | FILEPATTERN     | ${INPUT_FILENAME}                       |
      | PARALLELISM     | 1                                       |
      | FILE_LOAD_EVENT | EIS_StandardFileTransformation          |
      | SUCCESS_ACTION  | LEAVE                                   |

  Scenario: Load resultant price XML file into DMP

    Given I expect below files to be present in the host "dmp.ssh.inbound" into folder "${PUBLISHING_DIR}" after processing:
      | ${TRANSFORMED_FILE_NAME}_${VAR_SYSDATE}.xml |

    When I copy files below from remote folder "${PUBLISHING_DIR}" on host "dmp.ssh.inbound" into local folder "${testdata.path}/outfiles/runtime":
      | ${TRANSFORMED_FILE_NAME}_${VAR_SYSDATE}.xml |

    When I copy files below from local folder "${testdata.path}/outfiles/runtime" to the host "dmp.ssh.inbound" folder "${dmp.ssh.inbound.path}":
      | ${TRANSFORMED_FILE_NAME}_${VAR_SYSDATE}.xml |

    When I process "${testdata.path}/outfiles/runtime/${TRANSFORMED_FILE_NAME}_${VAR_SYSDATE}.xml" file with below parameters
      | BUSINESS_FEED |                                             |
      | FILE_PATTERN  | ${TRANSFORMED_FILE_NAME}_${VAR_SYSDATE}.xml |
      | MESSAGE_TYPE  | EIS_MT_DMP_CITI_BROKER_PRICE                |

    Then I extract new job id from jblg table into a variable "JOB_ID"

  Scenario: Data Verification : Missing NAV

    Given I expect value of column "missing_nav" in the below SQL query equals to "1":
    """
    select count(*) as missing_nav from ft_t_ntel where
    last_chg_trn_id in (select trn_id from ft_t_trid where job_id = '${JOB_ID}' and RECORD_SEQ_NUM = 4)
    and PARM_VAL_TXT = 'User defined Error thrown! . Cannot process file as required fields, PRICE is not present in the input record.'
    """

  Scenario: Publish loaded price from DMP to BRS

    Given I assign "/dmp/out/brs/eod" to variable "BRS_PUBLISHING_DIRECTORY"
    And I assign "esi_brs_citi_int_price" to variable "BRS_PUBLISHING_FILE_NAME"
    And I generate value with date format "hhmmss" and assign to variable "TIMESTAMP"

    And I remove below files in the host "dmp.ssh.inbound" from folder "${BRS_PUBLISHING_DIRECTORY}" if exists:
      | ${BRS_PUBLISHING_FILE_NAME}_*_.csv |

    Given I process publishing wrapper with below parameters and wait for the job to be completed
      | PUBLISHING_FILE_NAME | ${BRS_PUBLISHING_FILE_NAME}_${TIMESTAMP}.csv |
      | SUBSCRIPTION_NAME    | EIS_DMP_TO_BRS_CITI_BROKER_PRC_VIEW_SUB      |

    Then I expect below files to be present in the host "dmp.ssh.inbound" into folder "${BRS_PUBLISHING_DIRECTORY}" after processing:
      | ${BRS_PUBLISHING_FILE_NAME}_${TIMESTAMP}_${VAR_SYSDATE}_1.csv |

    Then I copy files below from remote folder "${BRS_PUBLISHING_DIRECTORY}" on host "dmp.ssh.inbound" into local folder "${testdata.path}/outfiles/runtime":
      | ${BRS_PUBLISHING_FILE_NAME}_${TIMESTAMP}_${VAR_SYSDATE}_1.csv |

    Then I expect reconciliation should be successful between given CSV files
      | ActualFile   | ${testdata.path}/outfiles/runtime/${BRS_PUBLISHING_FILE_NAME}_${TIMESTAMP}_${VAR_SYSDATE}_1.csv |
      | ExpectedFile | ${testdata.path}/outfiles/template/${TEMPLATE_FILENAME}                                         |