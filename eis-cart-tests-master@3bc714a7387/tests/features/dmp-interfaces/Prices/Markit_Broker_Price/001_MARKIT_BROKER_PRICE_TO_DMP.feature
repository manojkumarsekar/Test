# ===================================================================================================================================================================================
# Date            JIRA        Comments
# ===================================================================================================================================================================================
# 29/07/2019      TOM-4751    Markit - Broker Price Automation. Trasnform price file to XML, load price in DMP and distribute to BRS
# 05/09/2019      TOM-5101   PRC1 view contains the data from multiple SOI. As part of the load the data is loaded into ESIMANOVRD SOI.
#                 Extraction should also be checked against PRC1_GRP_NME = 'ESIMANOVRD'. Updating feature file to extract data for PRC1_GRP_NME = 'ESIMANOVRD'
# ===================================================================================================================================================================================
# Test Scenarios
# ===================================================================================================================================================================================
# valuationdate          | Price        | BOOK         | Use Case               | Translation                      | Load                           | Publish
# ===================================================================================================================================================================================
# 25.07.2019             | 45.26443	    |              | Missing Book           | Record should be filtered        | NA                             | Record should not be published
# 25.07.2019             |              | BPM1CY2CP    | Missing Price          | Record should be translated      | Exception Should be Thrown     | Record should not be published
# 25.07.2019             | 1.015        | ZZ9999005409 | Invalid Book           | Record should be filtered        | NA                             | Record should not be published
# 25.07.2019             | 45.26443     | BES2P9MU8    | Valid Record           | Record should be translated      | Record should be loaded        | Record should be Published
# 25.07.2019             | 245.43       | BPM1CYAER    | Valid Record           | Record should be translated      | Record should be loaded        | Record should be Published

@gc_interface_prices @gc_interface_refresh_soi
@dmp_regression_integrationtest
@tom_3648 @tom_5101 @manual_uploader @eisdev_6891

Feature: 001 | Price | Markit Broker Price | Verify Price Load/Publish

  Scenario: Transform Markit broker price file to XML format

    Given I assign "tests/test-data/dmp-interfaces/Prices/Markit_Broker_Price" to variable "testdata.path"
    And I assign "EastSpring_SG_Nextday.csv" to variable "INPUT_FILENAME"
    And I assign "esisg_dmp_markit_broker_price" to variable "TRANSFORMED_FILE_NAME"
    And I generate value with date format "YYYYMMdd" and assign to variable "VAR_SYSDATE"
    And I assign "/dmp/out/eis/edm" to variable "PUBLISHING_DIR"
    And I assign "esi_brs_markit_price_template.csv" to variable "TEMPLATE_FILENAME"

    # Delete the output file if it exist
    Given I remove below files in the host "dmp.ssh.inbound" from folder "${PUBLISHING_DIR}" if exists:
      | ${TRANSFORMED_FILE_NAME}_*.xml |

    When I copy files below from local folder "${testdata.path}/testdata" to the host "dmp.ssh.inbound" folder "${dmp.ssh.inbound.path}/markit":
      | ${INPUT_FILENAME} |


   # Transform File
    When I set the workflow template parameter "FILE" to "${dmp.ssh.inbound.path}/markit/${INPUT_FILENAME}"
    And I set the workflow template parameter "MESSAGE_TYPE" to "EIS_MT_MARKIT_BROKER_PRICE"

    When I send a web service request using template file "tests/test-data/intf-specs/gswf/template/EIS_StandardFileLoadTransformation/request.xmlt" and save the response to file "testout/evidence/gswf/resp/asyncResponse.xml"
    Then I extract a value from the XML file "testout/evidence/gswf/resp/asyncResponse.xml" using XPath query in file "tests/test-data/intf-specs/gswf/template/EIS_StandardFileLoadTransformation/flowResultIdQuery.xpath" to variable "flowResultId"

    Then I poll for maximum 120 seconds and expect the result of the SQL query below equals to "DONE":
      """
      SELECT WF_RUNTIME_STAT_TYP FROM FT_WF_WFRI WHERE INSTANCE_ID='${flowResultId}'
      """

    Then I execute below query and extract values of "JOB_ID" into same variables
      """
        SELECT job_id AS JOB_ID
        FROM ft_t_jblg
        WHERE INSTANCE_ID='${flowResultId}'
      """

  Scenario: Data Verification : Missing Book

    Given I expect value of column "filter_count" in the below SQL query equals to "2":
    """
    select count(*) as filter_count from ft_t_trid where job_id = '${JOB_ID}' and RECORD_SEQ_NUM in (1,3) and TRN_USR_STAT_TYP = 'FILTERED'
    """


  Scenario: Load resultant price XML file into DMP

    Given I expect below files to be present in the host "dmp.ssh.inbound" into folder "${PUBLISHING_DIR}" after processing:
      | ${TRANSFORMED_FILE_NAME}_${VAR_SYSDATE}.xml |

    When I copy file "${PUBLISHING_DIR}/${TRANSFORMED_FILE_NAME}_${VAR_SYSDATE}.xml" as "${dmp.ssh.inbound.path}/${TRANSFORMED_FILE_NAME}_${VAR_SYSDATE}.xml" in the named host "dmp.ssh.inbound"

    When I process files with below parameters and wait for the job to be completed
      | BUSINESS_FEED |                                             |
      | FILE_PATTERN  | ${TRANSFORMED_FILE_NAME}_${VAR_SYSDATE}.xml |
      | MESSAGE_TYPE  | EIS_MT_DMP_MARKIT_BROKER_PRICE              |

    Then I extract new job id from jblg table into a variable "JOB_ID"


  Scenario: Data Verification : Missing Price

    Given I expect value of column "missing_price" in the below SQL query equals to "1":
    """
    select count(*) as missing_price from ft_t_ntel where
    last_chg_trn_id in (select trn_id from ft_t_trid where job_id = '${JOB_ID}' and RECORD_SEQ_NUM = 1)
    and NOTFCN_ID = 60001
    and PARM_VAL_TXT = 'User defined Error thrown! . Cannot process file as required fields, PRICE is not present in the input record.'
    """

  Scenario: Data Verification : Valid Record Processing

    Given I expect value of column "VERIFY_ISPC_COUNT_BES2P9MU8" in the below SQL query equals to "1":
    """
    SELECT COUNT(*) AS VERIFY_ISPC_COUNT_BES2P9MU8
    FROM FT_T_ISPC
    WHERE JOB_ID = '${JOB_ID}'
    AND INSTR_ID IN (SELECT INSTR_ID FROM FT_T_ISID WHERE ISS_ID = 'BES2P9MU8')
    AND UNIT_CPRC = '45.26443'
    """

    Then I expect value of column "VERIFY_ISPC_COUNT_BPM1CYAER" in the below SQL query equals to "1":
    """
    SELECT COUNT(*) AS VERIFY_ISPC_COUNT_BPM1CYAER
    FROM FT_T_ISPC
    WHERE JOB_ID = '${JOB_ID}'
    AND INSTR_ID IN (SELECT INSTR_ID FROM FT_T_ISID WHERE ISS_ID = 'BPM1CYAER')
    AND UNIT_CPRC = '245.43'
    """

  Scenario: Publish loaded price from DMP to BRS

    Given I assign "/dmp/out/brs/eod" to variable "BRS_PUBLISHING_DIRECTORY"
    And I assign "esi_brs_GS_price_0730" to variable "BRS_PUBLISHING_FILE_NAME"
    And I generate value with date format "hhmmss" and assign to variable "TIMESTAMP"

    And I remove below files in the host "dmp.ssh.inbound" from folder "${BRS_PUBLISHING_DIRECTORY}" if exists:
      | ${BRS_PUBLISHING_FILE_NAME}*.csv |

    Given I process publishing wrapper with below parameters and wait for the job to be completed
      | PUBLISHING_FILE_NAME | ${BRS_PUBLISHING_FILE_NAME}_${TIMESTAMP}.csv                                                   |
      | SUBSCRIPTION_NAME    | EIS_DMP_TO_BRS_PRICE_VIEW_SUB                                                                  |
      | SQL                  | <![CDATA[<sql>TRUNC(PRC1_ADJST_TMS) = TRUNC(sysdate) and PRC1_GRP_NME = 'ESIMANOVRD' </sql>]]> |

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