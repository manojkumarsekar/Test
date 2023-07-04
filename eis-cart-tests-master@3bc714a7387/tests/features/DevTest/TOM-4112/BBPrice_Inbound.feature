# =====================================================================# =====================================================================
# Date            JIRA           Comments
# ============    ========       ========
# 25/03/2019      TOM-4112       First Version
# 26/08/2020      ESIDEV-6699    Security was removed from BBPRICEGRP in production and hence golden price was not calculated. Adding the test security to BBPRICEGRP to test functionality
# This feature file is to test loading price file from Bloomberg
# =====================================================================# =====================================================================
# EISDEV-7120 In order to speed up the execution time of golden price calculation, added the instruments and set RUNPVCFORPRVI as "False" part of parameters

#Reducing burden on integration test by tagging this under too_slow tag. temporarily adding this under unit_tests as integration already overloaded
@gc_interface_securities @gc_interface_prices @eisdev_7120
@dmp_regression_unittest
#@dmp_regression_integrationtest
@tom_4112 @bb_price @eisdev_6699 @pvc
Feature: Bloomberg Price Inbound

  Load price file from Bloomberg and ensure the prices are getting distributed to BRS.

  Scenario: Set variables and run cleardown script
    Given I assign "gs_price_template.out" to variable "INPUT_TEMPLATENAME"
    And I assign "gs_price.out" to variable "INPUT_FILENAME"
    And I assign "tests/test-data/DevTest/TOM-4112" to variable "testdata.path"
    And I assign "1000" to variable "workflow.max.polling.time"

    And I create input file "${INPUT_FILENAME}" using template "${INPUT_TEMPLATENAME}" with below codes from location "${testdata.path}"
      | PRC_TMS | DateTimeFormat:yyyyMMdd |

    When I copy files below from local folder "${testdata.path}/testdata" to the host "dmp.ssh.inbound" folder "${dmp.ssh.inbound.path}":
      | ${INPUT_FILENAME} |

    And I execute below query to "teardown existing test data"
      """
      ${testdata.path}/sql/ClearData.sql
      """

    And I execute below query to "add security to BBPRICEGRP group for GoldenPrice calculation"
      """
      ${testdata.path}/sql/ISGP_Setup.sql
      """

    Then I expect value of column "PRICE_COUNT" in the below SQL query equals to "0":
      """
      SELECT Count(1) PRICE_COUNT
      FROM   gs_gc.ft_t_ispc
      WHERE  last_chg_tms > Trunc(sysdate)
      AND instr_id IN
      (SELECT instr_id
      FROM   gs_gc.ft_t_isid
      WHERE  iss_id IN ( 'LU0440258258', 'GB0030932452', 'GB00F75H9F84',
                         'IE00B19Z9505' )
             AND id_ctxt_typ = 'ISIN'
             AND end_tms IS NULL)
      """

    And I process files with below parameters and wait for the job to be completed
      | BUSINESS_FEED            |                                  |
      | FILE_PATTERN             | ${INPUT_FILENAME}                |
      | MESSAGE_TYPE             | EIS_MT_BBG_SECURITY_PER_SECURITY |
      | PRICE_POINT_EVENT_DEF_ID | ESIPRPTEOD                       |

  Scenario: Verification of FT_T_ISPC table to check all the prices are got loaded

    Then I expect value of column "PRICE_COUNT" in the below SQL query equals to "13":
    """
    SELECT Count(1) PRICE_COUNT
    FROM   gs_gc.ft_t_ispc
    WHERE  last_chg_tms > Trunc(sysdate)
    AND instr_id IN
    (SELECT instr_id
    FROM   gs_gc.ft_t_isid
    WHERE  iss_id IN ( 'LU0440258258', 'GB0030932452', 'GB00F75H9F84',
                       'IE00B19Z9505' )
           AND id_ctxt_typ = 'ISIN'
           AND end_tms IS NULL)
    """

  Scenario: Process Golden Price Calculation Workflow

    Given I generate value with date format "yyyyMMdd" and assign to variable "PRC_TMS"
    And I process Goldenprice calculation with below parameters and wait for the job to be completed
      | PROCESSING_DATE                       | ${PRC_TMS}                                          |
      | RUNPVCFORPRVI                         | false                                               |
      | RUN_FAIR_VALUE_DERIVATION             | false                                               |
      | RUN_UNLISTED_WARRANT_PRICE_DERIVATION | false                                               |
      | RUN_THAI_PRICE_DERIVATION             | false                                               |
      | INSTRUMENTS                           | LU0440258258,GB0030932452,GB00F75H9F84,IE00B19Z9505 |

  Scenario: Triggering Publishing Wrapper Event for CSV file into directory for Price

    Given I assign "esi_brs_p_price" to variable "PUBLISHING_FILE_NAME"
    And I generate value with date format "YYYYMMdd" and assign to variable "VAR_SYSDATE"
    And I assign "/dmp/out/brs/eod" to variable "PUBLISHING_DIR"
    And I assign "esi_brs_p_price_template.csv" to variable "OUT_TEMPLATE_FILE"
    And I assign "esi_brs_p_price_expected.csv" to variable "OUT_EXPECTED_FILE"

    And I create input file "${OUT_EXPECTED_FILE}" using template "${OUT_TEMPLATE_FILE}" with below codes from location "${testdata.path}"
      | PRC_TMS | DateTimeFormat:yyyyMMdd |

    And I remove below files in the host "dmp.ssh.inbound" from folder "${PUBLISHING_DIR}" if exists:
      | ${PUBLISHING_FILE_NAME}_*.csv |

    When I process publishing wrapper with below parameters and wait for the job to be completed
      | PUBLISHING_FILE_NAME | ${PUBLISHING_FILE_NAME}.csv                                                                                                                       |
      | SUBSCRIPTION_NAME    | EIS_DMP_TO_BRS_PRICE_VIEW_SUB                                                                                                                     |
      | SQL                  | &lt;sql&gt; TRUNC(PRC1_ADJST_TMS) =TRUNC(SYSDATE ) AND PRC1_ISIN IN ('LU0440258258', 'GB0030932452', 'GB00F75H9F84', 'IE00B19Z9505') &lt;/sql&gt; |

    Then I expect below files to be present in the host "dmp.ssh.inbound" into folder "${PUBLISHING_DIR}" after processing:
      | ${PUBLISHING_FILE_NAME}_${VAR_SYSDATE}_1.csv |

    Then I copy files below from remote folder "${PUBLISHING_DIR}" on host "dmp.ssh.inbound" into local folder "${testdata.path}/outfiles/runtime":
      | ${PUBLISHING_FILE_NAME}_${VAR_SYSDATE}_1.csv |

    And I expect reconciliation between generated CSV file "${testdata.path}/outfiles/runtime/${PUBLISHING_FILE_NAME}_${VAR_SYSDATE}_1.csv" and reference CSV file "${testdata.path}/testdata/${OUT_EXPECTED_FILE}" should be successful and exceptions to be written to "${testdata.path}/outfiles/exceptions_${recon.timestamp}.csv" file

  Scenario: Cleanup max polling time variable
    Then I remove variable "workflow.max.polling.time" from memory
