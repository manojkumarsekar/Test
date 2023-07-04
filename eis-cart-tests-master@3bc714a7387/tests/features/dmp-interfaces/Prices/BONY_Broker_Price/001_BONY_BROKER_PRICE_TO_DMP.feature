# ===================================================================================================================================================================================
# Date            JIRA        Comments
# ===================================================================================================================================================================================
# 31/07/2019      TOM-3644    BONY - Broker Price Automation. Trasnform price file to XML, load price in DMP and distribute to BRS
# ===================================================================================================================================================================================
# Test Scenarios
# ===================================================================================================================================================================================
# CURRENT VALUATION DATE | CURRENT NAV  | ISIN         | Use Case               | Translation                      | Load                           | Publish
# ===================================================================================================================================================================================
# 02/07/2019	         | 14.992	    |              | Missing ISIN           | Record should be translated      | Exception Should be Thrown     | Record should not be published
#                        | 9.927	    | LU0560538919 | Missing Price Date     | Record should be translated      | Exception Should be Thrown     | Record should not be published
# 02/07/2019	         |              | LU0238923246 | Missing NAV            | Record should be translated      | Exception Should be Thrown     | Record should not be published
# 02/07/2019	         | 20.134	    | ZZ9999005409 | Invalid ISIN           | Record should be translated      | Exception Should be Thrown     | Record should not be published
# 02/07/2019	         | 10.665       | LU0428352776 | Valid Record           | Record should be translated      | Record should be loaded        | Record should be Published
# 02/07/2019	         | 24.875	    | LU0205653495 | Valid Record           | Record should be translated      | Record should be loaded        | Record should be Published


# ===================================================================================================================================================================================
# 25/11/2019      TOM-5050    https://jira.pruconnect.net/browse/EISDEV-5050
# ===================================================================================================================================================================================
# Test Scenarios
# ===================================================================================================================================================================================
# CURRENT VALUATION DATE | CURRENT NAV  | ISIN         | Use Case               | Translation                      | Load                           | Publish
# ===================================================================================================================================================================================
# 02/07/2019	         | 14.992	    |              | Missing ISIN           | Record should be translated      | Exception Should be Thrown     | Record should not be published
# 02/07/2019	         | 20.134	    | ZZ9999005409 | Invalid ISIN           | Record should be translated      | Exception Should be Thrown     | Record should not be published

# https://jira.pruconnect.net/browse/EISDEV-5050
# Commented as this not required because Invalid ISIN got filterd out

@gc_interface_prices @gc_interface_refresh_soi @gc_interface_excel2csv
@dmp_regression_integrationtest
@tom_3644 @tom_5050 @manual_uploader
Feature: 001 | Price | BONY Broker Price | Verify Price Load/Publish

  Scenario: Transform BONY broker price file to XML format

    Given I assign "tests/test-data/dmp-interfaces/Prices/BONY_Broker_Price" to variable "testdata.path"
    And I assign "PRU_FTP_PRU_TEST.XLS" to variable "INPUT_FILENAME"
    And I assign "esisg_dmp_bony_broker_price" to variable "TRANSFORMED_FILE_NAME"
    And I generate value with date format "YYYYMMdd" and assign to variable "VAR_SYSDATE"
    And I assign "esi_brs_bony_price_template.csv" to variable "TEMPLATE_FILENAME"
    And I assign "/dmp/out/eis/edm/" to variable "PUBLISHING_DIR"

    # Delete the output file if it exist
    Given I remove below files in the host "dmp.ssh.inbound" from folder "${PUBLISHING_DIR}" if exists:
      | ${TRANSFORMED_FILE_NAME}_*.xml |

    When I copy files below from local folder "${testdata.path}/testdata" to the host "dmp.ssh.inbound" folder "${dmp.ssh.inbound.path}/bony":
      | ${INPUT_FILENAME} |

    Given I set the workflow template parameter "MESSAGE_TYPE" to "EIS_MT_BONY_BROKER_PRICE"
    And I set the workflow template parameter "INPUT_DATA_DIR" to "${dmp.ssh.inbound.path}/bony"
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

    When I copy file "${PUBLISHING_DIR}/${TRANSFORMED_FILE_NAME}_${VAR_SYSDATE}.xml" as "${dmp.ssh.inbound.path}/${TRANSFORMED_FILE_NAME}_${VAR_SYSDATE}.xml" in the named host "dmp.ssh.inbound"

    When I process files with below parameters and wait for the job to be completed
      | BUSINESS_FEED |                                             |
      | FILE_PATTERN  | ${TRANSFORMED_FILE_NAME}_${VAR_SYSDATE}.xml |
      | MESSAGE_TYPE  | EIS_MT_DMP_BONY_BROKER_PRICE                |

    Then I extract new job id from jblg table into a variable "JOB_ID"

  Scenario: Data Verification : Missing ISIN

    Given I expect value of column "missing_isin" in the below SQL query equals to "1":
    """
    select count(*) as missing_isin from ft_t_ntel where
    last_chg_trn_id in (select trn_id from ft_t_trid where job_id = '${JOB_ID}' and RECORD_SEQ_NUM = 1)
    and PARM_VAL_TXT = 'User defined Error thrown! . Cannot process record as fields, EISLSTID/BCUSIP are not valid in the input record.'
    """

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

# Commented as this not required because Invalid ISIN got filterd out
#  Scenario: Data Verification : Invalid ISIN
#
#    Given I expect value of column "invalid_isin" in the below SQL query equals to "1":
#    """
#    select count(*) as invalid_isin from ft_t_ntel where
#    last_chg_trn_id in (select trn_id from ft_t_trid where job_id = '${JOB_ID}' and RECORD_SEQ_NUM = 4)
#    and PARM_VAL_TXT = 'User defined Error thrown! . Cannot process record as fields, EISLSTID/BCUSIP are not valid in the input record.'
#    """

  Scenario: Data Verification : Valid Record Processing

    Given I expect value of column "VERIFY_ISPC_COUNT_LU0428352776" in the below SQL query equals to "1":
    """
    SELECT COUNT(*) AS VERIFY_ISPC_COUNT_LU0428352776
    FROM FT_T_ISPC
    WHERE JOB_ID = '${JOB_ID}'
    AND INSTR_ID IN (SELECT INSTR_ID FROM FT_T_ISID WHERE ISS_ID = 'LU0428352776')
    AND UNIT_CPRC = '10.665'
    """

    Then I expect value of column "VERIFY_ISPC_COUNT_LU0205653495" in the below SQL query equals to "1":
    """
    SELECT COUNT(*) AS VERIFY_ISPC_COUNT_LU0205653495
    FROM FT_T_ISPC
    WHERE JOB_ID = '${JOB_ID}'
    AND INSTR_ID IN (SELECT INSTR_ID FROM FT_T_ISID WHERE ISS_ID = 'LU0205653495')
    AND UNIT_CPRC = '24.875'
    """

  Scenario: Publish loaded price from DMP to BRS

    Given I assign "/dmp/out/brs/eod" to variable "BRS_PUBLISHING_DIRECTORY"
    And I assign "esi_brs_GS_price_0730" to variable "BRS_PUBLISHING_FILE_NAME"
    And I generate value with date format "hhmmss" and assign to variable "TIMESTAMP"

    And I remove below files in the host "dmp.ssh.inbound" from folder "${BRS_PUBLISHING_DIRECTORY}" if exists:
      | ${BRS_PUBLISHING_FILE_NAME}_${TIMESTAMP}_${VAR_SYSDATE}_1.csv |

    Given I process publishing wrapper with below parameters and wait for the job to be completed
      | PUBLISHING_FILE_NAME | ${BRS_PUBLISHING_FILE_NAME}_${TIMESTAMP}.csv                                                        |
      | SUBSCRIPTION_NAME    | EIS_DMP_TO_BRS_PRICE_VIEW_SUB                                                                   |
      | SQL                  | <![CDATA[<sql>TRUNC(PRC1_ADJST_TMS) = TRUNC(sysdate) and PRC1_GRP_NME != 'INTMANOVRD' </sql>]]> |

    Then I expect below files to be present in the host "dmp.ssh.inbound" into folder "${BRS_PUBLISHING_DIRECTORY}" after processing:
      | ${BRS_PUBLISHING_FILE_NAME}_${TIMESTAMP}_${VAR_SYSDATE}_1.csv |

    Then I copy files below from remote folder "${BRS_PUBLISHING_DIRECTORY}" on host "dmp.ssh.inbound" into local folder "${testdata.path}/outfiles/runtime":
      | ${BRS_PUBLISHING_FILE_NAME}_${TIMESTAMP}_${VAR_SYSDATE}_1.csv |

    Then I expect each record in file "${testdata.path}/outfiles/template/${TEMPLATE_FILENAME}" should exist in file "${testdata.path}/outfiles/runtime/${BRS_PUBLISHING_FILE_NAME}_${TIMESTAMP}_${VAR_SYSDATE}_1.csv" and exceptions to be written to "${TESTDATA_PATH}/outfiles/005_exceptions_${recon.timestamp}.csv" file

  Scenario: Refresh SOI
    Given I set the workflow template parameter "GROUP_NAME" to "ESIMANOVRD"
    And I set the workflow template parameter "NO_OF_BRANCH" to "5"
    And I set the workflow template parameter "QUERY_NAME" to "EIS_REFRESH_MANUAL_PRICE_SOI"

    When I send a web service request using template file "tests/test-data/intf-specs/gswf/template/EIS_RefreshSOI/request.xmlt" and save the response to file "testout/evidence/gswf/resp/asyncResponse.xml"
    Then I extract a value from the XML file "testout/evidence/gswf/resp/asyncResponse.xml" using XPath query in file "tests/test-data/intf-specs/gswf/template/EIS_RefreshSOI/flowResultIdQuery.xpath" to variable "flowResultId"

    Then I poll for maximum 600 seconds and expect the result of the SQL query below equals to "DONE":
        """
        SELECT WF_RUNTIME_STAT_TYP FROM FT_WF_WFRI WHERE INSTANCE_ID='${flowResultId}'
        """

    Then I pause for 30 seconds

  #Verify Data:
    Then I expect value of column "PRICE_COUNT_POST_REFRESH" in the below SQL query equals to "0":
    """
    SELECT COUNT(*) AS PRICE_COUNT_POST_REFRESH
    FROM FT_V_PRC1
    WHERE TRUNC(PRC1_ADJST_TMS) = TRUNC(SYSDATE) AND PRC1_GRP_NME ='ESIMANOVRD'
    """