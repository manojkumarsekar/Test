#TOM:4636: Initial Version: https://collaborate.intranet.asia/pages/viewpage.action?pageId=58887782#Test-TechnicalDescription
#EISDEV-6747 : Added use case for end-dated acgp

@gc_interface_npp @gc_interface_positions @001_verify_np_position_load
@dmp_regression_unittest
@tom_4636 @eisdev_6747
Feature: 001 | NPP | BRS - DMP | Verify ADX NP Pos Load

  As per Non-Processing Portfolio(NPP) design, we would be receiving the Positions data for Non-Processing Portfolios for BRS in ADX NP and ADX NP XQ Package
  This feature file covers loading of Positions data for NPP
  Sample Data

  BCUSIP     | PORTFOLIO | Use Case
  92840M102  | B096573   | Portfolio B096573 is part of PortGroup "ESI_SSDRRT", Positions would be loaded with Requester Id, BRSNPEOD
  125523100  | B096573   | Portfolio B096573 is part of PortGroup "ESI_SSDRRT", Positions would be loaded with Requester Id, BRSNPEOD
  BRSRV3FP9  | AZPAIE    | Portfolio AZPAIE is not part of PortGroup "ESI_SSDRRT", Positions would be Filtered
  92840M102  | ALWVEU    | Portfolio ALWVEU is part of PortGroup "ESI_SSDRRT" but in the Exclusion List in Domains for Fld_id ='BRSEODEX', Positions would be Filtered
  344849104  | ALWVEU    | Portfolio ALWVEU is part of PortGroup "ESI_SSDRRT" but in the Exclusion List in Domains for Fld_id ='BRSEODEX', Positions would be Filtered
  92840M102  | TT37_S    | Portfolio TT37_S is part of PortGroup "TW_GFNPROC" and has one end_dated and one active record in ACGP, Positions would be loaded with Requester Id, BRSNPEOD

  Scenario: Assign Variables and Create Input Files with T-1 Data

    Given I assign "tests/test-data/dmp-interfaces/NPP/BRS_EOD" to variable "TESTDATA_PATH"
    And I assign "pos_np.xml" to variable "INPUTFILE_NAME"
    And I assign "${dmp.ssh.inbound.path}/reuters" to variable "RT_PATH_IN"
    And I assign "${dmp.ssh.outbound.path}/reuters" to variable "RT_PATH_OUT"
    And I assign "${dmp.ssh.outbound.path}/reuters/done" to variable "RT_PATH_DONE"

    #Create Positions File
    And I execute below query and extract values of "T_1_MMDDYYYY" into same variables
     """
     select TO_CHAR(sysdate-1, 'MM/DD/YYYY') AS T_1_MMDDYYYY from dual
     """

    And I create input file "${INPUTFILE_NAME}" using template "pos.np.template.xml" from location "${TESTDATA_PATH}/inputfiles"

  Scenario: Set-Up PortGroup and PortGroup-Participant, if it does not exist

    Given I execute below query
	"""
    Insert into FT_T_ACGR (ACCT_GRP_OID,ACCT_GRP_ID,GRP_PURP_TYP,START_TMS,LAST_CHG_TMS,LAST_CHG_USR_ID,GRP_DESC,GRP_NME,DATA_SRC_ID)
    select 'ESI_SSDRRT','ESI_SSDRRT','UNIVERSE',sysdate,sysdate,'ESAUTOMATION','Non processing portfolio group for extracts','ESI_SSDRRT','BRS' from dual
    where not exists (select 1 from ft_t_acgr where GRP_NME = 'ESI_SSDRRT');

    Insert into FT_T_ACGP (PRNT_ACCT_GRP_OID,START_TMS,ACCT_ORG_ID,ACCT_BK_ID,ACCT_ID,PRT_PURP_TYP,LAST_CHG_TMS,LAST_CHG_USR_ID,PRT_DESC,DATA_SRC_ID,ACGP_OID)
    select (select acct_grp_oid from ft_t_acgr where GRP_NME = 'ESI_SSDRRT'),sysdate,'EIS ','EIS ','GS0000000728','MEMBER  ',sysdate,'ESAUTOMATION','BRS Portfolio Group','BRS',new_oid from dual
    where not exists (select 1 from ft_t_acgp where PRNT_ACCT_GRP_OID in (select acct_grp_oid from ft_t_acgr where GRP_NME = 'ESI_SSDRRT') and acct_id = 'GS0000000728');

    COMMIT
	"""

  Scenario: Load ADX NP POS File

    When I copy files below from local folder "${TESTDATA_PATH}/inputfiles/testdata" to the host "dmp.ssh.inbound" folder "${dmp.ssh.inbound.path}":
      | ${INPUTFILE_NAME} |

    And I process files with below parameters and wait for the job to be completed
      | FILE_PATTERN  | ${INPUTFILE_NAME}           |
      | MESSAGE_TYPE  | EIS_MT_BRS_EOD_POSITION_NPP |
      | BUSINESS_FEED |                             |

    Then I expect workflow is processed in DMP with success record count as "3"

    Then I expect workflow is processed in DMP with filtered record count as "3"

  Scenario: Verify Positions for Non Processing Portfolio are loaded with Requester Id BRSNPEOD

    Given I expect value of column "BRSNPEOD_POS_COUNT" in the below SQL query equals to "3":
    """
    select count(*) as BRSNPEOD_POS_COUNT from ft_t_balh where RQSTR_ID = 'BRSNPEOD'
    and acct_id in (select acct_id from ft_t_acid where acct_alt_id in ('B096573','TT37_S'))
    and as_of_tms = to_date('${T_1_MMDDYYYY}','MM/DD/YYYY')
    """