#https://jira.intranet.asia/browse/TOM-3581
#TOM-3581 Original change to remove deuplicate swap positions
#TOM-4072 Modify test to use production account details to avoid load failure
#TOM-5104 Modify test to avoid non-deterministic security code from GS GSO
# eisdev_6341 : as part of eisdev_6174 ticket, two new columns were added to redi2 interface. modifying recon template with new columns

@gc_interface_redi2 @gc_interface_exchange_rates @gc_interface_positions
@dmp_regression_integrationtest
@tom_3581 @month_end_reporting @tom_4072 @tom_5104 @eisdev_6341 @eisdev_7435
Feature: Loading BNP daily MOPK into GC and publishing REDI2 accrual file

  The SWAPs appear to be duplicated in the daily valuation. Please see attached for more info.
  Investigations have shown the extraneous positions are reflecting the combined position created by the BNP SOD inbound interface for SWAPs.
  This combined position was to align the BNP data to BRS, and basically needs to be excluded from the REDI2 accrual report.
  The REDI2 accrual report will subsequently, for SWAPs, report the two individual positions from BNP, one for the payable leg, one for the receivable leg.

  This test case is testing the handling of SWAP positions in REDI2 accruals.
  The inbound process will create 3 records (2 as per BNP, 1 combined for BRS), but the outbound should only report 2 (the 2 from BNP)

  Scenario: TC_1: Clear old test data and setup variables

    Given I assign "tests/test-data/DevTest/TOM-3581" to variable "testdata.path"
    And I assign "U_VAL_TOM3581" to variable "PUBLISHING_FILENAME"
    And I assign "${dmp.ssh.outbound.path}/eis/redi2" to variable "PUBLISHING_DIR"
    And I generate value with date format "YYYYMMdd" and assign to variable "VAR_SYSDATE"

    And I execute below query
    """
    ${testdata.path}/sql/cleardown.sql
    """

    #Fetch next working day (Mon to Fri) because REDI2 accruals for Sat/Sun positions uses previous Fri FX rates
    And I execute below query and extract values of "POS_DATE" into same variables
    """
    SELECT TO_CHAR(GREATEST(SYSDATE + 1, NEXT_DAY(SYSDATE, 'FRIDAY') - 4), 'yyyymmdd') pos_date FROM DUAL
    """

    And I modify date "${POS_DATE}" with "+0d" from source format "YYYYMMdd" to destination format "yyyy-MMM-dd" and assign to "PUBLISH_DATE_IN"
    And I modify date "${POS_DATE}" with "+0d" from source format "YYYYMMdd" to destination format "dd/MM/yyyy" and assign to "PUBLISH_DATE_OUT"

    And I execute below query and extract values of "PORTFOLIO_CODE;PORTFOLIO_NAME" into same variables
    """
    ${testdata.path}/sql/fetch_active_non_latam_account.sql
    """

    And I execute below query and extract values of "REC_LEG_BNP_ID;PAY_LEG_BNP_ID" into same variables
    """
    ${testdata.path}/sql/fetch_active_fx_swap_bnp_ids.sql
    """

    And I create input file "TOM_3581_EXR.out" using template "TOM_3581_EXR_Template.out" from location "${testdata.path}"
    And I create input file "TOM_3581_SDP.out" using template "TOM_3581_SDP_Template.out" from location "${testdata.path}"
    #
    # Using input file substitution to create a new version of the expected output, to be used in the eventual reconciliation
    #
    And I create input file "U_VAL.csv" using template "U_VAL_expectation.csv" from location "${testdata.path}/outfiles"

  Scenario: TC_2: Load BNP files

    And I assign "TOM_3581_EXR.out" to variable "BNP_EXR_FILE"
    And I assign "TOM_3581_SDP.out" to variable "BNP_SDP_FILE"

    When I copy files below from local folder "${testdata.path}/testdata" to the host "dmp.ssh.inbound" folder "${dmp.ssh.inbound.path}":
      | ${BNP_EXR_FILE} |
      | ${BNP_SDP_FILE} |

    Given I process files with below parameters and wait for the job to be completed
      | BUSINESS_FEED |                              |
      | FILE_PATTERN  | ${BNP_EXR_FILE}              |
      | MESSAGE_TYPE  | EIS_MT_BNP_EOD_EXCHANGE_RATE |

    Given I process files with below parameters and wait for the job to be completed
      | BUSINESS_FEED |                                       |
      | FILE_PATTERN  | ${BNP_SDP_FILE}                       |
      | MESSAGE_TYPE  | EIS_MT_BNP_SOD_POSITIONNONFX_NONLATAM |

  Scenario: TC_3: Create Cross Rates

    Given I assign "tests/test-data/intf-specs/gswf/template/EIS_CallStoredProcedure/request.xmlt" to variable "CREATE_RATES"

    And I process the workflow template file "${CREATE_RATES}" with below parameters and wait for the job to be completed
      | SQL_PROC_NAME | esi_create_fxrt_cross_rates |

  Scenario: TC_4: Publish REDI2 accrual report

    Given I remove below files in the host "dmp.ssh.outbound" from folder "${PUBLISHING_DIR}" if exists:
      | U_VAL*.* |

    When I process publishing wrapper with below parameters and wait for the job to be completed
      | PUBLISHING_FILE_NAME | ${PUBLISHING_FILENAME}.csv       |
      | SUBSCRIPTION_NAME    | EIS_DMP_TO_REDI2_FEE_ACCRUAL_SUB |

    Then I expect below files to be present in the host "dmp.ssh.outbound" into folder "${PUBLISHING_DIR}" after processing:
      | ${PUBLISHING_FILENAME}_${VAR_SYSDATE}_1.csv |

    Then I copy files below from remote folder "${PUBLISHING_DIR}" on host "dmp.ssh.outbound" into local folder "${testdata.path}/outfiles/runtime":
      | ${PUBLISHING_FILENAME}_${VAR_SYSDATE}_1.csv |

  Scenario: TC_5: Reconcile output's SecurityCode, ensuring same value for both records

    Given I extract below values for row 2 from CSV file "${PUBLISHING_FILENAME}_${VAR_SYSDATE}_1.csv" in local folder "${testdata.path}/outfiles/runtime" with reference to "SourceId" column and assign to variables:
      | SecurityCode | VALUE_ROW_1 |

    And I extract below values for row 3 from CSV file "${PUBLISHING_FILENAME}_${VAR_SYSDATE}_1.csv" in local folder "${testdata.path}/outfiles/runtime" with reference to "SourceId" column and assign to variables:
      | SecurityCode | VALUE_ROW_2 |

    Then I expect the value of var "${VALUE_ROW_1}" equals to "${VALUE_ROW_2}"

  Scenario: TC_6: Reconcile output excluding SecurityCode

    When I exclude below columns from CSV file while doing reconciliations
      | SecurityCode |
      | ESI_CORE_L2  |
      | ESI_E3_CTAG  |

    Then I expect reconciliation between generated CSV file "${testdata.path}/outfiles/runtime/${PUBLISHING_FILENAME}_${VAR_SYSDATE}_1.csv" and reference CSV file "${testdata.path}/outfiles/testdata/U_VAL.csv" should be successful and exceptions to be written to "${testdata.path}/outfiles/runtime/differences.csv" file
