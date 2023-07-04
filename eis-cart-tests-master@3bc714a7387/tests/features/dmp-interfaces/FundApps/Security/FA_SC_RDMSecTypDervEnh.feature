#https://jira.intranet.asia/browse/TOM-4766
# https://collaborate.intranet.asia/pages/viewpage.action?spaceKey=TOMR3&title=Security+Asset+Classification+-+Data+Management+Platform#businessRequirements-508441805
# EISRDMSecurityTypeDerivation rule which derives the RDM Sec type has been enhanced with additional parameters for ETF
# When F10 comes in with SM_SEC_GROUP = EQUITY , SM_SEC_TYPE  = EQUITY  , DESC_INSTMT2 = ETF-F then the DERIVED RDMSCTYP = ETF
# For purposes of testing we have considered the above scenario for details refer the JIRA link above

@tom_4766

Feature: TOM-4766 Feature file to validate the enhancement done in the EISRDMSecurityTypeDerivation rule, plugged additional parameters for ETF

  Scenario: Assign variables and Clear old test data from ISCL

    Given I assign "tests/test-data/dmp-interfaces/FundApps/RDMSecDerv" to variable "testdata.path"
    Given I assign "200" to variable "workflow.max.polling.time"

    And I execute below query

     """
    ${testdata.path}/sql/Clear_Data_ISCL.sql
     """

  Scenario: Load BRS record

    Given I assign "F10-ETF-CHECK.xml" to variable "BRS_INPUT_FILE"

    When I copy files below from local folder "${testdata.path}/infiles" to the host "dmp.ssh.inbound" folder "${dmp.ssh.inbound.path}":
      | ${BRS_INPUT_FILE} |

    And I process files with below parameters and wait for the job to be completed
      | FILE_PATTERN  | ${BRS_INPUT_FILE}       |
      | MESSAGE_TYPE  | EIS_MT_BRS_SECURITY_NEW |
      | BUSINESS_FEED |                         |

    Then I extract new job id from jblg table into a variable "JOB_ID"
    And I expect value of column "JBLG_ROW_COUNT" in the below SQL query equals to "1":
      """
      SELECT count(*) as JBLG_ROW_COUNT FROM FT_T_JBLG
      WHERE JOB_ID = '${JOB_ID}'
      AND JOB_STAT_TYP ='CLOSED'
      """
    Then I expect value of column "RDMSCTYP_COUNT" in the below SQL query equals to "1":
      """
      SELECT count(*) as RDMSCTYP_COUNT FROM FT_T_ISCL
      WHERE INDUS_CL_SET_ID in ('RDMSCTYP')
      AND CL_VALUE ='ETF'
      AND INSTR_ID in (select INSTR_ID from ft_t_isid where iss_id in ('IE00BZ036H21') and id_ctxt_typ ='ISIN' and end_tms is null)
      AND END_TMS IS NULL
      """