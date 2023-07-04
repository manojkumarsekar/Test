#Ticket link : https://jira.intranet.asia/browse/TOM-4479
#Parent Ticket: https://jira.intranet.asia/browse/TOM-1226
#Requirement Links: https://collaborate.intranet.asia/pages/viewpage.action?pageId=14796607#Test-logicalMapping

@gc_interface_securities
@dmp_regression_unittest
@1004_tom_4479_bnp_dmp_security
Feature: BNP to DMP Security feed - Field Mapping - Foreign Exchange

  Description of the feature:
  As a part of this feature, we are testing:
  1. Loading Foreign Exchange Security Feed
  2. Validating Foreign Exchange specific fields mapping for FT_T_FINS, FT_T_ISCL , FT_T_ISID, FT_T_FIID and FT_T_FRIP tables as per Specifications

  Scenario: Assign Variables

    Given I assign "tests/test-data/Regression-DMP/SOD/BNP_TO_DMP/Security/TOM-4479" to variable "testdata.path"
    And I assign "ESISODP_SEC_FX_LOAD.out" to variable "INPUT_FILENAME"

  Scenario Outline: Clear existing data for the row <RowNum> in the input file

    Given I extract below values for row <RowNum> from PSV file "${INPUT_FILENAME}" in local folder "${testdata.path}/testdata" and assign to variables:
      | INSTR_ID          | VAR_INSTR_ID          |
      | ISIN              | VAR_ISIN              |
      | SEDOL             | VAR_SEDOL             |
      | HIP_SECURITY_CODE | VAR_HIP_SECURITY_CODE |

    Then I set end_tms to SYSDATE in database "dmp.db.VD" where iss_id in "'${VAR_INSTR_ID}','${VAR_ISIN}','${VAR_SEDOL}','${VAR_HIP_SECURITY_CODE}'"
    And I set end_tms to SYSDATE in database "dmp.db.GC" where iss_id in "'${VAR_INSTR_ID}','${VAR_ISIN}','${VAR_SEDOL}','${VAR_HIP_SECURITY_CODE}'"

    Examples:
      | RowNum |
      | 2      |
      | 3      |
      | 4      |

  Scenario: Load Security File for Foreign Exchange

    When I copy files below from local folder "${testdata.path}/testdata" to the host "dmp.ssh.inbound" folder "${dmp.ssh.inbound.path}":
      | ${INPUT_FILENAME} |

    And I process files with below parameters and wait for the job to be completed
      | BUSINESS_FEED |                     |
      | FILE_PATTERN  | ${INPUT_FILENAME}   |
      | MESSAGE_TYPE  | EIS_MT_BNP_SECURITY |

  Scenario Outline: Validate FX Type <FXType>

    Given I extract below values for row <RowNum2> from PSV file "${INPUT_FILENAME}" in local folder "${testdata.path}/testdata" and assign to variables:
      | INSTR_ID        | VAR_INSTR_ID        |
      | INSTR_TYPE      | VAR_INSTR_TYPE      |
      | ISSUE_CCY       | VAR_ISSUE_CCY       |
      | COUNTRY_OF_RISK | VAR_COUNTRY_OF_RISK |
      | HIP_BROKER_CODE | VAR_HIP_BROKER_CODE |
      | HIP_BROKER_NAME | VAR_HIP_BROKER_NAME |

    Then I execute below query and extract values of "INSTRUMENT_ID" into same variables
    """
      SELECT INSTR_ID AS INSTRUMENT_ID FROM FT_T_ISID WHERE ISS_ID IN ('${VAR_INSTR_ID}') AND END_TMS IS NULL
    """

    And I expect value of column "CL_VALUE" in the below SQL query equals to "1":
    """
      SELECT COUNT(*) AS CL_VALUE
      FROM FT_T_ISCL
      WHERE INSTR_ID = '${INSTRUMENT_ID}'
      AND INDUS_CL_SET_ID = 'BNPSECTYPE'
      AND CL_VALUE = '${VAR_INSTR_TYPE}'
    """

    And I expect value of column "CLSF_OID" in the below SQL query equals to "1":
    """
      SELECT COUNT(*) AS CLSF_OID
      FROM FT_T_ISCL
      WHERE INSTR_ID = '${INSTRUMENT_ID}'
      AND CLSF_OID IN (SELECT CLSF_OID FROM FT_T_INCL WHERE CL_VALUE = '${VAR_INSTR_TYPE}'
      AND CL_NME = '${VAR_INSTR_TYPE}'
      AND INDUS_CL_SET_ID = 'BNPSECTYPE' AND LEVEL_NUM = '1')
    """

    Examples:
      | RowNum2 | FXType  |
      | 2       | Spot    |
      | 3       | Forward |
      | 4       | NDF     |

  ############################## Validating HIP_BROKER_CODE and HIP_BROKER_NAME ###############################
  @ignore
  Scenario Outline: Verification <ScenarioDefinition>

    Given I extract below values for row <RowNum3> from PSV file "${INPUT_FILENAME}" in local folder "${testdata.path}/testdata" and assign to variables:
      | INSTR_ID        | VAR_INSTR_ID        |
      | HIP_BROKER_CODE | VAR_HIP_BROKER_CODE |
      | HIP_BROKER_NAME | VAR_HIP_BROKER_NAME |


    Then I expect value of column "InstrumentName" in the below SQL query equals to "1":
      """
        <Query>
      """

    And I expect value of column "HIPBrokerDef" in the below SQL query equals to "1":
    """
      SELECT COUNT(*) AS HIPBrokerDef
      FROM FT_T_FIID
      WHERE FINS_ID = '${VAR_HIP_BROKER_CODE}'
      AND FINS_ID_CTXT_TYP = 'HIPBROKER'
    """

    And I expect value of column "Expected3" in the below SQL query equals to "1":
    """
      SELECT COUNT(*) AS Expected3
      FROM FT_T_FRIP
      WHERE INSTR_ID = '${INSTRUMENT_ID}'
      AND INST_MNEM IN (SELECT INST_MNEM FROM FT_T_FIID WHERE FINS_ID = '${VAR_HIP_BROKER_CODE}' AND FINS_ID_CTXT_TYP = 'HIPBROKER')
      AND DATA_STAT_TYP = 'ACTIVE'
      AND FINSRL_TYP = 'ISSUER'
      AND PRT_PURP_TYP = 'BNPISSR'
     """

    Examples:
      | RowNum3 | ScenarioDefinition                                      | Query                                                                                             |
      | 2       | when HIP_BROKER_CODE and HIP_BROKER_NAME are present    | SELECT COUNT(*) AS InstrumentName FROM FT_T_FINS WHERE INST_NME = UPPER('${VAR_HIP_BROKER_NAME}') |
      | 3       | when HIP_BROKER_CODE is present, but no HIP_BROKER_NAME | SELECT COUNT(*) AS InstrumentName FROM FT_T_FINS WHERE INST_NME = '${VAR_HIP_BROKER_CODE}'        |
      | 4       | when HIP_BROKER_NAME is present, but no HIP_BROKER_CODE | SELECT COUNT(*) AS InstrumentName FROM FT_T_FINS WHERE INST_NME = UPPER('${VAR_HIP_BROKER_NAME}') |