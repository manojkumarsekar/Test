#eisdev-6192 : Initial Version

@gc_interface_securities
@dmp_regression_unittest
@dmp_rdmsectype_derivation @esidev_6192
Feature: 001 | RDM Sec Type Derivation | Update Data
  Verify RDM Sec Type is updated only when last_chg_usr_id is like 'EIS%'

  Scenario: End date Instruments in GC and VD DB and Assign Variables

    Given I generate value with date format "YYYYMMdd" and assign to variable "VAR_SYSDATE"
    And I assign "tests/test-data/dmp-interfaces/Security/RDM_SECTYPE_DERIVATION" to variable "TESTDATA_PATH"
    And I assign "BES37CLN6_REPUR.xml" to variable "INPUT_FILENAME_BES37CLN6_REPUR"
    And I assign "BES37CLN6_TREPUR.xml" to variable "INPUT_FILENAME_BES37CLN6_TREPUR"

    Then I inactivate "BES37CLN6" instruments in GC database
    Then I inactivate "BES37CLN6" instruments in VD database

  Scenario: Loading F10 for BCUSIP BES37CLN6 with RDM Sec Type REPUR

    Given I copy files below from local folder "${TESTDATA_PATH}/inputfiles/testdata" to the host "dmp.ssh.inbound" folder "${dmp.ssh.inbound.path}":
      | ${INPUT_FILENAME_BES37CLN6_REPUR} |

    When I process files with below parameters and wait for the job to be completed
      | BUSINESS_FEED |                                   |
      | FILE_PATTERN  | ${INPUT_FILENAME_BES37CLN6_REPUR} |
      | MESSAGE_TYPE  | EIS_MT_BRS_SECURITY_NEW           |

    Then I expect workflow is processed in DMP with success record count as "1"

  Scenario: Data verification for ISCL
  Expect RDMSECTYPE = REPUR is calculated and stored into FT_T_ISCL table

    Then I expect value of column "iscl_repur" in the below SQL query equals to "REPUR":
    """
    select cl_value as iscl_repur from ft_t_iscl
    where instr_id in (select instr_id from ft_t_isid where iss_id = 'BES37CLN6' and end_tms is null)
    and end_tms is null
    and LAST_CHG_USR_ID = 'EIS_BRS_DMP_SECURITY'
    and trunc(START_TMS) = trunc(sysdate)
    and INDUS_CL_SET_ID = 'RDMSCTYP'
    """

  Scenario: Loading F10 for BCUSIP BES37CLN6 with RDM Sec Type TREPUR

    Given I copy files below from local folder "${TESTDATA_PATH}/inputfiles/testdata" to the host "dmp.ssh.inbound" folder "${dmp.ssh.inbound.path}":
      | ${INPUT_FILENAME_BES37CLN6_TREPUR} |

    When I process files with below parameters and wait for the job to be completed
      | BUSINESS_FEED |                                    |
      | FILE_PATTERN  | ${INPUT_FILENAME_BES37CLN6_TREPUR} |
      | MESSAGE_TYPE  | EIS_MT_BRS_SECURITY_NEW            |

    Then I expect workflow is processed in DMP with success record count as "1"

  Scenario: Data verification for ISCL
  Expect RDMSECTYPE = TREPUR is calculated and stored into FT_T_ISCL table

    Then I expect value of column "iscl_trepur" in the below SQL query equals to "TREPUR":
    """
    select cl_value as iscl_trepur from ft_t_iscl
    where instr_id in (select instr_id from ft_t_isid where iss_id = 'BES37CLN6' and end_tms is null)
    and end_tms is null
    and LAST_CHG_USR_ID = 'EIS_BRS_DMP_SECURITY'
    and trunc(START_TMS) = trunc(sysdate)
    and INDUS_CL_SET_ID = 'RDMSCTYP'
    """

  Scenario: Update Last_chg_usr_id to testuser

    Given I execute below query to "Update last_chg_usr_id to testuser"
      """
      UPDATE FT_T_ISCL SET LAST_CHG_USR_ID = 'testuser'
      where instr_id in (select instr_id from ft_t_isid where iss_id = 'BES37CLN6' and end_tms is null)
      and end_tms is null
      and LAST_CHG_USR_ID = 'EIS_BRS_DMP_SECURITY'
      and trunc(START_TMS) = trunc(sysdate)
      and INDUS_CL_SET_ID = 'RDMSCTYP'
      and cl_value = 'TREPUR';
      COMMIT
      """

  Scenario: Loading F10 for BCUSIP BES37CLN6 with RDM Sec Type REPUR

    Given I copy files below from local folder "${TESTDATA_PATH}/inputfiles/testdata" to the host "dmp.ssh.inbound" folder "${dmp.ssh.inbound.path}":
      | ${INPUT_FILENAME_BES37CLN6_REPUR} |

    When I process files with below parameters and wait for the job to be completed
      | BUSINESS_FEED |                                   |
      | FILE_PATTERN  | ${INPUT_FILENAME_BES37CLN6_REPUR} |
      | MESSAGE_TYPE  | EIS_MT_BRS_SECURITY_NEW           |

    Then I expect workflow is processed in DMP with success record count as "1"

  Scenario: Data verification for ISCL
  Expect RDMSECTYPE = TREPUR is not updated as the last change user id is not equal to  and stored into FT_T_ISCL table

    Then I expect value of column "iscl_trepur" in the below SQL query equals to "TREPUR":
    """
    select cl_value as iscl_trepur from ft_t_iscl
    where instr_id in (select instr_id from ft_t_isid where iss_id = 'BES37CLN6' and end_tms is null)
    and end_tms is null
    and LAST_CHG_USR_ID = 'testuser'
    and trunc(START_TMS) = trunc(sysdate)
    and INDUS_CL_SET_ID = 'RDMSCTYP'
    """

