#Ticket link : https://jira.intranet.asia/browse/TOM-4479
#Parent Ticket: https://jira.intranet.asia/browse/TOM-1226
#Requirement Links: https://collaborate.intranet.asia/pages/viewpage.action?pageId=14796607#Test-logicalMapping

@gc_interface_securities
@dmp_regression_unittest
@1010_tom_4479_bnp_dmp_security
Feature: BNP to DMP Security feed - ESI Identifier Generation and Mapping in ISID for new securities

  Description of the feature:
  As a part of this feature, we are testing:
  1. End dating existing ESI generated identifiers and external identifiers from FT_T_ISID as a pre-requisite
  2. Loading  Security Feed
  3. Validating generation of ESI identifiers for FT_T_ISID table as per Specifications

  Scenario: Assign Variables

    Given I assign "tests/test-data/Regression-DMP/SOD/BNP_TO_DMP/Security/TOM-4479" to variable "testdata.path"
    And I assign "ESISODP_SEC_ESID_VAL.out" to variable "INPUT_FILENAME"

    And I extract below values for row 2 from PSV file "${INPUT_FILENAME}" in local folder "${testdata.path}/testdata" and assign to variables:
      | INSTR_ID | VAR_INSTR_ID |

    And I execute below query and extract values of "INSTRUMENT_ID" into same variables
    """
    SELECT INSTR_ID AS INSTRUMENT_ID FROM FT_T_ISID WHERE ISS_ID IN ('${VAR_INSTR_ID}') AND END_TMS IS NULL
    """

    And I execute below query and extract values of "EISSECID" into same variables
    """
    SELECT ISS_ID AS EISSECID FROM FT_T_ISID WHERE INSTR_ID IN ('${INSTRUMENT_ID}') AND ID_CTXT_TYP = 'EISSECID'
    """
    And I execute below query and extract values of "EISLSTID" into same variables
    """
    SELECT ISS_ID AS EISLSTID FROM FT_T_ISID WHERE INSTR_ID IN ('${INSTRUMENT_ID}') AND ID_CTXT_TYP = 'EISLSTID'
    """

    And I set end_tms to SYSDATE in database "dmp.db.VD" where iss_id in "'${VAR_INSTR_ID}','${VAR_ISIN}','${VAR_SEDOL}','${VAR_HIP_SECURITY_CODE}','${EISSECID}','${EISLSTID}'"
    And I set end_tms to SYSDATE in database "dmp.db.GC" where iss_id in "'${VAR_INSTR_ID}','${VAR_ISIN}','${VAR_SEDOL}','${VAR_HIP_SECURITY_CODE}','${EISSECID}','${EISLSTID}'"

  Scenario: Load Security File to check the auto generation


    When I copy files below from local folder "${testdata.path}/testdata" to the host "dmp.ssh.inbound" folder "${dmp.ssh.inbound.path}":
      | ${INPUT_FILENAME} |

    And I process files with below parameters and wait for the job to be completed
      | BUSINESS_FEED |                     |
      | FILE_PATTERN  | ${INPUT_FILENAME}   |
      | MESSAGE_TYPE  | EIS_MT_BNP_SECURITY |

    And I execute below query and extract values of "INSTRUMENT_ID" into same variables
    """
    SELECT INSTR_ID AS INSTRUMENT_ID FROM FT_T_ISID WHERE ISS_ID IN ('${VAR_INSTR_ID}') AND END_TMS IS NULL
    """

  Scenario: Verify the EIS identifiers are auto generated


    Then I execute below query and extract values of "INSTRUMENT_ID" into same variables
    """
    SELECT INSTR_ID AS INSTRUMENT_ID FROM FT_T_ISID WHERE ISS_ID IN ('${VAR_INSTR_ID}') AND END_TMS IS NULL
    """

    And  I expect value of column "EISSECID_CHECK" in the below SQL query equals to "1":
	"""
    SELECT COUNT(*) AS EISSECID_CHECK  FROM FT_T_ISID WHERE INSTR_ID = '${INSTRUMENT_ID}' AND ID_CTXT_TYP = 'EISSECID'
	"""

    And  I expect value of column "EISLSTID_CHECK" in the below SQL query equals to "1":
	"""
    SELECT COUNT(*) AS EISLSTID_CHECK FROM FT_T_ISID WHERE INSTR_ID = '${INSTRUMENT_ID}' AND ID_CTXT_TYP = 'EISLSTID'
	"""





