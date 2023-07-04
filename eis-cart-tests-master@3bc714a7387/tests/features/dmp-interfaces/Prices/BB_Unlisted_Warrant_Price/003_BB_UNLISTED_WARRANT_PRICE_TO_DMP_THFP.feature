# ===================================================================================================================================================================================
# Date            JIRA        Comments
# ===================================================================================================================================================================================
# 31/Oct/2019     eisdev_6801  Sourcing Unlisted Warrant Price
# ===================================================================================================================================================================================

@gc_interface_prices
@dmp_regression_integrationtest
@derive_unlisted_warrant_price @eisdev_6801 @eisdev_7105
Feature: Derive Overlying Unlisted Warrant Price with Underlying Thai Foreign Security

  Verify The Warrant Price of the Overlying Security is derived from the "Derived Thai Price", if the Underlying security is Thai Foreign Security
  To verify this price calculation, below data will be mocked up as there is no change in the derivation of below data as part of this jira
    Linkage of Overlying to Underlying Thai Foreign relation
    Derived Thai Foreign Price for Underlying Security

  Scenario: Assign Variables and Set up Data

    And I assign "tests/test-data/dmp-interfaces/Prices/BB_Unlisted_Warrant_Price" to variable "testdata.path"
    And I generate value with date format "YYYYMMdd" and assign to variable "PRC_TMS"

    Then I execute below query to "Clean up ISPC, GPCS, ISPS for SYSDATE-1"
    """
    ${testdata.path}/sql/cleanup_ispc.sql
    """

    When I execute below query to "Mock up data"
    """
    ${testdata.path}/sql/ClearDataSetup_THFP.sql
    """

  Scenario: TC3: Process Golden Price Calculation Workflow

    Given I generate value with date format "yyyyMMdd" and assign to variable "PRC_TMS"
    And I process Goldenprice calculation with below parameters and wait for the job to be completed
      | PROCESSING_DATE           | ${PRC_TMS} |
      | RUN_THAI_PRICE_DERIVATION | false      |
      | RUN_FAIR_VALUE_DERIVATION | false      |
      | INSTRUMENTS               | BES2XRRY6  |
      | RUNPVCFORPRVI             | false      |

  Scenario: Verification of FT_T_ISPC table overlying price is derived

    Then I expect value of column "PRICE_COUNT" in the below SQL query equals to "1":
    """
    SELECT Count(1) PRICE_COUNT
    FROM   gs_gc.ft_t_ispc
    WHERE  last_chg_tms > Trunc(sysdate)
    and PRC_TYP = 'DERIVE'
    AND UNIT_CPRC = 23.57
    AND instr_id IN
    (SELECT instr_id
    FROM   gs_gc.ft_t_isid
    WHERE  iss_id ='BES2XRRY6'
           AND id_ctxt_typ = 'BCUSIP'
           AND end_tms IS NULL)
    """

  Scenario: Publish Price Data

    Given I assign "esi_brs_p_price" to variable "PUBLISHING_FILE_NAME"
    And I generate value with date format "YYYYMMdd" and assign to variable "VAR_SYSDATE"
    And I assign "/dmp/out/brs/eod" to variable "PUBLISHING_DIR"

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

    Then I expect column "PRICE" value to be "23.57" where columns values are as below in CSV file "${testdata.path}/outfiles/runtime/${PUBLISHING_FILE_NAME}_${VAR_SYSDATE}_1.csv"
      | CLIENT_ID | ESL9349232 |
      | PURPOSE   | ESIPX      |
      | SOURCE    | ESALL      |
      | CURRENCY  | THB        |

  Scenario: Re-store Data

    When I execute below query to "Re-store data"
    """
    ${testdata.path}/sql/RestoreData_THFP.sql
    """