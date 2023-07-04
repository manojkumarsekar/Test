@gc_interface_securities
@dmp_regression_integrationtest
@tom_3742
Feature: Test multiple BNPLSTID are not created in ISID table with different Market ID for same security
  Issue Description: when same security with different Market is loaded by BRS and BNP files then it creates multiple entries in ISID table where
  as 1 entry with higher rank(BRS) in MKIS table

  Solution: Preference should be given to BRS and it should reflect in both ISID and MKIS table for all the idetifiers including BNP

  Steps followed:
  1. Load BRS file with Market XEUR
  2. Load BNP file with Market EUCH
  3. Load BRS file with Market XEUR
  4. Load BNP file with Market XEUR
  Expected Result: There should not be multiple entryies for BNPLSTID for XEUR and EUCH. One Market ID for XEUR should be present for all the identifiers (Preference BRS)

  Scenario: TC_1: Load BRS file with Market as XEUR and verify MKT_OID same across ISID, MKIS and MKID table

    Given I assign "tests/test-data/DevTest/TOM-3742" to variable "testdata.path"
    And I assign "BRS_21SEP_1.xml" to variable "BRS_SECURITY_FILE1"
    And I extract value from the xml file "${testdata.path}/Inbound/${BRS_SECURITY_FILE1}" with tagName "EXCHANGE_MIC" to variable "MARKET"

    And I execute below query to "Close already open identifiers"
    """
    update ft_t_isid set start_tms= sysdate -1 , end_tms=sysdate -1
    where INSTR_ID in (select INSTR_ID from ft_t_isid where iss_id='SMZ820187' and end_tms is null);
    COMMIT
    """

    When I copy files below from local folder "${testdata.path}/Inbound" to the host "dmp.ssh.inbound" folder "${dmp.ssh.inbound.path}":
      | ${BRS_SECURITY_FILE1} |

    And I process files with below parameters and wait for the job to be completed
      | BUSINESS_FEED |                         |
      | FILE_PATTERN  | ${BRS_SECURITY_FILE1}   |
      | MESSAGE_TYPE  | EIS_MT_BRS_SECURITY_NEW |

    Then I execute below query and extract values of "MKT_OID" into same variables
      """
        select MKT_OID from ft_t_mkid where MKT_ID ='${MARKET}'
        and MKT_ID_CTXT_TYP ='MIC'
      """

    And I expect value of column "MKT_OID_COUNT" in the below SQL query equals to "1":
      """
        select count(distinct MKT_OID) as MKT_OID_COUNT
        from ft_t_isid
        where INSTR_ID IN (select INSTR_ID from ft_t_isid where iss_id='SMZ820187' and end_tms is null)
        and MKT_OID is not null
      """

    And I expect value of column "MKT_OID" in the below SQL query equals to "${MKT_OID}":
      """
        select distinct MKT_OID
        from ft_t_isid
        where INSTR_ID IN (select INSTR_ID from ft_t_isid where iss_id='SMZ820187' and end_tms is null)
        and MKT_OID is not null
      """

    And I expect value of column "MKT_OID" in the below SQL query equals to "${MKT_OID}":
      """
        select MKT_OID
        from ft_t_mkis
        where INSTR_ID IN (select INSTR_ID from ft_t_isid where iss_id='SMZ820187' and end_tms is null)
      """

  Scenario: TC_2: Load BNP file with Market as EUCH and verify MKT_OID same across ISID, MKIS and MKID table

    Given I assign "tests/test-data/DevTest/TOM-3742" to variable "testdata.path"
    And I assign "bnp_21sep_2.out" to variable "BNP_SECURITY_FILE1"
    And I extract value from the xml file "${testdata.path}/Inbound/${BRS_SECURITY_FILE1}" with tagName "EXCHANGE_MIC" to variable "MARKET"

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
        where MKT_ID ='${MARKET}'
        and MKT_ID_CTXT_TYP ='MIC'
      """

    And I expect value of column "MKT_OID_COUNT" in the below SQL query equals to "1":
      """
        select count(distinct MKT_OID) as MKT_OID_COUNT
        from ft_t_isid
        where INSTR_ID IN (select INSTR_ID from ft_t_isid where iss_id='SMZ820187' and end_tms is null)
        and MKT_OID is not null
      """

    And I expect value of column "MKT_OID" in the below SQL query equals to "${MKT_OID}":
      """
        select distinct MKT_OID
        from ft_t_isid
        where INSTR_ID IN (select INSTR_ID
        from ft_t_isid where iss_id='SMZ820187' and end_tms is null)
        and MKT_OID is not null
      """

    And I expect value of column "MKT_OID" in the below SQL query equals to "${MKT_OID}":
      """
        select MKT_OID
        from ft_t_mkis
        where INSTR_ID IN (select INSTR_ID from ft_t_isid where iss_id='SMZ820187' and end_tms is null)
      """

  Scenario: TC_3: Load BRS file Market as XEUR and verify MKT_OID same across ISID, MKIS and MKID table

    Given I assign "tests/test-data/DevTest/TOM-3742" to variable "testdata.path"
    And I assign "brs_22sep_3.xml" to variable "BRS_SECURITY_FILE2"
    And I extract value from the xml file "${testdata.path}/Inbound/${BRS_SECURITY_FILE2}" with tagName "EXCHANGE_MIC" to variable "MARKET"

    When I copy files below from local folder "${testdata.path}/Inbound" to the host "dmp.ssh.inbound" folder "${dmp.ssh.inbound.path}":
      | ${BRS_SECURITY_FILE2} |

    And I process files with below parameters and wait for the job to be completed
      | BUSINESS_FEED |                         |
      | FILE_PATTERN  | ${BRS_SECURITY_FILE2}   |
      | MESSAGE_TYPE  | EIS_MT_BRS_SECURITY_NEW |

    Then I execute below query and extract values of "MKT_OID" into same variables
      """
        select MKT_OID
        from ft_t_mkid
        where MKT_ID ='${MARKET}'
        and MKT_ID_CTXT_TYP ='MIC'
      """

    And I expect value of column "MKT_OID_COUNT" in the below SQL query equals to "1":
      """
        select count(distinct MKT_OID) as MKT_OID_COUNT
        from ft_t_isid
        where INSTR_ID IN (select INSTR_ID from ft_t_isid where iss_id='SMZ820187' and end_tms is null)
        and MKT_OID is not null
      """

    And I expect value of column "MKT_OID" in the below SQL query equals to "${MKT_OID}":
      """
        select distinct MKT_OID
        from ft_t_isid
        where INSTR_ID IN (select INSTR_ID from ft_t_isid where iss_id='SMZ820187' and end_tms is null)
        and MKT_OID is not null
      """

    And I expect value of column "MKT_OID" in the below SQL query equals to "${MKT_OID}":
      """
        select MKT_OID
        from ft_t_mkis
        where INSTR_ID IN (select INSTR_ID from ft_t_isid where iss_id='SMZ820187' and end_tms is null)
      """

  Scenario: TC_4: Load BNP file Market as XEUR and verify MKT_OID same across ISID, MKIS and MKID table

    Given I assign "tests/test-data/DevTest/TOM-3742" to variable "testdata.path"
    And I assign "bnp_24sep_5.out" to variable "BNP_SECURITY_FILE2"
    And I extract value from the xml file "${testdata.path}/Inbound/${BRS_SECURITY_FILE1}" with tagName "EXCHANGE_MIC" to variable "MARKET"

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
        where MKT_ID ='${MARKET}'
        and MKT_ID_CTXT_TYP ='MIC'
      """

    And I expect value of column "MKT_OID_COUNT" in the below SQL query equals to "1":
      """
        select count(distinct MKT_OID) as MKT_OID_COUNT
        from ft_t_isid
        where INSTR_ID IN (select INSTR_ID from ft_t_isid where iss_id='SMZ820187' and end_tms is null)
        and MKT_OID is not null
      """

    And I expect value of column "MKT_OID" in the below SQL query equals to "${MKT_OID}":
      """
        select distinct MKT_OID
        from ft_t_isid
        where INSTR_ID IN (select INSTR_ID from ft_t_isid where iss_id='SMZ820187' and end_tms is null)
        and MKT_OID is not null
      """

    And I expect value of column "MKT_OID" in the below SQL query equals to "${MKT_OID}":
      """
        select MKT_OID
        from ft_t_mkis
        where INSTR_ID IN (select INSTR_ID from ft_t_isid where iss_id='SMZ820187' and end_tms is null)
      """
