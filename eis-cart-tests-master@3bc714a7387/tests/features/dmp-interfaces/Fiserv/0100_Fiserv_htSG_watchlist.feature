# ===================================================================================================================================================================================
# Date            JIRA        Comments
# ===================================================================================================================================================================================
# 04/08/2020      EISDEV-6411 Fiserv - File publishing for HTSG
# ===================================================================================================================================================================================
# FS : https://collaborate.pruconnect.net/display/EISFISERV/EISG+-+HTSG

@gc_interface_fiserv
@dmp_regression_unittest
@eisdev_6411 @fiserv_htsg @exceltocsv
Feature: 001 | Fiserv | HTSG Watchlist | Verify HTSG file transformed to FISERV format

  As a user I expect a HTSG AML watchlist file to be transformed into a FISERV formatted file

  Test Scenarios
  ===================================================================================================================================================================================
  Agent Code   |  Agent Name                |  Holder Name   									  |  ID No.   	    |  NAT		   | Expected Behavior
  ===================================================================================================================================================================================
  ATSGDMGI     |  IFAST FINANCIAL PTE LTD   |  IFAST FINANCIAL PTE LTD (NC)   			          |  200616003HNC   |  SINGAPORE   | Both Agent and Holder Should be Transformed
  ATSGMBB      |  MAYBANK SINGAPORE LIMITED |  MAYBAN NOMINEES (SINGAPORE) PTE LTD A/C DIRECT     |  MAYBANNOM1     |  SINGAPORE   | Both Agent and Holder Should be Transformed
  ATSGDMGI     |  IFAST FINANCIAL PTE LTD   |  IFAST FINANCIAL PTE LTD (NC)   				      |  200616003HNC   |  SINGAPORE   | Agent and Holder already Transformed, this record should be Filtered
  ATSGFPF      |  AVALLIS FINANCIAL PTE LTD |  IFAST FINANCIAL PTE LTD (NC)   				      |  200616003HNC   |  SINGAPORE   | Holder already Transformed, Only Agent should be Transformed
  ATSGFPF      |  AVALLIS FINANCIAL PTE LTD |  DBS NOMINEES FOR ACCOUNT FUNDS ACCOUNT -PAYOUT     |  222/1969FAC    |  SINGAPORE   | Agent already Transformed, Only Holder should be Transformed

  Scenario: Transform HTSG watchlist to FISERV format

    Given I assign "tests/test-data/dmp-interfaces/Fiserv" to variable "testdata.path"
    And I assign "UH_Fund_Balance_By_Distributor_Details_Apr 20_TC1.xls" to variable "INPUT_FILENAME"
    And I generate value with date format "YYYYMMdd" and assign to variable "VAR_SYSDATE"
    And I assign "WLF_MONTHLY_EISG_HTG_${VAR_SYSDATE}.txt" to variable "TRANSFORMED_FILE_NAME"
    And I assign "/dmp/out/fiserv" to variable "PUBLISHING_DIR"
    And I assign "tests/test-data/intf-specs/gswf/template/EIS_ConvertXLSXtoCSVandLoad/request.xmlt" to variable "CONVERT_XLS_CSV"

    # Delete the output file if it exist
    Given I remove below files in the host "dmp.ssh.outbound" from folder "${PUBLISHING_DIR}" if exists:
      | ${TRANSFORMED_FILE_NAME} |

    When I copy files below from local folder "${testdata.path}/testdata" to the host "dmp.ssh.inbound" folder "${dmp.ssh.inbound.path}":
      | ${INPUT_FILENAME} |

    And I process the workflow template file "${CONVERT_XLS_CSV}" with below parameters and wait for the job to be completed
      | MESSAGE_TYPE    | EIS_MT_HTSG_FISERV_WATCHLIST                    |
      | INPUT_DATA_DIR  | ${dmp.ssh.inbound.path}                         |
      | FILEPATTERN     | UH_Fund_Balance_By_Distributor_Details_Apr*.xls |
      | PARALLELISM     | 1                                               |
      | OUTPUT_DATA_DIR | ${dmp.ssh.archive.path}                         |
      | SUCCESS_ACTION  | MOVE                                            |
      | SHEET_NAME      | Details                                         |
      | FILE_LOAD_EVENT | EIS_StandardFileTransformation                  |

    Then I expect below files to be present in the host "dmp.ssh.outbound" into folder "${PUBLISHING_DIR}" after processing:
      | ${TRANSFORMED_FILE_NAME} |

    Then I copy files below from remote folder "${PUBLISHING_DIR}" on host "dmp.ssh.outbound" into local folder "${testdata.path}/outfiles/runtime":
      | ${TRANSFORMED_FILE_NAME} |

  Scenario: Compare HTSG FISERV file against expected output

    Given I exclude below column indices from CSV file while doing reconciliations
      | 1 |

    And I expect reconciliation should be successful between given CSV files
      | ActualFile   | ${testdata.path}/outfiles/runtime/${TRANSFORMED_FILE_NAME}               |
      | ExpectedFile | ${testdata.path}/outfiles/expected/WLF_MONTHLY_EISG_HTG_tc1_expected.txt |
