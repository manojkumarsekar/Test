#Ticket link : https://jira.intranet.asia/browse/TOM-4580
#Parent Ticket: https://jira.intranet.asia/browse/TOM-1558
#Requirement Links: https://collaborate.intranet.asia/pages/viewpage.action?pageId=29002538#Test-logicalMapping

@gc_interface_issuer
@dmp_regression_unittest
@01_tom_4580_brs_dmp_f17_issuer_extract
Feature: BRS to DMP EOD ASIA - Issuer Extract Positive Flow  - Field Mapping

  Description:
  Below Scenarios are handled as part of this feature:
  1. Loading EOD-ASIA-1: Issuer Extract - F17 Feed
  2. Validating fields mapping for Financial Institution tables as per Specifications

  Scenario: Load F17 from BRS to DMP

    Given I assign "tests/test-data/Regression-DMP/EOD/BRS_TO_DMP/File17-IssuerExtract/TOM-4580" to variable "testdata.path"
    And I assign "esi_ADX_EOD_ASIA_Template_PositiveFlow.xml" to variable "INPUTFILE_TEMPLATE"
    And I assign "esi_ADX_EOD_ASIA_PositiveFlow.xml" to variable "INPUT_FILENAME"

    And I generate value with date format "mmss" and assign to variable "TIMESTAMP"

    When I create input file "${INPUT_FILENAME}" using template "${INPUTFILE_TEMPLATE}" with below codes from location "${testdata.path}"
      | ISSUER_ID1 | ${TIMESTAMP}01 |

    And I copy files below from local folder "${testdata.path}/testdata" to the host "dmp.ssh.inbound" folder "${dmp.ssh.inbound.path}":
      | ${INPUT_FILENAME} |

    When I process files with below parameters and wait for the job to be completed
      | BUSINESS_FEED |                   |
      | FILE_PATTERN  | ${INPUT_FILENAME} |
      | MESSAGE_TYPE  | EIS_MT_BRS_ISSUER |

    Then I extract new job id from jblg table into a variable "JOB_ID"

    #verify all the records are processed successfully
    Then I expect value of column "SUCCESS_COUNT" in the below SQL query equals to "1":
    """
    SELECT TASK_SUCCESS_CNT AS SUCCESS_COUNT FROM FT_T_JBLG WHERE JOB_ID='${JOB_ID}'
    """

    # Extracting the tag values of first record in the file:
    When I extract below values from the xml file "${testdata.path}/testdata/${INPUT_FILENAME}"  with xpath or tagName at index 0 and assign to variables:
      | ISSUER_ID   | VAR_ISSUER_ID   |
      | LONG_NAME   | VAR_LONG_NAME   |
      | NAME        | VAR_NAME        |
      | COUNTRY     | VAR_COUNTRY     |
      | COUNTRY_INC | VAR_COUNTRY_INC |
      | ACTIVE      | VAR_ACTIVE      |
      | REVIEWED    | VAR_REVIEWED    |
      | WHEN_DONE   | VAR_WHEN_DONE   |


    And I execute below query and extract values of "VAR_INST_MNEM" into same variables
    """
      SELECT FINS.INST_MNEM AS VAR_INST_MNEM
      FROM FT_T_FINS FINS
      INNER JOIN FT_T_FIID FIID
      ON FIID.FINS_ID = FINS.PREF_FINS_ID
      AND FIID.FINS_ID_CTXT_TYP = FINS.PREF_FINS_ID_CTXT_TYP
      WHERE FIID.FINS_ID = '${VAR_ISSUER_ID}'
      AND FIID.FINS_ID_CTXT_TYP = 'BRSISSRID'
    """

  #  FT_T_FINS : FinancialInstitution
  Scenario: Validate LONG NAME, NAME and WHEN DONE Values Get Populated in Respective Fields of FT_T_FINS Table

    Then I expect value of column "EXPECTED1" in the below SQL query equals to "1":
    """
      SELECT COUNT(*) AS EXPECTED1
      FROM FT_T_FINS
      WHERE INST_MNEM = '${VAR_INST_MNEM}'
      AND INST_DESC = '${VAR_LONG_NAME}'
      AND INST_NME = UPPER('${VAR_LONG_NAME}')
      AND INST_STAT_TYP = '${VAR_ACTIVE}'
      AND INST_STAT_TMS = TO_TIMESTAMP(REGEXP_SUBSTR('${VAR_WHEN_DONE}','[^.]*'),'MM/DD/YYYY HH:MI:SS')
      AND DATA_SRC_ID = 'BRS'
      AND DATA_STAT_TYP = 'ACTIVE'
      AND LAST_CHG_USR_ID = 'EIS_BRS_DMP_ISSUER'
    """

  #  FT_T_FIID : FinancialInstitutionIdentifier
  Scenario: Validate ISSUER_ID is populated in FINS_ID Field of FT_T_FIID Table
    Then I expect value of column "ISSUER_ID" in the below SQL query equals to "1":
    """
      SELECT COUNT(*) AS ISSUER_ID
      FROM FT_T_FIID
      WHERE DATA_SRC_ID = 'BRS'
      AND DATA_STAT_TYP = 'ACTIVE'
      AND FINS_ID_CTXT_TYP = 'BRSISSRID'
      AND LAST_CHG_USR_ID = 'EIS_BRS_DMP_ISSUER'
      AND FINS_ID = '${VAR_ISSUER_ID}'
    """

  #  FT_T_FIDE : FinancialInstitutionDescription
  Scenario: Validate LONG NAME and NAME Values Get Populated in Respective Fields of FT_T_FIDE Table
    Then I expect value of column "EXPECTED2" in the below SQL query equals to "1":
    """
      SELECT COUNT(*) AS EXPECTED2
      FROM FT_T_FIDE
      WHERE INST_MNEM = '${VAR_INST_MNEM}'
      AND DATA_SRC_ID = 'BRS'
      AND DATA_STAT_TYP = 'ACTIVE'
      AND LAST_CHG_USR_ID = 'EIS_BRS_DMP_ISSUER'
      AND INST_DESC = '${VAR_LONG_NAME}'
      AND INST_NME = '${VAR_NAME}'
    """

  #  FT_T_FICL : FinancialInstitutionClassification
  Scenario: Validate REVIEWED Value Get Populated in CL_VALUE Field of FT_T_FICL Table
    Then I expect value of column "EXPECTED" in the below SQL query equals to "1":
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

  #  FT_T_FIGU : FinancialInstitutionGeoUnitPrt
  #  FT_T_GUNT : Geographic Unit
  Scenario: Validate COUNTRY Value Get Populated in PRNT_GU_ID Field of FT_T_GUNT Table and the Respective Fields Get Updated in FT_T_FIGU Table
    Then I expect value of column "COUNTRY_DOMICILE" in the below SQL query equals to "1":
    """
      SELECT COUNT(*) AS COUNTRY_DOMICILE
      FROM FT_T_FIGU FIGU
      INNER JOIN FT_T_GUNT GUNT
      ON GUNT.PRNT_GU_CNT = FIGU.GU_CNT
      AND GUNT.PRNT_GU_ID = FIGU.GU_ID
      AND GUNT.PRNT_GU_TYP = FIGU.GU_TYP
      WHERE FIGU.INST_MNEM = '${VAR_INST_MNEM}'
      AND GUNT.PRNT_GU_TYP = 'COUNTRY'
      AND GUNT.PRNT_GU_CNT = '1'
      AND GUNT.PRNT_GU_ID = '${VAR_COUNTRY}'
      AND FIGU.DATA_SRC_ID = 'BRS'
      AND FIGU.DATA_STAT_TYP = 'ACTIVE'
      AND FIGU.LAST_CHG_USR_ID = 'EIS_BRS_DMP_ISSUER'
      AND FIGU.FINS_GU_PURP_TYP = 'DOMICILE'
     """

  #  FT_T_FIGU : FinancialInstitutionGeoUnitPrt
  #  FT_T_GUNT : Geographic Unit
  Scenario: Validate COUNTRY_INC Value Get Populated in PRNT_GU_ID Field of FT_T_GUNT Table and the Respective Fields Get Updated in FT_T_FIGU Table
    Then I expect value of column "COUNTRY_INC_INCRPRTE" in the below SQL query equals to "1":
    """
      SELECT COUNT(*) AS COUNTRY_INC_INCRPRTE
      FROM FT_T_FIGU FIGU
      INNER JOIN FT_T_GUNT GUNT
      ON GUNT.PRNT_GU_CNT = FIGU.GU_CNT
      AND GUNT.PRNT_GU_ID = FIGU.GU_ID
      AND GUNT.PRNT_GU_TYP = FIGU.GU_TYP
      WHERE FIGU.INST_MNEM = '${VAR_INST_MNEM}'
      AND GUNT.PRNT_GU_TYP = 'COUNTRY'
      AND GUNT.PRNT_GU_CNT = '1'
      AND GUNT.PRNT_GU_ID = '${VAR_COUNTRY_INC}'
      AND FIGU.DATA_SRC_ID = 'BRS'
      AND FIGU.DATA_STAT_TYP = 'ACTIVE'
      AND FIGU.LAST_CHG_USR_ID = 'EIS_BRS_DMP_ISSUER'
      AND FIGU.FINS_GU_PURP_TYP = 'INCRPRTE'
    """

  #  FT_T_FINR : FINSFinancialInstitutionRole
  Scenario: Validate FT_T_FINR Table Get Updated
    Then I expect value of column "FINSRL_TYP" in the below SQL query equals to "1":
    """
      SELECT COUNT(*) AS FINSRL_TYP
      FROM FT_T_FINR
      WHERE INST_MNEM = '${VAR_INST_MNEM}'
      AND FINSRL_TYP = 'ISSUER'
    """

