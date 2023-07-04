# ===================================================================================================================================================================================
# Date            JIRA        Comments
# ===================================================================================================================================================================================
# 31/Oct/2019     TOM-5228    Sourcing Unlisted Warrant Price
# ===================================================================================================================================================================================
#FS: https://collaborate.intranet.asia/display/TOM/Unlisted+Warrant+Pricing?src=jira
# EISDEV-7120 In order to speed up the execution time of golden price calculation, added the instruments and set RUNPVCFORPRVI as "False" part of parameters

@gc_interface_prices @gc_interface_securities @eisdev_7120
@dmp_regression_integrationtest
@eisdev_5228 @eisdev_5228_bb @pvc @derive_unlisted_warrant_price
Feature: Derive Overlying Unlisted Warrant Price

  Load BRS File 10 to load strike price for overlying security
  Load price file(response) from Bloomberg which would create ISPC for underlying securities
  Overlying price is calculated using below logic and loaded in DMP which would then be published to BRS

  Scenario: TC1: Load Security Master F10 file with <STRIKE> labels and with valid values

    Given I assign "001_Security_Master_Strike_Price.xml" to variable "SECURITY_INPUT_FILENAME"
    And I assign "tests/test-data/dmp-interfaces/Prices/BB_Unlisted_Warrant_Price" to variable "testdata.path"

    When I copy files below from local folder "${testdata.path}/testdata" to the host "dmp.ssh.inbound" folder "${dmp.ssh.inbound.path}":
      | ${SECURITY_INPUT_FILENAME} |

    Given I process files with below parameters and wait for the job to be completed
      | BUSINESS_FEED |                            |
      | FILE_PATTERN  | ${SECURITY_INPUT_FILENAME} |
      | MESSAGE_TYPE  | EIS_MT_BRS_SECURITY_NEW    |

    Then I expect workflow is processed in DMP with total record count as "2"

    And I expect value of column "STRKE_CPRC_CNT" in the below SQL query equals to "1":
    """
    SELECT COUNT(*) AS STRKE_CPRC_CNT FROM ft_t_ench
    WHERE end_tms IS NULL
    AND entlmnt_typ = 'WARRANT'
    AND strke_cprc = 16.9
    AND instr_id IN
    (
      SELECT instr_id FROM ft_t_isid
      WHERE id_ctxt_typ = 'BCUSIP'
      AND iss_id = 'BES2XRRY6'
      AND end_tms IS NULL
    )
    """

  Scenario: TC2: Set variables and run cleardown script

    Given I assign "gs_price.out" to variable "INPUT_FILENAME"
    And I generate value with date format "YYYYMMdd" and assign to variable "PRC_TMS"

    And I create input file "${INPUT_FILENAME}" using template "gs_price_template.out" from location "${testdata.path}"
    When I copy files below from local folder "${testdata.path}/testdata" to the host "dmp.ssh.inbound" folder "${dmp.ssh.inbound.path}":
      | ${INPUT_FILENAME} |

    When I execute below query to "Clear data for BES2XRRY6 and SBTKFJD34 security from FT_T_ISPC and insert ISGP for overlying group"
    """
    ${testdata.path}/sql/ClearDataSetup.sql
    """

    Then I expect value of column "PRICE_COUNT" in the below SQL query equals to "0":
    """
    SELECT Count(1) PRICE_COUNT
    FROM   gs_gc.ft_t_ispc
    WHERE  last_chg_tms > Trunc(sysdate)
    AND instr_id IN
    (SELECT instr_id
    FROM   gs_gc.ft_t_isid
    WHERE  iss_id  ='SBTKFJD34'
           AND id_ctxt_typ = 'BCUSIP'
           AND end_tms IS NULL)
    """

    And I process files with below parameters and wait for the job to be completed
      | BUSINESS_FEED |                                  |
      | FILE_PATTERN  | ${INPUT_FILENAME}                |
      | MESSAGE_TYPE  | EIS_MT_BBG_SECURITY_PER_SECURITY |

  Scenario: Verification of FT_T_ISPC table to check all the prices for underlying got loaded

    Then I expect value of column "PRICE_COUNT" in the below SQL query equals to "7":
    """
    SELECT Count(1) PRICE_COUNT
    FROM   gs_gc.ft_t_ispc
    WHERE  last_chg_tms > Trunc(sysdate)
    AND instr_id IN
    (SELECT instr_id
    FROM   gs_gc.ft_t_isid
    WHERE  iss_id ='SBTKFJD34'
           AND id_ctxt_typ = 'BCUSIP'
           AND end_tms IS NULL)
    """

  Scenario: TC3: Process Golden Price Calculation Workflow

    Given I generate value with date format "yyyyMMdd" and assign to variable "PRC_TMS"
    And I process Goldenprice calculation with below parameters and wait for the job to be completed
      | PROCESSING_DATE           | ${PRC_TMS}          |
      | RUN_THAI_PRICE_DERIVATION | false               |
      | RUN_FAIR_VALUE_DERIVATION | false               |
      | RUNPVCFORPRVI             | false               |
      | INSTRUMENTS               | BES2XRRY6,SBTKFJD34 |


  Scenario: Verification of FT_T_ISPC table overlying price is derived

    Then I expect value of column "PRICE_COUNT" in the below SQL query equals to "1":
    """
    SELECT Count(1) PRICE_COUNT
    FROM   gs_gc.ft_t_ispc
    WHERE  last_chg_tms > Trunc(sysdate)
    and PRC_TYP = 'DERIVE'
    AND UNIT_CPRC = 0.2
    AND instr_id IN
    (SELECT instr_id
    FROM   gs_gc.ft_t_isid
    WHERE  iss_id ='BES2XRRY6'
           AND id_ctxt_typ = 'BCUSIP'
           AND end_tms IS NULL)
    """

  Scenario: TC4: Triggering Publishing Wrapper Event for CSV file into directory for Price

    Given I assign "esi_brs_p_price" to variable "PUBLISHING_FILE_NAME"
    And I generate value with date format "YYYYMMdd" and assign to variable "VAR_SYSDATE"
    And I assign "/dmp/out/brs/eod" to variable "PUBLISHING_DIR"
    And I assign "esi_brs_p_price_template.csv" to variable "TEMPLATE_FILE"
    And I assign "esi_brs_p_price_expected.csv" to variable "EXPECTED_FILE"
    And I create input file "${EXPECTED_FILE}" using template "${TEMPLATE_FILE}" from location "${testdata.path}"

    And I remove below files with pattern in the host "dmp.ssh.inbound" from folder "${PUBLISHING_DIR}" if exists:
      | ${PUBLISHING_FILE_NAME}_*.csv |

    When I process publishing wrapper with below parameters and wait for the job to be completed
      | PUBLISHING_FILE_NAME | ${PUBLISHING_FILE_NAME}.csv                                                                                                                                                                     |
      | SUBSCRIPTION_NAME    | EIS_DMP_TO_BRS_PRICE_VIEW_SUB                                                                                                                                                                   |
      | SQL                  | &lt;sql&gt; TRUNC(PRC1_ADJST_TMS) =TRUNC(SYSDATE ) AND prc1_instr_id IN (SELECT instr_id FROM ft_t_isid WHERE iss_id  ='BES2XRRY6' AND id_ctxt_typ = 'BCUSIP' AND end_tms IS NULL) &lt;/sql&gt; |

    Then I expect below files to be present in the host "dmp.ssh.inbound" into folder "${PUBLISHING_DIR}" after processing:
      | ${PUBLISHING_FILE_NAME}_${VAR_SYSDATE}_1.csv |

    Then I copy files below from remote folder "${PUBLISHING_DIR}" on host "dmp.ssh.inbound" into local folder "${testdata.path}/outfiles/runtime":
      | ${PUBLISHING_FILE_NAME}_${VAR_SYSDATE}_1.csv |

    And I expect reconciliation between generated CSV file "${testdata.path}/outfiles/runtime/${PUBLISHING_FILE_NAME}_${VAR_SYSDATE}_1.csv" and reference CSV file "${testdata.path}/testdata/${EXPECTED_FILE}" should be successful and exceptions to be written to "${testdata.path}/outfiles/exceptions_${recon.timestamp}.csv" file

  Scenario: Clear ISGP for overlying issue group
    Given I execute below query to "Delete group participants of issue group UNLUSECSOI"
    """
    DELETE from ft_t_isgp WHERE prnt_ISS_GRP_OID IN (SELECT ISS_GRP_OID from fT_T_isgr where iss_grp_id  = 'UNLWARSOI' AND end_tms is null)
    AND instr_id IN (SELECT instr_id FROM ft_t_isid  WHERE id_ctxt_typ = 'BCUSIP'  AND iss_id = 'BES2XRRY6' AND end_tms IS NULL)
    """