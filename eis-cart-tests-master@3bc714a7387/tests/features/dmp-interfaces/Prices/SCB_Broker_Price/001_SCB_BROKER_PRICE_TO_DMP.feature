# =================================================================================================
# Date            JIRA        Comments
# ============    ========    ========
# 22/05/2019      TOM-4642    SCB - Broker Price Automation.
#                             Trasnform price file to XML, load price in DMP and distribute to BRS
# 11/06/2019      TOM-4764    SCB - Broker Price Automation Changes.
#                             Disabled validations and removed the translation
# ==================================================================================================

@gc_interface_prices @gc_interface_excel2csv
@dmp_regression_integrationtest
@tom_4642 @tom_4764 @manual_uploader
Feature: SCB broker price file DMP load and distribute price to BRS

  Scenario: Transform SCB broker price file to XML format

    Given I assign "tests/test-data/dmp-interfaces/Prices/SCB_Broker_Price" to variable "testdata.path"
    And I assign "20190506 Daily Net Asset Value Internal Funds (ESI).xls" to variable "INPUT_FILENAME"
    And I assign "esisg_dmp_scb_broker_price" to variable "TRANSFORMED_FILE_NAME"
    And I generate value with date format "YYYYMMdd" and assign to variable "VAR_SYSDATE"
    And I assign "400" to variable "workflow.max.polling.time"
    And I assign "/dmp/out/eis/edm" to variable "PUBLISHING_DIR"
    And I assign "esi_brs_int_price.csv" to variable "TEMPLATE_FILENAME"

    # Clear data
    Given I execute below query
    """
    ${testdata.path}/sql/clearTestData.sql
    """

    # Delete the output file if it exist
    Given I remove below files in the host "dmp.ssh.inbound" from folder "${PUBLISHING_DIR}" if exists:
      | ${TRANSFORMED_FILE_NAME}_*.xml |

    When I copy files below from local folder "${testdata.path}/infiles" to the host "dmp.ssh.inbound" folder "${dmp.ssh.inbound.path}/scb":
      | ${INPUT_FILENAME} |

    Given I set the workflow template parameter "MESSAGE_TYPE" to "EIS_MT_SCB_BROKER_PRICE"
    And I set the workflow template parameter "INPUT_DATA_DIR" to "${dmp.ssh.inbound.path}/scb"
    And I set the workflow template parameter "FILEPATTERN" to "${INPUT_FILENAME}"
    And I set the workflow template parameter "PARALLELISM" to "1"
    And I set the workflow template parameter "FILE_LOAD_EVENT" to "EIS_StandardFileTransformation"

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
      | MESSAGE_TYPE  | EIS_MT_EDM_SCB_BROKER_PRICE                 |

    Then I extract new job id from jblg table into a variable "JOB_ID"

    Then I expect value of column "SUM_UNIT_CPRC" in the below SQL query equals to "3.533576":
    """
    SELECT SUM(UNIT_CPRC) AS SUM_UNIT_CPRC
    FROM ft_t_ispc
    WHERE  prcng_meth_typ = 'ESIPX   '
     AND prc_qt_meth_typ = 'PRCQUOTE'
     AND prc_srce_typ = 'ESM'
     AND Trunc(prc_tms) in (to_date('22-MAY-2019', 'DD-MON-YYYY'),to_date('25-MAY-2019', 'DD-MON-YYYY'),to_date('10-MAY-2019', 'DD-MON-YYYY'))
     AND prc_typ = 'SODEIS  '
     AND prc_valid_typ = 'CHECKED'
     AND Trunc(adjst_tms) = Trunc(sysdate)
     AND instr_id IN (SELECT instr_id
                      FROM   ft_t_isid
                      WHERE  iss_id IN ( 'HK0274',
                                         'HK0273',
                                         'HK0460' )
                             AND id_ctxt_typ = 'BROKERFUNDCD'
                             AND end_tms IS NULL)
    """

  Scenario: Publish loaded price from DMP to BRS

    Given I assign "/dmp/out/brs/intraday" to variable "BRS_PUBLISHING_DIRECTORY"
    And I assign "esi_brs_int_price" to variable "BRS_PUBLISHING_FILE_NAME"
    And I generate value with date format "hhmmss" and assign to variable "TIMESTAMP"
    And I remove below files in the host "dmp.ssh.inbound" from folder "${BRS_PUBLISHING_DIRECTORY}" if exists:
      | ${BRS_PUBLISHING_FILE_NAME}_${TIMESTAMP}_${VAR_SYSDATE}_1.csv |

    Given I process publishing wrapper with below parameters and wait for the job to be completed
      | PUBLISHING_FILE_NAME | ${BRS_PUBLISHING_FILE_NAME}_${TIMESTAMP}.csv |
      | SUBSCRIPTION_NAME    | EIS_DMP_TO_BRS_SCB_BROKER_PRICE_VIEW_SUB     |

    Then I expect below files to be present in the host "dmp.ssh.inbound" into folder "${BRS_PUBLISHING_DIRECTORY}" after processing:
      | ${BRS_PUBLISHING_FILE_NAME}_${TIMESTAMP}_${VAR_SYSDATE}_1.csv |

    Then I copy files below from remote folder "${BRS_PUBLISHING_DIRECTORY}" on host "dmp.ssh.inbound" into local folder "${testdata.path}/outfiles/runtime":
      | ${BRS_PUBLISHING_FILE_NAME}_${TIMESTAMP}_${VAR_SYSDATE}_1.csv |

    And I expect reconciliation between generated XML file "${testdata.path}/outfiles/runtime/${BRS_PUBLISHING_FILE_NAME}_${TIMESTAMP}_${VAR_SYSDATE}_1.csv" and reference XML file "${testdata.path}/outfiles/reference/${TEMPLATE_FILENAME}" should be successful and exceptions to be written to "${testdata.path}/outfiles/exceptions_${recon.timestamp}.csv" file
