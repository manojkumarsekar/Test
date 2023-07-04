#https://collaborate.intranet.asia/display/TOM/FIN-04+-+Redi2+UDAs
#https://collaborate.intranet.asia/pages/viewpage.action?pageId=33981594#Test-logicalMapping
#|   ESISODP_EXR__Template.out             | Exchange Rates for all currencies utilised in Test data
#|   ESISODP_SDP__Template.out             | 1 LONG record for account ALGLVE and 2 records (LONG & SHORT) for account AJIUIB for diff instruments
#|   ESISODP_SDP_SWAPS__Template.out       | 2 Records for SWAPS instrument for account ABTHAB
#|   ESISODP_POS__Template.out             | 2 Records for LONG among them 1 is to test overwrite feature (with increased qty) and 3rd record for SHORT for account ASPMSB
# TOM-4285 - To fix the regression data issue in the expected file format. BNP Level 5 classification changed in production. So changed test data accordingly.
# TOM-4359 - To fix the regression data issue in the expected file format. Create positions and FX rates for the next business day (Mon-Fri).
# eisdev_6341 : as part of eisdev_6174 ticket, two new columns were added to redi2 interface. modifying recon template with new columns. also excluded security name from recon as ff fails on re-run

@gc_interface_positions @gc_interface_exchange_rates @gc_interface_redi2
@dmp_regression_integrationtest
@tom_4359 @tom_4285 @tom_4069 @0101_redi2_fee_accru @eisdev_6341 @eisdev_7435
Feature: Redi2 - Fee Accruals Outbound CSV file generation Automation with

  Redi2 is an application that is used by Finance Team to calculate fees and generate invoices for client billing.
  In current state, Finance Team maintains a set of UDA's to convert and transform positions data from Hiport and CRTS into an usable format for Redi2.
  In R3, positions data will no longer be fed to Hiport and CRTS. BNP will own and deliver the data to ESI.

  Fee Accruals outbound file generation MDX reads data from FT_T_BALH (Position FX & NON FX) utilises Exchange rate FT_T_FXRT for the Exchange Rate conversion
  and generates Fee Accruals CSV file (U_VAL_YYYYMMDD.csv) which is also referred as Unaudited valuation Data.

  Scenario Outline: Prepare Data FOR "<InputFile>"

    Given I assign "<InputFile>" to variable "INPUT_FILENAME"
    And I assign "<Template>" to variable "INPUT_TEMPLATENAME"

    And I assign "tests/test-data/dmp-interfaces/R3_RPT_RD01_REDI2_FEE_ACCR" to variable "testdata.path"

    # Clear any future data positions (from previous feature files)
    And I execute below query
    """
    DELETE ft_t_bhst WHERE balh_oid IN (SELECT balh_oid FROM ft_t_balh WHERE as_of_tms > SYSDATE);
    DELETE ft_t_balh WHERE as_of_tms > SYSDATE;
    """

    #Fetch next working day (Mon to Fri) because REDI2 accruals for Sat/Sun positions uses previous Fri FX rates
    And I execute below query and extract values of "AS_OF_TMS" into same variables
    """
    SELECT TO_CHAR(GREATEST(SYSDATE + 1, NEXT_DAY(SYSDATE, 'FRIDAY') - 4), 'yyyy-MON-dd') AS_OF_TMS FROM DUAL
    """

    When I modify date "${AS_OF_TMS}" with "-2d" from source format "yyyy-MMM-dd" to destination format "yyyy-MMM-dd" and assign to "PRICE_DATE"

    And I assign "${AS_OF_TMS}" to variable "ADJST_TMS"
    And I assign "${AS_OF_TMS}" to variable "FX_TMS"

    And I create input file "${INPUT_FILENAME}" using template "${INPUT_TEMPLATENAME}" with below codes from location "${testdata.path}"
      | TRAN_ID | DateTimeFormat:dHmsS |

    When I copy files below from local folder "${testdata.path}/testdata" to the host "dmp.ssh.inbound" folder "${dmp.ssh.inbound.path}":
      | <InputFile> |

    Examples:
      | Template                        | InputFile          |
      | ESISODP_EXR__Template.out       | ESISODP_EXR__1.out |
      | ESISODP_SDP__Template.out       | ESISODP_SDP__1.out |
      | ESISODP_SDP_SWAPS__Template.out | ESISODP_SDP__2.out |
      | ESISODP_POS__Template.out       | ESISODP_POS__1.out |

  Scenario Outline: Data Loading FOR "<MessageType>"

    Given I process files with below parameters and wait for the job to be completed
      | BUSINESS_FEED | EIS_BF_BNP_FIXEDHEADER |
      | FILE_PATTERN  | <FilePattern>          |
      | MESSAGE_TYPE  | <MessageType>          |

    Examples:
      | FilePattern       | MessageType                        |
      | ESISODP_EXR_*.out | EIS_MT_BNP_EOD_EXCHANGE_RATE       |
      | ESISODP_SDP_*.out | EIS_MT_BNP_SOD_POSITIONNONFX_LATAM |
      | ESISODP_POS_*.out | EIS_MT_BNP_SOD_POSITIONFX_LATAM    |

  Scenario: Create Cross Rates

    Given I assign "tests/test-data/intf-specs/gswf/template/EIS_CallStoredProcedure/request.xmlt" to variable "CREATE_RATES"

    And I process the workflow template file "${CREATE_RATES}" with below parameters and wait for the job to be completed
      | SQL_PROC_NAME | esi_create_fxrt_cross_rates |

  Scenario: Triggering Publishing Wrapper Event

    Given I assign "U_VAL" to variable "PUBLISHING_FILE_NAME"

    Given I assign "/dmp/out/eis/redi2" to variable "PUBLISHING_DIR"

    Given I generate value with date format "YYYYMMdd" and assign to variable "VAR_SYSDATE"

    And I remove below files with pattern in the host "dmp.ssh.outbound" from folder "${PUBLISHING_DIR}" if exists:
      | ${PUBLISHING_FILE_NAME}*.csv |

    When I process publishing wrapper with below parameters and wait for the job to be completed
      | PUBLISHING_FILE_NAME | ${PUBLISHING_FILE_NAME}.csv      |
      | SUBSCRIPTION_NAME    | EIS_DMP_TO_REDI2_FEE_ACCRUAL_SUB |

    When I send a web service request using an xml file "testout/dmp-interfaces/asyncResponse.xml" and save the response to file "testout/dmp-interfaces/GetEventResultResponse.xml"
    Then I expect value from xml file "testout/dmp-interfaces/GetEventResultResponse.xml" with tagName "finished" should be "true"
    And I expect value from xml file "testout/dmp-interfaces/GetEventResultResponse.xml" with tagName "failed" should be "false"
    Then I extract value from the XML file "testout/dmp-interfaces/GetEventResultResponse.xml" with tagName "PublishDir" to variable "publishDirectory"

    Then I expect below files to be present in the host "dmp.ssh.inbound" into folder "${publishDirectory}" after processing:
      | ${PUBLISHING_FILE_NAME}_${VAR_SYSDATE}_1.csv |

    Then I copy files below from remote folder "${publishDirectory}" on host "dmp.ssh.inbound" into local folder "${testdata.path}/outfiles/runtime":
      | ${PUBLISHING_FILE_NAME}_${VAR_SYSDATE}_1.csv |

    Then I pause for 2 seconds

  Scenario: Verify Fee Accruals Output file

    Given I assign "U_VAL_MASTER_TEMPLATE.csv" to variable "FEE_ACCRU_MASTER_TEMPLATE"
    And I assign "U_VAL_MASTER.csv" to variable "FEE_ACCRU_MASTER"
    And I assign "${PUBLISHING_FILE_NAME}_${VAR_SYSDATE}_1.csv" to variable "FEE_ACCRU_CURR_FILE"
    And I modify date "${AS_OF_TMS}" with "+0d" from source format "yyyy-MMM-dd" to destination format "dd/MM/yyyy" and assign to "VALUATION_DATE"

    #I create output expected file from Master Template file
    And I create input file "${FEE_ACCRU_MASTER}" using template "${FEE_ACCRU_MASTER_TEMPLATE}" with below codes from location "${testdata.path}/outfiles/expected"
      |  |  |

    When I capture current time stamp into variable "recon.timestamp"

    When I exclude below columns from CSV file while doing reconciliations
      | ESI_CORE_L2  |
      | ESI_E3_CTAG  |
      | SecurityName |


    Then I expect reconciliation between generated CSV file "${testdata.path}/outfiles/runtime/${FEE_ACCRU_CURR_FILE}" and reference CSV file "${testdata.path}/outfiles/expected/testdata/${FEE_ACCRU_MASTER}" should be successful and exceptions to be written to "${testdata.path}/outfiles/runtime/exceptions_${recon.timestamp}.csv" file

  Scenario: Teardown test data

    And I execute below query
    """
    DELETE ft_t_bhst WHERE balh_oid IN (SELECT balh_oid FROM ft_t_balh WHERE as_of_tms > SYSDATE);
    DELETE ft_t_balh WHERE as_of_tms > SYSDATE;
    """
