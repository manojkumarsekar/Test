@gc_interface_securities
@dmp_regression_unittest
@tom_3742
Feature: Test multiple BNPLSTID are not created in ISID table with different Market ID for same security
  Issue Description: when same security with different Market is loaded by BNP files then it creates multiple entries in ISID table for different markets

  Solution: There should be only 1 BNPLSTID in ISID table for same security having multiple markets

  Steps Followed:
  1. Load BNP file with market EUCH
  2. Change the market id for BNPLSTID for security "MD_498637" in ISID table
  3. Load same BNP file again
  Expected Result: There should be only one entry for BNPLSTID in ISID and market id should be overwritten by latest market id in ISID table

  Scenario: TC_1: Load BNP file with Market as EUCH and verify MKT_OID same across ISID, MKIS and MKID table

    Given I assign "tests/test-data/DevTest/TOM-3742" to variable "testdata.path"
    And I assign "bnp_21sep_2.out" to variable "BNP_SECURITY_FILE1"

    And I execute below query to "Close already open identifiers/end date"
    """
    UPDATE ft_t_isid set start_tms= sysdate -1 , end_tms=sysdate -1
    where INSTR_ID in (select INSTR_ID from ft_t_isid where iss_id='MD_498637' and end_tms is null);
    COMMIT
    """

    When I copy files below from local folder "${testdata.path}/Inbound" to the host "dmp.ssh.inbound" folder "${dmp.ssh.inbound.path}":
      | ${BNP_SECURITY_FILE1} |

    And I process files with below parameters and wait for the job to be completed
      | BUSINESS_FEED |                       |
      | FILE_PATTERN  | ${BNP_SECURITY_FILE1} |
      | MESSAGE_TYPE  | EIS_MT_BNP_SECURITY   |

    Then I execute below query and extract values of "MKT_OID" into same variables
    """
    select MKT_OID
    from ft_t_mkid
    where MKT_ID ='EUCH'
    and MKT_ID_CTXT_TYP ='MIC'
    """

    Then I execute below query and extract values of "MKT_OID_AMEX" into same variables
    """
    select MKT_OID as MKT_OID_AMEX
    from ft_t_mkid
    where MKT_ID ='AMEX'
    """

    And I expect value of column "MKT_OID_COUNT" in the below SQL query equals to "1":
    """
    select count(distinct MKT_OID) as MKT_OID_COUNT
    from ft_t_isid
    where INSTR_ID IN (select INSTR_ID from ft_t_isid where iss_id='MD_498637' and end_tms is null)
    and MKT_OID is not null
    """

    And I expect value of column "MKT_OID" in the below SQL query equals to "${MKT_OID}":
    """
    select distinct MKT_OID
    from ft_t_isid
    where INSTR_ID IN (select INSTR_ID from ft_t_isid where iss_id='MD_498637' and end_tms is null)
    and MKT_OID is not null
    """

    When I execute below query
    """
    update ft_t_isid set MKT_OID = '${MKT_OID_AMEX}'
    where iss_id='MD_498637' and end_tms is null;
    COMMIT
    """

    When I copy files below from local folder "${testdata.path}/Inbound" to the host "dmp.ssh.inbound" folder "${dmp.ssh.inbound.path}":
      | ${BNP_SECURITY_FILE1} |

    And I process files with below parameters and wait for the job to be completed
      | BUSINESS_FEED |                       |
      | FILE_PATTERN  | ${BNP_SECURITY_FILE1} |
      | MESSAGE_TYPE  | EIS_MT_BNP_SECURITY   |

    Then I expect value of column "MKT_OID_COUNT" in the below SQL query equals to "1":
    """
    select count(distinct MKT_OID) as MKT_OID_COUNT
    from ft_t_isid
    where INSTR_ID IN (select INSTR_ID from ft_t_isid where iss_id='MD_498637' and end_tms is null)
    and MKT_OID is not null
    """

    And I expect value of column "MKT_OID" in the below SQL query equals to "${MKT_OID}":
    """
    select distinct MKT_OID
    from ft_t_isid
    where INSTR_ID IN (select INSTR_ID from ft_t_isid where iss_id='MD_498637' and end_tms is null)
    and MKT_OID is not null
    """