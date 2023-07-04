#https://jira.intranet.asia/browse/TOM-4970
# https://collaborate.intranet.asia/pages/viewpage.action?spaceKey=TOMR3&title=Security+Asset+Classification+-+Data+Management+Platform#businessRequirements-508441805
# EISRDMSecurityTypeDerivation rule which derives the RDM Sec type has been changed for deriving NVDR
# When F10 comes in with SM_SEC_GROUP = EQUITY , SM_SEC_TYPE  = EQUITY  , DESC_INSTMT2 = blank , OTHER CRITERIA = DR_TYPE = 'T' then the DERIVED RDMSCTYP = NVDR
# Old Criteria was DR_TYPE = Any values that decodes into a value that includes 'Non Voting' Requirement: When DR_TYPE is NOT either 'A' or 'N'  AND When DESC_INSTMT like NON-VOTING or NON VOTING

@tom_4970

Feature: TOM-4970 Feature file to validate the configuration changes done in the EISRDMSecurityTypeDerivation rule to derive NVDR

  Scenario: Assign variables and Clear old test data from ISCL

    Given I assign "tests/test-data/dmp-interfaces/FundApps/RDMSecDerv" to variable "testdata.path"
    Given I assign "200" to variable "workflow.max.polling.time"

    And I execute below query

     """
    ${testdata.path}/sql/Clear_Data_ISCL_NVDR.sql
     """

  Scenario: Load BRS record

    Given I assign "F10-NVDR-CHECK.xml" to variable "BRS_NVDR_FILE"

    When I copy files below from local folder "${testdata.path}/infiles" to the host "dmp.ssh.inbound" folder "${dmp.ssh.inbound.path}":
      | ${BRS_NVDR_FILE} |

    And I process files with below parameters and wait for the job to be completed
      | FILE_PATTERN  | ${BRS_NVDR_FILE}        |
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
      AND CL_VALUE ='NVDR'
      AND INSTR_ID in (select INSTR_ID from ft_t_isid where iss_id in ('TH0889010R14') and id_ctxt_typ ='ISIN' and end_tms is null)
      AND END_TMS IS NULL
      """