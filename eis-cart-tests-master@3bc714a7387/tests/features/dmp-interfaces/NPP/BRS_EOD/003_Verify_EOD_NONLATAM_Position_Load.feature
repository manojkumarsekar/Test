#TOM:4636: Initial Version: https://collaborate.intranet.asia/pages/viewpage.action?pageId=58887782#Test-TechnicalDescription

@gc_interface_npp @gc_interface_positions @003_eod_nonlatam_position_load
@dmp_regression_unittest
@tom_4636
Feature: 003 | EOD | NONLATAM Position Load

  As per Non-Processing Portfolio(NPP) design, we would be receiving the Positions data for Non-Processing Portfolios
  for BRS in ADX NP and ADX NP XQ Package We have updated Requester id mapping, verifying existing nonlatam/latam interfaces
  work as expected

  Scenario: Assign Variables and Create Input Files with T-1 Data
    Given I assign "tests/test-data/dmp-interfaces/NPP/BRS_EOD" to variable "TESTDATA_PATH"
    And I assign "pos_nonlatam.xml" to variable "INPUTFILE_NAME"

    #Create Positions File
    And I execute below query and extract values of "T_1_MMDDYYYY" into same variables
     """
     select TO_CHAR(sysdate-1, 'MM/DD/YYYY') AS T_1_MMDDYYYY from dual
     """

    And I create input file "${INPUTFILE_NAME}" using template "pos.nonlatam.template.xml" from location "${TESTDATA_PATH}/inputfiles"

  Scenario: Load ADX NONLATAM POS File

    When I copy files below from local folder "${TESTDATA_PATH}/inputfiles/testdata" to the host "dmp.ssh.inbound" folder "${dmp.ssh.inbound.path}":
      | ${INPUTFILE_NAME} |

    And I process files with below parameters and wait for the job to be completed
      | FILE_PATTERN  | ${INPUTFILE_NAME}                 |
      | MESSAGE_TYPE  | EIS_MT_BRS_EOD_POSITION_NON_LATAM |
      | BUSINESS_FEED |                                   |

    Then I extract new job id from jblg table into a variable "JOB_ID"

    And I expect value of column "JBLG_ROW_COUNT" in the below SQL query equals to "1":
    """
    SELECT count(*) as JBLG_ROW_COUNT FROM FT_T_JBLG
    WHERE JOB_ID = '${JOB_ID}'
    AND JOB_STAT_TYP ='CLOSED'
    """

  Scenario: Verify Positions for Non Processing Portfolio are loaded with Requester Id BRSNPEOD

    Given I expect value of column "BRSNPEOD_POS_COUNT" in the below SQL query equals to "4":
    """
    select count(*) as BRSNPEOD_POS_COUNT from ft_t_balh where RQSTR_ID = 'BRSEOD'
    and acct_id in (select acct_id from ft_t_acid where acct_alt_id in ('ALFISA','AHHLDF','NDEIFF','18STAR'))
    and as_of_tms = to_date('${T_1_MMDDYYYY}','MM/DD/YYYY')
    """

  Scenario: Verify Positions for Non Processing Portfolio configured in EXCLUSION LIST is filtered

    Given I expect value of column "TASK_FILTERED_CNT" in the below SQL query equals to "1":
    """
    SELECT TASK_FILTERED_CNT FROM FT_T_JBLG
    WHERE JOB_ID = '${JOB_ID}'
    """