#https://jira.intranet.asia/browse/TOM-5267

@tom_5267 @dmp_interfaces @reporting_dmp_interfaces  @r6_regulatory_reporting @tom_5267_40char

Feature: This feature is to test the new fields mapped in GC from Security file for Regulatory Reporting when the length of field is equal to 40 characters


  Scenario: TC_1: Setup variables and data cleanup

    Given I assign "tests/test-data/dmp-interfaces/Reporting/RegulatoryReporting/Security" to variable "testdata.path"
    And I assign "003_RegReporting_SecurityNewFields_40CharOnly.xml" to variable "SECURITY_FILENAME"

    #Existing records for the security BPM0UJEC4 with the INDUS_CL_SET_ID that is being tested are deleted to make sure the data present is from the file load
    And I execute below query
    """
    ${testdata.path}/sql/RegReporting_DataCleanup.sql
    """


  Scenario: TC_2: Load Security file in DMP

    Given I copy files below from local folder "${testdata.path}/testdata/Inbound" to the host "dmp.ssh.inbound" folder "${dmp.ssh.inbound.path}":
      | ${SECURITY_FILENAME} |

    Then I process files with below parameters and wait for the job to be completed
      | BUSINESS_FEED |                           |
      | FILE_PATTERN  | ${SECURITY_FILENAME}      |
      | MESSAGE_TYPE  | EIS_MT_BRS_RISK_ANALYTICS |

    And I extract new job id from jblg table into a variable "VAR_JOB_ID"

    Then I expect value of column "SEC_LOAD_SCCS_COUNT" in the below SQL query equals to "1":
    """
    SELECT TASK_SUCCESS_CNT AS SEC_LOAD_SCCS_COUNT FROM FT_T_JBLG WHERE JOB_ID = '${VAR_JOB_ID}'
    """

  Scenario Outline: TC_3: Data Verification in ISCL table for INDUS_CL_SET_ID = <INDUS_CL_SET_ID>

    Then I expect value of column "CL_VALUE_COUNT" in the below SQL query equals to "1":
      """
      SELECT COUNT(*) AS CL_VALUE_COUNT FROM FT_T_ISCL
      WHERE INSTR_ID IN
      (
            SELECT INSTR_ID FROM FT_T_ISID WHERE ISS_ID = 'BPM0UJEC4'
      )
      AND INDUS_CL_SET_ID = '<INDUS_CL_SET_ID>'
      AND CL_VALUE = '<CL_VALUE>'
      """

    Examples:
      | INDUS_CL_SET_ID | CL_VALUE                                 |
      | ESICRESCT       | Equity Financials Diversified Financials |
      | BARCSCT         | Corporates FinancialInstitutions Banking |
      | GICSSCT         | Financials Banks Banks Diversified Banks |
      | FTSESCT         | Industrials Construction & Material Test |
      | FICTRYSCT       | Developed Asia Korea (South),Republic of |
      | EQCTRYSCT       | Developed Asia Korea (South),Republic of |


  Scenario Outline: TC_4: Data Verification in INCL table for INDUS_CL_SET_ID = <INDUS_CL_SET_ID>

    Then I expect value of column "CL_VALUE_COUNT" in the below SQL query equals to "1":
    """
      SELECT COUNT(*) AS CL_VALUE_COUNT FROM FT_T_INCL
      WHERE CLSF_OID IN
      (
            SELECT CLSF_OID FROM FT_T_ISCL
            WHERE INSTR_ID IN
            (
                  SELECT INSTR_ID FROM FT_T_ISID WHERE ISS_ID = 'BPM0UJEC4'
            )
      )
      AND INDUS_CL_SET_ID = '<INDUS_CL_SET_ID>'
      AND CL_VALUE = '<CL_VALUE>'
      AND CL_NME = '<CL_NAME>'
      """

    Examples:
      | INDUS_CL_SET_ID | CL_VALUE                                 | CL_NAME                                  |
      | ESICRESCT       | Equity Financials Diversified Financials | Equity Financials Diversified Financials |
      | BARCSCT         | Corporates FinancialInstitutions Banking | Corporates FinancialInstitutions Banking |
      | GICSSCT         | Financials Banks Banks Diversified Banks | Financials Banks Banks Diversified Banks |
      | FTSESCT         | Industrials Construction & Material Test | Industrials Construction & Material Test |
      | FICTRYSCT       | Developed Asia Korea (South),Republic of | Developed Asia Korea (South),Republic of |
      | EQCTRYSCT       | Developed Asia Korea (South),Republic of | Developed Asia Korea (South),Republic of |