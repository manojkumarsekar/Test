#https://collaborate.intranet.asia/pages/viewpage.action?pageId=42009388
#https://jira.intranet.asia/browse/TOM-3334
#https://jira.intranet.asia/browse/TOM-3621 - As part of this ticket MAX(AS_OF_TMS) removed because business user needs the historical data

@gc_interface_positions @gc_interface_refresh_soi @gc_interface_ice @gc_interface_prices
@dmp_regression_integrationtest
@tom_3334 @tom_3621 @dmp_ice @dmp_ice_price_outbound
Feature: To load response file from ICE BPAM, publish Price file and check if BPAM price is getting published in the output file

  Scenario: TC_1: Create Position file with POS_DATE as SYSDATE and Load into DMP

    Given I assign "PositionFileLoad_Template.xml" to variable "INPUT_POS_TEMPLATENAME"
    And I assign "PositionFileLoad.xml" to variable "INPUT_POS_FILENAME"
    And I assign "tests/test-data/DevTest/TOM-3334" to variable "testdata.path"

    And I create input file "${INPUT_POS_FILENAME}" using template "${INPUT_POS_TEMPLATENAME}" with below codes from location "${testdata.path}/positions"
      | POS_DATE | DateTimeFormat:M/dd/YYYY |

    When I copy files below from local folder "${testdata.path}/positions/testdata" to the host "dmp.ssh.inbound" folder "${dmp.ssh.inbound.path}":
      | ${INPUT_POS_FILENAME} |

    When I process files with below parameters and wait for the job to be completed
      | BUSINESS_FEED |                               |
      | FILE_PATTERN  | ${INPUT_POS_FILENAME}         |
      | MESSAGE_TYPE  | EIS_MT_BRS_EOD_POSITION_LATAM |

     #This check to verify BALH table rowcount WITH PositionFileLoad.xml file rowcount
    Then I expect value of column "BALH_COUNT" in the below SQL query equals to "10":
     """
     SELECT count(distinct ISID.ISS_ID) AS BALH_COUNT
     FROM   FT_T_BALH BALH, FT_T_ISID ISID
     WHERE  BALH.INSTR_ID = ISID.INSTR_ID
     AND    ISID.ISS_ID LIKE 'MY%'
     AND    ISID.ID_CTXT_TYP = 'ISIN'
     AND    ISID.ISS_ID IN ('MYBGO1500046','MYBGL1300690','MYBGX1500062','MYBVL1701664','MYBVN1202818','MYBMX1100044','MYBUI1700474','MYBUN1700482','MYBVN1801346','MYBUI1500767')
     AND    ISID.END_TMS IS NULL
     AND    ISID.ISS_ID IS NOT NULL
     AND    BALH.RQSTR_ID = 'BRSEOD'
     """

  Scenario: TC_2: Create ICE Price file with PRICE_DATE as SYSDATE and Load into DMP

    Given I assign "ICEBPAM_ESI_PRICE_REF_OUTBOUND_MASTER.csv" to variable "INPUT_PRICE_TEMPLATENAME"
    And I assign "ICEBPAM_ESI_PRICE_REF_OUTBOUND.csv" to variable "INPUT_PRICE_FILENAME"

    And I create input file "${INPUT_PRICE_FILENAME}" using template "${INPUT_PRICE_TEMPLATENAME}" with below codes from location "${testdata.path}/price"
      | PRICE_DATE | DateTimeFormat:YYYYMMdd |

    When I copy files below from local folder "${testdata.path}/price/testdata" to the host "dmp.ssh.inbound" folder "${dmp.ssh.inbound.path}":
      | ${INPUT_PRICE_FILENAME} |

    When I process RefreshSOI workflow with below parameters and wait for the job to be completed
      | GROUP_NAME   | BPAMPSRSOI               |
      | NO_OF_BRANCH | 10                       |
      | QUERY_NAME   | EIS_REFRESH_BPAM_PSR_SOI |

    When I process files with below parameters and wait for the job to be completed
      | BUSINESS_FEED |                         |
      | FILE_PATTERN  | ${INPUT_PRICE_FILENAME} |
      | MESSAGE_TYPE  | EIM_MT_ICE_REFDATA      |

  Scenario: TC_3: Triggering Publishing Wrapper Event for CSV file into directory for BPAM Price

    Given I assign "esi_brs_p_price" to variable "PUBLISHING_FILE_NAME"
    And I generate value with date format "YYYYMMdd" and assign to variable "VAR_SYSDATE"
    And I assign "/dmp/out/brs/eod" to variable "PUBLISHING_DIR"

    And I remove below files with pattern in the host "dmp.ssh.inbound" from folder "${PUBLISHING_DIR}" if exists:
      | ${PUBLISHING_FILE_NAME}_*.csv |

    When I process publishing wrapper with below parameters and wait for the job to be completed
      | PUBLISHING_FILE_NAME | ${PUBLISHING_FILE_NAME}.csv                                     |
      | SUBSCRIPTION_NAME    | EIS_DMP_TO_BRS_PRICE_VIEW_SUB                                   |
      | SQL                  | &lt;sql&gt; TRUNC(PRC1_ADJST_TMS) =TRUNC(SYSDATE ) &lt;/sql&gt; |

    Then I expect below files to be present in the host "dmp.ssh.inbound" into folder "${PUBLISHING_DIR}" after processing:
      | ${PUBLISHING_FILE_NAME}_${VAR_SYSDATE}_1.csv |

    Then I copy files below from remote folder "${PUBLISHING_DIR}" on host "dmp.ssh.inbound" into local folder "${testdata.path}/outfiles/actual":
      | ${PUBLISHING_FILE_NAME}_${VAR_SYSDATE}_1.csv |

  Scenario: TC_4: Check if published file contains all the records which were loaded for BPAM Price

    Given I assign "ICE_BPAM_PRICE_MASTER_TEMPLATE.csv" to variable "INPUT_TEMPLATENAME"
    And I assign "ICE_BPAM_PRICE_MASTER.csv" to variable "PRICE_MASTER_FILENAME"
    And I assign "${PUBLISHING_FILE_NAME}_${VAR_SYSDATE}_1.csv" to variable "PRICE_CURR_FILE"

    And I create input file "${PRICE_MASTER_FILENAME}" using template "${INPUT_TEMPLATENAME}" with below codes from location "${testdata.path}/outfiles/expected"
      | POS_DATE | DateTimeFormat:YYYYMMdd |

    When I capture current time stamp into variable "recon.timestamp"
    Then I expect each record in file "${testdata.path}/outfiles/expected/testdata/${PRICE_MASTER_FILENAME}" should exist in file "${testdata.path}/outfiles/actual/${PRICE_CURR_FILE}" and exceptions to be written to "${testdata.path}/outfiles/actual/exceptions_${recon.timestamp}.csv" file