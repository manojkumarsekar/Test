#https://jira.intranet.asia/browse/TOM-4765
#https://jira.intranet.asia/browse/TOM-5339 - Change destination folder for file published for BRS

# ===================================================================================================================================================================================
# Test Scenarios
# ===================================================================================================================================================================================
# CURRENT VALUATION DATE | CURRENT NAV  | Fund Code         | Use Case               | Translation                      | Load                           | Publish
# ===================================================================================================================================================================================
# 25/6/2019     | 10.28   | HK0275 | record should publish successfully           | Record should be translated      | No error     | Record should be published
# 25/6/2019     | 10.28   |        | Missing Fund code      | Record should not be translated  | Exception Should be Thrown    | Record should not be published
# 25/6/2019     |         | HK0275 | Missing nav            | Record should be translated      | Exception Should be Thrown     | Record should not be published

# Feature file to test to load data from CITI and publish data from DMP to BRS.
# EISDEV-6419: Updating message type and some steps to new format
#https://jira.pruconnect.net/browse/EISDEV-7170

@gc_interface_prices @gc_interface_excel2csv
@dmp_regression_integrationtest
@tom_4765 @tom_5339 @citi_price_us @eisdev_6419 @manual_uploader @eisdev_7170
#EXM Rel 6 - Removing scenarios for exception validations with blank CLIENT_ID

Feature: 001 | Price | CITI Broker Price | Verify Price Load/Publish

  Scenario: Transform CITI broker price file to XML format

    Given I assign "tests/test-data/dmp-interfaces/Prices/CITI_NAV_Broker_Price" to variable "testdata.path"
    And I assign "CITI_1.xls" to variable "INPUT_FILENAME"
    And I assign "esisg_dmp_citi_broker_price_us" to variable "TRANSFORMED_FILE_NAME"
    And I generate value with date format "YYYYMMdd" and assign to variable "VAR_SYSDATE"
    And I assign "120" to variable "workflow.max.polling.time"
    And I assign "/dmp/out/eis/edm" to variable "PUBLISHING_DIR"
    And I assign "esi_brs_citi_int_price_template.csv" to variable "TEMPLATE_FILENAME"

    # Delete the output file if it exist
    Given I remove below files in the host "dmp.ssh.inbound" from folder "${PUBLISHING_DIR}" if exists:
      | ${TRANSFORMED_FILE_NAME}_*.xml |

    When I copy files below from local folder "${testdata.path}/testdata" to the host "dmp.ssh.inbound" folder "${dmp.ssh.inbound.path}/citi":
      | ${INPUT_FILENAME} |

    Given I assign "tests/test-data/intf-specs/gswf/template/EIS_ConvertXLSXtoCSVandLoad/request.xmlt" to variable "XLSX_TO_CSV_WF"
    And I process the workflow template file "${XLSX_TO_CSV_WF}" with below parameters and wait for the job to be completed
      | MESSAGE_TYPE    | EIS_MT_CITI_BROKER_PRICE_US    |
      | INPUT_DATA_DIR  | ${dmp.ssh.inbound.path}/citi   |
      | FILEPATTERN     | ${INPUT_FILENAME}              |
      | PARALLELISM     | 1                              |
      | FILE_LOAD_EVENT | EIS_StandardFileTransformation |
      | SUCCESS_ACTION  | LEAVE                          |

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

  Scenario: Data Verification : Valid Record Processing

    Given I expect value of column "VERIFY_ISPC_COUNT_QSLU51347323" in the below SQL query equals to "1":
    """
    SELECT COUNT(*) AS VERIFY_ISPC_COUNT_QSLU51347323
    FROM FT_T_ISPC
    WHERE JOB_ID = '${JOB_ID}'
    AND INSTR_ID IN (SELECT INSTR_ID FROM FT_T_ISID WHERE ISS_ID = 'QSLU51347323')
    AND UNIT_CPRC = '10.2806'
    """

  Scenario: Data Verification : Missing NAV

    Given I expect value of column "missing_nav" in the below SQL query equals to "1":
    """
    select count(*) as missing_nav from ft_t_ntel where
    last_chg_trn_id in (select trn_id from ft_t_trid where job_id = '${JOB_ID}' and RECORD_SEQ_NUM = 3)
    and PARM_VAL_TXT = 'User defined Error thrown! . Cannot process file as required fields, PRICE is not present in the input record.'
    """

    Given I expect value of column "VERIFY_ISPC_COUNT_QSLU51346655" in the below SQL query equals to "1":
    """
    SELECT COUNT(*) AS VERIFY_ISPC_COUNT_QSLU51346655
    FROM FT_T_ISPC
    WHERE JOB_ID = '${JOB_ID}'
    AND INSTR_ID IN (SELECT INSTR_ID FROM FT_T_ISID WHERE ISS_ID = 'QSLU51346655')
    AND UNIT_CPRC = '12.2806'
    """

  Scenario: Publish loaded price from DMP to BRS

    Given I assign "/dmp/out/brs/eod" to variable "BRS_PUBLISHING_DIRECTORY"
    And I assign "esi_brs_citi_int_price" to variable "BRS_PUBLISHING_FILE_NAME"
    And I generate value with date format "hhmmss" and assign to variable "TIMESTAMP"

    And I remove below files in the host "dmp.ssh.inbound" from folder "${BRS_PUBLISHING_DIRECTORY}" if exists:
      | ${BRS_PUBLISHING_FILE_NAME}_*_1.csv |

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