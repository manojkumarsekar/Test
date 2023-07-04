#https://collaborate.intranet.asia/display/TOMTN/Taiwan+Security+-+BBG+Total+Equity
#https://jira.intranet.asia/browse/TOM-4135

@gc_interface_equity @gc_interface_securities @gc_interface_cdf
@dmp_regression_integrationtest
@dmp_taiwan
@tom_4135 @tw_total_equity_out @outbound_check @tom_4135_out @tw_total_equity @brs_cdf
Feature: This feature is to test outbound for Total Equity

  1. Amounts are getting setup and published for Annual, Semi-Annual & Quarter Total Equity

  Scenario: TC_1: Create Position file with POS_DATE as SYSDATE and Load into DMP

    Given I assign "tc_1_bndtoeqytckr_global.out" to variable "INPUT_FILENAME1"
    And I assign "tc_3_bndtoeqytckr_fundamentls.out" to variable "INPUT_FILENAME2"
    And I assign "tests/test-data/dmp-interfaces/Taiwan/Total_Equity" to variable "testdata.path"

    And I execute below query
    """
    UPDATE ft_t_isid SET end_tms = sysdate-1, start_tms = sysdate-1 WHERE id_ctxt_typ = 'BNDEQYTCKER' AND end_tms is null
    AND instr_id IN (SELECT instr_id FROM ft_t_isid WHERE iss_id IN ('XS1453462076','USG21886AB53') AND end_tms IS NULL)
    """

    And I execute below query
    """
    DELETE FROM FT_T_ISAM WHERE ISS_AMT_TYP IN ('TOTEQYS','TOTEQYQ','TOTEQYA')
    AND END_TMS IS NULL AND INSTR_ID IN (SELECT INSTR_ID FROM FT_T_ISID WHERE
    ISS_ID IN ('XS1453462076','USG21886AB53')
    AND ID_CTXT_TYP IN ('BNDEQYTCKER','BBCPTICK') AND END_TMS IS NULL)
    """

    And I copy files below from local folder "${testdata.path}/testdata" to the host "dmp.ssh.inbound" folder "${dmp.ssh.inbound.path}":
      | ${INPUT_FILENAME1} |
      | ${INPUT_FILENAME2} |

    And I process files with below parameters and wait for the job to be completed
      | BUSINESS_FEED |                                  |
      | FILE_PATTERN  | ${INPUT_FILENAME1}               |
      | MESSAGE_TYPE  | EIS_MT_BBG_SECURITY_PER_SECURITY |

    Then I expect value of column "NTEL_INVALID_COUNT" in the below SQL query equals to "0":
    """
      SELECT COUNT(1) AS NTEL_INVALID_COUNT FROM FT_T_NTEL
      WHERE NOTFCN_STAT_TYP = 'OPEN' AND LAST_CHG_TRN_ID IN
      (SELECT TRN_ID FROM FT_T_TRID WHERE JOB_ID IN
      (SELECT JOB_ID FROM (SELECT JOB_ID, ROW_NUMBER() OVER
      (PARTITION BY JOB_INPUT_TXT ORDER BY JOB_START_TMS DESC) R
      FROM FT_T_JBLG WHERE JOB_INPUT_TXT LIKE '%${INPUT_FILENAME1}')
      WHERE R=1))
    """

    Then I expect value of column "ISID_COUNT" in the below SQL query equals to "2":
    """
      SELECT COUNT(1) AS ISID_COUNT FROM FT_T_ISID WHERE ISS_ID = '823 HK'
      AND ID_CTXT_TYP = 'BNDEQYTCKER' AND END_TMS IS NULL AND INSTR_ID IN (SELECT INSTR_ID FROM FT_T_ISID
      WHERE ISS_ID IN ('XS1453462076','USG21886AB53') AND END_TMS IS NULL)
    """

  Scenario: TC_2: Load fundamental file to check whether ISAM is updated for all securities which have same BOND_TO_EQY_TICKER

    And I process files with below parameters and wait for the job to be completed
      | BUSINESS_FEED |                         |
      | FILE_PATTERN  | ${INPUT_FILENAME2}      |
      | MESSAGE_TYPE  | EIS_MT_BBG_TOTAL_EQUITY |


    Then I expect value of column "ISAM_COUNT" in the below SQL query equals to "4":
    """
      SELECT COUNT(1) AS ISAM_COUNT FROM FT_T_ISAM WHERE INSTR_ID IN (SELECT INSTR_ID
      FROM FT_T_ISID WHERE ISS_ID = '823 HK'
      AND ID_CTXT_TYP = 'BNDEQYTCKER' AND END_TMS IS NULL AND INSTR_ID IN (SELECT INSTR_ID FROM FT_T_ISID
      WHERE ISS_ID IN ('XS1453462076','USG21886AB53') AND END_TMS IS NULL)) AND ISS_AMT_TYP IN ('TOTEQYS','TOTEQYQ','TOTEQYA')
      AND END_TMS IS NULL
    """

  Scenario: Triggering Publishing Wrapper Event for CSV file into directory for BBG total data

    Given I assign "esi_brs_sec_cdf" to variable "PUBLISHING_FILE_NAME"
    And I generate value with date format "YYYYMMdd" and assign to variable "VAR_SYSDATE"
    And I assign "/dmp/out/brs/1a_security" to variable "PUBLISHING_DIR"

    And I remove below files with pattern in the host "dmp.ssh.inbound" from folder "${PUBLISHING_DIR}" if exists:
      | ${PUBLISHING_FILE_NAME}_*.csv |

    When I process publishing wrapper with below parameters and wait for the job to be completed
      | PUBLISHING_FILE_NAME | ${PUBLISHING_FILE_NAME}.csv |
      | SUBSCRIPTION_NAME    | EIS_DMP_TO_BRS_CDF_SUB      |

    Then I expect below files to be present in the host "dmp.ssh.inbound" into folder "${PUBLISHING_DIR}" after processing:
      | ${PUBLISHING_FILE_NAME}_${VAR_SYSDATE}_1.csv |

    Then I copy files below from remote folder "${PUBLISHING_DIR}" on host "dmp.ssh.inbound" into local folder "${testdata.path}/outfiles/actual":
      | ${PUBLISHING_FILE_NAME}_${VAR_SYSDATE}_1.csv |

  Scenario: Check if published file for BBG total contains data for TOTEQYA (Annual Total Equity Amount), TOTEQYS (Semi-Annual Total Equity Amount), TOTEQYQ (Quarterly Total Equity Amount)

    And I expect each record in file "${testdata.path}/outfiles/expected/esi_brs_sec_cdf_expected_TOT_EQUITY_ASQ.csv" should exist in file "${testdata.path}/outfiles/actual/${PUBLISHING_FILE_NAME}_${VAR_SYSDATE}_1.csv" and exceptions to be written to "${testdata.path}/outfiles/runtime/${PUBLISHING_FILE_NAME}_${VAR_SYSDATE}_esi_brs_sec_cdf_expected_EXCEPTION.csv" file