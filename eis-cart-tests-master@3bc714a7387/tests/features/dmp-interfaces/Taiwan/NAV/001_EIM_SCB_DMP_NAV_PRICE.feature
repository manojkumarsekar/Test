#https://jira.intranet.asia/browse/TOM-4916 (To laod NAV for SCB)

# Loading SCB NAV file to store FT_T_ISPC table

@gc_interface_nav @gc_interface_prices
@dmp_regression_integrationtest
@dmp_taiwan
@tom_4905 @tom_5040 @tom_4916 @tom_5042 @exceltocsv
Feature: Loading NAV Price Data to populate FT_T_ISPC table

  Checking FT_T_ISPC and FT_T_ISGP

  Scenario: TC_1: Assign Variables

    Given I assign "SCB_NAV_TOM_4905.xls" to variable "INPUT_FILENAME_1"
    And I assign "SCB_NAV_MISSING_TOM_4905.xls" to variable "INPUT_FILENAME_2"
    And I assign "SCB_NET_NAV_MISSING_TOM_4905.xls" to variable "INPUT_FILENAME_3"
    And I assign "SCB_NAV_DATE_MISSING_TOM_4905.xls" to variable "INPUT_FILENAME_4"
    And I assign "SCB_NAV_TOM_4905" to variable "TRANSFORMED_FILE_NAME_1"
    And I assign "SCB_NAV_MISSING_TOM_4905" to variable "TRANSFORMED_FILE_NAME_2"
    And I assign "SCB_NET_NAV_MISSING_TOM_4905" to variable "TRANSFORMED_FILE_NAME_3"
    And I assign "SCB_NAV_DATE_MISSING_TOM_4905" to variable "TRANSFORMED_FILE_NAME_4"
    And I assign "tests/test-data/dmp-interfaces/Taiwan/NAV" to variable "testdata.path"

    When I copy files below from local folder "${testdata.path}/testdata" to the host "dmp.ssh.inbound" folder "${dmp.ssh.inbound.path}/scb/nav":
      | ${INPUT_FILENAME_4} |

    And I execute below query
    """
    ${testdata.path}/sql/ClearData_SCB_NAV.sql
    """

    Given I remove below files in the host "dmp.ssh.inbound" from folder "${dmp.ssh.inbound.path}/scb/nav" if exists:
      | ${TRANSFORMED_FILE_NAME_4}.csv |

    Given I set the workflow template parameter "MESSAGE_TYPE" to "EIM_MT_SCB_DMP_NAV"
    And I set the workflow template parameter "INPUT_DATA_DIR" to "${dmp.ssh.inbound.path}/scb/nav"
    And I set the workflow template parameter "FILEPATTERN" to "${INPUT_FILENAME_4}"
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
      | ${TRANSFORMED_FILE_NAME_4}.csv |

    Then I extract new job id from jblg table into a variable "JOB_ID"

        # Checking NTEL ,Where FUND_CODE is missing
    Then I expect value of column "ID_COUNT_NTEL" in the below SQL query equals to "1":
    """
    SELECT COUNT(*) AS ID_COUNT_NTEL FROM FT_T_NTEL
    WHERE NOTFCN_ID='60001'
    AND NOTFCN_STAT_TYP='OPEN'
    AND PARM_VAL_TXT='User defined Error thrown! . Cannot process file as required fields, NAV_DATE is not present in the input record.'
    AND LAST_CHG_TRN_ID IN ( SELECT TRN_ID FROM FT_T_TRID WHERE JOB_ID = '${JOB_ID}')
    """

  Scenario: TC_2: Load Files

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

    Then I extract new job id from jblg table into a variable "JOB_ID"

        # Checking NTEL ,Where FUND_CODE is missing
    Then I expect value of column "ID_COUNT_NTEL" in the below SQL query equals to "1":
    """
    SELECT COUNT(*) AS ID_COUNT_NTEL FROM FT_T_NTEL
    WHERE NOTFCN_ID='60001'
    AND NOTFCN_STAT_TYP='OPEN'
    AND PARM_VAL_TXT='User defined Error thrown! . Cannot process file as required fields, FUND_CODE is not present in the input record.'
    AND LAST_CHG_TRN_ID IN ( SELECT TRN_ID FROM FT_T_TRID WHERE JOB_ID = '${JOB_ID}')
    """

  Scenario: TC_3: Load Files

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
    WHERE NOTFCN_ID='60001'
    AND NOTFCN_STAT_TYP='OPEN'
    AND PARM_VAL_TXT='User defined Error thrown! . Cannot process file as required fields, NET_NAV is not present in the input record.'
    AND LAST_CHG_TRN_ID IN ( SELECT TRN_ID FROM FT_T_TRID WHERE JOB_ID = '${JOB_ID}')
    """

  Scenario: TC_4: Load Files

    Given I remove below files in the host "dmp.ssh.inbound" from folder "${dmp.ssh.inbound.path}/scb/nav" if exists:
      | ${TRANSFORMED_FILE_NAME_1}.csv |
    When I copy files below from local folder "${testdata.path}/testdata" to the host "dmp.ssh.inbound" folder "${dmp.ssh.inbound.path}/scb/nav":
      | ${INPUT_FILENAME_1} |

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

    # Checking ACCV
    Then I expect value of column "ID_COUNT_ACCV" in the below SQL query equals to "1":
    """
    SELECT COUNT(*) AS ID_COUNT_ACCV FROM FT_T_ACCV
    WHERE ACCT_ID IN (SELECT ACCT_ID FROM FT_T_ACID WHERE ACCT_ALT_ID = 'PBTDB' AND END_TMS IS NULL)
    AND VALU_CURR_CDE IN (select FUND_CURR_CDE from ft_t_fnch where acct_id in (select acct_id from ft_t_acid where acct_alt_id = 'PBTDB') and end_tms is null)
    AND VALU_VAL_CAMT='132764637.4'
    AND DATA_SRC_ID='SCB'
    AND Trunc(valu_adjst_tms) = Trunc(sysdate)
    """

    Then I expect value of column "ID_COUNT_ISPC" in the below SQL query equals to "1":
    """
    SELECT COUNT(*) AS ID_COUNT_ISPC FROM FT_T_ISPC
    WHERE INSTR_ID IN (SELECT INSTR_ID FROM FT_T_ISID WHERE ISS_ID = 'PBTDB' AND END_TMS IS NULL)
    AND PRCNG_METH_TYP='ESIMYS'
    AND DATA_SRC_ID='SCB'
    AND UNIT_CPRC='3.88'
    AND Trunc(adjst_tms) = Trunc(sysdate)
    """

        # Checking ISGP
    Then I expect value of column "ID_COUNT_ISGP" in the below SQL query equals to "1":
    """
    SELECT COUNT(*) AS ID_COUNT_ISGP FROM FT_T_ISGP
    WHERE INSTR_ID IN (SELECT INSTR_ID FROM FT_T_ISID WHERE ISS_ID = 'PBTDB' AND END_TMS IS NULL)
    AND PRT_PURP_TYP='MEMBER'
    AND DATA_STAT_TYP='ACTIVE'
    AND DATA_SRC_ID='SCB'
    """

  Scenario: TC_6: Publish NAV files

    Given I assign "eim_dmp_brs_nav" to variable "PUBLISHING_FILE_NAME_1"
    And I generate value with date format "YYYYMMdd" and assign to variable "VAR_SYSDATE"
    And I assign "/dmp/out/brs/eod" to variable "PUBLISHING_DIR"

    And I remove below files in the host "dmp.ssh.inbound" from folder "${PUBLISHING_DIR}" if exists:
      | ${PUBLISHING_FILE_NAME_1}*.csv |

    When I process publishing wrapper with below parameters and wait for the job to be completed
      | PUBLISHING_FILE_NAME | ${PUBLISHING_FILE_NAME_1}.csv                                                                                                                           |
      | SUBSCRIPTION_NAME    | EIM_DMP_BRS_SCB_NAV_SUB                                                                                                                                 |
      | SQL                  | &lt;sql&gt; acct_id in (select acct_id from fT_T_acid where acct_alt_id in ('PBTDB') and ACCT_ID_CTXT_TYP='SCBFUNDID' and end_tms is null) &lt;/sql&gt; |

    Then I expect below files to be present in the host "dmp.ssh.inbound" into folder "${PUBLISHING_DIR}" after processing:
      | ${PUBLISHING_FILE_NAME_1}_${VAR_SYSDATE}_1.csv |

    Then I copy files below from remote folder "${PUBLISHING_DIR}" on host "dmp.ssh.inbound" into local folder "tests/test-data/dmp-interfaces/Taiwan/NAV":
      | ${PUBLISHING_FILE_NAME_1}_${VAR_SYSDATE}_1.csv |

  Scenario: TC_7: Check the NavRate for PORTFOLIO in NAV outbound file

    Given I execute below query and extract values of "FUND_CURR_CDE" into same variables
    """
    select FUND_CURR_CDE from ft_t_fnch where acct_id in (select acct_id from ft_t_acid where acct_alt_id = 'PBTDB') and end_tms is null
    """

    Given I assign "${testdata.path}/${PUBLISHING_FILE_NAME_1}_${VAR_SYSDATE}_1.csv" to variable "CSV_FILE"

    #Check if PORTFOLIO MLTDED has value 132764637.4 in the outbound
    Given I expect column "VALUE" value to be "132764637.4" where columns values are as below in CSV file "${CSV_FILE}"
      | DATE           | 20190617         |
      | DATATYPE       | ABOR_COMPL       |
      | PORTFOLIO      | MLTLTDB          |
      | VALUE          | 132764637.4      |
      | CURRENCY       | ${FUND_CURR_CDE} |
      | DATA_ASOF_DATE | ${VAR_SYSDATE}   |
      | DATA_SOURCE    | SCB              |
      | LOAD_TYPE      | NAVS             |

  Scenario: TC_8: Publish Price files

    Given I assign "eim_dmp_brs_price" to variable "PUBLISHING_FILE_NAME_2"
    And I generate value with date format "YYYYMMdd" and assign to variable "VAR_SYSDATE"
    And I assign "/dmp/out/brs/eod" to variable "PUBLISHING_DIR"

    And I remove below files in the host "dmp.ssh.inbound" from folder "${PUBLISHING_DIR}" if exists:
      | ${PUBLISHING_FILE_NAME_2}_${VAR_SYSDATE}_1.csv |

    When I process publishing wrapper with below parameters and wait for the job to be completed
      | PUBLISHING_FILE_NAME | ${PUBLISHING_FILE_NAME_2}.csv                                  |
      | SUBSCRIPTION_NAME    | EIS_DMP_TO_BRS_PRICE_VIEW_SUB                                  |
      | SQL                  | &lt;sql&gt; TRUNC(PRC1_ADJST_TMS) =TRUNC(SYSDATE) &lt;/sql&gt; |

    Then I expect below files to be present in the host "dmp.ssh.inbound" into folder "${PUBLISHING_DIR}" after processing:
      | ${PUBLISHING_FILE_NAME_2}_${VAR_SYSDATE}_1.csv |

    Then I copy files below from remote folder "${PUBLISHING_DIR}" on host "dmp.ssh.inbound" into local folder "tests/test-data/dmp-interfaces/Taiwan/NAV":
      | ${PUBLISHING_FILE_NAME_2}_${VAR_SYSDATE}_1.csv |

  Scenario: TC_9: Check the PriceRate for PORTFOLIO in Price outbound file

    Given I assign "${testdata.path}/${PUBLISHING_FILE_NAME_2}_${VAR_SYSDATE}_1.csv" to variable "CSV_FILE"

    Given I expect column "PRICE" value to be "3.88" where columns values are as below in CSV file "${CSV_FILE}"
      | DATE      | 20190617     |
      | PRICE     | 3.88         |
      | CLIENT_ID | ESL2363971   |
      | ISIN      | MYU940000CC3 |
      | SEDOL     | BHJVX92      |
      | PURPOSE   | ESIMYS       |
      | SOURCE    | ESMY         |