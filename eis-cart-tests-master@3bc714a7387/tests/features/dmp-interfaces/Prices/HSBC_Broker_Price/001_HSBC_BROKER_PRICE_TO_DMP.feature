# ===================================================================================================================================================================================
# Date            JIRA        Comments
# ===================================================================================================================================================================================
# 22/05/2019      TOM-4751    HSBC - Broker Price Automation. Trasnform price file to XML, load price in DMP and distribute to BRS
# ===================================================================================================================================================================================
# Test Scenarios
# ===================================================================================================================================================================================
# CURRENT VALUATION DATE | CURRENT NAV  | ISIN         | Use Case               | Translation                      | Load                           | Publish
# ===================================================================================================================================================================================
#                        |              |              | First Record is Blank  | Record should not be translated  | Record should not be loaded    | Record should not be published
# 17-May-19              | 13772.000    |              | Missing ISIN           | Record should be translated      | Exception Should be Thrown     | Record should not be published
#                        |              |              | Record is Blank        | Record should not be translated  | Record should not be loaded    | Record should not be published
#                        | 1.030        | SGXZ87526794 | Missing Price Date     | Record should be translated      | Exception Should be Thrown     | Record should not be published
# 20-May-19              |              | SG9999012165 | Missing NAV            | Record should be translated      | Exception Should be Thrown     | Record should not be published
# 17-May-19              | 1.015        | ZZ9999005409 | Invalid ISIN           | Record should be translated      | Exception Should be Thrown     | Record should not be published
# 17-May-19              | 1.231        | SG9999008742 | Valid Record           | Record should be translated      | Record should be loaded        | Record should be Published
# 17-May-19              | 1.044        | XS1467374473 | Valid Record           | Record should be translated      | Record should be loaded        | Record should be Published
#                        |              |              | Last Record is Blank   | Record should not be translated  | Record should not be loaded    | Record should not be published
#https://jira.pruconnect.net/browse/EISDEV-7170
#EXM Rel 6 - Removing scenarios for exception validations with Blank CLIENT_ID

@gc_interface_prices @gc_interface_excel2csv
@dmp_regression_integrationtest
@tom_4751 @manual_uploader @eisdev_7170
Feature: 001 | Price | HSBC Broker Price | Verify Price Load/Publish

  Scenario: Transform HSBC broker price file to XML format

    Given I assign "tests/test-data/dmp-interfaces/Prices/HSBC_Broker_Price" to variable "testdata.path"
    And I assign "EASTSPRING INVESTMENTS FUND PRICE VARIANCE - 20190517.xls" to variable "INPUT_FILENAME"
    And I assign "esisg_dmp_hsbc_broker_price" to variable "TRANSFORMED_FILE_NAME"
    And I generate value with date format "YYYYMMdd" and assign to variable "VAR_SYSDATE"
    And I assign "400" to variable "workflow.max.polling.time"
    And I assign "/dmp/out/eis/edm" to variable "PUBLISHING_DIR"
    And I assign "esi_brs_hsbc_int_price_template.csv" to variable "TEMPLATE_FILENAME"

    # Delete the output file if it exist
    Given I remove below files in the host "dmp.ssh.inbound" from folder "${PUBLISHING_DIR}" if exists:
      | ${TRANSFORMED_FILE_NAME}_*.xml |

    When I copy files below from local folder "${testdata.path}/testdata" to the host "dmp.ssh.inbound" folder "${dmp.ssh.inbound.path}/hsbc":
      | ${INPUT_FILENAME} |

    Given I set the workflow template parameter "MESSAGE_TYPE" to "EIS_MT_HSBC_BROKER_PRICE"
    And I set the workflow template parameter "INPUT_DATA_DIR" to "${dmp.ssh.inbound.path}/hsbc"
    And I set the workflow template parameter "FILEPATTERN" to "${INPUT_FILENAME}"
    And I set the workflow template parameter "PARALLELISM" to "1"
    And I set the workflow template parameter "FILE_LOAD_EVENT" to "EIS_StandardFileTransformation"
    And I set the workflow template parameter "SUCCESS_ACTION" to "LEAVE"

    When I send a web service request using template file "tests/test-data/intf-specs/gswf/template/EIS_ConvertXLSXtoCSVandLoad/request.xmlt" and save the response to file "testout/evidence/gswf/resp/asyncResponse.xml"
    Then I extract a value from the XML file "testout/evidence/gswf/resp/asyncResponse.xml" using XPath query in file "tests/test-data/intf-specs/gswf/template/EIS_ConvertXLSXtoCSVandLoad/flowResultIdQuery.xpath" to variable "flowResultId"

    Then I poll for maximum 120 seconds and expect the result of the SQL query below equals to "DONE":
      """
      SELECT WF_RUNTIME_STAT_TYP FROM FT_WF_WFRI WHERE INSTANCE_ID='${flowResultId}'
      """

  Scenario: Load resultant price XML file into DMP

    Given I expect below files to be present in the host "dmp.ssh.inbound" into folder "${PUBLISHING_DIR}" after processing:
      | ${TRANSFORMED_FILE_NAME}_${VAR_SYSDATE}.xml |

    When I copy files below from remote folder "${PUBLISHING_DIR}" on host "dmp.ssh.inbound" into local folder "${testdata.path}/outfiles/runtime":
      | ${TRANSFORMED_FILE_NAME}_${VAR_SYSDATE}.xml |

    When I copy files below from local folder "${testdata.path}/outfiles/runtime" to the host "dmp.ssh.inbound" folder "${dmp.ssh.inbound.path}":
      | ${TRANSFORMED_FILE_NAME}_${VAR_SYSDATE}.xml |

    When I process files with below parameters and wait for the job to be completed
      | BUSINESS_FEED |                                             |
      | FILE_PATTERN  | ${TRANSFORMED_FILE_NAME}_${VAR_SYSDATE}.xml |
      | MESSAGE_TYPE  | EIS_MT_DMP_HSBC_BROKER_PRICE                |

    Then I extract new job id from jblg table into a variable "JOB_ID"

  Scenario: Data Verification : Missing Price Date

   Given I expect value of column "missing_price_date" in the below SQL query equals to "1":
    """
    select count(*) as missing_price_date from ft_t_ntel where
    last_chg_trn_id in (select trn_id from ft_t_trid where job_id = '${JOB_ID}' and RECORD_SEQ_NUM = 2)
    and PARM_VAL_TXT = 'User defined Error thrown! . Cannot process record as fields, Price Date are not valid in the input record.'
    """

  Scenario: Data Verification : Missing NAV

   Given I expect value of column "missing_nav" in the below SQL query equals to "1":
    """
    select count(*) as missing_nav from ft_t_ntel where
    last_chg_trn_id in (select trn_id from ft_t_trid where job_id = '${JOB_ID}' and RECORD_SEQ_NUM = 3)
    and PARM_VAL_TXT = 'User defined Error thrown! . Cannot process file as required fields, PRICE is not present in the input record.'
    """

  Scenario: Data Verification : Valid Record Processing

    Given I expect value of column "VERIFY_ISPC_COUNT_SG9999008742" in the below SQL query equals to "1":
    """
    SELECT COUNT(*) AS VERIFY_ISPC_COUNT_SG9999008742
    FROM FT_T_ISPC
    WHERE JOB_ID = '${JOB_ID}'
    AND INSTR_ID IN (SELECT INSTR_ID FROM FT_T_ISID WHERE ISS_ID = 'SG9999008742')
    AND UNIT_CPRC = '1.231'
    """

    Then I expect value of column "VERIFY_ISPC_COUNT_XS1467374473" in the below SQL query equals to "1":
    """
    SELECT COUNT(*) AS VERIFY_ISPC_COUNT_XS1467374473
    FROM FT_T_ISPC
    WHERE JOB_ID = '${JOB_ID}'
    AND INSTR_ID IN (SELECT INSTR_ID FROM FT_T_ISID WHERE ISS_ID = 'XS1467374473')
    AND UNIT_CPRC = '1.044'
    """

  Scenario: Publish loaded price from DMP to BRS

    Given I assign "/dmp/out/brs/intraday" to variable "BRS_PUBLISHING_DIRECTORY"
    And I assign "esi_brs_hsbc_int_price" to variable "BRS_PUBLISHING_FILE_NAME"
    And I generate value with date format "hhmmss" and assign to variable "TIMESTAMP"

    And I remove below files in the host "dmp.ssh.inbound" from folder "${BRS_PUBLISHING_DIRECTORY}" if exists:
      | ${BRS_PUBLISHING_FILE_NAME}_${TIMESTAMP}_${VAR_SYSDATE}_1.csv |

    Given I process publishing wrapper with below parameters and wait for the job to be completed
      | PUBLISHING_FILE_NAME | ${BRS_PUBLISHING_FILE_NAME}_${TIMESTAMP}.csv |
      | SUBSCRIPTION_NAME    | EIS_DMP_TO_BRS_HSBC_BROKER_PRC_VIEW_SUB     |

    Then I expect below files to be present in the host "dmp.ssh.inbound" into folder "${BRS_PUBLISHING_DIRECTORY}" after processing:
      | ${BRS_PUBLISHING_FILE_NAME}_${TIMESTAMP}_${VAR_SYSDATE}_1.csv |

    Then I copy files below from remote folder "${BRS_PUBLISHING_DIRECTORY}" on host "dmp.ssh.inbound" into local folder "${testdata.path}/outfiles/runtime":
      | ${BRS_PUBLISHING_FILE_NAME}_${TIMESTAMP}_${VAR_SYSDATE}_1.csv |

    And I expect reconciliation between generated XML file "${testdata.path}/outfiles/runtime/${BRS_PUBLISHING_FILE_NAME}_${TIMESTAMP}_${VAR_SYSDATE}_1.csv" and reference XML file "${testdata.path}/outfiles/template/${TEMPLATE_FILENAME}" should be successful and exceptions to be written to "${testdata.path}/outfiles/exceptions_${recon.timestamp}.csv" file