#https://jira.intranet.asia/browse/TOM-5099 (To laod NAV for SCB)

# Loading SCB NAV file to store FT_T_ISPC and FT_T_ACCV table.
# four records should be setup in FT_T_ACCV and two records in FT_T_ISPC and error should be throw for 1 record.

@gc_interface_nav @gc_interface_prices
@dmp_taiwan
@dmp_regression_integrationtest
@tom_5099 @exceltocsv
Feature: Loading NAV Price Data to populate FT_T_ISPC and FT_T_ACCV table.if FUND is missing at instrument level then it
  should not throw error. Error should be thrown at portfolio level.

  Scenario: TC_1: Assign Variables and Load file so that FT_T_ACCV and FT_T_ISPC should be setup

    Given I assign "SCB_NAV_TOM-5099_TC_1.xls" to variable "INPUT_FILENAME_1"
    And I assign "SCB_NAV_TOM-5099_TC_2.xls" to variable "INPUT_FILENAME_2"
    And I assign "SCB_NAV_TOM-5099_TC_3.xls" to variable "INPUT_FILENAME_3"
    And I assign "tests/test-data/dmp-interfaces/Taiwan/NAV" to variable "testdata.path"
    And I assign "SCB_NAV_TOM-5099_TC_1" to variable "TRANSFORMED_FILE_NAME_1"
    And I assign "SCB_NAV_TOM-5099_TC_2" to variable "TRANSFORMED_FILE_NAME_2"
    And I assign "SCB_NAV_TOM-5099_TC_3" to variable "TRANSFORMED_FILE_NAME_3"
    And I assign "NAV_TEMPLATE.csv" to variable "OUTPUT_TEMPLATENAME"
    And I generate value with date format "YYYYMMdd" and assign to variable "DYNAMIC_DATE"
    Given I assign "OUTBOUND_NAV_REFERENCE.csv" to variable "OUTPUT_FILENAME"
    And I create input file "${OUTPUT_FILENAME}" using template "${OUTPUT_TEMPLATENAME}" from location "${testdata.path}/outfiles"

    When I copy files below from local folder "${testdata.path}/testdata" to the host "dmp.ssh.inbound" folder "${dmp.ssh.inbound.path}/scb/nav":
      | ${INPUT_FILENAME_1} |

    And I execute below query
    """
    ${testdata.path}/sql/ClearData_SCB_NAV_TOM-5099.sql
    """

    And I execute below query
    """
    ${testdata.path}/sql/Insert_SCB_NAV_TOM-5099.sql
    """


    Given I remove below files in the host "dmp.ssh.inbound" from folder "${dmp.ssh.inbound.path}/scb/nav" if exists:
      | ${TRANSFORMED_FILE_NAME_1}.csv |

    Given I set the workflow template parameter "MESSAGE_TYPE" to "EIM_MT_SCB_DMP_NAV"
    And I set the workflow template parameter "INPUT_DATA_DIR" to "${dmp.ssh.inbound.path}/scb/nav"
    And I set the workflow template parameter "FILEPATTERN" to "${INPUT_FILENAME_1}"
    And I set the workflow template parameter "PARALLELISM" to "1"
    And I set the workflow template parameter "SUCCESS_ACTION" to "LEAVE"
    And I set the workflow template parameter "BUSINESS_FEED" to "EIM_BF_SCB_DMP_NAV"
    And I set the workflow template parameter "OUTPUT_DATA_DIR" to "${dmp.ssh.inbound.path}/scb/nav"

    When I send a web service request using template file "tests/test-data/intf-specs/gswf/template/EIS_ConvertXLSXtoCSVandLoad/request.xmlt" and save the response to file "testout/evidence/gswf/resp/asyncResponse.xml"
    Then I extract a value from the XML file "testout/evidence/gswf/resp/asyncResponse.xml" using XPath query in file "tests/test-data/intf-specs/gswf/template/EIS_ConvertXLSXtoCSVandLoad/flowResultIdQuery.xpath" to variable "flowResultId"

    Then I poll for maximum 120 seconds and expect the result of the SQL query below equals to "DONE":
      """
      SELECT WF_RUNTIME_STAT_TYP FROM FT_WF_WFRI WHERE INSTANCE_ID='${flowResultId}'
      """

    And I expect below files to be archived to the host "dmp.ssh.inbound" into folder "${dmp.ssh.inbound.path}/scb/nav" after processing:
      | ${TRANSFORMED_FILE_NAME_1}.csv |

        #Four rows should be created in FT_T_ACCV
    Then I expect value of column "ID_COUNT_ACCV" in the below SQL query equals to "1":
        """
    SELECT COUNT(*) AS ID_COUNT_ACCV FROM FT_T_ACCV
    WHERE ACCT_ID IN (SELECT ACCT_ID FROM FT_T_ACID WHERE ACCT_ALT_ID ='ADPSMF' AND END_TMS IS NULL)
    AND VALU_CURR_CDE IN (select FUND_CURR_CDE from ft_t_fnch where acct_id in (select acct_id from ft_t_acid where acct_alt_id = 'ADPSMF') and end_tms is null)
    AND VALU_VAL_CAMT='131.4'
    AND DATA_SRC_ID='SCB'
    AND Trunc(valu_adjst_tms) = Trunc(sysdate)
        """
    Then I expect value of column "ID_COUNT_ACCV" in the below SQL query equals to "1":
        """
    SELECT COUNT(*) AS ID_COUNT_ACCV FROM FT_T_ACCV
    WHERE ACCT_ID IN (SELECT ACCT_ID FROM FT_T_ACID WHERE ACCT_ALT_ID ='ADRMF' AND END_TMS IS NULL)
    AND VALU_CURR_CDE IN (select FUND_CURR_CDE from ft_t_fnch where acct_id in (select acct_id from ft_t_acid where acct_alt_id = 'ADRMF') and end_tms is null)
    AND VALU_VAL_CAMT='132.4'
    AND DATA_SRC_ID='SCB'
    AND Trunc(valu_adjst_tms) = Trunc(sysdate)
        """

      #Four rows should be created in FT_T_ISPC
    Then I expect value of column "ID_COUNT_ISPC" in the below SQL query equals to "1":
        """
    SELECT COUNT(*) AS ID_COUNT_ISPC FROM FT_T_ISPC
    WHERE INSTR_ID IN (SELECT INSTR_ID FROM FT_T_ISID WHERE ISS_ID = 'ADPSMF' AND END_TMS IS NULL)
    AND PRCNG_METH_TYP='ESIMYS'
    AND DATA_SRC_ID='SCB'
    AND UNIT_CPRC='1.01'
    AND Trunc(adjst_tms) = Trunc(sysdate)
        """

    Then I expect value of column "ID_COUNT_ISPC" in the below SQL query equals to "1":
        """
    SELECT COUNT(*) AS ID_COUNT_ISPC FROM FT_T_ISPC
    WHERE INSTR_ID IN (SELECT INSTR_ID FROM FT_T_ISID WHERE ISS_ID = 'ADRMF' AND END_TMS IS NULL)
    AND PRCNG_METH_TYP='ESIMYS'
    AND DATA_SRC_ID='SCB'
    AND UNIT_CPRC='1.02'
    AND Trunc(adjst_tms) = Trunc(sysdate)
        """

  Scenario: TC_2: load file for missing BROKERFUNDCDE , FT_T_ACCV should be setup but FT_T_ISCP should not be setup

    Given I remove below files in the host "dmp.ssh.inbound" from folder "${dmp.ssh.inbound.path}/scb/nav" if exists:
      | ${TRANSFORMED_FILE_NAME_2}.csv |
    When I copy files below from local folder "${testdata.path}/testdata" to the host "dmp.ssh.inbound" folder "${dmp.ssh.inbound.path}/scb/nav":
      | ${INPUT_FILENAME_2} |

    Given I set the workflow template parameter "MESSAGE_TYPE" to "EIM_MT_SCB_DMP_NAV"
    And I set the workflow template parameter "INPUT_DATA_DIR" to "${dmp.ssh.inbound.path}/scb/nav"
    And I set the workflow template parameter "FILEPATTERN" to "${INPUT_FILENAME_2}"
    And I set the workflow template parameter "PARALLELISM" to "1"
    And I set the workflow template parameter "SUCCESS_ACTION" to "LEAVE"
    And I set the workflow template parameter "BUSINESS_FEED" to "EIM_BF_SCB_DMP_NAV"
    And I set the workflow template parameter "OUTPUT_DATA_DIR" to "${dmp.ssh.inbound.path}/scb/nav"

    When I send a web service request using template file "tests/test-data/intf-specs/gswf/template/EIS_ConvertXLSXtoCSVandLoad/request.xmlt" and save the response to file "testout/evidence/gswf/resp/asyncResponse.xml"
    Then I extract a value from the XML file "testout/evidence/gswf/resp/asyncResponse.xml" using XPath query in file "tests/test-data/intf-specs/gswf/template/EIS_ConvertXLSXtoCSVandLoad/flowResultIdQuery.xpath" to variable "flowResultId"

    Then I poll for maximum 120 seconds and expect the result of the SQL query below equals to "DONE":
      """
      SELECT WF_RUNTIME_STAT_TYP FROM FT_WF_WFRI WHERE INSTANCE_ID='${flowResultId}'
      """

    And I expect below files to be archived to the host "dmp.ssh.inbound" into folder "${dmp.ssh.inbound.path}/scb/nav" after processing:
      | ${TRANSFORMED_FILE_NAME_2}.csv |


    Then I expect value of column "ID_COUNT_ACCV" in the below SQL query equals to "1":
        """
    SELECT COUNT(*) AS ID_COUNT_ACCV FROM FT_T_ACCV
    WHERE ACCT_ID IN (SELECT ACCT_ID FROM FT_T_ACID WHERE ACCT_ALT_ID ='ADRMFP' AND END_TMS IS NULL)
    AND VALU_CURR_CDE IN (select FUND_CURR_CDE from ft_t_fnch where acct_id in (select acct_id from ft_t_acid where acct_alt_id = 'ADRMFP') and end_tms is null)
    AND VALU_VAL_CAMT='133.4'
    AND DATA_SRC_ID='SCB'
    AND Trunc(valu_adjst_tms) = Trunc(sysdate)
        """
    Then I expect value of column "ID_COUNT_ACCV" in the below SQL query equals to "1":
        """
    SELECT COUNT(*) AS ID_COUNT_ACCV FROM FT_T_ACCV
    WHERE ACCT_ID IN (SELECT ACCT_ID FROM FT_T_ACID WHERE ACCT_ALT_ID ='PMPRCD' AND END_TMS IS NULL)
    AND VALU_CURR_CDE IN (select FUND_CURR_CDE from ft_t_fnch where acct_id in (select acct_id from ft_t_acid where acct_alt_id = 'PMPRCD') and end_tms is null)
    AND VALU_VAL_CAMT='134.4'
    AND DATA_SRC_ID='SCB'
    AND Trunc(valu_adjst_tms) = Trunc(sysdate)
        """

  Scenario: TC_3: Load Files to throw error for missing FUND at portfolio level

    Given I remove below files in the host "dmp.ssh.inbound" from folder "${dmp.ssh.inbound.path}/scb/nav" if exists:
      | ${TRANSFORMED_FILE_NAME_3}.csv |
    When I copy files below from local folder "${testdata.path}/testdata" to the host "dmp.ssh.inbound" folder "${dmp.ssh.inbound.path}/scb/nav":
      | ${INPUT_FILENAME_3} |

    Given I set the workflow template parameter "MESSAGE_TYPE" to "EIM_MT_SCB_DMP_NAV"
    And I set the workflow template parameter "INPUT_DATA_DIR" to "${dmp.ssh.inbound.path}/scb/nav"
    And I set the workflow template parameter "FILEPATTERN" to "${INPUT_FILENAME_3}"
    And I set the workflow template parameter "PARALLELISM" to "1"
    And I set the workflow template parameter "SUCCESS_ACTION" to "LEAVE"
    And I set the workflow template parameter "BUSINESS_FEED" to "EIM_BF_SCB_DMP_NAV"
    And I set the workflow template parameter "OUTPUT_DATA_DIR" to "${dmp.ssh.inbound.path}/scb/nav"

    When I send a web service request using template file "tests/test-data/intf-specs/gswf/template/EIS_ConvertXLSXtoCSVandLoad/request.xmlt" and save the response to file "testout/evidence/gswf/resp/asyncResponse.xml"
    Then I extract a value from the XML file "testout/evidence/gswf/resp/asyncResponse.xml" using XPath query in file "tests/test-data/intf-specs/gswf/template/EIS_ConvertXLSXtoCSVandLoad/flowResultIdQuery.xpath" to variable "flowResultId"

    Then I poll for maximum 120 seconds and expect the result of the SQL query below equals to "DONE":
      """
      SELECT WF_RUNTIME_STAT_TYP FROM FT_WF_WFRI WHERE INSTANCE_ID='${flowResultId}'
      """

    And I expect below files to be archived to the host "dmp.ssh.inbound" into folder "${dmp.ssh.inbound.path}/scb/nav" after processing:
      | ${TRANSFORMED_FILE_NAME_3}.csv |
    Then I extract new job id from jblg table into a variable "JOB_ID"

        # Checking NTEL ,Where FUND_CODE is missing
    Then I expect value of column "ID_COUNT_NTEL" in the below SQL query equals to "1":
        """
    SELECT COUNT(*) AS ID_COUNT_NTEL FROM FT_T_NTEL
    WHERE NOTFCN_ID='26'
    AND NOTFCN_STAT_TYP='OPEN'
    AND PARM_VAL_TXT='SCBFUNDID SGP222 SCB AccountAlternateIdentifier'
    AND LAST_CHG_TRN_ID IN ( SELECT TRN_ID FROM FT_T_TRID WHERE JOB_ID = '${JOB_ID}' AND RECORD_SEQ_NUM='1')
       """

  Scenario: TC_4: Publish NAV files

    Given I assign "eim_dmp_brs_nav" to variable "PUBLISHING_FILE_NAME_1"
    And I generate value with date format "YYYYMMdd" and assign to variable "VAR_SYSDATE"
    And I assign "/dmp/out/brs/eod" to variable "PUBLISHING_DIR"

    And I remove below files in the host "dmp.ssh.inbound" from folder "${PUBLISHING_DIR}" if exists:
      | ${PUBLISHING_FILE_NAME_1}*.csv |

    When I process publishing wrapper with below parameters and wait for the job to be completed
      | PUBLISHING_FILE_NAME | ${PUBLISHING_FILE_NAME_1}.csv                                                                                                                                                     |
      | SUBSCRIPTION_NAME    | EIM_DMP_BRS_SCB_NAV_SUB                                                                                                                                                           |
      | SQL                  | &lt;sql&gt; acct_id in (select acct_id from fT_T_acid where acct_alt_id IN('ADPSMF','ADRMF','ADRMFP','PMPRCD') and ACCT_ID_CTXT_TYP='SCBFUNDID' and end_tms is null) &lt;/sql&gt; |

    Then I expect below files to be present in the host "dmp.ssh.inbound" into folder "${PUBLISHING_DIR}" after processing:
      | ${PUBLISHING_FILE_NAME_1}_${VAR_SYSDATE}_1.csv |

    Then I copy files below from remote folder "${PUBLISHING_DIR}" on host "dmp.ssh.inbound" into local folder "tests/test-data/dmp-interfaces/Taiwan/NAV/outfiles/runtime":
      | ${PUBLISHING_FILE_NAME_1}_${VAR_SYSDATE}_1.csv |

  Scenario: TC_5 :Check if published file contains all the records which were loaded for Fundapps Portfolio data

    Given I assign "OUTBOUND_NAV_REFERENCE.csv" to variable "MASTER_FILE"
    And I assign "${PUBLISHING_FILE_NAME_1}_${VAR_SYSDATE}_1.csv" to variable "OUTPUT_FILE"

    When I capture current time stamp into variable "recon.timestamp"
    Then I expect each record in file "${testdata.path}/outfiles/testdata/${MASTER_FILE}" should exist in file "${testdata.path}/outfiles/runtime/${OUTPUT_FILE}" and exceptions to be written to "${testdata.path}/outfiles/runtime/exceptions_${recon.timestamp}.csv" file

  Scenario: Cleanup max polling time variable
    Then I remove variable "workflow.max.polling.time" from memory

  Scenario: TC_6: Publish Price files

    Given I assign "eim_dmp_brs_price" to variable "PUBLISHING_FILE_NAME_2"
    And I generate value with date format "YYYYMMdd" and assign to variable "VAR_SYSDATE"
    And I assign "/dmp/out/brs/eod" to variable "PUBLISHING_DIR"

    And I remove below files in the host "dmp.ssh.inbound" from folder "${PUBLISHING_DIR}" if exists:
      | ${PUBLISHING_FILE_NAME_2}*.csv |

    When I process publishing wrapper with below parameters and wait for the job to be completed
      | PUBLISHING_FILE_NAME | ${PUBLISHING_FILE_NAME_2}.csv                                  |
      | SUBSCRIPTION_NAME    | EIS_DMP_TO_BRS_PRICE_VIEW_SUB                                  |
      | SQL                  | &lt;sql&gt; TRUNC(PRC1_ADJST_TMS) =TRUNC(SYSDATE) &lt;/sql&gt; |

    Then I expect below files to be present in the host "dmp.ssh.inbound" into folder "${PUBLISHING_DIR}" after processing:
      | ${PUBLISHING_FILE_NAME_2}_${VAR_SYSDATE}_1.csv |

    Then I copy files below from remote folder "${PUBLISHING_DIR}" on host "dmp.ssh.inbound" into local folder "tests/test-data/dmp-interfaces/Taiwan/NAV/outfiles/runtime":
      | ${PUBLISHING_FILE_NAME_2}_${VAR_SYSDATE}_1.csv |

  Scenario: TC_7: Check the PriceRate for PORTFOLIO in Price outbound file

    Given I assign "${testdata.path}/outfiles/runtime/${PUBLISHING_FILE_NAME_2}_${VAR_SYSDATE}_1.csv" to variable "CSV_FILE"

    Given I expect column "PRICE" value to be "1.01" where columns values are as below in CSV file "${CSV_FILE}"
      | DATE      | 20190903     |
      | CLIENT_ID | ESL3565880   |
      | ISIN      | JP1300511G61 |
      | SEDOL     | BD5VSM6      |
      | PURPOSE   | ESIMYS       |
      | SOURCE    | ESMY         |

    Given I expect column "PRICE" value to be "1.02" where columns values are as below in CSV file "${CSV_FILE}"
      | DATE      | 20190903     |
      | CLIENT_ID | ESL1594673   |
      | ISIN      | SG6ZF3000008 |
      | SEDOL     | BYVXCM1      |
      | PURPOSE   | ESIMYS       |
      | SOURCE    | ESMY         |