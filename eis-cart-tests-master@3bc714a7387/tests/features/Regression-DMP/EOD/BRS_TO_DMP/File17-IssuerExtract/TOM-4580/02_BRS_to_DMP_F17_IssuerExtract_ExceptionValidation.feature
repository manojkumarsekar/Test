#Ticket link : https://jira.intranet.asia/browse/TOM-4580
#Parent Ticket: https://jira.intranet.asia/browse/TOM-1558
#Requirement Links: https://collaborate.intranet.asia/pages/viewpage.action?pageId=29002538#Test-logicalMapping

@gc_interface_issuer
@dmp_regression_unittest
@02_tom_4580_brs_dmp_f17_issuer_extract
Feature: BRS to DMP EOD ASIA - Issuer Extract - Exception Validation

  Validate that system throw exception and should not process the records when:
  1.) ISSUER_ID is NULL
  2.) NAME is NULL
  3.) LONG_NAME is NULL
  4.) Invalid value in COUNTRY field
  5.) Invalid value in COUNTRY_INC field
  6.) REVIEWED is NULL

  Scenario: Load F17 from BRS to DMP

    Given I assign "tests/test-data/Regression-DMP/EOD/BRS_TO_DMP/File17-IssuerExtract/TOM-4580" to variable "testdata.path"
    And I assign "esi_ADX_EOD_ASIA_Template_ExceptionVal.xml" to variable "INPUTFILE_TEMPLATE"
    And I assign "esi_ADX_EOD_ASIA_ExceptionVal.xml" to variable "INPUT_FILENAME"

    And I generate value with date format "mmss" and assign to variable "TIMESTAMP"

    When I create input file "${INPUT_FILENAME}" using template "${INPUTFILE_TEMPLATE}" with below codes from location "${testdata.path}"
      | ISSUER_ID2 | ${TIMESTAMP}02 |
      | ISSUER_ID3 | ${TIMESTAMP}03 |
      | ISSUER_ID4 | ${TIMESTAMP}04 |
      | ISSUER_ID5 | ${TIMESTAMP}05 |
      | ISSUER_ID6 | ${TIMESTAMP}06 |

    And I copy files below from local folder "${testdata.path}/testdata" to the host "dmp.ssh.inbound" folder "${dmp.ssh.inbound.path}":
      | ${INPUT_FILENAME} |

    When I process files with below parameters and wait for the job to be completed
      | BUSINESS_FEED |                   |
      | FILE_PATTERN  | ${INPUT_FILENAME} |
      | MESSAGE_TYPE  | EIS_MT_BRS_ISSUER |

    Then I extract new job id from jblg table into a variable "JOB_ID"

    #Verify 1 record processed successfully - When REVIEWED is NULL
    And I expect value of column "SUCCESS_COUNT" in the below SQL query equals to "1":
    """
    SELECT TASK_SUCCESS_CNT AS SUCCESS_COUNT FROM FT_T_JBLG WHERE JOB_ID='${JOB_ID}'
    """

  Scenario Outline:  Validate that system throw exception when <ScenarioDescription> in Record <Index>

    Then I expect value of column "EXCEPTION" in the below SQL query equals to "1":
    """
    SELECT COUNT(*) AS EXCEPTION FROM FT_T_NTEL NTEL
    JOIN FT_T_TRID TRID
    ON NTEL.LAST_CHG_TRN_ID = TRID.TRN_ID
    AND TRID.JOB_ID = '${JOB_ID}'
    WHERE NTEL.SOURCE_ID = 'TRANSLATION'
    AND NTEL.NOTFCN_STAT_TYP = 'OPEN'
    AND NTEL.NOTFCN_ID = 60001
    AND NTEL.MSG_SEVERITY_CDE = '40'
    AND NTEL.PART_ID = 'TRANS'
    AND NTEL.PARM_VAL_TXT LIKE '<Exception>%'
    """

    Examples:
      | Index | ScenarioDescription | Exception                                                                                                          |
      | 1     | ISSUER_ID is NULL   | User defined Error thrown! . Cannot process file as required fields, ISSUER_ID is not present in the input record. |
      | 2     | NAME is NULL        | User defined Error thrown! . Cannot process file as required fieldsNAME is not present in the input record.        |
      | 3     | LONG_NAME is NULL   | User defined Error thrown! . Cannot process file as required fields,LONG_NAME is not present in the input record.  |

  Scenario: Validate that system throw exception when COUNTRY is having an Invalid value in Record 4

    When I extract value from the xml file "${testdata.path}/testdata/${INPUT_FILENAME}" with xpath "//ISSUER_ID" at index 3 to variable "VAR_ISSUER_ID4"
    And I extract value from the xml file "${testdata.path}/testdata/${INPUT_FILENAME}" with xpath "//COUNTRY" at index 3 to variable "VAR_COUNTRY"

    Then I expect value of column "EXCEPTION_COUNTRY" in the below SQL query equals to "1":
    """
      SELECT COUNT(*) AS EXCEPTION_COUNTRY FROM FT_T_NTEL NTEL
      JOIN FT_T_TRID TRID
      ON NTEL.LAST_CHG_TRN_ID = TRID.TRN_ID
      AND TRID.JOB_ID = '${JOB_ID}'
      WHERE NTEL.SOURCE_ID LIKE '%GS_GC%'
      AND NTEL.NOTFCN_STAT_TYP = 'OPEN'
      AND NTEL.NOTFCN_ID = 11
      AND NTEL.MSG_SEVERITY_CDE = '40'
      AND NTEL.PART_ID = 'NESTED'
      AND NTEL.MAIN_ENTITY_ID = '${VAR_ISSUER_ID4}'
      AND NTEL.PARM_VAL_TXT = 'COUNTRY ${VAR_COUNTRY} BRS GeographicUnit'
      AND NTEL.CHAR_VAL_TXT = 'The Geographic Unit ''COUNTRY - ${VAR_COUNTRY}'' received from BRS is not present in the GeographicUnit.'
    """

  Scenario: Validate that system throw exception when COUNTRY_INC is having an Invalid value in Record 5

    When I extract value from the xml file "${testdata.path}/testdata/${INPUT_FILENAME}" with xpath "//ISSUER_ID" at index 4 to variable "VAR_ISSUER_ID5"
    When I extract value from the xml file "${testdata.path}/testdata/${INPUT_FILENAME}" with xpath "//COUNTRY_INC" at index 4 to variable "VAR_COUNTRY_INC"

    Then I expect value of column "EXCEPTION_COUNTRY_INC" in the below SQL query equals to "1":
   """
      SELECT COUNT(*) AS EXCEPTION_COUNTRY_INC FROM FT_T_NTEL NTEL
      JOIN FT_T_TRID TRID
      ON NTEL.LAST_CHG_TRN_ID = TRID.TRN_ID
      AND TRID.JOB_ID = '${JOB_ID}'
      WHERE NTEL.SOURCE_ID LIKE '%GS_GC%'
      AND NTEL.NOTFCN_STAT_TYP = 'OPEN'
      AND NTEL.NOTFCN_ID = 11
      AND NTEL.MSG_SEVERITY_CDE = '40'
      AND NTEL.PART_ID = 'NESTED'
      AND NTEL.MAIN_ENTITY_ID = '${VAR_ISSUER_ID5}'
      AND NTEL.PARM_VAL_TXT = 'COUNTRY ${VAR_COUNTRY_INC} BRS GeographicUnit'
      AND NTEL.CHAR_VAL_TXT = 'The Geographic Unit ''COUNTRY - ${VAR_COUNTRY_INC}'' received from BRS is not present in the GeographicUnit.'
      """

  Scenario: Validate that No Record Added to FICL Table when REVIEWED is NULL in Record 6

    # Extracting the ISSUER_ID value from the file:
    When I extract value from the xml file "${testdata.path}/testdata/${INPUT_FILENAME}" with xpath "//ISSUER_ID" at index 5 to variable "VAR_ISSUER_ID6"

    # Extracting the INST_MNEM
    And I execute below query and extract values of "VAR_INST_MNEM" into same variables
    """
      SELECT FINS.INST_MNEM AS VAR_INST_MNEM
      FROM FT_T_FINS FINS
      INNER JOIN FT_T_FIID FIID
      ON FIID.FINS_ID = FINS.PREF_FINS_ID
      AND FIID.FINS_ID_CTXT_TYP = FINS.PREF_FINS_ID_CTXT_TYP
      WHERE FIID.FINS_ID = '${VAR_ISSUER_ID6}'
      AND FIID.FINS_ID_CTXT_TYP = 'BRSISSRID'
      AND FINS.DATA_STAT_TYP = 'ACTIVE'
      AND FINS.LAST_CHG_USR_ID = 'EIS_BRS_DMP_ISSUER'
    """

    # Extracting the REVIEWED value from the file:
    When I extract value from the xml file "${testdata.path}/testdata/${INPUT_FILENAME}" with xpath "//REVIEWED" at index 5 to variable "VAR_REVIEWED"

    # FT_T_FICL : FinancialInstitutionClassification
    Then I expect value of column "EXPECTED" in the below SQL query equals to "0":
    """
      SELECT COUNT(*) AS EXPECTED
      FROM FT_T_FICL
      WHERE INST_MNEM = '${VAR_INST_MNEM}'
      AND DATA_SRC_ID = 'BRS'
      AND DATA_STAT_TYP = 'ACTIVE'
      AND LAST_CHG_USR_ID = 'EIS_BRS_DMP_ISSUER'
      AND INDUS_CL_SET_ID = 'REVIEWED'
      AND CL_VALUE = '${VAR_REVIEWED}'
    """