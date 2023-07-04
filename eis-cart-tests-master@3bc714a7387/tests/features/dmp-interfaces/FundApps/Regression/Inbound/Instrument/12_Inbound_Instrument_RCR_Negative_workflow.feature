#https://collaborate.intranet.asia/display/FUNDAPPS/FA-IN-SMF-LBURCR-Security-File#Test-logicalMapping
# Dev Ticket    : https://jira.intranet.asia/browse/TOM-4125
#Testing Ticket  : https://jira.intranet.asia/browse/TOM-4265

@gc_interface_securities
@dmp_regression_unittest
@dmp_fundapps_regression
@tom_4265 @12_inbound_rcr_negative @dmp_fundapps_functional @fund_apps_instrument @fa_inbound
Feature: To verify that DMP receive the inbound instrument file data from the entity BOCI
  All the fields should be updated in dmp as per the inbound instrument RCR file
  and Throws Exception if Mandatory fields not available in RCR file

  Scenario: Assign Variables
    Given I assign "tests/test-data/dmp-interfaces/FundApps/Regression/Inbound/Instrument" to variable "testdata.path"

  Scenario: TC1: Process Instrument Inbound file to DMP
    Given I assign "BOCIEISLINSTMT20180219.csv" to variable "INPUT_FILENAME"
    And I extract below values for row 2 from PSV file "${INPUT_FILENAME}" in local folder "${testdata.path}/testdata" with reference to "SECURITY_ID" column and assign to variables:
      | SECURITY_ID | ISS_ID     |
      | ISIN        | ISIN       |
      | SEDOL       | SEDOL_CODE |
      | CUSIP       | CUSIP_CODE |

    And I set end_tms to SYSDATE in database "dmp.db.GC" where iss_id in "'${ISS_ID}','${SEDOL_CODE}','${CUSIP_CODE}','${ISIN}'"

    And I copy files below from local folder "${testdata.path}/testdata" to the host "dmp.ssh.inbound" folder "${dmp.ssh.inbound.path}":
      | ${INPUT_FILENAME} |

    When I process files with below parameters and wait for the job to be completed
      | BUSINESS_FEED |                          |
      | FILE_PATTERN  | ${INPUT_FILENAME}        |
      | MESSAGE_TYPE  | EIS_MT_BOCI_DMP_SECURITY |

    Then I extract new job id from jblg table into a variable "JOB_ID"

    And I expect value of column "JBLG_ROW_COUNT" in the below SQL query equals to "1":
    """
    SELECT count(*) as JBLG_ROW_COUNT FROM FT_T_JBLG WHERE JOB_ID = '${JOB_ID}'
    """
     ##verify the Security ID Created
    And  I expect value of column "DESC_USAGE_TYP_COUNT" in the below SQL query equals to "1":
    """
     SELECT COUNT(*) AS DESC_USAGE_TYP_COUNT FROM FT_T_ISDE WHERE DESC_USAGE_TYP = 'PRIMARY'
     AND INSTR_ID = (SELECT INSTR_ID FROM FT_T_ISID WHERE ID_CTXT_TYP = 'BOCICODE' and ISS_ID='${ISS_ID}' AND END_TMS IS NULL)
    """
    #verify the ISIN updated
    And I expect value of column "ISS_ID" in the below SQL query equals to "1":
    """
     Select COUNT(*) AS ISS_ID FROM FT_T_ISID
     WHERE ID_CTXT_TYP = 'ISIN' AND ISS_ID='${ISIN}'
     AND TRUNC(LAST_CHG_TMS)=TRUNC(SYSDATE)
     AND END_TMS IS NULL
    """
    #verify the SEDOL updated
    And I expect value of column "SEDOL_COUNT" in the below SQL query equals to "1":
    """
     Select COUNT(*) AS SEDOL_COUNT FROM FT_T_ISID WHERE ID_CTXT_TYP = 'SEDOL' AND ISS_ID='${SEDOL_CODE}' AND END_TMS IS NULL
    """
    #verify the CUSIP updated
    And I expect value of column "CUSIP_COUNT" in the below SQL query equals to "1":
    """
     Select COUNT(*) AS CUSIP_COUNT FROM FT_T_ISID
     WHERE ID_CTXT_TYP = 'CUSIP' AND ISS_ID='${CUSIP_CODE}'
     AND TRUNC(LAST_CHG_TMS)=TRUNC(SYSDATE)
     AND END_TMS IS NULL
    """

  Scenario Outline: TC2: Process Instrument Inbound file to DMP  with same as previous set of data and different set of data
    Given I extract below values for row <RowNumber> from PSV file "${INPUT_FILENAME}" in local folder "${testdata.path}/testdata" with reference to "SECURITY_ID" column and assign to variables:
      | SECURITY_ID | ISS_ID     |
      | ISIN        | ISIN       |
      | SEDOL       | SEDOL_CODE |
      | CUSIP       | CUSIP_CODE |

    When I extract new job id from jblg table into a variable "JOB_ID"

    Then I expect value of column "JBLG_ROW_COUNT" in the below SQL query equals to "1":
    """
    SELECT count(*) as JBLG_ROW_COUNT FROM FT_T_JBLG WHERE JOB_ID = '${JOB_ID}'
    """
     ##verify the Security ID Created
    And  I expect value of column "DESC_USAGE_TYP_COUNT" in the below SQL query equals to "1":
    """
     SELECT COUNT(*) AS DESC_USAGE_TYP_COUNT FROM FT_T_ISDE WHERE DESC_USAGE_TYP = 'PRIMARY'
     AND INSTR_ID = (SELECT INSTR_ID FROM FT_T_ISID WHERE ID_CTXT_TYP = 'BOCICODE' and ISS_ID='${ISS_ID}' AND END_TMS IS NULL)
    """
    #verify the ISIN updated
    And I expect value of column "ISIN_COUNT" in the below SQL query equals to "1":
    """
     Select COUNT(*) AS ISIN_COUNT FROM FT_T_ISID WHERE ID_CTXT_TYP = 'ISIN' AND ISS_ID='${ISIN}' AND END_TMS IS NULL
    """
    #verify the SEDOL updated
    And I expect value of column "SEDOL_COUNT" in the below SQL query equals to "1":
    """
     Select COUNT(*) AS SEDOL_COUNT FROM FT_T_ISID WHERE ID_CTXT_TYP = 'SEDOL' AND ISS_ID='${SEDOL_CODE}' AND END_TMS IS NULL
    """

    Examples:
      | RowNumber |
      | 3         |
      | 4         |

  Scenario: TC3: Process Instrument Inbound file to DMP  with Currency_of_Denomination value as null
    Given I extract below values for row 5 from PSV file "${INPUT_FILENAME}" in local folder "${testdata.path}/testdata" with reference to "SECURITY_ID" column and assign to variables:
      | SECURITY_ID | ISS_ID     |
      | ISIN        | ISIN       |
      | SEDOL       | SEDOL_CODE |
      | CUSIP       | CUSIP_CODE |
    When I extract new job id from jblg table into a variable "JOB_ID"
    Then  I expect value of column "EXCEPTION_COUNT" in the below SQL query equals to "1":
    """
    SELECT COUNT(*) AS EXCEPTION_COUNT FROM FT_T_NTEL
    WHERE TRN_ID IN (
                    SELECT TRN_ID FROM FT_T_TRID
                    WHERE JOB_ID='${JOB_ID}'
                    )
    AND PARM_VAL_TXT LIKE '%User defined Error thrown%required fields, Currency_of_Denomination  is not present in the input record.'
    AND MSG_TYP = 'EIS_MT_BOCI_DMP_SECURITY'
    AND MSG_SEVERITY_CDE=40
    AND MAIN_ENTITY_ID_CTXT_TYP = 'BOCICODE'
    """

  Scenario: TC4: Process Instrument Inbound file to DMP  with SECURITY_TYPE/INSTR value as null
    Given I extract below values for row 6 from PSV file "${INPUT_FILENAME}" in local folder "${testdata.path}/testdata" with reference to "SECURITY_ID" column and assign to variables:
      | SECURITY_ID | ISS_ID     |
      | ISIN        | ISIN       |
      | SEDOL       | SEDOL_CODE |
      | CUSIP       | CUSIP_CODE |
    When I extract new job id from jblg table into a variable "JOB_ID"
    Then  I expect value of column "EXCEPTION_COUNT" in the below SQL query equals to "1":
    """
    SELECT COUNT(*) AS EXCEPTION_COUNT FROM FT_T_NTEL
    WHERE TRN_ID IN (
                    SELECT TRN_ID FROM FT_T_TRID
                    WHERE JOB_ID='${JOB_ID}'
                    )
    AND PARM_VAL_TXT LIKE '%User defined Error thrown%required fields, Security_Instrument_Type  is not present in the input record.'
    AND MSG_TYP = 'EIS_MT_BOCI_DMP_SECURITY'
    AND MSG_SEVERITY_CDE=40
    AND MAIN_ENTITY_ID_CTXT_TYP = 'BOCICODE'
    """

  Scenario: Clear the data after tests
    Then I set end_tms to SYSDATE in database "dmp.db.GC" where iss_id in "'${ISS_ID}','${SEDOL_CODE}','${CUSIP_CODE}','${ISIN}'"
    Then I set end_tms to SYSDATE in database "dmp.db.VD" where iss_id in "'${ISS_ID}','${SEDOL_CODE}','${CUSIP_CODE}','${ISIN}'"
