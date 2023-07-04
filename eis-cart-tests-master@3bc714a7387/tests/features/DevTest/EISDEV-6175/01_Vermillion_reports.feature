#https://jira.pruconnect.net/browse/EISDEV-6175
#https://collaborate.pruconnect.net/display/EISTOM/EIFFEL+III+Development+-+Credit+Tagging

#EISDEV-6831: performance improvement of the view

@dw_interface_vermillion
@dmp_dw_regression
@eisdev_6175 @vermillion_report_dwh @eisdev_6831

Feature: Test addition of two new columns - ESI_CORE_L2 and ESI_E3_CTAG to excel vermillion reports provided

  This feature tests addition of two new columns(classifications) - ESI_CORE_L2 and ESI_E3_CTAG in DWH vermillion reports
  ESI_CORE_L2 and ESI_E3_CTAG - values are flowing to DWH from GC via Talend delta job

  The following scenarios are covered:
  Security condition                                                     | ESI_CORE_L2  | ESI_E3_CTAG
  US4642868719 (ISIN present in file and in DB)                          | Fixed Income | Non Credit
  EASTSPRING INVSTS (Security Description present)                       | Fixed Income | Non Credit
  SPOT HONG KONG DOLLAR (Subclass is SPOT FX - security match not in DB) |              | Non Credit
  SPOT US DOLLAR (not in DB and subclass doesn't match)                  |              | Credit

  Background:

    Given I set the DMP workflow web service endpoint to named configuration "dwh.ws.WORKFLOW"
    And I set the database connection to configuration "dmp.db.DW"

  Scenario: Assign Variables

    Given I generate value with date format "YYYYMMdd" and assign to variable "VAR_SYSDATE"
    And I assign "tests/test-data/DevTest/EISDEV-6175" to variable "testdata.path"
    And I assign "PPAHAF_Excel_29022020_test.xlsx" to variable "INPUT_FILENAME"
    And I assign "PPAHAF_Excel_29022020_test_updated.xlsx" to variable "OUTPUT_FILENAME"
    Given I assign "/dmp/in/bnp/" to variable "BNP_DOWNLOAD_DIR"
    And I assign "/dmp/out/bnp/" to variable "BNP_UPLOAD_DIR"

  Scenario: Insert prequisite data

    And I execute below query to "Set up data for the given instrument for WNCS, WNCL, WISL"
    """
    ${testdata.path}/sql/dwh_wncs_wncl_insert.sql
    """

  Scenario: Run Excel Processing workflow to add the two columns to detailed evaluation sheet

    Given I assign "tests/test-data/intf-specs/gswf/template/EIS_RefreshMView/request.xmlt" to variable "REFRESH_MVIEW"

    And I process the workflow template file "${REFRESH_MVIEW}" with below parameters and wait for the job to be completed
      | MVIEW_NAME | ft_v_rpt1_vermillion             |
      | PROC_NAME  | esi_refresh_ft_v_rpt1_vermillion |

    When I remove below files in the host "dmp.ssh.inbound" from folder "${BNP_DOWNLOAD_DIR}" if exists:
      | *_Excel_*.xlsx |

    And I remove below files in the host "dmp.ssh.inbound" from folder "${BNP_UPLOAD_DIR}" if exists:
      | *_Excel_*.xlsx |

    And I copy files below from local folder "${testdata.path}/outputfiles" to the host "dmp.ssh.inbound" folder "${BNP_DOWNLOAD_DIR}":
      | ${INPUT_FILENAME} |

    Given I assign "tests/test-data/intf-specs/gswf/template/EIS_ProcessExcelFiles_DWH/request.xmlt" to variable "PROC_EXCEL"

    And I process the workflow template file "${PROC_EXCEL}" with below parameters and wait for the job to be completed
      | BEAN_SHELL_URI | db://resource/EASTSPRING/script/EIS_ProcessExcelVermillion.bshi |
      | FILE_PATTERN   | *_Excel_*.xlsx                                                  |
      | IP_DIR         | ${BNP_DOWNLOAD_DIR}                                             |
      | OP_DIR         | ${BNP_UPLOAD_DIR}                                               |

    Then I expect below files to be present in the host "dmp.ssh.inbound" into folder "${BNP_UPLOAD_DIR}" after processing:
      | ${OUTPUT_FILENAME} |
    Then I copy files below from remote folder "${BNP_UPLOAD_DIR}" on host "dmp.ssh.inbound" into local folder "${testdata.path}/outputfiles/runtime":
      | ${OUTPUT_FILENAME} |

  Scenario: Check the reports record count and positions' client details

    Then I expect reconciliation should be successful between given EXCEL files
      | ExpectedFile | ${testdata.path}/outputfiles/PPAHAF_Excel_expected.xlsx |
      | ActualFile   | ${testdata.path}/outputfiles/runtime/${OUTPUT_FILENAME} |
      | SheetIndex   | 1                                                       |