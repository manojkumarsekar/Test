#https://jira.intranet.asia/browse/TOM-3534 (Load IBPA prices only for securities exist in DMP and ignore others)

@gc_interface_prices
@dmp_regression_integrationtest
@tom_3534 @price_ibpa
Feature: Loading Price file to populate FT_T_ISPC table

  For this testcase we are trying to load PRICE in FT_T_ISPC table and publish the same PRICE.
  PRICE to be stored in Aladdin from IBPA source

  Scenario: TC_1: Load files

    Given I assign "PRICE_IBPA.csv" to variable "INPUT_FILENAME"
    And I assign "tests/test-data/DevTest/TOM-3534" to variable "testdata.path"

    And I execute below query to "Clear data for the given PRICE for FT_T_ISPC Table"
    """
    ${testdata.path}/sql/ClearData_PRICE_IBPA.sql
    """

    When I copy files below from local folder "${testdata.path}/testdata" to the host "dmp.ssh.inbound" folder "${dmp.ssh.inbound.path}":
      | ${INPUT_FILENAME} |

    Given I process files with below parameters and wait for the job to be completed
      | BUSINESS_FEED |                        |
      | FILE_PATTERN  | ${INPUT_FILENAME}      |
      | MESSAGE_TYPE  | ESII_MT_IBPA_DMP_PRICE |

  Scenario: TC_2: Publish NAV files

    Given I assign "esi_price_ibpa" to variable "PUBLISHING_FILE_NAME"
    And I generate value with date format "YYYYMMdd" and assign to variable "VAR_SYSDATE"
    And I assign "/dmp/out/brs/eod" to variable "PUBLISHING_DIR"
    And I remove below files in the host "dmp.ssh.inbound" from folder "${PUBLISHING_DIR}" if exists:
      | ${PUBLISHING_FILE_NAME}_${VAR_SYSDATE}_1.csv |

    When I process publishing wrapper with below parameters and wait for the job to be completed
      | PUBLISHING_FILE_NAME | ${PUBLISHING_FILE_NAME}.csv                                     |
      | SUBSCRIPTION_NAME    | EIS_DMP_TO_BRS_PRICE_VIEW_SUB                                   |
      | SQL                  | &lt;sql&gt; prc1_instr_id in(select instr_id from fT_T_isid where iss_id='SG71E6000003' and end_tms is null) &lt;/sql&gt; |

    Then I expect below files to be present in the host "dmp.ssh.inbound" into folder "${PUBLISHING_DIR}" after processing:
      | ${PUBLISHING_FILE_NAME}_${VAR_SYSDATE}_1.csv |

    Then I copy files below from remote folder "${PUBLISHING_DIR}" on host "dmp.ssh.inbound" into local folder "tests/test-data/DevTest/TOM-3534/outfiles":
      | ${PUBLISHING_FILE_NAME}_${VAR_SYSDATE}_1.csv |

  Scenario: TC_3: Check the price for Instrument in price outbound file

    Given I assign "${testdata.path}/outfiles/${PUBLISHING_FILE_NAME}_${VAR_SYSDATE}_1.csv" to variable "CSV_FILE"

      #Check if ISIN SG71E6000003 has value 100 in the outbound

    Given I expect column "ISIN" value to be "SG71E6000003" where columns values are as below in CSV file "${CSV_FILE}"
      | PRICE    | 100      |
      | PURPOSE  | ESIIDN   |
      | DATE     | 20180711 |
      | CURRENCY | SGD      |
      | SOURCE   | ESIDN    |

  Scenario: TC_4: Check for ISGP

    Then I expect value of column "ID_COUNT" in the below SQL query equals to "1":
      """
      SELECT COUNT(*) AS ID_COUNT FROM FT_T_ISGP
	  WHERE PRNT_ISS_GRP_OID='IBPAPRCSOI'
	  AND INSTR_ID IN (SELECT INSTR_ID FROM FT_T_ISID WHERE ISS_ID ='SG71E6000003')
	  AND END_TMS IS NULL
      """

  Scenario: TC_5: Check filtered rows

    Then I expect value of column "ROW_COUNT" in the below SQL query equals to "1":
      """
      SELECT TASK_FILTERED_CNT ROW_COUNT
      FROM GS_GC.FT_T_JBLG
      WHERE JOB_MSG_TYP = 'ESII_MT_IBPA_DMP_PRICE'
      AND JOB_START_TMS = (SELECT MAX(JOB_START_TMS) FROM  GS_GC.FT_T_JBLG WHERE JOB_MSG_TYP = 'ESII_MT_IBPA_DMP_PRICE')
      """