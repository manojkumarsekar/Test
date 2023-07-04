#Feature History
#TOM-3614: New Feature File for the underlying JIRA
#TOM-3768: Moved the feature file from as per new folder structure. Updated Feature Description
#TOM-4353: Ensure only one custodian identifier valid for BNYM
#https://jira.intranet.asia/browse/TOM-4581  (To fix custodian acct number issue)
#TOM-3870 : BNP is delivering Aladdin Portfolio Code through the FOS TRADE RECAP file; so DMP vlookup need to be pointed from "BNP - Hiport Code" in DMP to "Aladdin Port Code".
#EISDEV-6581 : Changing FF to translate DBANKID based on CRTSID

@gc_interface_portfolios @gc_interface_trades
@dmp_regression_integrationtest
@dmp_smoke @inmemorytranslation_wf @tom_3614 @tom_3768 @tom_4132 @tom_4353 @tom_4581 @tom_3870 @tom_4994 @eisdev_6258 @eisdev_6581
Feature: GC Smoke | Orchestrator | ESI | Publishing | In Memory Translation | Standard File Load Transformation

  Perform in-memory translation of BNP Performance Returns file and publish to DB

  Scenario: Providing filename and output directory

    Given I assign "EIM_BNP_TRADE_RECAP_UT_success.csv" to variable "INPUT_FILENAME_1"
    And I assign "EIM_BNP_TRADE_RECAP_Failure.csv" to variable "INPUT_FILENAME_2"
    And I assign "EIM_BNP_TRADE_RECAP_PM_Success.csv" to variable "INPUT_FILENAME_3"
    And I assign "tests/test-data/DevTest/TOM-3614" to variable "testdata.path"
    And I assign "esi_UT_MY_bnp_fos_trade_recap" to variable "OUTPUT_FILENAME_1"
    And I assign "esi_PM_MY_bnp_fos_trade_recap" to variable "OUTPUT_FILENAME_2"
    And I generate value with date format "yyyyMMdd" and assign to variable "VAR_SYSDATE"
    And I assign "/dmp/out/db/eod" to variable "PUBLISHING_DIR"
    And I assign "DMP_R3_PortfolioMasteringTemplate_4.11_EISDEV_6581.xlsx" to variable "PORTFOLIO_TEMPLATE"

    When I copy files below from local folder "${testdata.path}/testdata" to the host "dmp.ssh.inbound" folder "${dmp.ssh.inbound.path}":
      | ${INPUT_FILENAME_1}   |
      | ${INPUT_FILENAME_2}   |
      | ${INPUT_FILENAME_3}   |
      | ${PORTFOLIO_TEMPLATE} |

  Scenario: Load portfolio Template
  Verify Portfolio Template is Successfully Loaded with Success Count 1

    Given I process files with below parameters and wait for the job to be completed
      | BUSINESS_FEED |                                      |
      | FILE_PATTERN  | ${PORTFOLIO_TEMPLATE}                |
      | MESSAGE_TYPE  | EIS_MT_RDM_PORTFOLIO_MASTER_TEMPLATE |

    Then I expect workflow is processed in DMP with total record count as "2"

  Scenario: Transform BNP Performance Returns file to DB format - Missing Madatory Fields

    Given I remove below files in the host "dmp.ssh.inbound" from folder "${PUBLISHING_DIR}" if exists:
      | ${OUTPUT_FILENAME_1}_${VAR_SYSDATE}.csv |
      | ${OUTPUT_FILENAME_2}_${VAR_SYSDATE}.csv |

    And I set the workflow template parameter "FILE" to "${dmp.ssh.inbound.path}/${INPUT_FILENAME_2}"
    And I set the workflow template parameter "MESSAGE_TYPE" to "EIM_MT_BNP_UT_TRADE_RECAP"

   #Mail verification to be done manually
    And I set the workflow template parameter "EMAIL_TO" to "gomathi.sankar.ramakrishnan@eastspring.com"
    And I set the workflow template parameter "EMAIL_SUBJECT" to "TEST SPLIT ORDERS"
    And I set the workflow template parameter "PUBLISH_LOAD_SUMMARY" to "true"
    And I set the workflow template parameter "SUCCESS_ACTION" to "DELETE"
    And I set the workflow template parameter "FILE_PATTERN" to "EIM_BNP_TRADE_RECAP_Failure.csv"
    And I set the workflow template parameter "ATTACHMENT_FILENAME" to "Exceptions.xlsx"
    And I set the workflow template parameter "HEADER" to "Please see the summary of the load below"
    And I set the workflow template parameter "FOOTER" to "DMP Team, Please do not reply to this mail as this is an automated mail service. This e-mail message is only for the use of the intended recipient and may contain information that is privileged and confidential. If you are not the intended recipient, any disclosure, distribution or other use of this e-mail message is prohibited"
    And I set the workflow template parameter "FILE_LOAD_EVENT" to "EIS_StandardFileTransformation"
    And I set the workflow template parameter "EXCEPTION_DETAILS_COUNT" to "10"
    And I set the workflow template parameter "NOOFFILESINPARALLEL" to "1"

    When I send a web service request using template file "tests/test-data/intf-specs/gswf/template/EIS_StandardFileLoadTransformation/request.xmlt" and save the response to file "testout/evidence/gswf/resp/asyncResponse.xml"
    Then I extract a value from the XML file "testout/evidence/gswf/resp/asyncResponse.xml" using XPath query in file "tests/test-data/intf-specs/gswf/template/EIS_StandardFileLoadTransformation/flowResultIdQuery.xpath" to variable "flowResultId"

    Then I poll for maximum 60 seconds and expect the result of the SQL query below equals to "DONE":
      """
      SELECT WF_RUNTIME_STAT_TYP FROM FT_WF_WFRI WHERE INSTANCE_ID='${flowResultId}'
      """

    Then I expect value of column "NTEL_COUNT" in the below SQL query equals to "1":
      """
      SELECT COUNT(*) AS NTEL_COUNT FROM FT_T_NTEL
      WHERE NOTFCN_STAT_TYP = 'OPEN'
      AND NOTFCN_ID = '60001'
      AND APPL_ID = 'TPS'
      AND SOURCE_ID='TRANSLATION'
      AND PART_ID = 'TRANS'
      AND NOTFCN_STAT_TYP='OPEN'
      AND PARM_VAL_TXT LIKE '%User defined Error thrown! . Cannot process record as required fields, ISINCode, Clientportfoliocode, Tradedate, Settlementdate, Realquantity is not present in the input record.%'
      AND LAST_CHG_TRN_ID IN (SELECT TRN_ID FROM FT_T_TRID WHERE JOB_ID IN(SELECT JOB_ID FROM Ft_T_JBLG WHERE INSTANCE_ID='${flowResultId}' ))
      """

  Scenario: Transform BNP Performance Returns file to DB format

    Given I remove below files in the host "dmp.ssh.inbound" from folder "${PUBLISHING_DIR}" if exists:
      | ${OUTPUT_FILENAME_1}_${VAR_SYSDATE}.csv |

    And I set the workflow template parameter "FILE" to "${dmp.ssh.inbound.path}/${INPUT_FILENAME_1}"
    And I set the workflow template parameter "MESSAGE_TYPE" to "EIM_MT_BNP_UT_TRADE_RECAP"

    When I send a web service request using template file "tests/test-data/intf-specs/gswf/template/EIS_StandardFileLoadTransformation/request.xmlt" and save the response to file "testout/evidence/gswf/resp/asyncResponse.xml"
    Then I extract a value from the XML file "testout/evidence/gswf/resp/asyncResponse.xml" using XPath query in file "tests/test-data/intf-specs/gswf/template/EIS_StandardFileLoadTransformation/flowResultIdQuery.xpath" to variable "flowResultId"

    Then I expect below files to be present in the host "dmp.ssh.inbound" into folder "${PUBLISHING_DIR}" after processing:
      | ${OUTPUT_FILENAME_1}_${VAR_SYSDATE}.csv |

    Then I copy files below from remote folder "${PUBLISHING_DIR}" on host "dmp.ssh.inbound" into local folder "${testdata.path}/outfiles":
      | ${OUTPUT_FILENAME_1}_${VAR_SYSDATE}.csv |

  Scenario: Check the details for ISIN in outbound file

    Given I assign "${testdata.path}/outfiles/${OUTPUT_FILENAME_1}_${VAR_SYSDATE}.csv" to variable "CSV_FILE"

    #Check if ISIN LU1118698981 in the outbound
    Given I expect column "ISIN" value to be "LU1118698981" where columns values are as below in CSV file "${CSV_FILE}"
      | RECEIVER BIC                    | DEUMYKL0DFS             |
      | ACTION                          | NEWM                    |
      | CLIENT REFERENCE                | TEST1011CLF2            |
      | PREVIOUS REFERENCE NO.          |                         |
      | TRADE TYPE                      | F                       |
      | TRANSACTION TYPE                | DVP                     |
      | INSTRUMENT TYPE                 | E                       |
      | FA PORTFOLIO CODE               | DBTSTA65811             |
      | SECURITY IDENTIFIER TYPE        | MY_REUTERS              |
      | LOCAL SECURITY CODE             | LU1118698981            |
      | SECURITY DESCRIPTION            | AMUNDI ACTIONS ORIENT C |
      | FA BROKER IDENTIFIER TYPE       | LOCAL_BROKER_CODE       |
      | FA BROKER CODE                  | MY_BK                   |
      | FA COUNTERPARTY IDENTIFIER TYPE | LOCAL_BROKER_CODE       |
      | FA COUNTERPARTY CODE            | MY_BK                   |
      | TRADE DATE                      | 20171110                |
      | SETTLEMENT DATE                 | 20171110                |
      | QUANTITY                        | 602.4390244             |
      | DEAL PRICE CCY                  | USD                     |
      | DEAL PRICE                      | 12.3                    |
      | GROSS AMOUNT                    | 7410                    |
      | ACCRUED INTEREST                | 0                       |
      | SETTLEMENT CCY                  | USD                     |
      | SETTLEMENT AMOUNT               | 7410                    |
      | END OF LINE INDICATOR           | END                     |

  Scenario: Transform BNP Performance Returns file to DB format

    Given I remove below files in the host "dmp.ssh.inbound" from folder "${PUBLISHING_DIR}" if exists:
      | ${OUTPUT_FILENAME_2}_${VAR_SYSDATE}.csv |

    And I set the workflow template parameter "FILE" to "${dmp.ssh.inbound.path}/${INPUT_FILENAME_3}"
    And I set the workflow template parameter "MESSAGE_TYPE" to "EIM_MT_BNP_PM_TRADE_RECAP"

    When I send a web service request using template file "tests/test-data/intf-specs/gswf/template/EIS_StandardFileLoadTransformation/request.xmlt" and save the response to file "testout/evidence/gswf/resp/asyncResponse.xml"
    Then I extract a value from the XML file "testout/evidence/gswf/resp/asyncResponse.xml" using XPath query in file "tests/test-data/intf-specs/gswf/template/EIS_StandardFileLoadTransformation/flowResultIdQuery.xpath" to variable "flowResultId"

    Then I expect below files to be present in the host "dmp.ssh.inbound" into folder "${PUBLISHING_DIR}" after processing:
      | ${OUTPUT_FILENAME_2}_${VAR_SYSDATE}.csv |

    Then I copy files below from remote folder "${PUBLISHING_DIR}" on host "dmp.ssh.inbound" into local folder "${testdata.path}/outfiles":
      | ${OUTPUT_FILENAME_2}_${VAR_SYSDATE}.csv |

  Scenario: Check the details for ISIN in outbound file

    Given I assign "${testdata.path}/outfiles/${OUTPUT_FILENAME_2}_${VAR_SYSDATE}.csv" to variable "CSV_FILE"

    #Check if ISIN LU1118698981 in the outbound
    Given I expect column "ISIN" value to be "LU1118698981" where columns values are as below in CSV file "${CSV_FILE}"
      | RECEIVER BIC                    | DEUMYKL0DFS             |
      | ACTION                          | CANC                    |
      | CLIENT REFERENCE                | TEST1011CLF2            |
      | PREVIOUS REFERENCE NO.          | TEST1011CLF2            |
      | TRADE TYPE                      | F                       |
      | TRANSACTION TYPE                | RVP                     |
      | INSTRUMENT TYPE                 | E                       |
      | FA PORTFOLIO CODE               | DBTSTA65812             |
      | SECURITY IDENTIFIER TYPE        | MY_REUTERS              |
      | LOCAL SECURITY CODE             | LU1118698981            |
      | SECURITY DESCRIPTION            | AMUNDI ACTIONS ORIENT C |
      | FA BROKER IDENTIFIER TYPE       | LOCAL_BROKER_CODE       |
      | FA BROKER CODE                  | MY_BK                   |
      | FA COUNTERPARTY IDENTIFIER TYPE | LOCAL_BROKER_CODE       |
      | FA COUNTERPARTY CODE            | MY_BK                   |
      | TRADE DATE                      | 20171110                |
      | SETTLEMENT DATE                 | 20171110                |
      | QUANTITY                        | 602.4390244             |
      | DEAL PRICE CCY                  | USD                     |
      | DEAL PRICE                      | 12.3                    |
      | GROSS AMOUNT                    | 7410                    |
      | ACCRUED INTEREST                | 0                       |
      | SETTLEMENT CCY                  | USD                     |
      | SETTLEMENT AMOUNT               | 7410                    |
      | END OF LINE INDICATOR           | END                     |