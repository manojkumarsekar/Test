# =====================================================================
# Date            JIRA        Comments
# ============    ========    ========
# 13/12/2018      TOM-4027    First Version
# This feature file is to test loading share outstanding file from BRS
# =====================================================================

@gc_interface_shares
@dmp_regression_unittest
@tom_4027 @shares_outstanding
Feature: Shares Outstanding Inbound

  Load Shares outstanding input file containing 9 records.

  Scenario: Set variables and run cleardown script

    Given I assign "shares_outstanding.20181212.xml" to variable "INPUT_FILENAME"
    And I assign "tests/test-data/DevTest/TOM-4027" to variable "testdata.path"

    When I copy files below from local folder "${testdata.path}/testdata" to the host "dmp.ssh.inbound" folder "${dmp.ssh.inbound.path}":
      | ${INPUT_FILENAME} |

    When I execute below query
    """
    ${testdata.path}/sql/ClearData_001.sql
    """

    Then I expect value of column "SECURITY_COUNT" in the below SQL query equals to "0":
    """
    select count(instr_id) as SECURITY_COUNT
    from ft_t_ismc
    where instr_id IN (SELECT instr_id from ft_t_isid where iss_id in ('SBRJFWP37', 'BRSU9DTQ8', 'G2519Y108') and id_ctxt_typ = 'BCUSIP')
    and last_chg_tms > Trunc(sysdate)
    and capital_typ IN ('SO', 'AO', 'CSO', 'JPCSO')
    and end_tms is null
    """

    And I process files with below parameters and wait for the job to be completed
      | BUSINESS_FEED |                               |
      | FILE_PATTERN  | ${INPUT_FILENAME}             |
      | MESSAGE_TYPE  | EIS_MT_BRS_SHARES_OUTSTANDING |

    Then I expect value of column "SO_SECURITY_COUNT" in the below SQL query equals to "3":
    """
    select count(instr_id) as SO_SECURITY_COUNT
    from ft_t_ismc
    where instr_id IN (SELECT instr_id from ft_t_isid where iss_id in ('SBRJFWP37', 'BRSU9DTQ8', 'G2519Y108') and id_ctxt_typ = 'BCUSIP')
    and last_chg_tms > Trunc(sysdate)
    and capital_typ = 'SO'
    and end_tms is null
    """

    Then I expect value of column "CSO_SECURITY_COUNT" in the below SQL query equals to "3":
    """
    select count(instr_id) as CSO_SECURITY_COUNT
    from ft_t_ismc
    where instr_id IN (SELECT instr_id from ft_t_isid where iss_id in ('SBRJFWP37', 'BRSU9DTQ8', 'G2519Y108') and id_ctxt_typ = 'BCUSIP')
    and last_chg_tms > Trunc(sysdate)
    and capital_typ = 'CSO'
    and end_tms is null
    """

    Then I expect value of column "JPCSO_SECURITY_COUNT" in the below SQL query equals to "3":
    """
    select count(instr_id) as JPCSO_SECURITY_COUNT
    from ft_t_ismc
    where instr_id IN (SELECT instr_id from ft_t_isid where iss_id in ('SBRJFWP37', 'BRSU9DTQ8', 'G2519Y108') and id_ctxt_typ = 'BCUSIP')
    and last_chg_tms > Trunc(sysdate)
    and capital_typ = 'JPCSO'
    and end_tms is null
    """

    Then I expect value of column "AO_SECURITY_COUNT" in the below SQL query equals to "2":
    """
    select count(instr_id) as AO_SECURITY_COUNT
    from ft_t_ismc
    where instr_id IN (SELECT instr_id from ft_t_isid where iss_id in ('056752AM0', '73928RAA4') and id_ctxt_typ = 'BCUSIP')
    and last_chg_tms > Trunc(sysdate)
    and capital_typ = 'AO'
    and end_tms is null
    """
