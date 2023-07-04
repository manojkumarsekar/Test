# =====================================================================
# Date            JIRA        Comments
# ============    ========    ========
# 16/12/2019      EISDEV-5428    Initial Version
# =====================================================================
# https://jira.pruconnect.net/browse/EISDEV-5428

@gc_interface_securities
@dmp_regression_unittest
@eisdev_5428
Feature: Identifier Mismatch for PRCCUSIP

  Test #1: Load security master EOD file
  System currently do not allow PRCCUSIP to be tagged to other securities if it is already tagged to an unique security,
  resulting in PRCCUSIP to be errored out for other securities. So ,BCUSIP should be able to have PRCCUSIP which belongs to another BCUSIP.

  Scenario: Assign variables

    Given I assign "sm1.xml" to variable "INPUT_SECURITY_FILENAME"
    And I assign "sm3.xml" to variable "INPUT_SECURITY_FILENAME2"
    And I assign "tests/test-data/DevTest/EISDEV-5428" to variable "testdata.path"

  Scenario: Prerequisites to cleardown existing data

      #Clear data for the given position from balh
    When I execute below query to "Clear data for the given position from FT_T_BALH"
    """
    delete from ft_T_isid where instr_id in (
     select instr_id from ft_T_isid
     where iss_id ='BRTUJRTW2')
     and id_ctxt_typ='PRCCUSIP'
     and end_tms is null
    """

  Scenario: Load SECURITY files

    When I copy files below from local folder "${testdata.path}/infiles" to the host "dmp.ssh.inbound" folder "${dmp.ssh.inbound.path}":
      | ${INPUT_SECURITY_FILENAME}  |
      | ${INPUT_SECURITY_FILENAME2} |


    And I process files with below parameters and wait for the job to be completed
      | BUSINESS_FEED |                            |
      | FILE_PATTERN  | ${INPUT_SECURITY_FILENAME} |
      | MESSAGE_TYPE  | EIS_MT_BRS_SECURITY_NEW    |

    And I process files with below parameters and wait for the job to be completed
      | BUSINESS_FEED |                             |
      | FILE_PATTERN  | ${INPUT_SECURITY_FILENAME2} |
      | MESSAGE_TYPE  | EIS_MT_BRS_SECURITY_NEW     |

  #Verification of successful File load INPUT_SECURITY_FILENAME2
    Then I expect workflow is processed in DMP with total record count as "1"
    And completed record count as "1"

  Scenario:  Verification of ISID table for the positions loaded with required data from file to check - BCUSIP should be able to have PRCCUSIP which belongs to another BCUSIP.

    Then I expect value of column "PRCCUSIP_COUNT" in the below SQL query equals to "2":
      """
      select count(*) as PRCCUSIP_COUNT
      from ft_T_isid
      where instr_id in (select instr_id from ft_T_isid
      where iss_id in('BRTVCVNZ7','BRTUJRTW2'))
      and id_ctxt_typ='PRCCUSIP'
      and end_tms is null
      """





