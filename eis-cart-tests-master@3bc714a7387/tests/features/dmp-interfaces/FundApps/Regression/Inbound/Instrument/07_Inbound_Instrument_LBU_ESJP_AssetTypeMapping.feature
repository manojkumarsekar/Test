#https://collaborate.intranet.asia/display/FUNDAPPS/FA-IN-SMF-LBURCR-Security-File#Test-logicalMapping
# Dev Ticket    : https://jira.intranet.asia/browse/TOM-4125
#Testing Ticket  : https://jira.intranet.asia/browse/TOM-4265

@gc_interface_securities
@dmp_regression_unnittest
@dmp_fundapps_regression
@fa_inbound @tom_4265 @07_inbound_rcr_esjp @dmp_fundapps_functional @fund_apps_instrument
Feature: To verify that DMP receive the inbound instrument file data from the entity EastSpring Japan
  Asset Types should be updated for all issue types in dmp as per the inbound instrument RCR file

  Scenario: Assign Variables
    Given I assign "tests/test-data/dmp-interfaces/FundApps/Regression/Inbound/Instrument" to variable "testdata.path"
    And I assign "ESJPEISLINSTMT20180219.csv" to variable "INPUT_FILENAME"
    And I copy files below from local folder "${testdata.path}/testdata" to the host "dmp.ssh.inbound" folder "${dmp.ssh.inbound.path}":
      | ${INPUT_FILENAME} |

  Scenario Outline: TC_1:Prerequisites before running actual tests
    Given I extract below values for row <ROWNUMBER> from PSV file "${INPUT_FILENAME}" in local folder "${testdata.path}/testdata" with reference to "Security Id" column and assign to variables:
      | Security Id | ISS_ID     |
      | ISIN        | ISIN       |
      | Sedol       | SEDOL_CODE |
      | CUSIP       | CUSIP_CODE |

    And I set end_tms to SYSDATE in database "dmp.db.GC" where iss_id in "'${ISS_ID}','${SEDOL_CODE}','${CUSIP_CODE}','${ISIN}'"
    Examples:
      | DATA_TYPE | ROWNUMBER |
      | COM       | 2         |
      | CONV      | 3         |
      | CPFD      | 4         |
      | CWT       | 5         |
      | ELN       | 6         |
      | ETF       | 7         |
      | FUT       | 8         |
      | NVDR      | 9         |
      | OWT       | 10        |
      | PNOTE     | 11        |
      | PREF      | 12        |
      | REIT      | 13        |
      | RTS       | 14        |
      | BSWAP     | 15        |
      | ESWAP     | 16        |
      | UT        | 17        |
      | ECFD      | 18        |

  Scenario: TC2:Load the file to dmp
    Given I assign "ESJPEISLINSTMT20180219.csv" to variable "INPUT_FILENAME"
    When I process files with below parameters and wait for the job to be completed
      | BUSINESS_FEED |                          |
      | FILE_PATTERN  | ${INPUT_FILENAME}        |
      | MESSAGE_TYPE  | EIS_MT_ESJP_DMP_SECURITY |

  Scenario Outline: TC_17: verify the Asset Type mapping for all issue types
    Given I extract below values for row <ROWNUMBER> from PSV file "${INPUT_FILENAME}" in local folder "${testdata.path}/testdata" with reference to "Security Id" column and assign to variables:
      | Security Id                   | ISS_ID          |
      | ISIN                          | ISIN            |
      | Sedol                         | SEDOL_CODE      |
      | CUSIP                         | CUSIP_CODE      |
      | Security Type/Instrument Type | ISS_TYP         |
      | Source BU Code                | SOURCE_CODE     |
      | Currency of Denomination      | DENOM_CURR_CODE |
     #  To verify  the inbound instrument file load in to DMP  from the entity EastSpring Japan
    Then I expect value of column "ISS_TYP" in the below SQL query equals to "<EXPECTED_ISS_VALUE>":
      """
      SELECT ISS_TYP FROM FT_T_ISSU
      WHERE INSTR_ID=(
                    SELECT INSTR_ID FROM FT_T_ISID WHERE ID_CTXT_TYP = 'ESJPCODE' and ISS_ID='${ISS_ID}' AND END_TMS IS NULL
                    )
      AND DENOM_CURR_CDE='${DENOM_CURR_CODE}'
      AND TRUNC(LAST_CHG_TMS)=TRUNC(SYSDATE)
      AND DATA_SRC_ID='${SOURCE_CODE}'
      AND END_TMS IS NULL
      """
    Examples:
      | DATA_TYPE | ROWNUMBER | EXPECTED_ISS_VALUE |
      | COM       | 2         | EQSHR              |
      | CONV      | 3         | BOND               |
      | CPFD      | 4         | PFD                |
      | CWT       | 5         | WARRANTS           |
      | ELN       | 6         | MISC               |
      | ETF       | 7         | EQSHR              |
      | FUT       | 8         | FUTURES            |
      | NVDR      | 9         | EQSHR              |
      | OWT       | 10        | WARRANTS           |
      | PNOTE     | 11        | MISC               |
      | PREF      | 12        | PFD                |
      | REIT      | 13        | FUND               |
      | RTS       | 14        | RIGHTS             |
      | BSWAP     | 15        | SWAP               |
      | ESWAP     | 16        | SWAP               |
      | UT        | 17        | UNITTRST           |
      | ECFD      | 18        | MISC               |

  Scenario: Clear the data after tests
    Then I set end_tms to SYSDATE in database "dmp.db.GC" where iss_id in "'${ISS_ID}','${SEDOL_CODE}','${CUSIP_CODE}','${ISIN}'"
    Then I set end_tms to SYSDATE in database "dmp.db.VD" where iss_id in "'${ISS_ID}','${SEDOL_CODE}','${CUSIP_CODE}','${ISIN}'"
